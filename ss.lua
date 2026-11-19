local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local SUPABASE_URL = "https://eggflguqaoqccgtbbzlr.supabase.co"
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVnZ2ZsZ3VxYW9xY2NndGJiemxyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM1MDgzNjIsImV4cCI6MjEwOTA4NDM2Mn0.tk2PPWBCDyHNLSlPiJ35uhnlGLLildmJvuRJgqHFKuA"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local guiName = "FlowBottomBar"

if type(_G.FlowersCleanup) == "function" then
	_G.FlowersCleanup()
	return
end
local existingGui = _G.FlowersGui or playerGui:FindFirstChild(guiName)
if existingGui then
	existingGui:Destroy()
	_G.FlowersGui = nil
	return
end

local sections = {
	{ key = "home", title = "Home", icon = "107666112838606" },
	{ key = "commands", title = "Commands", icon = "137548923529153" },
	{ key = "users", title = "Flow users", icon = "85748034018110" },
	{ key = "servers", title = "Server list", icon = "100465503260845" },
	{ key = "settings", title = "Settings", icon = "78758671432935" },
}

local colors = {
	black = Color3.fromRGB(0, 0, 0),
	panel = Color3.fromRGB(20, 21, 24),
	panelPink = Color3.fromRGB(23, 23, 26),
	panelBlue = Color3.fromRGB(18, 19, 22),
	card = Color3.fromRGB(28, 29, 32),
	white = Color3.fromRGB(245, 245, 250),
	muted = Color3.fromRGB(160, 163, 170),
	pink = Color3.fromRGB(190, 193, 199),
	purple = Color3.fromRGB(124, 128, 136),
	cyan = Color3.fromRGB(220, 224, 230),
	activePink = Color3.fromRGB(238, 239, 242),
	darkPink = Color3.fromRGB(30, 31, 34),
	darkPurple = Color3.fromRGB(39, 40, 44),
	darkCyan = Color3.fromRGB(50, 52, 57),
	hoverPink = Color3.fromRGB(172, 175, 182),
	hoverCyan = Color3.fromRGB(211, 214, 219),
	border = Color3.fromRGB(76, 79, 85),
	barGlow = Color3.fromRGB(170, 182, 199),
	commandPink = Color3.fromRGB(20, 20, 23),
	commandPurple = Color3.fromRGB(30, 31, 34),
	commandCyan = Color3.fromRGB(52, 55, 61),
	commandSurface = Color3.fromRGB(20, 20, 23),
	commandPinkMid = Color3.fromRGB(34, 34, 38),
	commandCyanMid = Color3.fromRGB(46, 48, 53),
	commandPlaceholder = Color3.fromRGB(225, 225, 230),
	windowGlow = Color3.fromRGB(0, 0, 0),
	line = Color3.fromRGB(58, 60, 65),
	online = Color3.fromRGB(190, 193, 199),
	idle = Color3.fromRGB(154, 157, 164),
	dnd = Color3.fromRGB(120, 123, 130),
}

local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui
_G.FlowersGui = gui

local connections = {}
local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(connections, connection)
	return connection
end

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundTransparency = 1
root.Parent = gui

local screenDimmer = Instance.new("CanvasGroup")
screenDimmer.Name = "ScreenDimmer"
screenDimmer.Size = UDim2.fromScale(1, 1)
screenDimmer.BackgroundColor3 = colors.black
screenDimmer.BackgroundTransparency = 0
screenDimmer.GroupTransparency = 1
screenDimmer.Visible = false
screenDimmer.ZIndex = 2
screenDimmer.Parent = root
local dimmerGradient = Instance.new("UIGradient")
dimmerGradient.Rotation = 90
dimmerGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.74),
	NumberSequenceKeypoint.new(0.18, 0.86),
	NumberSequenceKeypoint.new(0.38, 1),
	NumberSequenceKeypoint.new(0.62, 1),
	NumberSequenceKeypoint.new(0.82, 0.86),
	NumberSequenceKeypoint.new(1, 0.74),
})
dimmerGradient.Parent = screenDimmer

local backdropTween
local function setBackdrop(enabled)
	if backdropTween then
		backdropTween:Cancel()
	end
	screenDimmer.Visible = true
	backdropTween = TweenService:Create(
		screenDimmer,
		TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ GroupTransparency = enabled and 0 or 1 }
	)
	backdropTween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed and not enabled then
			screenDimmer.Visible = false
		end
	end)
	backdropTween:Play()
end

local function corner(object, radius)
	local instance = Instance.new("UICorner")
	instance.CornerRadius = UDim.new(0, radius)
	instance.Parent = object
	return instance
end

local function addBottomContour(object, name, inset)
	local stroke = Instance.new("UIStroke")
	stroke.Name = name
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = colors.border
	stroke.Thickness = 1.25
	stroke.Transparency = 0.2
	stroke.Parent = object
	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Rotation = 90
	strokeGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.65, 1),
		NumberSequenceKeypoint.new(0.82, 0.58),
		NumberSequenceKeypoint.new(0.92, 0.26),
		NumberSequenceKeypoint.new(1, 0.18),
	})
	strokeGradient.Parent = stroke

	local edge = Instance.new("Frame")
	edge.Name = name .. "Edge"
	edge.Position = UDim2.new(0, inset, 1, -2)
	edge.Size = UDim2.new(1, -inset * 2, 0, 2)
	edge.BackgroundColor3 = colors.border
	edge.BorderSizePixel = 0
	edge.ZIndex = object.ZIndex + 1
	edge.Parent = object
	local edgeGradient = Instance.new("UIGradient")
	edgeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.black),
		ColorSequenceKeypoint.new(0.2, colors.border),
		ColorSequenceKeypoint.new(0.8, colors.border),
		ColorSequenceKeypoint.new(1, colors.black),
	})
	edgeGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.12, 0.35),
		NumberSequenceKeypoint.new(0.5, 0.18),
		NumberSequenceKeypoint.new(0.88, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	edgeGradient.Parent = edge
	return stroke
end

local shadowWarningIssued = false
local function addBlurShadow(object, blurRadius, color, transparency, offset)
	local ok, shadow = pcall(function()
		local shadow = Instance.new("UIShadow")
		shadow.BlurRadius = UDim.new(0, blurRadius)
		shadow.Color = color
		shadow.Transparency = transparency
		shadow.Offset = offset
		pcall(function()
			shadow.ShowBehindParent = true
		end)
		shadow.Parent = object
		return shadow
	end)
	if not ok and not shadowWarningIssued then
		shadowWarningIssued = true
		warn("Flowers: UIShadow could not be created: " .. tostring(shadow))
	end
	return ok and shadow or nil
end

local function addHoverScale(object, hoverScale)
	local scale = Instance.new("UIScale")
	scale.Parent = object
	local activeTween
	local function setScale(value)
		if activeTween then
			activeTween:Cancel()
		end
		activeTween = TweenService:Create(
			scale,
			TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Scale = value }
		)
		activeTween:Play()
	end
	object.MouseEnter:Connect(function()
		setScale(hoverScale or 1.06)
	end)
	object.MouseLeave:Connect(function()
		setScale(1)
	end)
	return scale
end

local function animateCardEntrance(card, scale, order, columns)
	columns = tonumber(columns) or 3
	if columns < 1 then
		columns = 3
	end
	local position = math.max(0, order - 1)
	local delay = math.min(((position % columns) + math.floor(position / columns)) * 0.06, 0.3)
	local fadeProperties = { "BackgroundTransparency", "TextTransparency", "ImageTransparency", "Transparency" }
	local baseValues = {}
	local function collect(object)
		for _, property in ipairs(fadeProperties) do
			local ok, value = pcall(function()
				return object[property]
			end)
			if ok and type(value) == "number" then
				baseValues[object] = baseValues[object] or {}
				baseValues[object][property] = value
			end
		end
		for _, child in ipairs(object:GetChildren()) do
			collect(child)
		end
	end
	collect(card)
	for object, properties in pairs(baseValues) do
		for property in pairs(properties) do
			pcall(function()
				object[property] = 1
			end)
		end
	end
	scale.Scale = 0.92
	task.delay(delay, function()
		if not card.Parent then
			return
		end
		TweenService:Create(
			scale,
			TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
		for object, properties in pairs(baseValues) do
			if object.Parent then
				for property, value in pairs(properties) do
					TweenService:Create(
						object,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ [property] = value }
					):Play()
				end
			end
		end
	end)
end

local function label(parent, text, position, size, textSize, textColor, font)
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.BorderSizePixel = 0
	item.Position = position
	item.Size = size
	item.Font = font or Enum.Font.Gotham
	item.Text = text
	item.TextColor3 = textColor or colors.white
	item.TextSize = textSize or 12
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.TextWrapped = true
	item.Parent = parent
	return item
end

local function makeSurface(parent, name, position, size, background, radius)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Position = position
	frame.Size = size
	frame.BackgroundColor3 = background or colors.card
	frame.BackgroundTransparency = 0
	frame.BorderSizePixel = 0
	frame.Parent = parent
	corner(frame, radius or 10)
	return frame
end

local function makeButton(parent, text, position, size, selected)
	local button = Instance.new("TextButton")
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = selected and colors.white or colors.card
	button.BackgroundTransparency = selected and 0 or 0.1
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamMedium
	button.Text = text
	button.TextColor3 = selected and colors.black or colors.white
	button.TextSize = 10
	button.Parent = parent
	corner(button, 9)
	return button
end

local function makeInput(parent, placeholder, position, size)
	local input = Instance.new("TextBox")
	input.Position = position
	input.Size = size
	input.BackgroundColor3 = colors.card
	input.BackgroundTransparency = 0
	input.BorderSizePixel = 0
	input.ClearTextOnFocus = false
	input.Font = Enum.Font.Gotham
	input.PlaceholderColor3 = colors.muted
	input.PlaceholderText = placeholder
	input.Text = ""
	input.TextColor3 = colors.white
	input.TextSize = 11
	input.TextXAlignment = Enum.TextXAlignment.Left
	input.Parent = parent
	corner(input, 9)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = input
	return input
end

local function makeScroll(parent, name, position, size)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = name
	scroll.Position = position
	scroll.Size = size
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = colors.purple
	scroll.CanvasSize = UDim2.new()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.Parent = parent
	return scroll
end

local function placeholder(parent, text, position, size)
	local block = makeSurface(parent, "Placeholder", position, size, colors.card, 10)
	label(block, text, UDim2.fromOffset(12, 4), UDim2.new(1, -24, 1, -8), 11, colors.muted)
	return block
end

local bar = Instance.new("Frame")
bar.Name = "NeonBar"
bar.AnchorPoint = Vector2.new(0.5, 1)
bar.Position = UDim2.new(0.5, 0, 1, 84)
bar.Size = UDim2.new(0, 0, 0, 0)
bar.BackgroundTransparency = 1
bar.BorderSizePixel = 0
bar.ZIndex = 3
bar.Parent = root

local dock = Instance.new("Frame")
dock.Name = "NavigationDock"
dock.AnchorPoint = Vector2.new(0.5, 0.5)
dock.Position = UDim2.fromScale(0.5, 0.5)
dock.Size = UDim2.fromOffset(0, 48)
dock.BackgroundColor3 = colors.black
dock.BackgroundTransparency = 0
dock.BorderSizePixel = 0
dock.ZIndex = 5
dock.ClipsDescendants = true
dock.Parent = bar
corner(dock, 20)
addBlurShadow(dock, 10, colors.black, 0.26, UDim2.new(0, 0, 0, 0))
addBottomContour(dock, "DockBottomContour", 18)
local dockBottomLight = Instance.new("Frame")
dockBottomLight.Name = "DockBottomLight"
dockBottomLight.Position = UDim2.new(0, 18, 0.78, 0)
dockBottomLight.Size = UDim2.new(1, -36, 0.22, 0)
dockBottomLight.BackgroundColor3 = colors.white
dockBottomLight.BorderSizePixel = 0
dockBottomLight.ZIndex = dock.ZIndex
dockBottomLight.Parent = dock
local dockLightGradient = Instance.new("UIGradient")
dockLightGradient.Rotation = 90
dockLightGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(1, 0.9),
})
dockLightGradient.Parent = dockBottomLight

local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.AnchorPoint = Vector2.new(0.5, 0.5)
buttonContainer.Position = UDim2.fromScale(0.5, 0.5)
buttonContainer.Size = UDim2.fromScale(1, 1)
buttonContainer.BackgroundTransparency = 1
buttonContainer.ClipsDescendants = true
buttonContainer.ZIndex = 6
buttonContainer.Parent = dock

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = buttonContainer

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)
layout.Parent = buttonContainer

local sectionButtons = {}
local navigationItems = {}
local windows = {}
local windowByName = {}
local windowSectionByName = {}
local windowTweens = {}
local windowScaleTweens = {}
local windowOpenPositions = {}
local windowSizeConstraints = {}
local windowBaseZIndex = {}
local focusedWindowOrder = {}
local customCommands = {}
local activeKey = nil
local refreshUsersPresence
local refreshServers
local activeDrag = nil
local dragInertia = nil
local activeResize = nil
local commandBar
local commandBarTween
local transitionToken = 0
local baseDockWidth = 220
local sectionTitleTween
local sectionTitleToken = 0

local sectionTitleLabel = Instance.new("TextLabel")
sectionTitleLabel.Name = "ActiveSectionTitle"
sectionTitleLabel.AnchorPoint = Vector2.new(0.5, 1)
sectionTitleLabel.Position = UDim2.new(0.5, 0, 1, -76)
sectionTitleLabel.Size = UDim2.fromOffset(360, 34)
sectionTitleLabel.BackgroundTransparency = 1
sectionTitleLabel.BorderSizePixel = 0
sectionTitleLabel.Font = Enum.Font.GothamBlack
sectionTitleLabel.Text = ""
sectionTitleLabel.TextColor3 = colors.white
sectionTitleLabel.TextSize = 24
sectionTitleLabel.TextTransparency = 1
sectionTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
sectionTitleLabel.TextYAlignment = Enum.TextYAlignment.Center
sectionTitleLabel.Visible = false
sectionTitleLabel.ZIndex = 20
sectionTitleLabel.Parent = root

local function stopSectionTitle()
	sectionTitleToken = sectionTitleToken + 1
	if sectionTitleTween then
		sectionTitleTween:Cancel()
		sectionTitleTween = nil
	end
	if sectionTitleLabel.Parent then
		sectionTitleLabel.Visible = false
		sectionTitleLabel.TextTransparency = 1
	end
end

local function showSectionTitle(key)
	local title
	for _, section in ipairs(sections) do
		if section.key == key then
			title = section.title
			break
		end
	end
	if not title then
		return
	end

	sectionTitleToken = sectionTitleToken + 1
	local token = sectionTitleToken
	if sectionTitleTween then
		sectionTitleTween:Cancel()
	end
	sectionTitleLabel.Text = title
	sectionTitleLabel.Visible = true
	sectionTitleLabel.TextTransparency = 1

	local fadeIn = TweenService:Create(
		sectionTitleLabel,
		TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ TextTransparency = 0 }
	)
	sectionTitleTween = fadeIn
	fadeIn.Completed:Connect(function(state)
		if state ~= Enum.PlaybackState.Completed or sectionTitleToken ~= token then
			return
		end
		task.delay(3, function()
			if sectionTitleToken ~= token or not sectionTitleLabel.Parent then
				return
			end
			local fadeOut = TweenService:Create(
				sectionTitleLabel,
				TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TextTransparency = 1 }
			)
			sectionTitleTween = fadeOut
			fadeOut.Completed:Connect(function(outState)
				if outState == Enum.PlaybackState.Completed and sectionTitleToken == token then
					sectionTitleLabel.Visible = false
					sectionTitleTween = nil
				end
			end)
			fadeOut:Play()
		end)
	end)
	fadeIn:Play()
end

local function playBarEntrance()
	local targetPosition = UDim2.new(0.5, 0, 1, -14)
	local barTween = TweenService:Create(
		bar,
		TweenInfo.new(0.46, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Position = targetPosition,
			Size = UDim2.fromOffset(baseDockWidth + 18, 56),
		}
	)
	barTween:Play()
	local dockTween = TweenService:Create(
		dock,
		TweenInfo.new(0.46, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = UDim2.fromOffset(baseDockWidth, 48) }
	)
	dockTween:Play()
end

local function stopWindowTween(key)
	local tween = windowTweens[key]
	if tween then
		tween:Cancel()
		windowTweens[key] = nil
	end
	local scaleTween = windowScaleTweens[key]
	if scaleTween then
		scaleTween:Cancel()
		windowScaleTweens[key] = nil
	end
end

local function windowButtonPosition(key)
	local button = sectionButtons[key]
	if not button then
		return UDim2.new(0.5, 0, 1, -38)
	end
	local absolute = button.AbsolutePosition
	local size = button.AbsoluteSize
	return UDim2.fromOffset(absolute.X + size.X / 2, absolute.Y + size.Y / 2)
end

local function clampWindowPosition(window, position, sizeOverride)
	local viewport = root.AbsoluteSize
	local size = sizeOverride or window.AbsoluteSize
	if not sizeOverride then
		local scaleController = window:FindFirstChildOfClass("UIScale")
		if scaleController and scaleController.Scale > 0 then
			size = size / scaleController.Scale
		end
	end
	if size.X >= viewport.X - 1 and size.Y >= viewport.Y - 1 then
		return position
	end
	local x = position.X.Scale * viewport.X + position.X.Offset
	local y = position.Y.Scale * viewport.Y + position.Y.Offset
	local margin = 16
	local minX = math.min(size.X / 2 + margin, viewport.X / 2)
	local maxX = math.max(viewport.X - size.X / 2 - margin, viewport.X / 2)
	local minY = math.min(size.Y / 2 + margin, viewport.Y / 2)
	local maxY = math.max(viewport.Y - size.Y / 2 - margin, viewport.Y / 2)
	return UDim2.fromOffset(
		math.clamp(x, minX, maxX),
		math.clamp(y, minY, maxY)
	)
end

local function refreshWindowSizeConstraints()
	local viewport = root.AbsoluteSize
	local available = Vector2.new(
		math.max(1, viewport.X - 32),
		math.max(1, viewport.Y - 120)
	)
	for window, record in pairs(windowSizeConstraints) do
		if window.Parent and record.constraint.Parent then
			local maximum = Vector2.new(
				math.min(record.maximum.X, available.X),
				math.min(record.maximum.Y, available.Y)
			)
			record.constraint.MaxSize = maximum
			record.constraint.MinSize = Vector2.new(
				math.min(record.minimum.X, maximum.X),
				math.min(record.minimum.Y, maximum.Y)
			)
		end
	end
end

