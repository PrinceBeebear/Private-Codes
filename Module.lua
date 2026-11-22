local Flow = {
	services = {
		players = game:GetService("Players");
		workspace = game:GetService("Workspace");
		replicated = game:GetService("ReplicatedStorage");
		run_service = game:GetService("RunService");
		user_input_service = game:GetService("UserInputService");
        http_service = game:GetService("HttpService");
	};
	flags = {
		reanimated = false;
	};
	connections = {
		died = nil;
		character_removing = nil;
        animation_hb = nil;
	};
	callbacks = {
		on_play = nil,
		on_stop = nil,
	},
	saved = {
		character = nil;
		animate_enabled = nil;
		requires_neck = nil;
	};
	animation = {
        cache = {};
        state = {
            is_playing = false;
            current_url = nil;
            speed = 1.0;
            keyframes = nil;
            total_duration = 0;
            elapsed_time = 0;
        };
        original_motor_c0s = {};
        joints = {};
    };
};

local API = {};

local get_game_ragdoll_info = function(enable)
	local place_id = game.PlaceId;
	if place_id == 15546218972 or place_id == 6884319169 then
		-- Mic Up and Mic Up 18+
		local remote = Flow.services.replicated:WaitForChild("event_rag");
		return remote, {"Ball"}, false;
	elseif place_id == 5991163185 then
		-- Spray Paint
		local remote = Flow.services.replicated.Remotes.Physics.Ragdoll;
		return remote, {}, false;
	elseif place_id == 5683833663 then
		-- Ragdoll Engine (uses LocalEvent, not RemoteEvent)
		local local_event = Flow.services.replicated:WaitForChild("LocalRagdollEvent");
		return local_event, {enable}, true;
	end;
	return nil, nil, false;
end;

local get_local_player = function()
	local player = Flow.services.players.LocalPlayer;
	if not player then
		return "bad argument to 'get_local_player' (LocalPlayer not found; must run in a LocalScript)";
	end;
	return player;
end;

local get_char = function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return ("bad argument #1 to 'get_char' (Player expected, got %s)"):format(typeof(player));
	end;
	local character = player.Character;
	if not character or not character.Parent then
		return ("Player %s has no active character."):format(player.Name);
	end;
	return character;
end;

