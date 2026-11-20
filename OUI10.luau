local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ConfigHttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui", 10)
if not PlayerGui then
	return
end

local GUI_NAME = "_0x51Ae"
local GuiParent = PlayerGui
pcall(function()
	if type(gethui) == "function" then
		local executorGui = gethui()
		if executorGui then
			GuiParent = executorGui
		end
	end
end)

if _G.OUI10CharacterConnection then
	pcall(function()
		_G.OUI10CharacterConnection:Disconnect()
	end)
end
_G.OUI10CharacterConnection = player.CharacterAdded:Connect(function()
	task.wait(1)
	local existingGui = GuiParent:FindFirstChild(GUI_NAME) or PlayerGui:FindFirstChild(GUI_NAME)
	if existingGui then
		existingGui.ResetOnSpawn = false
		_G.OUI10Gui = existingGui
	end
end)

if _G.OUI10Loaded then
	local existingGui = GuiParent:FindFirstChild(GUI_NAME) or PlayerGui:FindFirstChild(GUI_NAME)
	if existingGui then
		_G.OUI10Gui = existingGui
		return
	end
	_G.OUI10Loaded = false
	_G.OUI10Gui = nil
end
_G.OUI10Loaded = true

local CONFIG_DIRECTORY = "C:\\Users\\Prince\\AppData\\Local\\Potassium\\workspace\\Flow"
local CONFIG_PATH = CONFIG_DIRECTORY .. "\\config.json"
local CONFIG_CIPHER_KEY = "OUI10-Flow-Settings-v1"
local configDirectoryReady = false

local function ensureConfigDirectory()
	if type(isfolder) == "function" then
		local ok, exists = pcall(isfolder, CONFIG_DIRECTORY)
		if ok and exists then
			configDirectoryReady = true
			return true
		end
	end
	if type(makefolder) ~= "function" then
		warn("OUI10: executor does not offer makefolder to save the config.")
		return false
	end
	local ok, err = pcall(makefolder, CONFIG_DIRECTORY)
	if ok then
		configDirectoryReady = true
		return true
	end
	if type(isfolder) == "function" then
		local existsOk, exists = pcall(isfolder, CONFIG_DIRECTORY)
		if existsOk and exists then
			configDirectoryReady = true
			return true
		end
	end
	warn("OUI10: could not create the config folder: " .. tostring(err))
	return false
end

local function xorConfigBytes(value)
	local result = table.create(#value)
	for index = 1, #value do
		local byte = bit32.bxor(string.byte(value, index), string.byte(CONFIG_CIPHER_KEY, ((index - 1) % #CONFIG_CIPHER_KEY) + 1))
		result[index] = string.char(byte)
	end
	return table.concat(result)
end

local function decodeConfigHex(value)
	if type(value) ~= "string" or #value % 2 ~= 0 or value:find("[^%x]") then
		return nil
	end
	local bytes = table.create(#value / 2)
	for index = 1, #value, 2 do
		bytes[#bytes + 1] = string.char(tonumber(value:sub(index, index + 1), 16))
	end
	return table.concat(bytes)
end

local function loadSavedConfig()
	if not ensureConfigDirectory() then
		return
	end
	if type(isfile) ~= "function" or type(readfile) ~= "function" then
		warn("OUI10: executor does not offer isfile/readfile; using default settings.")
		return
	end
	local fileOk, exists = pcall(isfile, CONFIG_PATH)
	if not fileOk or not exists then
		return
	end
	local readOk, content = pcall(readfile, CONFIG_PATH)
	if not readOk then
		warn("OUI10: could not read config.json: " .. tostring(content))
		return
	end
	local outerOk, envelope = pcall(function()
		return ConfigHttpService:JSONDecode(content)
	end)
	if not outerOk or type(envelope) ~= "table" or envelope.version ~= 1 then
		warn("OUI10: config.json has an unrecognized format; using default settings.")
		return
	end
	local encrypted = decodeConfigHex(envelope.data)
	if not encrypted then
		warn("OUI10: config.json contains invalid encrypted data.")
		return
	end
	local configOk, config = pcall(function()
		return ConfigHttpService:JSONDecode(xorConfigBytes(encrypted))
	end)
	if not configOk or type(config) ~= "table" then
		warn("OUI10: could not decrypt config.json; using default settings.")
		return
	end
	if config.timeFormat == 12 or config.timeFormat == 24 then
		_G.OUI10TimeFormat = config.timeFormat
	end
	if config.navPosition == "top" or config.navPosition == "bottom" or config.navPosition == "left" or config.navPosition == "right" then
		_G.OUI10NavPosition = config.navPosition
	end
	if type(config.blurEnabled) == "boolean" then
		_G.OUI10BlurEnabled = config.blurEnabled
	end
	if type(config.rpdMode) == "number" then
		local rpd = math.clamp(math.floor(config.rpdMode), 1, 4)
		_G.OUI10RPDMode = rpd
	end
	if type(config.autoExec) == "table" then
		local autoExec = {}
		for command, enabled in pairs(config.autoExec) do
			if type(command) == "string" and enabled == true then
				autoExec[command] = true
			end
		end
		_G.OUI10AutoExec = autoExec
	end
	if type(config.customCommands) == "table" then
		local customs = {}
		for name, cmdData in pairs(config.customCommands) do
			if type(name) == "string" and type(cmdData) == "table" and type(cmdData.code) == "string" then
				customs[name] = { desc = type(cmdData.desc) == "string" and cmdData.desc or "", code = cmdData.code }
			end
		end
		_G.OUI10CustomCmds = customs
	end
	if type(config.dnd) == "table" then
		local dnd = {}
		for key, value in pairs(config.dnd) do
			if key == "DND_Enabled" or key == "DND_HideGame" or key == "DND_HideBanner" or key == "DND_HideAvatar"
				or key == "DND_HideName" or key == "DND_HidePlayers" or key == "DND_HidePing" or key == "DND_BlockJoin" then
				if type(value) == "boolean" then
					dnd[key] = value
				end
			elseif key == "DND_BannerId" or key == "DND_AvatarId" or key == "DND_CustomName" then
				if type(value) == "string" then
					dnd[key] = value
				end
			end
		end
		_G.OUI10DND = dnd
	end
	if type(config.favorites) == "table" then
		local favorites = {}
		for command, isFavorite in pairs(config.favorites) do
			if type(command) == "string" and isFavorite == true then
				favorites[command] = true
			end
		end
		_G.OUI10Favs = favorites
	end
end

local function saveConfig()
	if type(writefile) ~= "function" then
		warn("OUI10: executor does not offer writefile to save the config.")
		return false
	end
	if not configDirectoryReady and not ensureConfigDirectory() then
		return false
	end
	local config = {
		timeFormat = tonumber(_G.OUI10TimeFormat) == 12 and 12 or 24,
		navPosition = _G.OUI10NavPosition or "top",
		blurEnabled = _G.OUI10BlurEnabled == true,
		rpdMode = math.clamp(math.floor(tonumber(_G.OUI10RPDMode) or 1), 1, 4),
		autoExec = {},
		customCommands = {},
		dnd = {},
		favorites = {},
	}
	local dnd = type(_G.OUI10DND) == "table" and _G.OUI10DND or {}
	for _, key in ipairs({
		"DND_Enabled",
		"DND_HideGame",
		"DND_HideBanner",
		"DND_BannerId",
		"DND_HideAvatar",
		"DND_AvatarId",
		"DND_HideName",
		"DND_CustomName",
		"DND_HidePlayers",
		"DND_HidePing",
		"DND_BlockJoin",
	}) do
		local value = dnd[key]
		local textValue = key == "DND_BannerId" or key == "DND_AvatarId" or key == "DND_CustomName"
		if (textValue and type(value) == "string") or (not textValue and type(value) == "boolean") then
			config.dnd[key] = value
		end
	end
	local favorites = type(_G.OUI10Favs) == "table" and _G.OUI10Favs or {}
	for command, isFavorite in pairs(favorites) do
		if type(command) == "string" and isFavorite == true then
			config.favorites[command] = true
		end
	end
	local autoExec = type(_G.OUI10AutoExec) == "table" and _G.OUI10AutoExec or {}
	for command, enabled in pairs(autoExec) do
		if type(command) == "string" and enabled == true then
			config.autoExec[command] = true
		end
	end
	local customCommands = type(_G.OUI10CustomCmds) == "table" and _G.OUI10CustomCmds or {}
	for name, cmdData in pairs(customCommands) do
		if type(name) == "string" and type(cmdData) == "table" and type(cmdData.code) == "string" then
			config.customCommands[name] = { desc = tostring(cmdData.desc or ""), code = cmdData.code }
		end
	end
	local ok, result = pcall(function()
		local plainText = ConfigHttpService:JSONEncode(config)
		local encrypted = xorConfigBytes(plainText)
		local hexBytes = table.create(#encrypted)
		for index = 1, #encrypted do
			hexBytes[index] = string.format("%02X", string.byte(encrypted, index))
		end
		local hex = table.concat(hexBytes)
		local jsonLine = ConfigHttpService:JSONEncode({version = 1, data = hex})
		writefile(CONFIG_PATH, jsonLine)
	end)
	if not ok then
		warn("OUI10: could not save config.json: " .. tostring(result))
		return false
	end
	return true
end

loadSavedConfig()
_G.OUI10RPDMode = math.clamp(math.floor(tonumber(_G.OUI10RPDMode) or 1), 1, 4)

-- Tuning & Margins --------------------------------------------------------

local HEADER_Y = 66
local SUB_Y = 100
local SUB_TEXT_SIZE = 15
local SUB_COLOR = Color3.fromRGB(180, 182, 192)

local AFEM_STROKE = Color3.fromRGB(179, 179, 179)
local NAV_SELECTED_COLOR = Color3.fromRGB(232, 234, 240)
local NAV_ICON_SELECTED_COLOR = Color3.new(0, 0, 0)
local LIGHT_TR_OPEN = 0.35
local BLUR_OPEN = 22
local WHITE = Color3.new(1, 1, 1)

-- Single typography: the WHOLE interface uses the same font --
local UI_FONT = Enum.Font.GothamMedium

-- Utilities ---------------------------------------------------------------

local EASE_OUT = Enum.EasingDirection.Out

-- Active tweens per instance (weak keys): every entry keeps the tween
-- object together with the goal table it was created with. When a new
-- tween shares only SOME properties with an older one, the older tween
-- is cancelled and its remaining properties are folded into the new
-- one, so a cancel never silently drops another property animation
-- (before this, a Size-only tween cancelled a Position+Size tween and
-- the nav buttons simply stopped moving to their new slot). --
local activeTweens = setmetatable({}, { __mode = "k" })

local function tween(object, goal, duration, style)
	local animation = nil
	local finalGoal = nil
	local ok = pcall(function()
		local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, EASE_OUT)
		local prev = activeTweens[object]
		if not prev then
			prev = {}
			activeTweens[object] = prev
		end
		-- Older entries that share a property with the new goal are
		-- cancelled; the properties they still own (and the new goal
		-- does not set) ride along in the replacement tween. --
		local carried = nil
		for index = #prev, 1, -1 do
			local entry = prev[index]
			local overlaps = false
			for prop in pairs(goal) do
				if entry.goal[prop] ~= nil then
					overlaps = true
					break
				end
			end
			if overlaps then
				pcall(function()
					entry.animation:Cancel()
				end)
				table.remove(prev, index)
				for prop, value in pairs(entry.goal) do
					if goal[prop] == nil and (not carried or carried[prop] == nil) then
						carried = carried or {}
						carried[prop] = value
					end
				end
			end
		end
		finalGoal = goal
		if carried then
			finalGoal = {}
			for prop, value in pairs(goal) do
				finalGoal[prop] = value
			end
			for prop, value in pairs(carried) do
				if finalGoal[prop] == nil then
					finalGoal[prop] = value
				end
			end
		end
		animation = TweenService:Create(object, info, finalGoal)
		animation:Play()
		prev[#prev + 1] = { animation = animation, goal = finalGoal }
	end)
	if not ok then
		for property, value in pairs(finalGoal or goal) do
			pcall(function()
				object[property] = value
			end)
		end
	end
	return animation
end

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
	return corner
end

local function addStroke(parent, color, transparency)
	local barStroke = Instance.new("UIStroke")
	barStroke.Color = color
	barStroke.Thickness = 1
	barStroke.Transparency = transparency or 1
	barStroke.Parent = parent
	return barStroke
end

local function addAFEMStroke(parent, thickness, transparency)
	local stroke = addStroke(parent, Color3.fromRGB(179, 179, 179), transparency or 0)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = thickness or 1.4
	local glass = Instance.new("UIGradient")
	glass.Name = "AFEMGlass"
	glass.Rotation = -22
	glass.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.466, 0),
		NumberSequenceKeypoint.new(0.948, 0.906),
		NumberSequenceKeypoint.new(1, 1),
	})
	glass.Parent = stroke
	return stroke
end

local function addUserCardStroke(parent)
	local stroke = addStroke(parent, Color3.fromRGB(68, 70, 76), 0.08)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = 1.4
	local fade = Instance.new("UIGradient")
	fade.Rotation = 90
	fade.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(0.75, 0.72),
		NumberSequenceKeypoint.new(1, 0.15),
	})
	fade.Parent = stroke
	return stroke
end

-- rbxthumb GameIcon is keyed by the UNIVERSE id (game_id): passing the
-- place id returns the default Roblox placeholder icon, which is why the
-- banners only showed a generic Roblox logo. Fall back to the place id
-- only when the universe id is missing. --
local function gameIconThumb(w, h)
	local id = tonumber(game.GameId) or 0
	if id <= 0 then
		id = tonumber(game.PlaceId) or 0
	end
	return string.format("rbxthumb://type=GameIcon&id=%d&w=%d&h=%d", id, w or 512, h or 512)
end

local function addShadow(parent, blurRadius, transparency, offset)
	-- Native UIShadow (build 711+): it renders BELOW the parent, follows
	-- its UICorner and needs no texture asset, so the halo can no longer
	-- vanish when the old shadow image gets moderated. The classic
	-- DropShadow image label stays as fallback for older engines. --
	local ok, shadow = pcall(function()
		local s = Instance.new("UIShadow")
		s.BlurRadius = UDim.new(0, blurRadius or 8)
		s.Color = Color3.new(0, 0, 0)
		s.Transparency = math.clamp((transparency or 0.6) + 0.25, 0.45, 0.85)
		s.Offset = offset or UDim2.new(0, 0, 0, 6)
		-- only the outer halo: with a semi-transparent glass card the
		-- part of the shadow behind the parent would darken its interior --
		pcall(function()
			s.ShowBehindParent = false
		end)
		s.Parent = parent
		return s
	end)
	if ok and shadow then
		return shadow
	end

	local fallback = Instance.new("ImageLabel")
	fallback.Name = "DropShadow"
	fallback.Size = UDim2.new(1, 24, 1, 24)
	fallback.AnchorPoint = Vector2.new(0.5, 0.5)
	fallback.Position = UDim2.new(0.5, 0, 0.5, offset and offset.Y.Offset or 8)
	fallback.BackgroundTransparency = 1
	fallback.Image = "rbxassetid://5554236805"
	fallback.ImageColor3 = Color3.new(0, 0, 0)
	fallback.ImageTransparency = math.clamp((transparency or 0.6) + 0.25, 0.45, 0.85)
	fallback.ScaleType = Enum.ScaleType.Slice
	fallback.SliceCenter = Rect.new(23, 23, 277, 277)
	fallback.ZIndex = math.max(1, parent.ZIndex - 1)
	fallback.Parent = parent
	return fallback
end

local fades = {}
local menuFades = {}

local function track(object, property, openValue, isMenu)
	local entry = {object = object, property = property, open = openValue or 0, menu = isMenu}
	fades[#fades + 1] = entry
	if isMenu then
		menuFades[#menuFades + 1] = entry
	end
	object[property] = 1
end

-- Previous execution cleanup --

local function removeExisting()
	for _, parent in ipairs({GuiParent, PlayerGui}) do
		for _, child in ipairs(parent:GetChildren()) do
			if child.Name == GUI_NAME then
				pcall(function()
					child:Destroy()
				end)
			end
		end
	end
end

removeExisting()

if _G.OUI10Conn then
	for _, connection in ipairs(_G.OUI10Conn) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	_G.OUI10Conn = nil
end
_G.OUI10Open = nil

for _, effect in ipairs(Lighting:GetChildren()) do
	if effect.Name == "_0x9B2D" then
		pcall(function()
			effect:Destroy()
		end)
	end
end

-- Root GUI ----------------------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = GUI_NAME
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 2147483646
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = GuiParent
_G.OUI10Gui = Gui

-- Phones and small screens: global menu scale. ScrollingFrames
-- and the custom scroll already respond to touch; this keeps the size and
-- aspect ratio from getting in the way on small screens. --
local guiScale = Instance.new("UIScale")
guiScale.Parent = Gui
local function updateGuiScale()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Gui.AbsoluteSize
        local side = math.min(viewport.X, viewport.Y)
        local scale = 1
        if side < 820 then
                scale = math.clamp(side / 820, 0.7, 1)
        end
        guiScale.Scale = scale
end
updateGuiScale()
Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGuiScale)


task.spawn(function()
	while _G.OUI10Loaded do
		task.wait(5)
		if not Gui or not Gui.Parent then
			local existingGui = GuiParent:FindFirstChild(GUI_NAME) or PlayerGui:FindFirstChild(GUI_NAME)
			if existingGui then
				Gui = existingGui
				_G.OUI10Gui = existingGui
			elseif Gui then
				pcall(function()
					Gui.Parent = GuiParent
				end)
			end
		end
	end
end)

-- Backdrop (Active = false so the camera can be moved freely) --
local dim = Instance.new("Frame")
dim.Name = "Dim"
dim.AnchorPoint = Vector2.new(0, 0)
dim.Position = UDim2.new(0, 0, 0, 0)
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 1
dim.BorderSizePixel = 0
dim.Active = false
dim.Parent = Gui

local dimGradient = Instance.new("UIGradient")
dimGradient.Rotation = 90
dimGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.25, 0.7),
	NumberSequenceKeypoint.new(0.75, 0.7),
	NumberSequenceKeypoint.new(1, 0),
})
dimGradient.Parent = dim

local light = Instance.new("Frame")
light.Size = UDim2.new(1, 0, 0.12, 0)
light.BackgroundColor3 = WHITE
light.BackgroundTransparency = 1
light.BorderSizePixel = 0
light.Active = false
light.Parent = Gui

local lightGradient = Instance.new("UIGradient")
lightGradient.Rotation = 90
lightGradient.Color = ColorSequence.new(WHITE)
lightGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.94),
	NumberSequenceKeypoint.new(0.5, 0.97),
	NumberSequenceKeypoint.new(1, 1),
})
lightGradient.Parent = light

-- Screen blur ------------------------------------------------------------

local blur = nil
pcall(function()
	local effect = Instance.new("BlurEffect")
	effect.Name = "_0x9B2D"
	effect.Size = 0
	effect.Parent = Lighting
	blur = effect
end)

pcall(function()
	Gui.Destroying:Connect(function()
		if blur then
			pcall(function()
				blur:Destroy()
			end)
		end
	end)
end)

-- UI text: English only. The whole interface is written in English and
-- there is no translation layer. --
local function tr(text)
	return text
end

-- Clock names (English) --
local CLOCK_FORMAT = "<b>%s</b> %s, %s"
local DAYS = {"sun", "mon", "tue", "wed", "thu", "fri", "sat"}
local MONTHS = {"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December"}

-- Time in server: measured from the moment the script loads and shown
-- right next to the clock (e.g. "1h 23m in server"). --
local sessionSince = os.time()

local function formatSessionTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	if seconds < 60 then
		return string.format("%ds", seconds)
	elseif seconds < 3600 then
		return string.format("%dm", math.floor(seconds / 60))
	end
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	if minutes > 0 then
		return string.format("%dh %dm", hours, minutes)
	end
	return string.format("%dh", hours)
end

local sectionTitleLabel = Instance.new("TextLabel")
sectionTitleLabel.Size = UDim2.new(0, 520, 0, 40)
sectionTitleLabel.Position = UDim2.fromOffset(36, HEADER_Y)
sectionTitleLabel.BackgroundTransparency = 1
sectionTitleLabel.BorderSizePixel = 0
sectionTitleLabel.Font = UI_FONT
sectionTitleLabel.TextSize = 28
sectionTitleLabel.TextColor3 = WHITE
sectionTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
sectionTitleLabel.TextTransparency = 1
sectionTitleLabel.Text = tr("Flow users")
sectionTitleLabel.Active = false
sectionTitleLabel.Parent = Gui

-- Executor tag: name of the executor running the script, at the right edge on
-- the same line as the section title. The script recognizes the executor and
-- paints the tag with that executor's own brand color (white if unknown). --
local executorName = "Roblox"
pcall(function()
	local detected = (type(identifyexecutor) == "function" and identifyexecutor())
		or (type(getexecutorname) == "function" and getexecutorname())
	if type(detected) == "string" and #detected > 0 then
		executorName = detected
	end
end)
-- Brand colors of known executors: first name fragment that matches wins --
local EXECUTOR_COLORS = {
	{"hydrogen", Color3.fromRGB(64, 160, 255)},
	{"hydron", Color3.fromRGB(0, 210, 255)},
	{"wave", Color3.fromRGB(124, 92, 255)},
	{"delta", Color3.fromRGB(0, 145, 255)},
	{"codex", Color3.fromRGB(86, 130, 255)},
	{"solara", Color3.fromRGB(255, 170, 40)},
	{"swift", Color3.fromRGB(255, 80, 140)},
	{"krnl", Color3.fromRGB(255, 90, 50)},
	{"fluxus", Color3.fromRGB(255, 120, 50)},
	{"arceus", Color3.fromRGB(255, 130, 40)},
	{"synapse", Color3.fromRGB(190, 35, 35)},
	{"trigon", Color3.fromRGB(0, 190, 210)},
	{"vega", Color3.fromRGB(168, 85, 247)},
	{"xeno", Color3.fromRGB(110, 110, 255)},
	{"volcano", Color3.fromRGB(255, 70, 40)},
	{"kiwi", Color3.fromRGB(76, 199, 90)},
	{"jjsploit", Color3.fromRGB(220, 60, 60)},
}
local executorColor = WHITE
do
	local lowered = string.lower(executorName)
	for _, entry in ipairs(EXECUTOR_COLORS) do
		if string.find(lowered, entry[1], 1, true) then
			executorColor = entry[2]
			break
		end
	end
end
local executorTag = Instance.new("TextLabel")
executorTag.Name = "ExecutorTag"
executorTag.Size = UDim2.new(0, 420, 0, 40)
executorTag.AnchorPoint = Vector2.new(1, 0)
executorTag.Position = UDim2.new(1, -36, 0, HEADER_Y)
executorTag.BackgroundTransparency = 1
executorTag.BorderSizePixel = 0
executorTag.Font = UI_FONT
executorTag.TextSize = 28
executorTag.TextColor3 = executorColor
executorTag.TextXAlignment = Enum.TextXAlignment.Right
executorTag.TextTruncate = Enum.TextTruncate.AtEnd
executorTag.TextTransparency = 1
executorTag.Text = executorName
executorTag.Active = false
executorTag.Parent = Gui


local clock = Instance.new("TextLabel")
clock.Size = UDim2.new(0, 560, 0, 22)
clock.Position = UDim2.fromOffset(36, SUB_Y)
clock.BackgroundTransparency = 1
clock.BorderSizePixel = 0
clock.Font = UI_FONT
clock.TextSize = SUB_TEXT_SIZE
clock.RichText = true
clock.TextColor3 = SUB_COLOR
clock.TextXAlignment = Enum.TextXAlignment.Left
clock.TextTransparency = 1
clock.Text = ""
clock.Active = false
clock.Parent = Gui

-- Centered Top Navigation Buttons (1..5) ------------------------------------

local navBar = Instance.new("Frame")
navBar.Size = UDim2.fromOffset(198, 40)
navBar.AnchorPoint = Vector2.new(0.5, 0)
navBar.Position = UDim2.new(0.5, 0, 0, 18)
navBar.BackgroundTransparency = 1
navBar.BorderSizePixel = 0
navBar.ZIndex = 10
navBar.Parent = Gui
-- No bar: the container is invisible and only positions the buttons;
-- each button is its own round bubble (see makeNavButton). --


local sectionCards = {}
local navPosition = _G.OUI10NavPosition or "top"
if navPosition ~= "top" and navPosition ~= "bottom" and navPosition ~= "left" and navPosition ~= "right" then
        navPosition = "top"
end
local navVertical = false

-- 4 buttons: each section is its OWN round glass bubble (no shared
-- bar and no sliding layer). The sticker is big and white; entering the
-- section turns it black and the bubble turns translucent white. The
-- reorder (top/bottom/left/right) is animated with tweens so it feels
-- fluid, tidy and fast.
local NAV_ORDER = { "commands", "users", "servers", "settings" }
-- Phones: bigger buttons and stickers so they look right --
local IS_TOUCH_DEVICE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local NAV_BUTTON_SIZE = IS_TOUCH_DEVICE and 46 or 40
local NAV_ICON_SIZE = IS_TOUCH_DEVICE and 30 or 25
-- Active section: the bubble stretches ONLY along its bar axis
-- (wider on top/bottom bars, taller on side bars) and its corners
-- soften into a rounded square; on leave it becomes a circle again. --
local NAV_ACTIVE_EXPAND = 1.15
local NAV_CORNER_ROUND = UDim.new(1, 0)
local NAV_CORNER_ACTIVE = UDim.new(0.4, 0)
local function navButtonSize(selected)
	if not selected then
		return UDim2.fromOffset(NAV_BUTTON_SIZE, NAV_BUTTON_SIZE)
	end
	local grow = math.floor(NAV_BUTTON_SIZE * NAV_ACTIVE_EXPAND + 0.5)
	if navVertical then
		return UDim2.fromOffset(NAV_BUTTON_SIZE, grow)
	end
	return UDim2.fromOffset(grow, NAV_BUTTON_SIZE)
end
local NAV_GAP = 10
-- Stickers: white at rest; the active section turns them black and the
-- button itself is painted translucent white (no bubble layer). --
local NAV_ICON_IDLE_COLOR = Color3.fromRGB(255, 255, 255)
local NAV_ICON_SELECTED_COLOR = Color3.fromRGB(12, 12, 14)
local NAV_ACTIVE_BG_TRANSPARENCY = 0.78
-- Each button is its own always-visible dark glass bubble --
local NAV_TILE_COLOR = Color3.new(0, 0, 0)
local NAV_TILE_TRANSPARENCY = 0.8

local navButtons = {}
local navButtonIcons = {}
local navButtonCorners = {}
-- Liquid glass (AFEM): each bubble carries a white sheet with the AFEM
-- diagonal light band plus a UIScale used for the bubble pop. --
local navButtonScales = {}
local navButtonSheens = {}
local navButtonSheenCorners = {}
local navButtonSheenGradients = {}
local navGlassTokens = {}
local navSelectionKey = nil
local navOpenSectionHandler = nil
local requestPresenceRefresh = nil
local navPlayClickHandler = nil
local layoutCommandBarForNav = nil
local setCommandBarVisibleHook = nil

-- Entering a section makes EVERY bubble just a touch bigger (the active
-- one keeps its stretch on top of it). The slots are never touched, so
-- the buttons grow in place around their own center and the row never
-- reflows. --
local NAV_OPEN_GROW = 1.05
local function navOpenSize(selected)
	local base = navButtonSize(selected)
	if not navSelectionKey then
		return base
	end
	return UDim2.fromOffset(
		math.floor(base.X.Offset * NAV_OPEN_GROW + 0.5),
		math.floor(base.Y.Offset * NAV_OPEN_GROW + 0.5))
end

-- Slot centers along the bars. The slots are computed with the IDLE
-- size only: entering a section never reflows its neighbors, so the
-- buttons stay glued in place and only the active bubble grows. --
local function navSlotCenters()
	local total = #NAV_ORDER * NAV_BUTTON_SIZE + (#NAV_ORDER - 1) * NAV_GAP
	local centers = {}
	local edge = -total / 2
	for _ = 1, #NAV_ORDER do
		centers[#centers + 1] = edge + NAV_BUTTON_SIZE / 2
		edge = edge + NAV_BUTTON_SIZE + NAV_GAP
	end
	return centers
end

-- Hand-calculated positions (no UIListLayout) so the reorder can be animated --
local function layoutNavButtons(animated)
	local centers = navSlotCenters()
	for index, key in ipairs(NAV_ORDER) do
		local btn = navButtons[key]
		if btn then
			local center = centers[index]
			local goalPosition
			if navVertical then
				goalPosition = UDim2.new(0.5, 0, 0.5, center)
			else
				goalPosition = UDim2.new(0.5, center, 0.5, 0)
			end
			local goalSize = navOpenSize(key == navSelectionKey)
			if animated then
				tween(btn, {Position = goalPosition, Size = goalSize}, 0.26, Enum.EasingStyle.Quint)
			else
				btn.Position = goalPosition
				btn.Size = goalSize
			end
		end
	end
end

local function applyNavPosition(position)
        navPosition = position
        _G.OUI10NavPosition = position
        navVertical = position == "left" or position == "right"

        local totalNav = #NAV_ORDER * NAV_BUTTON_SIZE + (#NAV_ORDER - 1) * NAV_GAP + 8
        local containerSide = NAV_BUTTON_SIZE + 6
        local goalSize = navVertical and UDim2.fromOffset(containerSide, totalNav) or UDim2.fromOffset(totalNav, containerSide)
        local goalAnchor
        local goalPos
        if position == "bottom" then
                goalAnchor = Vector2.new(0.5, 1)
                goalPos = UDim2.new(0.5, 0, 1, -18)
        elseif position == "left" then
                goalAnchor = Vector2.new(0, 0.5)
                goalPos = UDim2.new(0, 18, 0.5, 0)
        elseif position == "right" then
                goalAnchor = Vector2.new(1, 0.5)
                goalPos = UDim2.new(1, -18, 0.5, 0)
        else
                goalAnchor = Vector2.new(0.5, 0)
                goalPos = UDim2.new(0.5, 0, 0, 18)
        end
        tween(navBar, {Size = goalSize, Position = goalPos, AnchorPoint = goalAnchor}, 0.26, Enum.EasingStyle.Quint)
        for _, data in pairs(sectionCards) do
                tween(data.card, {Size = UDim2.new(1, navVertical and -140 or -72, 1, -150)}, 0.26, Enum.EasingStyle.Quint)
        end
        layoutNavButtons(true)
        if layoutCommandBarForNav then
            layoutCommandBarForNav()
        end
end

applyNavPosition(navPosition)

local activeSectionKey = nil
local isOpen = false
_G.OUI10Open = false

local function makeNavButton(assetId, key, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(NAV_BUTTON_SIZE, NAV_BUTTON_SIZE)
        btn.AnchorPoint = Vector2.new(0.5, 0.5)
        -- Each button IS the bubble: rounded dark glass, always visible --
        btn.BackgroundColor3 = NAV_TILE_COLOR
        btn.BackgroundTransparency = NAV_TILE_TRANSPARENCY
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.LayoutOrder = order
        btn.ZIndex = 11
        btn.Parent = navBar
        -- Fully rounded bubble --
        navButtonCorners[key] = addCorner(btn, UDim.new(1, 0))

        -- Liquid glass sheet (AFEM style): a white layer with the same
        -- diagonal light band AFEM uses on its glass stroke. It rests
        -- fully transparent and only sweeps across on hover/selection --
        local sheen = Instance.new("Frame")
        sheen.Name = "GlassSheen"
        sheen.Size = UDim2.fromScale(1, 1)
        sheen.BackgroundColor3 = WHITE
        sheen.BackgroundTransparency = 1
        sheen.BorderSizePixel = 0
        sheen.Active = false
        sheen.ZIndex = 11
        sheen.Parent = btn
        local sheenCorner = addCorner(sheen, UDim.new(1, 0))
        local sheenGradient = Instance.new("UIGradient")
        sheenGradient.Name = "Glass"
        sheenGradient.Rotation = -22
        sheenGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.466, 0),
                NumberSequenceKeypoint.new(0.948, 0.906),
                NumberSequenceKeypoint.new(1, 1),
        })
        sheenGradient.Offset = Vector2.new(-1.1, 0)
        sheenGradient.Parent = sheen
        navButtonSheens[key] = sheen
        navButtonSheenCorners[key] = sheenCorner
        navButtonSheenGradients[key] = sheenGradient

        -- Bubble scale: pops on selection/hover on top of the size tween --
        local scale = Instance.new("UIScale")
        scale.Scale = 1
        scale.Parent = btn
        navButtonScales[key] = scale

        -- Drop shadow (native UIShadow.BlurRadius): a soft blurred halo
        -- so each bubble floats over the game. Tight and light (smaller
        -- blur, closer offset, higher transparency) so it reads as a
        -- gentle lift instead of a heavy smear. The class only exists on
        -- recent clients, so older engines simply skip it. --
        pcall(function()
                local shadow = Instance.new("UIShadow")
                shadow.BlurRadius = UDim.new(0.4, 0)
                shadow.Color = Color3.new(0, 0, 0)
                shadow.Transparency = 0.62
                shadow.Offset = UDim2.new(0, 0, 0, 3)
                pcall(function()
                        shadow.ShowBehindParent = false
                end)
                shadow.Parent = btn
        end)

        -- Big sticker: white at rest, black in its section --
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.fromOffset(NAV_ICON_SIZE, NAV_ICON_SIZE)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. assetId
        icon.ImageColor3 = NAV_ICON_IDLE_COLOR
        icon.ImageTransparency = 1
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Active = false
        icon.ZIndex = 12
        icon.Parent = btn
        navButtonIcons[key] = icon

        return btn