local function setWindowZIndex(window, targetZIndex)
	local delta = targetZIndex - window.ZIndex
	if delta == 0 then
		return
	end
	for _, descendant in ipairs(window:GetDescendants()) do
		if descendant:IsA("GuiObject") then
			descendant.ZIndex = math.max(1, descendant.ZIndex + delta)
		end
	end
	window.ZIndex = targetZIndex
end

local function focusWindow(window)
	for index = #focusedWindowOrder, 1, -1 do
		if focusedWindowOrder[index] == window then
			table.remove(focusedWindowOrder, index)
		end
	end
	table.insert(focusedWindowOrder, window)
	for index, focused in ipairs(focusedWindowOrder) do
		setWindowZIndex(focused, 40 + index * 20)
	end
end

local function resetWindowFocus(sectionKey)
	table.clear(focusedWindowOrder)
	for _, window in ipairs(windows[sectionKey] or {}) do
		setWindowZIndex(window, windowBaseZIndex[window])
	end
end

local function animateWindow(key, opening, destination)
	local window = windowByName[key]
	if not window then
		return nil
	end
	local scaleController = window:FindFirstChildOfClass("UIScale")
	if not scaleController then
		return nil
	end
	stopWindowTween(key)
	local isCommandWindow = windowSectionByName[key] == "commands"
	if opening then
		local spawnPosition = windowButtonPosition(windowSectionByName[key])
		if isCommandWindow and commandBar then
			spawnPosition = UDim2.fromOffset(
				root.AbsoluteSize.X / 2,
				18 + commandBar.AbsoluteSize.Y / 2
			)
		end
		window.Position = spawnPosition
		scaleController.Scale = 0.08
		if window:IsA("CanvasGroup") then
			window.GroupTransparency = 1
		end
		window.Visible = true
	end

	local sectionKeyForDuration = windowSectionByName[key]
	local duration = (sectionKeyForDuration == "users" or sectionKeyForDuration == "servers") and 0.36 or 0.24
	if not opening then
		duration = duration * 0.5
	end
	local scaleTween = TweenService:Create(
		scaleController,
		TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Scale = opening and 1 or 0.08 }
	)
	windowScaleTweens[key] = scaleTween
	scaleTween.Completed:Connect(function()
		if windowScaleTweens[key] == scaleTween then
			windowScaleTweens[key] = nil
		end
	end)
	scaleTween:Play()

	local tweenProperties = {
		Position = destination,
	}
	if window:IsA("CanvasGroup") then
		tweenProperties.GroupTransparency = opening and 0 or 1
	end
	local tween = TweenService:Create(
		window,
		TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		tweenProperties
	)
	windowTweens[key] = tween
	tween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed and not opening then
			window.Visible = false
		end
		if windowTweens[key] == tween then
			windowTweens[key] = nil
		end
	end)
	tween:Play()
	return tween
end

local function commandBarSize()
	return UDim2.fromOffset(math.max(80, math.min(330, root.AbsoluteSize.X - 32)), 38)
end

local function animateCommandBar(show)
	if not commandBar then
		return nil
	end
	if commandBarTween then
		commandBarTween:Cancel()
		commandBarTween = nil
	end

	if show then
		commandBar.Visible = true
		commandBar.Position = UDim2.new(0.5, 0, 0, -44)
		commandBar.Size = commandBarSize()
		commandBar.GroupTransparency = 1
	end

	local tween = TweenService:Create(
		commandBar,
		TweenInfo.new(show and 0.24 or 0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Position = show and UDim2.new(0.5, 0, 0, 18) or UDim2.new(0.5, 0, 0, -44),
			Size = commandBarSize(),
			GroupTransparency = show and 0 or 1,
		}
	)
	commandBarTween = tween
	tween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed and not show then
			commandBar.Visible = false
		end
		if commandBarTween == tween then
			commandBarTween = nil
		end
	end)
	tween:Play()
	return tween
end

local function closeSectionVisual(key, token, onClosed)
	local function finish()
		if transitionToken == token and onClosed then
			onClosed()
		end
	end

	local sectionWindows = windows[key] or {}
	if #sectionWindows == 0 and key ~= "commands" then
		finish()
		return
	end

	local remaining = #sectionWindows
	if key == "commands" then
		remaining = remaining + 1
		local commandTween = animateCommandBar(false)
		if commandTween then
			commandTween.Completed:Connect(function(state)
				if state == Enum.PlaybackState.Completed then
					remaining = remaining - 1
					if remaining == 0 then
						finish()
					end
				end
			end)
		else
			remaining = remaining - 1
		end
	end
	for _, window in ipairs(sectionWindows) do
		local destination = windowButtonPosition(key)
		if key == "commands" and commandBar then
			destination = UDim2.fromOffset(
				root.AbsoluteSize.X / 2,
				-44 + commandBar.AbsoluteSize.Y / 2
			)
		end
		local tween = animateWindow(window.Name, false, destination)
		if tween then
			tween.Completed:Connect(function(state)
				if state == Enum.PlaybackState.Completed then
					remaining = remaining - 1
					if remaining == 0 then
						finish()
					end
				end
			end)
		else
			remaining = remaining - 1
		end
	end
	if remaining == 0 then
		finish()
	end
end

local function openSectionVisual(key)
	resetWindowFocus(key)
	if key == "commands" then
		local token = transitionToken
		animateCommandBar(true)
		if activeKey ~= key or transitionToken ~= token then
			return
		end
		for _, window in ipairs(windows[key] or {}) do
			local destination = windowOpenPositions[window.Name] or window.Position
			animateWindow(window.Name, true, destination)
		end
		return
	end

	if key == "users" and refreshUsersPresence then
		task.spawn(refreshUsersPresence)
	end
	if key == "servers" and refreshServers then
		task.spawn(refreshServers)
	end
	for index, window in ipairs(windows[key] or {}) do
		local destination = windowOpenPositions[window.Name]
			or UDim2.new(index == 1 and 0.28 or 0.72, 0, 0.48, 0)
		animateWindow(window.Name, true, destination)
	end
end

local function setNavigationVisual(key, mode)
	local item = navigationItems[key]
	if not item then
		return
	end

	item.mode = mode
	item.pulseToken = item.pulseToken + 1
	local token = item.pulseToken
	local palette = mode == "active"
		and { colors.cyan, colors.activePink }
		or (mode == "hover" and { colors.hoverCyan, colors.hoverPink } or { colors.white })

	task.spawn(function()
		local colorIndex = 1
		while gui.Parent and item.pulseToken == token and item.mode == mode do
			local pulse = TweenService:Create(
				item.button,
				TweenInfo.new(mode == "idle" and 0.16 or 0.62, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ ImageColor3 = palette[colorIndex] }
			)
			pulse:Play()
			pulse.Completed:Wait()
			colorIndex = colorIndex % #palette + 1
		end
	end)
end

local function refreshNavigationVisuals()
	for key, item in pairs(navigationItems) do
		local mode = key == activeKey and "active" or (item.hovered and "hover" or "idle")
		setNavigationVisual(key, mode)
	end
end

local function closeActiveSection()
	if not activeKey then
		return
	end
	activeDrag = nil
	dragInertia = nil
	activeResize = nil
	transitionToken = transitionToken + 1
	local token = transitionToken
	local key = activeKey
	activeKey = nil
	closeSectionVisual(key, token)
	refreshNavigationVisuals()
	setBackdrop(false)
end

local function setActiveSection(key)
	if activeKey == key then
		closeActiveSection()
		return
	end

	if key == "users" or key == "servers" then
		stopSectionTitle()
	else
		showSectionTitle(key)
	end
	activeDrag = nil
	dragInertia = nil
	activeResize = nil
	transitionToken = transitionToken + 1
	local token = transitionToken
	local previousKey = activeKey
	activeKey = key
	refreshNavigationVisuals()
	if not previousKey then
		setBackdrop(true)
	end

	local function openNext()
		if transitionToken == token and activeKey == key then
			openSectionVisual(key)
		end
	end

	if previousKey then
		closeSectionVisual(previousKey, token, openNext)
	else
		openNext()
	end
end

local function createWindow(section, suffix, title, index)
	local windowKey = section.key .. suffix
	local window = Instance.new("CanvasGroup")
	window.Name = windowKey
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	local defaultPosition = UDim2.new(index == 1 and 0.28 or 0.72, 0, 0.48, 0)
	window.Position = defaultPosition
	window.Size = UDim2.new(0.4, 0, 0.58, 0)
	window.BackgroundColor3 = section.key == "commands" and colors.commandPink or colors.black
	window.BackgroundTransparency = 0
	window.BorderSizePixel = 0
	window.GroupTransparency = 1
	window.Visible = false
	window.ZIndex = 10 + index
	windowBaseZIndex[window] = window.ZIndex
	window.Active = true
	window.ClipsDescendants = false
	window.Parent = root
	windowByName[windowKey] = window
	windowSectionByName[windowKey] = section.key
	corner(window, 24)
	addBlurShadow(window, 22, colors.black, 0.36, UDim2.new(0, 0, 0, 0))
	addBottomContour(window, windowKey .. "BottomContour", 18)
	local windowScale = Instance.new("UIScale")
	windowScale.Name = "WindowScale"
	windowScale.Scale = 1
	windowScale.Parent = window

	local bottomGlow = Instance.new("Frame")
	bottomGlow.Name = "BottomWhiteGlow"
	bottomGlow.Position = UDim2.new(0, 0, 0.62, 0)
	bottomGlow.Size = UDim2.new(1, 0, 0.38, 0)
	bottomGlow.BackgroundColor3 = colors.white
	bottomGlow.BackgroundTransparency = 0
	bottomGlow.BorderSizePixel = 0
	bottomGlow.ZIndex = window.ZIndex
	bottomGlow.Parent = window
	corner(bottomGlow, 24)
	local bottomGlowGradient = Instance.new("UIGradient")
	bottomGlowGradient.Rotation = 90
	bottomGlowGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.65, 0.99),
		NumberSequenceKeypoint.new(1, 0.9),
	})
	bottomGlowGradient.Parent = bottomGlow

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(360, 280)
	sizeConstraint.MaxSize = Vector2.new(900, 680)
	sizeConstraint.Parent = window
	windowSizeConstraints[window] = {
		constraint = sizeConstraint,
		minimum = Vector2.new(360, 280),
		maximum = Vector2.new(900, 680),
	}
	refreshWindowSizeConstraints()

	local resizeCorners = {
		{ name = "ResizeTopLeft", x = 0, y = 0, horizontal = -1, vertical = -1 },
		{ name = "ResizeTopRight", x = 1, y = 0, horizontal = 1, vertical = -1 },
		{ name = "ResizeBottomLeft", x = 0, y = 1, horizontal = -1, vertical = 1 },
		{ name = "ResizeBottomRight", x = 1, y = 1, horizontal = 1, vertical = 1 },
	}
	for _, spec in ipairs(resizeCorners) do
		local handle = Instance.new("Frame")
		handle.Name = spec.name
		handle.AnchorPoint = Vector2.new(spec.x, spec.y)
		handle.Position = UDim2.new(spec.x, spec.x == 0 and 5 or -5, spec.y, spec.y == 0 and 5 or -5)
		handle.Size = UDim2.fromOffset(24, 24)
		handle.BackgroundTransparency = 1
		handle.BorderSizePixel = 0
		handle.Active = true
		handle.ZIndex = window.ZIndex + 5
		handle.Parent = window
		corner(handle, 7)
		connect(handle.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				focusWindow(window)
				activeDrag = nil
				dragInertia = nil
				local windowPosition = window.AbsolutePosition - root.AbsolutePosition
				local windowCenter = windowPosition + window.AbsoluteSize / 2
				activeResize = {
					window = window,
					start = input.Position,
					position = UDim2.fromOffset(windowCenter.X, windowCenter.Y),
					size = UDim2.fromOffset(window.AbsoluteSize.X, window.AbsoluteSize.Y),
					targetPosition = UDim2.fromOffset(windowCenter.X, windowCenter.Y),
					targetSize = UDim2.fromOffset(window.AbsoluteSize.X, window.AbsoluteSize.Y),
					absoluteSize = window.AbsoluteSize,
					horizontal = spec.horizontal,
					vertical = spec.vertical,
					minimum = sizeConstraint.MinSize,
					maximum = sizeConstraint.MaxSize,
					releasePending = false,
				}
			end
		end)
	end

	connect(window.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		focusWindow(window)
		if activeResize and activeResize.window == window then
			return
		end
		local absolutePosition = window.AbsolutePosition
		local localX = input.Position.X - absolutePosition.X
		local localY = input.Position.Y - absolutePosition.Y
		local resizeMargin = 30
		local nearHorizontalEdge = localX <= resizeMargin
			or localX >= window.AbsoluteSize.X - resizeMargin
		local nearVerticalEdge = localY <= resizeMargin
			or localY >= window.AbsoluteSize.Y - resizeMargin
		if nearHorizontalEdge and nearVerticalEdge then
			return
		end
		activeDrag = {
			window = window,
			input = input,
			start = input.Position,
			position = window.Position,
			target = window.Position,
			velocity = Vector2.zero,
			lastPointer = input.Position,
			lastUpdate = os.clock(),
		}
		dragInertia = nil
	end)

	window.Position = defaultPosition
	windowOpenPositions[window.Name] = defaultPosition

	return window
end

local function addWindowPair(section, firstTitle, secondTitle)
	local first = createWindow(section, "Primary", firstTitle, 1)
	local second = createWindow(section, "Secondary", secondTitle, 2)
	windows[section.key] = { first, second }
	return first, second
end

local function addCommandWindows(section)
	local recent = createWindow(section, "Recent", "", 1)
	local library = createWindow(section, "Library", "", 2)
	local custom = createWindow(section, "Custom", "", 3)
	local viewport = root.AbsoluteSize

	local specs = {
		{ window = recent, x = 0.265, width = 0.22, height = 0.49, top = 70, minimum = Vector2.new(230, 250), maximum = Vector2.new(500, 560) },
		{ window = library, x = 0.5, width = 0.24, height = 0.55, top = 62, minimum = Vector2.new(280, 300), maximum = Vector2.new(580, 640) },
		{ window = custom, x = 0.735, width = 0.22, height = 0.49, top = 70, minimum = Vector2.new(230, 250), maximum = Vector2.new(500, 560) },
	}

	for _, spec in ipairs(specs) do
		local window = spec.window
		local record = windowSizeConstraints[window]
		record.minimum = spec.minimum
		record.maximum = spec.maximum
		window.Size = UDim2.new(spec.width, 0, spec.height, 0)
		window.Position = UDim2.new(
			spec.x,
			0,
			0,
			spec.top + viewport.Y * spec.height / 2
		)
	end
	refreshWindowSizeConstraints()
	for _, spec in ipairs(specs) do
		windowOpenPositions[spec.window.Name] = clampWindowPosition(spec.window, spec.window.Position)
	end
	windows[section.key] = { recent, library, custom }
	return recent, library, custom
end