local fire_remote = function(remote, is_local, ...)
	if typeof(remote) ~= "Instance" then
		return ("bad argument to 'fire_remote' (Instance expected, got %s)"):format(typeof(remote));
	end;
	if is_local then
		-- Handle local events (BindableEvent)
		if not remote:IsA("BindableEvent") then
			return ("bad argument to 'fire_remote' (BindableEvent expected for local event, got %s)"):format(remote.ClassName);
		end;
		remote:Fire(...);
	else
		-- Handle remote events/functions
		if not (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
			return ("bad argument to 'fire_remote' (RemoteEvent or RemoteFunction expected, got %s)"):format(remote.ClassName);
		end;
		if remote:IsA("RemoteEvent") then
			remote:FireServer(...);
		else
			remote:InvokeServer(...);
		end;
	end;
	return nil;
end;

--- Enables/disables the native "Animate" script of a character.
local set_animate = function(character, disabled)
	local animate = character and character:FindFirstChild("Animate");
	if animate then
		animate.Disabled = disabled;
	end;
end;

--- Gets the native (real) character model for a player.
-- There is no clone anymore: the player's own character is used directly.
-- @param player (Player) [optional] - The player to get the character of. Defaults to LocalPlayer.
-- @return Model | nil
API.get_character = function(player)
	player = player or get_local_player();
	if typeof(player) == "string" then return nil end;
	return player.Character;
end;

--- Compatibility: this used to return the invisible clone. Now that the
-- module works without clones, it returns the native character while
-- reanimated (and nil when not reanimated, like the old clone did).
-- @param player (Player) [optional] - Defaults to LocalPlayer.
-- @return Model | nil
API.get_clone = function(player)
	if not Flow.flags.reanimated then return nil end;
	return API.get_character(player);
end;

--- Gets the real (native) character model for a player.
-- @param player (Player) [optional] - Defaults to LocalPlayer.
-- @return Model | nil
API.get_real_character = function(player)
	return API.get_character(player);
end;

--- Stops any currently playing animation.
API.stop_animation = function()
    if not Flow.animation.state.is_playing then return nil; end;

	local stopped_url = Flow.animation.state.current_url

    if Flow.connections.animation_hb then
        Flow.connections.animation_hb:Disconnect();
        Flow.connections.animation_hb = nil;
    end

    local player = get_local_player();
    if typeof(player) == "string" then return player end;

    local character = get_char(player);
    if typeof(character) ~= "string" then
        -- Restore the original pose of every joint we modified
        for motor, orig_c0 in pairs(Flow.animation.original_motor_c0s) do
            if motor and motor.Parent then
                motor.C0 = orig_c0;
            end
        end
        -- Resume the native animations (idle/walk)
        set_animate(character, Flow.saved.animate_enabled == false);
    end

    table.clear(Flow.animation.original_motor_c0s);
    table.clear(Flow.animation.joints);
    Flow.animation.state = { is_playing = false, current_url = nil, speed = 1.0, keyframes = nil, total_duration = 0, elapsed_time = 0 };

	if Flow.callbacks.on_stop then
		pcall(Flow.callbacks.on_stop, stopped_url)
	end
	return nil;
end;

--- Toggles the Reanimate state.
-- No clone is created: everything is done on the player's own character,
-- so noclip, double jump, clicking other players, tools, camera, etc.
-- keep working natively.
-- @param bool (boolean) - true to enable reanimation, false to disable.
-- @param remote (Instance) [optional] - A RemoteEvent/RemoteFunction/BindableEvent
--                 fired when toggling. Nothing is fired automatically otherwise;
--                 use API.ragdoll(true/false) for the game's own ragdoll.
-- @param args (table) [optional] - Arguments for the remote.
API.reanimate = function(bool, remote, args)
	if bool ~= true and bool ~= false then
		return ("bad argument #1 to 'reanimate' (boolean expected, got %s)"):format(typeof(bool));
	end;
	local player = get_local_player();
	if typeof(player) == "string" then return player end;

	if bool then
		if Flow.flags.reanimated then
			return "Already reanimated.";
		end;
		local real_char = get_char(player);
        if typeof(real_char) == "string" then return real_char end;
		local humanoid = real_char:FindFirstChildOfClass("Humanoid");
		if not humanoid then
			return "Real character is missing a Humanoid.";
		end;

		-- Save the native state so it can be restored later on
		local animate = real_char:FindFirstChild("Animate");
		Flow.saved.character = real_char;
		if animate then
			Flow.saved.animate_enabled = not animate.Disabled;
		else
			Flow.saved.animate_enabled = nil;
		end;
		Flow.saved.requires_neck = humanoid.RequiresNeck;

		-- Take over the animations: the native Animate script must be off,
		-- otherwise the idle/walk tracks overwrite our Motor6D C0 every frame.
		set_animate(real_char, true);
		humanoid.RequiresNeck = false;

		-- Automatic cleanup on death / respawn
		Flow.connections.character_removing = player.CharacterRemoving:Connect(function()
			API.reanimate(false);
		end);
		Flow.connections.died = humanoid.Died:Connect(function()
			API.reanimate(false);
		end);

		Flow.flags.reanimated = true;

		-- No ragdoll remote is fired automatically (it would drop the real
		-- body to the floor now that there is no clone to walk around).
		-- Use API.ragdoll(true) on demand in supported games.
		if remote then
			local is_local = typeof(remote) == "Instance" and remote:IsA("BindableEvent");
			local err = fire_remote(remote, is_local, unpack(args or {}));
            if err then return err end;
		end;
	else
		if not Flow.flags.reanimated then
			return nil;
		end;
        API.stop_animation();
		if remote then
			local is_local = typeof(remote) == "Instance" and remote:IsA("BindableEvent");
			local err = fire_remote(remote, is_local, unpack(args or {}));
            if err then return err end;
		end;
		for key, connection in pairs(Flow.connections) do
			if connection then
				connection:Disconnect();
				Flow.connections[key] = nil;
			end;
		end;

		-- Restore the native state of the character
		local saved_char = Flow.saved.character;
		if saved_char and saved_char.Parent then
			set_animate(saved_char, Flow.saved.animate_enabled == false);
			local saved_humanoid = saved_char:FindFirstChildOfClass("Humanoid");
			if saved_humanoid and Flow.saved.requires_neck ~= nil then
				saved_humanoid.RequiresNeck = Flow.saved.requires_neck;
			end;
		end;
		Flow.saved.character = nil;
		Flow.saved.animate_enabled = nil;
		Flow.saved.requires_neck = nil;
		Flow.flags.reanimated = false;
	end;
	return nil;
end;

--- Activates/deactivates the game's own ragdoll on demand (opt-in).
-- Detects the ragdoll remote of supported games (Mic Up, Spray Paint,
-- Ragdoll Engine). Nothing else in the API fires it automatically.
-- @param enable (boolean) - true to ragdoll, false to go back to normal.
-- @return nil | string - nil on success, error message otherwise.
API.ragdoll = function(enable)
	if enable ~= true and enable ~= false then
		return ("bad argument #1 to 'ragdoll' (boolean expected, got %s)"):format(typeof(enable));
	end;
	local remote, args, is_local = get_game_ragdoll_info(enable);
	if not remote then
		return "No ragdoll remote found for this game.";
	end;
	return fire_remote(remote, is_local, unpack(args));
end;

--- Plays an animation on the native character.
-- @param url (string) - The URL of the keyframe script.
-- @param speed (number) [optional] - The playback speed multiplier. Defaults to 1.
API.play_animation = function(url, speed)
    if not Flow.flags.reanimated then
        return "Cannot play animation, not reanimated.";
    end

    local player = get_local_player();
    if typeof(player) == "string" then return player end;

    local character = get_char(player);
    if typeof(character) == "string" then
        return "Cannot play animation, character not found.";
    end

    if Flow.animation.state.is_playing and Flow.animation.state.current_url == url then
        API.stop_animation();
        return nil;
    end

    API.stop_animation();

    -- Take full control of the character's animations
    set_animate(character, true);
    local anim_controller = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
    if anim_controller then
        for _, track in ipairs(anim_controller:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end

    local anim = Flow.animation;
    anim.state.speed = tonumber(speed) or 1.0;

    local keyframe_data = anim.cache[url];
    if not keyframe_data then
        local success, response = pcall(game.HttpGet, game, url);
		if not success then return "Animation Error: Failed to fetch URL." end

        local loaded_fn, err = loadstring(response);
		if not loaded_fn then return "Animation Error: Invalid script from URL. " .. tostring(err) end;

		local run_success, data = pcall(loaded_fn)
		if not run_success then return "Animation Error: Script from URL failed to execute. " .. tostring(data) end
        keyframe_data = data;

        if typeof(keyframe_data) ~= "table" then return "Animation Error: Script from URL did not return a table." end;

        anim.cache[url] = keyframe_data;
    end

    local keyframes = keyframe_data[next(keyframe_data)];
	if not keyframes or #keyframes == 0 then
		return "No keyframes array found for animation URL: " .. url;
	end

    anim.state.keyframes = keyframes;

    table.clear(anim.joints);
    table.clear(anim.original_motor_c0s);
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("Motor6D") and descendant.Part1 then
            anim.joints[descendant.Part1.Name] = descendant;
            anim.original_motor_c0s[descendant] = descendant.C0;
        end
    end

    anim.state.is_playing = true;
    anim.state.current_url = url;
    anim.state.total_duration = keyframes[#keyframes].Time;
	if anim.state.total_duration <= 0 then API.stop_animation(); return nil end;

	anim.state.elapsed_time = 0;

	if Flow.callbacks.on_play then
		pcall(Flow.callbacks.on_play, anim.state.current_url)
	end

	Flow.connections.animation_hb = Flow.services.run_service.Heartbeat:Connect(function(deltaTime)
		if not anim.state.is_playing then return end;

		anim.state.elapsed_time = (anim.state.elapsed_time + (deltaTime * anim.state.speed)) % anim.state.total_duration;

		local current_frame, next_frame;
		for i = 1, #anim.state.keyframes - 1 do
			if anim.state.elapsed_time >= anim.state.keyframes[i].Time and anim.state.elapsed_time < anim.state.keyframes[i+1].Time then
				current_frame = anim.state.keyframes[i];
				next_frame = anim.state.keyframes[i+1];
				break;
			end
		end
		if not current_frame then
			current_frame = anim.state.keyframes[#anim.state.keyframes];
			next_frame = anim.state.keyframes[1];
		end

		local frame_duration = next_frame.Time - current_frame.Time;
		if frame_duration <= 0 then frame_duration = anim.state.total_duration end;

		local alpha = (frame_duration > 0) and (anim.state.elapsed_time - current_frame.Time) / frame_duration or 0;
		alpha = math.clamp(alpha, 0, 1)

		for partName, pose_cframe in pairs(current_frame.Data or {}) do
            local motor = anim.joints[partName];
            if motor and anim.original_motor_c0s[motor] then
                local original_c0 = anim.original_motor_c0s[motor];
                local next_pose_cframe = next_frame.Data and next_frame.Data[partName];

                if next_pose_cframe then
                    motor.C0 = original_c0 * pose_cframe:Lerp(next_pose_cframe, alpha);
                else
                    motor.C0 = original_c0 * pose_cframe;
                end
            end
		end
	end);
	return nil;
end;

--- Sets the playback speed for any currently playing animation.
-- @param speed (number) - The new playback speed multiplier.
API.set_animation_speed = function(speed)
    Flow.animation.state.speed = tonumber(speed) or 1.0;
end;

--- Registers a callback function to be called when an animation starts playing.
-- @param callback (function) - The function to call. It receives the animation URL as an argument.
API.on_animation_play = function(callback)
	if type(callback) == "function" then
		Flow.callbacks.on_play = callback
	end
end

--- Registers a callback function to be called when an animation stops.
-- @param callback (function) - The function to call. It receives the animation URL that was stopped.
API.on_animation_stop = function(callback)
	if type(callback) == "function" then
		Flow.callbacks.on_stop = callback
	end
end

--- Returns the current animation playback state.
-- @return boolean, string | nil - is_playing, current_url
API.is_animation_playing = function()
	return Flow.animation.state.is_playing, Flow.animation.state.current_url
end

--- Returns true if the local player is currently reanimated.
-- @return boolean
API.is_reanimated = function()
	return Flow.flags.reanimated;
end;

return API;
