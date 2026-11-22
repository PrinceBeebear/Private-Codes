-- Reanim_module.lua — API de reanimación de Flow (modo híbrido)
--
-- El módulo puede funcionar de dos formas:
--
--   * SIN clon (por defecto): todo se hace sobre tu personaje nativo.
--     noclip, doble salto, click sobre otros jugadores, tools y cámara
--     funcionan de forma nativa (sin swap de personaje ni partes invisibles).
--     El ragdoll del juego NUNCA se dispara solo: usa API.ragdoll(true/false).
--
--   * CON clon (comportamiento original): se crea un personaje invisible
--     "Reanimation" que copia tu cuerpo cada frame, se hace swap de
--     player.Character y se auto-detecta/dispara el ragdoll del juego
--     (Mic Up, Spray Paint, Ragdoll Engine). Útil cuando el juego
--     reproduce animaciones o necesita ragdoll replicado.
--
-- Cambio de modo:
--   API.set_use_clone(true/false)   -- no se puede cambiar mientras estés reanimado
--   API.get_use_clone()             -- modo que usará el próximo reanimate(true)
--   API.is_clone_mode()             -- si la sesión ACTIVA está usando el clon
--   _G.FlowReanimUseClone = true    -- bandera global: tiene prioridad, persiste
--                                    -- entre cargas del módulo (útil desde RR.lua)
--
-- Compatibilidad: get_clone() y get_real_character() siguen existiendo.
local Flow = {
	services = {
		players = game:GetService("Players");
		workspace = game:GetService("Workspace");
		replicated = game:GetService("ReplicatedStorage");
		run_service = game:GetService("RunService");
		user_input_service = game:GetService("UserInputService");
		http_service = game:GetService("HttpService");
	};
	config = {
		use_clone = false;
	};
	flags = {
		reanimated = false;
		using_clone = false;
	};
	clones = {};
	real_chars = {};
	connections = {
		hb = nil;
		died = nil;
		real_char_child_removed = nil;
		character_removing = nil;
		clone_died = nil;
		clone_char_child_removed = nil;
		animation_hb = nil;
	};
	callbacks = {
		on_play = nil,
		on_stop = nil,
	};
	saved = {
		character = nil;
		animate_enabled = nil;
		requires_neck = nil;
		gui_reset = nil;
		remote = nil;
		remote_args = nil;
		remote_is_local = nil;
		remote_from_game = false;
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

--- Determines whether the clone mode should be used for the next session.
-- The global flag _G.FlowReanimUseClone wins when it is a boolean (it lets
-- external scripts like RR.lua pick the mode without touching this module).
-- @return boolean
local resolve_use_clone = function()
	local ok, value = pcall(function()
		if type(_G) ~= "table" then
			return nil;
		end;
		return rawget(_G, "FlowReanimUseClone");
	end);
	if ok and type(value) == "boolean" then
		return value;
	end;
	return Flow.config.use_clone == true;
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

local set_model_transparency = function(model, transparency)
	if not model then
		return;
	end;
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = transparency;
		end;
	end;
end;

--- Records the ResetOnSpawn of every ScreenGui of the player and turns it
-- off, so assigning player.Character does not wipe the UI.
-- @return table - map of ScreenGui -> original ResetOnSpawn
local save_gui_reset = function(player)
	local saved = {};
	local player_gui = player:FindFirstChildWhichIsA("PlayerGui");
	if player_gui then
		for _, gui in ipairs(player_gui:GetChildren()) do
			if gui:IsA("ScreenGui") then
				saved[gui] = gui.ResetOnSpawn;
				gui.ResetOnSpawn = false;
			end;
		end;
	end;
	return saved;
end;

--- Sets ResetOnSpawn on every ScreenGui of the player.
local set_gui_reset = function(player, value)
	local player_gui = player:FindFirstChildWhichIsA("PlayerGui");
	if player_gui then
		for _, gui in ipairs(player_gui:GetChildren()) do
			if gui:IsA("ScreenGui") then
				gui.ResetOnSpawn = value;
			end;
		end;
	end;
end;

--- Restores the ResetOnSpawn values captured by save_gui_reset.
local restore_gui_reset = function(saved)
	if not saved then
		return;
	end;
	for gui, value in pairs(saved) do
		if gui.Parent then
			gui.ResetOnSpawn = value;
		end;
	end;
end;

--- Creates the invisible clone used by the clone mode.
-- @param model (Instance) - The real character to clone.
-- @return Model | string - the clone, or an error message.
local clone_char = function(model)
	if typeof(model) ~= "Instance" then
		return ("bad argument #1 to 'clone_char' (Instance expected, got %s)"):format(typeof(model));
	end;
	model.Archivable = true;
	local new_clone = model:Clone();
	model.Archivable = false;
	new_clone.Name = "Reanimation";
	new_clone.Parent = Flow.services.workspace;
	local clone_animate = new_clone:FindFirstChild("Animate");
	if not clone_animate then
		clone_animate = new_clone:WaitForChild("Animate", 5);
	end;
	if clone_animate then
		clone_animate.Disabled = true;
	end;
	local clone_humanoid = new_clone:FindFirstChildOfClass("Humanoid");
	if clone_humanoid then
		clone_humanoid.RequiresNeck = false;
		clone_humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
	end;
	local force_field = new_clone:FindFirstChildWhichIsA("ForceField");
	if force_field then
		force_field:Destroy();
	end;
	return new_clone;
end;

--- Gets the active character model of a player (player.Character).
-- While the clone mode is reanimated this is the invisible clone (it is the
-- model that moves); otherwise it is the native character.
-- @param player (Player) [optional] - Defaults to LocalPlayer.
-- @return Model | nil
API.get_character = function(player)
	player = player or get_local_player();
	if typeof(player) == "string" then return nil end;
	return player.Character;
end;

--- Compatibility accessor. In clone mode it returns the clone while
-- reanimated; without clone it returns the native character while
-- reanimated (there is no clone to return). Nil when not reanimated,
-- matching the old clone semantics.
-- @param player (Player) [optional] - Defaults to LocalPlayer.
-- @return Model | nil
API.get_clone = function(player)
	if not Flow.flags.reanimated then return nil end;
	if Flow.flags.using_clone then
		player = player or get_local_player();
		if typeof(player) == "string" then return nil end;
		return Flow.clones[player];
	end;
	return API.get_character(player);
end;

--- Gets the real (native) character model for a player.
-- @param player (Player) [optional] - Defaults to LocalPlayer.
-- @return Model | nil
API.get_real_character = function(player)
	player = player or get_local_player();
	if typeof(player) == "string" then return nil end;
	return Flow.real_chars[player] or player.Character;
end;

--- Switches between clone / no-clone mode for the next reanimate(true).
-- @param bool (boolean) - true to use the clone, false to use the native character.
-- @return nil | string - nil on success, error message otherwise.
API.set_use_clone = function(bool)
	if bool ~= true and bool ~= false then
		return ("bad argument #1 to 'set_use_clone' (boolean expected, got %s)"):format(typeof(bool));
	end;
	if Flow.flags.reanimated then
		return "Cannot change the reanimation mode while reanimated. Call reanimate(false) first.";
	end;
	Flow.config.use_clone = bool;
	pcall(function()
		if type(_G) == "table" then
			_G.FlowReanimUseClone = bool;
		end;
	end);
	return nil;
end;

--- Returns the mode the next reanimate(true) will use.
-- @return boolean
API.get_use_clone = function()
	return resolve_use_clone();
end;

--- Returns true while an active reanimation session is using the clone.
-- @return boolean
API.is_clone_mode = function()
	return Flow.flags.using_clone == true;
end;

--- Stops any currently playing animation and restores the original poses.
API.stop_animation = function()
	if not Flow.animation.state.is_playing then return nil; end;

	local stopped_url = Flow.animation.state.current_url;

	if Flow.connections.animation_hb then
		Flow.connections.animation_hb:Disconnect();
		Flow.connections.animation_hb = nil;
	end;

	local player = get_local_player();
	if typeof(player) == "string" then return player end;

	-- Restore the original pose of every joint we modified
	for motor, orig_c0 in pairs(Flow.animation.original_motor_c0s) do
		if motor and motor.Parent then
			motor.C0 = orig_c0;
		end;
	end;

	-- Resume the native animations of the character we were animating
	if Flow.flags.using_clone then
		local cloned_char = Flow.clones[player];
		if cloned_char then
			set_animate(cloned_char, false);
		end;
	else
		local native_char = get_char(player);
		if typeof(native_char) ~= "string" then
			set_animate(native_char, Flow.saved.animate_enabled == false);
		end;
	end;

	table.clear(Flow.animation.original_motor_c0s);
	table.clear(Flow.animation.joints);
	Flow.animation.state = { is_playing = false, current_url = nil, speed = 1.0, keyframes = nil, total_duration = 0, elapsed_time = 0 };

	if Flow.callbacks.on_stop then
		pcall(Flow.callbacks.on_stop, stopped_url);
	end;
	return nil;
end;

--- Toggles the Reanimate state.
-- The mode comes from API.get_use_clone() (see the header of this file).
-- Clone mode reproduces the original behavior: invisible clone + swap of
-- player.Character + auto-detection of the game's ragdoll remote.
-- No-clone mode only touches the native character (Animate/RequiresNeck) and
-- never fires anything by itself: pass a remote explicitly or use
-- API.ragdoll(true/false) for the game's own ragdoll.
-- @param bool (boolean) - true to enable reanimation, false to disable.
-- @param remote (Instance) [optional] - A RemoteEvent/RemoteFunction/BindableEvent
--                 fired when toggling. When omitted, the remote used on
--                 enable is reused on disable.
-- @param args (table) [optional] - Arguments for the remote.
-- @return nil | string - nil on success, error message otherwise.
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

		local use_clone = resolve_use_clone();

		local real_hrp = nil;
		if use_clone then
			real_hrp = real_char:FindFirstChild("HumanoidRootPart");
			if not real_hrp then
				return "Real character is missing a HumanoidRootPart, cannot reanimate.";
			end;
		end;

		-- Resolve the remote of this session. Only clone mode auto-detects
		-- the game's ragdoll remote (original behavior); without clone
		-- nothing is fired unless a remote is passed explicitly.
		local session_remote = remote;
		local session_args = args;
		local session_is_local = false;
		local session_from_game = false;
		if session_remote then
			session_is_local = typeof(session_remote) == "Instance" and session_remote:IsA("BindableEvent");
		elseif use_clone then
			local game_remote, game_args, game_is_local = get_game_ragdoll_info(true);
			if game_remote then
				session_remote = game_remote;
				session_args = game_args;
				session_is_local = game_is_local;
				session_from_game = true;
			end;
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
		Flow.saved.remote = session_remote;
		Flow.saved.remote_args = session_args;
		Flow.saved.remote_is_local = session_is_local;
		Flow.saved.remote_from_game = session_from_game;

		if use_clone then
			-- ---------------------------------------------------- clone mode
			local cloned_char = clone_char(real_char);
			if typeof(cloned_char) == "string" then return cloned_char end;
			local cloned_humanoid = cloned_char:FindFirstChildOfClass("Humanoid");
			if not cloned_humanoid then
				cloned_char:Destroy();
				return "Cloned character failed to create or is missing a Humanoid.";
			end;
			Flow.real_chars[player] = real_char;
			Flow.clones[player] = cloned_char;
			set_model_transparency(cloned_char, 1);

			-- Swap without wiping the player's UI
			Flow.saved.gui_reset = save_gui_reset(player);
			player.Character = cloned_char;
			local clone_animate = cloned_char:FindFirstChild("Animate");
			if not clone_animate then
				clone_animate = cloned_char:WaitForChild("Animate", 5);
			end;
			if clone_animate then
				clone_animate.Disabled = true;
				clone_animate.Disabled = false;
			end;
			restore_gui_reset(Flow.saved.gui_reset);

			-- Follow the clone with the real body every frame
			Flow.connections.hb = Flow.services.run_service.Heartbeat:Connect(function()
				if not real_char.Parent or not cloned_char.Parent then
					API.reanimate(false);
					return;
				end;
				for _, part in ipairs(real_char:GetChildren()) do
					local clone_part = cloned_char:FindFirstChild(part.Name);
					if part:IsA("BasePart") and clone_part then
						part.CFrame = clone_part.CFrame;
						part.Velocity = Vector3.new();
					end;
				end;
			end);

			Flow.connections.died = humanoid.Died:Connect(function()
				API.reanimate(false);
			end);
			Flow.connections.real_char_child_removed = real_char.ChildRemoved:Connect(function(child)
				if child == humanoid or child == real_hrp then
					API.reanimate(false);
				end;
			end);
			Flow.connections.clone_char_child_removed = cloned_char.ChildRemoved:Connect(function(child)
				if child == cloned_humanoid then
					API.reanimate(false);
				end;
			end);
			Flow.connections.clone_died = cloned_humanoid.Died:Connect(function()
				if humanoid.Health > 0 then
					humanoid.Health = 0;
				else
					API.reanimate(false);
				end;
			end);
			Flow.connections.character_removing = player.CharacterRemoving:Connect(function(character_being_removed)
				if character_being_removed == cloned_char or character_being_removed == real_char then
					API.reanimate(false);
				end;
			end);
		else
			-- ------------------------------------------------- native mode
			-- Take over the animations: the native Animate script must be off,
			-- otherwise the idle/walk tracks overwrite our Motor6D C0.
			set_animate(real_char, true);
			humanoid.RequiresNeck = false;

			-- Automatic cleanup on death / respawn
			Flow.connections.character_removing = player.CharacterRemoving:Connect(function()
				API.reanimate(false);
			end);
			Flow.connections.died = humanoid.Died:Connect(function()
				API.reanimate(false);
			end);
		end;

		Flow.flags.using_clone = use_clone;
		Flow.flags.reanimated = true;

		if session_remote then
			local fire_err = fire_remote(session_remote, session_is_local, unpack(session_args or {}));
			if fire_err then return fire_err end;
		end;
	else
		if not Flow.flags.reanimated then
			return nil;
		end;
		API.stop_animation();

		local session_remote = remote;
		local session_args = args;
		local session_is_local = false;
		if session_remote then
			session_is_local = typeof(session_remote) == "Instance" and session_remote:IsA("BindableEvent");
		elseif Flow.saved.remote then
			if Flow.saved.remote_from_game then
				-- Re-detect with enable=false so toggle args are correct
				local game_remote, game_args, game_is_local = get_game_ragdoll_info(false);
				if game_remote then
					session_remote = game_remote;
					session_args = game_args;
					session_is_local = game_is_local;
				else
					session_remote = Flow.saved.remote;
					session_args = Flow.saved.remote_args;
					session_is_local = Flow.saved.remote_is_local == true;
				end;
			else
				session_remote = Flow.saved.remote;
				session_args = Flow.saved.remote_args;
				session_is_local = Flow.saved.remote_is_local == true;
			end;
		end;

		local fire_err = nil;
		if session_remote then
			fire_err = fire_remote(session_remote, session_is_local, unpack(session_args or {}));
		end;

		for key, connection in pairs(Flow.connections) do
			if connection then
				connection:Disconnect();
				Flow.connections[key] = nil;
			end;
		end;

		local saved_char = Flow.saved.character;
		if Flow.flags.using_clone then
			-- ------------------------------------------------- clone mode off
			local cloned_char = Flow.clones[player];
			if cloned_char and cloned_char.Parent then
				cloned_char:Destroy();
			end;
			Flow.clones[player] = nil;
			if saved_char and saved_char.Parent then
				set_model_transparency(saved_char, 0);
				local hrp = saved_char:FindFirstChild("HumanoidRootPart");
				if hrp then
					hrp.Transparency = 1;
				end;
				set_gui_reset(player, false);
				player.Character = saved_char;
			end;
			restore_gui_reset(Flow.saved.gui_reset);
			Flow.real_chars[player] = nil;
		else
			-- ----------------------------------------------- native mode off
			if saved_char and saved_char.Parent then
				set_animate(saved_char, Flow.saved.animate_enabled == false);
				local saved_humanoid = saved_char:FindFirstChildOfClass("Humanoid");
				if saved_humanoid and Flow.saved.requires_neck ~= nil then
					saved_humanoid.RequiresNeck = Flow.saved.requires_neck;
				end;
			end;
		end;

		Flow.saved.character = nil;
		Flow.saved.animate_enabled = nil;
		Flow.saved.requires_neck = nil;
		Flow.saved.gui_reset = nil;
		Flow.saved.remote = nil;
		Flow.saved.remote_args = nil;
		Flow.saved.remote_is_local = nil;
		Flow.saved.remote_from_game = false;
		Flow.flags.reanimated = false;
		Flow.flags.using_clone = false;

		return fire_err;
	end;
	return nil;
end;

--- Activates/deactivates the game's own ragdoll on demand (opt-in).
-- Detects the ragdoll remote of supported games (Mic Up, Spray Paint,
-- Ragdoll Engine). Without clone mode nothing else in the API fires it.
-- In clone mode reanimate() still auto-fires it (original behavior).
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

--- Plays an animation on the active character (clone in clone mode, the
-- native character otherwise).
-- @param url (string) - The URL of the keyframe script.
-- @param speed (number) [optional] - The playback speed multiplier. Defaults to 1.
API.play_animation = function(url, speed)
	if not Flow.flags.reanimated then
		return "Cannot play animation, not reanimated.";
	end;

	local player = get_local_player();
	if typeof(player) == "string" then return player end;

	local target_char;
	if Flow.flags.using_clone then
		target_char = Flow.clones[player];
		if not target_char then
			return "Cannot play animation, clone character not found.";
		end;
	else
		local native_char = get_char(player);
		if typeof(native_char) == "string" then
			return "Cannot play animation, character not found.";
		end;
		target_char = native_char;
	end;

	if Flow.animation.state.is_playing and Flow.animation.state.current_url == url then
		API.stop_animation();
		return nil;
	end

	API.stop_animation();

	-- Take full control of the character's animations
	set_animate(target_char, true);
	local anim_controller = target_char:FindFirstChildOfClass("Humanoid") or target_char:FindFirstChildOfClass("AnimationController")
	if anim_controller then
		for _, track in ipairs(anim_controller:GetPlayingAnimationTracks()) do
			track:Stop()
		end
	end

	local anim = Flow.animation;
	anim.state.speed = tonumber(speed) or 1.0;

	local keyframe_data = anim.cache[url];
	if not keyframe_data then
		local success_fetch, response = pcall(game.HttpGet, game, url);
		if not success_fetch then return "Animation Error: Failed to fetch URL." end

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
	for _, descendant in ipairs(target_char:GetDescendants()) do
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