local function buildCommandsPanels(commandWindow, recentWindow, customWindow, commandInput)
	local function makeHorizontalScroller(parent, name, position, size)
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = name
		scroll.Position = position
		scroll.Size = size
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 4
		scroll.ScrollBarImageColor3 = colors.border
		scroll.ScrollBarImageTransparency = 0.25
		scroll.CanvasSize = UDim2.new()
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.X
		scroll.ScrollingDirection = Enum.ScrollingDirection.X
		scroll.Active = true
		scroll.ZIndex = parent.ZIndex + 1
		scroll.Parent = parent

		local row = Instance.new("UIListLayout")
		row.FillDirection = Enum.FillDirection.Horizontal
		row.HorizontalAlignment = Enum.HorizontalAlignment.Left
		row.VerticalAlignment = Enum.VerticalAlignment.Center
		row.SortOrder = Enum.SortOrder.LayoutOrder
		row.Padding = UDim.new(0, 8)
		row.Parent = scroll
		return scroll
	end

	local commandTitle = label(commandWindow, "COMMAND LIBRARY", UDim2.fromOffset(18, 14), UDim2.new(1, -36, 0, 26), 16, colors.white, Enum.Font.GothamBlack)
	commandTitle.ZIndex = commandWindow.ZIndex + 1
	local commandSearch = makeInput(
		commandWindow,
		"Search commands...",
		UDim2.fromOffset(18, 48),
		UDim2.new(1, -36, 0, 34)
	)
	commandSearch.TextSize = 12
	commandSearch.ZIndex = commandWindow.ZIndex + 1

	local filterTitle = label(commandWindow, "FILTER", UDim2.fromOffset(18, 91), UDim2.new(1, -36, 0, 16), 10, colors.muted, Enum.Font.GothamSemibold)
	filterTitle.ZIndex = commandWindow.ZIndex + 1
	local customFilter = makeButton(
		commandWindow,
		"Custom",
		UDim2.fromOffset(18, 111),
		UDim2.fromOffset(82, 27),
		true
	)
	customFilter.Name = "CustomCommandFilter"
	customFilter.BackgroundColor3 = colors.commandCyan
	customFilter.TextColor3 = colors.white
	customFilter.TextSize = 11
	customFilter.ZIndex = commandWindow.ZIndex + 1
	local customFilterCorner = customFilter:FindFirstChildOfClass("UICorner")
	if customFilterCorner then
		customFilterCorner.CornerRadius = UDim.new(0, 14)
	end

	local commandList = makeHorizontalScroller(
		commandWindow,
		"CommandList",
		UDim2.fromOffset(18, 151),
		UDim2.new(1, -36, 1, -169)
	)
	local commandEmptyState = label(
		commandWindow,
		"No custom commands yet.",
		UDim2.new(0.5, 0, 0.64, 0),
		UDim2.new(1, -48, 0, 44),
		12,
		colors.muted
	)
	commandEmptyState.AnchorPoint = Vector2.new(0.5, 0.5)
	commandEmptyState.TextXAlignment = Enum.TextXAlignment.Center
	commandEmptyState.ZIndex = commandWindow.ZIndex + 2

	local function editDistance(first, second)
		first = first:lower()
		second = second:lower()
		local previous = {}
		for column = 1, #second + 1 do
			previous[column] = column - 1
		end
		for rowIndex = 1, #first do
			local current = { [1] = rowIndex }
			for column = 1, #second do
				local cost = first:sub(rowIndex, rowIndex) == second:sub(column, column) and 0 or 1
				current[column + 1] = math.min(
					current[column] + 1,
					previous[column + 1] + 1,
					previous[column] + cost
				)
			end
			previous = current
		end
		return previous[#second + 1]
	end

	local function commandMatchScore(command, query)
		if query == "" then
			return 0
		end
		local name = tostring(command.name or ""):lower()
		local description = tostring(command.description or ""):lower()
		local source = tostring(command.source or ""):lower()
		local nameStart = name:find(query, 1, true)
		if nameStart then
			return (nameStart - 1) / math.max(#name, 1) * 0.2
		end
		if description:find(query, 1, true) or source:find(query, 1, true) then
			return 0.22
		end
		return editDistance(query, name) / math.max(#query, #name, 1)
	end

	local function refreshCommandLibrary()
		for _, child in ipairs(commandList:GetChildren()) do
			if child.Name == "CustomCommandCard" then
				child:Destroy()
			end
		end

		local commandBarQuery = commandInput.Text:gsub("^%s*(.-)%s*$", "%1"):lower()
		local libraryQuery = commandSearch.Text:gsub("^%s*(.-)%s*$", "%1"):lower()
		local query = commandInput:IsFocused() and commandBarQuery
			or (libraryQuery ~= "" and libraryQuery or commandBarQuery)
		query = query:sub(1, 80)
		local matches = {}
		for _, command in ipairs(customCommands) do
			local score = commandMatchScore(command, query)
			if query == "" or score <= 0.72 then
				table.insert(matches, { command = command, score = score })
			end
		end
		table.sort(matches, function(a, b)
			if a.command.favorite ~= b.command.favorite then
				return a.command.favorite == true
			end
			if a.score == b.score then
				return a.command.name:lower() < b.command.name:lower()
			end
			return a.score < b.score
		end)

		for index, result in ipairs(matches) do
			local command = result.command
			local card = Instance.new("TextButton")
			card.Name = "CustomCommandCard"
			card.Size = UDim2.fromOffset(220, 76)
			card.BackgroundColor3 = colors.card
			card.BorderSizePixel = 0
			card.AutoButtonColor = false
			card.Text = ""
			card.LayoutOrder = index
			card.ClipsDescendants = true
			card.ZIndex = commandWindow.ZIndex + 2
			card.Parent = commandList
			corner(card, 14)
			local cardStroke = Instance.new("UIStroke")
			cardStroke.Color = colors.white
			cardStroke.Thickness = 1.5
			cardStroke.Transparency = 0.85
			cardStroke.Parent = card

			local cardHoverTween
			card.MouseEnter:Connect(function()
				if cardHoverTween then
					cardHoverTween:Cancel()
				end
				cardHoverTween = TweenService:Create(
					card,
					TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ BackgroundColor3 = colors.commandCyan }
				)
				cardHoverTween:Play()
				TweenService:Create(
					cardStroke,
					TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Transparency = 0.35 }
				):Play()
			end)
			card.MouseLeave:Connect(function()
				if cardHoverTween then
					cardHoverTween:Cancel()
				end
				cardHoverTween = TweenService:Create(
					card,
					TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ BackgroundColor3 = colors.card }
				)
				cardHoverTween:Play()
				TweenService:Create(
					cardStroke,
					TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Transparency = 0.85 }
				):Play()
			end)

			local sticker = Instance.new("ImageLabel")
			sticker.Name = "CommandSticker"
			sticker.Position = UDim2.fromOffset(10, 18)
			sticker.Size = UDim2.fromOffset(40, 40)
			sticker.BackgroundTransparency = 1
			sticker.Image = "rbxassetid://" .. command.icon
			sticker.ScaleType = Enum.ScaleType.Fit
			sticker.ZIndex = card.ZIndex + 1
			sticker.Parent = card

			local commandName = label(
				card,
				command.name,
				UDim2.fromOffset(60, 10),
				UDim2.new(1, -104, 0, 24),
				13,
				colors.white,
				Enum.Font.GothamBold
			)
			commandName.ZIndex = card.ZIndex + 1
			commandName.TextWrapped = false
			commandName.TextTruncate = Enum.TextTruncate.AtEnd
			local commandDescription = label(
				card,
				command.description,
				UDim2.fromOffset(60, 36),
				UDim2.new(1, -104, 0, 28),
				11,
				colors.muted
			)
			commandDescription.ZIndex = card.ZIndex + 1
			commandDescription.TextWrapped = false
			commandDescription.TextTruncate = Enum.TextTruncate.AtEnd

			local favoriteButton = Instance.new("TextButton")
			favoriteButton.Name = "FavoriteButton"
			favoriteButton.AnchorPoint = Vector2.new(1, 0.5)
			favoriteButton.Position = UDim2.new(1, -10, 0.5, 0)
			favoriteButton.Size = UDim2.fromOffset(30, 34)
			favoriteButton.BackgroundTransparency = 1
			favoriteButton.BorderSizePixel = 0
			favoriteButton.AutoButtonColor = false
			favoriteButton.Font = Enum.Font.GothamBold
			favoriteButton.Text = command.favorite and "★" or "☆"
			favoriteButton.TextColor3 = command.favorite and colors.white or colors.muted
			favoriteButton.TextSize = 23
			favoriteButton.ZIndex = card.ZIndex + 2
			favoriteButton.Parent = card
			favoriteButton.Activated:Connect(function()
				command.favorite = not command.favorite
				refreshCommandLibrary()
			end)

			card.Activated:Connect(function()
				commandInput.Text = command.name
				commandInput:CaptureFocus()
				commandInput.CursorPosition = #commandInput.Text + 1
			end)
		end

		commandEmptyState.Visible = #matches == 0
		if #matches == 0 then
			commandEmptyState.Text = query == ""
				and "No custom commands yet."
				or "No close custom commands match."
		end
	end
	connect(commandSearch:GetPropertyChangedSignal("Text"), refreshCommandLibrary)
	connect(commandInput:GetPropertyChangedSignal("Text"), refreshCommandLibrary)
	connect(customFilter.Activated, refreshCommandLibrary)

	local recentTitle = label(recentWindow, "RECENT COMMANDS", UDim2.fromOffset(18, 14), UDim2.new(1, -36, 0, 26), 16, colors.white, Enum.Font.GothamBlack)
	recentTitle.ZIndex = recentWindow.ZIndex + 1
	local recentList = makeHorizontalScroller(
		recentWindow,
		"RecentCommandList",
		UDim2.fromOffset(18, 48),
		UDim2.new(1, -36, 1, -66)
	)
	recentList.ScrollBarThickness = 0
	local recentEmptyState = label(
		recentWindow,
		"No commands have been executed in this session.",
		UDim2.fromOffset(2, 0),
		UDim2.new(1, -4, 1, -4),
		11,
		colors.muted
	)
	recentEmptyState.TextXAlignment = Enum.TextXAlignment.Center
	recentEmptyState.ZIndex = recentWindow.ZIndex + 2
	recentEmptyState.Parent = recentList

	local customTitle = label(customWindow, "ADD CUSTOM COMMAND", UDim2.fromOffset(18, 14), UDim2.new(1, -36, 0, 26), 16, colors.white, Enum.Font.GothamBlack)
	customTitle.ZIndex = customWindow.ZIndex + 1

	local customForm = Instance.new("Frame")
	customForm.Name = "CustomCommandForm"
	customForm.Position = UDim2.fromOffset(12, 48)
	customForm.Size = UDim2.new(1, -24, 1, -60)
	customForm.BackgroundTransparency = 1
	customForm.BorderSizePixel = 0
	customForm.Visible = true
	customForm.Active = false
	customForm.ZIndex = customWindow.ZIndex + 10
	customForm.Parent = customWindow

	local nameInput = makeInput(customForm, "Command name", UDim2.fromOffset(16, 12), UDim2.new(1, -32, 0, 32))
	local descriptionInput = makeInput(customForm, "Description", UDim2.fromOffset(16, 50), UDim2.new(1, -32, 0, 32))
	local stickerInput = makeInput(customForm, "Sticker asset ID", UDim2.fromOffset(16, 88), UDim2.new(1, -32, 0, 32))
	nameInput.ZIndex = customForm.ZIndex + 1
	descriptionInput.ZIndex = customForm.ZIndex + 1
	stickerInput.ZIndex = customForm.ZIndex + 1

	local sourceNotice = label(
		customForm,
		"Lua source is saved as text only; it is not executed.",
		UDim2.fromOffset(16, 123),
		UDim2.new(1, -32, 0, 16),
		10,
		colors.muted
	)
	sourceNotice.ZIndex = customForm.ZIndex + 1

	local sourceInput = Instance.new("TextBox")
	sourceInput.Name = "LuaSource"
	sourceInput.Position = UDim2.fromOffset(16, 142)
	sourceInput.Size = UDim2.new(1, -32, 1, -196)
	sourceInput.BackgroundColor3 = colors.card
	sourceInput.BorderSizePixel = 0
	sourceInput.ClearTextOnFocus = false
	sourceInput.Font = Enum.Font.Code
	sourceInput.MultiLine = true
	sourceInput.PlaceholderText = "Lua source"
	sourceInput.PlaceholderColor3 = colors.muted
	sourceInput.Text = ""
	sourceInput.TextColor3 = colors.white
	sourceInput.TextSize = 12
	sourceInput.TextWrapped = false
	sourceInput.TextXAlignment = Enum.TextXAlignment.Left
	sourceInput.TextYAlignment = Enum.TextYAlignment.Top
	sourceInput.ZIndex = customForm.ZIndex + 1
	sourceInput.Parent = customForm
	corner(sourceInput, 9)
	local sourcePadding = Instance.new("UIPadding")
	sourcePadding.PaddingLeft = UDim.new(0, 10)
	sourcePadding.PaddingRight = UDim.new(0, 8)
	sourcePadding.PaddingTop = UDim.new(0, 8)
	sourcePadding.Parent = sourceInput

	local formError = label(
		customForm,
		"",
		UDim2.new(0, 16, 1, -18),
		UDim2.new(1, -190, 0, 26),
		10,
		colors.dnd
	)
	formError.AnchorPoint = Vector2.new(0, 1)
	formError.Position = UDim2.new(0, 16, 1, -18)
	formError.ZIndex = customForm.ZIndex + 1

	local saveButton = makeButton(
		customForm,
		"Save",
		UDim2.new(1, -92, 1, -18),
		UDim2.fromOffset(76, 30),
		true
	)
	saveButton.AnchorPoint = Vector2.new(0, 1)
	saveButton.ZIndex = customForm.ZIndex + 1

	connect(saveButton.Activated, function()
		local name = nameInput.Text:gsub("^%s*(.-)%s*$", "%1")
		local description = descriptionInput.Text:gsub("^%s*(.-)%s*$", "%1")
		local icon = stickerInput.Text:match("^%s*(%d+)%s*$")
		local source = sourceInput.Text
		if name == "" or description == "" or not icon or source:gsub("%s", "") == "" then
			formError.Text = "Complete every field and use a numeric sticker ID."
			return
		end

		table.insert(customCommands, {
			name = name,
			description = description,
			icon = icon,
			source = source,
		})
		nameInput.Text = ""
		descriptionInput.Text = ""
		stickerInput.Text = ""
		sourceInput.Text = ""
		formError.Text = ""
		refreshCommandLibrary()
	end)

	refreshCommandLibrary()
end