end

-- Bubble / liquid-glass animation: a light band sweeps across the glass
-- sheet while the bubble pops (UIScale), like AFEM's glass buttons. --
local function playNavGlass(key, strong)
        local token = (navGlassTokens[key] or 0) + 1
        navGlassTokens[key] = token
        local sheen = navButtonSheens[key]
        local scale = navButtonScales[key]
        if sheen then
                local gradient = navButtonSheenGradients[key]
                if gradient then
                        gradient.Offset = Vector2.new(-1.1, 0)
                end
                tween(sheen, {BackgroundTransparency = strong and 0.84 or 0.92}, 0.16, Enum.EasingStyle.Quad)
                if gradient then
                        tween(gradient, {Offset = Vector2.new(1.1, 0)}, strong and 0.5 or 0.4, Enum.EasingStyle.Quad)
                end
                task.delay(strong and 0.52 or 0.42, function()
                        if navGlassTokens[key] == token and sheen.Parent then
                                tween(sheen, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quad)
                        end
                end)
        end
        if scale then
                tween(scale, {Scale = strong and 1.12 or 1.05}, 0.14, Enum.EasingStyle.Quad)
                task.delay(0.15, function()
                        if navGlassTokens[key] == token and scale.Parent then
                                tween(scale, {Scale = 1}, 0.3, Enum.EasingStyle.Quint)
                        end
                end)
        end
end

-- Cursor feedback: the bubble under the cursor grows, close bubbles grow a
-- little less and far bubbles return to normal; holding a bubble grows it. --
local navHoverKey = nil
local navHoldKey = nil
local NAV_HOVER_GROW = { [0] = 1.14, [1] = 1.08, [2] = 1.03 }
local NAV_HOLD_GROW = 1.18

local function navOrderIndex(key)
	for index, navKey in ipairs(NAV_ORDER) do
		if navKey == key then
			return index
		end
	end
	return nil
end

local function applyNavMagnify()
	local hoverIndex = navHoverKey and navOrderIndex(navHoverKey) or nil
	for index, key in ipairs(NAV_ORDER) do
		local btn = navButtons[key]
		if btn then
			local base = navOpenSize(key == navSelectionKey)
			local factor = 1
			if hoverIndex then
				factor = NAV_HOVER_GROW[math.abs(index - hoverIndex)] or 1
			end
			if key == navHoldKey then
				factor = math.max(factor, NAV_HOLD_GROW)
			end
			if key == navSelectionKey then
				factor = 1 + (factor - 1) * 0.4
			end
			local width = math.floor(base.X.Offset * factor + 0.5)
			local height = math.floor(base.Y.Offset * factor + 0.5)
			if math.abs(btn.Size.X.Offset - width) > 0.5 or math.abs(btn.Size.Y.Offset - height) > 0.5 then
				tween(btn, {Size = UDim2.fromOffset(width, height)}, 0.18, Enum.EasingStyle.Quint)
			end
		end
	end
end

local function setNavSelection(key)
        navSelectionKey = key
        for _, navKey in ipairs(NAV_ORDER) do
                local icon = navButtonIcons[navKey]
                local button = navButtons[navKey]
                local selected = navKey == key
                if icon then
                        -- Sticker: white at rest, black in its section --
                        tween(icon, {
                                ImageColor3 = selected and NAV_ICON_SELECTED_COLOR or NAV_ICON_IDLE_COLOR,
                        }, 0.22, Enum.EasingStyle.Quad)
                end
                if button then
                        -- The bubble is the button: translucent white when active --
                        tween(button, {
                                BackgroundColor3 = selected and WHITE or NAV_TILE_COLOR,
                                BackgroundTransparency = selected and NAV_ACTIVE_BG_TRANSPARENCY or NAV_TILE_TRANSPARENCY,
                        }, 0.22, Enum.EasingStyle.Quad)
                        -- The active section stretches along its bar axis (wider on
                        -- top/bottom bars, taller on side bars) and its corners soften
                        -- into a rounded square; the others become circles again. --
                        local goalSize = navOpenSize(selected)
                        if math.abs(button.Size.X.Offset - goalSize.X.Offset) > 0.5 or math.abs(button.Size.Y.Offset - goalSize.Y.Offset) > 0.5 then
                                tween(button, {Size = goalSize}, selected and 0.28 or 0.24, Enum.EasingStyle.Quint)
                        end
                        local corner = navButtonCorners[navKey]
                        if corner then
                                tween(corner, {CornerRadius = selected and NAV_CORNER_ACTIVE or NAV_CORNER_ROUND}, selected and 0.28 or 0.24, Enum.EasingStyle.Quint)
                        end
                        -- the glass sheet follows the bubble shape so the
                        -- sweep never spills outside the corner --
                        local sheenCorner = navButtonSheenCorners[navKey]
                        if sheenCorner then
                                tween(sheenCorner, {CornerRadius = selected and NAV_CORNER_ACTIVE or NAV_CORNER_ROUND}, selected and 0.28 or 0.24, Enum.EasingStyle.Quint)
                        end
                end
		end
		layoutNavButtons(true)
		applyNavMagnify()
		if key then
			-- liquid-glass sweep + bubble pop on the new selection --
			playNavGlass(key, true)
		end
end

_G.OUI10Conn = _G.OUI10Conn or {}
local function navConnect(signal, handler)
        local connection = signal:Connect(handler)
        _G.OUI10Conn[#_G.OUI10Conn + 1] = connection
        return connection
end

-- Entrance: every bubble grows from zero smoothly while the glass and
-- the sticker are revealed (no bounce, no pop). --
local function playNavEntrance()
        for _, key in ipairs(NAV_ORDER) do
                local button = navButtons[key]
                local icon = navButtonIcons[key]
                if button then
                        button.Size = UDim2.fromOffset(0, 0)
                        button.BackgroundTransparency = 1
                end
                if icon then
                        icon.ImageTransparency = 1
                end
        end
        for index, key in ipairs(NAV_ORDER) do
                local button = navButtons[key]
                local icon = navButtonIcons[key]
                task.delay(0.07 * index, function()
                        if button and button.Parent then
                                tween(button, {Size = UDim2.fromOffset(NAV_BUTTON_SIZE, NAV_BUTTON_SIZE)}, 0.4, Enum.EasingStyle.Quint)
                                tween(button, {BackgroundTransparency = NAV_TILE_TRANSPARENCY}, 0.35, Enum.EasingStyle.Quint)
                        end
                        if icon and icon.Parent then
                                tween(icon, {ImageTransparency = 0}, 0.35, Enum.EasingStyle.Quint)
                        end
                end)
        end
        task.delay(0.4, function()
                if navSelectionKey then
                        setNavSelection(navSelectionKey)
                end
        end)
end

-- Section Containers -------------------------------------------------------

local sectionCardPages = {}
local currentSectionKey = nil

local sectionFadeObjects = setmetatable({}, {__mode = "k"})
local cardEntranceEpoch = 0

local function cacheSectionFadeObject(card, object)
	local cache = sectionFadeObjects[card]
	if not cache or cache.indexed[object] then
		return
	end

	local properties = {}
	if object:IsA("GuiObject") then
		properties.BackgroundTransparency = true
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			properties.TextTransparency = true
			properties.TextStrokeTransparency = true
		end
		if object:IsA("ImageLabel") or object:IsA("ImageButton") then
			properties.ImageTransparency = true
		end
		if object:IsA("ScrollingFrame") then
			properties.ScrollBarImageTransparency = true
		end
	elseif object:IsA("UIStroke") then
		properties.Transparency = true
	else
		local isShadowOk, isShadow = pcall(function()
			return object:IsA("UIShadow")
		end)
		if isShadowOk and isShadow then
			properties.Transparency = true
		end
	end

	local baseValues = {}
	for property in pairs(properties) do
		local ok, value = pcall(function()
			return object[property]
		end)
		if ok and type(value) == "number" then
			baseValues[property] = value
		end
	end
	if next(baseValues) then
		cache.indexed[object] = true
		cache.entries[#cache.entries + 1] = {
			object = object,
			properties = baseValues,
			fadeState = "visible",
			transitionToken = 0,
		}
	end
end

local function createSectionCard(key)
	local card = Instance.new("Frame")
	card.Name = "Card_" .. key
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.new(0.5, 0, 0.53, 0)
	card.Size = UDim2.new(1, navVertical and -140 or -72, 1, -150)
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.Visible = false
	card.Active = false
	card.ZIndex = 5
	card.Parent = Gui

	local pageHost = Instance.new("Frame")
	pageHost.Name = "PageHost"
	pageHost.Size = UDim2.new(1, -28, 1, -28)
	pageHost.Position = UDim2.fromOffset(14, 14)
	pageHost.BackgroundTransparency = 1
	pageHost.BorderSizePixel = 0
	pageHost.ClipsDescendants = true
	pageHost.Active = false
	pageHost.Parent = card

	sectionCardPages[key] = pageHost
	sectionCards[key] = {
		card = card,
		pageHost = pageHost,
	}
	sectionFadeObjects[card] = {
		entries = {},
		indexed = setmetatable({}, {__mode = "k"}),
	}
	cacheSectionFadeObject(card, card)
	for _, object in ipairs(card:GetDescendants()) do
		cacheSectionFadeObject(card, object)
	end
	card.DescendantAdded:Connect(function(object)
		task.defer(function()
			if object.Parent then
				cacheSectionFadeObject(card, object)
			end
		end)
	end)
	return card
end

createSectionCard("commands")
createSectionCard("users")
createSectionCard("servers")
createSectionCard("settings")

track(dim, "BackgroundTransparency", 0.55, true)
track(light, "BackgroundTransparency", LIGHT_TR_OPEN, true)
track(clock, "TextTransparency", 0, true)
track(sectionTitleLabel, "TextTransparency", 0, true)
track(executorTag, "TextTransparency", 0, true)

local function showHud()
	if _G.OUI10HudOn == false then
		return
	end
	for _, fade in ipairs(fades) do
		if not fade.menu then
			tween(fade.object, {[fade.property] = fade.open}, 0.4)
		end
	end
end

-- Clock --------------------------------------------------------------------

task.spawn(function()
	while Gui.Parent do
		local now = os.date("*t")
		local timeText
		if _G.OUI10TimeFormat == 12 then
			local hour = now.hour % 12
			if hour == 0 then
				hour = 12
			end
			timeText = string.format("%d:%02d %s", hour, now.min, now.hour >= 12 and "PM" or "AM")
		else
			timeText = string.format("%02d:%02d", now.hour, now.min)
		end
		clock.Text = string.format(CLOCK_FORMAT, timeText, DAYS[now.wday], MONTHS[now.month])
			.. "  ·  <b>" .. formatSessionTime(os.time() - sessionSince) .. "</b> in server"
		task.wait(1)
	end
end)

_G.OUI10Conn = _G.OUI10Conn or {}

local function connect(signal, handler)
	local connection = signal:Connect(handler)
	table.insert(_G.OUI10Conn, connection)
	return connection
end

local SECTION_CENTER = UDim2.new(0.5, 0, 0.53, 0)
local SECTION_OFF_TOP = UDim2.new(0.5, 0, -0.6, 0)
local SECTION_OFF_BOTTOM = UDim2.new(0.5, 0, 1.6, 0)
local sectionOrder = {commands = 1, users = 2, servers = 3, settings = 4}
local sectionTransitionToken = 0
local sectionSlideTweens = {}

local function cancelCardSlide(card)
	local previous = sectionSlideTweens[card]
	if previous then
		previous:Cancel()
		sectionSlideTweens[card] = nil
	end
end

local function slideTween(card, goal, duration)
	cancelCardSlide(card)
	local animation = TweenService:Create(
		card,
		TweenInfo.new(duration or 0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
		goal
	)
	sectionSlideTweens[card] = animation
	animation:Play()
	return animation
end

local function resetCard(card)
	cancelCardSlide(card)
	card.Visible = false
	card.Position = SECTION_CENTER
end

local blurEnabled = _G.OUI10BlurEnabled == true
local showPage = nil
local SECTION_FADE_DURATION = 0.3

local function fadeSectionCard(card, show)
	cardEntranceEpoch = cardEntranceEpoch + 1
	local cache = sectionFadeObjects[card]
	if not cache then
		return
	end
	for _, object in ipairs(card:GetDescendants()) do
		cacheSectionFadeObject(card, object)
	end
	for _, entry in ipairs(cache.entries) do
		local object = entry.object
		if object == card or object:IsDescendantOf(card) then
			if not show and entry.fadeState == "visible" then
				local busy = false
				local walk = object
				while walk and walk ~= card do
					local busyUntil = walk:GetAttribute("OUI10CardBusy")
					if type(busyUntil) == "number" and busyUntil > os.clock() then
						busy = true
						break
					end
					walk = walk.Parent
				end
				if not busy then
					for property in pairs(entry.properties) do
						local ok, value = pcall(function()
							return object[property]
						end)
						if ok and type(value) == "number" then
							entry.properties[property] = value
						end
					end
				end
			end
			local goal = {}
			for property, baseValue in pairs(entry.properties) do
				goal[property] = show and baseValue or 1
			end
			if next(goal) then
				entry.transitionToken = entry.transitionToken + 1
				local token = entry.transitionToken
				entry.fadeState = show and "fadingIn" or "fadingOut"
				local animation = tween(object, goal, SECTION_FADE_DURATION, Enum.EasingStyle.Quad)
				if animation then
					animation.Completed:Connect(function(playbackState)
						if playbackState == Enum.PlaybackState.Completed and entry.transitionToken == token then
							entry.fadeState = show and "visible" or "hidden"
						end
					end)
				else
					entry.fadeState = show and "visible" or "hidden"
				end
			end
		end
	end
end

local function hideSectionCardAfterFade(card, key)
	task.delay(SECTION_FADE_DURATION, function()
		if currentSectionKey ~= key then
			card.Visible = false
			card.Position = SECTION_CENTER
		end
	end)
end

-- Roblox topbar buttons: hidden while any section is open,
-- and back to their original state on close (best effort: one pcall per
-- step in case the executor blocks CoreGui or changes its structure). --
local topbarSavedVisibility = nil
local topbarSavedMinimize = nil
local topbarSavedCore = nil

-- The Roblox chat is native (no script chat anymore): it is never
-- hidden by this script, so no desired-state tracking is needed. --

-- Some games run TopBarPlus menus whose rows live in ScrollingFrames named
-- "Center"/"Right"; when the topbar is hidden/shown their layout updater
-- runs and spams errors if the UIListLayout is missing. A temporary layout
-- is added while hidden and removed again on restore. --
local topbarLayoutPatches = {}
local function patchTopbarMissingLayouts()
	local okCore, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if not okCore or not coreGui then
		return
	end
	local okList, descendants = pcall(function()
		return coreGui:GetDescendants()
	end)
	if not okList or type(descendants) ~= "table" then
		return
	end
	for _, inst in ipairs(descendants) do
		pcall(function()
			if inst:IsA("ScrollingFrame") and (inst.Name == "Center" or inst.Name == "Right") and not inst:FindFirstChild("UIListLayout") then
				local layout = Instance.new("UIListLayout")
				layout.Name = "UIListLayout"
				layout.FillDirection = Enum.FillDirection.Vertical
				layout.SortOrder = Enum.SortOrder.LayoutOrder
				layout.Parent = inst
				topbarLayoutPatches[inst] = layout
			end
		end)
	end
end
local function clearTopbarLayoutPatches()
	for inst, layout in pairs(topbarLayoutPatches) do
		pcall(function()
			if layout.Parent then
				layout:Destroy()
			end
		end)
		topbarLayoutPatches[inst] = nil
	end
end
local function setRobloxTopbarHidden(hidden)
	-- 1) MinimizePlayerExperience: the official client switch that minimizes
	-- the WHOLE topbar UI at once (Roblox menu, chat and microphone) --
	if hidden then
		if topbarSavedMinimize == nil then
			pcall(function()
				topbarSavedMinimize = game:GetService("GuiService").MinimizePlayerExperienceEnabled
			end)
		end
		-- The Roblox chat is native again: the minimizer is never
		-- forced on, so the chat stays untouched while Flow is open. --
		local minimizeGoal = topbarSavedMinimize == true
		pcall(function()
			game:GetService("GuiService").MinimizePlayerExperienceEnabled = minimizeGoal
		end)
	else
		pcall(function()
			game:GetService("GuiService").MinimizePlayerExperienceEnabled = topbarSavedMinimize == true
		end)
		topbarSavedMinimize = nil
	end
	-- 2) Via CoreGui: hides the whole topbar container (new TopBarApp,
	-- TopBarFrame and the legacy TopBar); fallback in case route 1 fails --
	if hidden then
		if not topbarSavedVisibility then
			topbarSavedVisibility = {}
			local okCore, coreGui = pcall(function()
				return game:GetService("CoreGui")
			end)
			for _, name in ipairs({ "TopBarApp", "TopBarFrame", "TopBar", "TopbarPlus" }) do
				local ok, container = pcall(function()
					return (okCore and coreGui) and coreGui:FindFirstChild(name) or nil
				end)
				if ok and container then
					if container:IsA("GuiObject") then
						topbarSavedVisibility[container] = { prop = "Visible", value = container.Visible }
						container.Visible = false
					elseif container:IsA("ScreenGui") then
						topbarSavedVisibility[container] = { prop = "Enabled", value = container.Enabled }
						container.Enabled = false
					end
				end
			end
		end
	elseif topbarSavedVisibility then
		for container, saved in pairs(topbarSavedVisibility) do
			pcall(function()
				if container.Parent then
					container[saved.prop] = saved.value
				end
			end)
		end
		topbarSavedVisibility = nil
	end
	-- 3) Via StarterGui: full topbar + chat + player list (robust when the
	-- executor blocks CoreGui); everything is restored when the section closes --
	pcall(function()
		local starterGui = game:GetService("StarterGui")
		if hidden then
			if not topbarSavedCore then
				topbarSavedCore = {}
				pcall(function()
					topbarSavedCore.topbar = starterGui:GetCore("TopbarEnabled")
				end)
				for _, coreType in ipairs({Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Backpack, Enum.CoreGuiType.Health, Enum.CoreGuiType.EmotesMenu}) do
					pcall(function()
						topbarSavedCore[coreType] = starterGui:GetCoreGuiEnabled(coreType)
					end)
				end
			end
			pcall(function() starterGui:SetCore("TopbarEnabled", false) end)
			for _, coreType in ipairs({Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Backpack, Enum.CoreGuiType.Health, Enum.CoreGuiType.EmotesMenu}) do
				-- The Roblox chat is never force-hidden: it must stay
				-- visible with a section open, and across open/close
				-- cycles (there is no script chat taking over). --
				if coreType ~= Enum.CoreGuiType.Chat then
					pcall(function() starterGui:SetCoreGuiEnabled(coreType, false) end)
				end
			end
			patchTopbarMissingLayouts()
			task.delay(0.3, patchTopbarMissingLayouts)
			task.delay(1, patchTopbarMissingLayouts)
		else
			clearTopbarLayoutPatches()
			if topbarSavedCore then
				pcall(function() starterGui:SetCore("TopbarEnabled", topbarSavedCore.topbar ~= false) end)
				for _, coreType in ipairs({Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Backpack, Enum.CoreGuiType.Health, Enum.CoreGuiType.EmotesMenu}) do
					-- The chat was never hidden, so restoring its saved
					-- value is a no-op; the other core types go back to
					-- the state they had before Flow opened --
					local was = topbarSavedCore[coreType]
					pcall(function()
						starterGui:SetCoreGuiEnabled(coreType, was ~= false)
					end)
				end
				topbarSavedCore = nil
			end
		end
	end)
end

-- Safety net: if the interface gets destroyed another way (re-execution,
-- destroy command), the Roblox topbar goes back to its original state --
pcall(function()
	Gui.Destroying:Connect(function()
		pcall(setRobloxTopbarHidden, false)
	end)
end)

local function setOpen(open)
	isOpen = open and true or false
	_G.OUI10Open = isOpen
	pcall(setRobloxTopbarHidden, isOpen)
	if setCommandBarVisibleHook then
		setCommandBarVisibleHook(isOpen and currentSectionKey == "commands")
	end
	dim.Active = false

	if not isOpen then
		sectionTransitionToken = sectionTransitionToken + 1
		local closeToken = sectionTransitionToken
		setNavSelection(nil)
		for key, data in pairs(sectionCards) do
			local card = data.card
			if card.Visible then
				fadeSectionCard(card, false)
				cancelCardSlide(card)
				task.delay(SECTION_FADE_DURATION, function()
					if not isOpen and sectionTransitionToken == closeToken then
						card.Visible = false
						card.Position = SECTION_CENTER
					end
				end)
			end
		end
	else
		for key, data in pairs(sectionCards) do
			local card = data.card
			if key == currentSectionKey then
				card.Position = SECTION_CENTER
				card.Visible = true
				fadeSectionCard(data.card, true)
			elseif card.Visible then
				fadeSectionCard(card, false)
				cancelCardSlide(card)
				hideSectionCardAfterFade(card, key)
			else
				resetCard(card)
			end
		end
	end

	for _, fade in ipairs(menuFades) do
		tween(fade.object, {[fade.property] = isOpen and fade.open or 1}, 0.3)
	end
	if blur then
		tween(blur, {Size = isOpen and blurEnabled and BLUR_OPEN or 0}, 0.4, Enum.EasingStyle.Quint)
	end
end

local sectionNames = {
	commands = tr("Commands"),
	users = tr("Flow users"),
	servers = tr("Server list"),
	settings = tr("Settings")
}

-- Section title: fades out, swaps text and fades back in when the user
-- moves between sections (the menu open/close fades still own the
-- visibility while the menu itself opens or closes). --
local sectionTitleToken = 0
local function setSectionTitle(key, transitionToken, animate)
	local text = sectionNames[key] or "Flow users"
	if not animate then
		sectionTitleLabel.Text = text
		return
	end
	sectionTitleToken = sectionTitleToken + 1
	local token = sectionTitleToken
	tween(sectionTitleLabel, {TextTransparency = 1}, 0.14, Enum.EasingStyle.Quad)
	task.delay(0.15, function()
		if sectionTitleToken ~= token then return end
		if transitionToken and sectionTransitionToken ~= transitionToken then return end
		if not isOpen then return end
		sectionTitleLabel.Text = text
		tween(sectionTitleLabel, {TextTransparency = 0}, 0.22, Enum.EasingStyle.Quad)
	end)
end

local function openSection(key, transitionToken)
	if not transitionToken then
		sectionTransitionToken = sectionTransitionToken + 1
		transitionToken = sectionTransitionToken
	end
	if currentSectionKey == key and isOpen then
		setOpen(false)
		return
	end
	-- Opening Flow users requests an immediate refresh of the list
	if key == "users" and requestPresenceRefresh then
		requestPresenceRefresh()
	end

	local previousKey = currentSectionKey
	local wasOpen = isOpen

	activeSectionKey = key
	currentSectionKey = key
	if setCommandBarVisibleHook then
		setCommandBarVisibleHook(key == "commands")
	end
	setNavSelection(key)

	if previousKey and previousKey ~= key and sectionCards[previousKey] and sectionCards[key] then
		local prevCard = sectionCards[previousKey].card
		local newCard = sectionCards[key].card

		for k, data in pairs(sectionCards) do
			if k ~= key and k ~= previousKey then
				local card = data.card
				if card.Visible then
					fadeSectionCard(card, false)
					cancelCardSlide(card)
					hideSectionCardAfterFade(card, k)
				else
					resetCard(card)
				end
			end
		end

		local movingDown = (sectionOrder[key] or 1) > (sectionOrder[previousKey] or 1)
		local newStart = movingDown and SECTION_OFF_BOTTOM or SECTION_OFF_TOP
		local prevTarget = movingDown and SECTION_OFF_TOP or SECTION_OFF_BOTTOM
		newCard.Position = newStart
		newCard.Visible = true

		if wasOpen then
			slideTween(prevCard, {Position = prevTarget}, 0.16)
			fadeSectionCard(prevCard, false)
			hideSectionCardAfterFade(prevCard, previousKey)
		else
			fadeSectionCard(prevCard, false)
			hideSectionCardAfterFade(prevCard, previousKey)
		end
		fadeSectionCard(newCard, true)
		if showPage then
			showPage(key)
		end
		if not wasOpen then
			setOpen(true)
		end
		slideTween(newCard, {Position = SECTION_CENTER}, 0.16)

		setSectionTitle(key, transitionToken, wasOpen)
		return
	end

	setSectionTitle(key, transitionToken, wasOpen)
	for k, data in pairs(sectionCards) do
		if k == key then
			data.card.Position = SECTION_CENTER
			data.card.Visible = true
		else
			resetCard(data.card)
		end
	end

	if showPage then
		showPage(key)
	end
	setOpen(true)
end

navOpenSectionHandler = openSection

-- Navigation buttons --
navButtons["commands"] = makeNavButton("137548923529153", "commands", 1)
navButtons["users"] = makeNavButton("85748034018110", "users", 2)
navButtons["servers"] = makeNavButton("100465503260845", "servers", 3)
navButtons["settings"] = makeNavButton("78758671432935", "settings", 4)
layoutNavButtons(false)
playNavEntrance()
-- Hover / hold feedback for the nav bubbles --
for _, key in ipairs(NAV_ORDER) do
	local btn = navButtons[key]
	if btn then
		navConnect(btn.MouseEnter, function()
			navHoverKey = key
			applyNavMagnify()
			playNavGlass(key, false)
		end)
		navConnect(btn.MouseLeave, function()
			task.delay(0.06, function()
				if navHoverKey == key then
					navHoverKey = nil
					applyNavMagnify()
				end
			end)
		end)
		navConnect(btn.MouseButton1Down, function()
			navHoldKey = key
			applyNavMagnify()
		end)
		navConnect(btn.MouseButton1Up, function()
			if navHoldKey == key then
				navHoldKey = nil
				applyNavMagnify()
			end
		end)
	end
end

for key, btn in pairs(navButtons) do
	btn.Activated:Connect(function()
		pcall(function()
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://107063096720740"
			sound.Volume = 0.3
			sound.PlaybackSpeed = 1.8
			sound.Parent = game:GetService("SoundService")
			game:GetService("SoundService"):PlayLocalSound(sound)
			task.delay(2, function() sound:Destroy() end)
		end)
		openSection(key)
	end)
end

local function playClick()
	pcall(function()
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://107063096720740"
		sound.Volume = 0.3
		sound.PlaybackSpeed = 1.8
		sound.Parent = game:GetService("SoundService")
		game:GetService("SoundService"):PlayLocalSound(sound)
		task.delay(2, function()
			pcall(function()
				sound:Destroy()
			end)
		end)
	end)
end

navPlayClickHandler = playClick

-- Sections Implementation --------------------------------------------------