local function _addTabRow(parent, options, y)
	local tabs = {}
	local gap = 0.012
	local width = (1 - gap * (#options - 1)) / #options
	for index, option in ipairs(options) do
		tabs[index] = makeButton(
			parent,
			option,
			UDim2.new((index - 1) * (width + gap), 0, 0, y),
			UDim2.new(width, 0, 0, 26),
			index == 1
		)
	end
	return tabs
end

local function buildUsers(section)
	local usersArea = Instance.new("Frame")
	usersArea.Name = "UsersCardsArea"
	usersArea.AnchorPoint = Vector2.new(0.5, 0.5)
	usersArea.Position = UDim2.new(0.5, 0, 0.5, 40)
	usersArea.Size = UDim2.fromScale(1, 1)
	usersArea.BackgroundTransparency = 1
	usersArea.BorderSizePixel = 0
	usersArea.Visible = false
	usersArea.ZIndex = 10
	usersArea.Parent = root
	usersArea.Active = false
	local usersScale = Instance.new("UIScale")
	usersScale.Name = "WindowScale"
	usersScale.Parent = usersArea
	windowBaseZIndex[usersArea] = usersArea.ZIndex
	windowByName[usersArea.Name] = usersArea
	windowSectionByName[usersArea.Name] = section.key

	windowOpenPositions[usersArea.Name] = UDim2.new(0.5, 0, 0.5, 40)
	windows[section.key] = { usersArea }

	local usersToolbar = Instance.new("Frame")
	usersToolbar.Name = "UsersToolbar"
	usersToolbar.Position = UDim2.new(0, 0, 0, 94)
	usersToolbar.Size = UDim2.new(1, 0, 0, 32)
	usersToolbar.BackgroundTransparency = 1
	usersToolbar.ZIndex = usersArea.ZIndex + 1
	usersToolbar.Parent = usersArea

	local tabs = Instance.new("Frame")
	tabs.Name = "UserFilters"
	tabs.AnchorPoint = Vector2.new(1, 0)
	tabs.Position = UDim2.new(1, -24, 0, 0)
	tabs.Size = UDim2.fromOffset(234, 28)
	tabs.BackgroundColor3 = colors.black
	tabs.BackgroundTransparency = 0.72
	tabs.BorderSizePixel = 0
	tabs.ZIndex = usersToolbar.ZIndex
	tabs.Parent = usersToolbar
	corner(tabs, 16)
	local filterBubble = Instance.new("Frame")
	filterBubble.Name = "FilterBubble"
	filterBubble.Position = UDim2.fromOffset(82, 3)
	filterBubble.Size = UDim2.fromOffset(76, 22)
	filterBubble.BackgroundColor3 = colors.white
	filterBubble.BorderSizePixel = 0
	filterBubble.ZIndex = tabs.ZIndex
	filterBubble.Parent = tabs
	corner(filterBubble, 11)

	local filterTabs = {}
	local filterSpecs = {
		{ label = "In game", key = "In game", x = 0, width = 78 },
		{ label = "Flow users", key = "Flow users", x = 78, width = 84 },
		{ label = "Friends", key = "Friends", x = 162, width = 72 },
	}
	for index, spec in ipairs(filterSpecs) do
		local tab = Instance.new("TextButton")
		tab.Name = spec.key:gsub("%s+", "") .. "Filter"
		tab.Position = UDim2.fromOffset(spec.x, 0)
		tab.Size = UDim2.fromOffset(spec.width, 28)
		tab.BackgroundTransparency = 1
		tab.BorderSizePixel = 0
		tab.AutoButtonColor = false
		tab.Font = Enum.Font.GothamMedium
		tab.Text = spec.label
		tab.TextSize = 11
		tab.TextColor3 = index == 2 and colors.black or colors.white
		tab.ZIndex = tabs.ZIndex + 1
		tab.Parent = tabs
		filterTabs[index] = tab
	end

	local onlineCount = label(
		usersToolbar,
		"Loading Flow users...",
		UDim2.new(1, -626, 0, 4),
		UDim2.new(0, 94, 0, 22),
		10,
		colors.muted
	)
	onlineCount.TextXAlignment = Enum.TextXAlignment.Right
	onlineCount.TextSize = 13
	onlineCount.TextColor3 = colors.white
	onlineCount.ZIndex = usersToolbar.ZIndex + 1
	local search = makeInput(
		usersToolbar,
		"Search Flow users...",
		UDim2.new(1, -304, 0, 0),
		UDim2.fromOffset(260, 28)
	)
	search.AnchorPoint = Vector2.new(1, 0)
	search.BackgroundColor3 = colors.black
	search.BackgroundTransparency = 0.4
	search.TextSize = 13
	search.ZIndex = usersToolbar.ZIndex + 1
	local searchCorner = search:FindFirstChildOfClass("UICorner")
	if searchCorner then
		searchCorner.CornerRadius = UDim.new(0, 20)
	end
	local searchStroke = addBottomContour(search, "UsersSearchBottomContour", 14)
	searchStroke.Color = colors.border
	searchStroke.Thickness = 1
	searchStroke.Transparency = 0.42
	connect(search.Focused, function()
		TweenService:Create(searchStroke, TweenInfo.new(0.18), { Transparency = 0.08 }):Play()
		TweenService:Create(search, TweenInfo.new(0.18), { BackgroundTransparency = 0.18 }):Play()
	end)
	connect(search.FocusLost, function()
		TweenService:Create(searchStroke, TweenInfo.new(0.18), { Transparency = 0.42 }):Play()
		TweenService:Create(search, TweenInfo.new(0.18), { BackgroundTransparency = 0.4 }):Play()
	end)

	local list = makeScroll(usersArea, "FlowUsersList", UDim2.new(0, 0, 0, 136), UDim2.new(1, 0, 1, -266))
	list.ZIndex = usersArea.ZIndex + 1
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollBarThickness = 0
	list.ScrollBarImageTransparency = 1
	local usersListPadding = Instance.new("UIPadding")
	usersListPadding.PaddingLeft = UDim.new(0, 8)
	usersListPadding.PaddingRight = UDim.new(0, 8)
	usersListPadding.PaddingTop = UDim.new(0, 14)
	usersListPadding.PaddingBottom = UDim.new(0, 14)
	usersListPadding.Parent = list
	local usersGrid = Instance.new("UIGridLayout")
	usersGrid.FillDirection = Enum.FillDirection.Horizontal
	usersGrid.FillDirectionMaxCells = 3
	usersGrid.CellSize = UDim2.new(1 / 3, -10, 0, 116)
	usersGrid.CellPadding = UDim2.fromOffset(15, 14)
	usersGrid.SortOrder = Enum.SortOrder.LayoutOrder
	usersGrid.Parent = list
	local function fitUsersGrid()
		local viewHeight = list.AbsoluteSize.Y
		if viewHeight <= 0 then
			return
		end
		local columns = (UserInputService.TouchEnabled or list.AbsoluteSize.X < 560) and 2 or 3
		usersGrid.FillDirectionMaxCells = columns
		local cardHeight = math.clamp(math.floor((viewHeight - 56) / 3), 58, 116)
		usersGrid.CellSize = UDim2.new(1 / columns, -10, 0, cardHeight)
	end
	connect(list:GetPropertyChangedSignal("AbsoluteSize"), fitUsersGrid)
	task.defer(fitUsersGrid)

	local usersEmpty = label(
		usersArea,
		"Loading Flow users...",
		UDim2.new(0, 24, 0, 136),
		UDim2.new(1, -48, 1, -266),
		16,
		colors.muted
	)
	usersEmpty.TextXAlignment = Enum.TextXAlignment.Center
	usersEmpty.Font = Enum.Font.GothamMedium
	usersEmpty.TextSize = 16
	usersEmpty.TextColor3 = colors.white
	usersEmpty.TextTransparency = 1
	usersEmpty.TextStrokeColor3 = colors.black
	usersEmpty.TextStrokeTransparency = 0.35
	usersEmpty.Visible = false
	usersEmpty.ZIndex = usersArea.ZIndex + 3
	local usersEmptyScale = Instance.new("UIScale")
	usersEmptyScale.Scale = 0.96
	usersEmptyScale.Parent = usersEmpty

	local usersPerPage = 9
	local usersPageNumber = 1
	local usersTotalPages = 1
	local renderUsers
	local pageBar = Instance.new("Frame")
	pageBar.Name = "UsersPagination"
	pageBar.AnchorPoint = Vector2.new(0.5, 1)
	pageBar.Position = UDim2.new(0.5, 0, 1, -126)
	pageBar.Size = UDim2.new(1, -32, 0, 44)
	pageBar.BackgroundTransparency = 1
	pageBar.BorderSizePixel = 0
	pageBar.ZIndex = usersArea.ZIndex + 2
	pageBar.Parent = usersArea

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.FillDirection = Enum.FillDirection.Horizontal
	pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Padding = UDim.new(0, 6)
	pageLayout.Parent = pageBar

	local function makePageButton(text, order, width)
		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(width, 30)
		button.BackgroundColor3 = colors.black
		button.BackgroundTransparency = 0.72
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 12
		button.TextColor3 = colors.white
		button.Text = text
		button.LayoutOrder = order
		button.ZIndex = pageBar.ZIndex + 1
		button.Parent = pageBar
		corner(button, 15)
		addHoverScale(button, 1.08)
		return button
	end

	local function goToUsersPage(pageNumber)
		pageNumber = math.clamp(pageNumber, 1, usersTotalPages)
		if pageNumber == usersPageNumber then
			return
		end
		usersPageNumber = pageNumber
		list.CanvasPosition = Vector2.zero
		renderUsers(true)
	end

	local function rebuildUsersPagination(totalPages)
		usersTotalPages = totalPages
		for _, child in ipairs(pageBar:GetChildren()) do
			if child:IsA("GuiObject") and child ~= pageLayout then
				child:Destroy()
			end
		end

		local previous = makePageButton("‹", 1, 36)
		previous.Activated:Connect(function()
			goToUsersPage(usersPageNumber - 1)
		end)
		previous.TextTransparency = usersPageNumber <= 1 and 0.55 or 0

		local pageNumbers = {}
		if totalPages <= 7 then
			for pageNumber = 1, totalPages do
				pageNumbers[#pageNumbers + 1] = pageNumber
			end
		else
			pageNumbers = { 1 }
			local firstVisible = math.max(2, usersPageNumber - 1)
			local lastVisible = math.min(totalPages - 1, usersPageNumber + 1)
			if firstVisible > 2 then
				pageNumbers[#pageNumbers + 1] = "..."
			end
			for pageNumber = firstVisible, lastVisible do
				pageNumbers[#pageNumbers + 1] = pageNumber
			end
			if lastVisible < totalPages - 1 then
				pageNumbers[#pageNumbers + 1] = "..."
			end
			pageNumbers[#pageNumbers + 1] = totalPages
		end

		for index, pageNumber in ipairs(pageNumbers) do
			if pageNumber == "..." then
				local dots = label(
					pageBar,
					"…",
					UDim2.new(),
					UDim2.fromOffset(18, 30),
					12,
					colors.muted
				)
				dots.LayoutOrder = index + 1
				dots.ZIndex = pageBar.ZIndex + 1
			else
				local button = makePageButton(tostring(pageNumber), index + 1, 30)
				if pageNumber == usersPageNumber then
					button.BackgroundColor3 = colors.white
					button.BackgroundTransparency = 0
					button.TextColor3 = colors.black
				end
				local targetPage = pageNumber
				button.Activated:Connect(function()
					goToUsersPage(targetPage)
				end)
			end
		end

		local nextButton = makePageButton("›", 9999, 36)
		nextButton.Activated:Connect(function()
			goToUsersPage(usersPageNumber + 1)
		end)
		nextButton.TextTransparency = usersPageNumber >= totalPages and 0.55 or 0
	end

	connect(UserInputService.InputBegan, function(input, gameProcessed)
		if gameProcessed or activeKey ~= "users" or UserInputService:GetFocusedTextBox() then
			return
		end
		if input.KeyCode == Enum.KeyCode.Q then
			goToUsersPage(usersPageNumber - 1)
		elseif input.KeyCode == Enum.KeyCode.E then
			goToUsersPage(usersPageNumber + 1)
		end
	end)

	local selectedUser
	local currentFilter = "Flow users"
	local currentQuery = ""
	local animateUsersOnRender = true
	local lastSignature = nil
	local skipNextSignatureRender = false
	local flowUsersCache = type(_G.FlowUsersCache) == "table" and _G.FlowUsersCache or {}
	local friendsCache = type(_G.FlowFriendsCache) == "table" and _G.FlowFriendsCache or {}
	local presenceError = nil
	local presenceLoading = true
	local friendsError = nil
	local friendsLoading = true
	local friendsRefreshInProgress = false
	local function fitUsersToolbar()
		local width = usersToolbar.AbsoluteSize.X
		local compact = width < 900 or UserInputService.TouchEnabled
		local widths = compact and { 62, 70, 62 } or { 78, 84, 72 }
		local x = 0
		for index, spec in ipairs(filterSpecs) do
			spec.x = x
			spec.width = widths[index]
			filterTabs[index].Position = UDim2.fromOffset(x, 0)
			filterTabs[index].Size = UDim2.fromOffset(widths[index], 28)
			x = x + widths[index]
		end
		tabs.Size = UDim2.fromOffset(x, 28)

		local searchWidth = 260
		local rightOffset = 24 + x + 10
		if compact then
			searchWidth = math.clamp(width - rightOffset - 16, 110, 200)
			onlineCount.Visible = false
		else
			onlineCount.Visible = true
			onlineCount.Position = UDim2.new(1, -(rightOffset + searchWidth + 10 + 94), 0, 4)
		end
		search.Position = UDim2.new(1, -rightOffset, 0, 0)
		search.Size = UDim2.fromOffset(searchWidth, 28)

		local selectedIndex = 2
		for index, spec in ipairs(filterSpecs) do
			if spec.key == currentFilter then
				selectedIndex = index
				break
			end
		end
		local selectedSpec = filterSpecs[selectedIndex]
		filterBubble.Position = UDim2.fromOffset(selectedSpec.x + 4, 3)
		filterBubble.Size = UDim2.fromOffset(selectedSpec.width - 8, 22)
	end
	connect(root:GetPropertyChangedSignal("AbsoluteSize"), fitUsersToolbar)
	task.defer(fitUsersToolbar)

	local function fullAvatarThumbnail(data)
		if data and data.HideAvatar then
			local avatarId = tostring(data.AvatarId or "109728664560706"):match("%d+") or "109728664560706"
			return string.format("rbxthumb://type=Asset&id=%s&w=420&h=420", avatarId)
		end
		return string.format(
			"rbxthumb://type=AvatarHeadShot&id=%d&w=420&h=420",
			tonumber(data and data.UserId) or 0
		)
	end

	local function makeStatusBadge(photo)
		local ringColor = Color3.fromRGB(18, 18, 20)
		local badge = Instance.new("Frame")
		badge.Name = "StatusBadge"
		badge.Size = UDim2.fromOffset(22, 22)
		badge.AnchorPoint = Vector2.new(1, 1)
		badge.Position = UDim2.new(1, 4, 1, 3)
		badge.BackgroundColor3 = ringColor
		badge.BorderSizePixel = 0
		badge.ZIndex = photo.ZIndex + 1
		badge.Parent = photo
		corner(badge, 11)

		local disc = Instance.new("Frame")
		disc.Name = "StatusDisc"
		disc.Size = UDim2.fromOffset(14, 14)
		disc.AnchorPoint = Vector2.new(0.5, 0.5)
		disc.Position = UDim2.fromScale(0.5, 0.5)
		disc.BackgroundColor3 = Color3.fromRGB(35, 197, 89)
		disc.BorderSizePixel = 0
		disc.ZIndex = badge.ZIndex + 1
		disc.Parent = badge
		corner(disc, 7)

		local moon = Instance.new("Frame")
		moon.Name = "StatusMoon"
		moon.Size = UDim2.fromOffset(14, 14)
		moon.AnchorPoint = Vector2.new(0.5, 0.5)
		moon.Position = UDim2.fromScale(0.5, 0.5)
		moon.BackgroundColor3 = Color3.fromRGB(250, 201, 65)
		moon.BorderSizePixel = 0
		moon.Visible = false
		moon.ZIndex = badge.ZIndex + 1
		moon.Parent = badge
		corner(moon, 7)

		local moonCut = Instance.new("Frame")
		moonCut.Size = UDim2.fromOffset(13, 13)
		moonCut.AnchorPoint = Vector2.new(0.5, 0.5)
		moonCut.Position = UDim2.new(0, 12, 0, 7)
		moonCut.BackgroundColor3 = ringColor
		moonCut.BorderSizePixel = 0
		moonCut.ZIndex = moon.ZIndex + 1
		moonCut.Parent = moon
		corner(moonCut, 7)

		local dndBar = Instance.new("Frame")
		dndBar.Name = "StatusDndBar"
		dndBar.Size = UDim2.fromOffset(10, 3)
		dndBar.AnchorPoint = Vector2.new(0.5, 0.5)
		dndBar.Position = UDim2.fromScale(0.5, 0.5)
		dndBar.BackgroundColor3 = colors.white
		dndBar.BorderSizePixel = 0
		dndBar.Visible = false
		dndBar.ZIndex = badge.ZIndex + 2
		dndBar.Parent = badge
		corner(dndBar, 2)
		return badge
	end

	local function setStatusBadgeState(photo, state)
		local badge = photo:FindFirstChild("StatusBadge")
		if not badge then
			return
		end
		local disc = badge:FindFirstChild("StatusDisc")
		local moon = badge:FindFirstChild("StatusMoon")
		local dndBar = badge:FindFirstChild("StatusDndBar")
		if disc then
			disc.Visible = state == "online" or state == "dnd"
			disc.BackgroundColor3 = state == "dnd" and Color3.fromRGB(237, 66, 69) or Color3.fromRGB(35, 197, 89)
		end
		if moon then
			moon.Visible = state == "idle"
		end
		if dndBar then
			dndBar.Visible = state == "dnd"
		end
	end

	local function matchesCurrentQuery(data)
		local name = tostring(data.Name or data.DisplayName or data.UserName or "")
		return currentQuery == ""
			or name:lower():find(currentQuery:lower(), 1, true) ~= nil
			or tostring(data.UserId or ""):find(currentQuery, 1, true) ~= nil
	end

	local function getCurrentUsers()
		if currentFilter == "In game" then
			local items = {}
			for _, member in ipairs(Players:GetPlayers()) do
				local flowData = flowUsersCache[member.UserId]
				local data
				if type(flowData) == "table" then
					data = flowData
				else
					data = {
						UserId = member.UserId,
						Name = member.DisplayName ~= "" and member.DisplayName or member.UserName,
						UserName = member.UserName,
						DisplayName = member.DisplayName,
						GameName = game.Name ~= "" and game.Name or "Roblox",
						GameId = game.GameId,
						PlaceId = game.PlaceId,
						JobId = "",
						ServerLabel = "Same server",
						Players = #Players:GetPlayers(),
						MaxPlayers = Players.MaxPlayers,
						Badge = 0,
					}
				end
				if matchesCurrentQuery(data) then
					table.insert(items, data)
				end
			end
			table.sort(items, function(a, b)
				return tostring(a.Name or a.DisplayName or ""):lower() < tostring(b.Name or b.DisplayName or ""):lower()
			end)
			return items
		end

		local source = flowUsersCache
		if currentFilter == "Friends" then
			source = type(_G.FlowFriendsCache) == "table" and _G.FlowFriendsCache or friendsCache
		end
		if type(source) ~= "table" then
			return {}
		end
		local items = {}
		for _, data in pairs(source) do
			if type(data) == "table" then
				local samePlace = tonumber(data.PlaceId) == tonumber(game.PlaceId)
				local sameUniverse = tonumber(data.GameId) == tonumber(game.GameId)
				local sameGame = samePlace or sameUniverse
				local matchesQuery = matchesCurrentQuery(data)
				if (currentFilter ~= "In game" or sameGame) and matchesQuery then
					table.insert(items, data)
				end
			end
		end
		table.sort(items, function(a, b)
			return tostring(a.Name or a.DisplayName or ""):lower() < tostring(b.Name or b.DisplayName or ""):lower()
		end)
		return items
	end

	local function requestOnlineFriends()
		local options = {
			Url = string.format("https://friends.roblox.com/v1/users/%d/friends/online", player.UserId),
			Method = "GET",
			Headers = { Accept = "application/json" },
		}
		local requestOk, response = pcall(function()
			if type(request) == "function" then
				return request(options)
			elseif type(http_request) == "function" then
				return http_request(options)
			end
			return HttpService:RequestAsync(options)
		end)
		if not requestOk or type(response) ~= "table" then
			return nil, tostring(response or "HTTP request failed"):sub(1, 90)
		end
		local statusCode = tonumber(response.StatusCode or response.status_code)
		if response.Success == false or (statusCode and statusCode >= 400) then
			return nil, statusCode and ("HTTP " .. tostring(statusCode)) or "HTTP request failed"
		end
		local body = response.Body or response.body or ""
		if type(body) ~= "string" then
			return nil, "Invalid friends response"
		end
		local decodeOk, result = pcall(function()
			return HttpService:JSONDecode(body)
		end)
		if not decodeOk or type(result) ~= "table" or type(result.data) ~= "table" then
			return nil, "Invalid friends response"
		end
		return result.data, nil
	end

	local function fetchOnlineFriends()
		if friendsRefreshInProgress then
			return
		end
		friendsRefreshInProgress = true
		local bucket = {}
		local gotValidResponse = false
		local lastError = nil

		local function putFriend(entry)
			if type(entry) ~= "table" then
				return
			end
			local userId = tonumber(entry.UserId or entry.UserID or entry.VisitorId or entry.Id or entry.id)
			if not userId or userId <= 0 or userId == player.UserId then
				return
			end
			local userName = tostring(entry.UserName or entry.Username or entry.Name or entry.name or "")
			local displayName = tostring(entry.DisplayName or entry.displayName or userName)
			local location = tostring(entry.LastLocation or entry.lastLocation or entry.Location or "")
			bucket[userId] = {
				UserId = userId,
				Name = displayName ~= "" and displayName or userName,
				UserName = userName,
				DisplayName = displayName,
				GameName = location ~= "" and location or "Playing Roblox",
				GameId = tonumber(entry.GameId or entry.gameId or entry.RootPlaceId or entry.rootPlaceId) or 0,
				PlaceId = tonumber(entry.PlaceId or entry.placeId) or 0,
				JobId = tostring(entry.JobId or entry.jobId or ""),
			}
		end

		local onlineOk, online = pcall(function()
			return player:GetFriendsOnline(200)
		end)
		if onlineOk and type(online) == "table" then
			gotValidResponse = true
			for _, entry in pairs(online) do
				putFriend(entry)
			end
		else
			lastError = tostring(online):sub(1, 90)
		end

		if next(bucket) == nil then
			local pagesOk, pagesError = pcall(function()
				local pages = Players:GetFriendsAsync(player.UserId)
				while true do
					for _, entry in ipairs(pages:GetCurrentPage()) do
						if entry.IsOnline then
							putFriend(entry)
						end
					end
					if pages.IsFinished then
						break
					end
					pages:AdvanceToNextPageAsync()
				end
			end)
			if pagesOk then
				gotValidResponse = true
			else
				lastError = tostring(pagesError):sub(1, 90)
			end
		end

		if next(bucket) == nil then
			local entries, httpError = requestOnlineFriends()
			if entries then
				gotValidResponse = true
				for _, entry in ipairs(entries) do
					putFriend(entry)
				end
			elseif httpError then
				lastError = httpError
			end
		end

		if gotValidResponse then
			friendsCache = bucket
			_G.FlowFriendsCache = bucket
			friendsError = nil
		elseif lastError then
			friendsError = lastError
		end
		friendsLoading = false
		friendsRefreshInProgress = false
		lastSignature = nil
		skipNextSignatureRender = true
		renderUsers(true)
	end

	local function setSelected(data)
		selectedUser = data
	end

	local function addUserCardLabel(card, name, text, y, height, textSize, textColor, font)
		local textLabel = label(
			card,
			text,
			UDim2.fromOffset(88, y),
			UDim2.new(1, -100, 0, height),
			textSize,
			textColor,
			font
		)
		textLabel.Name = name
		textLabel.TextWrapped = false
		textLabel.TextTruncate = Enum.TextTruncate.AtEnd
		textLabel.ZIndex = card.ZIndex + 2
		return textLabel
	end

	renderUsers = function(animateCards)
		for _, child in ipairs(list:GetChildren()) do
			if child ~= usersGrid and child ~= usersListPadding then
				child:Destroy()
			end
		end

		local items = getCurrentUsers()
		local countLabel = "users"
		if currentFilter == "Friends" then
			countLabel = "friends online"
		elseif currentFilter == "In game" then
			countLabel = "players"
		end
		onlineCount.Text = tostring(#items) .. " " .. countLabel
		if #items == 0 then
			local entering = not usersEmpty.Visible
			usersEmpty.Visible = true
			if entering then
				usersEmpty.TextTransparency = 1
				usersEmptyScale.Scale = 0.96
				TweenService:Create(
					usersEmpty,
					TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ TextTransparency = 0.08 }
				):Play()
				TweenService:Create(
					usersEmptyScale,
					TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Scale = 1 }
				):Play()
			end
			usersPageNumber = 1
			rebuildUsersPagination(1)
			if currentFilter == "Friends" then
				if friendsLoading then
					usersEmpty.Text = "Loading online friends..."
				elseif friendsError then
					usersEmpty.Text = "Could not load online friends: " .. tostring(friendsError):sub(1, 90)
				else
					usersEmpty.Text = "No friends playing Roblox right now."
				end
			elseif presenceLoading then
				usersEmpty.Text = "Loading Flow users..."
			elseif presenceError then
				usersEmpty.Text = "Could not load Flow users: " .. tostring(presenceError):sub(1, 90)
			else
				usersEmpty.Text = "No active Flow users right now."
			end
			setSelected(nil)
			if not presenceLoading and not friendsLoading then
				animateUsersOnRender = false
			end
			return
		end

		usersEmpty.Visible = false
		local totalPages = math.max(1, math.ceil(#items / usersPerPage))
		usersPageNumber = math.clamp(usersPageNumber, 1, totalPages)
		rebuildUsersPagination(totalPages)
		local startIndex = (usersPageNumber - 1) * usersPerPage + 1
		local endIndex = math.min(#items, startIndex + usersPerPage - 1)
		local keepSelected = selectedUser and tonumber(selectedUser.UserId)
		local foundSelection = false
		for index = startIndex, endIndex do
			local order = index - startIndex + 1
			local data = items[index]
			local isFriend = currentFilter == "Friends"
			local gameId = tonumber(data.GameId) or 0
			local placeId = tonumber(data.PlaceId) or 0
			local bannerId = tostring(data.BannerId or "134918452547700"):match("%d+") or "134918452547700"
			local hideBanner = data.HideBanner or data.HideGame or gameId == 0
			local shownName = data.HideName
				and (tostring(data.CustomName or "") ~= "" and data.CustomName or "Hidden")
				or (data.Name or data.DisplayName or data.UserName or "?")
			local shownGame
			if data.HideGame then
				shownGame = "Hidden"
			else
				shownGame = tostring(data.GameName or data.GameId or "")
				if shownGame == "" or shownGame:lower() == "ugc" then
					shownGame = isFriend and "Roblox" or (game.Name ~= "" and game.Name or "Roblox")
				end
			end
			local playing = not data.HideGame and (gameId ~= 0 or placeId ~= 0)
			local status = isFriend and "online" or (data.DND and "dnd" or (playing and "online" or "idle"))

			local card = Instance.new("TextButton")
			card.Name = "FlowUser_" .. tostring(data.UserId or order)
			card.Size = UDim2.new(1 / 3, -10, 0, 116)
			card.BackgroundColor3 = colors.black
			card.BackgroundTransparency = 0.45
			card.BorderSizePixel = 0
			card.AutoButtonColor = false
			card.Text = ""
			card.LayoutOrder = order
			card.ClipsDescendants = false
			card.ZIndex = usersArea.ZIndex + 2
			card.Parent = list
			corner(card, 16)
			addBlurShadow(card, 6, colors.black, 0.3, UDim2.new(0, 0, 0, 1))

			local banner = Instance.new("ImageLabel")
			banner.Name = "GameBanner"
			banner.Size = UDim2.fromScale(1, 1)
			banner.BackgroundTransparency = 1
			banner.BorderSizePixel = 0
			banner.ScaleType = Enum.ScaleType.Crop
			banner.ImageColor3 = Color3.fromRGB(190, 190, 196)
			banner.ZIndex = card.ZIndex
			banner.Parent = card
			corner(banner, 16)
			if hideBanner then
				banner.Image = string.format("rbxthumb://type=Asset&id=%s&w=420&h=420", bannerId)
			else
				banner.Image = string.format("rbxthumb://type=GameIcon&id=%d&w=512&h=512", gameId)
			end
			local bannerLight = Instance.new("UIGradient")
			bannerLight.Rotation = 90
			bannerLight.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colors.white),
				ColorSequenceKeypoint.new(0.3, colors.white),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
			})
			bannerLight.Parent = banner

			local shade = Instance.new("Frame")
			shade.Size = UDim2.fromScale(1, 1)
			shade.BackgroundColor3 = colors.black
			shade.BackgroundTransparency = 0
			shade.BorderSizePixel = 0
			shade.ZIndex = card.ZIndex + 1
			shade.Parent = card
			corner(shade, 16)
			local shadeGradient = Instance.new("UIGradient")
			shadeGradient.Rotation = 90
			shadeGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colors.black),
				ColorSequenceKeypoint.new(0.55, colors.black),
				ColorSequenceKeypoint.new(1, colors.black),
			})
			shadeGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.58),
				NumberSequenceKeypoint.new(0.58, 0.74),
				NumberSequenceKeypoint.new(1, 0.82),
			})
			shadeGradient.Parent = shade

			local avatar = Instance.new("ImageLabel")
			avatar.Name = "Avatar"
			avatar.AnchorPoint = Vector2.new(0, 0.5)
			avatar.Position = UDim2.new(0, 22, 0.5, 0)
			avatar.Size = UDim2.fromOffset(56, 56)
			avatar.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
			avatar.BorderSizePixel = 0
			avatar.ScaleType = Enum.ScaleType.Crop
			avatar.ZIndex = card.ZIndex + 2
			avatar.Image = fullAvatarThumbnail(data)
			avatar.Parent = card
			corner(avatar, 28)
			local avatarStroke = Instance.new("UIStroke")
			avatarStroke.Color = colors.border
			avatarStroke.Transparency = 0.3
			avatarStroke.Thickness = 1.5
			avatarStroke.Parent = avatar
			makeStatusBadge(avatar)
			setStatusBadgeState(avatar, status)

			addUserCardLabel(
				card,
				"UserName",
				tostring(shownName),
				13,
				18,
				13,
				colors.white,
				Enum.Font.GothamSemibold
			)
			addUserCardLabel(
				card,
				"UserGame",
				shownGame,
				35,
				15,
				12,
				Color3.fromRGB(201, 204, 216)
			)
			local badgeValue = tonumber(data.Badge) or 0
			if badgeValue == 1 or badgeValue == 2 then
				local badgeLabel = Instance.new("TextLabel")
				badgeLabel.Name = "UserBadge"
				badgeLabel.BackgroundTransparency = 1
				badgeLabel.Size = UDim2.fromOffset(18, 18)
				badgeLabel.Position = UDim2.fromOffset(88, 12)
				badgeLabel.Font = Enum.Font.SourceSansBold
				badgeLabel.TextSize = 16
				badgeLabel.TextColor3 = colors.white
				badgeLabel.Text = badgeValue == 1 and string.char(0xEE, 0x80, 0x80) or string.char(0xEE, 0x80, 0x83)
				badgeLabel.ZIndex = card.ZIndex + 2
				badgeLabel.Parent = card
				pcall(function()
					local width = game:GetService("TextService"):GetTextSize(
						tostring(shownName),
						13,
						Enum.Font.GothamSemibold,
						Vector2.new(2000, 100)
					).X
					badgeLabel.Position = UDim2.fromOffset(88 + width + 4, 12)
				end)
			end

			local statsText
			if not isFriend then
				local playerCount = data.HidePlayers and "--/--" or (tostring(data.Players or 0) .. "/" .. tostring(data.MaxPlayers or 0))
				local ping = data.HidePing and "--" or tostring(data.Ping or "--") .. " ms"
				statsText = "Players: " .. playerCount .. " | Ping: " .. ping
			else
				statsText = "Online on Roblox"
			end
			addUserCardLabel(card, "UserStats", statsText, 54, 14, 11, Color3.fromRGB(201, 204, 216))

			local jobId = tostring(data.JobId or data.jobId or "")
			local updatedAt = tonumber(data.Since)
			if not updatedAt or updatedAt <= 0 then
				updatedAt = tonumber(data.UpdatedAt)
			end
			local elapsed = updatedAt and (os.time() - updatedAt) or nil
			local timeText = "--"
			if elapsed and elapsed >= 0 then
				if elapsed < 60 then
					timeText = string.format("%ds", elapsed)
				elseif elapsed < 3600 then
					timeText = string.format("%dm", math.floor(elapsed / 60))
				else
					timeText = string.format("%dh", math.floor(elapsed / 3600))
				end
			end
			local serverText = tostring(data.ServerLabel or "")
			if serverText == "" then
				serverText = jobId ~= "" and ("Job " .. jobId .. " · ") or ""
				serverText = serverText .. timeText
			end
			addUserCardLabel(card, "UserServer", serverText, 73, 14, 11, Color3.fromRGB(201, 204, 216))

			local stroke = Instance.new("UIStroke")
			stroke.Color = colors.border
			stroke.Transparency = 0.08
			stroke.Thickness = 1.4
			stroke.Parent = card
			local strokeGradient = Instance.new("UIGradient")
			strokeGradient.Rotation = 90
			strokeGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(0.75, 0.72),
				NumberSequenceKeypoint.new(1, 0.15),
			})
			strokeGradient.Parent = stroke

			local cardScale = addHoverScale(card, 1.035)
			card.MouseEnter:Connect(function()
				TweenService:Create(
					stroke,
					TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Color = colors.cyan, Transparency = 0.12 }
				):Play()
			end)
			card.MouseLeave:Connect(function()
				local selected = selectedUser and tonumber(selectedUser.UserId) == tonumber(data.UserId)
				TweenService:Create(
					stroke,
					TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Color = selected and colors.cyan or colors.border,
						Transparency = selected and 0.15 or 0.08,
					}
				):Play()
			end)

			local uid = tonumber(data.UserId)
			if uid and uid == keepSelected then
				foundSelection = true
				stroke.Transparency = 0.15
				stroke.Color = colors.cyan
			end
			card.Activated:Connect(function()
				setSelected(data)
				for _, item in ipairs(list:GetChildren()) do
					local itemStroke = item:FindFirstChildOfClass("UIStroke")
					if itemStroke then
						itemStroke.Transparency = item == card and 0.15 or 0.7
						itemStroke.Color = item == card and colors.cyan or colors.white
					end
				end
			end)
			if animateCards or animateUsersOnRender then
				animateCardEntrance(card, cardScale, order, usersGrid.FillDirectionMaxCells)
			end
		end

		animateUsersOnRender = false
		if keepSelected then
			if foundSelection then
				for _, data in ipairs(items) do
					if tonumber(data.UserId) == keepSelected then
						setSelected(data)
						break
					end
				end
			else
				setSelected(nil)
			end
		elseif items[1] then
			setSelected(items[1])
		end
	end

	local function selectFilter(index)
		local spec = filterSpecs[index]
		currentFilter = spec.key
		TweenService:Create(
			filterBubble,
			TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{
				Position = UDim2.fromOffset(spec.x + 4, 3),
				Size = UDim2.fromOffset(spec.width - 8, 22),
			}
		):Play()
		for tabIndex, tab in ipairs(filterTabs) do
			local selected = tabIndex == index
			TweenService:Create(tab, TweenInfo.new(0.16), {
				TextColor3 = selected and colors.black or colors.white,
			}):Play()
		end
		usersPageNumber = 1
		list.CanvasPosition = Vector2.zero
		fitUsersToolbar()
		lastSignature = nil
		skipNextSignatureRender = true
		renderUsers(true)
	end
	for index, tab in ipairs(filterTabs) do
		local tabIndex = index
		connect(tab.Activated, function()
			selectFilter(tabIndex)
			if filterSpecs[tabIndex].key == "Friends" then
				task.spawn(fetchOnlineFriends)
			end
		end)
	end
	connect(search:GetPropertyChangedSignal("Text"), function()
		currentQuery = search.Text
		usersPageNumber = 1
		list.CanvasPosition = Vector2.zero
		lastSignature = nil
		skipNextSignatureRender = true
		renderUsers(false)
	end)

	renderUsers()

	local refreshInProgress = false
	local lastPresenceWarning = ""
	local lastPresenceWarningAt = 0
	local function fetchPresenceRows()
		local options = {
			Url = SUPABASE_URL .. "/rest/v1/flow_presence?is_active=eq.true&select=*",
			Method = "GET",
			Headers = {
				["apikey"] = SUPABASE_ANON_KEY,
				["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY,
				["Accept"] = "application/json",
			},
		}
		local requestOk, response = pcall(function()
			if type(request) == "function" then
				return request(options)
			elseif type(http_request) == "function" then
				return http_request(options)
			end
			return HttpService:RequestAsync(options)
		end)
		if not requestOk then
			return nil, tostring(response):sub(1, 90)
		end
		if type(response) ~= "table" then
			return nil, "HTTP request failed"
		end
		local statusCode = tonumber(response.StatusCode or response.status_code)
		if response.Success == false or (statusCode and statusCode >= 400) then
			local detail = tostring(response.Body or response.body or ""):gsub("%s+", " "):sub(1, 90)
			local message = statusCode and ("HTTP " .. tostring(statusCode)) or "HTTP request failed"
			return nil, detail ~= "" and (message .. ": " .. detail) or message
		end
		local body = response.Body or response.body or ""
		if type(body) ~= "string" then
			return nil, "Invalid response body"
		end
		if body == "" then
			return {}, nil
		end
		local decodeOk, rows = pcall(function()
			return HttpService:JSONDecode(body)
		end)
		if not decodeOk or type(rows) ~= "table" then
			return nil, "Invalid Supabase response"
		end
		return rows, nil
	end

	refreshUsersPresence = function()
		if refreshInProgress then
			return
		end
		refreshInProgress = true
		local rows, errorMessage = fetchPresenceRows()
		if not gui.Parent or not usersArea.Parent then
			refreshInProgress = false
			return
		end
		if rows then
			local now = os.time()
			local newCache = {}
			for _, row in ipairs(rows) do
				if type(row) == "table" then
					local updatedAt = tonumber(row.updated_at_ts) or 0
					local userId = tonumber(row.user_id) or 0
					if userId > 0 and now - updatedAt <= 120 then
						newCache[userId] = {
							UserId = userId,
							Name = type(row.name) == "string" and row.name or "",
							GameName = type(row.game_name) == "string" and row.game_name or "",
							GameId = tonumber(row.game_id) or 0,
							PlaceId = tonumber(row.place_id) or 0,
							JobId = type(row.job_id) == "string" and row.job_id or "",
							Since = tonumber(row.since),
							Players = tonumber(row.players) or 0,
							MaxPlayers = tonumber(row.max_players) or 0,
							Ping = tonumber(row.ping) or 0,
							UpdatedAt = updatedAt,
							DND = row.dnd == true,
							HideGame = row.hide_game == true,
							HideBanner = row.hide_banner == true,
							BannerId = tostring(row.banner_id or "134918452547700"),
							HideAvatar = row.hide_avatar == true,
							AvatarId = tostring(row.avatar_id or "109728664560706"),
							HideName = row.hide_name == true,
							CustomName = type(row.custom_name) == "string" and row.custom_name or "Hidden",
							HidePlayers = row.hide_players == true,
							HidePing = row.hide_ping == true,
							BlockJoin = row.block_join == true,
							Badge = tonumber(row.badge) or 0,
						}
					end
				end
			end
			flowUsersCache = newCache
			_G.FlowUsersCache = newCache
			presenceError = nil
		else
			presenceError = errorMessage or "Request failed"
			local now = os.clock()
			if presenceError ~= lastPresenceWarning or now - lastPresenceWarningAt >= 60 then
				warn("Flowers: could not refresh Flow users from Supabase (" .. presenceError .. ").")
				lastPresenceWarning = presenceError
				lastPresenceWarningAt = now
			end
		end
		presenceLoading = false
		lastSignature = nil
		skipNextSignatureRender = true
		renderUsers(true)
		refreshInProgress = false
	end

	task.spawn(refreshUsersPresence)
	task.spawn(fetchOnlineFriends)

	local function signatureValue(value)
		local text = tostring(value or "")
		return tostring(#text) .. ":" .. text
	end

	task.spawn(function()
		local nextPresenceRefresh = 0
		local nextFriendsRefresh = 0
		while gui.Parent and usersArea.Parent do
			if usersArea.Visible and activeKey == "users" then
				if os.clock() >= nextPresenceRefresh then
					nextPresenceRefresh = os.clock() + 15
					task.spawn(refreshUsersPresence)
				end
				if currentFilter == "Friends" and os.clock() >= nextFriendsRefresh then
					nextFriendsRefresh = os.clock() + 30
					task.spawn(fetchOnlineFriends)
				end
				local items = getCurrentUsers()
				local parts = {}
				for _, data in ipairs(items) do
					parts[#parts + 1] = table.concat({
						signatureValue(data.UserId),
						signatureValue(data.UpdatedAt),
						signatureValue(data.PlaceId),
						signatureValue(data.GameId),
						signatureValue(data.Name),
						signatureValue(data.DisplayName),
						signatureValue(data.UserName),
						signatureValue(data.CustomName),
						signatureValue(data.GameName),
						signatureValue(data.Players),
						signatureValue(data.MaxPlayers),
						signatureValue(data.Ping),
						signatureValue(data.HideName),
						signatureValue(data.HideGame),
						signatureValue(data.HidePlayers),
						signatureValue(data.HidePing),
						signatureValue(data.HideAvatar),
						signatureValue(data.HideBanner),
						signatureValue(data.BannerId),
						signatureValue(data.AvatarId),
						signatureValue(data.DND),
						signatureValue(data.JobId or data.jobId),
						signatureValue(data.Since),
						signatureValue(data.Badge),
					})
				end
				local signature = table.concat(parts, "|") .. "|" .. currentFilter .. "|" .. currentQuery
				if signature ~= lastSignature then
					lastSignature = signature
					if skipNextSignatureRender then
						skipNextSignatureRender = false
					else
						renderUsers(false)
					end
				end
			end
			task.wait(1)
		end
	end)

end

local function gameIconThumb(width, height)
	local id = tonumber(game.GameId) or 0
	if id == 0 then
		-- GameIcon keyed by place id returns the default Roblox placeholder --
		id = tonumber(game.PlaceId) or 0
	end
	return string.format("rbxthumb://type=GameIcon&id=%d&w=%d&h=%d", id, width, height)
end

local function buildServers(section)
	-- Single full-screen page (OUI10 style): banner with YOUR server,
	-- sliding sort pill, 3x3 grid, circle pagination (Q/E) and a detail
	-- modal that bubbles out of the card on click. --
	local serversArea = Instance.new("Frame")
	serversArea.Name = "ServersCardsArea"
	serversArea.AnchorPoint = Vector2.new(0.5, 0.5)
	serversArea.Position = UDim2.new(0.5, 0, 0.5, 0)
	serversArea.Size = UDim2.fromScale(1, 1)
	serversArea.BackgroundTransparency = 1
	serversArea.BorderSizePixel = 0
	serversArea.Visible = false
	serversArea.ZIndex = 10
	serversArea.Parent = root
	serversArea.Active = false
	local serversScale = Instance.new("UIScale")
	serversScale.Name = "WindowScale"
	serversScale.Parent = serversArea
	windowBaseZIndex[serversArea] = serversArea.ZIndex
	windowByName[serversArea.Name] = serversArea
	windowSectionByName[serversArea.Name] = section.key
	windowOpenPositions[serversArea.Name] = UDim2.new(0.5, 0, 0.5, 0)
	windows[section.key] = { serversArea }

	local sortMode = "ping"
	local sortButtons = {}
	local serverPageNumber = 1
	local serverTotalPages = 1
	local serversPerPage = 9
	local serverCache = {}
	local serverFirstSeen = {}
	local serverAgeLabels = {}
	local serverSearchText = ""
	local serverFetchError = nil
	local serverFetchActive = false
	local serverHasFetched = false
	local serverLastFetch = 0
	local renderServers
	local rebuildServerPagination
	local goToServerPage
	local updateBanner

	-- Banner band: STATIC, it always resolves YOUR own server so the
	-- job id / players / ping up there never change when a card opens. --
	local bannerHolder = Instance.new("Frame")
	bannerHolder.Name = "ServerBanner"
	bannerHolder.Position = UDim2.fromOffset(12, 10)
	bannerHolder.Size = UDim2.new(1, -24, 0, 150)
	bannerHolder.BackgroundTransparency = 1
	bannerHolder.BorderSizePixel = 0
	bannerHolder.ZIndex = serversArea.ZIndex + 1
	bannerHolder.Parent = serversArea
	corner(bannerHolder, 18)
	addBlurShadow(bannerHolder, 18, colors.black, 0.45, UDim2.new(0, 0, 0, 5))

	local bannerClip = Instance.new("Frame")
	bannerClip.Name = "BannerClip"
	bannerClip.Size = UDim2.fromScale(1, 1)
	bannerClip.BackgroundColor3 = colors.card
	bannerClip.BorderSizePixel = 0
	bannerClip.ClipsDescendants = true
	bannerClip.ZIndex = bannerHolder.ZIndex
	bannerClip.Parent = bannerHolder
	corner(bannerClip, 18)
	local bannerStroke = Instance.new("UIStroke")
	bannerStroke.Color = colors.border
	bannerStroke.Transparency = 0.35
	bannerStroke.Thickness = 1
	bannerStroke.Parent = bannerClip

	local bannerArt = Instance.new("ImageLabel")
	bannerArt.Name = "BannerArt"
	bannerArt.Size = UDim2.fromScale(1, 1)
	bannerArt.BackgroundTransparency = 1
	bannerArt.BorderSizePixel = 0
	bannerArt.ScaleType = Enum.ScaleType.Crop
	bannerArt.ImageColor3 = Color3.fromRGB(190, 190, 198)
	bannerArt.Image = gameIconThumb(512, 512)
	bannerArt.ZIndex = bannerClip.ZIndex + 1
	bannerArt.Parent = bannerClip
	corner(bannerArt, 18)

	local bannerShade = Instance.new("Frame")
	bannerShade.Name = "BannerShade"
	bannerShade.Size = UDim2.fromScale(1, 1)
	bannerShade.BackgroundColor3 = colors.black
	bannerShade.BorderSizePixel = 0
	bannerShade.ZIndex = bannerClip.ZIndex + 2
	bannerShade.Parent = bannerClip
	corner(bannerShade, 18)
	local bannerShadeFade = Instance.new("UIGradient")
	bannerShadeFade.Rotation = 90
	bannerShadeFade.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.black),
		ColorSequenceKeypoint.new(0.45, colors.black),
		ColorSequenceKeypoint.new(1, colors.card),
	})
	bannerShadeFade.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(0.34, 0.7),
		NumberSequenceKeypoint.new(0.66, 0.28),
		NumberSequenceKeypoint.new(1, 0.04),
	})
	bannerShadeFade.Parent = bannerShade

	local function makeBannerLabel(name, y, height, size, color)
		local item = Instance.new("TextLabel")
		item.Name = name
		item.Size = UDim2.new(1, -320, 0, height)
		item.Position = UDim2.new(0, 16, 1, y)
		item.BackgroundTransparency = 1
		item.BorderSizePixel = 0
		item.Font = Enum.Font.GothamMedium
		item.TextSize = size
		item.TextColor3 = color
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.TextTruncate = Enum.TextTruncate.AtEnd
		item.ZIndex = bannerClip.ZIndex + 3
		item.Parent = bannerClip
		return item
	end
	local bannerScope = makeBannerLabel("BannerScope", -62, 12, 10, colors.muted)
	local bannerPlayers = makeBannerLabel("BannerPlayers", -48, 18, 14, colors.white)
	local bannerMeta = makeBannerLabel("BannerMeta", -26, 14, 10, colors.muted)
	bannerScope.Text = "YOUR SERVER"

	local function makeBannerButton(name, text, width, xFromRight)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = UDim2.fromOffset(width, 34)
		button.AnchorPoint = Vector2.new(1, 1)
		button.Position = UDim2.new(1, xFromRight, 1, -16)
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 12
		button.Text = text
		button.ZIndex = bannerClip.ZIndex + 4
		button.Parent = bannerClip
		corner(button, 17)
		addHoverScale(button, 1.05)
		return button
	end
	-- White pill = play, dark glass pill = copy (right aligned) --
	local bannerPlay = makeBannerButton("BannerPlay", "▶ Play", 96, -16)
	bannerPlay.BackgroundColor3 = colors.white
	bannerPlay.BackgroundTransparency = 0.12
	bannerPlay.TextColor3 = colors.black
	local bannerCopy = makeBannerButton("BannerCopyId", "Copy ID", 86, -120)
	bannerCopy.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
	bannerCopy.BackgroundTransparency = 0.15
	bannerCopy.TextColor3 = colors.white
	local bannerCopyStroke = Instance.new("UIStroke")
	bannerCopyStroke.Color = colors.border
	bannerCopyStroke.Transparency = 0.15
	bannerCopyStroke.Thickness = 1
	bannerCopyStroke.Parent = bannerCopy

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
		bannerScope.Text = "YOUR SERVER"
		if not server then
			bannerPlayers.Text = "Players: ? / ?"
			bannerMeta.Text = "Server ID unavailable"
			return
		end
		local playing = tonumber(server.playing)
		local maxPlayers = tonumber(server.maxPlayers)
		if playing and maxPlayers then
			bannerPlayers.Text = string.format("Players: %d / %d", playing, maxPlayers)
		else
			bannerPlayers.Text = string.format(
				"Players: %d / %d",
				#Players:GetPlayers(),
				Players.MaxPlayers
			)
		end
		local parts = {}
		local ping = tonumber(server.ping)
		if ping then
			parts[#parts + 1] = tostring(math.floor(ping + 0.5)) .. " ms"
		end
		parts[#parts + 1] = "ID: " .. tostring(server.id or "")
		bannerMeta.Text = table.concat(parts, "   ·   ")
	end

	local function flashBannerButton(button, text, revert)
		button.Text = text
		task.delay(1.3, function()
			if button.Parent then
				button.Text = revert
			end
		end)
	end

	bannerPlay.Activated:Connect(function()
		local server = resolveBannerServer()
		local jobId = server and tostring(server.id or "") or ""
		if jobId == "" then
			flashBannerButton(bannerPlay, "Unavailable", "▶ Play")
			return
		end
		pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
		end)
		flashBannerButton(bannerPlay, "Connecting...", "▶ Play")
	end)

	bannerCopy.Activated:Connect(function()
		local server = resolveBannerServer()
		local jobId = server and tostring(server.id or "") or ""
		if jobId == "" then
			return
		end
		local clipboard
		pcall(function()
			clipboard = setclipboard or toclipboard or (syn and syn.write_clipboard)
		end)
		local copied = type(clipboard) == "function" and pcall(clipboard, jobId)
		flashBannerButton(bannerCopy, copied and "Copied" or "Unavailable", "Copy ID")
	end)

	updateBanner()

	-- Toolbar row under the banner: sort bar (left), counter, search (right) --
	local toolbar = Instance.new("Frame")
	toolbar.Name = "ServersToolbar"
	toolbar.Position = UDim2.new(0, 12, 0, 168)
	toolbar.Size = UDim2.new(1, -24, 0, 30)
	toolbar.BackgroundTransparency = 1
	toolbar.BorderSizePixel = 0
	toolbar.ZIndex = serversArea.ZIndex + 2
	toolbar.Parent = serversArea

	local sortBar = Instance.new("Frame")
	sortBar.Name = "SortBar"
	sortBar.Size = UDim2.fromOffset(240, 30)
	sortBar.AnchorPoint = Vector2.new(0, 0.5)
	sortBar.Position = UDim2.new(0, 0, 0.5, 0)
	sortBar.BackgroundColor3 = colors.black
	sortBar.BackgroundTransparency = 0.75
	sortBar.BorderSizePixel = 0
	sortBar.ZIndex = toolbar.ZIndex
	sortBar.Parent = toolbar
	corner(sortBar, 16)

	-- Sliding white pill: same animation as the Flow users tabs --
	local sortPill = Instance.new("Frame")
	sortPill.Name = "SortPill"
	sortPill.AnchorPoint = Vector2.new(0, 0.5)
	sortPill.BackgroundColor3 = colors.white
	sortPill.BorderSizePixel = 0
	sortPill.ZIndex = sortBar.ZIndex + 1
	sortPill.Parent = sortBar
	corner(sortPill, 11)

	local function updateSortStyle(noAnimation)
		local target = sortButtons[sortMode]
		if target then
			local goal = {
				Position = UDim2.new(0, target.Position.X.Offset + 4, 0.5, 0),
				Size = UDim2.new(0, math.max(28, target.Size.X.Offset - 8), 0, 22),
			}
			if noAnimation then
				sortPill.Position = goal.Position
				sortPill.Size = goal.Size
			else
				TweenService:Create(
					sortPill,
					TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					goal
				):Play()
			end
		end
		for key, button in pairs(sortButtons) do
			local selected = key == sortMode
			TweenService:Create(
				button,
				TweenInfo.new(noAnimation and 0.001 or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TextColor3 = selected and colors.black or colors.white }
			):Play()
		end
	end

	for _, option in ipairs({
		{ key = "ping", label = "Ping", width = 44, x = 0 },
		{ key = "full", label = "Most full", width = 62, x = 48 },
		{ key = "empty", label = "Most empty", width = 62, x = 114 },
		{ key = "region", label = "Region", width = 54, x = 180 },
	}) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(option.width, 22)
		button.AnchorPoint = Vector2.new(0, 0.5)
		button.Position = UDim2.new(0, option.x, 0.5, 0)
		button.BackgroundColor3 = colors.white
		button.BackgroundTransparency = 1
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 10
		button.TextColor3 = colors.white
		button.Text = option.label
		button.ZIndex = sortBar.ZIndex + 2
		button.Parent = sortBar
		corner(button, 11)
		addHoverScale(button, 1.06)
		sortButtons[option.key] = button
		button.Activated:Connect(function()
			sortMode = option.key
			serverPageNumber = 1
			updateSortStyle()
			renderServers(true)
		end)
	end

	local serverStatus = Instance.new("TextLabel")
	serverStatus.Name = "ServersCounter"
	serverStatus.Size = UDim2.fromOffset(150, 30)
	serverStatus.AnchorPoint = Vector2.new(1, 0.5)
	serverStatus.Position = UDim2.new(1, -284, 0.5, 0)
	serverStatus.BackgroundTransparency = 1
	serverStatus.BorderSizePixel = 0
	serverStatus.Font = Enum.Font.GothamMedium
	serverStatus.TextSize = 13
	serverStatus.TextColor3 = colors.white
	serverStatus.TextXAlignment = Enum.TextXAlignment.Right
	serverStatus.TextTruncate = Enum.TextTruncate.AtEnd
	serverStatus.Text = "Loading servers..."
	serverStatus.ZIndex = toolbar.ZIndex + 1
	serverStatus.Parent = toolbar

	local serverSearch = makeInput(
		toolbar,
		"Search server...",
		UDim2.new(1, -12, 0.5, 0),
		UDim2.fromOffset(260, 30)
	)
	serverSearch.AnchorPoint = Vector2.new(1, 0.5)
	serverSearch.TextSize = 13
	serverSearch.BackgroundColor3 = colors.black
	serverSearch.BackgroundTransparency = 0.4
	local serverSearchCorner = serverSearch:FindFirstChildOfClass("UICorner")
	if serverSearchCorner then
		serverSearchCorner.CornerRadius = UDim.new(0, 16)
	end
	local serverSearchStroke = addBottomContour(serverSearch, "ServerSearchContour", 14)
	serverSearchStroke.Color = colors.border
	serverSearchStroke.Thickness = 1
	serverSearchStroke.Transparency = 0.42
	connect(serverSearch.Focused, function()
		TweenService:Create(serverSearchStroke, TweenInfo.new(0.18), { Transparency = 0.08 }):Play()
		TweenService:Create(serverSearch, TweenInfo.new(0.18), { BackgroundTransparency = 0.18 }):Play()
	end)
	connect(serverSearch.FocusLost, function()
		TweenService:Create(serverSearchStroke, TweenInfo.new(0.18), { Transparency = 0.42 }):Play()
		TweenService:Create(serverSearch, TweenInfo.new(0.18), { BackgroundTransparency = 0.4 }):Play()
	end)

	local function fitServersToolbar()
		local width = toolbar.AbsoluteSize.X
		if width <= 0 then
			return
		end
		local compact = width < 900 or UserInputService.TouchEnabled
		local searchWidth
		if compact then
			serverStatus.Visible = false
			searchWidth = math.clamp(width - 240 - 36, 96, 200)
		else
			serverStatus.Visible = true
			searchWidth = 260
		end
		serverSearch.Size = UDim2.fromOffset(searchWidth, 30)
		serverStatus.Position = UDim2.new(1, -(12 + searchWidth + 12), 0.5, 0)
	end
	connect(toolbar:GetPropertyChangedSignal("AbsoluteSize"), fitServersToolbar)
	task.defer(fitServersToolbar)

	-- Card grid ----------------------------------------------------------------
	local serverList = makeScroll(
		serversArea,
		"ServerCards",
		UDim2.new(0, 12, 0, 206),
		UDim2.new(1, -24, 1, -346)
	)
	serverList.ZIndex = serversArea.ZIndex + 3
	serverList.ScrollBarThickness = 0
	serverList.ScrollBarImageTransparency = 1
	local serverEmpty = label(serversArea, "", UDim2.new(0, 12, 0, 206), UDim2.new(1, -24, 1, -346), 14, colors.white)
	serverEmpty.Name = "ServersEmpty"
	serverEmpty.TextXAlignment = Enum.TextXAlignment.Center
	serverEmpty.TextStrokeColor3 = colors.black
	serverEmpty.TextStrokeTransparency = 0.35
	serverEmpty.Visible = false
	serverEmpty.ZIndex = serverList.ZIndex + 1
	local serverEmptyScale = Instance.new("UIScale")
	serverEmptyScale.Scale = 0.96
	serverEmptyScale.Parent = serverEmpty

	local serverPadding = Instance.new("UIPadding")
	serverPadding.PaddingLeft = UDim.new(0, 8)
	serverPadding.PaddingRight = UDim.new(0, 8)
	serverPadding.PaddingTop = UDim.new(0, 8)
	serverPadding.PaddingBottom = UDim.new(0, 8)
	serverPadding.Parent = serverList
	local serverGrid = Instance.new("UIGridLayout")
	serverGrid.CellSize = UDim2.new(1 / 3, -16, 0, 116)
	serverGrid.CellPadding = UDim2.fromOffset(15, 14)
	serverGrid.FillDirectionMaxCells = 3
	serverGrid.SortOrder = Enum.SortOrder.LayoutOrder
	serverGrid.Parent = serverList

	local function fitServerGrid()
		local viewHeight = serverList.AbsoluteSize.Y
		local viewWidth = serverList.AbsoluteSize.X
		if viewHeight <= 0 or viewWidth <= 0 then
			return
		end
		local columns = (UserInputService.TouchEnabled or viewWidth < 560) and 2 or 3
		serverGrid.FillDirectionMaxCells = columns
		-- 16 covers the 8+8 padding plus the 15px gaps split per column --
		serverGrid.CellSize = UDim2.new(
			1 / columns,
			-16,
			0,
			math.clamp(math.floor((viewHeight - 56) / 3), 58, 116)
		)
	end
	connect(serverList:GetPropertyChangedSignal("AbsoluteSize"), fitServerGrid)
	task.defer(fitServerGrid)

	-- Circle pagination with Q/E key hints --
	local serverPagBar = Instance.new("Frame")
	serverPagBar.Name = "ServersPagination"
	serverPagBar.Size = UDim2.new(1, 0, 0, 46)
	serverPagBar.Position = UDim2.new(0, 0, 1, -134)
	serverPagBar.BackgroundTransparency = 1
	serverPagBar.BorderSizePixel = 0
	serverPagBar.Active = false
	serverPagBar.ZIndex = serversArea.ZIndex + 4
	serverPagBar.Parent = serversArea
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
		button.BackgroundColor3 = colors.black
		button.BackgroundTransparency = 0.72
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 14
		button.TextColor3 = colors.white
		button.Text = text
		button.LayoutOrder = order
		button.ZIndex = serverPagBar.ZIndex + 1
		button.Parent = serverPagBar
		corner(button, 14)
		local stroke = Instance.new("UIStroke")
		stroke.Color = colors.border
		stroke.Transparency = 0.5
		stroke.Thickness = 1
		stroke.Parent = button
		addHoverScale(button, 1.05)
		return button
	end

	local function addPagKeyHint(button, key)
		local hint = Instance.new("TextLabel")
		hint.Size = UDim2.fromOffset(22, 14)
		hint.AnchorPoint = Vector2.new(0.5, 1)
		hint.Position = UDim2.new(0.5, 0, 0, -2)
		hint.BackgroundTransparency = 1
		hint.BorderSizePixel = 0
		hint.Font = Enum.Font.GothamMedium
		hint.TextSize = 10
		hint.TextColor3 = colors.white
		hint.TextTransparency = 0.2
		hint.Text = key
		hint.ZIndex = button.ZIndex + 1
		hint.Parent = button
		return hint
	end

	local serverPagPrev = makeServerPagButton("‹", 1, 42)
	local serverPagNext = makeServerPagButton("›", 9999, 42)
	addPagKeyHint(serverPagPrev, "Q")
	addPagKeyHint(serverPagNext, "E")

	local serverLastTotalPages = 1

	rebuildServerPagination = function(totalPages)
		serverTotalPages = totalPages
		serverLastTotalPages = totalPages
		serverPagPrev.TextTransparency = serverPageNumber <= 1 and 0.6 or 0
		serverPagNext.TextTransparency = serverPageNumber >= totalPages and 0.6 or 0
		for _, child in ipairs(serverPagBar:GetChildren()) do
			if child.Name == "ServerPagCircle" then
				child:Destroy()
			end
		end
		-- Never draw every page: cap the row so it always fits the bar --
		local firstPage = 1
		local lastPage = totalPages
		if totalPages > 9 then
			firstPage = math.clamp(serverPageNumber - 4, 1, totalPages - 8)
			lastPage = firstPage + 8
		end
		for pageNum = firstPage, lastPage do
			local active = pageNum == serverPageNumber
			local circle = Instance.new("TextButton")
			circle.Name = "ServerPagCircle"
			circle.Size = UDim2.fromOffset(30, 30)
			circle.BackgroundColor3 = colors.white
			circle.BackgroundTransparency = active and 0 or 1
			circle.BorderSizePixel = 0
			circle.AutoButtonColor = false
			circle.Font = Enum.Font.GothamMedium
			circle.TextSize = 12
			circle.TextColor3 = active and colors.black or colors.white
			circle.TextTransparency = active and 0 or 0.55
			circle.Text = tostring(pageNum)
			circle.LayoutOrder = 10 + pageNum
			circle.ZIndex = serverPagBar.ZIndex + 1
			circle.Parent = serverPagBar
			corner(circle, 15)
			addHoverScale(circle, 1.1)
			circle.Activated:Connect(function()
				if pageNum ~= serverPageNumber then
					serverPageNumber = pageNum
					renderServers(true)
				end
			end)
		end
	end

	goToServerPage = function(pageNumber)
		pageNumber = math.clamp(pageNumber, 1, serverTotalPages)
		if pageNumber == serverPageNumber then
			return
		end
		serverPageNumber = pageNumber
		renderServers(true)
	end

	serverPagPrev.Activated:Connect(function()
		goToServerPage(serverPageNumber - 1)
	end)
	serverPagNext.Activated:Connect(function()
		goToServerPage(serverPageNumber + 1)
	end)

	local function formatSeen(timestamp)
		local age = math.max(0, os.time() - timestamp)
		if age < 60 then
			return tostring(age) .. "s"
		elseif age < 3600 then
			return tostring(math.floor(age / 60)) .. "m"
		elseif age < 86400 then
			return tostring(math.floor(age / 3600)) .. "h"
		end
		return tostring(math.floor(age / 86400)) .. "d"
	end

	-- The public servers API exposes no region field, so "Region" is
	-- approximated by ping distance to the server the player is on. --
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

	local function getSortedServers()
		local rows = table.clone(serverCache)
		local query = serverSearchText:gsub("^%s+", ""):gsub("%s+$", ""):lower()
		if query ~= "" then
			local filtered = {}
			for _, server in ipairs(rows) do
				local id = tostring(server.id or ""):lower()
				local ping = tostring(server.ping or ""):lower()
				if id:find(query, 1, true) or ping:find(query, 1, true) then
					filtered[#filtered + 1] = server
				end
			end
			rows = filtered
		end

		local baselinePing = sortMode == "region" and regionBaselinePing() or nil
		table.sort(rows, function(a, b)
			local pingA = tonumber(a.ping) or math.huge
			local pingB = tonumber(b.ping) or math.huge
			if sortMode == "ping" and pingA ~= pingB then
				return pingA < pingB
			elseif sortMode == "full" and a.playing ~= b.playing then
				return (tonumber(a.playing) or 0) > (tonumber(b.playing) or 0)
			elseif sortMode == "empty" and a.playing ~= b.playing then
				return (tonumber(a.playing) or 0) < (tonumber(b.playing) or 0)
			elseif sortMode == "region" then
				local distanceA = baselinePing and math.abs(pingA - baselinePing) or pingA
				local distanceB = baselinePing and math.abs(pingB - baselinePing) or pingB
				if distanceA ~= distanceB then
					return distanceA < distanceB
				end
			end
			return tostring(a.id or "") < tostring(b.id or "")
		end)
		return rows
	end

	-- Expanded server panel (bubble effect on card click) --
	local detailServer = nil
	local detailFirstSeen = nil

	local detailBackdrop = Instance.new("TextButton")
	detailBackdrop.Name = "ServerDetailBackdrop"
	detailBackdrop.Size = UDim2.fromScale(1, 1)
	detailBackdrop.BackgroundColor3 = colors.black
	detailBackdrop.BackgroundTransparency = 1
	detailBackdrop.BorderSizePixel = 0
	detailBackdrop.AutoButtonColor = false
	detailBackdrop.Text = ""
	detailBackdrop.Visible = false
	detailBackdrop.ZIndex = serversArea.ZIndex + 20
	detailBackdrop.Parent = serversArea

	local serverDetail = Instance.new("Frame")
	serverDetail.Name = "ServerDetail"
	serverDetail.AnchorPoint = Vector2.new(0.5, 0.5)
	serverDetail.Position = UDim2.fromScale(0.5, 0.5)
	serverDetail.BackgroundTransparency = 1
	serverDetail.BorderSizePixel = 0
	serverDetail.Visible = false
	serverDetail.ZIndex = serversArea.ZIndex + 21
	serverDetail.Parent = serversArea
	addBlurShadow(serverDetail, 24, colors.black, 0.4, UDim2.new(0, 0, 0, 6))

	local detailScale = Instance.new("UIScale")
	detailScale.Parent = serverDetail

	-- Clipped container: the banner art is cut at the middle --
	local detailClip = Instance.new("Frame")
	detailClip.Name = "DetailClip"
	detailClip.Size = UDim2.fromScale(1, 1)
	detailClip.BackgroundColor3 = colors.card
	detailClip.BackgroundTransparency = 0.06
	detailClip.BorderSizePixel = 0
	detailClip.ClipsDescendants = true
	detailClip.ZIndex = serverDetail.ZIndex
	detailClip.Parent = serverDetail
	corner(detailClip, 20)
	local detailStroke = Instance.new("UIStroke")
	detailStroke.Color = colors.border
	detailStroke.Transparency = 0.35
	detailStroke.Thickness = 1.2
	detailStroke.Parent = detailClip

	local detailBanner = Instance.new("ImageLabel")
	detailBanner.Name = "DetailBanner"
	detailBanner.Size = UDim2.new(1, 0, 0.5, 0)
	detailBanner.BackgroundTransparency = 1
	detailBanner.BorderSizePixel = 0
	detailBanner.ScaleType = Enum.ScaleType.Crop
	detailBanner.ImageColor3 = Color3.fromRGB(190, 190, 198)
	detailBanner.Image = gameIconThumb(256, 256)
	detailBanner.ZIndex = detailClip.ZIndex
	detailBanner.Parent = detailClip
	corner(detailBanner, 20)

	-- Cut shading: the banner fades out and disappears at the middle --
	local detailShade = Instance.new("Frame")
	detailShade.Name = "DetailShade"
	detailShade.Size = UDim2.new(1, 0, 0.5, 0)
	detailShade.BackgroundColor3 = colors.black
	detailShade.BorderSizePixel = 0
	detailShade.ZIndex = detailClip.ZIndex + 1
	detailShade.Parent = detailClip
	corner(detailShade, 20)
	local detailShadeFade = Instance.new("UIGradient")
	detailShadeFade.Rotation = 90
	detailShadeFade.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors.black),
		ColorSequenceKeypoint.new(0.6, colors.black),
		ColorSequenceKeypoint.new(1, colors.card),
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
	detailInfo.ZIndex = detailClip.ZIndex + 2
	detailInfo.Parent = detailClip
	local detailLayout = Instance.new("UIListLayout")
	detailLayout.FillDirection = Enum.FillDirection.Vertical
	detailLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	detailLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	detailLayout.Padding = UDim.new(0, 6)
	detailLayout.Parent = detailInfo

	local function makeDetailText(text, height, size, color, font, order)
		local item = Instance.new("TextLabel")
		item.Size = UDim2.new(1, 0, 0, height)
		item.LayoutOrder = order
		item.BackgroundTransparency = 1
		item.BorderSizePixel = 0
		item.Font = font or Enum.Font.GothamMedium
		item.TextSize = size
		item.TextColor3 = color or colors.white
		item.TextXAlignment = Enum.TextXAlignment.Center
		item.TextTruncate = Enum.TextTruncate.AtEnd
		item.Text = text
		item.ZIndex = detailInfo.ZIndex + 1
		item.Parent = detailInfo
		return item
	end

	local detailPlayers = makeDetailText("Players: 0 / 0", 17, 13, colors.white, Enum.Font.GothamSemibold, 1)
	local detailPing = makeDetailText("Ping N/A", 15, 12, colors.pink, nil, 2)
	local detailAge = makeDetailText("Seen 0s", 15, 11, colors.pink, nil, 3)

	local detailIdRow = Instance.new("Frame")
	detailIdRow.Name = "DetailIdRow"
	detailIdRow.AutomaticSize = Enum.AutomaticSize.X
	detailIdRow.Size = UDim2.new(0, 0, 0, 17)
	detailIdRow.LayoutOrder = 4
	detailIdRow.BackgroundTransparency = 1
	detailIdRow.BorderSizePixel = 0
	detailIdRow.ZIndex = detailInfo.ZIndex + 1
	detailIdRow.Parent = detailInfo
	local detailIdLayout = Instance.new("UIListLayout")
	detailIdLayout.FillDirection = Enum.FillDirection.Horizontal
	detailIdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	detailIdLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	detailIdLayout.Padding = UDim.new(0, 8)
	detailIdLayout.Parent = detailIdRow

	local detailIdLabel = Instance.new("TextLabel")
	detailIdLabel.Name = "DetailServerId"
	detailIdLabel.AutomaticSize = Enum.AutomaticSize.X
	detailIdLabel.Size = UDim2.new(0, 0, 0, 16)
	detailIdLabel.BackgroundTransparency = 1
	detailIdLabel.BorderSizePixel = 0
	detailIdLabel.Font = Enum.Font.GothamMedium
	detailIdLabel.TextSize = 10
	detailIdLabel.TextColor3 = colors.muted
	detailIdLabel.TextXAlignment = Enum.TextXAlignment.Left
	detailIdLabel.Text = "ID: "
	detailIdLabel.ZIndex = detailIdRow.ZIndex + 1
	detailIdLabel.Parent = detailIdRow

	local detailCopy = Instance.new("TextButton")
	detailCopy.Name = "CopyServerId"
	detailCopy.Size = UDim2.fromOffset(54, 18)
	detailCopy.LayoutOrder = 2
	detailCopy.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
	detailCopy.BackgroundTransparency = 0.15
	detailCopy.BorderSizePixel = 0
	detailCopy.AutoButtonColor = false
	detailCopy.Font = Enum.Font.GothamMedium
	detailCopy.TextSize = 9
	detailCopy.TextColor3 = colors.white
	detailCopy.Text = "Copy"
	detailCopy.ZIndex = detailIdRow.ZIndex + 1
	detailCopy.Parent = detailIdRow
	corner(detailCopy, 6)
	local detailCopyStroke = Instance.new("UIStroke")
	detailCopyStroke.Color = colors.border
	detailCopyStroke.Transparency = 0.15
	detailCopyStroke.Thickness = 1
	detailCopyStroke.Parent = detailCopy
	detailCopy.Activated:Connect(function()
		if not detailServer then
			return
		end
		local clipboard
		pcall(function()
			clipboard = setclipboard or toclipboard or (syn and syn.write_clipboard)
		end)
		local copied = type(clipboard) == "function" and pcall(clipboard, tostring(detailServer.id))
		detailCopy.Text = copied and "Copied" or "Unavailable"
		task.delay(1.2, function()
			if detailCopy.Parent then
				detailCopy.Text = "Copy"
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
	detailJoin.ZIndex = detailInfo.ZIndex + 1
	detailJoin.Parent = detailInfo
	corner(detailJoin, 23)
	local detailJoinStroke = Instance.new("UIStroke")
	detailJoinStroke.Color = colors.border
	detailJoinStroke.Transparency = 0.2
	detailJoinStroke.Thickness = 1.1
	detailJoinStroke.Parent = detailJoin
	local detailPlayIcon = Instance.new("ImageLabel")
	detailPlayIcon.Size = UDim2.fromOffset(24, 24)
	detailPlayIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	detailPlayIcon.Position = UDim2.fromScale(0.5, 0.5)
	detailPlayIcon.BackgroundTransparency = 1
	detailPlayIcon.Image = "rbxassetid://106640709678034"
	detailPlayIcon.ImageColor3 = colors.white
	detailPlayIcon.ScaleType = Enum.ScaleType.Fit
	detailPlayIcon.Active = false
	detailPlayIcon.ZIndex = detailJoin.ZIndex + 1
	detailPlayIcon.Parent = detailJoin
	detailJoin.MouseEnter:Connect(function()
		TweenService:Create(detailJoin, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(32, 32, 32) }):Play()
	end)
	detailJoin.MouseLeave:Connect(function()
		TweenService:Create(detailJoin, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(0, 0, 0) }):Play()
	end)
	detailJoin.Activated:Connect(function()
		if not detailServer then
			return
		end
		local jobId = tostring(detailServer.id or "")
		if jobId == "" then
			flashBannerButton(detailJoin, "", "")
			return
		end
		pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
		end)
	end)

	local function updateServerDetail()
		if not detailServer then
			return
		end
		detailPlayers.Text = string.format(
			"Players: %d / %d",
			tonumber(detailServer.playing) or 0,
			tonumber(detailServer.maxPlayers) or 0
		)
		local ping = tonumber(detailServer.ping)
		detailPing.Text = ping and (tostring(math.floor(ping + 0.5)) .. " ms") or "Ping N/A"
		detailIdLabel.Text = "ID: " .. tostring(detailServer.id or "")
		if detailFirstSeen then
			detailAge.Text = "Seen " .. formatSeen(detailFirstSeen)
		end
	end

	local function closeServerDetail()
		if not serverDetail.Visible then
			return
		end
		detailServer = nil
		TweenService:Create(
			detailBackdrop,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		):Play()
		TweenService:Create(
			detailScale,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Scale = 0.6 }
		):Play()
		task.delay(0.19, function()
			if not detailServer then
				serverDetail.Visible = false
				detailBackdrop.Visible = false
				detailScale.Scale = 1
			end
		end)
	end

	local function openServerDetail(server, card)
		detailServer = server
		detailFirstSeen = serverFirstSeen[tostring(server.id)] or os.time()
		updateServerDetail()

		local pageAbs = root.AbsoluteSize
		local pagePos = root.AbsolutePosition
		local finalWidth = math.clamp(pageAbs.X * 0.62, 300, 470)
		local finalHeight = math.clamp(pageAbs.Y * 0.76, 300, 380)

		-- The card grows from its position toward the center (bubble) --
		local startCenter
		local startW, startH
		if card then
			local cardAbsPos = card.AbsolutePosition
			local cardAbsSize = card.AbsoluteSize
			startCenter = Vector2.new(
				cardAbsPos.X - pagePos.X + cardAbsSize.X * 0.5,
				cardAbsPos.Y - pagePos.Y + cardAbsSize.Y * 0.5
			)
			startW, startH = cardAbsSize.X, cardAbsSize.Y
		else
			startCenter = Vector2.new(pageAbs.X * 0.5, pageAbs.Y * 0.5)
			startW, startH = finalWidth * 0.6, finalHeight * 0.6
		end

		serverDetail.Size = UDim2.fromOffset(startW, startH)
		serverDetail.Position = UDim2.fromOffset(startCenter.X, startCenter.Y)
		detailBackdrop.Visible = true
		serverDetail.Visible = true

		TweenService:Create(
			detailBackdrop,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 0.5 }
		):Play()
		TweenService:Create(
			serverDetail,
			TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = UDim2.fromOffset(finalWidth, finalHeight),
				Position = UDim2.fromOffset(pageAbs.X * 0.5, pageAbs.Y * 0.5),
			}
		):Play()
		TweenService:Create(
			detailScale,
			TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	end

	detailBackdrop.Activated:Connect(function()
		closeServerDetail()
	end)

	renderServers = function(animateCards)
		closeServerDetail()
		for _, child in ipairs(serverList:GetChildren()) do
			if child ~= serverGrid and child ~= serverPadding then
				child:Destroy()
			end
		end
		table.clear(serverAgeLabels)

		local rows = getSortedServers()
		local totalPages = math.max(1, math.ceil(#rows / serversPerPage))
		serverPageNumber = math.clamp(serverPageNumber, 1, totalPages)
		rebuildServerPagination(totalPages)
		serverStatus.Text = serverFetchError
			or (serverHasFetched and (tostring(#rows) .. " servers loaded") or "Loading servers...")
		if #rows == 0 and serverHasFetched and not serverFetchError then
			serverStatus.Text = serverSearchText ~= ""
				and "No servers match your search."
				or "No servers available."
		end

		local showEmpty = #rows == 0 and serverHasFetched
		if showEmpty then
			local entering = not serverEmpty.Visible
			serverEmpty.Visible = true
			serverEmpty.Text = serverStatus.Text
			if entering then
				serverEmpty.TextTransparency = 1
				serverEmptyScale.Scale = 0.96
				TweenService:Create(
					serverEmpty,
					TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ TextTransparency = 0 }
				):Play()
				TweenService:Create(
					serverEmptyScale,
					TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Scale = 1 }
				):Play()
			end
		else
			serverEmpty.Visible = false
		end

		local firstIndex = (serverPageNumber - 1) * serversPerPage + 1
		local lastIndex = math.min(#rows, firstIndex + serversPerPage - 1)
		for index = firstIndex, lastIndex do
			local server = rows[index]
			local card = Instance.new("TextButton")
			card.Name = "ServerCard"
			card.BackgroundColor3 = colors.black
			card.BackgroundTransparency = 0.45
			card.BorderSizePixel = 0
			card.AutoButtonColor = false
			card.Text = ""
			card.LayoutOrder = index
			card.ZIndex = 1
			card.Parent = serverList
			corner(card, 16)
			addBlurShadow(card, 6, colors.black, 0.3, UDim2.new(0, 0, 0, 1))

			local cardArt = Instance.new("ImageLabel")
			cardArt.Name = "GameBanner"
			cardArt.Size = UDim2.fromScale(1, 1)
			cardArt.BackgroundTransparency = 1
			cardArt.BorderSizePixel = 0
			cardArt.ScaleType = Enum.ScaleType.Crop
			cardArt.ImageColor3 = Color3.fromRGB(190, 190, 196)
			cardArt.Image = gameIconThumb(256, 256)
			cardArt.ZIndex = card.ZIndex
			cardArt.Parent = card
			corner(cardArt, 16)
			local cardArtLight = Instance.new("UIGradient")
			cardArtLight.Rotation = 90
			cardArtLight.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colors.white),
				ColorSequenceKeypoint.new(0.3, colors.white),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
			})
			cardArtLight.Parent = cardArt

			local cardShade = Instance.new("Frame")
			cardShade.Size = UDim2.fromScale(1, 1)
			cardShade.BackgroundColor3 = colors.black
			cardShade.BorderSizePixel = 0
			cardShade.ZIndex = card.ZIndex + 1
			cardShade.Parent = card
			corner(cardShade, 16)
			local cardShadeFade = Instance.new("UIGradient")
			cardShadeFade.Rotation = 90
			cardShadeFade.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(0.55, 0.62),
				NumberSequenceKeypoint.new(1, 0.72),
			})
			cardShadeFade.Parent = cardShade

			local cardPlayers = label(
				card,
				string.format(
					"Players: %d / %d",
					tonumber(server.playing) or 0,
					tonumber(server.maxPlayers) or 0
				),
				UDim2.fromOffset(14, 18),
				UDim2.new(1, -28, 0, 16),
				12,
				colors.white,
				Enum.Font.GothamSemibold
			)
			cardPlayers.ZIndex = card.ZIndex + 2

			local ping = tonumber(server.ping)
			local cardPing = label(
				card,
				ping and (tostring(math.floor(ping + 0.5)) .. " ms") or "Ping N/A",
				UDim2.fromOffset(14, 39),
				UDim2.new(1, -28, 0, 14),
				11,
				colors.pink
			)
			cardPing.ZIndex = card.ZIndex + 2

			local cardId = label(
				card,
				"ID: " .. tostring(server.id or ""),
				UDim2.fromOffset(14, 57),
				UDim2.new(1, -28, 0, 14),
				9,
				colors.muted
			)
			cardId.TextTruncate = Enum.TextTruncate.AtEnd
			cardId.ZIndex = card.ZIndex + 2

			local firstSeen = serverFirstSeen[tostring(server.id)] or os.time()
			local ageLabel = label(
				card,
				"Seen " .. formatSeen(firstSeen),
				UDim2.fromOffset(14, 77),
				UDim2.new(1, -28, 0, 14),
				10,
				colors.pink
			)
			ageLabel.ZIndex = card.ZIndex + 2
			serverAgeLabels[tostring(server.id)] = { label = ageLabel, firstSeen = firstSeen }

			local cardStroke = Instance.new("UIStroke")
			cardStroke.Color = colors.border
			cardStroke.Transparency = 0.35
			cardStroke.Thickness = 1
			cardStroke.Parent = card
			local cardScale = addHoverScale(card, 1.05)
			card.MouseEnter:Connect(function()
				TweenService:Create(
					cardStroke,
					TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Color = colors.cyan, Transparency = 0.1 }
				):Play()
			end)
			card.MouseLeave:Connect(function()
				TweenService:Create(
					cardStroke,
					TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Color = colors.border, Transparency = 0.35 }
				):Play()
			end)
			card.Activated:Connect(function()
				openServerDetail(server, card)
			end)

			if animateCards then
				animateCardEntrance(card, cardScale, index - firstIndex + 1, serverGrid.FillDirectionMaxCells)
			end
		end

		updateBanner()
		task.defer(fitServerGrid)
	end

	local function requestServerData(url)
		local options = {
			Url = url,
			Method = "GET",
			Headers = { Accept = "application/json" },
		}
		local requestOk, response = pcall(function()
			if type(request) == "function" then
				return request(options)
			elseif type(http_request) == "function" then
				return http_request(options)
			end
			return HttpService:RequestAsync(options)
		end)
		if not requestOk then
			local fallbackOk, fallbackBody = pcall(function()
				return game:HttpGet(url, true)
			end)
			if fallbackOk and type(fallbackBody) == "string" then
				response = fallbackBody
			else
				return nil, (tostring(response) .. "; fallback failed: " .. tostring(fallbackBody)):sub(1, 100)
			end
		end

		local statusCode
		local body
		if type(response) == "string" then
			body = response
		elseif type(response) == "table" then
			statusCode = tonumber(response.StatusCode or response.status_code)
			if response.Success == false or (statusCode and statusCode >= 400) then
				return nil, statusCode and ("HTTP " .. tostring(statusCode)) or "HTTP request failed"
			end
			body = response.Body or response.body
		end
		if type(body) ~= "string" or body == "" then
			local fallbackOk, fallbackBody = pcall(function()
				return game:HttpGet(url, true)
			end)
			if fallbackOk then
				body = fallbackBody
			end
		end
		if type(body) ~= "string" or body == "" then
			return nil, "Empty server response"
		end
		local decodeOk, result = pcall(function()
			return HttpService:JSONDecode(body)
		end)
		if not decodeOk or type(result) ~= "table" or type(result.data) ~= "table" then
			return nil, "Invalid server response"
		end
		return result
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
		renderServers(false)
		task.spawn(function()
			local fetched = {}
			local seenIds = {}
			local seenCursors = {}
			local cursor = nil
			local fetchError = nil
			for _ = 1, 4 do
				local url = string.format(
					"https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
					game.PlaceId
				)
				if cursor and cursor ~= "" then
					url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
				end
				local result, err = requestServerData(url)
				if not result then
					fetchError = "Server API unavailable: " .. tostring(err)
					break
				end
				for _, server in ipairs(result.data) do
					if type(server) == "table" then
						local id = tostring(server.id or "")
						if id ~= "" and not seenIds[id] then
							seenIds[id] = true
							serverFirstSeen[id] = serverFirstSeen[id] or os.time()
							fetched[#fetched + 1] = server
						end
					end
				end
				local nextCursor = result.nextPageCursor
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
			updateBanner()
			renderServers(true)
		end)
	end

	refreshServers = fetchServers

	connect(serverSearch:GetPropertyChangedSignal("Text"), function()
		serverSearchText = serverSearch.Text
		serverPageNumber = 1
		serverList.CanvasPosition = Vector2.zero
		renderServers(false)
	end)

	connect(UserInputService.InputBegan, function(input, gameProcessed)
		if gameProcessed or activeKey ~= "servers" or UserInputService:GetFocusedTextBox() then
			return
		end
		if input.KeyCode == Enum.KeyCode.Q then
			goToServerPage(serverPageNumber - 1)
		elseif input.KeyCode == Enum.KeyCode.E then
			goToServerPage(serverPageNumber + 1)
		end
	end)

	updateSortStyle(true)
	renderServers(false)
	task.defer(function()
		fetchServers(false)
	end)
	task.spawn(function()
		while gui.Parent do
			task.wait(120)
			if activeKey == "servers" then
				fetchServers(true)
			end
		end
	end)
	task.spawn(function()
		while gui.Parent do
			task.wait(60)
			if activeKey == "servers" then
				for _, ageEntry in pairs(serverAgeLabels) do
					if ageEntry.label.Parent then
						ageEntry.label.Text = "Seen " .. formatSeen(ageEntry.firstSeen)
					end
				end
				if detailServer and detailFirstSeen then
					detailAge.Text = "Seen " .. formatSeen(detailFirstSeen)
				end
			end
		end
	end)
end


local function _buildSettings(first, second)
	label(first, "PREFERENCES", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 18), 9, colors.cyan, Enum.Font.GothamSemibold)
	local formatBox = makeSurface(first, "TimeFormat", UDim2.new(0, 0, 0, 26), UDim2.new(1, 0, 0, 54), colors.card, 10)
	label(formatBox, "Time format", UDim2.fromOffset(12, 0), UDim2.new(0.45, 0, 1, 0), 11, colors.white)
	makeButton(formatBox, "12 h", UDim2.new(0.52, 0, 0.5, -13), UDim2.new(0.2, -4, 0, 26), false)
	makeButton(formatBox, "24 h", UDim2.new(0.76, 0, 0.5, -13), UDim2.new(0.2, -4, 0, 26), true)
	local positionBox = makeSurface(first, "NavigationPosition", UDim2.new(0, 0, 0, 90), UDim2.new(1, 0, 0, 54), colors.card, 10)
	label(positionBox, "Navigation position", UDim2.fromOffset(12, 0), UDim2.new(0.4, 0, 1, 0), 10, colors.white)
	makeButton(positionBox, "Top", UDim2.new(0.43, 0, 0.5, -13), UDim2.new(0.16, -3, 0, 26), false)
	makeButton(positionBox, "Bottom", UDim2.new(0.60, 0, 0.5, -13), UDim2.new(0.2, -3, 0, 26), true)
	makeButton(positionBox, "Side", UDim2.new(0.81, 0, 0.5, -13), UDim2.new(0.16, -3, 0, 26), false)
	placeholder(first, "Preference controls will be connected in a later step.", UDim2.new(0, 0, 0, 158), UDim2.new(1, 1, 0, 82))

	label(second, "INTERFACE", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 18), 9, colors.cyan, Enum.Font.GothamSemibold)
	local appearance = makeSurface(second, "Appearance", UDim2.new(0, 0, 0, 26), UDim2.new(1, 0, 0, 70), colors.card, 10)
	label(appearance, "Theme", UDim2.fromOffset(12, 6), UDim2.new(0.38, 0, 0, 24), 11, colors.white)
	makeButton(appearance, "Vice City", UDim2.new(0.42, 0, 0, 6), UDim2.new(0.52, 0, 0, 26), true)
	label(appearance, "Glow", UDim2.fromOffset(12, 38), UDim2.new(0.38, 0, 0, 24), 11, colors.white)
	makeButton(appearance, "On", UDim2.new(0.42, 0, 0, 38), UDim2.new(0.52, 0, 0, 26), true)
	placeholder(second, "Additional interface controls will go here.", UDim2.new(0, 0, 0, 110), UDim2.new(1, 1, 0, 130))
end

commandBar = Instance.new("CanvasGroup")
commandBar.Name = "CommandBar"
commandBar.AnchorPoint = Vector2.new(0.5, 0)
commandBar.Position = UDim2.new(0.5, 0, 0, -44)
commandBar.Size = UDim2.fromOffset(330, 38)
commandBar.BackgroundColor3 = colors.black
commandBar.BackgroundTransparency = 0
commandBar.BorderSizePixel = 0
commandBar.GroupTransparency = 1
commandBar.Visible = false
commandBar.ZIndex = 7
commandBar.Parent = root
commandBar.ClipsDescendants = true
corner(commandBar, 20)
addBlurShadow(commandBar, 10, colors.black, 0.34, UDim2.new(0, 0, 0, 0))
addBottomContour(commandBar, "CommandBarBottomContour", 18)
local commandBarBottomLight = Instance.new("Frame")
commandBarBottomLight.Name = "CommandBarBottomLight"
commandBarBottomLight.Position = UDim2.new(0, 18, 0.76, 0)
commandBarBottomLight.Size = UDim2.new(1, -36, 0.24, 0)
commandBarBottomLight.BackgroundColor3 = colors.white
commandBarBottomLight.BorderSizePixel = 0
commandBarBottomLight.ZIndex = commandBar.ZIndex
commandBarBottomLight.Parent = commandBar
local commandBarLightGradient = Instance.new("UIGradient")
commandBarLightGradient.Rotation = 90
commandBarLightGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(1, 0.9),
})
commandBarLightGradient.Parent = commandBarBottomLight