task.spawn(function()
	local initialized, initializationError = xpcall(function()
	local HttpService = game:GetService("HttpService")
	local TeleportService = game:GetService("TeleportService")
	local Stats = game:GetService("Stats")

	local SUPABASE_URL      = "https://eggflguqaoqccgtbbzlr.supabase.co"
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVnZ2ZsZ3VxYW9xY2NndGJiemxyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM1MDgzNjIsImV4cCI6MjEwOTA4NDM2Mn0.tk2PPWBCDyHNLSlPiJ35uhnlGLLildmJvuRJgqHFKuA"

local function supaHeaders(extra)
    local h = {
        ["apikey"]        = SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY,
        ["Content-Type"]  = "application/json",
        ["Accept"]        = "application/json",
    }
    if extra then
        for k, v in pairs(extra) do h[k] = v end
    end
    return h
end

local function supaRequest(method, path, body, extraHeaders)
    local url = SUPABASE_URL .. "/rest/v1" .. path
    local opts = {
        Url = url,
        Method = method,
        Headers = supaHeaders(extraHeaders),
        Body = body and HttpService:JSONEncode(body) or nil,
    }
    local ok, resp = pcall(function()
        if type(request) == "function" then
            return request(opts)
        elseif type(http_request) == "function" then
            return http_request(opts)
        end
        return HttpService:RequestAsync(opts)
    end)
    if not ok then return nil end
    local status = resp.StatusCode or resp.status_code
    local raw = resp.Body or resp.body or ""
    if status and status >= 400 then
        warn("[Supabase] " .. status .. ": " .. raw)
        return nil
    end
    if raw ~= "" then
        return HttpService:JSONDecode(raw)
    end
    return {}
end

    local TEXT_DIM = Color3.fromRGB(150, 153, 162)

	local AFEM_BLACK = Color3.new(0, 0, 0)
	local AFEM_CARD = Color3.new(0, 0, 0)

	-- Real name of the current game (avoids seeing or sending "Ugc") --
	local placeName = tostring(game.Name or "")
	task.spawn(function()
		local ok, info = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		end)
		if ok and info and info.Name and tostring(info.Name) ~= "" then
			placeName = tostring(info.Name)
		end
	end)

	local function decode(text)
		local ok, data = pcall(function()
			return HttpService:JSONDecode(text)
		end)
		if ok then
			return data
		end
		return nil
	end

	local function httpRequest(method, url, body)
		local headers = {["Content-Type"] = "application/json", Accept = "application/json"}
		local ok, response = pcall(function()
			if type(request) == "function" then
				return request({Url = url, Method = method, Headers = headers, Body = body})
			end
			if type(http_request) == "function" then
				return http_request({Url = url, Method = method, Headers = headers, Body = body})
			end
			return HttpService:RequestAsync({Url = url, Method = method, Headers = headers, Body = body})
		end)
		if not ok or type(response) ~= "table" then
			return nil
		end
		if response.Success == false then
			return nil
		end
		local status = response.StatusCode or response.status_code
		if status and status >= 400 then
			return nil
		end
		return response.Body or response.body or ""
	end

	local function notify(_text)
	end

	local pages = {}
	local currentKey = nil
	local showServerPage
	local writePresence
	local deactivatePresenceRow
	local dndConfig = _G.OUI10DND
	if type(dndConfig) ~= "table" then
		dndConfig = type(_G._FlowCfg) == "table" and _G._FlowCfg or {}
		_G.OUI10DND = dndConfig
	end
	local dndDefaults = {
		DND_Enabled = false,
		DND_HideGame = true,
		DND_HideBanner = true,
		DND_BannerId = "134918452547700",
		DND_HideAvatar = true,
		DND_AvatarId = "109728664560706",
		DND_HideName = false,
		DND_CustomName = "Hidden",
		DND_HidePlayers = true,
		DND_HidePing = true,
		DND_BlockJoin = true,
	}
	for key, value in pairs(dndDefaults) do
		local textValue = key == "DND_BannerId" or key == "DND_AvatarId" or key == "DND_CustomName"
		if (textValue and type(dndConfig[key]) ~= "string") or (not textValue and type(dndConfig[key]) ~= "boolean") then
			dndConfig[key] = value
		end
	end
	saveConfig()

	local function makePage(key)
		local page = Instance.new(key == "settings" and "ScrollingFrame" or "Frame")
		page.Name = "Page_" .. key
		page.Size = UDim2.fromScale(1, 1)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.Visible = false
		page.Active = key == "settings"
		if key == "settings" then
			page.AutomaticCanvasSize = Enum.AutomaticSize.Y
			page.CanvasSize = UDim2.new(0, 0, 0, 0)
			page.ScrollBarThickness = 0
			page.ScrollingDirection = Enum.ScrollingDirection.Y
		end
		page.Parent = sectionCardPages[key]
		pages[key] = page
		return page
	end

	makePage("commands")
	makePage("servers")
	makePage("settings")
	local usersPage = makePage("users")

	local SCROLL_W = 5
	local function applyCustomScroll(scrollFrame, parentFrame, topOffset, bottomOffsetFunc, rightInset)
		scrollFrame.ScrollBarThickness = 0
		scrollFrame.ScrollBarImageTransparency = 1
		local insetX = tonumber(rightInset) or 0
		local track = Instance.new("Frame")
		track.Name = "Track_" .. scrollFrame.Name
		track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		track.BackgroundTransparency = 0.95
		track.BorderSizePixel = 0
		track.ZIndex = 15
		track.Active = true
		track.Parent = parentFrame
		Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

		local thumb = Instance.new("Frame")
		thumb.Name = "Thumb"
		thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		thumb.BackgroundTransparency = 0.4
		thumb.BorderSizePixel = 0
		thumb.ZIndex = 16
		thumb.Parent = track
		Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

		local trackHit = Instance.new("TextButton")
		trackHit.Name = "TrackHit"
		trackHit.BackgroundTransparency = 1
		trackHit.Text = ""
		trackHit.Size = UDim2.new(1, 0, 1, 0)
		trackHit.ZIndex = 17
		trackHit.Active = true
		trackHit.Parent = track

		local function updateScroll()
			local bOffset = type(bottomOffsetFunc) == "function" and bottomOffsetFunc() or (tonumber(bottomOffsetFunc) or 10)
			track.Position = UDim2.new(1, -(6 + SCROLL_W + insetX), 0, topOffset)
			track.Size = UDim2.new(0, SCROLL_W, 1, -(topOffset + bOffset))
			local view = (scrollFrame.AbsoluteWindowSize.Y > 0 and scrollFrame.AbsoluteWindowSize.Y) or scrollFrame.AbsoluteSize.Y
			local content = (scrollFrame.AbsoluteCanvasSize.Y > 0 and scrollFrame.AbsoluteCanvasSize.Y) or scrollFrame.CanvasSize.Y.Offset
			if view <= 0 or content <= view + 1 then
				track.Visible = false
				thumb.Visible = false
				return
			end
			track.Visible = true
			thumb.Visible = true
			local trackH = track.AbsoluteSize.Y
			local thumbH = math.max(20, math.floor(trackH * (view / content)))
			local maxThumbY = trackH - thumbH
			local maxCanvasY = content - view
			local ratio = (maxCanvasY > 0) and math.clamp(scrollFrame.CanvasPosition.Y / maxCanvasY, 0, 1) or 0
			thumb.Size = UDim2.new(1, 0, 0, thumbH)
			thumb.Position = UDim2.new(0, 0, 0, math.floor(maxThumbY * ratio))
		end

		scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(updateScroll)
		scrollFrame:GetPropertyChangedSignal("CanvasSize"):Connect(updateScroll)
		scrollFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateScroll)
		scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScroll)
		track:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScroll)

		local scrollDragging, scrollDragOffsetY = false, 0
		local function scrollToTrackLocalY(localY)
			local view = (scrollFrame.AbsoluteWindowSize.Y > 0 and scrollFrame.AbsoluteWindowSize.Y) or scrollFrame.AbsoluteSize.Y
			local content = (scrollFrame.AbsoluteCanvasSize.Y > 0 and scrollFrame.AbsoluteCanvasSize.Y) or scrollFrame.CanvasSize.Y.Offset
			if content <= view + 1 then return end
			local maxThumbY = track.AbsoluteSize.Y - thumb.AbsoluteSize.Y
			local y = math.clamp(localY - scrollDragOffsetY, 0, maxThumbY)
			scrollFrame.CanvasPosition = Vector2.new(0, (maxThumbY > 0) and (y / maxThumbY) * (content - view) or 0)
		end

		thumb.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				scrollDragging = true
				scrollDragOffsetY = i.Position.Y - thumb.AbsolutePosition.Y
			end
		end)

		trackHit.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				scrollDragging = true
				scrollDragOffsetY = thumb.AbsoluteSize.Y / 2
				scrollToTrackLocalY(i.Position.Y - track.AbsolutePosition.Y)
			end
		end)

		UserInputService.InputChanged:Connect(function(i)
			if scrollDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				scrollToTrackLocalY(i.Position.Y - track.AbsolutePosition.Y)
			end
		end)

		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				scrollDragging = false
			end
		end)

		task.defer(updateScroll)
		return updateScroll, track, thumb
	end

	local function makeList(page, topOffset, bottomOffset, rightInset)
		local list = Instance.new("ScrollingFrame")
		list.Size = UDim2.new(1, 0, 1, -(topOffset + (bottomOffset or 0)))
		list.Position = UDim2.fromOffset(0, topOffset)
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.ScrollBarThickness = 0
		list.ScrollBarImageTransparency = 1
		list.CanvasSize = UDim2.new(0, 0, 0, 0)
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.ScrollingDirection = Enum.ScrollingDirection.Y
		list.Active = true
		list.Parent = page

		local updateScroll, track = applyCustomScroll(list, page, topOffset, bottomOffset or 0, rightInset)
		return list, updateScroll, track
	end

	local function makeToolbar(page, height, topOffset)
		topOffset = topOffset or 10
		height = height or 30
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, 0, 0, height)
		bar.Position = UDim2.fromOffset(0, topOffset)
		bar.BackgroundTransparency = 1
		bar.BorderSizePixel = 0
		bar.Active = false
		bar.Parent = page
		return bar
	end

	local function makeTabs(frame, tabDefs)
		for _, t in ipairs(tabDefs or {}) do
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0, t.width, 1, 0)
			b.AnchorPoint = Vector2.new(0, 0.5)
			b.Position = UDim2.new(0, (t.x or 0), 0.5, 0)
			b.BackgroundTransparency = 1
			b.BorderSizePixel = 0
			b.AutoButtonColor = false
			b.Font = UI_FONT
			b.TextSize = 11
			b.TextColor3 = t.color or WHITE
			b.Text = t.text
			b.ZIndex = 3
			b.Parent = frame
			if t.onActivated then
				b.Activated:Connect(t.onActivated)
			end
		end
	end

	local function makeSearchBox(page, opts)
		opts = opts or {}
		local box = Instance.new("TextBox")
		box.Size = UDim2.fromOffset(opts.width or 240, opts.height or 30)
		box.AnchorPoint = Vector2.new(1, 0)
		box.Position = UDim2.new(1, -(opts.width or 240) - 12, 0, 0)
		box.BackgroundColor3 = opts.bgColor or AFEM_BLACK
		box.BackgroundTransparency = opts.bgTransparency or 0.55
		box.BorderSizePixel = 0
		box.Font = opts.font or UI_FONT
		box.TextSize = opts.textSize or 13
		box.TextColor3 = WHITE
		box.PlaceholderText = opts.placeholder or ""
		box.PlaceholderColor3 = opts.placeholderColor or Color3.fromRGB(160, 160, 160)
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.ClearTextOnFocus = false
		box.Text = ""
		box.Parent = page
		addCorner(box, UDim.new(0, opts.cornerRadius or 16))
		if opts.strokeColor then
			addStroke(box, opts.strokeColor, opts.strokeFade or 0.7)
		end
		return box
	end

	local function addHoverScale(object, factor)
		local scale = Instance.new("UIScale")
		scale.Parent = object
		local baseZ = object.ZIndex
		object.MouseEnter:Connect(function()
			tween(scale, {Scale = factor or 1.04}, 0.12)
			object.ZIndex = baseZ + 10
		end)
		object.MouseLeave:Connect(function()
			tween(scale, {Scale = 1}, 0.12)
			object.ZIndex = baseZ
		end)
		return scale
	end

	local function addLabel(parent, text, x, y, width, height, size, color, font)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(width or 1, 0, 0, height or 16)
		label.Position = UDim2.fromOffset(x, y)
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Font = font or UI_FONT
		label.TextSize = size or 13
		label.TextColor3 = color or WHITE
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.Text = text
		label.Active = false
		label.Parent = parent
		return label
	end

	-- FIX "Out of local registers ... exceeded limit 200": each section is built
	-- inside its own function to spread the local variables across several
	-- functions (each function gets its own register budget in Luau).
	local function buildSettingsSection()
		local settingsPage = pages["settings"]
		addLabel(settingsPage, tr("Appearance"), 18, 12, 1, 20, 14, WHITE, UI_FONT)
		local settingsDivider = Instance.new("Frame")
		settingsDivider.Size = UDim2.new(1, -36, 0, 1)
		settingsDivider.Position = UDim2.fromOffset(18, 40)
		settingsDivider.BackgroundColor3 = AFEM_STROKE
		settingsDivider.BackgroundTransparency = 0.75
		settingsDivider.BorderSizePixel = 0
		settingsDivider.Parent = settingsPage

		-- Row style: the label sits on the LEFT and its control on the
		-- RIGHT of the same row, which is the comfortable layout --
		local timeFormatBar = Instance.new("Frame")
		timeFormatBar.Size = UDim2.fromOffset(174, 32)
		timeFormatBar.AnchorPoint = Vector2.new(1, 0)
		timeFormatBar.Position = UDim2.new(1, -18, 0, 50)
		timeFormatBar.BackgroundColor3 = AFEM_BLACK
		timeFormatBar.BackgroundTransparency = 0.7
		timeFormatBar.BorderSizePixel = 0
		timeFormatBar.Parent = settingsPage
		addCorner(timeFormatBar, UDim.new(0, 8))
		addLabel(settingsPage, tr("Clock format"), 18, 54, 0.5, 24, 13, WHITE)

		-- Sliding pill in the Flow users style (no white outline) --
		local timePill = Instance.new("Frame")
		timePill.Name = "Pill"
		timePill.BackgroundColor3 = WHITE
		timePill.BorderSizePixel = 0
		timePill.ZIndex = 2
		timePill.Parent = timeFormatBar
		addCorner(timePill, UDim.new(0, 6))

		local timeFormatButtons = {}
		for index, format in ipairs({12, 24}) do
			local button = Instance.new("TextButton")
			button.Size = UDim2.fromOffset(82, 26)
			button.Position = UDim2.fromOffset(4 + (index - 1) * 85, 3)
			button.BackgroundTransparency = 1
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.Font = UI_FONT
			button.TextSize = 12
			button.TextColor3 = WHITE
			button.Text = tostring(format) .. " h"
			button.ZIndex = 3
			button.Parent = timeFormatBar
			addHoverScale(button, 1.06)
			timeFormatButtons[format] = button
		end

		local function styleTimeFormatButtons(animate)
			local selectedFormat = tonumber(_G.OUI10TimeFormat) == 12 and 12 or 24
			for value, timeButton in pairs(timeFormatButtons) do
				local selected = value == selectedFormat
				tween(timeButton, {TextColor3 = selected and AFEM_BLACK or WHITE}, animate and 0.2 or 0)
			end
			local activeButton = timeFormatButtons[selectedFormat]
			if activeButton then
				local goal = {Position = activeButton.Position, Size = activeButton.Size}
				if animate then
					tween(timePill, goal, 0.24, Enum.EasingStyle.Quint)
				else
					timePill.Position = goal.Position
					timePill.Size = goal.Size
				end
			end
		end

		for format, timeButton in pairs(timeFormatButtons) do
			timeButton.Activated:Connect(function()
				playClick()
				_G.OUI10TimeFormat = format
				saveConfig()
				styleTimeFormatButtons(true)
			end)
		end
		styleTimeFormatButtons(false)

		local navPositionBar = Instance.new("Frame")
		navPositionBar.Size = UDim2.fromOffset(320, 34)
		navPositionBar.AnchorPoint = Vector2.new(1, 0)
		navPositionBar.Position = UDim2.new(1, -18, 0, 118)
		navPositionBar.BackgroundColor3 = AFEM_BLACK
		navPositionBar.BackgroundTransparency = 0.7
		navPositionBar.BorderSizePixel = 0
		navPositionBar.Parent = settingsPage
		addCorner(navPositionBar, UDim.new(0, 8))
		addLabel(settingsPage, tr("Button position"), 18, 121, 0.4, 28, 13, WHITE)

		local navPositionButtons = {}
		local navPositionOptions = {
			{key = "top", label = tr("Top")},
			{key = "bottom", label = tr("Bottom")},
			{key = "left", label = tr("Left")},
			{key = "right", label = tr("Right")},
		}

		-- Sliding pill in the Flow users style (no white outline) --
		local navPosPill = Instance.new("Frame")
		navPosPill.Name = "Pill"
		navPosPill.BackgroundColor3 = WHITE
		navPosPill.BorderSizePixel = 0
		navPosPill.ZIndex = 2
		navPosPill.Parent = navPositionBar
		addCorner(navPosPill, UDim.new(0, 6))

		local function styleNavPositionButtons(animate)
			for _, option in ipairs(navPositionOptions) do
				local button = navPositionButtons[option.key]
				local selected = navPosition == option.key
				tween(button, {TextColor3 = selected and AFEM_BLACK or WHITE}, animate and 0.2 or 0)
			end
			local activeButton = navPositionButtons[navPosition]
			if activeButton then
				local goal = {Position = activeButton.Position, Size = activeButton.Size}
				if animate then
					tween(navPosPill, goal, 0.24, Enum.EasingStyle.Quint)
				else
					navPosPill.Position = goal.Position
					navPosPill.Size = goal.Size
				end
			end
		end

		for index, option in ipairs(navPositionOptions) do
			local button = Instance.new("TextButton")
			button.Size = UDim2.fromOffset(74, 26)
			button.Position = UDim2.fromOffset(4 + (index - 1) * 78, 4)
			button.BackgroundTransparency = 1
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.Font = UI_FONT
			button.TextSize = 10
			button.TextColor3 = WHITE
			button.Text = option.label
			button.ZIndex = 3
			button.Parent = navPositionBar
			addHoverScale(button, 1.06)
			navPositionButtons[option.key] = button
			button.Activated:Connect(function()
				playClick()
				applyNavPosition(option.key)
				setNavSelection(activeSectionKey)
				styleNavPositionButtons(true)
				saveConfig()
			end)
		end
		styleNavPositionButtons(false)

		-- (The bar mode disappeared along with the bar: these are bubbles now) --

		local blurTrack = Instance.new("Frame")
		blurTrack.Size = UDim2.fromOffset(44, 24)
		blurTrack.AnchorPoint = Vector2.new(1, 0)
		blurTrack.Position = UDim2.new(1, -18, 0, 88)
		blurTrack.BackgroundColor3 = blurEnabled and Color3.fromRGB(180, 180, 185) or Color3.fromRGB(65, 65, 70)
		blurTrack.BorderSizePixel = 0
		blurTrack.Parent = settingsPage
		addCorner(blurTrack, UDim.new(1, 0))
		local blurLabel = addLabel(settingsPage, tr("Background blur"), 18, 88, 0.6, 24, 13, WHITE)

		local blurKnob = Instance.new("Frame")
		blurKnob.Size = UDim2.fromOffset(18, 18)
		blurKnob.Position = blurEnabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		blurKnob.BackgroundColor3 = WHITE
		blurKnob.BorderSizePixel = 0
		blurKnob.Parent = blurTrack
		addCorner(blurKnob, UDim.new(1, 0))

		local blurToggle = Instance.new("TextButton")
		blurToggle.Size = UDim2.fromScale(1, 1)
		blurToggle.BackgroundTransparency = 1
		blurToggle.Text = ""
		blurToggle.Parent = blurTrack
		blurToggle.Activated:Connect(function()
			playClick()
			blurEnabled = not blurEnabled
			_G.OUI10BlurEnabled = blurEnabled
			saveConfig()
			tween(blurTrack, {BackgroundColor3 = blurEnabled and Color3.fromRGB(180, 180, 185) or Color3.fromRGB(65, 65, 70)}, 0.2)
			tween(blurKnob, {Position = blurEnabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, 0.2, Enum.EasingStyle.Quart)
			if blur then
				tween(blur, {Size = isOpen and blurEnabled and BLUR_OPEN or 0}, 0.35, Enum.EasingStyle.Quint)
			end
		end)

		addLabel(settingsPage, tr("Do not disturb"), 18, 163, 0.6, 24, 14, WHITE, UI_FONT)
		addLabel(settingsPage, tr("Controls the information visible to other Flow users."), 18, 187, 1, 20, 11, SUB_COLOR)

		local dndSwitches = {}
		local function applyDndSwitch(key, enabled, animate)
			local switch = dndSwitches[key]
			if not switch then
				return
			end
			local background = enabled and Color3.fromRGB(180, 180, 185) or Color3.fromRGB(65, 65, 70)
			local knobPosition = enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
			if animate then
				tween(switch.track, {BackgroundColor3 = background}, 0.2)
				tween(switch.knob, {Position = knobPosition}, 0.2, Enum.EasingStyle.Quart)
			else
				switch.track.BackgroundColor3 = background
				switch.knob.Position = knobPosition
			end
		end

		local function addDndSwitch(key, labelText, y, onChanged, parent)
			local track = Instance.new("Frame")
			track.Size = UDim2.fromOffset(44, 24)
			track.AnchorPoint = Vector2.new(1, 0)
			track.Position = UDim2.new(1, -18, 0, y)
			track.BackgroundColor3 = dndConfig[key] and Color3.fromRGB(180, 180, 185) or Color3.fromRGB(65, 65, 70)
			track.BorderSizePixel = 0
			track.Parent = parent or settingsPage
			addCorner(track, UDim.new(1, 0))
			addLabel(parent or settingsPage, labelText, 18, y, 0.7, 24, 12, WHITE)

			local knob = Instance.new("Frame")
			knob.Size = UDim2.fromOffset(18, 18)
			knob.Position = dndConfig[key] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
			knob.BackgroundColor3 = WHITE
			knob.BorderSizePixel = 0
			knob.Parent = track
			addCorner(knob, UDim.new(1, 0))

			local button = Instance.new("TextButton")
			button.Size = UDim2.fromScale(1, 1)
			button.BackgroundTransparency = 1
			button.Text = ""
			button.Parent = track
			dndSwitches[key] = {track = track, knob = knob}
			button.Activated:Connect(function()
				playClick()
				local enabled = not dndConfig[key]
				if onChanged then
					onChanged(enabled)
				else
					dndConfig[key] = enabled
				end
				local flowConfig = _G._FlowCfg
				if type(flowConfig) == "table" then
					flowConfig[key] = dndConfig[key]
					if key == "DND_HideGame" then
						flowConfig.DND_HideBanner = dndConfig.DND_HideBanner
					end
				end
				applyDndSwitch(key, dndConfig[key], true)
				if writePresence then
					writePresence()
				if requestPresenceRefresh then
					requestPresenceRefresh()
				end
				end
				saveConfig()
			end)
		end

		-- Options container: only shown while Do not disturb is active --
		local dndOptionsHost = Instance.new("Frame")
		dndOptionsHost.Name = "DndOptionsHost"
		dndOptionsHost.Size = UDim2.new(1, 0, 0, 0)
		dndOptionsHost.Position = UDim2.fromOffset(0, 243)
		dndOptionsHost.BackgroundTransparency = 1
		dndOptionsHost.BorderSizePixel = 0
		dndOptionsHost.ClipsDescendants = true
		dndOptionsHost.Parent = settingsPage

		local function setDndOptionsVisible(visible, animate)
			local goalSize = UDim2.new(1, 0, 0, visible and 304 or 0)
			if animate then
				tween(dndOptionsHost, {Size = goalSize}, 0.28, Enum.EasingStyle.Quart)
			else
				dndOptionsHost.Size = goalSize
			end
		end

		addDndSwitch("DND_Enabled", tr("Enable Do not disturb"), 215, function(enabled)
			dndConfig.DND_Enabled = enabled
			setDndOptionsVisible(enabled, true)
		end)
		local dndOptions = {
			{key = "DND_HideGame", label = tr("Hide game and banner")},
			{key = "DND_HideAvatar", label = tr("Hide avatar")},
			{key = "DND_HideName", label = tr("Hide name")},
			{key = "DND_HidePlayers", label = tr("Hide players")},
			{key = "DND_HidePing", label = tr("Hide ping")},
			{key = "DND_BlockJoin", label = tr("Block joining my server")},
		}
		for index, option in ipairs(dndOptions) do
			local optionKey = option.key
			local y = 6 + (index - 1) * 30
			addDndSwitch(optionKey, option.label, y, function(enabled)
				if optionKey == "DND_HideGame" then
					dndConfig.DND_HideGame = enabled
					dndConfig.DND_HideBanner = enabled
				else
					dndConfig[optionKey] = enabled
				end
			end, dndOptionsHost)
		end

		local function addDndTextBox(labelText, key, y, placeholder, parent)
			local box = Instance.new("TextBox")
			box.Size = UDim2.fromOffset(260, 26)
			box.AnchorPoint = Vector2.new(1, 0)
			box.Position = UDim2.new(1, -18, 0, y)
			box.BackgroundColor3 = AFEM_BLACK
			box.BackgroundTransparency = 0.55
			box.BorderSizePixel = 0
			box.Font = UI_FONT
			box.TextSize = 11
			box.TextColor3 = WHITE
			box.PlaceholderColor3 = TEXT_DIM
			box.PlaceholderText = placeholder
			box.TextXAlignment = Enum.TextXAlignment.Left
			box.ClearTextOnFocus = false
			box.Text = tostring(dndConfig[key] or "")
			box.Parent = parent or settingsPage
			addCorner(box, UDim.new(0, 7))
			addLabel(parent or settingsPage, labelText, 18, y + 4, 0.4, 20, 11, WHITE)
			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 7)
			padding.Parent = box
			box.FocusLost:Connect(function()
				local value = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
				if value ~= "" then
					dndConfig[key] = value
					local flowConfig = _G._FlowCfg
					if type(flowConfig) == "table" then
						flowConfig[key] = value
					end
					if writePresence then
						writePresence()
					if requestPresenceRefresh then
						requestPresenceRefresh()
					end
					end
					saveConfig()
				else
					box.Text = tostring(dndConfig[key] or "")
				end
			end)
		end
		addDndTextBox(tr("Banner ID"), "DND_BannerId", 198, tr("Image ID"), dndOptionsHost)
		addDndTextBox(tr("Avatar ID"), "DND_AvatarId", 232, tr("Image ID"), dndOptionsHost)
		addDndTextBox(tr("Custom name"), "DND_CustomName", 266, "Hidden", dndOptionsHost)
		setDndOptionsVisible(dndConfig.DND_Enabled == true, false)
	end
	buildSettingsSection()

	local function buildServersSection()
		local serversPage = pages["servers"]
		local serversToolbar = makeToolbar(serversPage, 30, 196)
		local serverSortMode = "ping"
		local serverSortButtons = {}
		local serverCache = {}
		local serverPageNumber = 1
		local SERVERS_PER_PAGE = 9 -- cuadricula 3x3 completa: ya no falta ninguno abajo a la derecha
		local serverFirstSeen = {}
		local serverAgeLabels = {}
		local serverFetchActive = false
		local serverHasFetched = false
		local serverLastFetch = 0
		local serverFetchError = nil
		local serverSearchText = ""
		-- Flow users parity: the list only re-renders on entry when something
		-- changed (static, no stagger); the section fade shows the cards. --
		local serversAnimate = true
		local serversPageDirty = false
		local renderServerPage
		local serverPagRebuild
		local serverPagGo
		-- Banner band: STATIC — it always resolves YOUR own server, so
		-- opening another server never changes the job id / players /
		-- ping shown up there --
		local updateBanner = nil

                -- Flow users style entrance animation (staggered diagonal reveal) --
                local SERVER_FADE_PROPS = {"TextTransparency", "ImageTransparency", "BackgroundTransparency", "Transparency"}
                local function animateServerCardEntrance(card, scale, order)
                        local epoch = cardEntranceEpoch
                        local col = (order - 1) % 3
                        local row = math.floor((order - 1) / 3)
                        local delay = (row + col) * 0.07

                        local bases = {}
                        local function rec(obj)
                                local t = {}
                                for _, prop in ipairs(SERVER_FADE_PROPS) do
                                        local ok, value = pcall(function()
                                                return obj[prop]
                                        end)
                                        if ok and type(value) == "number" then
                                                t[prop] = value
                                        end
                                end
                                bases[obj] = t
                                for _, child in ipairs(obj:GetChildren()) do
                                        rec(child)
                                end
                        end
                        rec(card)
                        local sectionCard = sectionCards["servers"] and sectionCards["servers"].card
                        if sectionCard then
                            for obj in pairs(bases) do
                                cacheSectionFadeObject(sectionCard, obj)
                            end
                        end
                        card:SetAttribute("OUI10CardBusy", os.clock() + delay + 0.45)

                        for obj, t in pairs(bases) do
                                for prop in pairs(t) do
                                        pcall(function()
                                                obj[prop] = 1
                                        end)
                                end
                        end
                        if scale then
                            scale.Scale = 0.92
                        end

                        task.delay(delay, function()
                            if not card.Parent then
                                return
                            end
                            if scale then
                                tween(scale, {Scale = 1}, 0.32, Enum.EasingStyle.Quint)
                            end
                            if epoch ~= cardEntranceEpoch then
                                return
                            end
                            for obj, t in pairs(bases) do
                                for prop, base in pairs(t) do
                                    tween(obj, {[prop] = base}, 0.3, Enum.EasingStyle.Quint)
                                end
                            end
                        end)
                end

		-- Game banner: rounded art on top with a dark gradient division
		-- running top to bottom; the dense bottom of that division is the
		-- data band (server info + Play + Copy ID). It follows the server
		-- selected in the grid and defaults to the one you are on. --
		local function buildServerBanner()
			local holder = Instance.new("Frame")
			holder.Name = "ServerBanner"
			holder.Size = UDim2.new(1, -24, 0, 176)
			holder.Position = UDim2.fromOffset(12, 10)
			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.ZIndex = 2
			holder.Parent = serversPage
			-- shadow lives on the UNCLIPPED holder so the halo is not cut --
			addCorner(holder, UDim.new(0, 18))
			addShadow(holder, 18, 0.45, UDim2.new(0, 0, 0, 5))

			local clip = Instance.new("Frame")
			clip.Name = "BannerClip"
			clip.Size = UDim2.fromScale(1, 1)
			clip.BackgroundColor3 = AFEM_CARD
			clip.BackgroundTransparency = 0.06
			clip.BorderSizePixel = 0
			clip.ClipsDescendants = true
			clip.ZIndex = 2
			clip.Parent = holder
			addCorner(clip, UDim.new(0, 18))
			-- same border language as the Flow users cards --
			addUserCardStroke(clip)

			local art = Instance.new("ImageLabel")
			art.Name = "BannerArt"
			art.Size = UDim2.fromScale(1, 1)
			art.BackgroundTransparency = 1
			art.BorderSizePixel = 0
			art.ScaleType = Enum.ScaleType.Crop
			art.ImageColor3 = Color3.new(1, 1, 1)
			art.Image = gameIconThumb(512, 512)
			art.ZIndex = 2
			art.Parent = clip

			-- Darkness division over the art: almost clear at the top so
			-- the icon reads, dense at the bottom so the data band always
			-- has contrast on any thumbnail. --
			local shade = Instance.new("Frame")
			shade.Name = "BannerShade"
			shade.Size = UDim2.fromScale(1, 1)
			shade.BackgroundColor3 = Color3.new(0, 0, 0)
			shade.BackgroundTransparency = 0
			shade.BorderSizePixel = 0
			shade.ZIndex = 3
			shade.Parent = clip
			local shadeFade = Instance.new("UIGradient")
			shadeFade.Rotation = 90
			shadeFade.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(0.45, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(1, AFEM_CARD),
			})
			shadeFade.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.9),
				NumberSequenceKeypoint.new(0.34, 0.7),
				NumberSequenceKeypoint.new(0.66, 0.28),
				NumberSequenceKeypoint.new(1, 0.04),
			})
			shadeFade.Parent = shade

			local function makeBannerLabel(name, y, height, size, color)
				local label = Instance.new("TextLabel")
				label.Name = name
				label.Size = UDim2.new(1, -300, 0, height)
				label.Position = UDim2.new(0, 16, 1, y)
				label.BackgroundTransparency = 1
				label.BorderSizePixel = 0
				label.Font = UI_FONT
				label.TextSize = size
				label.TextColor3 = color
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextTruncate = Enum.TextTruncate.AtEnd
				label.ZIndex = 4
				label.Parent = clip
				return label
			end
			local scopeLabel = makeBannerLabel("BannerScope", -68, 12, 10, TEXT_DIM)
			local playersLabel = makeBannerLabel("BannerPlayers", -54, 18, 14, WHITE)
			local metaLabel = makeBannerLabel("BannerMeta", -32, 14, 10, TEXT_DIM)
			scopeLabel.Text = tr("YOUR SERVER")

			local function makeBannerButton(name, text, width, xFromRight)
				local button = Instance.new("TextButton")
				button.Name = name
				button.Size = UDim2.fromOffset(width, 34)
				button.AnchorPoint = Vector2.new(1, 1)
				button.Position = UDim2.new(1, xFromRight, 1, -16)
				button.BorderSizePixel = 0
				button.AutoButtonColor = false
				button.Font = UI_FONT
				button.TextSize = 12
				button.Text = text
				button.ZIndex = 4
				button.Parent = clip
				addCorner(button, UDim.new(0, 17))
				addHoverScale(button, 1.05)
				return button
			end
			-- White pill = play, dark glass pill = copy (right aligned) --
			local playBtn = makeBannerButton("BannerPlay", "▶ Play", 96, -16)
			playBtn.BackgroundColor3 = WHITE
			playBtn.BackgroundTransparency = 0.12
			playBtn.TextColor3 = AFEM_BLACK
			local copyBtn = makeBannerButton("BannerCopyId", tr("Copy ID"), 86, -120)
			copyBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
			copyBtn.BackgroundTransparency = 0.15
			copyBtn.TextColor3 = WHITE
			addAFEMStroke(copyBtn, 1, 0.15)

			-- YOUR own server, looked up in the cache so its
			-- players/ping show when the API returned it --
			local function resolveBannerServer()
				local myId = tostring(game.JobId or "")
				if myId ~= "" then
					for _, entry in ipairs(serverCache) do
						if tostring(entry.id) == myId then
							return entry
						end
					end
					return { id = myId }
				end
				return nil
			end

			updateBanner = function()
				local server = resolveBannerServer()
				scopeLabel.Text = tr("YOUR SERVER")
				if not server then
					playersLabel.Text = "Players: ? / ?"
					metaLabel.Text = tr("Server ID unavailable")
					return
				end
				local playing = tonumber(server.playing)
				local maxPlayers = tonumber(server.maxPlayers)
				if playing and maxPlayers then
					playersLabel.Text = string.format(tr("Players: %d / %d"), playing, maxPlayers)
				else
					playersLabel.Text = "Players: ? / ?"
				end
				local parts = {}
				local ping = tonumber(server.ping)
				if ping then
					parts[#parts + 1] = tostring(math.floor(ping + 0.5)) .. " ms"
				end
				parts[#parts + 1] = "ID: " .. tostring(server.id or "")
				metaLabel.Text = table.concat(parts, "   ·   ")
			end

			playBtn.Activated:Connect(function()
				local server = resolveBannerServer()
				local jobId = server and tostring(server.id or "") or ""
				if jobId == "" then
					notify(tr("Server unavailable"))
					return
				end
				playClick()
				pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
				end)
				notify("Connecting...")
			end)

			copyBtn.Activated:Connect(function()
				local server = resolveBannerServer()
				local jobId = server and tostring(server.id or "") or ""
				if jobId == "" then
					return
				end
				playClick()
				local clipboard
				pcall(function()
					clipboard = setclipboard or toclipboard or (syn and syn.write_clipboard)
				end)
				local copied = type(clipboard) == "function" and pcall(clipboard, jobId)
				copyBtn.Text = copied and tr("Copied") or tr("Unavailable")
				task.delay(1.2, function()
					if copyBtn.Parent then
						copyBtn.Text = tr("Copy ID")
					end
				end)
			end)

			updateBanner()
		end
		buildServerBanner()

		-- Server counter aligned to the right (same as Flow users) --
		local serverStatus = Instance.new("TextLabel")
		serverStatus.Size = UDim2.fromOffset(140, 30)
		serverStatus.AnchorPoint = Vector2.new(1, 0.5)
		serverStatus.Position = UDim2.new(1, -(12 + 260 + 10), 0.5, 0)
		serverStatus.BackgroundTransparency = 1
		serverStatus.BorderSizePixel = 0
		serverStatus.Font = UI_FONT
		serverStatus.TextSize = 13
		serverStatus.TextColor3 = WHITE
		serverStatus.TextXAlignment = Enum.TextXAlignment.Right
		serverStatus.TextTruncate = Enum.TextTruncate.AtEnd
		serverStatus.Text = tr("Load public servers")
		serverStatus.Active = false
		serverStatus.ZIndex = 5
		serverStatus.Parent = serversToolbar

		-- Search box on the right (same position as in Flow users) --
		local serverSearch = makeSearchBox(serversToolbar, {
			width = 260,
			height = 30,
			font = UI_FONT,
			textSize = 13,
			placeholder = tr("Search server…"),
			placeholderColor = Color3.fromRGB(160, 160, 160),
			cornerRadius = 16,
			strokeColor = Color3.fromRGB(80, 80, 80),
			strokeFade = 0.7,
		})
		serverSearch.AnchorPoint = Vector2.new(1, 0.5)
		serverSearch.Position = UDim2.new(1, -12, 0.5, 0)
		serverSearch.ZIndex = 5
		local serverSearchPad = Instance.new("UIPadding")
		serverSearchPad.PaddingLeft = UDim.new(0, 12)
		serverSearchPad.PaddingRight = UDim.new(0, 12)
		serverSearchPad.Parent = serverSearch

		-- The 4 server lists sit on the left of the row under the banner --
		local serverSortBar = Instance.new("Frame")
		serverSortBar.Size = UDim2.fromOffset(240, 30)
		serverSortBar.AnchorPoint = Vector2.new(0, 0.5)
		serverSortBar.Position = UDim2.new(0, 0, 0.5, 0)
		serverSortBar.BackgroundColor3 = AFEM_BLACK
		serverSortBar.BackgroundTransparency = 0.75
		serverSortBar.BorderSizePixel = 0
		serverSortBar.ZIndex = 5
		serverSortBar.Parent = serversToolbar
		addCorner(serverSortBar, UDim.new(0, 16))


		-- Sliding white pill: same animation as the Flow users tabs --
		local serverSortPill = Instance.new("Frame")
		serverSortPill.Name = "SortPill"
		serverSortPill.AnchorPoint = Vector2.new(0, 0.5)
		serverSortPill.BackgroundColor3 = WHITE
		serverSortPill.BorderSizePixel = 0
		serverSortPill.ZIndex = 5
		serverSortPill.Parent = serverSortBar
		addCorner(serverSortPill, UDim.new(0, 11))

		local function updateServerSortStyle(noAnimation)
			local target = serverSortButtons[serverSortMode]
			if target then
				local goal = {
					Position = UDim2.new(0, target.Position.X.Offset + 4, 0.5, 0),
					Size = UDim2.new(0, math.max(28, target.Size.X.Offset - 8), 0, 22),
				}
				if noAnimation then
					serverSortPill.Position = goal.Position
					serverSortPill.Size = goal.Size
				else
					tween(serverSortPill, goal, 0.3, Enum.EasingStyle.Quart)
				end
			end
			for key, button in pairs(serverSortButtons) do
				local selected = key == serverSortMode
				tween(button, {
					TextColor3 = selected and AFEM_BLACK or WHITE,
				}, noAnimation and 0 or 0.2)
			end
		end

		for _, option in ipairs({
			{key = "ping", label = "Ping", width = 44, x = 0},
			{key = "full", label = tr("Most full"), width = 62, x = 48},
			{key = "empty", label = tr("Most empty"), width = 62, x = 114},
			{key = "region", label = tr("Region"), width = 54, x = 180},
		}) do
			local button = Instance.new("TextButton")
			button.Size = UDim2.fromOffset(option.width, 22)
			button.AnchorPoint = Vector2.new(0, 0.5)
			button.Position = UDim2.new(0, option.x, 0.5, 0)
			button.BackgroundColor3 = WHITE
			button.BackgroundTransparency = 1
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.Font = UI_FONT
			button.TextSize = 10
			button.TextColor3 = WHITE
			button.Text = option.label
			button.ZIndex = 6
			button.Parent = serverSortBar
			addCorner(button, UDim.new(0, 11))
			addHoverScale(button, 1.06)
			serverSortButtons[option.key] = button
			button.Activated:Connect(function()
				playClick()
				serverSortMode = option.key
				serverPageNumber = 1
				updateServerSortStyle()
				renderServerPage()
			end)
		end


		local serversList, updateServersScroll = makeList(serversPage, 242, 48)
		local serversLayout = Instance.new("UIGridLayout")
		serversLayout.CellSize = UDim2.new(1 / 3, -10, 0, 116)
		serversLayout.CellPadding = UDim2.new(0, 15, 0, 14)
		serversLayout.SortOrder = Enum.SortOrder.LayoutOrder
		serversLayout.Parent = serversList
		local serversPadding = Instance.new("UIPadding")
		serversPadding.PaddingLeft = UDim.new(0, 18)
		serversPadding.PaddingRight = UDim.new(0, 18)
		serversPadding.PaddingTop = UDim.new(0, 14)
		serversPadding.PaddingBottom = UDim.new(0, 14)
		serversPadding.Parent = serversList
		local function fitServersGrid()
			local viewHeight = serversList.AbsoluteSize.Y
			if viewHeight <= 0 then
				return
			end
			local viewWidth = serversList.AbsoluteSize.X
			local columns = (IS_TOUCH_DEVICE or viewWidth < 560) and 2 or 3
			local cardHeight = math.clamp(math.floor((viewHeight - 56) / 3), 58, 116)
			serversLayout.CellSize = UDim2.new(1 / columns, -10, 0, cardHeight)
		end
		serversList:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitServersGrid)
		task.defer(fitServersGrid)

		local serverPagBar = Instance.new("Frame")
		serverPagBar.Size = UDim2.new(1, 0, 0, 46)
		serverPagBar.Position = UDim2.new(0, 0, 1, -50)
		serverPagBar.BackgroundTransparency = 1
		serverPagBar.BorderSizePixel = 0
		serverPagBar.Active = false
		serverPagBar.Parent = serversPage
		
		local serverPagLayout = Instance.new("UIListLayout")
		serverPagLayout.FillDirection = Enum.FillDirection.Horizontal
		serverPagLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		serverPagLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		serverPagLayout.SortOrder = Enum.SortOrder.LayoutOrder
		serverPagLayout.Padding = UDim.new(0, 6)
		serverPagLayout.Parent = serverPagBar
		
		local function makeServerPagButton(text, order, width)
			local button = Instance.new("TextButton")
			button.Size = UDim2.fromOffset(width, 28)
			button.BackgroundColor3 = AFEM_BLACK
			button.BackgroundTransparency = 0.75
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.Font = UI_FONT
			button.TextSize = 14
			button.TextColor3 = WHITE
			button.Text = text
			button.LayoutOrder = order
			button.Parent = serverPagBar
			addCorner(button, UDim.new(0, 12))
			addStroke(button, AFEM_STROKE, 0.5)
			addHoverScale(button, 1.05)
			return button
		end
		
		local serverPagPrev = makeServerPagButton("‹", 1, 42)
		local serverPagNext = makeServerPagButton("›", 9999, 42)
		
		local function addServerPagKeyHint(button, key)
			local hint = Instance.new("TextLabel")
			hint.Size = UDim2.fromOffset(22, 14)
			hint.AnchorPoint = Vector2.new(0.5, 1)
			hint.Position = UDim2.new(0.5, 0, 0, -2)
			hint.BackgroundTransparency = 1
			hint.BorderSizePixel = 0
			hint.Font = UI_FONT
			hint.TextSize = 10
			hint.TextColor3 = WHITE
			hint.TextTransparency = 0.2
			hint.Text = key
			hint.Parent = button
		end
		
		addServerPagKeyHint(serverPagPrev, "Q")
		addServerPagKeyHint(serverPagNext, "E")
		
		local serverLastTotalPages = 1
		
		serverPagRebuild = function(totalPages)
			serverLastTotalPages = totalPages
			serverPagPrev.TextTransparency = serverPageNumber <= 1 and 0.6 or 0
			serverPagNext.TextTransparency = serverPageNumber >= totalPages and 0.6 or 0
			for _, child in ipairs(serverPagBar:GetChildren()) do
				if child.Name == "ServerPagCircle" then
					child:Destroy()
				end
			end
			for pageNum = 1, totalPages do
				local active = (pageNum == serverPageNumber)
				local circle = Instance.new("TextButton")
				circle.Name = "ServerPagCircle"
				circle.Size = UDim2.fromOffset(30, 30)
				circle.BackgroundColor3 = WHITE
				circle.BackgroundTransparency = active and 0 or 1
				circle.BorderSizePixel = 0
				circle.AutoButtonColor = false
				circle.Font = UI_FONT
				circle.TextSize = 12
				circle.TextColor3 = active and AFEM_BLACK or WHITE
				circle.TextTransparency = active and 0 or 0.55
				circle.Text = tostring(pageNum)
				circle.LayoutOrder = 10 + pageNum
				circle.Parent = serverPagBar
				addCorner(circle, UDim.new(1, 0))
				addHoverScale(circle, 1.1)
				circle.Activated:Connect(function()
					if pageNum ~= serverPageNumber then
						playClick()
						serverPageNumber = pageNum
						renderServerPage()
					end
				end)
			end
		end
		
		serverPagGo = function(pageNum)
			pageNum = math.clamp(pageNum, 1, serverLastTotalPages)
			if pageNum == serverPageNumber then
				return
			end
			playClick()
			serverPageNumber = pageNum
			renderServerPage()
		end

		-- The public servers API exposes no region field, so "Region" is
		-- approximated by ping distance to the server the player is on:
		-- servers in the same region answer with a similar ping, so the
		-- pings closest to yours come first (fallback: the closest ping
		-- seen in the list). --
		local function regionBaselinePing()
			local myId = tostring(game.JobId or "")
			if myId ~= "" then
				for _, entry in ipairs(serverCache) do
					if tostring(entry.id) == myId then
						local ping = tonumber(entry.ping)
						if ping then
							return ping
						end
					end
				end
			end
			local closest = nil
			for _, entry in ipairs(serverCache) do
				local ping = tonumber(entry.ping)
				if ping and (not closest or ping < closest) then
					closest = ping
				end
			end
			return closest
		end

		local function sortedServers()
			local rows = table.clone(serverCache)
			local query = serverSearchText:gsub("^%s+", ""):gsub("%s+$", ""):lower()
			if query ~= "" then
				local filtered = {}
				for _, entry in ipairs(rows) do
					local id = tostring(entry.id or ""):lower()
					local ping = tostring(entry.ping or "")
					if id:find(query, 1, true) or ping:find(query, 1, true) then
						filtered[#filtered + 1] = entry
					end
				end
				rows = filtered
			end
			local regionBase = (serverSortMode == "region") and regionBaselinePing() or nil
			table.sort(rows, function(a, b)
				if serverSortMode == "ping" then
					local pingA = tonumber(a.ping) or math.huge
					local pingB = tonumber(b.ping) or math.huge
					if pingA ~= pingB then
						return pingA < pingB
					end
				elseif serverSortMode == "full" then
					if a.playing ~= b.playing then
						return a.playing > b.playing
					end
				elseif serverSortMode == "region" then
					local pingA = tonumber(a.ping) or math.huge
					local pingB = tonumber(b.ping) or math.huge
					local distA = regionBase and math.abs(pingA - regionBase) or pingA
					local distB = regionBase and math.abs(pingB - regionBase) or pingB
					if distA ~= distB then
						return distA < distB
					end
				elseif a.playing ~= b.playing then
					return a.playing < b.playing
				end
				return tostring(a.id) < tostring(b.id)
			end)
			return rows
		end

		local function formatServerSeen(firstSeen)
			local age = math.max(0, os.time() - firstSeen)
			if age < 60 then
				return tostring(age) .. "s"
			elseif age < 3600 then
				return tostring(math.floor(age / 60)) .. "m"
			elseif age < 86400 then
				return tostring(math.floor(age / 3600)) .. "h"
			end
			return tostring(math.floor(age / 86400)) .. "d"
		end

		-- Expanded server panel (bubble effect on click) ------------------------
		local detailServer = nil
		local detailFirstSeen = nil

		local serverDetailBackdrop = Instance.new("TextButton")
		serverDetailBackdrop.Name = "ServerDetailBackdrop"
		serverDetailBackdrop.Size = UDim2.fromScale(1, 1)
		serverDetailBackdrop.BackgroundColor3 = Color3.new(0, 0, 0)
		serverDetailBackdrop.BackgroundTransparency = 1
		serverDetailBackdrop.BorderSizePixel = 0
		serverDetailBackdrop.AutoButtonColor = false
		serverDetailBackdrop.Text = ""
		serverDetailBackdrop.Visible = false
		serverDetailBackdrop.ZIndex = 30
		serverDetailBackdrop.Parent = serversPage

		local serverDetail = Instance.new("Frame")
		serverDetail.Name = "ServerDetail"
		serverDetail.AnchorPoint = Vector2.new(0.5, 0.5)
		serverDetail.Position = UDim2.fromScale(0.5, 0.5)
		serverDetail.BackgroundTransparency = 1
		serverDetail.BorderSizePixel = 0
		serverDetail.Visible = false
		serverDetail.ZIndex = 31
		serverDetail.Parent = serversPage
		addShadow(serverDetail, 24, 0.4, UDim2.new(0, 0, 0, 6))

		local detailScale = Instance.new("UIScale")
		detailScale.Parent = serverDetail

		-- Clipped container (ClipsDescendants): the banner is cut at the middle --
		local detailClip = Instance.new("Frame")
		detailClip.Name = "DetailClip"
		detailClip.Size = UDim2.fromScale(1, 1)
		detailClip.BackgroundColor3 = AFEM_CARD
		detailClip.BackgroundTransparency = 0.06
		detailClip.BorderSizePixel = 0
		detailClip.ClipsDescendants = true
		detailClip.ZIndex = 31
		detailClip.Parent = serverDetail
		addCorner(detailClip, UDim.new(0, 20))
		addAFEMStroke(detailClip, 1.2, 0.35)

		local detailBanner = Instance.new("ImageLabel")
		detailBanner.Name = "DetailBanner"
		detailBanner.Size = UDim2.new(1, 0, 0.5, 0)
		detailBanner.BackgroundTransparency = 1
		detailBanner.BorderSizePixel = 0
		detailBanner.ScaleType = Enum.ScaleType.Crop
		detailBanner.ImageColor3 = Color3.fromRGB(143, 143, 147)
		detailBanner.Image = gameIconThumb(256, 256)
		detailBanner.ZIndex = 31
		detailBanner.Parent = detailClip
		addCorner(detailBanner, UDim.new(0, 20))

		-- "Cut" shading: the banner fades out and disappears at the middle --
		local detailShade = Instance.new("Frame")
		detailShade.Name = "DetailShade"
		detailShade.Size = UDim2.new(1, 0, 0.5, 0)
		detailShade.BackgroundColor3 = Color3.new(0, 0, 0)
		detailShade.BackgroundTransparency = 0
		detailShade.BorderSizePixel = 0
		detailShade.ZIndex = 32
		detailShade.Parent = detailClip
		addCorner(detailShade, UDim.new(0, 20))
		local detailShadeFade = Instance.new("UIGradient")
		detailShadeFade.Rotation = 90
		detailShadeFade.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
			ColorSequenceKeypoint.new(0.6, Color3.new(0, 0, 0)),
			ColorSequenceKeypoint.new(1, AFEM_CARD),
		})
		detailShadeFade.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.45),
			NumberSequenceKeypoint.new(0.5, 0.7),
			NumberSequenceKeypoint.new(0.82, 0.2),
			NumberSequenceKeypoint.new(1, 0.06),
		})
		detailShadeFade.Parent = detailShade

		-- Server data centered on the lower half --
		local detailInfo = Instance.new("Frame")
		detailInfo.Name = "DetailInfo"
		detailInfo.Size = UDim2.new(1, -36, 0.5, -10)
		detailInfo.Position = UDim2.new(0, 18, 0.5, 5)
		detailInfo.BackgroundTransparency = 1
		detailInfo.BorderSizePixel = 0
		detailInfo.ZIndex = 33
		detailInfo.Parent = detailClip

		local detailLayout = Instance.new("UIListLayout")
		detailLayout.FillDirection = Enum.FillDirection.Vertical
		detailLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		detailLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		detailLayout.Padding = UDim.new(0, 6)
		detailLayout.Parent = detailInfo

		local function makeDetailText(text, height, size, color, font, order)
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, height)
			label.LayoutOrder = order
			label.BackgroundTransparency = 1
			label.BorderSizePixel = 0
			label.Font = font or UI_FONT
			label.TextSize = size
			label.TextColor3 = color or WHITE
			label.TextXAlignment = Enum.TextXAlignment.Center
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.Text = text
			label.ZIndex = 33
			label.Parent = detailInfo
			return label
		end

		local detailPlayers = makeDetailText(tr("Players: 0 / 0"), 17, 13, WHITE, UI_FONT, 1)
		local detailPing = makeDetailText(tr("Ping N/A"), 15, 12, TEXT_BRIGHT, UI_FONT, 2)
		local detailAge = makeDetailText("", 15, 11, TEXT_BRIGHT, UI_FONT, 3)
		detailAge.Text = tr("Seen 0s")

		-- Row: server ID + copy button next to it --
		local detailIdRow = Instance.new("Frame")
		detailIdRow.Name = "DetailIdRow"
		detailIdRow.AutomaticSize = Enum.AutomaticSize.X
		detailIdRow.Size = UDim2.new(0, 0, 0, 17)
		detailIdRow.LayoutOrder = 4
		detailIdRow.BackgroundTransparency = 1
		detailIdRow.BorderSizePixel = 0
		detailIdRow.ZIndex = 33
		detailIdRow.Parent = detailInfo

		local detailIdRowLayout = Instance.new("UIListLayout")
		detailIdRowLayout.FillDirection = Enum.FillDirection.Horizontal
		detailIdRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		detailIdRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		detailIdRowLayout.Padding = UDim.new(0, 8)
		detailIdRowLayout.Parent = detailIdRow

		local detailIdLabel = Instance.new("TextLabel")
		detailIdLabel.Name = "DetailServerId"
		detailIdLabel.AutomaticSize = Enum.AutomaticSize.X
		detailIdLabel.Size = UDim2.new(0, 0, 0, 16)
		detailIdLabel.BackgroundTransparency = 1
		detailIdLabel.BorderSizePixel = 0
		detailIdLabel.Font = UI_FONT
		detailIdLabel.TextSize = 10
		detailIdLabel.TextColor3 = TEXT_DIM
		detailIdLabel.TextXAlignment = Enum.TextXAlignment.Left
		detailIdLabel.Text = "ID: "
		detailIdLabel.ZIndex = 34
		detailIdLabel.Parent = detailIdRow

		local detailCopy = Instance.new("TextButton")
		detailCopy.Name = "CopyServerId"
		detailCopy.Size = UDim2.fromOffset(54, 18)
		detailCopy.LayoutOrder = 2
		detailCopy.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
		detailCopy.BackgroundTransparency = 0.15
		detailCopy.BorderSizePixel = 0
		detailCopy.AutoButtonColor = false
		detailCopy.Font = UI_FONT
		detailCopy.TextSize = 9
		detailCopy.TextColor3 = WHITE
		detailCopy.Text = tr("Copy")
		detailCopy.ZIndex = 34
		detailCopy.Parent = detailIdRow
		addCorner(detailCopy, UDim.new(0, 6))
		addAFEMStroke(detailCopy, 1, 0.15)
		detailCopy.Activated:Connect(function()
			playClick()
			if not detailServer then
				return
			end
			local clipboard
			pcall(function()
				clipboard = setclipboard or toclipboard or (syn and syn.write_clipboard)
			end)
			local copied = type(clipboard) == "function" and pcall(clipboard, tostring(detailServer.id))
			detailCopy.Text = copied and tr("Copied") or tr("Unavailable")
			task.delay(1.2, function()
				if detailCopy.Parent then
					detailCopy.Text = tr("Copy")
				end
			end)
		end)

		-- Join button (same circular style as in Flow users) --
		local detailJoin = Instance.new("ImageButton")
		detailJoin.Name = "JoinServer"
		detailJoin.Size = UDim2.fromOffset(46, 46)
		detailJoin.LayoutOrder = 5
		detailJoin.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		detailJoin.BackgroundTransparency = 0.08
		detailJoin.BorderSizePixel = 0
		detailJoin.AutoButtonColor = false
		detailJoin.Image = ""
		detailJoin.ZIndex = 33
		detailJoin.Parent = detailInfo
		addCorner(detailJoin, UDim.new(1, 0))
		addAFEMStroke(detailJoin, 1.1, 0.2)
		local detailPlayIcon = Instance.new("ImageLabel")
		detailPlayIcon.Size = UDim2.fromOffset(24, 24)
		detailPlayIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		detailPlayIcon.Position = UDim2.fromScale(0.5, 0.5)
		detailPlayIcon.BackgroundTransparency = 1
		detailPlayIcon.Image = "rbxassetid://106640709678034"
		detailPlayIcon.ImageColor3 = WHITE
		detailPlayIcon.ScaleType = Enum.ScaleType.Fit
		detailPlayIcon.Active = false
		detailPlayIcon.ZIndex = 34
		detailPlayIcon.Parent = detailJoin
		detailJoin.MouseEnter:Connect(function()
			tween(detailJoin, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.15)
		end)
		detailJoin.MouseLeave:Connect(function()
			tween(detailJoin, {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}, 0.15)
		end)
		detailJoin.Activated:Connect(function()
			if not detailServer then
				return
			end
			playClick()
			local jobId = tostring(detailServer.id or "")
			if jobId == "" then
				notify(tr("Server unavailable"))
				return
			end
			pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
			end)
			notify("Connecting...")
		end)

		local function updateServerDetail()
			if not detailServer then
				return
			end
			detailPlayers.Text = string.format(
				tr("Players: %d / %d"),
				tonumber(detailServer.playing) or 0,
				tonumber(detailServer.maxPlayers) or 0
			)
			local ping = tonumber(detailServer.ping)
			detailPing.Text = ping and (tostring(math.floor(ping + 0.5)) .. " ms") or tr("Ping N/A")
			detailIdLabel.Text = "ID: " .. tostring(detailServer.id or "")
			if detailFirstSeen then
				detailAge.Text = tr("Seen ") .. formatServerSeen(detailFirstSeen)
			end
		end

		local function closeServerDetail()
			if not serverDetail.Visible then
				return
			end
			detailServer = nil
			tween(serverDetailBackdrop, {BackgroundTransparency = 1}, 0.2)
			tween(detailScale, {Scale = 0.6}, 0.2, Enum.EasingStyle.Quad)
			task.delay(0.19, function()
				if not detailServer then
					serverDetail.Visible = false
					serverDetailBackdrop.Visible = false
					detailScale.Scale = 1
				end
			end)
		end

		local function openServerDetail(server, card)
			detailServer = server
			detailFirstSeen = tonumber(server.OUI10FirstSeen) or serverFirstSeen[tostring(server.id)] or os.time()
			updateServerDetail()

			local pageAbs = serversPage.AbsoluteSize
			local finalWidth = math.clamp(pageAbs.X * 0.62, 300, 470)
			local finalHeight = math.clamp(pageAbs.Y * 0.76, 300, 380)

			-- The card grows from its position toward the center (bubble) --
			local startCenter
			local startW, startH
			if card then
				local cardAbsPos = card.AbsolutePosition
				local cardAbsSize = card.AbsoluteSize
				local pageAbsPos = serversPage.AbsolutePosition
				startCenter = Vector2.new(
					cardAbsPos.X - pageAbsPos.X + cardAbsSize.X * 0.5,
					cardAbsPos.Y - pageAbsPos.Y + cardAbsSize.Y * 0.5
				)
				startW, startH = cardAbsSize.X, cardAbsSize.Y
			else
				startCenter = Vector2.new(pageAbs.X * 0.5, pageAbs.Y * 0.5)
				startW, startH = finalWidth * 0.6, finalHeight * 0.6
			end

			serverDetail.Size = UDim2.fromOffset(startW, startH)
			serverDetail.Position = UDim2.fromOffset(startCenter.X, startCenter.Y)
			serverDetailBackdrop.Visible = true
			serverDetail.Visible = true

			tween(serverDetailBackdrop, {BackgroundTransparency = 0.5}, 0.25)
			tween(
				serverDetail,
				{
					Size = UDim2.fromOffset(finalWidth, finalHeight),
					Position = UDim2.fromOffset(pageAbs.X * 0.5, pageAbs.Y * 0.5),
				},
				0.42,
				Enum.EasingStyle.Back
			)
			tween(detailScale, {Scale = 1}, 0.42, Enum.EasingStyle.Back)
		end

		serverDetailBackdrop.Activated:Connect(function()
			playClick()
			closeServerDetail()
		end)

		renderServerPage = function()
			serversPageDirty = false
			closeServerDetail()
			for _, child in ipairs(serversList:GetChildren()) do
				if child.Name == "ServerCard" then
					child:Destroy()
				end
			end
			serverAgeLabels = {}

			local rows = sortedServers()
			local totalPages = math.max(1, math.ceil(#rows / SERVERS_PER_PAGE))
			serverPageNumber = math.clamp(serverPageNumber, 1, totalPages)
			local firstIndex = (serverPageNumber - 1) * SERVERS_PER_PAGE + 1
			local lastIndex = math.min(#rows, firstIndex + SERVERS_PER_PAGE - 1)
			for index = firstIndex, lastIndex do
				local server = rows[index]
				local row = Instance.new("TextButton")
				row.Name = "ServerCard"
				row.Size = UDim2.new(1, 0, 0, 116)
				row.BackgroundColor3 = AFEM_CARD
				row.BackgroundTransparency = 0.45
				row.BorderSizePixel = 0
				row.AutoButtonColor = false
				row.Text = ""
				row.ClipsDescendants = false
				row.LayoutOrder = index
				row.Parent = serversList
				addCorner(row, UDim.new(0, 16))
				addUserCardStroke(row)
				local cardScale = addHoverScale(row)
				addShadow(row, 6, 0.3, UDim2.new(0, 0, 0, 1))

				local banner = Instance.new("ImageLabel")
				banner.Size = UDim2.fromScale(1, 1)
				banner.BackgroundTransparency = 1
				banner.BorderSizePixel = 0
				banner.ScaleType = Enum.ScaleType.Crop
				banner.ImageColor3 = Color3.fromRGB(143, 143, 147)
				banner.Image = gameIconThumb(256, 256)
				banner.Parent = row
				addCorner(banner, UDim.new(0, 16))

				local bannerLight = Instance.new("UIGradient")
				bannerLight.Rotation = 90
				bannerLight.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
				})
				bannerLight.Parent = banner

				local shade = Instance.new("Frame")
				shade.Size = UDim2.fromScale(1, 1)
				shade.BackgroundColor3 = Color3.new(0, 0, 0)
				shade.BackgroundTransparency = 0
				shade.BorderSizePixel = 0
				shade.Parent = row
				addCorner(shade, UDim.new(0, 16))
				local shadeFade = Instance.new("UIGradient")
				shadeFade.Rotation = 90
				shadeFade.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
					ColorSequenceKeypoint.new(0.55, Color3.new(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
				})
				shadeFade.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.62),
					NumberSequenceKeypoint.new(0.58, 0.78),
					NumberSequenceKeypoint.new(1, 0.86),
				})
				shadeFade.Parent = shade

				local countLabel = addLabel(
					row,
					string.format(tr("Players: %d / %d"), tonumber(server.playing) or 0, tonumber(server.maxPlayers) or 0),
					14, 20, 1, 16, 12, WHITE, UI_FONT
				)
				countLabel.Size = UDim2.new(1, -28, 0, 16)
				local ping = tonumber(server.ping)
				local pingLabel = addLabel(
					row,
					ping and (tostring(math.floor(ping + 0.5)) .. " ms") or tr("Ping N/A"),
					14, 41, 1, 14, 11, TEXT_BRIGHT
				)
				pingLabel.Size = UDim2.new(1, -28, 0, 14)
				local idLabel = addLabel(row, "ID: " .. tostring(server.id or ""), 14, 59, 1, 14, 9, TEXT_DIM)
				idLabel.Size = UDim2.new(1, -28, 0, 14)
				local firstSeen = tonumber(server.OUI10FirstSeen) or serverFirstSeen[tostring(server.id)] or os.time()
				local ageEntry = {
					label = addLabel(row, "", 14, 79, 1, 14, 10, TEXT_BRIGHT),
					firstSeen = firstSeen,
				}
				ageEntry.label.Size = UDim2.new(1, -28, 0, 14)
				serverAgeLabels[tostring(server.id)] = ageEntry

				-- Card click: the banner band is STATIC (it always shows
				-- YOUR server), so the job id / players / ping up there
				-- never change when a card is opened; the card expands
				-- with a bubble effect and the detail modal carries the
				-- selected server's data --
				row.Activated:Connect(function()
					playClick()
					openServerDetail(server, row)
				end)
				if serversAnimate then
					animateServerCardEntrance(row, cardScale, index - firstIndex + 1)
				end
			end
			for _, ageEntry in pairs(serverAgeLabels) do
				ageEntry.label.Text = tr("Seen ") .. formatServerSeen(ageEntry.firstSeen)
			end

			serverPagRebuild(totalPages)
			serverStatus.Text = serverFetchError or (serverHasFetched and (tostring(#rows) .. tr(" servers loaded")) or tr("Loading servers..."))
			if #rows == 0 and serverHasFetched and not serverFetchError then
				serverStatus.Text = tr("No servers available")
			end
			if updateServersScroll then
				task.defer(updateServersScroll)
			end
		end

		local function fetchServers(force)
			if serverFetchActive then
				return
			end
			if not force and serverHasFetched and os.time() - serverLastFetch < 120 then
				return
			end
			serverFetchActive = true
			serverFetchError = nil
			serverStatus.Text = tr("Loading servers...")
			task.spawn(function()
				local fetched = {}
				local seenIds = {}
				local seenCursors = {}
				local cursor = nil
				local fetchError = nil
				for _ = 1, 4 do -- menos paginas por pase: la API deja de saturarse
					local url = string.format(
						"https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
						game.PlaceId
					)
					if cursor and cursor ~= "" then
						url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
					end
					local body = httpRequest("GET", url)
					if not body or body == "" then
						local ok, result = pcall(function()
							return game:HttpGet(url, true)
						end)
						if ok then
							body = result
						end
					end
					local response = body and decode(body)
					if type(response) ~= "table" or type(response.data) ~= "table" then
						fetchError = tr("API unavailable or temporary rate limit")
						break
					end
					for _, server in ipairs(response.data) do
						local id = tostring(server.id or "")
						if id ~= "" and not seenIds[id] then
							seenIds[id] = true
							serverFirstSeen[id] = serverFirstSeen[id] or os.time()
							server.OUI10FirstSeen = serverFirstSeen[id]
							fetched[#fetched + 1] = server
						end
					end
					local nextCursor = response.nextPageCursor
					if type(nextCursor) ~= "string" or nextCursor == "" or seenCursors[nextCursor] then
						break
					end
					seenCursors[nextCursor] = true
					cursor = nextCursor
					task.wait(0.25)
				end
				serverCache = fetched
				serverFetchError = fetchError
				serverLastFetch = os.time()
				serverHasFetched = true
				serverFetchActive = false
				if updateBanner then
					updateBanner()
				end
				if isOpen and currentSectionKey == "servers" then
					renderServerPage()
				else
					-- Same as Flow users: while the section is closed the list
					-- is only marked dirty; the entry renders it statically. --
					serversPageDirty = true
				end
			end)
		end

		serverPagPrev.Activated:Connect(function()
			serverPagGo(serverPageNumber - 1)
		end)
		serverPagNext.Activated:Connect(function()
			serverPagGo(serverPageNumber + 1)
		end)

		-- Q/E keys to switch pages, same as in Flow users --
		connect(UserInputService.InputBegan, function(input, gameProcessed)
			if gameProcessed or not isOpen or currentSectionKey ~= "servers" then
				return
			end
			if UserInputService:GetFocusedTextBox() then
				return
			end
			if input.KeyCode == Enum.KeyCode.Q then
				serverPagGo(serverPageNumber - 1)
			elseif input.KeyCode == Enum.KeyCode.E then
				serverPagGo(serverPageNumber + 1)
			end
		end)
		local serverSearchDebounce = nil
		serverSearch:GetPropertyChangedSignal("Text"):Connect(function()
			if serverSearchDebounce then
				task.cancel(serverSearchDebounce)
			end
			serverSearchDebounce = task.delay(0.25, function()
				serverSearchText = serverSearch.Text
				serverPageNumber = 1
				serversAnimate = false
				renderServerPage()
				serversAnimate = true
			end)
		end)
		task.defer(updateServerSortStyle, true)
		serversAnimate = false
		renderServerPage()
		serversAnimate = true
		-- Preload at startup so entering the section shows the list right
		-- away, exactly like Flow users. --
		task.defer(function()
			fetchServers(false)
		end)
		showServerPage = function(forceRefresh)
			-- Entry: render only when the data changed, without the per-card
			-- stagger (the section card fade does the reveal), like Flow users. --
			if not serverHasFetched or (forceRefresh and os.time() - serverLastFetch >= 120) then
				fetchServers(forceRefresh)
			elseif serversPageDirty then
				serversAnimate = false
				renderServerPage()
				serversAnimate = true
			end
			closeServerDetail()
		end
		task.spawn(function()
			while Gui.Parent do
				task.wait(120)
				if isOpen and currentSectionKey == "servers" then
					fetchServers(true)
				end
			end
		end)
		task.spawn(function()
			while Gui.Parent do
				task.wait(60)
				if isOpen and currentSectionKey == "servers" then
					for _, ageEntry in pairs(serverAgeLabels) do
						if ageEntry.label.Parent then
							ageEntry.label.Text = tr("Seen ") .. formatServerSeen(ageEntry.firstSeen)
						end
					end
					if detailServer and detailFirstSeen then
						detailAge.Text = tr("Seen ") .. formatServerSeen(detailFirstSeen)
					end
				end
			end
		end)
	end
	buildServersSection()

	-- Flow users variables that are also used outside this section
	-- (in showPage and in the presence loops at the end of the script)
	local usersToolbar, usersCount, usersTabs, pillIndicator
	local usersTabGame, usersTabAll, usersTabFriends, usersSearch
	local usersTab, usersAnimate, usersReload, usersPageDirty
	local usersRender, usersRefreshAll, fetchPresence, fetchFriends, friendsSig
	-- Flow badge: 0 none, 1 verified, 2 plus (badge column of flow_presence)
	local setBadgeForUser
	local function buildUsersSection()
		-- Users Section -----------------------------------------------------------

		-- Discord style status badges: green (playing), yellow moon (menu/web)
		-- and red with a white bar (do not disturb). 100% vector drawing. --
		local STATUS_ONLINE_COLOR = Color3.fromRGB(35, 197, 89)
		local STATUS_IDLE_COLOR = Color3.fromRGB(250, 201, 65)
		local STATUS_DND_COLOR = Color3.fromRGB(237, 66, 69)
		local STATUS_RING_COLOR = Color3.fromRGB(18, 18, 20)

		local function makeStatusBadge(photo)
			local badge = Instance.new("Frame")
			badge.Name = "StatusBadge"
			badge.Size = UDim2.fromOffset(22, 22)
			badge.AnchorPoint = Vector2.new(1, 1)
			badge.Position = UDim2.new(1, 4, 1, 3)
			badge.BackgroundColor3 = STATUS_RING_COLOR
			badge.BorderSizePixel = 0
			badge.ZIndex = 8
			badge.Parent = photo
			addCorner(badge, UDim.new(1, 0))

			local disc = Instance.new("Frame")
			disc.Name = "StatusDisc"
			disc.Size = UDim2.fromOffset(14, 14)
			disc.AnchorPoint = Vector2.new(0.5, 0.5)
			disc.Position = UDim2.fromScale(0.5, 0.5)
			disc.BackgroundColor3 = STATUS_ONLINE_COLOR
			disc.BorderSizePixel = 0
			disc.ZIndex = 9
			disc.Parent = badge
			addCorner(disc, UDim.new(1, 0))

			-- Vector moon: yellow circle + a cutout circle in the ring color --
			local moon = Instance.new("Frame")
			moon.Name = "StatusMoon"
			moon.Size = UDim2.fromOffset(14, 14)
			moon.AnchorPoint = Vector2.new(0.5, 0.5)
			moon.Position = UDim2.fromScale(0.5, 0.5)
			moon.BackgroundColor3 = STATUS_IDLE_COLOR
			moon.BorderSizePixel = 0
			moon.Visible = false
			moon.ZIndex = 9
			moon.Parent = badge
			addCorner(moon, UDim.new(1, 0))

			local moonCut = Instance.new("Frame")
			moonCut.Name = "StatusMoonCut"
			moonCut.Size = UDim2.fromOffset(13, 13)
			moonCut.AnchorPoint = Vector2.new(0.5, 0.5)
			moonCut.Position = UDim2.new(0, 12, 0, 7)
			moonCut.BackgroundColor3 = STATUS_RING_COLOR
			moonCut.BorderSizePixel = 0
			moonCut.ZIndex = 10
			moonCut.Parent = moon
			addCorner(moonCut, UDim.new(1, 0))

			-- Horizontal white bar of the do-not-disturb mode --
			local dndBar = Instance.new("Frame")
			dndBar.Name = "StatusDndBar"
			dndBar.Size = UDim2.fromOffset(10, 3)
			dndBar.AnchorPoint = Vector2.new(0.5, 0.5)
			dndBar.Position = UDim2.fromScale(0.5, 0.5)
			dndBar.BackgroundColor3 = WHITE
			dndBar.BorderSizePixel = 0
			dndBar.Visible = false
			dndBar.ZIndex = 10
			dndBar.Parent = badge
			addCorner(dndBar, UDim.new(1, 0))

			return badge
		end

		local function setStatusBadgeState(photo, state)
			local badge = photo and photo:FindFirstChild("StatusBadge")
			if not badge then
				return
			end
			local disc = badge:FindFirstChild("StatusDisc")
			local moon = badge:FindFirstChild("StatusMoon")
			local dndBar = badge:FindFirstChild("StatusDndBar")
			if disc then
				disc.Visible = state == "online" or state == "dnd"
				disc.BackgroundColor3 = (state == "dnd") and STATUS_DND_COLOR or STATUS_ONLINE_COLOR
			end
			if moon then
				moon.Visible = state == "idle"
			end
			if dndBar then
				dndBar.Visible = state == "dnd"
			end
		end

		usersToolbar = makeToolbar(usersPage, 30, 10)

		usersCount = Instance.new("TextLabel")
		usersCount.Size = UDim2.fromOffset(118, 30)
		usersCount.AnchorPoint = Vector2.new(1, 0.5)
		usersCount.Position = UDim2.new(1, -(12 + 176 + 10 + 260 + 10), 0.5, 0)
		usersCount.BackgroundTransparency = 1
		usersCount.BorderSizePixel = 0
		usersCount.Font = UI_FONT
		usersCount.TextSize = 13
		usersCount.TextColor3 = WHITE
		usersCount.TextXAlignment = Enum.TextXAlignment.Right
		usersCount.Text = tr("0 online")
		usersCount.Active = false
		usersCount.ZIndex = 5
		usersCount.Parent = usersToolbar

		usersTabs = Instance.new("Frame")
		usersTabs.Size = UDim2.fromOffset(176, 30)
		usersTabs.AnchorPoint = Vector2.new(1, 0.5)
		usersTabs.Position = UDim2.new(1, -12, 0.5, 0)
		usersTabs.BackgroundColor3 = AFEM_BLACK
		usersTabs.BackgroundTransparency = 0.75
		usersTabs.BorderSizePixel = 0
		usersTabs.ZIndex = 5
		usersTabs.Parent = usersToolbar
		addCorner(usersTabs, UDim.new(0, 16))

		pillIndicator = Instance.new("Frame")
		pillIndicator.Name = "PillIndicator"
		pillIndicator.Size = UDim2.new(0, 58, 0, 22)
		pillIndicator.AnchorPoint = Vector2.new(0, 0.5)
		pillIndicator.Position = UDim2.new(0, 4, 0.5, 0)
		pillIndicator.BackgroundColor3 = WHITE
		pillIndicator.BorderSizePixel = 0
		pillIndicator.ZIndex = 2
		pillIndicator.Parent = usersTabs
		addCorner(pillIndicator, UDim.new(0, 11))

		usersTabGame = Instance.new("TextButton")
		usersTabGame.Size = UDim2.new(0, 60, 1, 0)
		usersTabGame.AnchorPoint = Vector2.new(0, 0.5)
		usersTabGame.Position = UDim2.new(0, 0, 0.5, 0)
		usersTabGame.BackgroundTransparency = 1
		usersTabGame.BorderSizePixel = 0
		usersTabGame.AutoButtonColor = false
		usersTabGame.Font = UI_FONT
		usersTabGame.TextSize = 11
		usersTabGame.TextColor3 = AFEM_BLACK
		usersTabGame.Text = tr("In game")
		usersTabGame.TextXAlignment = Enum.TextXAlignment.Left
		usersTabGame.ZIndex = 3
		usersTabGame.Parent = usersTabs
		local usersTabGamePadding = Instance.new("UIPadding")
		usersTabGamePadding.PaddingLeft = UDim.new(0, 7)
		usersTabGamePadding.Parent = usersTabGame

		usersTabAll = Instance.new("TextButton")
		usersTabAll.Size = UDim2.new(0, 40, 1, 0)
		usersTabAll.AnchorPoint = Vector2.new(0, 0.5)
		usersTabAll.Position = UDim2.new(0, 60, 0.5, 0)
		usersTabAll.BackgroundTransparency = 1
		usersTabAll.BorderSizePixel = 0
		usersTabAll.AutoButtonColor = false
		usersTabAll.Font = UI_FONT
		usersTabAll.TextSize = 11
		usersTabAll.TextColor3 = WHITE
		usersTabAll.Text = tr("All")
		usersTabAll.ZIndex = 3
		usersTabAll.Parent = usersTabs

		usersTabFriends = Instance.new("TextButton")
		usersTabFriends.Size = UDim2.new(0, 66, 1, 0)
		usersTabFriends.AnchorPoint = Vector2.new(0, 0.5)
		usersTabFriends.Position = UDim2.new(0, 102, 0.5, 0)
		usersTabFriends.BackgroundTransparency = 1
		usersTabFriends.BorderSizePixel = 0
		usersTabFriends.AutoButtonColor = false
		usersTabFriends.Font = UI_FONT
		usersTabFriends.TextSize = 11
		usersTabFriends.TextColor3 = WHITE
		usersTabFriends.Text = tr("Friends")
		usersTabFriends.ZIndex = 3
		usersTabFriends.Parent = usersTabs

		usersSearch = makeSearchBox(usersToolbar, {
			width = 260,
			height = 30,
			font = UI_FONT,
			textSize = 13,
			placeholder = tr("Search flow user…"),
			placeholderColor = Color3.fromRGB(160, 160, 160),
			cornerRadius = 16,
			strokeColor = Color3.fromRGB(80, 80, 80),
			strokeFade = 0.7,
		})
		usersSearch.AnchorPoint = Vector2.new(1, 0.5)
		usersSearch.Position = UDim2.new(1, -(12 + 176 + 10), 0.5, 0)
		usersSearch.ZIndex = 5

		local usersSearchPad = Instance.new("UIPadding")
		usersSearchPad.PaddingLeft = UDim.new(0, 12)
		usersSearchPad.PaddingRight = UDim.new(0, 12)
		usersSearchPad.Parent = usersSearch

		local usersList, updateUsersScroll = makeList(usersPage, 60, 48)
		usersTab = "all"
		local usersCache = {}
		_G.FlowUsersCache = usersCache
		usersAnimate = true
		local usersSeen = {} -- uids ya renderizados (para detectar llegadas) --
		usersReload = false -- next render arrives through the presence change --
		local usersRenderToken = 0
		local usersQuery = ""
		usersPageDirty = true

		for _, child in ipairs(usersList:GetChildren()) do
			if child:IsA("UIListLayout") then
				child:Destroy()
			end
		end

		local usersListPad = Instance.new("UIPadding")
		usersListPad.PaddingLeft = UDim.new(0, 18)
		usersListPad.PaddingRight = UDim.new(0, 18)
		usersListPad.PaddingTop = UDim.new(0, 14)
		usersListPad.PaddingBottom = UDim.new(0, 14)
		usersListPad.Parent = usersList

		local usersGrid = Instance.new("UIGridLayout")
		usersGrid.CellSize = UDim2.new(1 / 3, -10, 0, 116)
		usersGrid.CellPadding = UDim2.new(0, 15, 0, 14)
		usersGrid.SortOrder = Enum.SortOrder.LayoutOrder
		usersGrid.Parent = usersList
		local function fitUsersGrid()
			local viewHeight = usersList.AbsoluteSize.Y
			if viewHeight <= 0 then
				return
			end
			local cardHeight = math.clamp(math.floor((viewHeight - 56) / 3), 58, 116)
			usersGrid.CellSize = UDim2.new(1 / 3, -10, 0, cardHeight)
		end
		usersList:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitUsersGrid)
		task.defer(fitUsersGrid)

		local usersEmpty = Instance.new("TextLabel")
		usersEmpty.Size = UDim2.new(1, 0, 0, 20)
		usersEmpty.AnchorPoint = Vector2.new(0.5, 0.5)
		usersEmpty.Position = UDim2.fromScale(0.5, 0.5)
		usersEmpty.BackgroundTransparency = 1
		usersEmpty.BorderSizePixel = 0
		usersEmpty.Font = UI_FONT
		usersEmpty.TextSize = 12
		usersEmpty.TextColor3 = TEXT_DIM
		usersEmpty.Text = tr("Nobody online right now")
		usersEmpty.Visible = false
		usersEmpty.Active = false
		usersEmpty.Parent = usersPage


		local USERS_PER_PAGE = 9
		local usersPageNum = 1
		local usersTotalPages = 1

		local pagBar = Instance.new("Frame")
		pagBar.Size = UDim2.new(1, 0, 0, 46)
		pagBar.Position = UDim2.new(0, 0, 1, -50)
		pagBar.BackgroundTransparency = 1
		pagBar.BorderSizePixel = 0
		pagBar.Active = false
		pagBar.Parent = usersPage

		local pagLayout = Instance.new("UIListLayout")
		pagLayout.FillDirection = Enum.FillDirection.Horizontal
		pagLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		pagLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		pagLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pagLayout.Padding = UDim.new(0, 6)
		pagLayout.Parent = pagBar

		local function makePagButton(text, order, width)
			local button = Instance.new("TextButton")
			button.Size = UDim2.fromOffset(width, 28)
			button.BackgroundColor3 = AFEM_BLACK
			button.BackgroundTransparency = 0.75
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.Font = UI_FONT
			button.TextSize = 14
			button.TextColor3 = WHITE
			button.Text = text
			button.LayoutOrder = order
			button.Parent = pagBar
			addCorner(button, UDim.new(0, 12))
			addStroke(button, AFEM_STROKE, 0.5)
			addHoverScale(button, 1.05)
			return button
		end

		local pagPrev = makePagButton("‹", 1, 42)
		local pagNext = makePagButton("›", 9999, 42)

		local function addPageKeyHint(button, key)
			local hint = Instance.new("TextLabel")
			hint.Size = UDim2.fromOffset(22, 14)
			hint.AnchorPoint = Vector2.new(0.5, 1)
			hint.Position = UDim2.new(0.5, 0, 0, -2)
			hint.BackgroundTransparency = 1
			hint.BorderSizePixel = 0
			hint.Font = UI_FONT
			hint.TextSize = 10
			hint.TextColor3 = WHITE
			hint.TextTransparency = 0.2
			hint.Text = key
			hint.Parent = button
		end

		addPageKeyHint(pagPrev, "Q")
		addPageKeyHint(pagNext, "E")

		local function pagRebuild(totalPages)
			usersTotalPages = totalPages
			pagPrev.TextTransparency = usersPageNum <= 1 and 0.6 or 0
			pagNext.TextTransparency = usersPageNum >= totalPages and 0.6 or 0
			for _, child in ipairs(pagBar:GetChildren()) do
				if child.Name == "PagCircle" then
					child:Destroy()
				end
			end
			for pageNum = 1, totalPages do
				local active = (pageNum == usersPageNum)
				local circle = Instance.new("TextButton")
				circle.Name = "PagCircle"
				circle.Size = UDim2.fromOffset(30, 30)
				circle.BackgroundColor3 = WHITE
				circle.BackgroundTransparency = active and 0 or 1
				circle.BorderSizePixel = 0
				circle.AutoButtonColor = false
				circle.Font = UI_FONT
				circle.TextSize = 12
				circle.TextColor3 = active and AFEM_BLACK or WHITE
				circle.TextTransparency = active and 0 or 0.55
				circle.Text = tostring(pageNum)
				circle.LayoutOrder = 10 + pageNum
				circle.Parent = pagBar
				addCorner(circle, UDim.new(1, 0))
				addHoverScale(circle, 1.1)
				circle.Activated:Connect(function()
					if pageNum ~= usersPageNum then
						playClick()
						usersPageNum = pageNum
						usersRender()
					end
				end)
			end
		end

		local function pagGo(pageNum)
			pageNum = math.clamp(pageNum, 1, usersTotalPages)
			if pageNum == usersPageNum then
				return
			end
			playClick()
			usersPageNum = pageNum
			usersRender()
		end

		pagPrev.Activated:Connect(function()
			pagGo(usersPageNum - 1)
		end)

		pagNext.Activated:Connect(function()
			pagGo(usersPageNum + 1)
		end)

		connect(UserInputService.InputBegan, function(input, gameProcessed)
			if gameProcessed or not isOpen or currentSectionKey ~= "users" then
				return
			end
			if UserInputService:GetFocusedTextBox() then
				return
			end
			if input.KeyCode == Enum.KeyCode.Q then
				pagGo(usersPageNum - 1)
			elseif input.KeyCode == Enum.KeyCode.E then
				pagGo(usersPageNum + 1)
			end
		end)

		local function styleUserTabs()
			local tabs = {
				game = usersTabGame,
				all = usersTabAll,
				friends = usersTabFriends,
			}
		
			local targetButton = tabs[usersTab]
			local targetX = targetButton.Position.X.Offset + 4
			local targetWidth = math.max(28, targetButton.Size.X.Offset - 8)

			TweenService:Create(pillIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, targetX, 0.5, 0),
				Size = UDim2.new(0, targetWidth, 0, 22)
			}):Play()

			for key, button in pairs(tabs) do
				local active = (usersTab == key)
				TweenService:Create(button, TweenInfo.new(0.2), {
					TextColor3 = active and AFEM_BLACK or WHITE
				}):Play()
			end
		end

		local function thumb(id, w, h)
			return string.format("rbxthumb://type=Asset&id=%s&w=%d&h=%d", tostring(id), w, h)
		end

		local lastPresenceSig = nil
		local function presenceEntrySignature(entry)
			return table.concat({
				tostring(entry.Name or ""),
				tostring(entry.GameName or ""),
				tostring(entry.GameId or entry.gameId or ""),
				tostring(entry.PlaceId or entry.placeId or ""),
				tostring(entry.JobId or entry.jobId or ""),
				tostring(entry.Since or ""),
				tostring(entry.BannerId or ""),
				tostring(entry.AvatarId or ""),
				tostring(entry.HideBanner or ""),
				tostring(entry.HideGame or ""),
				tostring(entry.HideAvatar or ""),
				tostring(entry.HideName or ""),
				tostring(entry.HidePlayers or ""),
				tostring(entry.HidePing or ""),
				tostring(entry.BlockJoin or ""),
				tostring(entry.DND or ""),
				tostring(entry.Badge or 0),
			}, "\31")
		end
		local function presenceSnapshotSignature(entry)
			return table.concat({
				presenceEntrySignature(entry),
				tostring(entry.Players or ""),
				tostring(entry.MaxPlayers or ""),
				tostring(entry.Ping or ""),
			}, "\31")
		end
		local function friendEntrySignature(entry)
			return table.concat({
				tostring(entry.UserName or ""),
				tostring(entry.DisplayName or ""),
				tostring(entry.Location or entry.LastLocation or ""),
				tostring(entry.GameId or entry.gameId or ""),
				tostring(entry.PlaceId or entry.placeId or ""),
			}, "\31")
		end

		fetchPresence = function()
    local result = supaRequest("GET", "/flow_presence?is_active=eq.true&select=*")
    if type(result) ~= "table" then
        return false
    end

    local newCache = {}
    local now = os.time()

    for _, row in ipairs(result) do
        local updated = tonumber(row.updated_at_ts) or 0
        if now - updated <= 120 then
            local uid = tonumber(row.user_id) or 0
            if uid ~= 0 then
                newCache[uid] = {
                    UserId      = uid,
                    Name        = row.name or "",
                    GameName    = row.game_name or "",
                    GameId      = row.game_id or 0,
                    PlaceId     = row.place_id or 0,
                    JobId       = row.job_id or "",
                    Players     = row.players or 0,
                    MaxPlayers  = row.max_players or 0,
                    Ping        = row.ping or 0,
                    Since       = row.since or 0,
                    UpdatedAt   = row.updated_at_ts or 0,
                    DND         = row.dnd or false,
                    HideGame    = row.hide_game or false,
                    HideBanner  = row.hide_banner or false,
                    BannerId    = row.banner_id or "134918452547700",
                    HideAvatar  = row.hide_avatar or false,
                    AvatarId    = row.avatar_id or "109728664560706",
                    HideName    = row.hide_name or false,
                    CustomName  = row.custom_name or "Hidden",
                    HidePlayers = row.hide_players or false,
                    HidePing    = row.hide_ping or false,
                    BlockJoin   = row.block_join or false,
                    Badge       = tonumber(row.badge) or 0,
                }
            end
        end
    end

    local parts = {}
    for userId, entry in pairs(newCache) do
        parts[#parts + 1] = tostring(userId) .. "\30" .. presenceSnapshotSignature(entry)
    end
    table.sort(parts)
    local sig = table.concat(parts, "|")

    usersCache = newCache
    _G.FlowUsersCache = usersCache
    local n = 0
    for _ in pairs(usersCache) do n = n + 1 end
    usersCount.Text = tostring(n) .. tr(" online")

    local changed = (sig ~= lastPresenceSig)
    lastPresenceSig = sig
    return changed
end

		local friendsCache = {}
		_G.FlowFriendsCache = friendsCache
		friendsSig = nil

		local function friendUserId(entry)
			return tonumber(entry.UserId or entry.UserID or entry.VisitorId or entry.Id or entry.id)
		end

		local function friendName(entry)
			return tostring(entry.UserName or entry.Username or entry.Name or entry.name or "")
		end

		local function friendDisplay(entry)
			local display = tostring(entry.DisplayName or entry.displayName or "")
			if display == "" then
				display = friendName(entry)
			end
			return display
		end

		local function friendLocation(entry)
			return tostring(entry.LastLocation or entry.Location or entry.lastLocation or "")
		end

		local function putFriend(bucket, entry)
			if type(entry) ~= "table" then
				return
			end
			local uid = friendUserId(entry)
			if not uid or uid == 0 or uid == player.UserId then
				return
			end
			bucket[uid] = {
				UserId = uid,
				UserName = friendName(entry),
				DisplayName = friendDisplay(entry),
				Location = friendLocation(entry),
				PlaceId = entry.PlaceId or entry.placeId,
				GameId = entry.GameId or entry.gameId,
			}
		end

		fetchFriends = function()
			local bucket = {}

			local function ingestFriends(result)
				if type(result) ~= "table" then
					return
				end
				for _, entry in pairs(result) do
					putFriend(bucket, entry)
				end
			end

			local online = nil
			pcall(function()
				online = player:GetFriendsOnline(200)
			end)
			if type(online) ~= "table" then
				pcall(function()
					online = player:GetFriendsOnline()
				end)
			end
			ingestFriends(online)

			if next(bucket) == nil then
				pcall(function()
					local pages = Players:GetFriendsAsync(player.UserId)
					while true do
						for _, item in ipairs(pages:GetCurrentPage()) do
							local online = item.IsOnline
							if online == nil and item.PresenceType then
								online = item.PresenceType ~= Enum.FriendPresenceType.Offline
							end
							if online then
								putFriend(bucket, item)
							end
						end
						if pages.IsFinished then
							break
						end
						pages:AdvanceToNextPageAsync()
					end
				end)
			end

			if next(bucket) == nil then
				local body = httpRequest("GET", string.format("https://friends.roblox.com/v1/users/%d/friends/online", player.UserId))
				local data = body and decode(body)
				if type(data) == "table" and type(data.data) == "table" then
					for _, entry in ipairs(data.data) do
						putFriend(bucket, entry)
					end
				end
			end

			for _, other in ipairs(Players:GetPlayers()) do
				if other ~= player then
					local isFriend = false
					pcall(function()
						isFriend = player:IsFriendsWith(other.UserId)
					end)
					if isFriend then
						putFriend(bucket, {
							UserId = other.UserId,
							UserName = other.Name,
							DisplayName = other.DisplayName,
							Location = tr("This game"),
						})
					end
				end
			end

			local newCache = {}
			local parts = {}
			for uid, entry in pairs(bucket) do
				newCache[#newCache + 1] = entry
				parts[#parts + 1] = table.concat({
					tostring(uid),
					tostring(entry.UserName or ""),
					tostring(entry.DisplayName or ""),
					tostring(entry.Location or ""),
					tostring(entry.GameId or ""),
					tostring(entry.PlaceId or ""),
				}, "\31")
			end
			table.sort(parts)
			friendsCache = newCache
			_G.FlowFriendsCache = friendsCache
			friendsSig = table.concat(parts, "|")
		end

		local CARD_FADE_PROPS = {"TextTransparency", "ImageTransparency", "BackgroundTransparency", "Transparency"}
		local TEXT_BRIGHT = Color3.fromRGB(201, 204, 216)
		local cardFadeCache = setmetatable({}, {__mode = "k"})

		local function snapshotCard(card)
			local cached = cardFadeCache[card]
			if cached then
				return cached
			end
			local bases = {}
			local function rec(obj)
				local t = {}
				for _, prop in ipairs(CARD_FADE_PROPS) do
					local ok, value = pcall(function()
						return obj[prop]
					end)
					if ok and type(value) == "number" then
						t[prop] = value
					end
				end
				if next(t) then
					bases[obj] = t
				end
				for _, child in ipairs(obj:GetChildren()) do
					rec(child)
				end
			end
			rec(card)
			cardFadeCache[card] = bases
			return bases
		end

		local function fadeCardOut(card, duration)
			local bases = snapshotCard(card)
			for obj, props in pairs(bases) do
				for prop in pairs(props) do
					tween(obj, {[prop] = 1}, duration or 0.3)
				end
			end
			local scale = card:FindFirstChildOfClass("UIScale")
			if scale then
				tween(scale, {Scale = 0.94}, duration or 0.3)
			end
		end

		local function addLoadingSpinner(card)
			local spinner = Instance.new("ImageLabel")
			spinner.Name = "LoadSpinner"
			spinner.Image = "rbxassetid://17119858971"
			spinner.BackgroundTransparency = 1
			spinner.AnchorPoint = Vector2.new(0.5, 0.5)
			spinner.Position = UDim2.new(0.5, 0, 0.5, 0)
			spinner.Size = UDim2.fromOffset(42, 42)
			spinner.ImageColor3 = WHITE
			spinner.ZIndex = 40
			spinner.Parent = card
			task.spawn(function()
				while spinner.Parent do
					tween(spinner, {Rotation = spinner.Rotation + 360}, 0.85, Enum.EasingStyle.Linear)
					task.wait(0.85)
				end
			end)
			return spinner
		end

		-- Live card reveal: loading spinner first, fade in afterwards --
		local function revealCardWithLoader(card)
			local epoch = cardEntranceEpoch
			local bases = snapshotCard(card)
			local sectionCard = sectionCards["users"] and sectionCards["users"].card
			if sectionCard then
				for obj in pairs(bases) do
					if obj ~= card then
						cacheSectionFadeObject(sectionCard, obj)
					end
				end
			end
			card:SetAttribute("OUI10CardBusy", os.clock() + 1.1)
			for obj, props in pairs(bases) do
				if obj ~= card then
					for prop in pairs(props) do
						pcall(function()
							obj[prop] = 1
						end)
					end
				end
			end
			local spinner = addLoadingSpinner(card)
			task.delay(0.55, function()
				if not card.Parent then
					return
				end
				task.delay(0.34, function()
					if spinner.Parent then
						spinner:Destroy()
					end
				end)
				if epoch ~= cardEntranceEpoch then
					return
				end
				for obj, props in pairs(bases) do
					if obj ~= card then
						for prop, base in pairs(props) do
							tween(obj, {[prop] = base}, 0.32, Enum.EasingStyle.Quint)
						end
					end
				end
			end)
		end

		local function animateCardEntrance(card, scale, order)
			local epoch = cardEntranceEpoch
			local col = (order - 1) % 3
			local row = math.floor((order - 1) / 3)
			local steps = row + col
			local delay = steps * 0.07

			local bases = {}
			local function rec(obj)
				local t = {}
				for _, prop in ipairs(CARD_FADE_PROPS) do
					local ok, value = pcall(function()
						return obj[prop]
					end)
					if ok and type(value) == "number" then
						t[prop] = value
					end
				end
				bases[obj] = t
				for _, child in ipairs(obj:GetChildren()) do
					rec(child)
				end
			end
			rec(card)

			local sectionCard = sectionCards["users"] and sectionCards["users"].card
			if sectionCard then
				for obj in pairs(bases) do
					cacheSectionFadeObject(sectionCard, obj)
				end
			end
			card:SetAttribute("OUI10CardBusy", os.clock() + delay + 0.45)

			for obj, t in pairs(bases) do
				for prop in pairs(t) do
					pcall(function()
						obj[prop] = 1
					end)
				end
			end
			if scale then
				scale.Scale = 0.92
			end

			task.delay(delay, function()
				if not card.Parent then
					return
				end
				if scale then
					tween(scale, {Scale = 1}, 0.32, Enum.EasingStyle.Quint)
				end
				if epoch ~= cardEntranceEpoch then
					return
				end
				for obj, t in pairs(bases) do
					for prop, base in pairs(t) do
						tween(obj, {[prop] = base}, 0.3, Enum.EasingStyle.Quint)
					end
				end
			end)
		end

		local function updateUserCardDetails(card, data)
			local statsLabel = card:FindFirstChild("UserStats")
			if statsLabel and statsLabel:IsA("TextLabel") then
				local playerCount = "--/--"
				if not data.HidePlayers and data.Players and data.MaxPlayers then
					playerCount = tostring(data.Players) .. "/" .. tostring(data.MaxPlayers)
				end
				local pingLabel = "-- ms"
				if not data.HidePing and data.Ping then
					pingLabel = tostring(data.Ping) .. " ms"
				end
				statsLabel.Text = tr("Players: ") .. playerCount .. tr(" | Ping: ") .. pingLabel
			end

			local serverLabel = card:FindFirstChild("UserServer")
			if serverLabel and serverLabel:IsA("TextLabel") then
				local jobId = tostring(data.JobId or data.jobId or "")
				local serverId = (jobId ~= "" and not data.HideGame) and ("Job " .. jobId .. " · ") or ""
				local activeSecs
				if data.Since then
					activeSecs = os.time() - (tonumber(data.Since) or 0)
				elseif data.UpdatedAt then
					activeSecs = os.time() - (tonumber(data.UpdatedAt) or 0)
				end
				local timeText = "--"
				if activeSecs and activeSecs >= 0 then
					if activeSecs < 60 then
						timeText = string.format("%ds", activeSecs)
					elseif activeSecs < 3600 then
						timeText = string.format("%dm", math.floor(activeSecs / 60))
					else
						timeText = string.format("%dh", math.floor(activeSecs / 3600))
					end
				end
				serverLabel.Text = serverId .. timeText
			end
			-- refresh the badge icon if it changed while the card is alive
			local badgeLabel = card:FindFirstChild("UserBadge")
			if badgeLabel and badgeLabel:IsA("TextLabel") then
				local b = tonumber(data.Badge) or 0
				badgeLabel.Text = (b == 1 and string.char(0xEE, 0x80, 0x80)) or (b == 2 and string.char(0xEE, 0x80, 0x83)) or ""
				badgeLabel.Visible = b == 1 or b == 2
			end
		end

		local function makeUserCard(data, sameExperience, order, withLoader)
			local currentPlaceId = tonumber(game.PlaceId) or 0
			local currentJobId = tostring(game.JobId or "")
			local dataPlaceId = tonumber(data.PlaceId or data.placeId or data.RootPlaceId or data.rootPlaceId) or currentPlaceId
			local dataJobId = tostring(data.JobId or data.jobId or "")
			local canJoin = sameExperience and not data.BlockJoin and dataJobId ~= "" and dataJobId ~= currentJobId

			local card = Instance.new("TextButton")
			card.Name = "FlowUser"
			card.Size = UDim2.new(1, 0, 0, 116)
			card.BackgroundColor3 = AFEM_CARD
			card.BackgroundTransparency = 0.45
			card.BorderSizePixel = 0
			card.AutoButtonColor = false
			card.Text = ""
			card.ClipsDescendants = false
			card.LayoutOrder = order
			card.AnchorPoint = Vector2.new(0.5, 0.5)
			card:SetAttribute("OUI10Uid", tonumber(data.UserId) or 0)
			card:SetAttribute("OUI10VisualSignature", presenceEntrySignature(data))
			card.Parent = usersList
			addCorner(card, UDim.new(0, 16))
			addUserCardStroke(card)
			local cardScale = addHoverScale(card)
			addShadow(card, 6, 0.3, UDim2.new(0, 0, 0, 1))

			local banner = Instance.new("ImageLabel")
			banner.Size = UDim2.fromScale(1, 1)
			banner.BackgroundTransparency = 1
			banner.BorderSizePixel = 0
			banner.ScaleType = Enum.ScaleType.Crop
			banner.ImageColor3 = Color3.fromRGB(143, 143, 147)
			banner.Parent = card
			addCorner(banner, UDim.new(0, 16))

			local bannerLight = Instance.new("UIGradient")
			bannerLight.Rotation = 90
			bannerLight.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
			})
			bannerLight.Parent = banner

			local gameId = tonumber(data.GameId) or 0
			if data.HideBanner or data.HideGame or gameId == 0 then
				local bannerId = data.BannerId or "134918452547700"
				local digits = tostring(bannerId):match("%d+")
				banner.Image = thumb(digits or "134918452547700", 420, 420)
			else
				banner.Image = string.format("rbxthumb://type=GameIcon&id=%d&w=150&h=150", gameId)
			end

			local shade = Instance.new("Frame")
			shade.Size = UDim2.fromScale(1, 1)
			shade.BackgroundColor3 = Color3.new(0, 0, 0)
			shade.BackgroundTransparency = 0
			shade.BorderSizePixel = 0
			shade.Parent = card
			addCorner(shade, UDim.new(0, 16))
			local shadeFade = Instance.new("UIGradient")
			shadeFade.Name = "FrostFade"
			shadeFade.Rotation = 90
			shadeFade.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(0.55, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
			})
			shadeFade.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.62),
				NumberSequenceKeypoint.new(0.58, 0.78),
				NumberSequenceKeypoint.new(1, 0.86),
			})
			shadeFade.Parent = shade

			local photo = Instance.new("ImageLabel")
			photo.Size = UDim2.fromOffset(56, 56)
			photo.AnchorPoint = Vector2.new(0, 0.5)
			photo.Position = UDim2.new(0, 22, 0.5, 0)
			photo.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
			photo.BorderSizePixel = 0
			photo.ScaleType = Enum.ScaleType.Crop
			photo.Parent = card
			addCorner(photo, UDim.new(1, 0))
			local photoStroke = addStroke(photo, AFEM_STROKE, 0.3)
			photoStroke.Thickness = 1.5

			local avatarDigits = data.AvatarId and tostring(data.AvatarId):match("%d+")
			if data.UserId and not data.HideAvatar then
				photo.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", tonumber(data.UserId) or 0)
			else
				photo.Image = thumb(avatarDigits or "109728664560706", 150, 150)
			end

			local statusBadge = makeStatusBadge(photo)
			local userPlaying = (not data.HideGame)
				and ((tonumber(data.GameId or 0) or 0) ~= 0 or (tonumber(data.PlaceId or 0) or 0) ~= 0)
			setStatusBadgeState(photo, data.DND and "dnd" or (userPlaying and "online" or "idle"))

			local shownName = data.HideName and (tostring(data.Name or "") ~= "" and data.Name or "Hidden") or data.Name
			local nameLabel = addLabel(card, tostring(shownName or "?"), 88, 22, 1, 18, 13, WHITE, UI_FONT)
			nameLabel.Size = UDim2.new(1, -100, 0, 18)
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			-- Badge icon to the right of the name: 0 none, 1 verified, 2 plus
			local badgeIcons = { [1] = string.char(0xEE, 0x80, 0x80), [2] = string.char(0xEE, 0x80, 0x83) }
			local badgeValue = tonumber(data.Badge) or 0
			local badgeLabel = Instance.new("TextLabel")
			badgeLabel.Name = "UserBadge"
			badgeLabel.BackgroundTransparency = 1
			badgeLabel.Size = UDim2.fromOffset(18, 18)
			badgeLabel.Position = UDim2.new(0, 92, 0, 21)
			badgeLabel.Font = Enum.Font.SourceSansBold
			badgeLabel.TextSize = 16
			badgeLabel.TextColor3 = WHITE
			badgeLabel.Text = (badgeValue == 1 and badgeIcons[1]) or (badgeValue == 2 and badgeIcons[2]) or ""
			badgeLabel.Visible = badgeValue == 1 or badgeValue == 2
			badgeLabel.Parent = card
			pcall(function()
				local nameWidth = game:GetService("TextService"):GetTextSize(tostring(shownName or "?"), 13, UI_FONT, Vector2.new(2000, 100)).X
				badgeLabel.Position = UDim2.new(0, 88 + nameWidth + 4, 0, 21)
			end)

			local shownGame
			if data.HideGame then
				shownGame = tr("Hidden")
			else
				shownGame = tostring(data.GameName or data.GameId or "")
				if shownGame == "" or shownGame:lower() == "ugc" then
					shownGame = (placeName ~= "" and placeName) or "Roblox"
				end
			end
			local gameLabel = addLabel(card, shownGame, 88, 41, 1, 15, 12, TEXT_BRIGHT)
			gameLabel.Size = UDim2.new(1, -100, 0, 15)

			local statsLabel = addLabel(card, "", 88, 59, 1, 14, 11, TEXT_BRIGHT)
			statsLabel.Name = "UserStats"
			statsLabel.Size = UDim2.new(1, -100, 0, 14)

			local srvLabel = addLabel(card, "", 88, 76, 1, 14, 11, TEXT_BRIGHT)
			srvLabel.Name = "UserServer"
			srvLabel.Size = UDim2.new(1, -100, 0, 14)

			local joinButton = nil
			if canJoin then
				joinButton = Instance.new("ImageButton")
				joinButton.AnchorPoint = Vector2.new(1, 0.5)
				joinButton.Position = UDim2.new(1, -14, 0.5, 0)
				joinButton.Size = UDim2.fromOffset(44, 44)
				joinButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				joinButton.BackgroundTransparency = 0.08
				joinButton.BorderSizePixel = 0
				joinButton.AutoButtonColor = false
				joinButton.Image = ""
				joinButton.Parent = card
				addCorner(joinButton, UDim.new(1, 0))
				addAFEMStroke(joinButton, 1.1, 0.2)
				local playIcon = Instance.new("ImageLabel")
				playIcon.Size = UDim2.fromOffset(24, 24)
				playIcon.AnchorPoint = Vector2.new(0.5, 0.5)
				playIcon.Position = UDim2.fromScale(0.5, 0.5)
				playIcon.BackgroundTransparency = 1
				playIcon.Image = "rbxassetid://106640709678034"
				playIcon.ImageColor3 = WHITE
				playIcon.ScaleType = Enum.ScaleType.Fit
				playIcon.Active = false
				playIcon.Parent = joinButton
				joinButton.MouseEnter:Connect(function()
					tween(joinButton, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.15)
				end)
				joinButton.MouseLeave:Connect(function()
					tween(joinButton, {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}, 0.15)
				end)
				joinButton.Activated:Connect(function()
					playClick()
					pcall(function()
						TeleportService:TeleportToPlaceInstance(dataPlaceId, dataJobId, player)
					end)
					notify("Connecting...")
				end)
			end

			card.Activated:Connect(function()
				if not canJoin then
					return
				end
				playClick()
				pcall(function()
					TeleportService:TeleportToPlaceInstance(dataPlaceId, dataJobId, player)
				end)
				notify("Connecting...")
			end)

			snapshotCard(card)
			updateUserCardDetails(card, data)
			if withLoader then
				revealCardWithLoader(card)
			elseif usersAnimate then
				animateCardEntrance(card, cardScale, order)
			end
		end

		local function makeFriendCard(friend, order, withLoader)
			local uid = tonumber(friend.UserId or friend.UserID) or 0
			-- Safe name: if DisplayName is missing "nil" is never shown --
			local rawDisplay = tostring(friend.DisplayName or "")
			local rawName = tostring(friend.UserName or friend.Name or "")
			local display = rawDisplay ~= "" and rawDisplay or (rawName ~= "" and rawName or "?")
			local userName = rawName
			-- The default card also covers whoever is on the Roblox website --
			local rawLocation = tostring(friend.Location or friend.LastLocation or "")
			local friendInMenu = rawLocation == "" or rawLocation == "Roblox" or rawLocation == "Website"
			local location = friendInMenu and tr("In the Roblox menu") or rawLocation
			local currentPlaceId = tonumber(game.PlaceId) or 0
			local currentJobId = tostring(game.JobId or "")
			local dataGameId = tonumber(friend.GameId or friend.gameId or 0) or 0
			local currentGameId = tonumber(game.GameId) or 0
			local sameExperience = dataGameId ~= 0 and dataGameId == currentGameId
			local dataPlaceId = tonumber(friend.PlaceId or friend.placeId) or currentPlaceId
			local dataJobId = tostring(friend.JobId or friend.jobId or "")
			-- Joining is only possible in the same game AND a different server --
			local canJoin = sameExperience and dataJobId ~= "" and dataJobId ~= currentJobId

			local card = Instance.new("TextButton")
			card.Name = "FriendUser"
			card.Size = UDim2.new(1, 0, 0, 116)
			card.BackgroundColor3 = AFEM_CARD
			card.BackgroundTransparency = 0.45
			card.BorderSizePixel = 0
			card.AutoButtonColor = false
			card.Text = ""
			card.ClipsDescendants = false
			card.LayoutOrder = order
			card.AnchorPoint = Vector2.new(0.5, 0.5)
			card:SetAttribute("OUI10Uid", uid)
			card:SetAttribute("OUI10VisualSignature", friendEntrySignature(friend))
			card.Parent = usersList
			addCorner(card, UDim.new(0, 16))
			addUserCardStroke(card)
			local cardScale = addHoverScale(card)
			addShadow(card, 6, 0.3, UDim2.new(0, 0, 0, 1))

			local banner = Instance.new("ImageLabel")
			banner.Size = UDim2.fromScale(1, 1)
			banner.BackgroundTransparency = 1
			banner.BorderSizePixel = 0
			banner.ScaleType = Enum.ScaleType.Crop
			banner.ImageColor3 = Color3.fromRGB(143, 143, 147)
			banner.Image = thumb("134918452547700", 420, 420)
			banner.Parent = card
			addCorner(banner, UDim.new(0, 16))

			local bannerLight = Instance.new("UIGradient")
			bannerLight.Rotation = 90
			bannerLight.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
			})
			bannerLight.Parent = banner

			local shade = Instance.new("Frame")
			shade.Size = UDim2.fromScale(1, 1)
			shade.BackgroundColor3 = Color3.new(0, 0, 0)
			shade.BackgroundTransparency = 0
			shade.BorderSizePixel = 0
			shade.Parent = card
			addCorner(shade, UDim.new(0, 16))
			local shadeFade = Instance.new("UIGradient")
			shadeFade.Name = "FrostFade"
			shadeFade.Rotation = 90
			shadeFade.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(0.55, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
			})
			shadeFade.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.62),
				NumberSequenceKeypoint.new(0.58, 0.78),
				NumberSequenceKeypoint.new(1, 0.86),
			})
			shadeFade.Parent = shade

			local photo = Instance.new("ImageLabel")
			photo.Size = UDim2.fromOffset(56, 56)
			photo.AnchorPoint = Vector2.new(0, 0.5)
			photo.Position = UDim2.new(0, 22, 0.5, 0)
			photo.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
			photo.BorderSizePixel = 0
			photo.ScaleType = Enum.ScaleType.Crop
			photo.Parent = card
			addCorner(photo, UDim.new(1, 0))
			local photoStroke = addStroke(photo, AFEM_STROKE, 0.3)
			photoStroke.Thickness = 1.5
			photo.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", uid)
			makeStatusBadge(photo)
			local presenceForFriend = usersCache[uid]
			local friendState = "idle"
			if presenceForFriend and presenceForFriend.DND then
				friendState = "dnd"
			elseif not friendInMenu then
				friendState = "online"
			end
			setStatusBadgeState(photo, friendState)

			local nameLabel = addLabel(card, display, 88, 34, 1, 18, 13, WHITE, UI_FONT)
			nameLabel.Size = UDim2.new(1, -100, 0, 18)
			if userName ~= "" and userName ~= display then
				local handleLabel = addLabel(card, "@" .. userName, 88, 53, 1, 14, 12, TEXT_BRIGHT)
				handleLabel.Size = UDim2.new(1, -100, 0, 14)
				local locLabel = addLabel(card, location, 88, 70, 1, 14, 11, TEXT_BRIGHT)
				locLabel.Size = UDim2.new(1, -100, 0, 14)
			else
				local locLabel = addLabel(card, location, 88, 55, 1, 14, 11, TEXT_BRIGHT)
				locLabel.Size = UDim2.new(1, -100, 0, 14)
			end

			local joinButton = nil
			if canJoin then
				-- Same style as the Flow users join button --
				joinButton = Instance.new("ImageButton")
				joinButton.AnchorPoint = Vector2.new(1, 0.5)
				joinButton.Position = UDim2.new(1, -14, 0.5, 0)
				joinButton.Size = UDim2.fromOffset(44, 44)
				joinButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				joinButton.BackgroundTransparency = 0.08
				joinButton.BorderSizePixel = 0
				joinButton.AutoButtonColor = false
				joinButton.Image = ""
				joinButton.Parent = card
				addCorner(joinButton, UDim.new(1, 0))
				addAFEMStroke(joinButton, 1.1, 0.2)
				local playIcon = Instance.new("ImageLabel")
				playIcon.Size = UDim2.fromOffset(24, 24)
				playIcon.AnchorPoint = Vector2.new(0.5, 0.5)
				playIcon.Position = UDim2.fromScale(0.5, 0.5)
				playIcon.BackgroundTransparency = 1
				playIcon.Image = "rbxassetid://106640709678034"
				playIcon.ImageColor3 = WHITE
				playIcon.ScaleType = Enum.ScaleType.Fit
				playIcon.Active = false
				playIcon.Parent = joinButton
				joinButton.MouseEnter:Connect(function()
					tween(joinButton, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.15)
				end)
				joinButton.MouseLeave:Connect(function()
					tween(joinButton, {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}, 0.15)
				end)
				joinButton.Activated:Connect(function()
					playClick()
					if dataJobId ~= "" then
						pcall(function()
							TeleportService:TeleportToPlaceInstance(dataPlaceId, dataJobId, player)
						end)
					else
						pcall(function()
							TeleportService:TeleportAsync(dataPlaceId, {player})
						end)
					end
					notify("Connecting...")
				end)
			end

			snapshotCard(card)
			if withLoader then
				revealCardWithLoader(card)
			elseif usersAnimate then
				animateCardEntrance(card, cardScale, order)
			end
		end

		usersRender = function()
			usersPageDirty = false
			local isReload = usersReload
			if usersReload then
				usersReload = false
			end
			usersRenderToken = usersRenderToken + 1
			local token = usersRenderToken

			-- Cards currently on screen, indexed by uid --
			local existing = {}
			for _, child in ipairs(usersList:GetChildren()) do
				if child:IsA("TextButton") and (child.Name == "FlowUser" or child.Name == "FriendUser") then
					local uid = tonumber(child:GetAttribute("OUI10Uid"))
					if uid and uid ~= 0 then
						existing[uid] = child
					end
				end
			end

			-- which ones are still valid right now (to detect disconnects) --
			local sourceIds = {}
			if usersTab == "friends" then
				for _, f in ipairs(friendsCache) do
					sourceIds[tonumber(f.UserId or f.UserID) or 0] = true
				end
			else
				for id in pairs(usersCache) do
					sourceIds[tonumber(id) or 0] = true
				end
			end

			local emptyText = nil
			local page = {}
			local kind = "user"

			if usersTab == "friends" then
				kind = "friend"
				local fQuery = usersQuery:lower()
				local fList = {}
				for _, f in ipairs(friendsCache) do
					local uname = tostring(f.UserName or "")
					local dname = tostring(f.DisplayName or "")
					local searchOk = (fQuery == ""
						or uname:lower():find(fQuery, 1, true) ~= nil
						or dname:lower():find(fQuery, 1, true) ~= nil)
					if searchOk then
						fList[#fList + 1] = f
					end
				end
				local function friendPlaying(f)
					local loc = tostring(f.Location or f.LastLocation or "")
					return loc ~= "" and loc ~= "Roblox" and loc ~= "Website"
				end
				table.sort(fList, function(a, b)
					local pa, pb = friendPlaying(a), friendPlaying(b)
					if pa ~= pb then
						return pa
					end
					return tostring(a.DisplayName or a.UserName or "") < tostring(b.DisplayName or b.UserName or "")
				end)
				if #fList == 0 then
					emptyText = (fQuery ~= "") and (tr("Nobody matches \"") .. usersQuery .. "\"") or tr("No friends online")
				else
					local fTotal = math.max(1, math.ceil(#fList / USERS_PER_PAGE))
					if usersPageNum > fTotal then
						usersPageNum = fTotal
					end
					pagRebuild(fTotal)
					local fStart = (usersPageNum - 1) * USERS_PER_PAGE + 1
					local fEnd = math.min(#fList, fStart + USERS_PER_PAGE - 1)
					for index = fStart, fEnd do
						local f = fList[index]
						page[#page + 1] = {
							uid = tonumber(f.UserId or f.UserID) or 0,
							friend = f,
						}
					end
				end
			else
				local currentPlaceId = tonumber(game.PlaceId) or 0
				local currentGameId = tonumber(game.GameId) or 0
				local query = usersQuery:lower()
				local list = {}
				for id, entry in pairs(usersCache) do
					local dataPlaceId = tonumber(entry.PlaceId or entry.placeId or entry.RootPlaceId or entry.rootPlaceId) or 0
					local dataGameId = tonumber(entry.GameId or entry.gameId or entry.UniverseId or entry.universeId) or 0
					local samePlace = dataPlaceId ~= 0 and dataPlaceId == currentPlaceId
					local sameGame = dataGameId ~= 0 and dataGameId == currentGameId
					local sameExperience = samePlace or sameGame
					local tabOk = (usersTab == "all" or sameExperience)
					local searchOk = (query == "" or tostring(entry.Name or ""):lower():find(query, 1, true) ~= nil)
					if tabOk and searchOk then
						list[#list + 1] = {uid = tonumber(id) or tonumber(entry.UserId or entry.userid) or 0, data = entry, sameExperience = sameExperience}
					end
				end
				table.sort(list, function(a, b)
					return tostring(a.data.Name or ""):lower() < tostring(b.data.Name or ""):lower()
				end)
				if #list == 0 then
					if usersQuery ~= "" then
						emptyText = tr("Nobody matches \"") .. usersQuery .. "\""
					else
						emptyText = (usersTab == "game") and tr("Nobody from your game online") or tr("Nobody online right now")
					end
				else
					local totalPages = math.max(1, math.ceil(#list / USERS_PER_PAGE))
					if usersPageNum > totalPages then
						usersPageNum = totalPages
					end
					pagRebuild(totalPages)
					local startIndex = (usersPageNum - 1) * USERS_PER_PAGE + 1
					local endIndex = math.min(#list, startIndex + USERS_PER_PAGE - 1)
					for index = startIndex, endIndex do
						page[#page + 1] = list[index]
					end
				end
			end

			if emptyText then
				usersEmpty.Text = emptyText
				usersEmpty.Visible = true
				pagRebuild(1)
				for uid, card in pairs(existing) do
					if isReload and not sourceIds[uid] then
						-- Disconnected: fade out --
						fadeCardOut(card, 0.3)
						local dead = card
						task.delay(0.4, function()
							pcall(function()
								if dead.Parent then
									dead:Destroy()
								end
							end)
						end)
					else
						card:Destroy()
					end
				end
				usersSeen = {}
				if updateUsersScroll then
					task.defer(updateUsersScroll)
				end
				return
			end

			usersEmpty.Visible = false

			local desiredUids = {}
			for _, item in ipairs(page) do
				desiredUids[item.uid] = true
			end

			if not isReload then
				for uid, card in pairs(existing) do
					card:Destroy()
				end
				usersSeen = {}
				for index, item in ipairs(page) do
					if kind == "friend" then
						makeFriendCard(item.friend, index, false)
					else
						makeUserCard(item.data, item.sameExperience, index, false)
					end
					usersSeen[item.uid] = true
				end
				if updateUsersScroll then
					task.defer(updateUsersScroll)
				end
				return
			end

			-- Live render (arrivals/departures): keep cards, fade out disconnects --
			local leavingCards = {}
			for uid, card in pairs(existing) do
				if not sourceIds[uid] then
					leavingCards[card] = true
					fadeCardOut(card, 0.3)
					local dead = card
					task.delay(0.32, function()
						pcall(function()
							if dead.Parent then
								dead:Destroy()
							end
						end)
					end)
				end
			end

			local toCreate = {}
			local toReorder = {}
			for index, item in ipairs(page) do
				local card = existing[item.uid]
				local signature = kind == "friend"
					and friendEntrySignature(item.friend)
					or presenceEntrySignature(item.data)
				if card and card:GetAttribute("OUI10VisualSignature") ~= signature then
					card:Destroy()
					existing[item.uid] = nil
					card = nil
				end
				if card and not leavingCards[card] then
					if kind == "user" then
						updateUserCardDetails(card, item.data)
					end
					if card.LayoutOrder ~= index then
						toReorder[#toReorder + 1] = {card = card, index = index}
					end
					usersSeen[item.uid] = true
				else
					toCreate[#toCreate + 1] = {item = item, index = index}
				end
			end

			for uid, card in pairs(existing) do
				if not leavingCards[card] and not desiredUids[uid] then
					card:Destroy()
				end
			end

			local function createMissing()
				if usersRenderToken ~= token then
					return
				end
				for _, queued in ipairs(toReorder) do
					if usersRenderToken ~= token then
						return
					end
					if queued.card.Parent then
						queued.card.LayoutOrder = queued.index
						task.wait(0.035)
					end
				end
				for _, queued in ipairs(toCreate) do
					if usersRenderToken ~= token then
						return
					end
					local item = queued.item
					local isNew = not usersSeen[item.uid]
					if kind == "friend" then
						makeFriendCard(item.friend, queued.index, isNew)
					else
						makeUserCard(item.data, item.sameExperience, queued.index, isNew)
					end
				end
				usersSeen = {}
				for uid in pairs(desiredUids) do
					usersSeen[uid] = true
				end
				if updateUsersScroll then
					task.defer(updateUsersScroll)
				end
			end

			local hadLeaving = next(leavingCards) ~= nil
			if hadLeaving then
				task.delay(0.35, function()
					if usersRenderToken == token then
						createMissing()
					end
				end)
			else
				createMissing()
			end
		end

		usersRefreshAll = function()
			fetchPresence()
			fetchFriends()
			usersRender()
		end

		usersTabGame.Activated:Connect(function()
			playClick()
			if usersTab == "game" then
				return
			end
			usersTab = "game"
			usersPageNum = 1
			styleUserTabs()
			usersRender()
		end)

		usersTabAll.Activated:Connect(function()
			playClick()
			if usersTab == "all" then
				return
			end
			usersTab = "all"
			usersPageNum = 1
			styleUserTabs()
			usersRender()
		end)

		usersTabFriends.Activated:Connect(function()
			playClick()
			if usersTab == "friends" then
				return
			end
			usersTab = "friends"
			usersPageNum = 1
			styleUserTabs()
			fetchFriends()
			usersAnimate = true
			usersRender()
		end)

		styleUserTabs()

		usersSearch:GetPropertyChangedSignal("Text"):Connect(function()
			usersQuery = usersSearch.Text:gsub("^%s+", ""):gsub("%s+$", "")
			usersPageNum = 1
			usersAnimate = false
			usersRender()
			usersAnimate = true
		end)
		usersSearch.FocusLost:Connect(function()
			usersQuery = usersSearch.Text:gsub("^%s+", ""):gsub("%s+$", "")
			usersPageNum = 1
			usersAnimate = false
			usersRender()
			usersAnimate = true
		end)
	end
	buildUsersSection()

	-- Page switching -----------------------------------------------------------

	local showCommandPage -- se asigna mas abajo, en la seccion Commands

	showPage = function(key, deferRefresh)
		currentKey = key
		local page = pages[key]
		if not page then
			return
		end
		page.Visible = true
		page.Position = UDim2.fromOffset(0, 0)
		if key == "users" and not deferRefresh then
			if usersPageDirty then
				usersAnimate = false
				usersRender()
				usersAnimate = true
			end
		elseif key == "servers" and not deferRefresh and showServerPage then
			showServerPage()
		elseif key == "commands" and not deferRefresh and showCommandPage then
			showCommandPage()
		end
		if key == "users" then
			usersToolbar.Visible = true
			usersCount.TextTransparency = 0
			usersTabs.Visible = true
			usersTabs.BackgroundTransparency = 0.75
			pillIndicator.BackgroundTransparency = 0
			for _, button in ipairs({usersTabGame, usersTabAll, usersTabFriends}) do
				button.Visible = true
				button.BackgroundTransparency = 1
				button.TextTransparency = 0
			end
			usersSearch.Visible = true
			usersSearch.BackgroundTransparency = 0.55
			usersSearch.TextTransparency = 0
			local searchStroke = usersSearch:FindFirstChildOfClass("UIStroke")
			if searchStroke then
				searchStroke.Transparency = 0.7
			end
		end
	end

	usersAnimate = false
	usersRefreshAll()
	usersAnimate = true

	local function buildCommandsSection()
		-- Commands: Commands tab --------------------------------------------------------
		local commandsPage = pages["commands"]
		local cmdQuery = ""
		local cmdFilter = "all" -- all | favs | auto | custom
		local renderCommands, styleCommandTabs -- forward declarations
		local commandsPageDirty = true

		local COMMAND_REPO_API = "https://api.github.com/repos/PrinceBeebear/Pankcakejson/contents/"
		local COMMAND_REPO_RAW_URL = "https://raw.githubusercontent.com/PrinceBeebear/Pankcakejson/main/"

		-- Repository commands for immediate availability
		local defaultFlowCommands = {
			{ cmd = "antivcban", desc = "Anti VoiceChat Ban", file = "Antivcban.lua", kind = "repo" },
			{ cmd = "reanimation", desc = "Reanimation", file = "Reanimation.lua", kind = "repo" },
			{ cmd = "sfly", desc = "Sfly", file = "Sfly.lua", kind = "repo" },
			{ cmd = "spy", desc = "Spy", file = "Spy.lua", kind = "repo" },
			-- Comandos internos / utilitarios
			{ cmd = "fov", desc = tr("Field of view (FOV)"), kind = "auto" },
			{ cmd = "rj", desc = tr("Cinematic rejoin"), kind = "auto" },
			{ cmd = "to", desc = tr("Teleport to player"), kind = "auto" },
			{ cmd = "freecam", desc = tr("Free camera"), kind = "auto" },
			{ cmd = "unfreecam", desc = tr("Disable free camera"), kind = "auto" },
			{ cmd = "destroy", desc = tr("Close interface"), kind = "auto" },
		}

		-- Protected set: the internal commands must ALWAYS be listed in the
		-- AUTO tab, no matter what Flow merges into the command list --
		local internalAutoCommands = {}
		for _, item in ipairs(defaultFlowCommands) do
			if item.kind == "auto" then
				internalAutoCommands[item.cmd] = item
			end
		end

		local availableCommands = {}
		local repoScripts = {}
		local scriptCache = {}

		local function formatCommandName(filename)
			local name = filename:gsub("%.lua$", ""):gsub(" ", "-"):lower()
			return name
		end

		local function formatDescription(filename)
			local name = filename:gsub("%.lua$", ""):gsub("[-_]", " ")
			local words = {}
			for word in name:gmatch("%S+") do
				words[#words + 1] = word:sub(1, 1):upper() .. word:sub(2):lower()
			end
			return table.concat(words, " ")
		end

		for _, item in ipairs(defaultFlowCommands) do
			table.insert(availableCommands, {
				cmd = item.cmd,
				desc = item.desc,
				kind = item.kind or "repo",
				fileName = item.file,
			})
			if item.file then
				repoScripts[item.cmd] = item.file
			end
		end

		-- Command execution (identical to Flow.lua with offline and online support)
		local function ExecuteCommand(rawCmd)
			if not rawCmd or rawCmd == "" then return end
			local args = {}
			for w in string.gmatch(rawCmd, "%S+") do table.insert(args, w) end
			local c = string.lower(args[1] or "")
			local displayCmd = c

			local function showNotif(title, action)
				if type(_G._sn) == "function" then
					pcall(function() _G._sn(title, action or "ejecutado") end)
				elseif type(notify) == "function" then
					pcall(function() notify(title .. " " .. (action or "ejecutado")) end)
				end
			end

			-- If a Flow ExecuteCommand exists in the global environment, call it
			if type(_G.ExecuteCommand) == "function" and _G.ExecuteCommand ~= ExecuteCommand then
				local ok = pcall(function() _G.ExecuteCommand(rawCmd) end)
				if ok then return end
			end

			if c == "destroy" then
				if deactivatePresenceRow then
					pcall(deactivatePresenceRow)
				end
				setOpen(false)
				task.delay(0.35, function()
					pcall(function() if Gui then Gui:Destroy() end end)
					_G.OUI10Open = false
					_G.OUI10Loaded = false
					_G.OUI10Gui = nil
				end)
				return
			elseif c == "badge" then
				-- Only the creator can assign badges: 0 none, 1 verified, 2 plus
				-- (change 11920899390 to your UserId if this one is not yours)
				if player.UserId ~= 11920899390 then
					notify(tr("Only the script creator can assign badges."))
					return
				end
				local who = args[2]
				local value = tonumber(args[3]) or -1
				if not who or value < 0 or value > 2 then
					notify(tr("Usage: badge <user or id> <0|1|2>"))
					return
				end
				task.spawn(function()
					local targetId = tonumber(who)
					local targetName = who
					if not targetId then
						local okHttp, res = pcall(function()
							local opts = {
								Url = "https://users.roblox.com/v1/usernames/users",
								Method = "POST",
								Headers = { ["Content-Type"] = "application/json" },
								Body = HttpService:JSONEncode({ usernames = { who }, excludeBannedUsers = false }),
							}
							if type(request) == "function" then
								return request(opts)
							elseif type(http_request) == "function" then
								return http_request(opts)
							end
							return HttpService:RequestAsync(opts)
						end)
						local body = okHttp and res and (res.Body or res.body)
						if body then
							local okJson, decoded = pcall(function()
								return HttpService:JSONDecode(body)
							end)
							if okJson and type(decoded) == "table" and type(decoded.data) == "table" and decoded.data[1] then
								targetId = tonumber(decoded.data[1].id) or nil
								targetName = tostring(decoded.data[1].name or who)
							end
						end
					end
					if not targetId then
						notify(tr("Could not find that user: ") .. tostring(who))
						return
					end
					local saved = false
					if setBadgeForUser then
						saved = setBadgeForUser(targetId, value, targetName)
					end
					if saved then
						notify(tr("Badge ") .. tostring(value) .. tr(" assigned to ") .. tostring(targetName))
						if requestPresenceRefresh then
							requestPresenceRefresh()
						end
					end
				end)
			elseif c == "rj" then
				pcall(function()
					local ts = game:GetService("TeleportService")
					ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
				end)
			elseif c == "fov" then
				pcall(function()
					local val = args[2]
					if not val or val == "" then
						workspace.CurrentCamera.FieldOfView = 70
					else
						local num = tonumber(val)
						workspace.CurrentCamera.FieldOfView = num and math.clamp(num, 30, 120) or 70
					end
				end)
			elseif c == "to" then
				pcall(function()
					local targetName = args[2]
					if not targetName or targetName == "" then
						showNotif("To", tr("type the name"))
						return
					end
					local nm = table.concat(args, " ", 2):lower()
					displayCmd = "to " .. nm
					for _, p in ipairs(Players:GetPlayers()) do
						if p ~= Players.LocalPlayer and (p.Name:lower():find(nm, 1, true) or p.DisplayName:lower():find(nm, 1, true)) then
							if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
								Players.LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
								showNotif("To", p.DisplayName)
								return
							end
						end
					end
					showNotif("To", tr("player not found"))
				end)
			else
				local customEntry = type(_G.OUI10CustomCmds) == "table" and _G.OUI10CustomCmds[c] or nil
				if customEntry and type(customEntry.code) == "string" and customEntry.code ~= "" then
					task.spawn(function()
						local customFn = loadstring(customEntry.code)
						if customFn then
							customFn()
							showNotif(displayCmd, "ejecutado")
						else
							showNotif(c, tr("invalid code"))
						end
					end)
					return
				end
				local fileName = (_G._rs and _G._rs[c]) or repoScripts[c]
				if not fileName then
					for _, d in ipairs(defaultFlowCommands) do
						if d.cmd == c and d.file then
							fileName = d.file
							break
						end
					end
				end

				if fileName then
					task.spawn(function()
						local cached = scriptCache[c]
						if cached then
							local fn = loadstring(cached)
							if fn then
								fn()
								showNotif(displayCmd, "ejecutado")
								return
							end
						end

						-- 1. Try a local file if the executor supports readfile
						local function tryLocal(p)
							if type(isfile) == "function" and isfile(p) and type(readfile) == "function" then
								local ok2, content = pcall(function() return readfile(p) end)
								if ok2 and content and content ~= "" then
									local fn = loadstring(content)
									if fn then
										fn()
										showNotif(displayCmd, "ejecutado")
										return true
									end
								end
							end
							return false
						end

						if tryLocal(fileName) then return end
						local sp = ""
						pcall(function() if type(getscriptpath) == "function" then sp = getscriptpath() end end)
						local dir = sp:match("(.+[/\\])") or ""
						if dir ~= "" and tryLocal(dir .. fileName) then return end

						-- 2. Download from the Flow GitHub Raw
						local url = COMMAND_REPO_RAW_URL .. HttpService:UrlEncode(fileName)
						local ok, content = pcall(function() return game:HttpGet(url, true) end)
						if not ok or not content or content == "" then
							ok, content = pcall(function() return httpRequest("GET", url) end)
						end
						if ok and type(content) == "string" and content ~= "" then
							scriptCache[c] = content
							local fn = loadstring(content)
							if fn then
								fn()
								showNotif(displayCmd, "ejecutado")
								return
							end
						end
						showNotif(c, tr("execution error"))
					end)
				else
					showNotif(c, tr("does not exist"))
					return
				end
			end
			showNotif(displayCmd, "ejecutado")
		end
		_G.ExecuteCommand = ExecuteCommand

		-- Refresh commands from the Flow repository in the background
		local function RefreshCommandsFromRepo()
			task.spawn(function()
				local updated = false
				local function fileOk()
					return type(writefile) == "function" and type(readfile) == "function" and type(isfolder) == "function" and type(delfile) == "function"
				end
				local function loadCache()
					if fileOk() then
						local okC, cBody = pcall(function() return readfile("flow_repo_cache.json") end)
						if okC and cBody then
							local okD, cData = pcall(function() return HttpService:JSONDecode(cBody) end)
							if okD and type(cData) == "table" then
								return cData
							end
						end
					end
					return nil
				end
				local function saveCache()
					if repoScripts and next(repoScripts) and fileOk() then
						pcall(function() writefile("flow_repo_cache.json", HttpService:JSONEncode(repoScripts)) end)
					end
				end

				-- If Flow already has global commands, merge them in
				if type(_G._ac) == "table" and #_G._ac > 0 then
					for _, cmdData in ipairs(_G._ac) do
						local exists = false
						for _, ex in ipairs(availableCommands) do
							if ex.cmd == cmdData.cmd then exists = true; break end
						end
						if not exists then
							table.insert(availableCommands, {
								cmd = cmdData.cmd,
								desc = cmdData.desc or formatDescription(cmdData.cmd),
								kind = cmdData.isCustom and "custom" or (cmdData.isRepo == false and "auto" or "repo"),
								fileName = cmdData.fileName,
							})
							if cmdData.fileName then
								repoScripts[cmdData.cmd] = cmdData.fileName
							end
							updated = true
						end
					end
				end

				-- Query the GitHub Repo API
				local body = httpRequest("GET", COMMAND_REPO_API)
				if body then
					local ok, list = pcall(function() return HttpService:JSONDecode(body) end)
					if ok and type(list) == "table" then
						for _, item in ipairs(list) do
							if item.type == "file" and item.name:match("%.lua$") and item.name ~= "Flow.lua" then
								local name = formatCommandName(item.name)
								repoScripts[name] = item.name
								local exists = false
								for _, ex in ipairs(availableCommands) do
									if ex.cmd == name then exists = true; break end
								end
								if not exists then
									table.insert(availableCommands, {
										cmd = name,
										desc = formatDescription(item.name),
										kind = "repo",
										fileName = item.name,
									})
									updated = true
								end
							end
						end
					end
				end

				-- Try Flow HTML scraping if the API fails
				local okHtml, html = pcall(function() return game:HttpGet("https://github.com/PrinceBeebear/Pankcakejson", true) end)
				if okHtml and html then
					for path in html:gmatch('title="([^"]+%.lua)"') do
						local fn = path:match("([^/\\]+%.lua)$") or path
						if fn ~= "Flow.lua" then
							local name = formatCommandName(fn)
							repoScripts[name] = fn
							local exists = false
							for _, ex in ipairs(availableCommands) do
								if ex.cmd == name then exists = true; break end
							end
							if not exists then
								table.insert(availableCommands, {
									cmd = name,
									desc = formatDescription(fn),
									kind = "repo",
									fileName = fn,
								})
								updated = true
							end
						end
					end
				end

				-- Local commands via listfiles
				if type(listfiles) == "function" then
					pcall(function()
						local sp = ""
						pcall(function() if type(getscriptpath) == "function" then sp = getscriptpath() end end)
						local dir = sp:match("(.+[/\\])") or ""
						local files = listfiles(dir ~= "" and dir or nil)
						if type(files) == "table" then
							for _, f in ipairs(files) do
								local fn = f:match("([^/\\]+%.lua)$")
								if fn and fn ~= "Flow.lua" then
									local name = formatCommandName(fn)
									repoScripts[name] = fn
									local exists = false
									for _, ex in ipairs(availableCommands) do
										if ex.cmd == name then exists = true; break end
									end
									if not exists then
										table.insert(availableCommands, {
											cmd = name,
											desc = formatDescription(fn),
											kind = "repo",
											fileName = fn,
										})
										updated = true
									end
								end
							end
						end
					end)
				end

				saveCache()
				table.sort(availableCommands, function(a, b) return a.cmd:lower() < b.cmd:lower() end)
				if renderCommands then
					renderCommands(true)
				end
				if styleCommandTabs then
					styleCommandTabs(true)
				end
			end)
		end

		local function getCommandsData()
			local favs = _G.OUI10Favs or {}
			local all = {}
			local seen = {}
			for _, c in ipairs(availableCommands) do
				if not seen[c.cmd] then
					seen[c.cmd] = true
					all[#all + 1] = {
						cmd = c.cmd,
						desc = (c.desc and c.desc ~= "") and c.desc or (tr("Command ") .. c.cmd),
						kind = c.kind or "repo",
						isFav = favs[c.cmd] == true,
					}
				end
			end
			-- External commands injected by the user
			local ok, provided = pcall(function()
				if type(_G.OUI10GetCommands) == "function" then return _G.OUI10GetCommands() end
				return _G.OUI10Commands
			end)
			if ok and type(provided) == "table" then
				for k, v in pairs(provided) do
					local name = type(v) == "table" and (v.cmd or v.name) or (type(k) == "string" and k or tostring(v))
					if name and not seen[name] then
						seen[name] = true
						local desc = type(v) == "table" and (v.desc or v.description) or ""
						all[#all + 1] = {
							cmd = name,
							desc = desc ~= "" and desc or (tr("Command ") .. name),
							kind = "custom",
							isFav = favs[name] == true,
						}
					end
				end
			end
			-- Custom commands saved from the Custom tab --
			local savedCustoms = type(_G.OUI10CustomCmds) == "table" and _G.OUI10CustomCmds or {}
			for customName, customData in pairs(savedCustoms) do
				if not seen[customName] then
					seen[customName] = true
					all[#all + 1] = {
						cmd = customName,
						desc = (type(customData) == "table" and type(customData.desc) == "string" and customData.desc ~= "") and customData.desc or tr("Custom command"),
						kind = "custom",
						isFav = favs[customName] == true,
					}
				end
			end
			-- Internal commands always keep their AUTO slot: they are appended
			-- if a merge dropped them and forced back to kind "auto" otherwise --
			for internalCmd, internalItem in pairs(internalAutoCommands) do
				local found = false
				for _, c in ipairs(all) do
					if c.cmd == internalCmd then
						c.kind = "auto"
						found = true
						break
					end
				end
				if not found then
					seen[internalCmd] = true
					all[#all + 1] = {
						cmd = internalCmd,
						desc = internalItem.desc,
						kind = "auto",
						isFav = favs[internalCmd] == true,
					}
				end
			end
			table.sort(all, function(a, b) return a.cmd:lower() < b.cmd:lower() end)
			return all
		end

		local function filterCommands(query)
			query = (query or ""):lower()
			local filtered = {}
			for _, c in ipairs(getCommandsData()) do
				local passTab = (cmdFilter == "all")
					or (cmdFilter == "favs" and c.isFav)
					or (cmdFilter == "auto" and c.kind == "auto")
					or (cmdFilter == "custom" and c.kind == "custom")
				if passTab and (query == "" or c.cmd:lower():find(query, 1, true) or c.desc:lower():find(query, 1, true)) then
					filtered[#filtered + 1] = c
				end
			end
			return filtered
		end

		local cmdToolbar = makeToolbar(commandsPage, 30, 10)

		-- Minimal toolbar: the segmented tabs sit on the LEFT and the
		-- search box on the RIGHT. The old "N COMMANDS" label is gone --
		-- the ALL tab already carries the total, so the row reads clean. --
		local cmdTabs = Instance.new("Frame")
		cmdTabs.Size = UDim2.fromOffset(260, 30)
		cmdTabs.AnchorPoint = Vector2.new(0, 0.5)
		cmdTabs.Position = UDim2.new(0, 0, 0.5, 0)
		cmdTabs.BackgroundColor3 = AFEM_BLACK
		cmdTabs.BackgroundTransparency = 0.75
		cmdTabs.BorderSizePixel = 0
		cmdTabs.ZIndex = 5
		cmdTabs.Parent = cmdToolbar
		addCorner(cmdTabs, UDim.new(0, 16))
		addAFEMStroke(cmdTabs, 1, 0.6)
		

		local cmdPill = Instance.new("Frame")
		cmdPill.Size = UDim2.new(0, 34, 0, 22)
		cmdPill.AnchorPoint = Vector2.new(0, 0.5)
		cmdPill.Position = UDim2.new(0, 4, 0.5, 0)
		cmdPill.BackgroundColor3 = WHITE
		cmdPill.BorderSizePixel = 0
		cmdPill.ZIndex = 6
		cmdPill.Parent = cmdTabs
		addCorner(cmdPill, UDim.new(0, 11))

		local function makeCmdTab(name, text)
			local b = Instance.new("TextButton")
			b.Name = name
			b.Size = UDim2.new(0, 44, 1, 0)
			b.AnchorPoint = Vector2.new(0, 0.5)
			b.Position = UDim2.new(0, 0, 0.5, 0)
			b.BackgroundTransparency = 1
			b.BorderSizePixel = 0
			b.AutoButtonColor = false
			b.Font = UI_FONT
			b.TextSize = 11
			b.TextColor3 = WHITE
			b.Text = text
			b.ZIndex = 7
			b.Parent = cmdTabs
			return b
		end

		local cmdTabAll = makeCmdTab("CmdTabAll", "ALL")
		local cmdTabFavs = makeCmdTab("CmdTabFavs", "FAVS")
		local cmdTabAuto = makeCmdTab("CmdTabAuto", "AUTO")
		local cmdTabCustom = makeCmdTab("CmdTabCustom", tr("CUSTOM"))

		local cmdTabButtons = {
			all = cmdTabAll,
			favs = cmdTabFavs,
			auto = cmdTabAuto,
			custom = cmdTabCustom,
		}
		local cmdTabBase = {
			all = "ALL",
			favs = "FAVS",
			auto = "AUTO",
			custom = tr("CUSTOM"),
		}
		-- Live width of the segmented strip: every label carries its
		-- counter ("ALL 128 / FAVS 5 / ...") so the strip re-measures
		-- itself whenever the counts change (new favorite, new custom
		-- command, repo sync). The strip is anchored right, so a wider
		-- strip just grows to the left in place. --
		local cmdTabsWidth = 260

		local function updateCmdTabs()
			local data = getCommandsData()
			local counts = { all = #data, favs = 0, auto = 0, custom = 0 }
			for _, c in ipairs(data) do
				if c.isFav then counts.favs = counts.favs + 1 end
				if c.kind == "auto" then counts.auto = counts.auto + 1 end
				if c.kind == "custom" then counts.custom = counts.custom + 1 end
			end
			local x = 0
			for _, key in ipairs({ "all", "favs", "auto", "custom" }) do
				local label = cmdTabBase[key] .. " " .. tostring(counts[key])
				local b = cmdTabButtons[key]
				-- GothamMedium at 11px: ~6px per glyph plus padding --
				local w = math.max(40, math.floor(#label * 6.2 + 18))
				b.Text = label
				b.Size = UDim2.new(0, w, 1, 0)
				b.Position = UDim2.new(0, x, 0.5, 0)
				x = x + w
			end
			cmdTabsWidth = math.max(160, x)
			cmdTabs.Size = UDim2.fromOffset(cmdTabsWidth, 30)
		end
		updateCmdTabs()

		local cmdSearch = makeSearchBox(cmdToolbar, {
			width = 240,
			height = 30,
			font = UI_FONT,
			textSize = 13,
			placeholder = tr("Search command…"),
			placeholderColor = Color3.fromRGB(160, 160, 160),
			cornerRadius = 16,
		})
		cmdSearch.AnchorPoint = Vector2.new(1, 0.5)
		cmdSearch.Position = UDim2.new(1, -12, 0.5, 0)
		cmdSearch.ZIndex = 5

		local cmdSearchPad = Instance.new("UIPadding")
		cmdSearchPad.PaddingLeft = UDim.new(0, 12)
		cmdSearchPad.PaddingRight = UDim.new(0, 12)
		cmdSearchPad.Parent = cmdSearch

		local commandBarWidth = UserInputService.TouchEnabled and not UserInputService.MouseEnabled and 280 or 340
		local cmdList, updateCmdScroll, cmdScrollTrack
		local cmdPanel
		local customEditor = nil
		local commandBar = Instance.new("Frame")
		commandBar.Name = "FlowCommandBar"
		commandBar.Size = UDim2.fromOffset(commandBarWidth, 30)
		commandBar.AnchorPoint = Vector2.new(0, 0.5)
		commandBar.Position = UDim2.new(0, 0, 0.5, 0)
		commandBar.BackgroundColor3 = AFEM_BLACK
		commandBar.BackgroundTransparency = 0.55
		commandBar.BorderSizePixel = 0
		commandBar.ZIndex = 9
		commandBar.Visible = false
		commandBar.Parent = Gui
		addCorner(commandBar, UDim.new(0, 16))
		-- The list and the glass panel behind it always share the same
		-- rect: every layout branch places both together --
		local function placeCmdList(pos, size)
			cmdList.Position = pos
			cmdList.Size = size
			if cmdPanel then
				cmdPanel.Position = pos
				cmdPanel.Size = size
			end
		end

		local function fitCommandBar()
			local toolbarWidth = cmdToolbar.AbsoluteSize.X
			if toolbarWidth <= 0 then
				return
			end
			if toolbarWidth < 740 then
				cmdToolbar.Size = UDim2.new(1, 0, 0, 66)
				-- tabs keep the first row on the left; the search box
				-- wraps to a full-width second row --
				cmdTabs.Size = UDim2.fromOffset(cmdTabsWidth, 30)
				cmdTabs.AnchorPoint = Vector2.new(0, 0.5)
				cmdTabs.Position = UDim2.new(0, 0, 0.5, 0)
				cmdSearch.Size = UDim2.new(1, -24, 0, 30)
				cmdSearch.AnchorPoint = Vector2.new(0, 0.5)
				cmdSearch.Position = UDim2.new(0, 12, 0, 51)
				if cmdList then
					if cmdFilter == "custom" then
						-- below the wrapped search box (its bottom sits
						-- at y=91 in the narrow toolbar) --
						placeCmdList(UDim2.fromOffset(12, 350), UDim2.new(1, -24, 1, -368))
						if customEditor then
							customEditor.Position = UDim2.fromOffset(12, 100)
							customEditor.Size = UDim2.new(1, -24, 0, 240)
						end
					else
						placeCmdList(UDim2.fromOffset(12, 100), UDim2.new(1, -24, 1, -118))
					end
				end
				if cmdScrollTrack then
					cmdScrollTrack.Visible = false
				end
			else
				cmdToolbar.Size = UDim2.new(1, 0, 0, 30)
				cmdTabs.Size = UDim2.fromOffset(cmdTabsWidth, 30)
				cmdTabs.AnchorPoint = Vector2.new(0, 0.5)
				cmdTabs.Position = UDim2.new(0, 0, 0.5, 0)
				cmdSearch.Size = UDim2.fromOffset(240, 30)
				cmdSearch.AnchorPoint = Vector2.new(1, 0.5)
				cmdSearch.Position = UDim2.new(1, -12, 0.5, 0)
				if cmdList then
					if cmdFilter == "custom" then
						placeCmdList(UDim2.new(0.5, 6, 0, 54), UDim2.new(0.5, -18, 1, -72))
						if customEditor then
							customEditor.Position = UDim2.new(0, 12, 0, 54)
							customEditor.Size = UDim2.new(0.5, -18, 1, -72)
						end
					else
						placeCmdList(UDim2.fromOffset(12, 54), UDim2.new(1, -24, 1, -72))
					end
				end
				if cmdScrollTrack then
					cmdScrollTrack.Visible = true
				end
			end
		end
		cmdToolbar:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitCommandBar)
		task.defer(fitCommandBar)

		local commandInput = Instance.new("TextBox")
		commandInput.Name = "CommandInput"
		commandInput.Size = UDim2.new(1, -24, 1, 0)
		commandInput.Position = UDim2.fromOffset(12, 0)
		commandInput.BackgroundTransparency = 1
		commandInput.BorderSizePixel = 0
		commandInput.ClearTextOnFocus = false
		commandInput.Font = UI_FONT
		commandInput.TextSize = 12
		commandInput.TextColor3 = WHITE
		commandInput.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
		commandInput.PlaceholderText = tr("Run command...")
		commandInput.Text = ""
		commandInput.TextXAlignment = Enum.TextXAlignment.Left
		commandInput.ZIndex = 6
		commandInput.Parent = commandBar

				-- Ghost suggestion (like the Flow.lua bar): while typing, the rest of
		-- the command shows up in gray; Enter completes and runs it. --
		local cmdSuggestion = ""
		local cmdSuggestLabel = Instance.new("TextLabel")
		cmdSuggestLabel.Name = "CommandSuggest"
		cmdSuggestLabel.Size = UDim2.new(1, -24, 1, 0)
		cmdSuggestLabel.Position = UDim2.fromOffset(12, 0)
		cmdSuggestLabel.BackgroundTransparency = 1
		cmdSuggestLabel.BorderSizePixel = 0
		cmdSuggestLabel.Font = UI_FONT
		cmdSuggestLabel.TextSize = 12
		cmdSuggestLabel.TextColor3 = TEXT_DIM
		cmdSuggestLabel.TextXAlignment = Enum.TextXAlignment.Left
		cmdSuggestLabel.TextTruncate = Enum.TextTruncate.AtEnd
		cmdSuggestLabel.Text = ""
		cmdSuggestLabel.ZIndex = 6
		cmdSuggestLabel.Parent = commandBar

		local function updateCommandSuggestion()
			local typed = commandInput.Text
			cmdSuggestion = ""
			cmdSuggestLabel.Text = ""
			if typed == "" then
				return
			end
			local lowerTyped = typed:lower()
			for _, cmdData in ipairs(availableCommands) do
				local cmdName = (cmdData.cmd or ""):match("^(%S+)")
				if cmdName and #cmdName > #typed and cmdName:lower():sub(1, #lowerTyped) == lowerTyped then
					cmdSuggestion = cmdName
					cmdSuggestLabel.Text = cmdName
					break
				end
			end
		end
		commandInput:GetPropertyChangedSignal("Text"):Connect(updateCommandSuggestion)

		local function submitCommand()
			local rawCommand = commandInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
			if rawCommand == "" then
				return
			end
			playClick()
			if cmdSuggestion ~= "" and #rawCommand < #cmdSuggestion then
				rawCommand = cmdSuggestion
			end
			ExecuteCommand(rawCommand)
			commandInput.Text = ""
			commandInput:ReleaseFocus()
		end

commandInput.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				submitCommand()
			end
		end)
		-- The command bar floats on the screen and follows the nav bar:
		-- nav bottom -> bar above the buttons; nav left -> bottom-left;
		-- nav right -> bottom-right; nav top -> below the bar. --
		layoutCommandBarForNav = function()
			if not commandBar then
				return
			end
			if navPosition == "bottom" then
				commandBar.AnchorPoint = Vector2.new(0.5, 1)
				commandBar.Position = UDim2.new(0.5, 0, 1, -72)
			elseif navPosition == "left" then
				commandBar.AnchorPoint = Vector2.new(0, 1)
				commandBar.Position = UDim2.new(0, 78, 1, -20)
			elseif navPosition == "right" then
				commandBar.AnchorPoint = Vector2.new(1, 1)
				commandBar.Position = UDim2.new(1, -78, 1, -20)
			else
				commandBar.AnchorPoint = Vector2.new(0.5, 0)
				commandBar.Position = UDim2.new(0.5, 0, 0, 76)
			end
		end
		layoutCommandBarForNav()

		local commandBarFades = {}
		local function trackCommandBar(object, property, openValue)
			commandBarFades[#commandBarFades + 1] = {object = object, property = property, open = openValue}
			object[property] = 1
		end
		trackCommandBar(commandBar, "BackgroundTransparency", 0.55)
		trackCommandBar(commandInput, "TextTransparency", 0)
		trackCommandBar(cmdSuggestLabel, "TextTransparency", 0)

		local commandBarShown = false
		local function setCommandBarVisible(show)
			if commandBarShown == show then
				return
			end
			commandBarShown = show
			if show then
				commandBar.Size = UDim2.fromOffset(commandBarWidth, 30)
				layoutCommandBarForNav()
				commandBar.Visible = true
			end
			for _, fade in ipairs(commandBarFades) do
				tween(fade.object, {[fade.property] = show and fade.open or 1}, 0.24)
			end
			if not show then
				task.delay(0.26, function()
					if not commandBarShown then
						commandBar.Visible = false
					end
				end)
			end
		end
		setCommandBarVisibleHook = setCommandBarVisible

				-- Custom command editor (Custom tab) --
		customEditor = Instance.new("Frame")
		customEditor.Name = "CustomEditor"
		customEditor.Size = UDim2.new(1, 0, 0, 240)
		customEditor.Position = UDim2.fromOffset(0, 66)
		-- same glass card language as the command list panel --
		customEditor.BackgroundColor3 = AFEM_CARD
		customEditor.BackgroundTransparency = 0.06
		customEditor.BorderSizePixel = 0
		customEditor.Visible = false
		customEditor.ClipsDescendants = true
		customEditor.Parent = commandsPage
		addCorner(customEditor, UDim.new(0, 18))
		addUserCardStroke(customEditor)

		local function makeCustomBox(placeholder, y, height, multiline)
			local box = Instance.new("TextBox")
			box.Size = UDim2.new(1, -24, 0, height)
			box.Position = UDim2.fromOffset(12, y)
			box.BackgroundColor3 = AFEM_BLACK
			box.BackgroundTransparency = 0.55
			box.BorderSizePixel = 0
			box.Font = UI_FONT
			box.TextSize = 12
			box.TextColor3 = WHITE
			box.PlaceholderColor3 = TEXT_DIM
			box.PlaceholderText = placeholder
			box.Text = ""
			box.TextXAlignment = Enum.TextXAlignment.Left
			box.TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
			box.TextWrapped = multiline
			box.MultiLine = multiline
			box.ClearTextOnFocus = false
			box.ZIndex = 6
			box.Parent = customEditor
			addCorner(box, UDim.new(0, 10))
			local boxPad = Instance.new("UIPadding")
			boxPad.PaddingLeft = UDim.new(0, 8)
			boxPad.Parent = box
			return box
		end

		-- Labeled rows: Name / Description / Code --
		addLabel(customEditor, tr("Name"), 12, 6, 1, 13, 10, TEXT_DIM)
		local customNameBox = makeCustomBox(tr("Command name (e.g. my-script)"), 21, 26, false)
		addLabel(customEditor, tr("Description"), 12, 52, 1, 13, 10, TEXT_DIM)
		local customDescBox = makeCustomBox(tr("Description (optional)"), 67, 24, false)
		addLabel(customEditor, tr("Code"), 12, 96, 1, 13, 10, TEXT_DIM)
		local customCodeBox = makeCustomBox(tr("Command Lua code..."), 111, 116, true)
		-- The Lua code box stretches down to the button row at any
		-- editor height (scale based), and code reads like code --
		customCodeBox.Size = UDim2.new(1, -24, 1, -161)
		customCodeBox.Font = Enum.Font.Code
		local customSaveBtn = Instance.new("TextButton")
		customSaveBtn.Size = UDim2.new(0.4, -12, 0, 30)
		customSaveBtn.AnchorPoint = Vector2.new(1, 1)
		customSaveBtn.Position = UDim2.new(1, -12, 1, -6)
		customSaveBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
		customSaveBtn.BackgroundTransparency = 0.25
		customSaveBtn.BorderSizePixel = 0
		customSaveBtn.AutoButtonColor = false
		customSaveBtn.Font = UI_FONT
		customSaveBtn.TextSize = 12
		customSaveBtn.TextColor3 = WHITE
		customSaveBtn.Text = tr("Save custom command")
		customSaveBtn.ZIndex = 6
		customSaveBtn.Parent = customEditor
		addCorner(customSaveBtn, UDim.new(0, 10))

		-- Cancel clears the three fields (the form is only a draft
		-- until Save is pressed) --
		local customCancelBtn = Instance.new("TextButton")
		customCancelBtn.Name = "CustomCancel"
		customCancelBtn.Size = UDim2.new(0.3, -12, 0, 30)
		customCancelBtn.AnchorPoint = Vector2.new(0, 1)
		customCancelBtn.Position = UDim2.new(0, 12, 1, -6)
		customCancelBtn.BackgroundColor3 = AFEM_BLACK
		customCancelBtn.BackgroundTransparency = 0.45
		customCancelBtn.BorderSizePixel = 0
		customCancelBtn.AutoButtonColor = false
		customCancelBtn.Font = UI_FONT
		customCancelBtn.TextSize = 12
		customCancelBtn.TextColor3 = WHITE
		customCancelBtn.Text = tr("Cancel")
		customCancelBtn.ZIndex = 6
		customCancelBtn.Parent = customEditor
		addCorner(customCancelBtn, UDim.new(0, 10))
		customCancelBtn.Activated:Connect(function()
			playClick()
			customNameBox.Text = ""
			customDescBox.Text = ""
			customCodeBox.Text = ""
		end)

		local function cmdNotify(title, action)
			if type(_G._sn) == "function" then
				pcall(function() _G._sn(title, action or "") end)
			end
		end

		customSaveBtn.Activated:Connect(function()
			playClick()
			local name = customNameBox.Text:gsub("^%s+", ""):gsub("%s+$", ""):gsub("[^%w_%-]", "-"):lower()
			local desc = customDescBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
			local code = customCodeBox.Text
			if name == "" or code == "" then
				cmdNotify(tr("Error"), tr("name and code required"))
				return
			end
			_G.OUI10CustomCmds = _G.OUI10CustomCmds or {}
			local isNew = _G.OUI10CustomCmds[name] == nil
			_G.OUI10CustomCmds[name] = { desc = desc, code = code }
			saveConfig()
			customNameBox.Text = ""
			customDescBox.Text = ""
			customCodeBox.Text = ""
			cmdNotify(name, isNew and tr("command added") or tr("command updated"))
			renderCommands(true)
			styleCommandTabs(true)
		end)

		-- One calm glass panel behind the palette rows: the section
		-- reads as a single surface (same card language as Flow users) --
		cmdPanel = Instance.new("Frame")
		cmdPanel.Name = "CmdPanel"
		cmdPanel.BackgroundColor3 = AFEM_CARD
		cmdPanel.BackgroundTransparency = 0.06
		cmdPanel.BorderSizePixel = 0
		cmdPanel.ZIndex = 1
		cmdPanel.Parent = commandsPage
		addCorner(cmdPanel, UDim.new(0, 18))
		addUserCardStroke(cmdPanel)
		addShadow(cmdPanel, 18, 0.4, UDim2.new(0, 0, 0, 5))

		-- Command list with its own custom scrollbar (applyCustomScroll);
		-- the right inset keeps the track inside the panel --
		cmdList, updateCmdScroll, cmdScrollTrack = makeList(commandsPage, 54, 18, 12)
		fitCommandBar()

		local cmdPad = Instance.new("UIPadding")
		cmdPad.PaddingLeft = UDim.new(0, 12)
		cmdPad.PaddingRight = UDim.new(0, 12)
		cmdPad.PaddingTop = UDim.new(0, 12)
		cmdPad.PaddingBottom = UDim.new(0, 12)
		cmdPad.Parent = cmdList

		local cmdGrid = Instance.new("UIGridLayout")
		-- Palette rows: 40 px each, touching, no dividers --
		cmdGrid.CellSize = UDim2.new(1, 0, 0, 40)
		cmdGrid.CellPadding = UDim2.new(0, 0, 0, 0)
		cmdGrid.SortOrder = Enum.SortOrder.LayoutOrder
		cmdGrid.Parent = cmdList

		local cmdEmpty = Instance.new("TextLabel")
		cmdEmpty.Size = UDim2.new(1, 0, 0, 20)
		cmdEmpty.AnchorPoint = Vector2.new(0.5, 0.5)
		cmdEmpty.Position = UDim2.new(0.5, 0, 0.5, 18)
		cmdEmpty.BackgroundTransparency = 1
		cmdEmpty.BorderSizePixel = 0
		cmdEmpty.Font = UI_FONT
		cmdEmpty.TextSize = 12
		cmdEmpty.TextColor3 = TEXT_DIM
		cmdEmpty.Text = tr("No commands available")
		cmdEmpty.Visible = false
		cmdEmpty.Active = false
		cmdEmpty.Parent = commandsPage

		-- CTA under the empty-state message: "Clear search" when the
		-- query found nothing, "Create command" on an empty Custom tab --
		local cmdEmptyBtn = Instance.new("TextButton")
		cmdEmptyBtn.Name = "CmdEmptyAction"
		cmdEmptyBtn.Size = UDim2.fromOffset(140, 26)
		cmdEmptyBtn.AnchorPoint = Vector2.new(0.5, 0)
		cmdEmptyBtn.Position = UDim2.new(0.5, 0, 0.5, 34)
		cmdEmptyBtn.BackgroundColor3 = WHITE
		cmdEmptyBtn.BackgroundTransparency = 0.85
		cmdEmptyBtn.BorderSizePixel = 0
		cmdEmptyBtn.AutoButtonColor = false
		cmdEmptyBtn.Font = UI_FONT
		cmdEmptyBtn.TextSize = 11
		cmdEmptyBtn.TextColor3 = WHITE
		cmdEmptyBtn.Text = ""
		cmdEmptyBtn.Visible = false
		cmdEmptyBtn.ZIndex = 5
		cmdEmptyBtn.Parent = commandsPage
		addCorner(cmdEmptyBtn, UDim.new(0, 13))
		cmdEmptyBtn.Activated:Connect(function()
			playClick()
			if cmdQuery ~= "" then
				cmdSearch.Text = ""
				-- the Text signal drives the handler on real clients;
				-- this fallback covers environments where it is quiet --
				if cmdQuery ~= "" then
					cmdQuery = ""
					renderCommands(true)
				end
			elseif cmdFilter == "custom" then
				pcall(function() customNameBox:CaptureFocus() end)
			end
		end)

		-- Command card
		-- Command palette row (Raycast / VS Code style): nothing at rest
		-- but text — a category icon chip, the name in code font and the
		-- muted description on ONE centered line, actions on the right.
		-- Hover lifts the whole row; the selected row keeps an accent
		-- bar plus a highlighted background --
		local cmdSelectedRow = nil
		local SELECT_TINT = Color3.fromRGB(70, 130, 255)
		local KIND_COLORS = {
			auto = Color3.fromRGB(255, 196, 80),
			custom = Color3.fromRGB(120, 220, 150),
		}
		local KIND_GLYPHS = {
			auto = "⚡",
			custom = "✎",
		}
		local function kindColorOf(kind)
			return KIND_COLORS[kind] or Color3.fromRGB(120, 170, 255)
		end
		local function kindGlyphOf(kind)
			return KIND_GLYPHS[kind] or "{ }"
		end

		local function buildCommandCard(c, order)
			local isCustom = c.kind == "custom"
			local card = Instance.new("TextButton")
			card.Name = "CmdCard"
			card.Size = UDim2.new(1, 0, 0, 40)
			card.BackgroundColor3 = WHITE
			card.BackgroundTransparency = 1
			card.BorderSizePixel = 0
			card.AutoButtonColor = false
			card.Text = ""
			card.ClipsDescendants = true
			card.LayoutOrder = order
			card.Parent = cmdList
			addCorner(card, UDim.new(0, 10))

			-- selection accent bar: left edge, only on the selected row --
			local selBar = Instance.new("Frame")
			selBar.Name = "CmdSelBar"
			selBar.AnchorPoint = Vector2.new(0, 0.5)
			selBar.Position = UDim2.new(0, 0, 0.5, 0)
			selBar.Size = UDim2.fromOffset(3, 24)
			selBar.BackgroundColor3 = SELECT_TINT
			selBar.BorderSizePixel = 0
			selBar.Visible = false
			selBar.ZIndex = 2
			selBar.Parent = card
			addCorner(selBar, UDim.new(0, 2))

			-- category icon chip: the one color anchor of the row --
			local kindColor = kindColorOf(c.kind)
			local icon = Instance.new("Frame")
			icon.Name = "CmdIcon"
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.Position = UDim2.new(0, 8, 0.5, 0)
			icon.Size = UDim2.fromOffset(24, 24)
			icon.BackgroundColor3 = kindColor
			icon.BackgroundTransparency = 0.88
			icon.BorderSizePixel = 0
			icon.ZIndex = 2
			icon.Parent = card
			addCorner(icon, UDim.new(0, 8))
			local iconGlyph = Instance.new("TextLabel")
			iconGlyph.Size = UDim2.fromScale(1, 1)
			iconGlyph.BackgroundTransparency = 1
			iconGlyph.BorderSizePixel = 0
			iconGlyph.Font = UI_FONT
			iconGlyph.TextSize = 12
			iconGlyph.TextColor3 = kindColor
			iconGlyph.Text = kindGlyphOf(c.kind)
			iconGlyph.ZIndex = 3
			iconGlyph.Parent = icon

			local nameLbl = Instance.new("TextLabel")
			nameLbl.AnchorPoint = Vector2.new(0, 0.5)
			nameLbl.Size = UDim2.fromOffset(170, 17)
			nameLbl.Position = UDim2.new(0, 48, 0.5, 0)
			nameLbl.BackgroundTransparency = 1
			nameLbl.BorderSizePixel = 0
			nameLbl.Font = Enum.Font.Code
			nameLbl.TextSize = 13
			nameLbl.TextColor3 = WHITE
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
			nameLbl.Text = "> " .. (c.cmd or "?")
			nameLbl.ZIndex = 3
			nameLbl.Parent = card

			local descLbl = Instance.new("TextLabel")
			-- same line as the name, muted; it stops before the right
			-- action column (wider on custom rows to clear the delete) --
			descLbl.AnchorPoint = Vector2.new(0, 0.5)
			descLbl.Position = UDim2.new(0, 234, 0.5, 0)
			descLbl.Size = isCustom and UDim2.new(1, -470, 0, 14) or UDim2.new(1, -378, 0, 14)
			descLbl.BackgroundTransparency = 1
			descLbl.BorderSizePixel = 0
			descLbl.Font = UI_FONT
			descLbl.TextSize = 11
			descLbl.TextColor3 = TEXT_DIM
			descLbl.TextXAlignment = Enum.TextXAlignment.Left
			descLbl.TextTruncate = Enum.TextTruncate.AtEnd
			descLbl.Text = c.desc or ""
			descLbl.ZIndex = 3
			descLbl.Parent = card

			-- Category word, muted on the right (the chip carries the
			-- color): AUTO / CUSTOM / SCRIPT --
			local kindChip = Instance.new("TextLabel")
			kindChip.Name = "CmdKind"
			local kindText = (c.kind == "auto" and "AUTO")
				or (c.kind == "custom" and "CUSTOM")
				or "SCRIPT"
			kindChip.Size = UDim2.fromOffset(64, 12)
			kindChip.AnchorPoint = Vector2.new(1, 1)
			kindChip.Position = isCustom and UDim2.new(1, -164, 1, -11) or UDim2.new(1, -136, 1, -11)
			kindChip.BackgroundTransparency = 1
			kindChip.BorderSizePixel = 0
			kindChip.Font = UI_FONT
			kindChip.TextSize = 9
			kindChip.TextColor3 = TEXT_DIM
			kindChip.TextXAlignment = Enum.TextXAlignment.Right
			kindChip.Text = kindText
			kindChip.ZIndex = 3
			kindChip.Parent = card

			local favBtn = Instance.new("TextButton")
			favBtn.Size = UDim2.fromOffset(22, 22)
			favBtn.AnchorPoint = Vector2.new(1, 1)
			favBtn.Position = UDim2.new(1, -106, 1, -6)
			favBtn.BackgroundTransparency = 1
			favBtn.BorderSizePixel = 0
			favBtn.AutoButtonColor = false
			favBtn.Font = UI_FONT
			favBtn.TextSize = 15
			favBtn.Text = "★"
			favBtn.TextColor3 = c.isFav and Color3.fromRGB(230, 150, 255) or WHITE
			favBtn.TextTransparency = c.isFav and 0 or 0.7
			favBtn.ZIndex = 5
			favBtn.Parent = card
			favBtn.Activated:Connect(function()
				_G.OUI10Favs = _G.OUI10Favs or {}
				if c.isFav then
					_G.OUI10Favs[c.cmd] = nil
					c.isFav = false
				else
					_G.OUI10Favs[c.cmd] = true
					c.isFav = true
				end
				saveConfig()
				favBtn.TextColor3 = c.isFav and Color3.fromRGB(230, 150, 255) or WHITE
				favBtn.TextTransparency = c.isFav and 0 or 0.7
				if cmdFilter == "favs" then
					renderCommands(true)
					styleCommandTabs(true)
				end
			end)

			-- Checkbox: this command runs only when the script opens --
			local autoOn = (_G.OUI10AutoExec or {})[c.cmd] == true
			local autoExecTrack = Instance.new("Frame")
			autoExecTrack.Name = "AutoExecToggle"
			autoExecTrack.Size = UDim2.fromOffset(34, 18)
			autoExecTrack.AnchorPoint = Vector2.new(1, 1)
			autoExecTrack.Position = UDim2.new(1, -10, 1, -8)
			autoExecTrack.BackgroundColor3 = autoOn and Color3.fromRGB(120, 200, 255) or Color3.fromRGB(70, 70, 76)
			autoExecTrack.BackgroundTransparency = 0.2
			autoExecTrack.BorderSizePixel = 0
			autoExecTrack.ZIndex = 6
			autoExecTrack.Parent = card
			addCorner(autoExecTrack, UDim.new(1, 0))
			local autoExecKnob = Instance.new("Frame")
			autoExecKnob.Size = UDim2.fromOffset(14, 14)
			autoExecKnob.AnchorPoint = Vector2.new(0.5, 0.5)
			autoExecKnob.Position = autoOn and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 9, 0.5, 0)
			autoExecKnob.BackgroundColor3 = WHITE
			autoExecKnob.BorderSizePixel = 0
			autoExecKnob.ZIndex = 7
			autoExecKnob.Parent = autoExecTrack
			addCorner(autoExecKnob, UDim.new(1, 0))
			local autoExecBtn = Instance.new("TextButton")
			autoExecBtn.Size = UDim2.new(1, 0, 1, 0)
			autoExecBtn.BackgroundTransparency = 1
			autoExecBtn.Text = ""
			autoExecBtn.ZIndex = 8
			autoExecBtn.Parent = autoExecTrack
			autoExecBtn.Activated:Connect(function()
				playClick()
				_G.OUI10AutoExec = _G.OUI10AutoExec or {}
				local nowOn = _G.OUI10AutoExec[c.cmd] ~= true
				if nowOn then
					_G.OUI10AutoExec[c.cmd] = true
				else
					_G.OUI10AutoExec[c.cmd] = nil
				end
				saveConfig()
				tween(autoExecTrack, {BackgroundColor3 = nowOn and Color3.fromRGB(120, 200, 255) or Color3.fromRGB(70, 70, 76)}, 0.15)
				tween(autoExecKnob, {Position = nowOn and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 9, 0.5, 0)}, 0.15, Enum.EasingStyle.Quart)
				if type(_G._sn) == "function" then
					pcall(function() _G._sn(tostring(c.cmd), nowOn and tr("auto on start") or tr("auto disabled")) end)
				end
			end)
			if c.kind == "custom" then
				local delBtn = Instance.new("TextButton")
				delBtn.Size = UDim2.fromOffset(22, 22)
				delBtn.AnchorPoint = Vector2.new(1, 1)
				delBtn.Position = UDim2.new(1, -134, 1, -6)
				delBtn.BackgroundTransparency = 1
				delBtn.BorderSizePixel = 0
				delBtn.AutoButtonColor = false
				delBtn.Font = UI_FONT
				delBtn.TextSize = 16
				delBtn.Text = "×"
				delBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
				delBtn.ZIndex = 6
				delBtn.Parent = card
				delBtn.Activated:Connect(function()
					playClick()
					if type(_G.OUI10CustomCmds) == "table" then
						_G.OUI10CustomCmds[c.cmd] = nil
						saveConfig()
						if type(_G._sn) == "function" then
							pcall(function() _G._sn(tostring(c.cmd), tr("command removed")) end)
						end
						renderCommands(true)
						styleCommandTabs(true)
					end
				end)
			end
			-- The selected row keeps a soft blue tint; every other row
			-- rests fully transparent over the panel --
			local function restRowBg()
				if card == cmdSelectedRow then
					tween(card, { BackgroundColor3 = SELECT_TINT, BackgroundTransparency = 0.84 }, 0.25)
				else
					tween(card, { BackgroundColor3 = WHITE, BackgroundTransparency = 1 }, 0.25)
				end
			end
			-- Brief colored ping so the click feels answered, then the
			-- row returns to its resting state --
			local function flashCard(color)
				tween(card, { BackgroundColor3 = color, BackgroundTransparency = 0.3 }, 0.1)
				task.delay(0.4, function()
					if card.Parent then
						restRowBg()
					end
				end)
			end

			-- Explicit Run: hover reveals it on desktop, touch devices
			-- always see it (there is no hover there) --
			local runBtn = Instance.new("TextButton")
			runBtn.Name = "CmdRun"
			runBtn.Size = UDim2.fromOffset(46, 18)
			runBtn.AnchorPoint = Vector2.new(1, 1)
			runBtn.Position = UDim2.new(1, -52, 1, -8)
			runBtn.BackgroundColor3 = WHITE
			runBtn.BackgroundTransparency = 0.82
			runBtn.BorderSizePixel = 0
			runBtn.AutoButtonColor = false
			runBtn.Font = UI_FONT
			runBtn.TextSize = 10
			runBtn.TextColor3 = WHITE
			runBtn.Text = "▶ Run"
			runBtn.ZIndex = 6
			runBtn.Visible = IS_TOUCH_DEVICE
			runBtn.Parent = card
			addCorner(runBtn, UDim.new(0, 9))
			runBtn.Activated:Connect(function()
				if c.cmd and c.cmd ~= "" then
					playClick()
					flashCard(Color3.fromRGB(60, 165, 95))
					ExecuteCommand(c.cmd)
				end
			end)
			card.MouseEnter:Connect(function()
				runBtn.Visible = true
				-- whole-row hover: the surface lifts so the row reads
				-- as clickable (and the actions appear with it) --
				if card ~= cmdSelectedRow then
					tween(card, { BackgroundTransparency = 0.9 }, 0.15)
				end
			end)
			card.MouseLeave:Connect(function()
				runBtn.Visible = IS_TOUCH_DEVICE
				if card ~= cmdSelectedRow then
					tween(card, { BackgroundTransparency = 1 }, 0.15)
				end
			end)

			-- Clicking the card SELECTS the command: it lands in the
			-- bar so the user can add arguments and run it with Enter.
			-- The explicit Run (or the bar) is what actually executes,
			-- so a stray click can no longer fire a command by accident --
			card.Activated:Connect(function()
				if c.cmd and c.cmd ~= "" then
					playClick()
					local prev = cmdSelectedRow
					cmdSelectedRow = card
					if prev and prev ~= card and prev.Parent then
						tween(prev, { BackgroundColor3 = WHITE, BackgroundTransparency = 1 }, 0.15)
						local prevBar = prev:FindFirstChild("CmdSelBar")
						if prevBar then
							prevBar.Visible = false
						end
					end
					selBar.Visible = true
					tween(card, { BackgroundColor3 = SELECT_TINT, BackgroundTransparency = 0.84 }, 0.15)
					commandInput.Text = c.cmd
					updateCommandSuggestion()
					pcall(function() commandInput:CaptureFocus() end)
				end
			end)

			return card
		end

		renderCommands = function(instant)
			commandsPageDirty = false
			-- keep the tab counters and the responsive toolbar in sync
			-- with the live command list --
			updateCmdTabs()
			fitCommandBar()
			local rows = filterCommands(cmdQuery)

			for _, child in ipairs(cmdList:GetChildren()) do
				if child.Name == "CmdCard" then
					child:Destroy()
				end
			end

			if #rows == 0 then
				cmdEmpty.Text = (cmdQuery ~= "") and (tr("No results for \"") .. cmdQuery .. "\"")
					or (cmdFilter == "favs" and tr("No favorites yet"))
					or (cmdFilter == "custom" and tr("No custom commands yet"))
					or tr("No commands available")
				cmdEmpty.Visible = true
				if cmdQuery ~= "" then
					cmdEmptyBtn.Text = tr("Clear search")
					cmdEmptyBtn.Visible = true
				elseif cmdFilter == "custom" then
					cmdEmptyBtn.Text = tr("Create command")
					cmdEmptyBtn.Visible = true
				else
					cmdEmptyBtn.Visible = false
				end
				if updateCmdScroll then
					task.defer(updateCmdScroll)
				end
				return
			end

			cmdEmpty.Visible = false
			cmdEmptyBtn.Visible = false
			cmdSelectedRow = nil
			for i, c in ipairs(rows) do
				buildCommandCard(c, i)
			end
			if updateCmdScroll then
				task.defer(updateCmdScroll)
			end
		end

		styleCommandTabs = function(noAnimation)
			local target = cmdTabButtons[cmdFilter] or cmdTabAll
			local targetX = target.Position.X.Offset + 4
			local targetWidth = math.max(28, target.Size.X.Offset - 8)
			tween(cmdPill, {
				Position = UDim2.new(0, targetX, 0.5, 0),
				Size = UDim2.new(0, targetWidth, 0, 22),
			}, noAnimation and 0 or 0.3, Enum.EasingStyle.Quart)
			for key, button in pairs(cmdTabButtons) do
				tween(button, {TextColor3 = (key == cmdFilter) and AFEM_BLACK or WHITE}, noAnimation and 0 or 0.2)
			end
		end

		local function setCommandFilter(key)
			cmdFilter = key
			-- Custom tab: editor on the left, commands on the right --
			local showEditor = key == "custom"
			if customEditor then
				customEditor.Visible = showEditor
			end
			cmdGrid.CellSize = UDim2.new(1, 0, 0, 40)
			cmdEmpty.Position = showEditor and UDim2.new(0.75, 0, 0.5, 18) or UDim2.new(0.5, 0, 0.5, 18)
			cmdEmptyBtn.Position = UDim2.new(showEditor and 0.75 or 0.5, 0, 0.5, 34)
			fitCommandBar()
			renderCommands(false)
			styleCommandTabs()
		end

		cmdTabAll.Activated:Connect(function()
			setCommandFilter("all")
		end)
		cmdTabFavs.Activated:Connect(function()
			setCommandFilter("favs")
		end)
		cmdTabAuto.Activated:Connect(function()
			setCommandFilter("auto")
		end)
		cmdTabCustom.Activated:Connect(function()
			setCommandFilter("custom")
		end)

		local function onCommandSearchChanged()
			local text = cmdSearch.Text:gsub("^%s+", ""):gsub("%s+$", "")
			if text == cmdQuery then
				return
			end
			cmdQuery = text
			renderCommands(true)
		end
		cmdSearch:GetPropertyChangedSignal("Text"):Connect(onCommandSearchChanged)
		cmdSearch.FocusLost:Connect(onCommandSearchChanged)

		showCommandPage = function()
			if commandsPageDirty then
				renderCommands(true)
			end
			styleCommandTabs(true)
		end

		-- Load initial commands and sync with the Flow repo
		renderCommands(true)
		styleCommandTabs(true)
		commandsPage.Visible = false
		RefreshCommandsFromRepo()
	end
	buildCommandsSection()
	-- Auto exec: commands checked with the checkbox run on startup --
	task.spawn(function()
		task.wait(2.5)
		local autoExecMap = type(_G.OUI10AutoExec) == "table" and _G.OUI10AutoExec or {}
		local customMap = type(_G.OUI10CustomCmds) == "table" and _G.OUI10CustomCmds or {}
		for autoName, autoEnabled in pairs(autoExecMap) do
			if autoEnabled and autoName ~= "destroy" and autoName ~= "badge" then
				local autoCustom = customMap[autoName]
				if autoCustom and type(autoCustom.code) == "string" and autoCustom.code ~= "" then
					pcall(function()
						local autoFn = loadstring(autoCustom.code)
						if autoFn then
							autoFn()
						end
					end)
				elseif type(_G.ExecuteCommand) == "function" then
					pcall(function() _G.ExecuteCommand(autoName) end)
				end
				task.wait(0.3)
			end
		end
	end)




	local presenceSince = os.time()
	local pendingPresenceBody = nil
	local presenceWriteActive = false
	-- Supabase upsert (PostgREST): one row per user in flow_presence.
	-- on_conflict=user_id turns the POST into an automatic INSERT/UPDATE,
	-- the direct equivalent of the per-UserId PUT used in Firebase.
	local PRESENCE_UPSERT_PATH = "/flow_presence?on_conflict=user_id"
	local PRESENCE_UPSERT_HEADERS = { Prefer = "resolution=merge-duplicates,return=minimal" }
	local function flushPresenceWrites()
		if presenceWriteActive then
			return
		end
		presenceWriteActive = true
		task.spawn(function()
			while pendingPresenceBody do
				local body = pendingPresenceBody
				pendingPresenceBody = nil
				local response = supaRequest("POST", PRESENCE_UPSERT_PATH, body, PRESENCE_UPSERT_HEADERS)
				if response == nil then
					warn("OUI10: could not update the Flow presence in Supabase.")
				end
			end
			presenceWriteActive = false
			if pendingPresenceBody then
				flushPresenceWrites()
			end
		end)
	end
	-- The payload uses the snake_case columns fetchPresence expects: game_id
	-- feeds the banner (GameIcon), user_id the avatar (AvatarHeadShot), job_id
	-- the join button and since the time on the server. is_active=true and
	-- updated_at_ts keep the connected state (the read applies a 120 s TTL).
	writePresence = function()
		local hideGame = dndConfig.DND_Enabled and dndConfig.DND_HideGame
		local hideBanner = dndConfig.DND_Enabled and dndConfig.DND_HideBanner
		local hideAvatar = dndConfig.DND_Enabled and dndConfig.DND_HideAvatar
		local hideName = dndConfig.DND_Enabled and dndConfig.DND_HideName
		local hidePlayers = dndConfig.DND_Enabled and dndConfig.DND_HidePlayers
		local hidePing = dndConfig.DND_Enabled and dndConfig.DND_HidePing
		local blockJoin = dndConfig.DND_Enabled and dndConfig.DND_BlockJoin
		pendingPresenceBody = {
			user_id = player.UserId,
			name = hideName and (tostring(dndConfig.DND_CustomName or "") ~= "" and dndConfig.DND_CustomName or "Hidden") or player.DisplayName,
			game_name = hideGame and "Hidden" or ((placeName ~= "" and placeName) or game.Name),
			game_id = hideGame and 0 or game.GameId,
			place_id = hideGame and 0 or game.PlaceId,
			job_id = blockJoin and "" or game.JobId,
			players = 0,
			max_players = 0,
			ping = 0,
			since = presenceSince,
			updated_at_ts = os.time(),
			dnd = dndConfig.DND_Enabled and true or false,
			hide_game = hideGame and true or false,
			hide_banner = (hideBanner or hideGame) and true or false,
			banner_id = tostring(dndConfig.DND_BannerId or "134918452547700"),
			hide_avatar = hideAvatar and true or false,
			avatar_id = tostring(dndConfig.DND_AvatarId or "109728664560706"),
			hide_name = hideName and true or false,
			custom_name = tostring(dndConfig.DND_CustomName or "Hidden"),
			hide_players = hidePlayers and true or false,
			hide_ping = hidePing and true or false,
			block_join = blockJoin and true or false,
			is_active = true,
		}
		if not hidePlayers then
			pendingPresenceBody.players = #Players:GetPlayers()
			pendingPresenceBody.max_players = Players.MaxPlayers
		end
		if not hidePing then
			local ping
			local gotPing = pcall(function()
				ping = player:GetNetworkPing() * 1000
			end)
			if not gotPing or not ping or ping <= 0 then
				pcall(function()
					ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
				end)
			end
			if ping and ping > 0 then
				pendingPresenceBody.ping = math.floor(ping + 0.5)
			end
		end
		flushPresenceWrites()
	end

	-- Turning the own row off on exit: when the game closes or the script
	-- is unloaded the heartbeat stops and the row would stay "connected".
	-- It is NOT deleted: the badge lives in the same row and is kept for
	-- the next time the user joins. PATCH: is_active=false (invisible in
	-- the list, 120 s TTL) and with no server to join.
	deactivatePresenceRow = function()
		local response = supaRequest("PATCH", "/flow_presence?user_id=eq." .. tostring(player.UserId), {
			is_active = false,
			job_id = "",
			game_id = 0,
			place_id = 0,
			game_name = "Hidden",
		})
		if response == nil then
			warn("OUI10: could not turn off the Flow presence in Supabase.")
			return false
		end
		return true
	end
	-- Important: BindToClose ONLY exists on the server; on the client it
	-- throws "BindToClose can only be called on the server" and used to
	-- abort the whole startup (nothing was written or read because of it).
	-- The LocalPlayer leaving notice is used as best effort; if it does
	-- not make it in time, the supabase_setup.sql cron turns the row off anyway.
	pcall(function()
		player:GetPropertyChangedSignal("Parent"):Connect(function()
			if player.Parent == nil then
				-- up to 3 attempts: the first send sometimes does not make it out
				for attempt = 1, 3 do
					if deactivatePresenceRow() then
						break
					end
					task.wait(0.15)
				end
			end
		end)
	end)
	-- Badges in the SAME flow_presence table (badge column, next to name).
	setBadgeForUser = function(targetId, value, nameText)
		if not targetId or targetId <= 0 then
			return false
		end
		-- Upsert by user_id: if the user is connected only the badge changes
		-- (the heartbeat never sends the badge, the session stays the same);
		-- if offline it creates a sleeping row: updated_at_ts = 0 makes the
		-- read (120 s TTL) not show it until the user actually joins.
		local response = supaRequest("POST", "/flow_presence?on_conflict=user_id", {
			user_id = targetId,
			name = tostring(nameText or ""),
			badge = value,
		}, { Prefer = "resolution=merge-duplicates,return=minimal" })
		if response == nil then
			warn("OUI10: could not save the badge in Supabase.")
			return false
		end
		return true
	end
	task.spawn(function()
		writePresence()
		while Gui.Parent do
			task.wait(15)
			if Gui.Parent then
				writePresence()
			end
		end
		-- Fallback: if the Gui gets destroyed another way, the row turns off too.
		pcall(deactivatePresenceRow)
	end)

	-- Fast read: 3 s base cycle. An own change (Do not disturb or opening
	-- Flow users) wakes the cycle instantly, so the list refreshes in
	-- ~1 s instead of waiting for the full cycle. Friends are checked every
	-- 3 cycles (~9 s) to avoid saturating the Roblox API.
	local PRESENCE_READ_INTERVAL = 3
	local presenceRefreshNow = false
	local presenceRefreshToken = 0
	requestPresenceRefresh = function()
		presenceRefreshToken = presenceRefreshToken + 1
		local token = presenceRefreshToken
		-- short wait so the write reaches the database first
		task.delay(0.6, function()
			if token == presenceRefreshToken and Gui.Parent then
				presenceRefreshNow = true
			end
		end)
	end
	task.spawn(function()
		local cycle = 0
		while Gui.Parent do
			cycle = cycle + 1
			local changed = fetchPresence()
			local friendsChanged = false
			if cycle % 3 == 1 then
				local prevFriends = friendsSig
				fetchFriends()
				friendsChanged = friendsSig ~= prevFriends
			end
			if isOpen and currentSectionKey == "users" then
				if (usersTab == "friends" and friendsChanged) or (usersTab ~= "friends" and changed) then
					usersReload = true
					usersRender()
				end
			elseif (usersTab == "friends" and friendsChanged) or (usersTab ~= "friends" and changed) then
				usersPageDirty = true
			end
			-- split wait in steps: the wake-up jumps in without waiting for the cycle
			local remaining = PRESENCE_READ_INTERVAL
			while Gui.Parent and not presenceRefreshNow and remaining > 0 do
				remaining = remaining - task.wait(0.25)
			end
			presenceRefreshNow = false
		end
	end)
	if Gui.Parent then
		Gui:SetAttribute("OUI10Ready", true)
		showHud()
	end
	end, function(err)
		return debug.traceback(tostring(err), 2)
	end)
	if not initialized then
		local message = "OUI10: error while building the sections: " .. tostring(initializationError)
		pcall(function()
			Gui:SetAttribute("OUI10InitializationError", tostring(initializationError))
		end)
		warn(message)
	end
end)