local commandInput = makeInput(commandBar, "Enter a command...", UDim2.fromOffset(10, 4), UDim2.new(1, -20, 1, -8))
commandInput.BackgroundTransparency = 1
commandInput.PlaceholderColor3 = colors.muted
commandInput.TextColor3 = colors.white
commandInput.TextSize = 12
commandInput.ZIndex = commandBar.ZIndex + 1
connect(commandInput.Focused, function()
	if commandInput.CursorPosition < 1 then
		commandInput.CursorPosition = #commandInput.Text + 1
	end
end)

for index, section in ipairs(sections) do
	local slot = Instance.new("Frame")
	slot.Name = section.key .. "NavigationItem"
	slot.LayoutOrder = index
	slot.Size = UDim2.fromOffset(28, 40)
	slot.BackgroundTransparency = 1
	slot.BorderSizePixel = 0
	slot.ClipsDescendants = true
	slot.ZIndex = 6
	slot.Parent = buttonContainer

	local button = Instance.new("ImageButton")
	button.Name = section.key .. "Button"
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = UDim2.fromScale(0.5, 0.5)
	button.Size = UDim2.fromOffset(28, 28)
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Image = "rbxassetid://" .. section.icon
	button.ImageColor3 = colors.white
	button.ScaleType = Enum.ScaleType.Fit
	button.ZIndex = 6
	button.Parent = slot
	sectionButtons[section.key] = button

	navigationItems[section.key] = {
		slot = slot,
		button = button,
		hovered = false,
		mode = "idle",
		pulseToken = 0,
	}

	if section.key == "commands" then
		local recentWindow, libraryWindow, customWindow = addCommandWindows(section)
		buildCommandsPanels(libraryWindow, recentWindow, customWindow, commandInput)
	elseif section.key == "users" then
		buildUsers(section)
	elseif section.key == "servers" then
		buildServers(section)
	else
		addWindowPair(section, "", "")
	end

	connect(slot.MouseEnter, function()
		navigationItems[section.key].hovered = true
		refreshNavigationVisuals()
	end)
	connect(slot.MouseLeave, function()
		navigationItems[section.key].hovered = false
		refreshNavigationVisuals()
	end)
	connect(button.Activated, function()
		setActiveSection(section.key)
	end)
end

connect(root:GetPropertyChangedSignal("AbsoluteSize"), function()
	refreshWindowSizeConstraints()
	if commandBar then
		commandBar.Size = commandBarSize()
	end
	for name, position in pairs(windowOpenPositions) do
		local window = windowByName[name]
		if window then
			windowOpenPositions[name] = clampWindowPosition(window, position)
			if window.Visible then
				window.Position = clampWindowPosition(window, window.Position)
			end
		end
	end
end)

connect(UserInputService.InputChanged, function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	if activeResize and not activeResize.releasePending then
		local resize = activeResize
		local delta = input.Position - resize.start
		local width = math.clamp(
			resize.absoluteSize.X + delta.X * resize.horizontal,
			resize.minimum.X,
			resize.maximum.X
		)
		local height = math.clamp(
			resize.absoluteSize.Y + delta.Y * resize.vertical,
			resize.minimum.Y,
			resize.maximum.Y
		)
		local widthDelta = width - resize.absoluteSize.X
		local heightDelta = height - resize.absoluteSize.Y
		resize.targetSize = UDim2.fromOffset(
			resize.size.X.Offset + widthDelta,
			resize.size.Y.Offset + heightDelta
		)
		local targetPosition = UDim2.fromOffset(
			resize.position.X.Offset + widthDelta * resize.horizontal / 2,
			resize.position.Y.Offset + heightDelta * resize.vertical / 2
		)
		local targetAbsoluteSize = Vector2.new(
			resize.targetSize.X.Scale * root.AbsoluteSize.X + resize.targetSize.X.Offset,
			resize.targetSize.Y.Scale * root.AbsoluteSize.Y + resize.targetSize.Y.Offset
		)
		resize.targetPosition = clampWindowPosition(
			resize.window,
			targetPosition,
			targetAbsoluteSize
		)
		return
	end
	if not activeDrag then
		return
	end
	local drag = activeDrag
	local delta = input.Position - drag.start
	local targetPosition = UDim2.new(
		drag.position.X.Scale,
		drag.position.X.Offset + delta.X,
		drag.position.Y.Scale,
		drag.position.Y.Offset + delta.Y
	)
	drag.target = clampWindowPosition(drag.window, targetPosition)
	local now = os.clock()
	local elapsed = math.max(now - drag.lastUpdate, 1 / 240)
	local pointerDelta = input.Position - drag.lastPointer
	local velocity = pointerDelta / elapsed
	if velocity.Magnitude > 900 then
		velocity = velocity.Unit * 900
	end
	drag.velocity = velocity
	drag.lastPointer = input.Position
	drag.lastUpdate = now
end)

connect(RunService.RenderStepped, function(deltaTime)
	if activeResize then
		local resize = activeResize
		local alpha = 1 - math.exp(-deltaTime * 28)
		resize.window.Size = resize.window.Size:Lerp(resize.targetSize, alpha)
		resize.window.Position = resize.window.Position:Lerp(resize.targetPosition, alpha)
		if resize.releasePending then
			local currentSize = resize.window.Size
			local currentPosition = resize.window.Position
			local sizeError = math.abs(currentSize.X.Scale - resize.targetSize.X.Scale)
				+ math.abs(currentSize.X.Offset - resize.targetSize.X.Offset)
				+ math.abs(currentSize.Y.Scale - resize.targetSize.Y.Scale)
				+ math.abs(currentSize.Y.Offset - resize.targetSize.Y.Offset)
			local positionError = math.abs(currentPosition.X.Scale - resize.targetPosition.X.Scale)
				+ math.abs(currentPosition.X.Offset - resize.targetPosition.X.Offset)
				+ math.abs(currentPosition.Y.Scale - resize.targetPosition.Y.Scale)
				+ math.abs(currentPosition.Y.Offset - resize.targetPosition.Y.Offset)
			if sizeError < 0.5 and positionError < 0.5 then
				activeResize = nil
			end
		end
	end
	if activeDrag then
		local alpha = 1 - math.exp(-deltaTime * 22)
		local window = activeDrag.window
		window.Position = window.Position:Lerp(activeDrag.target, alpha)
		return
	end
	if dragInertia then
		local inertia = dragInertia
		local window = inertia.window
		local viewport = root.AbsoluteSize
		local currentPosition = window.Position
		local velocity = inertia.velocity
		local targetPosition = UDim2.fromOffset(
			currentPosition.X.Scale * viewport.X + currentPosition.X.Offset + velocity.X * deltaTime,
			currentPosition.Y.Scale * viewport.Y + currentPosition.Y.Offset + velocity.Y * deltaTime
		)
		local clampedPosition = clampWindowPosition(window, targetPosition)
		if math.abs(clampedPosition.X.Offset - targetPosition.X.Offset) > 0.5 then
			velocity = Vector2.new(0, velocity.Y)
		end
		if math.abs(clampedPosition.Y.Offset - targetPosition.Y.Offset) > 0.5 then
			velocity = Vector2.new(velocity.X, 0)
		end
		window.Position = clampedPosition
		inertia.velocity = velocity * math.exp(-12 * deltaTime)
		if inertia.velocity.Magnitude < 22 then
			dragInertia = nil
		end
	end
end)

connect(UserInputService.InputEnded, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		if activeDrag then
			local drag = activeDrag
			if drag.velocity.Magnitude > 35 then
				dragInertia = {
					window = drag.window,
					velocity = drag.velocity,
				}
			end
			activeDrag = nil
		end
		if activeResize then
			activeResize.releasePending = true
		end
	end
end)

local function cleanup()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)
	stopSectionTitle()
	if backdropTween then
		backdropTween:Cancel()
	end
	if gui.Parent then
		gui:Destroy()
	end
	if _G.FlowersGui == gui then
		_G.FlowersGui = nil
	end
	if _G.FlowersCleanup == cleanup then
		_G.FlowersCleanup = nil
	end
end

_G.FlowersCleanup = cleanup
playBarEntrance()
connect(gui.Destroying, function()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)
	stopSectionTitle()
	if backdropTween then
		backdropTween:Cancel()
	end
	if _G.FlowersGui == gui then
		_G.FlowersGui = nil
	end
	if _G.FlowersCleanup == cleanup then
		_G.FlowersCleanup = nil
	end
end)
