--!strict
local _0xS0, _0xS1, _0xS2, _0xS3, _0xS4, _0xS5, _0xS6, _0xS7, _0xS8, _0xS9 = game:GetService("Players"), game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("GuiService"), game:GetService("HttpService"), game:GetService("TextService"), game:GetService("TeleportService"), game:GetService("Stats"), game:GetService("MarketplaceService")
local _0xP0: Player, _0xP1: PlayerGui = _0xS0.LocalPlayer, _0xS0.LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
local _0xU0: string, _0xI0: string, _0xD0: string, _0xC0: string, _0xC1: string = "iPhoneDynamicBar_UI", "80101065468420", "FloVV2", "FloVV2/Config.json", "FloVV2/RepoCache_Private.json"
local _0xR0: string, _0xR1: string, _0xR2: string, _0xRTree: string = "https://api.github.com/repos/PrinceBeebear/Private-Codes/contents/", "https://raw.githubusercontent.com/PrinceBeebear/Private-Codes/main/", "https://github.com/PrinceBeebear/Private-Codes", "https://api.github.com/repos/PrinceBeebear/Private-Codes/git/trees/main?recursive=1"
local _0xSupaUrl: string, _0xSupaKey: string = "https://eggflguqaoqccgtbbzlr.supabase.co", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVnZ2ZsZ3VxYW9xY2NndGJiemxyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM1MDgzNjIsImV4cCI6MjEwOTA4NDM2Mn0.tk2PPWBCDyHNLSlPiJ35uhnlGLLildmJvuRJgqHFKuA"
local _0xDndDefaults = { customName = "Hidden User", avatarId = "109728664560706", bannerId = "78420676701187" }

type _0xT0 = { id: string, label: string, asset: string }
type _0xT1 = { btn: TextButton, icon: ImageLabel, targetX: number }
type _0xT2 = { CommandBarKey: string, LastTab: string, Favorites: { [string]: boolean }, DoNotDisturb: boolean, CustomName: string, CustomAvatarId: string, CustomBannerId: string }
type _0xT3 = { cmd: string, desc: string, filePath: string, folder: string }

local _0xG0 = (_G :: any) :: { [string]: any }
if type(_0xG0._0xF10V_Cleanup) == "function" then _0xG0._0xF10V_Cleanup(); return end
local _0xOld: Instance? = _0xG0._0xF10V_Gui or _0xP1:FindFirstChild(_0xU0)
if _0xOld then _0xOld:Destroy(); _0xG0._0xF10V_Gui = nil; return end

local _0xF10V: { [string]: any } = {}
local _0xUI: { [string]: any } = {}
local _0xState: { [string]: any } = {
	MenuOpen = false,
	NotifActive = false,
	CmdMode = false,
	ListeningBind = false,
	CmdHasText = false,
	CmdListOpen = false,
	UsersActive = false,
	ServersActive = false,
	ConfigActive = false,
	ActiveTab = "",
	MenuSession = 0,
	NotifToken = 0,
	CaretAccum = 0,
	CaretShown = true,
	SelectedFolderFilter = "All",
	CurrentSuggest = "",
	UsersPerPage = 9,
	UsersPageNum = 1,
	UsersTotalPages = 1,
	UsersSubTab = "flow",
	UsersSearchQuery = "",
	ServersPerPage = 6,
	ServersPageNum = 1,
	ServersTotalPages = 1,
	ServersSubTab = "all",
	ServersSearchQuery = "",
}

_0xF10V._0x10 = function(_url: string, _method: string?, _body: string?, _extraHeaders: { [string]: string }?): string?
	local _req: any = (syn and (syn :: any).request) or (http and (http :: any).request) or (request :: any) or (http_request :: any)
	local _headers: { [string]: string } = { ["Accept"] = "application/json", ["Content-Type"] = "application/json" }
	if _extraHeaders then for _k, _v in pairs(_extraHeaders) do _headers[_k] = _v end end
	if type(_req) == "function" then
		local _ok: boolean, _res: any = pcall(function() return _req({ Url = _url, Method = _method or "GET", Headers = _headers, Body = _body }) end)
		if _ok and type(_res) == "table" and type(_res.Body) == "string" then
			local _st: number? = _res.StatusCode or _res.status_code
			if not _st or _st < 400 then return _res.Body end
		end
	end
	if (_method or "GET") == "GET" then
		local _ok2: boolean, _body2: string = pcall(function() return game:HttpGet(_url, true) end)
		if _ok2 and type(_body2) == "string" and _body2 ~= "" then return _body2 end
	end
	return nil
end

-- VERIFICACIÓN DE WB_list ANTES DE INICIAR EL SCRIPT
local function _0xCheckWBList(): boolean
	local _h: { [string]: string } = {
		["apikey"] = _0xSupaKey,
		["Authorization"] = "Bearer " .. _0xSupaKey,
	}
	local _raw: string? = _0xF10V._0x10(`{_0xSupaUrl}/rest/v1/WB_list?user_id=eq.{_0xP0.UserId}&select=status`, "GET", nil, _h)
	if _raw and _raw ~= "" then
		local _ok: boolean, _data: any = pcall(function() return _0xS5:JSONDecode(_raw) end)
		if _ok and type(_data) == "table" and #_data > 0 then
			local _status: number? = tonumber(_data[1].status)
				if _status == 2 then
					_0xP0:Kick("Has sido baneado de este script (Blacklist).")
					return false
				elseif _status == 1 then
					return true
				end
			end
		end
	-- WB_list es una whitelist: cualquier valor distinto de 1 no autoriza el acceso.
	_0xP0:Kick("No estás en la whitelist de este script.")
	return false
end

-- La comprobación de WB_list se realiza después de sincronizar los datos iniciales.

local _0xCfg: _0xT2 = { CommandBarKey = "F6", LastTab = "home", Favorites = {}, DoNotDisturb = false, CustomName = _0xDndDefaults.customName, CustomAvatarId = _0xDndDefaults.avatarId, CustomBannerId = _0xDndDefaults.bannerId }

_0xF10V._0x01 = function(): ()
	pcall(function() if not (type(isfolder) == "function" and isfolder(_0xD0)) and type(makefolder) == "function" then makefolder(_0xD0) end end)
end

_0xF10V._0x02 = function(): ()
	_0xF10V._0x01()
	pcall(function() if type(writefile) == "function" then writefile(_0xC0, _0xS5:JSONEncode(_0xCfg)) end end)
end

_0xF10V._0x03 = function(): ()
	_0xF10V._0x01()
	local _okLoad: boolean = false
	pcall(function()
		if type(isfile) == "function" and isfile(_0xC0) and type(readfile) == "function" then
			local _dec: any = _0xS5:JSONDecode(readfile(_0xC0))
			if type(_dec) == "table" then
				if type(_dec.CommandBarKey) == "string" and _dec.CommandBarKey ~= "" then _0xCfg.CommandBarKey = _dec.CommandBarKey end
				if type(_dec.LastTab) == "string" and _dec.LastTab ~= "" then _0xCfg.LastTab = _dec.LastTab end
				if type(_dec.Favorites) == "table" then _0xCfg.Favorites = _dec.Favorites end
				if type(_dec.DoNotDisturb) == "boolean" then _0xCfg.DoNotDisturb = _dec.DoNotDisturb end
				if type(_dec.CustomName) == "string" and _dec.CustomName ~= "" then _0xCfg.CustomName = _dec.CustomName end
				if type(_dec.CustomAvatarId) == "string" and _dec.CustomAvatarId ~= "" then _0xCfg.CustomAvatarId = _dec.CustomAvatarId end
				if type(_dec.CustomBannerId) == "string" and _dec.CustomBannerId ~= "" then _0xCfg.CustomBannerId = _dec.CustomBannerId end
				_okLoad = true
			end
		end
	end)
	if not _okLoad then _0xF10V._0x02() end
end
_0xF10V._0x03()

_0xF10V._0x04 = function(_kName: string): EnumKeyCode
	local _ok: boolean, _res: any = pcall(function() return (Enum.KeyCode :: any)[_kName] end)
	return if _ok and typeof(_res) == "EnumItem" then (_res :: EnumKeyCode) else Enum.KeyCode.F6
end

_0xF10V._0x05 = function(_kEnum: EnumKeyCode): string
	local _n: string = _kEnum.Name
	if #_n <= 3 then return string.upper(_n) end
	local _ok: boolean, _s: string = pcall(function() return _0xS2:GetStringForKeyCode(_kEnum) end)
	return if _ok and _s ~= "" and _s ~= " " then string.upper(_s) else string.upper(string.sub(_n, 1, 3))
end

local _0xBindKey: EnumKeyCode = _0xF10V._0x04(_0xCfg.CommandBarKey)
local _0xPal = {
	black = Color3.fromRGB(0, 0, 0), cardBg = Color3.fromRGB(16, 16, 18), rowBg = Color3.fromRGB(24, 24, 28), rowHover = Color3.fromRGB(34, 34, 38),
	white = Color3.fromRGB(255, 255, 255), softWhite = Color3.fromRGB(235, 235, 240), muted = Color3.fromRGB(158, 158, 164), suggest = Color3.fromRGB(115, 115, 122),
	border = Color3.fromRGB(88, 88, 94), bindPill = Color3.fromRGB(30, 30, 34), bindStroke = Color3.fromRGB(105, 105, 112), bindListening = Color3.fromRGB(210, 210, 215),
	ouiStroke = Color3.fromRGB(150, 154, 162), ouiCardBg = Color3.fromRGB(0, 0, 0), ouiMuted = Color3.fromRGB(185, 189, 198),
}

-- 2. SCREENGUI PRINCIPAL
local _0xGui: ScreenGui = Instance.new("ScreenGui")
_0xGui.Name, _0xGui.IgnoreGuiInset, _0xGui.ResetOnSpawn, _0xGui.ZIndexBehavior, _0xGui.Parent = _0xU0, true, false, Enum.ZIndexBehavior.Sibling, _0xP1
_0xG0._0xF10V_Gui = _0xGui

local _0xConns: { RBXScriptConnection }, _0xAlive: boolean = {}, true

local _0xRealGameName: string = "Roblox Experience"
local _0xGameNameCache: { [number]: string } = {}
_0xF10V._0xGetGameName = function(_placeId: number): string
	if _placeId <= 0 then return "Roblox" end
	if _0xGameNameCache[_placeId] then return _0xGameNameCache[_placeId] end
	local _ok: boolean, _info: any = pcall(function()
		local _svc: any = _0xS9
		return if type(_svc.GetProductInfoAsync) == "function" then _svc:GetProductInfoAsync(_placeId, Enum.InfoType.Asset) else _svc:GetProductInfo(_placeId, Enum.InfoType.Asset)
	end)
	if _ok and type(_info) == "table" and type(_info.Name) == "string" and _info.Name ~= "" and _info.Name ~= "UGC" then
		_0xGameNameCache[_placeId] = _info.Name
		return _info.Name
	end
	return "Roblox Experience"
end
task.spawn(function() _0xRealGameName = _0xF10V._0xGetGameName(game.PlaceId) end)

_0xF10V._0xCopyText = function(_txt: string): boolean
	local _fn: any = (setclipboard :: any) or (toclipboard :: any) or (Clipboard and (Clipboard :: any).set)
	if type(_fn) == "function" then
		local _ok: boolean = pcall(function() _fn(_txt) end)
		return _ok
	end
	return false
end

_0xF10V._0x06 = function(_id: string): string return `rbxthumb://type=Asset&id={_id}&w=420&h=420` end

_0xF10V._0x07 = function(_obj: GuiObject, _rad: number): UICorner
	local _c: UICorner = Instance.new("UICorner")
	_c.CornerRadius, _c.Parent = UDim.new(0, _rad), _obj
	return _c
end

_0xF10V._0x08 = function(_obj: GuiObject, _blur: number, _col: Color3, _trans: number, _off: UDim2): Instance?
	local _ok: boolean, _res: any = pcall(function()
		local _sh: any = Instance.new("UIShadow" :: any)
		_sh.BlurRadius, _sh.Color, _sh.Transparency, _sh.Offset = UDim.new(0, _blur), _col, _trans, _off
		pcall(function() _sh.ShowBehindParent = true end)
		_sh.Parent = _obj
		return _sh
	end)
	return if _ok then (_res :: Instance) else nil
end

_0xF10V._0x09 = function(_obj: GuiObject, _name: string, _col: Color3?): UIStroke
	local _st: UIStroke = Instance.new("UIStroke")
	_st.Name, _st.ApplyStrokeMode, _st.Color, _st.Thickness, _st.Transparency, _st.Parent = _name, Enum.ApplyStrokeMode.Border, _col or _0xPal.border, 1.2, 0.35, _obj
	local _gr: UIGradient = Instance.new("UIGradient")
	_gr.Rotation, _gr.Transparency, _gr.Parent = 90, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(0.6, 0.7), NumberSequenceKeypoint.new(0.88, 0.25), NumberSequenceKeypoint.new(1, 0.1) }), _st
	return _st
end

_0xF10V._0xOUI10CardStroke = function(_obj: GuiObject, _thickness: number?, _transparency: number?): UIStroke
	local _st: UIStroke = Instance.new("UIStroke")
	_st.ApplyStrokeMode, _st.Color, _st.Thickness, _st.Transparency, _st.Parent = Enum.ApplyStrokeMode.Border, _0xPal.ouiStroke, _thickness or 1.35, _transparency or 0.25, _obj
	local _gr: UIGradient = Instance.new("UIGradient")
	_gr.Rotation, _gr.Transparency, _gr.Parent = 90, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.42, 1), NumberSequenceKeypoint.new(0.76, 0.45), NumberSequenceKeypoint.new(1, 0.08) }), _st
	return _st
end

_0xF10V._0xOUI10Stroke = function(_obj: GuiObject, _thickness: number?, _transparency: number?): UIStroke
	local _st: UIStroke = Instance.new("UIStroke")
	_st.ApplyStrokeMode, _st.Color, _st.Thickness, _st.Transparency, _st.Parent = Enum.ApplyStrokeMode.Border, _0xPal.ouiStroke, _thickness or 1.25, _transparency or 0.28, _obj
	local _gr: UIGradient = Instance.new("UIGradient")
	_gr.Rotation, _gr.Transparency, _gr.Parent = 90, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(0.5, 0.78), NumberSequenceKeypoint.new(1, 0.12) }), _st
	return _st
end

_0xF10V._0xBubbleStroke = function(_obj: GuiObject): UIStroke
	local _st: UIStroke = Instance.new("UIStroke")
	_st.Name, _st.ApplyStrokeMode, _st.Color, _st.Thickness, _st.Transparency, _st.Parent = "SoftTopBottomContour", Enum.ApplyStrokeMode.Border, _0xPal.white, 1.1, 0.55, _obj
	local _gr: UIGradient = Instance.new("UIGradient")
	_gr.Rotation, _gr.Transparency, _gr.Parent = 90, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(0.11, 0.82), NumberSequenceKeypoint.new(0.2, 1), NumberSequenceKeypoint.new(0.8, 1), NumberSequenceKeypoint.new(0.89, 0.82), NumberSequenceKeypoint.new(1, 0.35) }), _st
	return _st
end

_0xF10V._0xSolidSoftStroke = function(_obj: GuiObject): UIStroke
	local _st: UIStroke = Instance.new("UIStroke")
	_st.Name, _st.ApplyStrokeMode, _st.Color, _st.Thickness, _st.Transparency, _st.Parent = "SoftSolidContour", Enum.ApplyStrokeMode.Border, Color3.fromRGB(155, 158, 166), 1.25, 0.18, _obj
	return _st
end

_0xF10V._0x0A = function(_parent: GuiObject): CanvasGroup
	local _wrap: CanvasGroup = Instance.new("CanvasGroup")
	_wrap.Name, _wrap.AnchorPoint, _wrap.Position, _wrap.Size, _wrap.BackgroundTransparency, _wrap.BorderSizePixel, _wrap.GroupTransparency, _wrap.Active, _wrap.ZIndex, _wrap.Parent = "BottomToTopWindowLight", Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, 0), UDim2.new(1, 60, 0, 110), 1, 0, 0, false, _parent.ZIndex + 1, _parent
	local _horizMask: UIGradient = Instance.new("UIGradient")
	_horizMask.Rotation, _horizMask.Transparency, _horizMask.Parent = 0, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.22, 0.15), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(0.78, 0.15), NumberSequenceKeypoint.new(1, 1) }), _wrap
	local _lt: Frame = Instance.new("Frame")
	_lt.Name, _lt.Size, _lt.BackgroundColor3, _lt.BackgroundTransparency, _lt.BorderSizePixel, _lt.Active, _lt.ZIndex, _lt.Parent = "LightBeam", UDim2.fromScale(1, 1), _0xPal.white, 0, 0, false, _wrap.ZIndex, _wrap
	local _lg: UIGradient = Instance.new("UIGradient")
	_lg.Rotation, _lg.Transparency, _lg.Parent = -90, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.87), NumberSequenceKeypoint.new(0.4, 0.94), NumberSequenceKeypoint.new(0.8, 0.985), NumberSequenceKeypoint.new(1, 1) }), _lt
	return _wrap
end

-- 3, 4, 5 & 6. BARRA DINÁMICA SUPERIOR, BOTONES, NOTIFICACIONES Y ELEMENTOS DE COMANDO
local _0xDims = { BaseW = 215, BaseH = 36, CmdBarW = 310, CmdBarH = 38, NotifW = 296, NotifH = 48, TopY = 12, IndOff = 0.75, IndOn = 0.15, BtnSize = 38, BtnRad = 19, BtnGap = 10, DropW = 312, DropMaxH = 360 }

local _0xTabs: { _0xT0 } = {
	{ id = "home", label = "Home", asset = _0xF10V._0x06("6034798461") },
	{ id = "commands", label = "Commands", asset = _0xF10V._0x06("98569163399333") },
	{ id = "users", label = "Users", asset = _0xF10V._0x06("118364573026678") },
	{ id = "servers", label = "Server list", asset = _0xF10V._0x06("133470080762210") },
	{ id = "config", label = "Config", asset = _0xF10V._0x06("107537126744306") },
}
local _0xBtnMap: { [string]: _0xT1 } = {}

_0xF10V._0x0B = function(): number return _0xDims.TopY + (if _0xState.NotifActive then _0xDims.NotifH else (if _0xState.CmdMode then _0xDims.CmdBarH else _0xDims.BaseH)) end
_0xF10V._0x0C = function(): number return _0xF10V._0x0B() + 4 end
_0xF10V._0x0D = function(): number return _0xDims.TopY + 12 end
_0xF10V._0x0E = function(): number return _0xF10V._0x0C() + 11 end

do
	local _bar: CanvasGroup = Instance.new("CanvasGroup")
	_bar.Name, _bar.AnchorPoint, _bar.Position, _bar.Size, _bar.BackgroundColor3, _bar.BackgroundTransparency, _bar.BorderSizePixel, _bar.GroupTransparency, _bar.ZIndex, _bar.ClipsDescendants, _bar.Parent = "iPhoneDynamicBar", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, -50), UDim2.fromOffset(_0xDims.BaseW, _0xDims.BaseH), _0xPal.black, 0, 0, 1, 12, true, _0xGui
	_0xF10V._0x07(_bar, 22)
	_0xF10V._0x08(_bar, 9, _0xPal.black, 0.22, UDim2.new(0, 0, 0, 1))
	_0xF10V._0x09(_bar, "iPhoneBarBottomContour", _0xPal.border)
	_0xUI.Bar = _bar

	local _icon: ImageLabel = Instance.new("ImageLabel")
	_icon.Name, _icon.AnchorPoint, _icon.Position, _icon.Size, _icon.BackgroundTransparency, _icon.Image, _icon.ImageColor3, _icon.ScaleType, _icon.Rotation, _icon.ZIndex, _icon.Parent = "ScriptIcon", Vector2.new(0, 0.5), UDim2.new(0, 13, 0.5, 0), UDim2.fromOffset(22, 22), 1, _0xF10V._0x06(_0xI0), _0xPal.white, Enum.ScaleType.Fit, 0, _bar.ZIndex + 4, _bar
	_0xUI.Icon = _icon

	local _lens: Frame = Instance.new("Frame")
	_lens.Name, _lens.AnchorPoint, _lens.Position, _lens.Size, _lens.BackgroundColor3, _lens.BorderSizePixel, _lens.ZIndex, _lens.Parent = "CameraLens", Vector2.new(0.5, 0.5), UDim2.new(1, -20, 0.5, 0), UDim2.fromOffset(10, 10), Color3.fromRGB(22, 22, 24), 0, _bar.ZIndex + 2, _bar
	_0xF10V._0x07(_lens, 5)
	_0xUI.Lens = _lens

	local _tz: Frame = Instance.new("Frame")
	_tz.Name, _tz.AnchorPoint, _tz.Position, _tz.Size, _tz.BackgroundTransparency, _tz.ZIndex, _tz.Parent = "HomeIndicatorTriggerZone", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, _0xF10V._0x0C()), UDim2.fromOffset(230, 14), 1, 15, _0xGui
	_0xUI.TriggerZone = _tz

	local _ind: Frame = Instance.new("Frame")
	_ind.Name, _ind.AnchorPoint, _ind.Position, _ind.Size, _ind.BackgroundColor3, _ind.BackgroundTransparency, _ind.BorderSizePixel, _ind.ZIndex, _ind.Parent = "HomeIndicatorBar", Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0, 5), UDim2.fromOffset(86, 4), _0xPal.white, 1, 0, 16, _tz
	_0xF10V._0x07(_ind, 2)
	_0xUI.Indicator = _ind

	local _nBox: CanvasGroup = Instance.new("CanvasGroup")
	_nBox.Name, _nBox.Size, _nBox.BackgroundTransparency, _nBox.GroupTransparency, _nBox.Visible, _nBox.ZIndex, _nBox.Parent = "NotifyContainer", UDim2.fromScale(1, 1), 1, 1, false, _bar.ZIndex + 3, _bar
	_0xUI.NotifBox = _nBox

	local _nTag: TextLabel = Instance.new("TextLabel")
	_nTag.Name, _nTag.Position, _nTag.Size, _nTag.BackgroundTransparency, _nTag.Font, _nTag.Text, _nTag.TextColor3, _nTag.TextSize, _nTag.TextXAlignment, _nTag.ZIndex, _nTag.Parent = "NotifyTag", UDim2.fromOffset(50, 8), UDim2.new(1, -66, 0, 12), 1, Enum.Font.GothamBold, "FLOW • SYSTEM", _0xPal.muted, 9, Enum.TextXAlignment.Left, _nBox.ZIndex + 1, _nBox
	_0xUI.NotifTag = _nTag

	local _nLbl: TextLabel = Instance.new("TextLabel")
	_nLbl.Name, _nLbl.Position, _nLbl.Size, _nLbl.BackgroundTransparency, _nLbl.Font, _nLbl.Text, _nLbl.TextColor3, _nLbl.TextSize, _nLbl.TextTruncate, _nLbl.TextXAlignment, _nLbl.TextYAlignment, _nLbl.ZIndex, _nLbl.Parent = "NotifyText", UDim2.fromOffset(50, 21), UDim2.new(1, -66, 0, 18), 1, Enum.Font.GothamMedium, "", _0xPal.softWhite, 12, Enum.TextTruncate.AtEnd, Enum.TextXAlignment.Left, Enum.TextYAlignment.Center, _nBox.ZIndex + 1, _nBox
	_0xUI.NotifLabel = _nLbl

	local _cBox: CanvasGroup = Instance.new("CanvasGroup")
	_cBox.Name, _cBox.Size, _cBox.BackgroundTransparency, _cBox.GroupTransparency, _cBox.Visible, _cBox.ZIndex, _cBox.Parent = "CommandBarContainer", UDim2.fromScale(1, 1), 1, 1, false, _bar.ZIndex + 4, _bar
	_0xUI.CmdBox = _cBox

	local _cPref: TextLabel = Instance.new("TextLabel")
	_cPref.Name, _cPref.AnchorPoint, _cPref.Position, _cPref.Size, _cPref.BackgroundTransparency, _cPref.Font, _cPref.Text, _cPref.TextColor3, _cPref.TextSize, _cPref.TextXAlignment, _cPref.ZIndex, _cPref.Parent = "CommandPrefix", Vector2.new(0, 0.5), UDim2.new(0, 14, 0.5, 0), UDim2.fromOffset(14, 22), 1, Enum.Font.GothamBlack, ">", _0xPal.white, 14, Enum.TextXAlignment.Left, _cBox.ZIndex + 1, _cBox

	local _cSug: TextLabel = Instance.new("TextLabel")
	_cSug.Name, _cSug.AnchorPoint, _cSug.Position, _cSug.Size, _cSug.BackgroundTransparency, _cSug.Font, _cSug.Text, _cSug.TextColor3, _cSug.TextSize, _cSug.TextXAlignment, _cSug.ZIndex, _cSug.Parent = "CommandSuggest", Vector2.new(0, 0.5), UDim2.new(0, 28, 0.5, 0), UDim2.new(1, -86, 0, 22), 1, Enum.Font.GothamMedium, "", _0xPal.suggest, 12, Enum.TextXAlignment.Left, _cBox.ZIndex + 1, _cBox
	_0xUI.CmdSuggest = _cSug

	local _cInp: TextBox = Instance.new("TextBox")
	_cInp.Name, _cInp.AnchorPoint, _cInp.Position, _cInp.Size, _cInp.BackgroundTransparency, _cInp.ClearTextOnFocus, _cInp.Font, _cInp.PlaceholderText, _cInp.PlaceholderColor3, _cInp.Text, _cInp.TextColor3, _cInp.TextSize, _cInp.TextXAlignment, _cInp.TextTruncate, _cInp.ZIndex, _cInp.Parent = "CommandInput", Vector2.new(0, 0.5), UDim2.new(0, 28, 0.5, 0), UDim2.new(1, -86, 0, 22), 1, false, Enum.Font.GothamMedium, "Prefijo + comando y cantidad...", _0xPal.muted, "", _0xPal.white, 12, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, _cBox.ZIndex + 2, _cBox
	_0xUI.CmdInput = _cInp

	local _caret: Frame = Instance.new("Frame")
	_caret.Name, _caret.AnchorPoint, _caret.Position, _caret.Size, _caret.BackgroundColor3, _caret.BorderSizePixel, _caret.Visible, _caret.ZIndex, _caret.Parent = "BlinkingCaret", Vector2.new(0, 0.5), UDim2.new(0, 28, 0.5, 0), UDim2.fromOffset(1.5, 14), _0xPal.white, 0, false, _cBox.ZIndex + 4, _cBox
	_0xUI.Caret = _caret

	local _bBtn: TextButton = Instance.new("TextButton")
	_bBtn.Name, _bBtn.AnchorPoint, _bBtn.Position, _bBtn.Size, _bBtn.BackgroundColor3, _bBtn.BackgroundTransparency, _bBtn.Font, _bBtn.Text, _bBtn.TextColor3, _bBtn.TextSize, _bBtn.AutoButtonColor, _bBtn.ZIndex, _bBtn.Parent = "CommandKeybindButton", Vector2.new(1, 0.5), UDim2.new(1, -10, 0.5, 0), UDim2.fromOffset(38, 22), _0xPal.bindPill, 0.05, Enum.Font.GothamBold, _0xF10V._0x05(_0xBindKey), _0xPal.white, 10, false, _cBox.ZIndex + 3, _cBox
	_0xF10V._0x07(_bBtn, 11)
	_0xUI.BindBtn = _bBtn

	local _bSt: UIStroke = Instance.new("UIStroke")
	_bSt.ApplyStrokeMode, _bSt.Color, _bSt.Thickness, _bSt.Transparency, _bSt.Parent = Enum.ApplyStrokeMode.Border, _0xPal.bindStroke, 1, 0.25, _bBtn
end

_0xF10V._0x0F = function(): ()
	for _id: string, _entry: _0xT1 in pairs(_0xBtnMap) do
		local _sel: boolean = (_id == _0xState.ActiveTab)
		_0xS1:Create(_entry.icon, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { ImageColor3 = if _sel then _0xPal.black else _0xPal.white, ImageTransparency = if _sel then 0 else 0.12 }):Play()
		_0xS1:Create(_entry.btn, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundColor3 = if _sel then _0xPal.white else _0xPal.black, BackgroundTransparency = if _sel then 0.45 else 0.52 }):Play()
	end
end

local _0xTweens: { [string]: any } = { Nav = {} }
_0xF10V._0x15 = function(): ()
	for _, _tw: Tween in ipairs(_0xTweens.Nav) do pcall(function() _tw:Cancel() end) end
	table.clear(_0xTweens.Nav)
end
_0xF10V._0x16 = function(_tw: Tween): Tween
	table.insert(_0xTweens.Nav, _tw)
	_tw:Play()
	return _tw
end

local _0xNotify = function(_message: string, _duration: number?, _justify: boolean?, _customTag: string?): ()
	if not _0xAlive or not _0xUI.Bar.Parent then return end
	_0xState.NotifToken += 1
	local _tok: number, _dur: number = _0xState.NotifToken, _duration or 2.8
	_0xState.NotifActive = true
	_0xUI.NotifTag.Text = _customTag or (if _justify then "WELCOME" else "FLOW • SYSTEM")
	_0xUI.NotifLabel.Text = _message
	_0xUI.Lens.Visible, _0xUI.CmdBox.Visible, _0xUI.NotifBox.Visible = false, false, true

	local _expInfo: TweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	_0xS1:Create(_0xUI.Bar, _expInfo, { Size = UDim2.fromOffset(_0xDims.NotifW, _0xDims.NotifH) }):Play()
	_0xS1:Create(_0xUI.TriggerZone, _expInfo, { Position = UDim2.new(0.5, 0, 0, _0xF10V._0x0C()) }):Play()
	if _0xState.MenuOpen then
		_0xF10V._0x15()
		local _ny: number = _0xF10V._0x0E()
		for _, _item: _0xT0 in ipairs(_0xTabs) do
			local _e: _0xT1? = _0xBtnMap[_item.id]
			if _e and _e.btn.Parent then _0xF10V._0x16(_0xS1:Create(_e.btn, _expInfo, { Position = UDim2.new(0.5, _e.targetX, 0, _ny) })) end
		end
	end

	if _0xTweens.Spin then _0xTweens.Spin:Cancel(); _0xTweens.Spin = nil end
	_0xUI.Icon.Visible, _0xUI.Icon.ImageTransparency, _0xUI.Icon.Rotation = true, 0, 0
	_0xS1:Create(_0xUI.Icon, TweenInfo.new(0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.fromOffset(26, 26) }):Play()
	local _spin: Tween = _0xS1:Create(_0xUI.Icon, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Rotation = 360 })
	_0xTweens.Spin = _spin
	_spin:Play()
	_spin.Completed:Connect(function(_st: EnumPlaybackState)
		if _st == Enum.PlaybackState.Completed and _0xUI.Icon.Parent then _0xUI.Icon.Rotation = 0 end
		if _0xTweens.Spin == _spin then _0xTweens.Spin = nil end
	end)
	_0xUI.NotifBox.GroupTransparency = 1
	_0xS1:Create(_0xUI.NotifBox, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()

	task.delay(_dur, function()
		if _0xState.NotifToken ~= _tok or not _0xAlive or not _0xUI.Bar.Parent or _0xState.CmdMode then return end
		_0xState.NotifActive = false
		_0xS1:Create(_0xUI.NotifBox, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { GroupTransparency = 1 }):Play()
		local _colInfo: TweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local _colTw: Tween = _0xS1:Create(_0xUI.Bar, _colInfo, { Size = UDim2.fromOffset(_0xDims.BaseW, _0xDims.BaseH) })
		_colTw:Play()
		_0xS1:Create(_0xUI.TriggerZone, _colInfo, { Position = UDim2.new(0.5, 0, 0, _0xF10V._0x0C()) }):Play()
		if _0xState.MenuOpen then
			_0xF10V._0x15()
			local _by: number = _0xF10V._0x0E()
			for _, _item: _0xT0 in ipairs(_0xTabs) do
				local _e: _0xT1? = _0xBtnMap[_item.id]
				if _e and _e.btn.Parent then _0xF10V._0x16(_0xS1:Create(_e.btn, _colInfo, { Position = UDim2.new(0.5, _e.targetX, 0, _by) })) end
			end
		end
		_0xS1:Create(_0xUI.Icon, _colInfo, { Position = UDim2.new(0, 13, 0.5, 0), Size = UDim2.fromOffset(22, 22), Rotation = 0 }):Play()
		_colTw.Completed:Connect(function(_st: EnumPlaybackState)
			if _st == Enum.PlaybackState.Completed and _0xState.NotifToken == _tok and not _0xState.CmdMode then
				_0xUI.NotifBox.Visible, _0xUI.Lens.Visible = false, true
			end
		end)
	end)
end
_0xF10V._0x1C = _0xNotify

_0xF10V._0x22 = function(): ()
	local _txt: string, _cPos: number = _0xUI.CmdInput.Text, _0xUI.CmdInput.CursorPosition
	local _sub: string = if _cPos > 0 then string.sub(_txt, 1, math.max(0, _cPos - 1)) else _txt
	local _sz: Vector2 = _0xS6:GetTextSize(_sub, _0xUI.CmdInput.TextSize, _0xUI.CmdInput.Font, Vector2.new(9999, 9999))
	_0xUI.Caret.Position = UDim2.new(0, 28 + math.min(_sz.X, math.max(0, _0xUI.CmdInput.AbsoluteSize.X - 2)), 0.5, 0)
	_0xState.CaretAccum, _0xState.CaretShown = 0, true
	if _0xState.CmdMode and _0xUI.CmdInput:IsFocused() then _0xUI.Caret.Visible = true end
end

-- 7. VENTANA DE LISTA DE COMANDOS CON FILTROS POR CARPETAS DEL REPOSITORIO
do
	local _drop: CanvasGroup = Instance.new("CanvasGroup")
	_drop.Name, _drop.AnchorPoint, _drop.Position, _drop.Size, _drop.BackgroundColor3, _drop.BackgroundTransparency, _drop.BorderSizePixel, _drop.GroupTransparency, _drop.Visible, _drop.ClipsDescendants, _drop.ZIndex, _drop.Parent = "CommandListWindow", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, _0xF10V._0x0C() + 20), UDim2.fromOffset(_0xDims.DropW, 130), _0xPal.cardBg, 0.08, 0, 1, false, true, 14, _0xGui
	_0xF10V._0x07(_drop, 14)
	_0xF10V._0x08(_drop, 12, _0xPal.black, 0.22, UDim2.new(0, 0, 0, 3))
	_0xF10V._0x09(_drop, "CmdDropContour", _0xPal.border)
	_0xF10V._0x0A(_drop)
	_0xUI.CmdDrop = _drop

	local _hdr: TextLabel = Instance.new("TextLabel")
	_hdr.Name, _hdr.Position, _hdr.Size, _hdr.BackgroundTransparency, _hdr.Font, _hdr.Text, _hdr.TextColor3, _hdr.TextSize, _hdr.TextXAlignment, _hdr.ZIndex, _hdr.Parent = "RepoHeader", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 14), 1, Enum.Font.GothamBold, "Commands • 0", _0xPal.muted, 10, Enum.TextXAlignment.Left, _drop.ZIndex + 2, _drop
	_0xUI.DropHeader = _hdr

	local _fBar: ScrollingFrame = Instance.new("ScrollingFrame")
	_fBar.Name, _fBar.Position, _fBar.Size, _fBar.BackgroundTransparency, _fBar.BorderSizePixel, _fBar.ScrollBarThickness, _fBar.ScrollingDirection, _fBar.AutomaticCanvasSize, _fBar.CanvasSize, _fBar.ZIndex, _fBar.Parent = "FolderFilterBar", UDim2.fromOffset(10, 26), UDim2.new(1, -20, 0, 24), 1, 0, 0, Enum.ScrollingDirection.X, Enum.AutomaticSize.X, UDim2.fromOffset(0, 0), _drop.ZIndex + 2, _drop
	_0xUI.FolderBar = _fBar

	local _fLay: UIListLayout = Instance.new("UIListLayout")
	_fLay.FillDirection, _fLay.VerticalAlignment, _fLay.Padding, _fLay.SortOrder, _fLay.Parent = Enum.FillDirection.Horizontal, Enum.VerticalAlignment.Center, UDim.new(0, 5), Enum.SortOrder.LayoutOrder, _fBar

	local _dScr: ScrollingFrame = Instance.new("ScrollingFrame")
	_dScr.Name, _dScr.Position, _dScr.Size, _dScr.BackgroundTransparency, _dScr.BorderSizePixel, _dScr.ScrollBarThickness, _dScr.ScrollBarImageColor3, _dScr.CanvasSize, _dScr.AutomaticCanvasSize, _dScr.ZIndex, _dScr.Parent = "CmdScroll", UDim2.fromOffset(8, 54), UDim2.new(1, -16, 1, -62), 1, 0, 2, _0xPal.border, UDim2.fromOffset(0, 0), Enum.AutomaticSize.Y, _drop.ZIndex + 2, _drop
	_0xUI.DropScroll = _dScr

	local _dPad: UIPadding = Instance.new("UIPadding")
	_dPad.PaddingTop, _dPad.PaddingBottom, _dPad.PaddingLeft, _dPad.PaddingRight, _dPad.Parent = UDim.new(0, 2), UDim.new(0, 6), UDim.new(0, 2), UDim.new(0, 4), _dScr

	local _dLay: UIListLayout = Instance.new("UIListLayout")
	_dLay.Padding, _dLay.SortOrder, _dLay.Parent = UDim.new(0, 4), Enum.SortOrder.LayoutOrder, _dScr
end

-- 8. PANEL FLOTANTE DE CONFIGURACIÓN (ESTILO PÍLDORAS OUI10 COMO SERVER LIST)
do
	local _cWin: CanvasGroup = Instance.new("CanvasGroup")
	_cWin.Name, _cWin.AnchorPoint, _cWin.Position, _cWin.Size, _cWin.BackgroundTransparency, _cWin.BorderSizePixel, _cWin.GroupTransparency, _cWin.Visible, _cWin.ClipsDescendants, _cWin.ZIndex, _cWin.Parent = "ConfigFloatingLayer", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 122), UDim2.fromOffset(380, if _0xCfg.DoNotDisturb then 266 else 92), 1, 0, 1, false, false, 14, _0xGui
	_0xUI.ConfigWin = _cWin

	local _cTitle: TextLabel = Instance.new("TextLabel")
	_cTitle.Position, _cTitle.Size, _cTitle.BackgroundTransparency, _cTitle.Font, _cTitle.Text, _cTitle.TextColor3, _cTitle.TextSize, _cTitle.TextXAlignment, _cTitle.ZIndex, _cTitle.Parent = UDim2.fromOffset(8, 0), UDim2.new(1, -16, 0, 18), 1, Enum.Font.GothamBold, "CONFIGURATION", _0xPal.ouiMuted, 10, Enum.TextXAlignment.Left, _cWin.ZIndex + 2, _cWin

	-- Bloque estilo barrita flotante de Server List para Modo No Molestar
	local _dndRow: Frame = Instance.new("Frame")
	_dndRow.Name, _dndRow.Position, _dndRow.Size, _dndRow.BackgroundColor3, _dndRow.BackgroundTransparency, _dndRow.BorderSizePixel, _dndRow.ZIndex, _dndRow.Parent = "DndPillBlock", UDim2.fromOffset(0, 22), UDim2.new(1, 0, 0, 44), _0xPal.black, 0.55, 0, _cWin.ZIndex + 2, _cWin
	_0xF10V._0x07(_dndRow, 22)
	_0xF10V._0xOUI10Stroke(_dndRow, 1.15, 0.28)
	_0xUI.DndRowBlock = _dndRow

	local _dndLbl: TextLabel = Instance.new("TextLabel")
	_dndLbl.Position, _dndLbl.Size, _dndLbl.BackgroundTransparency, _dndLbl.Font, _dndLbl.Text, _dndLbl.TextColor3, _dndLbl.TextSize, _dndLbl.TextXAlignment, _dndLbl.ZIndex, _dndLbl.Parent = UDim2.fromOffset(16, 6), UDim2.new(1, -80, 0, 16), 1, Enum.Font.GothamBold, "Modo no molestar", _0xPal.white, 12, Enum.TextXAlignment.Left, _dndRow.ZIndex + 1, _dndRow

	local _dndSub: TextLabel = Instance.new("TextLabel")
	_dndSub.Position, _dndSub.Size, _dndSub.BackgroundTransparency, _dndSub.Font, _dndSub.Text, _dndSub.TextColor3, _dndSub.TextSize, _dndSub.TextXAlignment, _dndSub.ZIndex, _dndSub.Parent = UDim2.fromOffset(16, 22), UDim2.new(1, -80, 0, 14), 1, Enum.Font.Gotham, "Oculta tu partida y usa perfil custom", _0xPal.ouiMuted, 10, Enum.TextXAlignment.Left, _dndRow.ZIndex + 1, _dndRow

	local _dndBtn: TextButton = Instance.new("TextButton")
	_dndBtn.Name, _dndBtn.AnchorPoint, _dndBtn.Position, _dndBtn.Size, _dndBtn.BackgroundColor3, _dndBtn.BackgroundTransparency, _dndBtn.BorderSizePixel, _dndBtn.AutoButtonColor, _dndBtn.Text, _dndBtn.ZIndex, _dndBtn.Parent = "DoNotDisturbToggle", Vector2.new(1, 0.5), UDim2.new(1, -12, 0.5, 0), UDim2.fromOffset(46, 24), if _0xCfg.DoNotDisturb then _0xPal.white else _0xPal.black, if _0xCfg.DoNotDisturb then 0.14 else 0.45, 0, false, "", _dndRow.ZIndex + 2, _dndRow
	_0xF10V._0x07(_dndBtn, 12)
	_0xF10V._0xOUI10Stroke(_dndBtn, 1.1, 0.3)
	_0xUI.DndToggleBtn = _dndBtn

	local _dndKnob: Frame = Instance.new("Frame")
	_dndKnob.AnchorPoint, _dndKnob.Position, _dndKnob.Size, _dndKnob.BackgroundColor3, _dndKnob.BorderSizePixel, _dndKnob.ZIndex, _dndKnob.Parent = Vector2.new(0, 0.5), if _0xCfg.DoNotDisturb then UDim2.new(0, 25, 0.5, 0) else UDim2.new(0, 3, 0.5, 0), UDim2.fromOffset(18, 18), if _0xCfg.DoNotDisturb then _0xPal.black else _0xPal.white, 0, _dndBtn.ZIndex + 1, _dndBtn
	_0xF10V._0x07(_dndKnob, 9)
	_0xUI.DndKnob = _dndKnob

	-- Contenedor flotante de campos (cada input es su propia cápsula como la barra de Server List)
	local _dndSettings: Frame = Instance.new("Frame")
	_dndSettings.Name, _dndSettings.Position, _dndSettings.Size, _dndSettings.BackgroundTransparency, _dndSettings.Visible, _dndSettings.ZIndex, _dndSettings.Parent = "DndProfileSettings", UDim2.fromOffset(0, 74), UDim2.new(1, 0, 0, 150), 1, _0xCfg.DoNotDisturb, _cWin.ZIndex + 2, _cWin
	_0xUI.DndSettingsGroup = _dndSettings

	local function _makeDndPillInput(_label: string, _placeholder: string, _value: string, _y: number): TextBox
		local _pillWrap: Frame = Instance.new("Frame")
		_pillWrap.Name, _pillWrap.Position, _pillWrap.Size, _pillWrap.BackgroundColor3, _pillWrap.BackgroundTransparency, _pillWrap.BorderSizePixel, _pillWrap.ZIndex, _pillWrap.Parent = `Pill_{_label}`, UDim2.fromOffset(0, _y), UDim2.new(1, 0, 0, 38), _0xPal.black, 0.55, 0, _dndSettings.ZIndex + 1, _dndSettings
		_0xF10V._0x07(_pillWrap, 19)
		_0xF10V._0xOUI10Stroke(_pillWrap, 1.15, 0.28)

		-- Cápsula interna izquierda para el título (imitando la píldora blanca activa de Server List)
		local _tagPill: Frame = Instance.new("Frame")
		_tagPill.AnchorPoint, _tagPill.Position, _tagPill.Size, _tagPill.BackgroundColor3, _tagPill.BackgroundTransparency, _tagPill.BorderSizePixel, _tagPill.ZIndex, _tagPill.Parent = Vector2.new(0, 0.5), UDim2.new(0, 5, 0.5, 0), UDim2.fromOffset(104, 28), _0xPal.white, 0.14, 0, _pillWrap.ZIndex + 1, _pillWrap
		_0xF10V._0x07(_tagPill, 14)

		local _lbl: TextLabel = Instance.new("TextLabel")
		_lbl.Size, _lbl.BackgroundTransparency, _lbl.Font, _lbl.Text, _lbl.TextColor3, _lbl.TextSize, _lbl.ZIndex, _lbl.Parent = UDim2.fromScale(1, 1), 1, Enum.Font.GothamBold, _label, _0xPal.black, 10, _tagPill.ZIndex + 1, _tagPill

		local _input: TextBox = Instance.new("TextBox")
		_input.Position, _input.Size, _input.BackgroundTransparency, _input.BorderSizePixel, _input.ClearTextOnFocus, _input.Font, _input.PlaceholderText, _input.PlaceholderColor3, _input.Text, _input.TextColor3, _input.TextSize, _input.TextXAlignment, _input.TextTruncate, _input.ZIndex, _input.Parent = UDim2.fromOffset(118, 0), UDim2.new(1, -132, 1, 0), 1, 0, false, Enum.Font.GothamMedium, _placeholder, _0xPal.ouiMuted, _value, _0xPal.white, 11, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, _pillWrap.ZIndex + 1, _pillWrap

		return _input
	end

	_0xUI.DndNameInput = _makeDndPillInput("Nombre", "Escribe un nombre...", _0xCfg.CustomName, 0)
	_0xUI.DndAvatarInput = _makeDndPillInput("Avatar ID", "ID de imagen...", _0xCfg.CustomAvatarId, 46)
	_0xUI.DndBannerInput = _makeDndPillInput("Banner ID", "ID de cartel...", _0xCfg.CustomBannerId, 92)

	local _stLbl: TextLabel = Instance.new("TextLabel")
	_stLbl.Position, _stLbl.Size, _stLbl.BackgroundTransparency, _stLbl.Font, _stLbl.Text, _stLbl.TextColor3, _stLbl.TextSize, _stLbl.TextXAlignment, _stLbl.ZIndex, _stLbl.Parent = UDim2.fromOffset(8, 224), UDim2.new(1, -16, 0, 18), 1, Enum.Font.GothamMedium, if _0xCfg.DoNotDisturb then "Estado: Activado (Perfil custom visible)" else "Estado: Desactivado (Perfil normal)", _0xPal.ouiMuted, 10, Enum.TextXAlignment.Left, _cWin.ZIndex + 2, _cWin
	_stLbl.Visible = _0xCfg.DoNotDisturb
	_0xUI.CfgStatusLbl = _stLbl
end

-- 9. APARTADO FLOTANTE USERS (SIN VENTANAS, ESTILO OUI10.lua)
local _0xFlowUsersCache: { any }, _0xFlowProfilesById: { [number]: any }, _0xFriendsCache: { any }, _0xGameThumbCache: { [number]: string } = {}, {}, {}, {}
local _0xKnownFlowOnlineIds: { [number]: boolean } = {}
local _0xInitialFlowSyncDone: boolean = false
local _0xUserCardSpinUntil: { [number]: number } = {}
local _0xKnownFlowDndState: { [number]: boolean } = {}

local _0xSubTabButtons: { [string]: TextButton } = {}
local _0xSubTabDefs = {
	{ id = "all", label = "In game", w = 58, x = 4 },
	{ id = "flow", label = "Flow users", w = 92, x = 64 },
	{ id = "friends", label = "Friends", w = 68, x = 158 },
}
local _0xRenderUsers: (_animateOUI10: boolean?) -> ()

local _0xUpdateSubTabVisuals = function(_animatePill: boolean): ()
	for _, _def in ipairs(_0xSubTabDefs) do
		local _b: TextButton? = _0xSubTabButtons[_def.id]
		if _b then
			local _isSel: boolean = (_0xState.UsersSubTab == _def.id)
			if _isSel then
				if _animatePill then
					_0xS1:Create(_0xUI.SubTabPill, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(_def.x, 3), Size = UDim2.fromOffset(_def.w, 24) }):Play()
				else
					_0xUI.SubTabPill.Position, _0xUI.SubTabPill.Size = UDim2.fromOffset(_def.x, 3), UDim2.fromOffset(_def.w, 24)
				end
			end
			_0xS1:Create(_b, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = if _isSel then _0xPal.black else _0xPal.ouiMuted }):Play()
		end
	end
end

do
	local _uLayer: CanvasGroup = Instance.new("CanvasGroup")
	_uLayer.Name, _uLayer.AnchorPoint, _uLayer.Position, _uLayer.Size, _uLayer.BackgroundTransparency, _uLayer.BorderSizePixel, _uLayer.GroupTransparency, _uLayer.Visible, _uLayer.ZIndex, _uLayer.Parent = "UsersFloatingLayer", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 122), UDim2.fromOffset(1020, 444), 1, 0, 1, false, 14, _0xGui
	_0xUI.UsersLayer = _uLayer

	local _uTop: Frame = Instance.new("Frame")
	_uTop.Name, _uTop.AnchorPoint, _uTop.Position, _uTop.Size, _uTop.BackgroundTransparency, _uTop.ZIndex, _uTop.Parent = "UsersFilterBar", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 4), UDim2.new(1, -40, 0, 34), 1, 15, _uLayer

	local _stHost: Frame = Instance.new("Frame")
	_stHost.Position, _stHost.Size, _stHost.BackgroundColor3, _stHost.BackgroundTransparency, _stHost.BorderSizePixel, _stHost.ZIndex, _stHost.Parent = UDim2.fromOffset(0, 2), UDim2.fromOffset(230, 30), _0xPal.black, 0.55, 0, 15, _uTop
	_0xF10V._0x07(_stHost, 15)
	_0xF10V._0xOUI10Stroke(_stHost, 1.15, 0.28)
	_0xUI.SubTabsHost = _stHost

	local _stPill: Frame = Instance.new("Frame")
	_stPill.Name, _stPill.Position, _stPill.Size, _stPill.BackgroundColor3, _stPill.BackgroundTransparency, _stPill.BorderSizePixel, _stPill.ZIndex, _stPill.Parent = "ActiveSubTabPill", UDim2.fromOffset(64, 3), UDim2.fromOffset(92, 24), _0xPal.white, 0.14, 0, 16, _stHost
	_0xF10V._0x07(_stPill, 12)
	_0xUI.SubTabPill = _stPill

	local _uCnt: TextLabel = Instance.new("TextLabel")
	_uCnt.Name, _uCnt.AnchorPoint, _uCnt.Position, _uCnt.Size, _uCnt.BackgroundTransparency, _uCnt.Font, _uCnt.Text, _uCnt.TextColor3, _uCnt.TextSize, _uCnt.TextXAlignment, _uCnt.ZIndex, _uCnt.Parent = "UsersCount", Vector2.new(1, 0.5), UDim2.new(1, -274, 0.5, 0), UDim2.fromOffset(100, 20), 1, Enum.Font.GothamMedium, "0 online", _0xPal.ouiMuted, 11, Enum.TextXAlignment.Right, 16, _uTop
	_0xUI.UsersCountLbl = _uCnt

	for _, _def in ipairs(_0xSubTabDefs) do
		local _tb: TextButton = Instance.new("TextButton")
		_tb.Name, _tb.Position, _tb.Size, _tb.BackgroundTransparency, _tb.BorderSizePixel, _tb.AutoButtonColor, _tb.Font, _tb.Text, _tb.TextColor3, _tb.TextSize, _tb.ZIndex, _tb.Parent = `SubTab_{_def.id}`, UDim2.fromOffset(_def.x, 3), UDim2.fromOffset(_def.w, 24), 1, 0, false, Enum.Font.GothamBold, _def.label, if _def.id == _0xState.UsersSubTab then _0xPal.black else _0xPal.ouiMuted, 11, 17, _stHost
		_0xSubTabButtons[_def.id] = _tb
		_tb.Activated:Connect(function()
			if _0xState.UsersSubTab == _def.id then return end
			_0xState.UsersSubTab, _0xState.UsersPageNum = _def.id, 1
			_0xUpdateSubTabVisuals(true)
			_0xRenderUsers(true)
		end)
	end

	local _uSBox: Frame = Instance.new("Frame")
	_uSBox.Name, _uSBox.AnchorPoint, _uSBox.Position, _uSBox.Size, _uSBox.BackgroundColor3, _uSBox.BackgroundTransparency, _uSBox.BorderSizePixel, _uSBox.ZIndex, _uSBox.Parent = "UsersSearchWrap", Vector2.new(1, 0), UDim2.new(1, 0, 0, 2), UDim2.fromOffset(260, 30), _0xPal.black, 0.55, 0, 15, _uTop
	_0xF10V._0x07(_uSBox, 16)
	_0xF10V._0xOUI10Stroke(_uSBox, 1.15, 0.28)
	_0xUI.UsersSearchBox = _uSBox

	local _uSrch: TextBox = Instance.new("TextBox")
	_uSrch.Name, _uSrch.Position, _uSrch.Size, _uSrch.BackgroundTransparency, _uSrch.BorderSizePixel, _uSrch.Font, _uSrch.PlaceholderText, _uSrch.PlaceholderColor3, _uSrch.Text, _uSrch.TextColor3, _uSrch.TextSize, _uSrch.TextXAlignment, _uSrch.ClearTextOnFocus, _uSrch.ZIndex, _uSrch.Parent = "UsersSearchInput", UDim2.fromOffset(14, 0), UDim2.new(1, -28, 1, 0), 1, 0, Enum.Font.Gotham, "Search user...", _0xPal.ouiMuted, "", _0xPal.white, 11, Enum.TextXAlignment.Left, false, 16, _uSBox
	_0xUI.UsersSearch = _uSrch

	local _uCards: Frame = Instance.new("Frame")
	_uCards.Name, _uCards.AnchorPoint, _uCards.Position, _uCards.Size, _uCards.BackgroundTransparency, _uCards.ZIndex, _uCards.Parent = "UsersCardsHost", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 48), UDim2.new(1, -40, 0, 344), 1, 15, _uLayer
	_0xUI.UsersCardsHost = _uCards

	local _uPag: Frame = Instance.new("Frame")
	_uPag.Name, _uPag.AnchorPoint, _uPag.Position, _uPag.Size, _uPag.BackgroundTransparency, _uPag.ZIndex, _uPag.Parent = "UsersPaginationBar", Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -2), UDim2.new(1, 0, 0, 32), 1, 15, _uLayer
	_0xUI.UsersPagBar = _uPag

	local _pLay: UIListLayout = Instance.new("UIListLayout")
	_pLay.FillDirection, _pLay.HorizontalAlignment, _pLay.VerticalAlignment, _pLay.Padding, _pLay.Parent = Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, UDim.new(0, 6), _uPag
end

-- 9B. APARTADO FLOTANTE SERVER LIST
local _0xServersCache: { any } = {}
local _0xRenderServers: (_animateOUI10: boolean?) -> ()
local _0xSrvTabButtons: { [string]: TextButton } = {}
local _0xSrvTabDefs = {
	{ id = "all", label = "All", w = 56, x = 4 },
	{ id = "players", label = "Most Players", w = 96, x = 62 },
	{ id = "ping", label = "Lowest Ping", w = 88, x = 160 },
}

local _0xUpdateSrvTabVisuals = function(_animatePill: boolean): ()
	for _, _def in ipairs(_0xSrvTabDefs) do
		local _b: TextButton? = _0xSrvTabButtons[_def.id]
		if _b then
			local _isSel: boolean = (_0xState.ServersSubTab == _def.id)
			if _isSel then
				if _animatePill then
					_0xS1:Create(_0xUI.SrvTabPill, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(_def.x, 3), Size = UDim2.fromOffset(_def.w, 24) }):Play()
				else
					_0xUI.SrvTabPill.Position, _0xUI.SrvTabPill.Size = UDim2.fromOffset(_def.x, 3), UDim2.fromOffset(_def.w, 24)
				end
			end
			_0xS1:Create(_b, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = if _isSel then _0xPal.black else _0xPal.ouiMuted }):Play()
		end
	end
end

do
	local _sLayer: CanvasGroup = Instance.new("CanvasGroup")
	_sLayer.Name, _sLayer.AnchorPoint, _sLayer.Position, _sLayer.Size, _sLayer.BackgroundTransparency, _sLayer.BorderSizePixel, _sLayer.GroupTransparency, _sLayer.Visible, _sLayer.ZIndex, _sLayer.Parent = "ServersFloatingLayer", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 122), UDim2.fromOffset(1020, 468), 1, 0, 1, false, 14, _0xGui
	_0xUI.ServersLayer = _sLayer

	local _sTop: Frame = Instance.new("Frame")
	_sTop.Name, _sTop.AnchorPoint, _sTop.Position, _sTop.Size, _sTop.BackgroundTransparency, _sTop.ZIndex, _sTop.Parent = "ServersFilterBar", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 4), UDim2.new(1, -40, 0, 34), 1, 15, _sLayer
	_0xUI.ServersTopBar = _sTop

	local _stHost: Frame = Instance.new("Frame")
	_stHost.Position, _stHost.Size, _stHost.BackgroundColor3, _stHost.BackgroundTransparency, _stHost.BorderSizePixel, _stHost.ZIndex, _stHost.Parent = UDim2.fromOffset(0, 2), UDim2.fromOffset(252, 30), _0xPal.black, 0.55, 0, 15, _sTop
	_0xF10V._0x07(_stHost, 15)
	_0xF10V._0xOUI10Stroke(_stHost, 1.15, 0.28)

	local _stPill: Frame = Instance.new("Frame")
	_stPill.Name, _stPill.Position, _stPill.Size, _stPill.BackgroundColor3, _stPill.BackgroundTransparency, _stPill.BorderSizePixel, _stPill.ZIndex, _stPill.Parent = "ActiveSrvTabPill", UDim2.fromOffset(4, 3), UDim2.fromOffset(56, 24), _0xPal.white, 0.14, 0, 16, _stHost
	_0xF10V._0x07(_stPill, 12)
	_0xUI.SrvTabPill = _stPill

	for _, _def in ipairs(_0xSrvTabDefs) do
		local _tb: TextButton = Instance.new("TextButton")
		_tb.Name, _tb.Position, _tb.Size, _tb.BackgroundTransparency, _tb.BorderSizePixel, _tb.AutoButtonColor, _tb.Font, _tb.Text, _tb.TextColor3, _tb.TextSize, _tb.ZIndex, _tb.Parent = `SrvTab_{_def.id}`, UDim2.fromOffset(_def.x, 3), UDim2.fromOffset(_def.w, 24), 1, 0, false, Enum.Font.GothamBold, _def.label, if _def.id == _0xState.ServersSubTab then _0xPal.black else _0xPal.ouiMuted, 11, 17, _stHost
		_0xSrvTabButtons[_def.id] = _tb
		_tb.Activated:Connect(function()
			if _0xState.ServersSubTab == _def.id then return end
			_0xState.ServersSubTab, _0xState.ServersPageNum = _def.id, 1
			_0xUpdateSrvTabVisuals(true)
			_0xRenderServers(true)
		end)
	end

	local _sCnt: TextLabel = Instance.new("TextLabel")
	_sCnt.Name, _sCnt.AnchorPoint, _sCnt.Position, _sCnt.Size, _sCnt.BackgroundTransparency, _sCnt.Font, _sCnt.Text, _sCnt.TextColor3, _sCnt.TextSize, _sCnt.TextXAlignment, _sCnt.ZIndex, _sCnt.Parent = "ServersCount", Vector2.new(1, 0.5), UDim2.new(1, -274, 0.5, 0), UDim2.fromOffset(120, 20), 1, Enum.Font.GothamMedium, "0 servers", _0xPal.ouiMuted, 11, Enum.TextXAlignment.Right, 16, _sTop
	_0xUI.ServersCountLbl = _sCnt

	local _sSBox: Frame = Instance.new("Frame")
	_sSBox.Name, _sSBox.AnchorPoint, _sSBox.Position, _sSBox.Size, _sSBox.BackgroundColor3, _sSBox.BackgroundTransparency, _sSBox.BorderSizePixel, _sSBox.ZIndex, _sSBox.Parent = "ServersSearchWrap", Vector2.new(1, 0), UDim2.new(1, 0, 0, 2), UDim2.fromOffset(260, 30), _0xPal.black, 0.55, 0, 15, _sTop
	_0xF10V._0x07(_sSBox, 16)
	_0xF10V._0xOUI10Stroke(_sSBox, 1.15, 0.28)

	local _sSrch: TextBox = Instance.new("TextBox")
	_sSrch.Name, _sSrch.Position, _sSrch.Size, _sSrch.BackgroundTransparency, _sSrch.BorderSizePixel, _sSrch.Font, _sSrch.PlaceholderText, _sSrch.PlaceholderColor3, _sSrch.Text, _sSrch.TextColor3, _sSrch.TextSize, _sSrch.TextXAlignment, _sSrch.ClearTextOnFocus, _sSrch.ZIndex, _sSrch.Parent = "ServersSearchInput", UDim2.fromOffset(14, 0), UDim2.new(1, -28, 1, 0), 1, 0, Enum.Font.Gotham, "Search job id / players...", _0xPal.ouiMuted, "", _0xPal.white, 11, Enum.TextXAlignment.Left, false, 16, _sSBox
	_0xUI.ServersSearch = _sSrch

	local _mCard: CanvasGroup = Instance.new("CanvasGroup")
	_mCard.Name, _mCard.AnchorPoint, _mCard.Position, _mCard.Size, _mCard.BackgroundColor3, _mCard.BackgroundTransparency, _mCard.BorderSizePixel, _mCard.ClipsDescendants, _mCard.ZIndex, _mCard.Parent = "MainServerCard", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 48), UDim2.new(1, -40, 0, 112), _0xPal.ouiCardBg, 0.42, 0, true, 16, _sLayer
	_0xF10V._0x07(_mCard, 18)
	_0xF10V._0xOUI10CardStroke(_mCard, 1.4, 0.22)
	_0xF10V._0x08(_mCard, 12, _0xPal.black, 0.25, UDim2.new(0, 0, 0, 3))
	_0xUI.MainSrvCard = _mCard

	local _mBan: ImageLabel = Instance.new("ImageLabel")
	_mBan.Size, _mBan.BackgroundColor3, _mBan.BorderSizePixel, _mBan.ScaleType, _mBan.ImageTransparency, _mBan.ZIndex, _mBan.Parent = UDim2.fromScale(1, 1), Color3.fromRGB(22, 24, 30), 0, Enum.ScaleType.Crop, 0.22, 16, _mCard
	_0xUI.MainSrvBanner = _mBan

	local _mShd: Frame = Instance.new("Frame")
	_mShd.Size, _mShd.BackgroundColor3, _mShd.BackgroundTransparency, _mShd.BorderSizePixel, _mShd.ZIndex, _mShd.Parent = UDim2.fromScale(1, 1), Color3.fromRGB(10, 11, 14), 0.2, 0, 17, _mCard
	local _mGrd: UIGradient = Instance.new("UIGradient")
	_mGrd.Rotation, _mGrd.Transparency, _mGrd.Parent = 0, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.06), NumberSequenceKeypoint.new(0.6, 0.28), NumberSequenceKeypoint.new(1, 0.48) }), _mShd

	local _mBdg: Frame = Instance.new("Frame")
	_mBdg.Position, _mBdg.Size, _mBdg.BackgroundColor3, _mBdg.BackgroundTransparency, _mBdg.BorderSizePixel, _mBdg.ZIndex, _mBdg.Parent = UDim2.fromOffset(20, 14), UDim2.fromOffset(118, 20), _0xPal.white, 0.14, 0, 18, _mCard
	_0xF10V._0x07(_mBdg, 10)
	local _mBdgTxt: TextLabel = Instance.new("TextLabel")
	_mBdgTxt.Size, _mBdgTxt.BackgroundTransparency, _mBdgTxt.Font, _mBdgTxt.Text, _mBdgTxt.TextColor3, _mBdgTxt.TextSize, _mBdgTxt.ZIndex, _mBdgTxt.Parent = UDim2.fromScale(1, 1), 1, Enum.Font.GothamBlack, "CURRENT SERVER", _0xPal.black, 9, 19, _mBdg

	local _mTit: TextLabel = Instance.new("TextLabel")
	_mTit.Position, _mTit.Size, _mTit.BackgroundTransparency, _mTit.Font, _mTit.Text, _mTit.TextColor3, _mTit.TextSize, _mTit.TextXAlignment, _mTit.TextTruncate, _mTit.ZIndex, _mTit.Parent = UDim2.fromOffset(20, 38), UDim2.new(1, -240, 0, 22), 1, Enum.Font.GothamBold, "Current Server", _0xPal.white, 16, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, 18, _mCard
	_0xUI.MainSrvTitle = _mTit

	local _mSt: TextLabel = Instance.new("TextLabel")
	_mSt.Position, _mSt.Size, _mSt.BackgroundTransparency, _mSt.Font, _mSt.Text, _mSt.TextColor3, _mSt.TextSize, _mSt.TextXAlignment, _mSt.ZIndex, _mSt.Parent = UDim2.fromOffset(20, 62), UDim2.new(1, -240, 0, 16), 1, Enum.Font.GothamMedium, "0/0 players · 0 ms", _0xPal.softWhite, 12, Enum.TextXAlignment.Left, 18, _mCard
	_0xUI.MainSrvStats = _mSt

	local _mJob: TextLabel = Instance.new("TextLabel")
	_mJob.Position, _mJob.Size, _mJob.BackgroundTransparency, _mJob.Font, _mJob.Text, _mJob.TextColor3, _mJob.TextSize, _mJob.TextXAlignment, _mJob.TextTruncate, _mJob.ZIndex, _mJob.Parent = UDim2.fromOffset(20, 81), UDim2.new(1, -240, 0, 15), 1, Enum.Font.Gotham, "Job ID: ...", _0xPal.ouiMuted, 10, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, 18, _mCard
	_0xUI.MainSrvJobLbl = _mJob

	local _mCopy: TextButton = Instance.new("TextButton")
	_mCopy.AnchorPoint, _mCopy.Position, _mCopy.Size, _mCopy.BackgroundColor3, _mCopy.BackgroundTransparency, _mCopy.BorderSizePixel, _mCopy.AutoButtonColor, _mCopy.Font, _mCopy.Text, _mCopy.TextColor3, _mCopy.TextSize, _mCopy.ZIndex, _mCopy.Parent = Vector2.new(1, 0.5), UDim2.new(1, -116, 0.5, 0), UDim2.fromOffset(92, 36), _0xPal.black, 0.3, 0, false, Enum.Font.GothamBold, "Copy ID", _0xPal.white, 11, 20, _mCard
	_0xF10V._0x07(_mCopy, 18)
	_0xF10V._0xOUI10Stroke(_mCopy, 1.25, 0.25)
	_mCopy.Activated:Connect(function()
		local _jid: string = tostring(game.JobId)
		if _0xF10V._0xCopyText(_jid) then _0xNotify("Server ID copiada al portapapeles", 2.2, false) else _0xNotify(`ID: {_jid}`, 3.0, false) end
	end)

	local _mRej: TextButton = Instance.new("TextButton")
	_mRej.AnchorPoint, _mRej.Position, _mRej.Size, _mRej.BackgroundColor3, _mRej.BackgroundTransparency, _mRej.BorderSizePixel, _mRej.AutoButtonColor, _mRej.Font, _mRej.Text, _mRej.TextColor3, _mRej.TextSize, _mRej.ZIndex, _mRej.Parent = Vector2.new(1, 0.5), UDim2.new(1, -18, 0.5, 0), UDim2.fromOffset(88, 36), _0xPal.white, 0.14, 0, false, Enum.Font.GothamBold, "Rejoin", _0xPal.black, 11, 20, _mCard
	_0xF10V._0x07(_mRej, 18)
	_mRej.Activated:Connect(function()
		_0xNotify("Rejoining current server...", 2.2, false)
		pcall(function() _0xS7:TeleportToPlaceInstance(game.PlaceId, game.JobId, _0xP0) end)
	end)

	local _sCards: Frame = Instance.new("Frame")
	_sCards.Name, _sCards.AnchorPoint, _sCards.Position, _sCards.Size, _sCards.BackgroundTransparency, _sCards.ZIndex, _sCards.Parent = "ServersCardsHost", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 174), UDim2.new(1, -40, 0, 244), 1, 15, _sLayer
	_0xUI.ServersCardsHost = _sCards

	local _sPag: Frame = Instance.new("Frame")
	_sPag.Name, _sPag.AnchorPoint, _sPag.Position, _sPag.Size, _sPag.BackgroundTransparency, _sPag.ZIndex, _sPag.Parent = "ServersPaginationBar", Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -2), UDim2.new(1, 0, 0, 32), 1, 15, _sLayer
	_0xUI.ServersPagBar = _sPag

	local _spLay: UIListLayout = Instance.new("UIListLayout")
	_spLay.FillDirection, _spLay.HorizontalAlignment, _spLay.VerticalAlignment, _spLay.Padding, _spLay.Parent = Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, UDim.new(0, 6), _sPag
end

local _0xMakeStatusBadge = function(_parent: GuiObject, _mode: string, _z: number): Frame
	local _badge: Frame = Instance.new("Frame")
	_badge.Name, _badge.AnchorPoint, _badge.Position, _badge.Size, _badge.BackgroundColor3, _badge.BorderSizePixel, _badge.ZIndex, _badge.Parent = "StatusBadge", Vector2.new(1, 1), UDim2.new(1, 2, 1, 2), UDim2.fromOffset(18, 18), Color3.fromRGB(16, 17, 20), 0, _z, _parent
	_0xF10V._0x07(_badge, 9)

	if _mode == "dnd" then
		local _dot: Frame = Instance.new("Frame")
		_dot.AnchorPoint, _dot.Position, _dot.Size, _dot.BackgroundColor3, _dot.BorderSizePixel, _dot.ZIndex, _dot.Parent = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(12, 12), Color3.fromRGB(242, 63, 67), 0, _z + 1, _badge
		_0xF10V._0x07(_dot, 6)
		local _bar: Frame = Instance.new("Frame")
		_bar.AnchorPoint, _bar.Position, _bar.Size, _bar.BackgroundColor3, _bar.BorderSizePixel, _bar.ZIndex, _bar.Parent = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(8, 2), _0xPal.white, 0, _z + 2, _dot
		_0xF10V._0x07(_bar, 1)
	elseif _mode == "idle" then
		local _moon: Frame = Instance.new("Frame")
		_moon.AnchorPoint, _moon.Position, _moon.Size, _moon.BackgroundColor3, _moon.BorderSizePixel, _moon.ZIndex, _moon.Parent = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(12, 12), Color3.fromRGB(240, 178, 50), 0, _z + 1, _badge
		_0xF10V._0x07(_moon, 6)
		local _cut: Frame = Instance.new("Frame")
		_cut.Position, _cut.Size, _cut.BackgroundColor3, _cut.BorderSizePixel, _cut.ZIndex, _cut.Parent = UDim2.fromOffset(-1, -1), UDim2.fromOffset(8, 8), Color3.fromRGB(16, 17, 20), 0, _z + 2, _moon
		_0xF10V._0x07(_cut, 4)
	elseif _mode == "offline" then
		local _off: Frame = Instance.new("Frame")
		_off.AnchorPoint, _off.Position, _off.Size, _off.BackgroundColor3, _off.BorderSizePixel, _off.ZIndex, _off.Parent = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(12, 12), Color3.fromRGB(128, 132, 142), 0, _z + 1, _badge
		_0xF10V._0x07(_off, 6)
		local _hole: Frame = Instance.new("Frame")
		_hole.AnchorPoint, _hole.Position, _hole.Size, _hole.BackgroundColor3, _hole.BorderSizePixel, _hole.ZIndex, _hole.Parent = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(5, 5), Color3.fromRGB(16, 17, 20), 0, _z + 2, _off
		_0xF10V._0x07(_hole, 3)
	else
		local _on: Frame = Instance.new("Frame")
		_on.AnchorPoint, _on.Position, _on.Size, _on.BackgroundColor3, _on.BorderSizePixel, _on.ZIndex, _on.Parent = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(12, 12), Color3.fromRGB(35, 165, 90), 0, _z + 1, _badge
		_0xF10V._0x07(_on, 6)
	end
	return _badge
end

local _0xFormatAgo = function(_sinceTs: number?): string
	if not _sinceTs or _sinceTs <= 0 then return "now" end
	local _diff: number = math.max(0, os.time() - _sinceTs)
	if _diff < 60 then return `{_diff}s` end
	local _m: number = math.floor(_diff / 60)
	if _m < 60 then return `{_m}m` end
	return `{math.floor(_m / 60)}h`
end

-- 10. CONEXIÓN AL REPOSITORIO GITHUB SIN ALTERAR NOMBRES DE COMANDOS
local _0xRepoFiles: { [string]: string }, _0xRepoFolders: { [string]: string }, _0xRepoDescs: { [string]: string }, _0xScriptCache: { [string]: string }, _0xAvailableCmds: { _0xT3 }, _0xDetectedFolders: { string } = {}, {}, {}, {}, {}, { "All" }

_0xF10V._0x11 = function(_rawPath: string): string
	local _base: string = string.match(_rawPath, "([^/\\]+)$") or _rawPath
	return (string.gsub(string.gsub(string.gsub(_base, "%.luau$", ""), "%.lua$", ""), "%.json$", ""))
end

_0xF10V._0x12 = function(_rawPath: string): string
	local _dir: string? = string.match(_rawPath, "^(.+)/[^/]+$")
	if not _dir or _dir == "" then return "Root" end
	return string.match(_dir, "^([^/]+)") or _dir
end

_0xF10V._0x13 = function(): ()
	table.clear(_0xAvailableCmds)
	local _folderSet: { [string]: boolean } = {}
	for _cmdName: string, _filePath: string in pairs(_0xRepoFiles) do
		local _fld: string = _0xRepoFolders[_cmdName] or _0xF10V._0x12(_filePath)
		_folderSet[_fld] = true
		table.insert(_0xAvailableCmds, { cmd = _cmdName, desc = _0xRepoDescs[_cmdName] or "", filePath = _filePath, folder = _fld })
	end
	table.clear(_0xDetectedFolders)
	table.insert(_0xDetectedFolders, "All")
	local _sortedFolders: { string } = {}
	for _fName: string in pairs(_folderSet) do table.insert(_sortedFolders, _fName) end
	table.sort(_sortedFolders, function(_a, _b)
		if _a == "Root" then return true end
		if _b == "Root" then return false end
		return string.lower(_a) < string.lower(_b)
	end)
	for _, _fName: string in ipairs(_sortedFolders) do table.insert(_0xDetectedFolders, _fName) end

	table.sort(_0xAvailableCmds, function(_a: _0xT3, _b: _0xT3): boolean
		local _fa: boolean, _fb: boolean = _0xCfg.Favorites[_a.cmd] == true, _0xCfg.Favorites[_b.cmd] == true
		if _fa ~= _fb then return _fa end
		return string.lower(_a.cmd) < string.lower(_b.cmd)
	end)
end

_0xF10V._0x14 = function(): ()
	task.spawn(function()
		local _loadedFromTree: boolean = false
		local _treeBody: string? = _0xF10V._0x10(_0xRTree)
		if _treeBody then
			local _okT: boolean, _decT: any = pcall(function() return _0xS5:JSONDecode(_treeBody) end)
			if _okT and type(_decT) == "table" and type(_decT.tree) == "table" then
				table.clear(_0xRepoFiles)
				table.clear(_0xRepoFolders)
				for _, _node: any in ipairs(_decT.tree) do
					if type(_node) == "table" and _node.type == "blob" and type(_node.path) == "string" and string.match(_node.path, "%.luau?$") then
						local _cName: string = _0xF10V._0x11(_node.path)
						_0xRepoFiles[_cName] = _node.path
						_0xRepoFolders[_cName] = _0xF10V._0x12(_node.path)
						_loadedFromTree = true
					end
				end
			end
		end

		if not _loadedFromTree then
			local function _scanContentsDir(_subPath: string)
				local _url: string = if _subPath == "" then _0xR0 else (_0xR0 .. _subPath)
				local _apiBody: string? = _0xF10V._0x10(_url)
				if not _apiBody then return end
				local _ok: boolean, _list: any = pcall(function() return _0xS5:JSONDecode(_apiBody) end)
				if _ok and type(_list) == "table" then
					for _, _item: any in ipairs(_list) do
						if type(_item) == "table" and type(_item.path) == "string" then
							if _item.type == "dir" then
								_scanContentsDir(_item.path)
							elseif _item.type == "file" and string.match(_item.path, "%.luau?$") then
								local _cName: string = _0xF10V._0x11(_item.path)
								_0xRepoFiles[_cName] = _item.path
								_0xRepoFolders[_cName] = _0xF10V._0x12(_item.path)
							end
						end
					end
				end
			end
			_scanContentsDir("")
		end

		if not next(_0xRepoFiles) then
			local _html: string? = _0xF10V._0x10(_0xR2)
			if _html then
				for _path: string in string.gmatch(_html, '/PrinceBeebear/Private%-Codes/blob/main/([^"]+%.luau?)') do
					local _cName: string = _0xF10V._0x11(_path)
					_0xRepoFiles[_cName] = _path
					_0xRepoFolders[_cName] = _0xF10V._0x12(_path)
				end
			end
		end

		if next(_0xRepoFiles) then
			_0xF10V._0x01()
			pcall(function() if type(writefile) == "function" then writefile(_0xC1, _0xS5:JSONEncode(_0xRepoFiles)) end end)
		end
		_0xF10V._0x13()
		if _0xState.CmdListOpen then _0xF10V._0x1A(string.gsub(_0xUI.CmdInput.Text, "^[;/!%.]+", "")) end

		for _cmdKey: string, _fp: string in pairs(_0xRepoFiles) do
			task.spawn(function()
				local _encodedPath: string = string.gsub(_fp, "[^/]+", function(_seg: string) return _0xS5:UrlEncode(_seg) end)
				local _code: string? = _0xF10V._0x10(_0xR1 .. _encodedPath)
				if _code and _code ~= "" then
					_0xScriptCache[_cmdKey] = _code
					local _firstLine: string? = string.match(_code, "^([^\r\n]+)")
					local _comment: string? = if _firstLine then string.match(_firstLine, "^%-%-%s*(.+)$") else nil
					if _comment and _comment ~= "!strict" then
						_0xRepoDescs[_cmdKey] = _comment
						_0xF10V._0x13()
					end
				end
			end)
		end
	end)
end
_0xF10V._0x14()

-- 11. SUPABASE, NOTIFICACIONES DE FLOW USERS CONECTADOS Y RENDERIZADO
local _0xSupaRequest = function(_method: string, _path: string, _body: any?, _extra: { [string]: string }?): any
	local _h: { [string]: string } = { ["apikey"] = _0xSupaKey, ["Authorization"] = "Bearer " .. _0xSupaKey }
	if _extra then for _k, _v in pairs(_extra) do _h[_k] = _v end end
	local _raw: string? = _0xF10V._0x10(_0xSupaUrl .. "/rest/v1" .. _path, _method, if _body then _0xS5:JSONEncode(_body) else nil, _h)
	if not _raw then return nil end
	if _raw == "" then return {} end
	local _ok: boolean, _dec: any = pcall(function() return _0xS5:JSONDecode(_raw) end)
	return if _ok then _dec else nil
end

local _0xResolveGameBanner = function(_placeId: number, _imgLabel: ImageLabel): ()
	if _placeId <= 0 then
		_imgLabel.Image = _0xF10V._0x06(_0xDndDefaults.bannerId)
		return
	end
	if _0xGameThumbCache[_placeId] then
		_imgLabel.Image = _0xGameThumbCache[_placeId]
		return
	end
	_imgLabel.Image = `rbxthumb://type=GameThumbnail&id={_placeId}&w=768&h=432`
	task.spawn(function()
		local _ok: boolean, _info: any = pcall(function()
			local _svc: any = _0xS9
			return if type(_svc.GetProductInfoAsync) == "function" then _svc:GetProductInfoAsync(_placeId, Enum.InfoType.Asset) else _svc:GetProductInfo(_placeId, Enum.InfoType.Asset)
		end)
		if _ok and type(_info) == "table" and tonumber(_info.IconImageAssetId) and tonumber(_info.IconImageAssetId) > 0 then
			local _url = `rbxthumb://type=Asset&id={tostring(_info.IconImageAssetId)}&w=768&h=432`
			_0xGameThumbCache[_placeId] = _url
			if _imgLabel.Parent then _imgLabel.Image = _url end
		else
			_0xGameThumbCache[_placeId] = `rbxthumb://type=GameThumbnail&id={_placeId}&w=768&h=432`
		end
	end)
end

local _0xRefreshOnlineFriends = function(): ()
	local _ok, _onlineList = pcall(function()
		local _plrAny: any = _0xP0
		return if type(_plrAny.GetFriendsOnlineAsync) == "function" then _plrAny:GetFriendsOnlineAsync(200) else _plrAny["GetFriendsOnline"](_plrAny, 200)
	end)
	local _loadedFriends: { any } = {}
	if _ok and type(_onlineList) == "table" then
		for _, _f in ipairs(_onlineList) do
			if _f.IsOnline ~= false then
				local _fPlaceId: number = tonumber(_f.PlaceId) or 0
				local _inGame: boolean = (_fPlaceId > 0)
				local _lastLoc: string = tostring(_f.LastLocation or "")
				if _lastLoc == "" or _lastLoc == "UGC" then
					_lastLoc = if _inGame then _0xF10V._0xGetGameName(_fPlaceId) else "Roblox Menu"
				end
				table.insert(_loadedFriends, {
					user_id = _f.VisitorId,
					name = if tostring(_f.DisplayName or "") ~= "" then _f.DisplayName else _f.UserName,
					username = _f.UserName,
					is_online = true,
					in_game = _inGame,
					place_id = _fPlaceId,
					job_id = tostring(_f.GameId or ""),
					game_name = _lastLoc,
				})
			end
		end
	else
		local _ok2, _pages = pcall(function() return _0xS0:GetFriendsAsync(_0xP0.UserId) end)
		if _ok2 and _pages then
			while true do
				for _, _item in ipairs(_pages:GetCurrentPage()) do
					if _item.IsOnline then
						table.insert(_loadedFriends, {
							user_id = _item.Id,
							name = if _item.DisplayName ~= "" then _item.DisplayName else _item.Username,
							username = _item.Username,
							is_online = true,
							in_game = false,
							place_id = 0,
							job_id = "",
							game_name = "Roblox Menu",
						})
					end
				end
				if _pages.IsFinished then break end
				pcall(function() _pages:AdvanceToNextPageAsync() end)
			end
		end
	end
	table.sort(_loadedFriends, function(_a, _b)
		if _a.in_game ~= _b.in_game then return _a.in_game end
		return string.lower(tostring(_a.name)) < string.lower(tostring(_b.name))
	end)
	_0xFriendsCache = _loadedFriends
	if _0xState.UsersActive and _0xState.UsersSubTab == "friends" then _0xRenderUsers(false) end
end
task.spawn(_0xRefreshOnlineFriends)

local _0xRebuildPagBar = function(_bar: Frame, _currPage: number, _totalPages: number, _onSelect: (_p: number) -> ()): ()
	for _, _c: Instance in ipairs(_bar:GetChildren()) do
		if _c:IsA("TextButton") then _c:Destroy() end
	end
	local function _makePagBtn(_txt: string, _order: number, _active: boolean, _cb: () -> ())
		local _b: TextButton = Instance.new("TextButton")
		_b.Size, _b.BackgroundColor3, _b.BackgroundTransparency, _b.BorderSizePixel, _b.AutoButtonColor, _b.Font, _b.Text, _b.TextColor3, _b.TextSize, _b.LayoutOrder, _b.ZIndex, _b.Parent = UDim2.fromOffset(28, 28), if _active then _0xPal.white else _0xPal.black, if _active then 0.14 else 0.5, 0, false, Enum.Font.GothamBold, _txt, if _active then _0xPal.black else _0xPal.white, 11, _order, 16, _bar
		_0xF10V._0x07(_b, 14)
		_0xF10V._0xOUI10Stroke(_b, 1.15, 0.25)
		_b.Activated:Connect(_cb)
	end
	_makePagBtn("‹", 1, false, function() if _currPage > 1 then _onSelect(_currPage - 1) end end)
	for _p = 1, _totalPages do
		local _isCurrent: boolean = (_p == _currPage)
		_makePagBtn(tostring(_p), 10 + _p, _isCurrent, function()
			if _isCurrent then return end
			_onSelect(_p)
		end)
	end
	_makePagBtn("›", 999, false, function() if _currPage < _totalPages then _onSelect(_currPage + 1) end end)
end

local _0xMergeUserEntry = function(_raw: any): any
	local _uid: number = tonumber(_raw.user_id) or 0
	local _prof: any = _0xFlowProfilesById[_uid]
	local _merged = table.clone(_raw)
	if _prof then
		if (_merged.banner_id == nil or tostring(_merged.banner_id) == "") and _prof.banner_id then _merged.banner_id = _prof.banner_id end
		if (_merged.avatar_id == nil or tostring(_merged.avatar_id) == "") and _prof.avatar_id then _merged.avatar_id = _prof.avatar_id end
		if (_merged.custom_name == nil or tostring(_merged.custom_name) == "") and _prof.custom_name then _merged.custom_name = _prof.custom_name end
		if _prof.badge ~= nil and _merged.badge == nil then _merged.badge = _prof.badge end
		if _prof.hide_name ~= nil and _merged.hide_name == nil then _merged.hide_name = _prof.hide_name end
		if _prof.hide_game ~= nil and _merged.hide_game == nil then _merged.hide_game = _prof.hide_game end
		if _prof.hide_players ~= nil and _merged.hide_players == nil then _merged.hide_players = _prof.hide_players end
		if _prof.hide_ping ~= nil and _merged.hide_ping == nil then _merged.hide_ping = _prof.hide_ping end
		if _prof.hide_avatar ~= nil and _merged.hide_avatar == nil then _merged.hide_avatar = _prof.hide_avatar end
		if _prof.block_join ~= nil and _merged.block_join == nil then _merged.block_join = _prof.block_join end
	end
	if _uid == _0xP0.UserId and _0xCfg.DoNotDisturb then
		_merged.block_join, _merged.hide_name, _merged.custom_name, _merged.hide_game, _merged.hide_players, _merged.hide_ping, _merged.hide_avatar, _merged.avatar_id, _merged.banner_id = true, true, _0xCfg.CustomName, true, true, true, true, _0xCfg.CustomAvatarId, _0xCfg.CustomBannerId
	end
	if tostring(_merged.game_name or "") == "UGC" then
		local _pid: number = tonumber(_merged.place_id) or 0
		_merged.game_name = if _pid == game.PlaceId then _0xRealGameName else _0xF10V._0xGetGameName(_pid)
	end
	return _merged
end

local _0xGetActiveUsersList = function(): { any }
	local _flowById: { [number]: any } = {}
	for _, _fu in ipairs(_0xFlowUsersCache) do _flowById[tonumber(_fu.user_id) or 0] = _fu end

	if _0xState.UsersSubTab == "flow" then
		local _res: { any } = {}
		for _, _fu in ipairs(_0xFlowUsersCache) do table.insert(_res, _0xMergeUserEntry(_fu)) end
		return _res
	elseif _0xState.UsersSubTab == "friends" then
		local _res: { any } = {}
		for _, _fr in ipairs(_0xFriendsCache) do
			if _fr.is_online then
				local _fData = _flowById[_fr.user_id]
				if _fData then
					local _entry = _0xMergeUserEntry(_fData)
					local _hasDnd: boolean = (_entry.hide_game == true or _entry.block_join == true or _entry.hide_name == true)
					if _hasDnd and tostring(_entry.banner_id or "") == "" then
						_entry.banner_id = _0xDndDefaults.bannerId
					end
					table.insert(_res, _entry)
				else
					local _inGame: boolean = (_fr.in_game == true and (tonumber(_fr.place_id) or 0) > 0)
					table.insert(_res, _0xMergeUserEntry({
						user_id = _fr.user_id,
						name = _fr.name,
						username = _fr.username,
						game_name = if _inGame then tostring(_fr.game_name or "Playing Roblox") else "Roblox Menu",
						place_id = if _inGame then tonumber(_fr.place_id) else 0,
						job_id = if _inGame then tostring(_fr.job_id or "") else "",
						banner_id = if _inGame then "" else _0xDndDefaults.bannerId,
						is_friend_entry = true,
						is_online = true,
						in_game = _inGame,
					}))
				end
			end
		end
		return _res
	else
		local _srvList: { any } = {}
		for _, _plr: Player in ipairs(_0xS0:GetPlayers()) do
			local _fData = _flowById[_plr.UserId]
			table.insert(_srvList, _0xMergeUserEntry({
				user_id = _plr.UserId, name = _plr.DisplayName, game_name = `@{_plr.Name}`, place_id = game.PlaceId, job_id = "",
				is_server_plr = true,
				banner_id = if _fData then _fData.banner_id else nil, avatar_id = if _fData then _fData.avatar_id else nil,
				hide_avatar = if _fData then _fData.hide_avatar else nil, hide_name = if _fData then _fData.hide_name else nil,
				hide_ping = if _fData then _fData.hide_ping else nil,
				custom_name = if _fData then _fData.custom_name else nil, badge = if _fData then _fData.badge else nil,
			}))
		end
		table.sort(_srvList, function(_a, _b) return string.lower(tostring(_a.name)) < string.lower(tostring(_b.name)) end)
		return _srvList
	end
end

_0xRenderUsers = function(_animateOUI10: boolean?): ()
	for _, _c: Instance in ipairs(_0xUI.UsersCardsHost:GetChildren()) do
		if _c:IsA("CanvasGroup") or _c:IsA("TextButton") then _c:Destroy() end
	end

	local _rawList: { any } = _0xGetActiveUsersList()
	local _q: string, _filtered: { any } = string.lower(_0xState.UsersSearchQuery), {}
	for _, _u in ipairs(_rawList) do
		local _uName: string = if _u.hide_name then tostring(_u.custom_name or "Hidden") else tostring(_u.name or "")
		if _q == "" or string.find(string.lower(_uName), _q, 1, true) then table.insert(_filtered, _u) end
	end

	_0xUI.UsersCountLbl.Text = `{#_filtered} online`
	_0xState.UsersTotalPages = math.max(1, math.ceil(#_filtered / _0xState.UsersPerPage))
	_0xState.UsersPageNum = math.clamp(_0xState.UsersPageNum, 1, _0xState.UsersTotalPages)
	_0xRebuildPagBar(_0xUI.UsersPagBar, _0xState.UsersPageNum, _0xState.UsersTotalPages, function(_p: number) _0xState.UsersPageNum = _p; _0xRenderUsers(true) end)

	local _startIdx: number = (_0xState.UsersPageNum - 1) * _0xState.UsersPerPage + 1
	local _endIdx: number = math.min(#_filtered, _startIdx + _0xState.UsersPerPage - 1)
	local _countOnPage: number = _endIdx - _startIdx + 1
	if _countOnPage <= 0 then return end

	local _cols, _rows, _gapX, _gapY = 3, 3, 14, 14
	local _hostW: number = if _0xUI.UsersCardsHost.AbsoluteSize.X > 0 then _0xUI.UsersCardsHost.AbsoluteSize.X else 980
	local _hostH: number = if _0xUI.UsersCardsHost.AbsoluteSize.Y > 0 then _0xUI.UsersCardsHost.AbsoluteSize.Y else 344
	local _cardW: number = math.floor((_hostW - (_gapX * (_cols - 1))) / _cols)
	local _cardH: number = math.floor((_hostH - (_gapY * (_rows - 1))) / _rows)

	for _slot = 1, _countOnPage do
		local _u = _filtered[_startIdx + _slot - 1]
		local _colIdx, _rowIdx = (_slot - 1) % _cols, math.floor((_slot - 1) / _cols)
		local _centerX: number = _colIdx * (_cardW + _gapX) + (_cardW * 0.5)
		local _centerY: number = _rowIdx * (_cardH + _gapY) + (_cardH * 0.5)

		local _canJoin: boolean = (not _u.block_join)
			and tostring(_u.job_id or "") ~= ""
			and tostring(_u.job_id) ~= tostring(game.JobId)
			and tonumber(_u.place_id) == tonumber(game.PlaceId)

		local _cardWrap: CanvasGroup = Instance.new("CanvasGroup")
		_cardWrap.Name, _cardWrap.AnchorPoint, _cardWrap.Size, _cardWrap.BackgroundColor3, _cardWrap.BackgroundTransparency, _cardWrap.BorderSizePixel, _cardWrap.ClipsDescendants, _cardWrap.ZIndex, _cardWrap.Parent = `UserCard_{_slot}`, Vector2.new(0.5, 0.5), UDim2.fromOffset(_cardW, _cardH), _0xPal.ouiCardBg, 0.45, 0, true, 16, _0xUI.UsersCardsHost
		_0xF10V._0x07(_cardWrap, 16)

		local _cardStroke: UIStroke = _0xF10V._0xOUI10CardStroke(_cardWrap, 1.35, if _animateOUI10 then 1 else 0.25)
		local _cardShadow: any = _0xF10V._0x08(_cardWrap, 12, Color3.fromRGB(0, 0, 0), if _animateOUI10 then 1 else 0.25, UDim2.new(0, 0, 0, 2))

		local _cardScale: UIScale = Instance.new("UIScale")
		_cardScale.Scale, _cardScale.Parent = 1, _cardWrap

		local _clipHost: Frame = Instance.new("Frame")
		_clipHost.Name, _clipHost.Size, _clipHost.BackgroundTransparency, _clipHost.BorderSizePixel, _clipHost.ClipsDescendants, _clipHost.ZIndex, _clipHost.Parent = "ClipHost", UDim2.fromScale(1, 1), 1, 0, true, 16, _cardWrap
		_0xF10V._0x07(_clipHost, 16)

		local _bannerId: string = tostring(_u.banner_id or _u.banner or "")
		local _placeIdNum: number = tonumber(_u.place_id) or 0
		local _bannerImg: ImageLabel = Instance.new("ImageLabel")
		_bannerImg.Name, _bannerImg.Size, _bannerImg.BackgroundColor3, _bannerImg.BorderSizePixel, _bannerImg.ScaleType, _bannerImg.ImageTransparency, _bannerImg.ZIndex, _bannerImg.Parent = "CardBanner", UDim2.fromScale(1, 1), Color3.fromRGB(24, 25, 30), 0, Enum.ScaleType.Crop, 0.25, 16, _clipHost
		if _bannerId ~= "" then
			_bannerImg.Image = `rbxthumb://type=Asset&id={_bannerId}&w=420&h=420`
		elseif _placeIdNum > 0 then
			_0xResolveGameBanner(_placeIdNum, _bannerImg)
		else
			_bannerImg.Image = _0xF10V._0x06(_0xDndDefaults.bannerId)
		end

		local _shade: Frame = Instance.new("Frame")
		_shade.Name, _shade.Size, _shade.BackgroundColor3, _shade.BackgroundTransparency, _shade.BorderSizePixel, _shade.ZIndex, _shade.Parent = "FrostFade", UDim2.fromScale(1, 1), Color3.fromRGB(10, 11, 14), 0.26, 0, 17, _clipHost
		local _shadeGrad: UIGradient = Instance.new("UIGradient")
		_shadeGrad.Rotation, _shadeGrad.Transparency, _shadeGrad.Parent = 0, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.55, 0.34), NumberSequenceKeypoint.new(1, 0.56) }), _shade

		local _avatarHolder: Frame = Instance.new("Frame")
		_avatarHolder.AnchorPoint, _avatarHolder.Position, _avatarHolder.Size, _avatarHolder.BackgroundTransparency, _avatarHolder.ZIndex, _avatarHolder.Parent = Vector2.new(0, 0.5), UDim2.new(0, 18, 0.5, 0), UDim2.fromOffset(56, 56), 1, 18, _cardWrap

		local _avatar: ImageLabel = Instance.new("ImageLabel")
		_avatar.Size, _avatar.BackgroundColor3, _avatar.BorderSizePixel, _avatar.ZIndex, _avatar.Parent = UDim2.fromScale(1, 1), Color3.fromRGB(26, 28, 34), 0, 18, _avatarHolder
			_avatar.Image = if _u.hide_avatar then `rbxthumb://type=Asset&id={tostring(_u.avatar_id or _0xDndDefaults.avatarId)}&w=150&h=150` else string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", tonumber(_u.user_id) or 0)
			_0xF10V._0x07(_avatar, 28)
			_0xF10V._0xSolidSoftStroke(_avatar)

		local _statusMode: string = if (_u.hide_name or _u.hide_game or _u.block_join) then "dnd" elseif (_u.is_friend_entry and not _u.in_game) then "idle" else "online"
		_0xMakeStatusBadge(_avatarHolder, _statusMode, 20)

		local _uidNum: number = tonumber(_u.user_id) or 0
		local _spinUntil: number = _0xUserCardSpinUntil[_uidNum] or 0
		if os.clock() < _spinUntil then
			local _spinWrap: Frame = Instance.new("Frame")
			_spinWrap.Name, _spinWrap.AnchorPoint, _spinWrap.Position, _spinWrap.Size, _spinWrap.BackgroundColor3, _spinWrap.BackgroundTransparency, _spinWrap.BorderSizePixel, _spinWrap.ZIndex, _spinWrap.Parent = "UserLoadingSpinner", Vector2.new(1, 0.5), UDim2.new(1, if _canJoin then -66 else -16, 0.5, 0), UDim2.fromOffset(26, 26), _0xPal.black, 0.35, 0, 24, _cardWrap
			_0xF10V._0x07(_spinWrap, 13)
			_0xF10V._0xOUI10Stroke(_spinWrap, 1.1, 0.3)

			local _ring: Frame = Instance.new("Frame")
			_ring.AnchorPoint, _ring.Position, _ring.Size, _ring.BackgroundTransparency, _ring.ZIndex, _ring.Parent = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(14, 14), 1, 25, _spinWrap
			_0xF10V._0x07(_ring, 7)

			local _ringStroke: UIStroke = Instance.new("UIStroke")
			_ringStroke.ApplyStrokeMode, _ringStroke.Color, _ringStroke.Thickness, _ringStroke.Parent = Enum.ApplyStrokeMode.Border, _0xPal.white, 2, _ring

			local _ringGrad: UIGradient = Instance.new("UIGradient")
			_ringGrad.Transparency, _ringGrad.Parent = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.65, 0.75),
				NumberSequenceKeypoint.new(1, 1),
			}), _ringStroke

			local _rotTw: Tween = _0xS1:Create(_ringGrad, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 360 })
			_rotTw:Play()

			task.delay(math.max(0.1, _spinUntil - os.clock()), function()
				pcall(function() _rotTw:Cancel() end)
				if _spinWrap.Parent then
					local _fadeOut: Tween = _0xS1:Create(_spinWrap, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
					_fadeOut:Play()
					_fadeOut.Completed:Connect(function()
						if _spinWrap.Parent then _spinWrap:Destroy() end
					end)
				end
			end)
		end

		local _rightMargin: number = if _canJoin then 148 else 96
		local _shownName: string = if _u.hide_name then tostring(_u.custom_name or "Hidden") else tostring(_u.name or "User")
		local _badgeCode: number = tonumber(_u.badge) or 0
		local _badgeGlyph: string = if _badgeCode == 1 then "\u{E000}" elseif _badgeCode == 2 then "\u{E003}" else ""

		local _lblName: TextLabel = Instance.new("TextLabel")
		_lblName.Position, _lblName.Size, _lblName.BackgroundTransparency, _lblName.Font, _lblName.Text, _lblName.TextColor3, _lblName.TextSize, _lblName.TextXAlignment, _lblName.TextTruncate, _lblName.ZIndex, _lblName.Parent = UDim2.fromOffset(86, 19), UDim2.new(1, -(_rightMargin + (if _badgeGlyph ~= "" then 18 else 0)), 0, 18), 1, Enum.Font.GothamBold, _shownName, _0xPal.white, 13, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, 18, _cardWrap

		if _badgeGlyph ~= "" then
			local _nameW: number = math.min(_0xS6:GetTextSize(_shownName, 13, Enum.Font.GothamBold, Vector2.new(999, 20)).X, math.max(20, _cardW - _rightMargin - 18))
			local _lblBadge: TextLabel = Instance.new("TextLabel")
			_lblBadge.Position, _lblBadge.Size, _lblBadge.BackgroundTransparency, _lblBadge.Font, _lblBadge.Text, _lblBadge.TextColor3, _lblBadge.TextSize, _lblBadge.TextXAlignment, _lblBadge.ZIndex, _lblBadge.Parent = UDim2.fromOffset(86 + _nameW + 4, 19), UDim2.fromOffset(16, 18), 1, Enum.Font.GothamBold, _badgeGlyph, _0xPal.white, 12, Enum.TextXAlignment.Left, 18, _cardWrap
		end

		local _lblGame: TextLabel = Instance.new("TextLabel")
		_lblGame.Position, _lblGame.Size, _lblGame.BackgroundTransparency, _lblGame.Font, _lblGame.Text, _lblGame.TextColor3, _lblGame.TextSize, _lblGame.TextXAlignment, _lblGame.TextTruncate, _lblGame.ZIndex, _lblGame.Parent = UDim2.fromOffset(86, 38), UDim2.new(1, -_rightMargin, 0, 15), 1, Enum.Font.GothamMedium, if _u.hide_game then "Hidden" else tostring(_u.game_name or "Roblox"), _0xPal.softWhite, 11, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, 18, _cardWrap

		local _lblStats: TextLabel = Instance.new("TextLabel")
		_lblStats.Position, _lblStats.Size, _lblStats.BackgroundTransparency, _lblStats.Font, _lblStats.TextColor3, _lblStats.TextSize, _lblStats.TextXAlignment, _lblStats.TextTruncate, _lblStats.ZIndex, _lblStats.Parent = UDim2.fromOffset(86, 55), UDim2.new(1, -_rightMargin, 0, 14), 1, Enum.Font.Gotham, _0xPal.ouiMuted, 10, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, 18, _cardWrap
		if _u.is_friend_entry then
			_lblStats.Text = if _u.hide_game then "Do Not Disturb" else `@{tostring(_u.username or "")}`
		elseif _u.is_server_plr then
			_lblStats.Text = if _u.hide_ping then "Do Not Disturb" else "In this server"
		else
			local _pStr: string = if _u.hide_players then "--/--" else `{_u.players or 0}/{_u.max_players or 0}`
			local _pingStr: string = if _u.hide_ping then "-- ms" else `{_u.ping or 0} ms`
			_lblStats.Text = `{_pStr} · {_pingStr}`
		end

		local _lblSrv: TextLabel = Instance.new("TextLabel")
		_lblSrv.Position, _lblSrv.Size, _lblSrv.BackgroundTransparency, _lblSrv.Font, _lblSrv.TextColor3, _lblSrv.TextSize, _lblSrv.TextXAlignment, _lblSrv.TextTruncate, _lblSrv.ZIndex, _lblSrv.Parent = UDim2.fromOffset(86, 71), UDim2.new(1, -_rightMargin, 0, 14), 1, Enum.Font.Gotham, _0xPal.ouiMuted, 9, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, 18, _cardWrap
		local _jobShort: string = if tostring(_u.job_id or "") ~= "" then string.sub(tostring(_u.job_id), 1, 8) else "hidden"
		_lblSrv.Text = if _u.is_server_plr then "" elseif _u.is_friend_entry then (if _u.in_game then "In Experience" else "Roblox App / Web") else `Job {_jobShort} · {_0xFormatAgo(tonumber(_u.since))}`
		_lblSrv.Visible = not _u.is_server_plr

		_cardWrap.MouseEnter:Connect(function()
			_cardWrap.ZIndex = 22
			_0xS1:Create(_cardScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.028 }):Play()
			_0xS1:Create(_cardWrap, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.3 }):Play()
		end)
		_cardWrap.MouseLeave:Connect(function()
			_cardWrap.ZIndex = 16
			_0xS1:Create(_cardScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			_0xS1:Create(_cardWrap, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.45 }):Play()
		end)

		if _canJoin then
			local _joinBtn: TextButton = Instance.new("TextButton")
			_joinBtn.Name, _joinBtn.AnchorPoint, _joinBtn.Position, _joinBtn.Size, _joinBtn.BackgroundColor3, _joinBtn.BackgroundTransparency, _joinBtn.BorderSizePixel, _joinBtn.AutoButtonColor, _joinBtn.Text, _joinBtn.ZIndex, _joinBtn.Parent = "JoinButton", Vector2.new(1, 0.5), UDim2.new(1, -14, 0.5, 0), UDim2.fromOffset(44, 44), _0xPal.black, 0.25, 0, false, "", 24, _cardWrap
			_0xF10V._0x07(_joinBtn, 22)
			local _joinStroke: UIStroke = _0xF10V._0xOUI10Stroke(_joinBtn, 1.35, if _animateOUI10 then 1 else 0.25)

			local _joinIcon: ImageLabel = Instance.new("ImageLabel")
			_joinIcon.AnchorPoint, _joinIcon.Position, _joinIcon.Size, _joinIcon.BackgroundTransparency, _joinIcon.Image, _joinIcon.ImageColor3, _joinIcon.ScaleType, _joinIcon.ZIndex, _joinIcon.Parent = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(20, 20), 1, _0xF10V._0x06("106640709678034"), _0xPal.white, Enum.ScaleType.Fit, 25, _joinBtn

			_joinBtn.MouseEnter:Connect(function() _0xS1:Create(_joinBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(36, 39, 48), Size = UDim2.fromOffset(47, 47) }):Play() end)
			_joinBtn.MouseLeave:Connect(function() _0xS1:Create(_joinBtn, TweenInfo.new(0.12), { BackgroundColor3 = _0xPal.black, Size = UDim2.fromOffset(44, 44) }):Play() end)
			_joinBtn.Activated:Connect(function()
				_0xNotify(`Joining {_shownName}...`, 2.2, false)
				pcall(function() _0xS7:TeleportToPlaceInstance(tonumber(_u.place_id) :: number, tostring(_u.job_id), _0xP0) end)
			end)

			if _animateOUI10 then
				task.delay((_slot - 1) * 0.035, function()
					if _joinStroke.Parent and _0xState.UsersActive then
						_0xS1:Create(_joinStroke, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.25 }):Play()
					end
				end)
			end
		end

		if _animateOUI10 then
			_cardWrap.Position, _cardWrap.GroupTransparency = UDim2.fromOffset(_centerX, _centerY + 8), 1
			task.delay((_slot - 1) * 0.035, function()
				if _cardWrap.Parent and _0xState.UsersActive then
					local _inInfo: TweenInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					_0xS1:Create(_cardWrap, _inInfo, { Position = UDim2.fromOffset(_centerX, _centerY), GroupTransparency = 0 }):Play()
					_0xS1:Create(_cardStroke, _inInfo, { Transparency = 0.25 }):Play()
					if _cardShadow then pcall(function() _0xS1:Create(_cardShadow, _inInfo, { Transparency = 0.25 }):Play() end) end
				end
			end)
		else
			_cardWrap.Position, _cardWrap.GroupTransparency = UDim2.fromOffset(_centerX, _centerY), 0
		end
	end
end

-- CARGA Y RENDERIZADO DE SERVER LIST (OUI10.lua)
local _0xFetchServers = function(): ()
	local _raw: string? = _0xF10V._0x10(`https://games.roblox.com/v1/games/{game.PlaceId}/servers/Public?sortOrder=Desc&limit=100`)
	local _list: { any } = {}
	local _loaded: boolean = false
	if _raw then
		local _ok: boolean, _dec: any = pcall(function() return _0xS5:JSONDecode(_raw) end)
		if _ok and type(_dec) == "table" and type(_dec.data) == "table" then
			_loaded = true
			for _, _srv in ipairs(_dec.data) do
				if type(_srv) == "table" and tostring(_srv.id or "") ~= "" then
					table.insert(_list, {
						id = tostring(_srv.id),
						playing = tonumber(_srv.playing) or 0,
						maxPlayers = tonumber(_srv.maxPlayers) or _0xS0.MaxPlayers,
						ping = math.floor((tonumber(_srv.ping) or 0) + 0.5),
						isCurrent = (tostring(_srv.id) == tostring(game.JobId)),
					})
				end
			end
		end
	end
	-- No sustituyas una caché válida por una lista vacía si Roblox falla o responde a medias.
	if _loaded then _0xServersCache = _list end
	if _0xState.ServersActive then _0xRenderServers(false) end
end
task.spawn(_0xFetchServers)

task.spawn(function()
	while _0xAlive do
		task.wait(30)
		if not _0xAlive then break end
		task.spawn(_0xFetchServers)
	end
end)

_0xRenderServers = function(_animateOUI10: boolean?): ()
	local _myPing: number = 0
	pcall(function() _myPing = math.floor(_0xP0:GetNetworkPing() * 1000 + 0.5) end)
	_0xResolveGameBanner(game.PlaceId, _0xUI.MainSrvBanner)
	_0xUI.MainSrvTitle.Text = _0xRealGameName
	_0xUI.MainSrvStats.Text = `{#_0xS0:GetPlayers()}/{_0xS0.MaxPlayers} players · {_myPing} ms`
	_0xUI.MainSrvJobLbl.Text = `Job ID: {if tostring(game.JobId) ~= "" then tostring(game.JobId) else "Local / Studio"}`

	for _, _c: Instance in ipairs(_0xUI.ServersCardsHost:GetChildren()) do
		if _c:IsA("CanvasGroup") or _c:IsA("TextButton") then _c:Destroy() end
	end

	local _q: string, _filtered: { any } = string.lower(_0xState.ServersSearchQuery), {}
	for _, _s in ipairs(_0xServersCache) do
		if not _s.isCurrent then
			local _txtMatch: string = string.lower(`{_s.id} {_s.playing}/{_s.maxPlayers}`)
			if _q == "" or string.find(_txtMatch, _q, 1, true) then table.insert(_filtered, _s) end
		end
	end

	if _0xState.ServersSubTab == "players" then
		table.sort(_filtered, function(_a, _b) return (_a.playing or 0) > (_b.playing or 0) end)
	elseif _0xState.ServersSubTab == "ping" then
		table.sort(_filtered, function(_a, _b)
			local _pa: number = if (_a.ping or 0) > 0 then _a.ping else 99999
			local _pb: number = if (_b.ping or 0) > 0 then _b.ping else 99999
			return _pa < _pb
		end)
	end

	_0xUI.ServersCountLbl.Text = `{#_filtered} servers`
	_0xState.ServersTotalPages = math.max(1, math.ceil(#_filtered / _0xState.ServersPerPage))
	_0xState.ServersPageNum = math.clamp(_0xState.ServersPageNum, 1, _0xState.ServersTotalPages)
	_0xRebuildPagBar(_0xUI.ServersPagBar, _0xState.ServersPageNum, _0xState.ServersTotalPages, function(_p: number) _0xState.ServersPageNum = _p; _0xRenderServers(true) end)

	local _startIdx: number = (_0xState.ServersPageNum - 1) * _0xState.ServersPerPage + 1
	local _endIdx: number = math.min(#_filtered, _startIdx + _0xState.ServersPerPage - 1)
	local _countOnPage: number = _endIdx - _startIdx + 1
	if _countOnPage <= 0 then return end

	local _cols, _rows, _gapX, _gapY = 3, 2, 14, 14
	local _hostW: number = if _0xUI.ServersCardsHost.AbsoluteSize.X > 0 then _0xUI.ServersCardsHost.AbsoluteSize.X else 980
	local _hostH: number = if _0xUI.ServersCardsHost.AbsoluteSize.Y > 0 then _0xUI.ServersCardsHost.AbsoluteSize.Y else 244
	local _cardW: number = math.floor((_hostW - (_gapX * (_cols - 1))) / _cols)
	local _cardH: number = math.floor((_hostH - (_gapY * (_rows - 1))) / _rows)

	for _slot = 1, _countOnPage do
		local _srv = _filtered[_startIdx + _slot - 1]
		local _colIdx, _rowIdx = (_slot - 1) % _cols, math.floor((_slot - 1) / _cols)
		local _centerX: number = _colIdx * (_cardW + _gapX) + (_cardW * 0.5)
		local _centerY: number = _rowIdx * (_cardH + _gapY) + (_cardH * 0.5)

		local _cardWrap: CanvasGroup = Instance.new("CanvasGroup")
		_cardWrap.Name, _cardWrap.AnchorPoint, _cardWrap.Size, _cardWrap.BackgroundColor3, _cardWrap.BackgroundTransparency, _cardWrap.BorderSizePixel, _cardWrap.ClipsDescendants, _cardWrap.ZIndex, _cardWrap.Parent = `ServerCard_{_slot}`, Vector2.new(0.5, 0.5), UDim2.fromOffset(_cardW, _cardH), _0xPal.ouiCardBg, 0.45, 0, true, 16, _0xUI.ServersCardsHost
		_0xF10V._0x07(_cardWrap, 16)

		local _cardStroke: UIStroke = _0xF10V._0xOUI10CardStroke(_cardWrap, 1.35, if _animateOUI10 then 1 else 0.25)
		local _cardShadow: any = _0xF10V._0x08(_cardWrap, 12, Color3.fromRGB(0, 0, 0), if _animateOUI10 then 1 else 0.25, UDim2.new(0, 0, 0, 2))

		local _cardScale: UIScale = Instance.new("UIScale")
		_cardScale.Scale, _cardScale.Parent = 1, _cardWrap

		local _clipHost: Frame = Instance.new("Frame")
		_clipHost.Size, _clipHost.BackgroundTransparency, _clipHost.BorderSizePixel, _clipHost.ClipsDescendants, _clipHost.ZIndex, _clipHost.Parent = UDim2.fromScale(1, 1), 1, 0, true, 16, _cardWrap
		_0xF10V._0x07(_clipHost, 16)

		local _bannerImg: ImageLabel = Instance.new("ImageLabel")
		_bannerImg.Size, _bannerImg.BackgroundColor3, _bannerImg.BorderSizePixel, _bannerImg.ScaleType, _bannerImg.ImageTransparency, _bannerImg.ZIndex, _bannerImg.Parent = UDim2.fromScale(1, 1), Color3.fromRGB(24, 25, 30), 0, Enum.ScaleType.Crop, 0.25, 16, _clipHost
		_0xResolveGameBanner(game.PlaceId, _bannerImg)

		local _shade: Frame = Instance.new("Frame")
		_shade.Size, _shade.BackgroundColor3, _shade.BackgroundTransparency, _shade.BorderSizePixel, _shade.ZIndex, _shade.Parent = UDim2.fromScale(1, 1), Color3.fromRGB(10, 11, 14), 0.26, 0, 17, _clipHost
		local _shadeGrad: UIGradient = Instance.new("UIGradient")
		_shadeGrad.Rotation, _shadeGrad.Transparency, _shadeGrad.Parent = 0, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.55, 0.34), NumberSequenceKeypoint.new(1, 0.56) }), _shade

		local _rightMargin: number = 114
		local _lblTitle: TextLabel = Instance.new("TextLabel")
		_lblTitle.Position, _lblTitle.Size, _lblTitle.BackgroundTransparency, _lblTitle.Font, _lblTitle.Text, _lblTitle.TextColor3, _lblTitle.TextSize, _lblTitle.TextXAlignment, _lblTitle.TextTruncate, _lblTitle.ZIndex, _lblTitle.Parent = UDim2.fromOffset(18, 19), UDim2.new(1, -_rightMargin, 0, 18), 1, Enum.Font.GothamBold, `Server #{_startIdx + _slot - 1}`, _0xPal.white, 14, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, 18, _cardWrap

		local _lblPlayers: TextLabel = Instance.new("TextLabel")
		_lblPlayers.Position, _lblPlayers.Size, _lblPlayers.BackgroundTransparency, _lblPlayers.Font, _lblPlayers.Text, _lblPlayers.TextColor3, _lblPlayers.TextSize, _lblPlayers.TextXAlignment, _lblPlayers.TextTruncate, _lblPlayers.ZIndex, _lblPlayers.Parent = UDim2.fromOffset(18, 41), UDim2.new(1, -_rightMargin, 0, 16), 1, Enum.Font.GothamMedium, `{_srv.playing}/{_srv.maxPlayers} players · {_srv.ping} ms`, _0xPal.softWhite, 11, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, 18, _cardWrap

		local _lblJob: TextLabel = Instance.new("TextLabel")
		_lblJob.Position, _lblJob.Size, _lblJob.BackgroundTransparency, _lblJob.Font, _lblJob.Text, _lblJob.TextColor3, _lblJob.TextSize, _lblJob.TextXAlignment, _lblJob.TextTruncate, _lblJob.ZIndex, _lblJob.Parent = UDim2.fromOffset(18, 63), UDim2.new(1, -_rightMargin, 0, 15), 1, Enum.Font.Gotham, `ID {string.sub(_srv.id, 1, 16)}...`, _0xPal.ouiMuted, 10, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, 18, _cardWrap

		_cardWrap.MouseEnter:Connect(function()
			_cardWrap.ZIndex = 22
			_0xS1:Create(_cardScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.028 }):Play()
			_0xS1:Create(_cardWrap, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.3 }):Play()
		end)
		_cardWrap.MouseLeave:Connect(function()
			_cardWrap.ZIndex = 16
			_0xS1:Create(_cardScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			_0xS1:Create(_cardWrap, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.45 }):Play()
		end)

		local _copyBtn: TextButton = Instance.new("TextButton")
		_copyBtn.Name, _copyBtn.AnchorPoint, _copyBtn.Position, _copyBtn.Size, _copyBtn.BackgroundColor3, _copyBtn.BackgroundTransparency, _copyBtn.BorderSizePixel, _copyBtn.AutoButtonColor, _copyBtn.Font, _copyBtn.Text, _copyBtn.TextColor3, _copyBtn.TextSize, _copyBtn.ZIndex, _copyBtn.Parent = "CopySrvIdBtn", Vector2.new(1, 0.5), UDim2.new(1, -60, 0.5, 0), UDim2.fromOffset(38, 38), _0xPal.black, 0.28, 0, false, Enum.Font.GothamBold, "ID", _0xPal.white, 10, 24, _cardWrap
		_0xF10V._0x07(_copyBtn, 19)
		local _copyStroke: UIStroke = _0xF10V._0xOUI10Stroke(_copyBtn, 1.25, if _animateOUI10 then 1 else 0.25)

		_copyBtn.MouseEnter:Connect(function() _0xS1:Create(_copyBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(36, 39, 48), Size = UDim2.fromOffset(41, 41) }):Play() end)
		_copyBtn.MouseLeave:Connect(function() _0xS1:Create(_copyBtn, TweenInfo.new(0.12), { BackgroundColor3 = _0xPal.black, Size = UDim2.fromOffset(38, 38) }):Play() end)
		_copyBtn.Activated:Connect(function()
			if _0xF10V._0xCopyText(_srv.id) then _0xNotify(`ID copiada: {string.sub(_srv.id, 1, 10)}...`, 2.2, false) else _0xNotify(`ID: {_srv.id}`, 3.0, false) end
		end)

		local _joinBtn: TextButton = Instance.new("TextButton")
		_joinBtn.Name, _joinBtn.AnchorPoint, _joinBtn.Position, _joinBtn.Size, _joinBtn.BackgroundColor3, _joinBtn.BackgroundTransparency, _joinBtn.BorderSizePixel, _joinBtn.AutoButtonColor, _joinBtn.Text, _joinBtn.ZIndex, _joinBtn.Parent = "JoinSrvBtn", Vector2.new(1, 0.5), UDim2.new(1, -14, 0.5, 0), UDim2.fromOffset(40, 40), _0xPal.black, 0.25, 0, false, "", 24, _cardWrap
		_0xF10V._0x07(_joinBtn, 20)
		local _joinStroke: UIStroke = _0xF10V._0xOUI10Stroke(_joinBtn, 1.35, if _animateOUI10 then 1 else 0.25)

		local _joinIcon: ImageLabel = Instance.new("ImageLabel")
		_joinIcon.AnchorPoint, _joinIcon.Position, _joinIcon.Size, _joinIcon.BackgroundTransparency, _joinIcon.Image, _joinIcon.ImageColor3, _joinIcon.ScaleType, _joinIcon.ZIndex, _joinIcon.Parent = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(19, 19), 1, _0xF10V._0x06("106640709678034"), _0xPal.white, Enum.ScaleType.Fit, 25, _joinBtn

		_joinBtn.MouseEnter:Connect(function() _0xS1:Create(_joinBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(36, 39, 48), Size = UDim2.fromOffset(43, 43) }):Play() end)
		_joinBtn.MouseLeave:Connect(function() _0xS1:Create(_joinBtn, TweenInfo.new(0.12), { BackgroundColor3 = _0xPal.black, Size = UDim2.fromOffset(40, 40) }):Play() end)
		_joinBtn.Activated:Connect(function()
			_0xNotify(`Joining server {string.sub(_srv.id, 1, 8)}...`, 2.2, false)
			pcall(function() _0xS7:TeleportToPlaceInstance(game.PlaceId, _srv.id, _0xP0) end)
		end)

		if _animateOUI10 then
			_cardWrap.Position, _cardWrap.GroupTransparency = UDim2.fromOffset(_centerX, _centerY + 8), 1
			task.delay((_slot - 1) * 0.035, function()
				if _cardWrap.Parent and _0xState.ServersActive then
					local _inInfo: TweenInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					_0xS1:Create(_cardWrap, _inInfo, { Position = UDim2.fromOffset(_centerX, _centerY), GroupTransparency = 0 }):Play()
					_0xS1:Create(_cardStroke, _inInfo, { Transparency = 0.25 }):Play()
					_0xS1:Create(_copyStroke, _inInfo, { Transparency = 0.25 }):Play()
					_0xS1:Create(_joinStroke, _inInfo, { Transparency = 0.25 }):Play()
					if _cardShadow then pcall(function() _0xS1:Create(_cardShadow, _inInfo, { Transparency = 0.25 }):Play() end) end
				end
			end)
		else
			_cardWrap.Position, _cardWrap.GroupTransparency = UDim2.fromOffset(_centerX, _centerY), 0
		end
	end
end

_0xUI.UsersSearch:GetPropertyChangedSignal("Text"):Connect(function() _0xState.UsersSearchQuery, _0xState.UsersPageNum = _0xUI.UsersSearch.Text, 1; _0xRenderUsers(false) end)
_0xUI.ServersSearch:GetPropertyChangedSignal("Text"):Connect(function() _0xState.ServersSearchQuery, _0xState.ServersPageNum = _0xUI.ServersSearch.Text, 1; _0xRenderServers(false) end)

local _0xPresenceSince: number = os.time()
local _0xSyncSupabase = function(): boolean
	if _0xRealGameName == "Roblox Experience" or _0xRealGameName == "UGC" then
		_0xRealGameName = _0xF10V._0xGetGameName(game.PlaceId)
	end

	local _pingVal: number = 0
	pcall(function() _pingVal = math.floor(_0xP0:GetNetworkPing() * 1000 + 0.5) end)
	if _pingVal <= 0 then pcall(function() _pingVal = math.floor(_0xS8.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end) end

	-- Marca al usuario local como activo SOLO tras ejecutar el script
	local _dnd: boolean = _0xCfg.DoNotDisturb
	local _presenceWriteOk: boolean = _0xSupaRequest("POST", "/flow_presence?on_conflict=user_id", {
		user_id = _0xP0.UserId, name = _0xP0.DisplayName, game_name = _0xRealGameName, game_id = game.GameId, place_id = game.PlaceId,
		job_id = if _dnd then "" else game.JobId, players = #_0xS0:GetPlayers(), max_players = _0xS0.MaxPlayers, ping = _pingVal,
		since = _0xPresenceSince, updated_at_ts = os.time(), is_active = true, block_join = _dnd, hide_name = _dnd,
		custom_name = if _dnd then _0xCfg.CustomName else "", hide_game = _dnd, hide_players = _dnd, hide_ping = _dnd, hide_avatar = _dnd,
		avatar_id = if _dnd then _0xCfg.CustomAvatarId else "", banner_id = if _dnd then _0xCfg.CustomBannerId else "",
	}, { Prefer = "resolution=merge-duplicates,return=minimal" }) ~= nil

	local _profiles: any = _0xSupaRequest("GET", "/flow_profiles?select=*")
	if type(_profiles) == "table" then
		local _map: { [number]: any } = {}
		for _, _p in ipairs(_profiles) do
			local _idNum = tonumber(_p.user_id)
			if _idNum then _map[_idNum] = _p end
		end
		_0xFlowProfilesById = _map
	end

	local _rows: any = _0xSupaRequest("GET", "/flow_presence?select=*&order=updated_at_ts.desc")
	if type(_rows) == "table" then
		local _now: number, _valid: { any } = os.time(), {}
		local _currentOnlineMap: { [number]: boolean } = {}
		local _newlyConnectedNames: { string } = {}

		for _, _r in ipairs(_rows) do
			-- Solo cuenta como conectado si ejecutó el script (is_active == true explícito y timestamp reciente)
			local _isAct: boolean = (_r.is_active == true)
			local _ts: number = tonumber(_r.updated_at_ts) or 0
			local _uid: number = tonumber(_r.user_id) or 0
			if _isAct and _uid > 0 and _ts > 0 and (_now - _ts) <= 90 then
				table.insert(_valid, _r)
				_currentOnlineMap[_uid] = true

				local _mergedUser = _0xMergeUserEntry(_r)
				local _isDndNow: boolean = (_mergedUser.block_join == true or _mergedUser.hide_name == true or _mergedUser.hide_game == true)
				local _wasOnline: boolean = (_0xKnownFlowOnlineIds[_uid] == true)
				local _prevDnd: boolean? = _0xKnownFlowDndState[_uid]

				if (not _wasOnline) or (_prevDnd ~= nil and _prevDnd ~= _isDndNow) then
					_0xUserCardSpinUntil[_uid] = os.clock() + 2.4
				end
				_0xKnownFlowDndState[_uid] = _isDndNow

				if _0xInitialFlowSyncDone and not _wasOnline and _uid ~= _0xP0.UserId then
					local _dispName: string = if _mergedUser.hide_name then tostring(_mergedUser.custom_name or "Hidden User") else tostring(_mergedUser.name or "Flow User")
					table.insert(_newlyConnectedNames, _dispName)
				end
			end
		end

		_0xKnownFlowOnlineIds = _currentOnlineMap
		_0xInitialFlowSyncDone = true
		_0xFlowUsersCache = _valid
		if _0xState.UsersActive then _0xRenderUsers(false) end

		if #_newlyConnectedNames > 0 and not _0xState.CmdMode then
			if #_newlyConnectedNames == 1 then
				_0xNotify(`{_newlyConnectedNames[1]} is now online`, 3.2, false, "FLOW • ONLINE")
			else
				_0xNotify(`{#_newlyConnectedNames} Flow users connected`, 3.2, false, "FLOW • ONLINE")
			end
		end
	end
	return _presenceWriteOk
end

-- Crea una entrada whitelist solo después de la sincronización de presencia.
-- Una fila existente no se modifica: Status=1 es whitelist y Status=2 blacklist.
local _0xEnsureWBListDefault = function(): boolean
	local _rows: any = _0xSupaRequest("GET", `/WB_list?user_id=eq.{_0xP0.UserId}&select=user_id,status`)
	if type(_rows) ~= "table" then return false end
	if #_rows > 0 then return true end
	local _created: any = _0xSupaRequest("POST", "/WB_list?on_conflict=user_id", {
		username = _0xP0.Name, user_id = _0xP0.UserId, status = 1,
	}, { Prefer = "resolution=ignore-duplicates,return=minimal" })
	return _created ~= nil
end

_0xUI.DndToggleBtn.Activated:Connect(function()
	_0xCfg.DoNotDisturb = not _0xCfg.DoNotDisturb
	_0xF10V._0x02()
	local _on: boolean = _0xCfg.DoNotDisturb
	_0xUserCardSpinUntil[_0xP0.UserId] = os.clock() + 2.2
	_0xKnownFlowDndState[_0xP0.UserId] = _on

	_0xS1:Create(_0xUI.DndToggleBtn, TweenInfo.new(0.18), { BackgroundColor3 = if _on then _0xPal.white else _0xPal.black, BackgroundTransparency = if _on then 0.14 else 0.45 }):Play()
	_0xS1:Create(_0xUI.DndKnob, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = if _on then UDim2.new(0, 25, 0.5, 0) else UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = if _on then _0xPal.black else _0xPal.white }):Play()
	_0xUI.CfgStatusLbl.Text = if _on then "Estado: Activado (Perfil custom visible)" else "Estado: Desactivado (Perfil normal)"
	_0xUI.DndSettingsGroup.Visible, _0xUI.CfgStatusLbl.Visible = _on, _on
	_0xS1:Create(_0xUI.ConfigWin, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(380, if _on then 266 else 92) }):Play()
	if _0xState.UsersActive then _0xRenderUsers(false) end
	task.spawn(_0xSyncSupabase)
end)

local _dndEditToken: number = 0
local function _bindLiveDndInput(_input: TextBox, _key: string): ()
	_input:GetPropertyChangedSignal("Text"):Connect(function()
		local _value: string = _input.Text
		if _key == "name" then _0xCfg.CustomName = _value
		elseif _key == "avatar" then _0xCfg.CustomAvatarId = _value
		else _0xCfg.CustomBannerId = _value end
		_0xF10V._0x02()
		_dndEditToken += 1
		local _token: number = _dndEditToken
		task.delay(0.7, function()
			if _token ~= _dndEditToken or not _0xAlive then return end
			if _0xState.UsersActive then _0xRenderUsers(false) end
			task.spawn(_0xSyncSupabase)
		end)
	end)
end
_bindLiveDndInput(_0xUI.DndNameInput, "name")
_bindLiveDndInput(_0xUI.DndAvatarInput, "avatar")
_bindLiveDndInput(_0xUI.DndBannerInput, "banner")


-- Primero se publica la presencia; después se crea el Status por defecto si falta;
-- al final se aplica la validación de whitelist/blacklist.
task.spawn(function()
	local _initialSyncOk: boolean = _0xSyncSupabase()
	if not _0xAlive or not _initialSyncOk then return end
	_0xEnsureWBListDefault()
	if not _0xCheckWBList() then return end
	while _0xAlive do
		_0xSyncSupabase()
		_0xRefreshOnlineFriends()
		task.wait(8)
	end
end)

-- 12. GESTOR DE VENTANAS Y MENÚ
_0xF10V._0x24 = function(_open: boolean): ()
	if _open then
		if _0xState.ConfigActive then return end
		_0xState.ConfigActive = true
		if _0xTweens.ConfigFade then _0xTweens.ConfigFade:Cancel(); _0xTweens.ConfigFade = nil end
		local _topOffset: number = if _0xState.MenuOpen then 122 else 82
		_0xUI.ConfigWin.Position, _0xUI.ConfigWin.GroupTransparency, _0xUI.ConfigWin.Visible = UDim2.new(0.5, 0, 0, _topOffset - 8), 1, true
		local _tw = _0xS1:Create(_0xUI.ConfigWin, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, _topOffset), GroupTransparency = 0 })
		_0xTweens.ConfigFade = _tw
		_tw:Play()
	else
		if not _0xState.ConfigActive then return end
		_0xState.ConfigActive = false
		if _0xTweens.ConfigFade then _0xTweens.ConfigFade:Cancel(); _0xTweens.ConfigFade = nil end
		local _tw = _0xS1:Create(_0xUI.ConfigWin, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { GroupTransparency = 1 })
		_0xTweens.ConfigFade = _tw
		_tw:Play()
		_tw.Completed:Connect(function(_st: EnumPlaybackState) if _st == Enum.PlaybackState.Completed and not _0xState.ConfigActive then _0xUI.ConfigWin.Visible = false end end)
	end
end

_0xF10V._0x17 = function(): ()
	if not _0xAlive or _0xState.MenuOpen or _0xState.CmdHasText then return end
	_0xState.MenuOpen = true
	_0xState.MenuSession += 1
	_0xF10V._0x15()
	local _openY: number, _hiddenY: number = _0xF10V._0x0E(), _0xF10V._0x0D()
	_0xF10V._0x16(_0xS1:Create(_0xUI.Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = _0xDims.IndOn, Size = UDim2.fromOffset(96, 4) }))
	for _, _item: _0xT0 in ipairs(_0xTabs) do
		local _entry: _0xT1? = _0xBtnMap[_item.id]
		if _entry and _entry.btn.Parent then
			if not _entry.btn.Visible then
				_entry.btn.Position, _entry.btn.Size, _entry.icon.Size, _entry.icon.ImageTransparency = UDim2.new(0.5, 0, 0, _hiddenY), UDim2.fromOffset(18, 18), UDim2.fromOffset(11, 11), 0.85
			end
			_entry.btn.Visible = true
			_0xF10V._0x16(_0xS1:Create(_entry.btn, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, _entry.targetX, 0, _openY), Size = UDim2.fromOffset(_0xDims.BtnSize, _0xDims.BtnSize) }))
			_0xF10V._0x16(_0xS1:Create(_entry.icon, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(19, 19), ImageTransparency = 0 }))
		end
	end
end

_0xF10V._0x18 = function(): ()
	if not _0xState.MenuOpen then return end
	_0xState.MenuOpen = false
	_0xState.MenuSession += 1
	local _sess: number, _hiddenY: number = _0xState.MenuSession, _0xF10V._0x0D()
	_0xF10V._0x15()
	_0xF10V._0x16(_0xS1:Create(_0xUI.Indicator, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = _0xDims.IndOff, Size = UDim2.fromOffset(86, 4) }))
	for _, _item: _0xT0 in ipairs(_0xTabs) do
		local _entry: _0xT1? = _0xBtnMap[_item.id]
		if _entry and _entry.btn.Parent then
			local _ab: Tween = _0xF10V._0x16(_0xS1:Create(_entry.btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 0, _hiddenY), Size = UDim2.fromOffset(16, 16) }))
			_0xF10V._0x16(_0xS1:Create(_entry.icon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.fromOffset(10, 10), ImageTransparency = 1 }))
			_ab.Completed:Connect(function(_st: EnumPlaybackState)
				if _st == Enum.PlaybackState.Completed and not _0xState.MenuOpen and _0xState.MenuSession == _sess and _entry.btn.Parent then _entry.btn.Visible = false end
			end)
		end
	end
end

-- 13. VENTANA DE COMMANDS CON FILTROS POR CARPETAS
_0xF10V._0x19 = function(): ()
	if not _0xState.CmdListOpen then return end
	_0xState.CmdListOpen = false
	if _0xTweens.DropFade then _0xTweens.DropFade:Cancel(); _0xTweens.DropFade = nil end
	local _tw: Tween = _0xS1:Create(_0xUI.CmdDrop, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { GroupTransparency = 1 })
	_0xTweens.DropFade = _tw
	_tw:Play()
	_tw.Completed:Connect(function(_st: EnumPlaybackState) if _st == Enum.PlaybackState.Completed and not _0xState.CmdListOpen then _0xUI.CmdDrop.Visible = false end end)
end

_0xF10V._0xRebuildFolderPills = function(_filter: string): ()
	for _, _child: Instance in ipairs(_0xUI.FolderBar:GetChildren()) do
		if _child:IsA("TextButton") then _child:Destroy() end
	end
	if not table.find(_0xDetectedFolders, _0xState.SelectedFolderFilter) then
		_0xState.SelectedFolderFilter = "All"
	end
	for _i: number, _fName: string in ipairs(_0xDetectedFolders) do
		local _active: boolean = (_0xState.SelectedFolderFilter == _fName)
		local _txtW: number = _0xS6:GetTextSize(_fName, 10, Enum.Font.GothamBold, Vector2.new(400, 20)).X
		local _pill: TextButton = Instance.new("TextButton")
		_pill.Name, _pill.Size, _pill.BackgroundColor3, _pill.BackgroundTransparency, _pill.BorderSizePixel, _pill.AutoButtonColor, _pill.Font, _pill.Text, _pill.TextColor3, _pill.TextSize, _pill.LayoutOrder, _pill.ZIndex, _pill.Parent = `Folder_{_fName}`, UDim2.fromOffset(_txtW + 16, 20), if _active then _0xPal.white else _0xPal.rowBg, if _active then 0.1 else 0.3, 0, false, Enum.Font.GothamBold, _fName, if _active then _0xPal.black else _0xPal.softWhite, 10, _i, _0xUI.FolderBar.ZIndex + 1, _0xUI.FolderBar
		_0xF10V._0x07(_pill, 10)
		local _pSt: UIStroke = Instance.new("UIStroke")
		_pSt.ApplyStrokeMode, _pSt.Color, _pSt.Thickness, _pSt.Transparency, _pSt.Parent = Enum.ApplyStrokeMode.Border, _0xPal.border, 1, 0.55, _pill
		_pill.Activated:Connect(function()
			_0xState.SelectedFolderFilter = _fName
			_0xF10V._0x1A(_filter)
		end)
	end
end

_0xF10V._0x1A = function(_filter: string): number
	_0xF10V._0xRebuildFolderPills(_filter)
	for _, _child: Instance in ipairs(_0xUI.DropScroll:GetChildren()) do
		if _child:IsA("TextButton") then _child:Destroy() end
	end
	local _q: string, _matches: { _0xT3 } = string.lower(_filter), {}
	for _, _item: _0xT3 in ipairs(_0xAvailableCmds) do
		local _folderOk: boolean = (_0xState.SelectedFolderFilter == "All" or _item.folder == _0xState.SelectedFolderFilter)
		if _folderOk and (_q == "" or string.find(string.lower(_item.cmd), _q, 1, true) or string.find(string.lower(_item.desc), _q, 1, true)) then
			table.insert(_matches, _item)
		end
	end
	_0xUI.DropHeader.Text = `Commands ({_0xState.SelectedFolderFilter}) • {#_matches}`

	for _idx: number, _data: _0xT3 in ipairs(_matches) do
		local _isFav: boolean = _0xCfg.Favorites[_data.cmd] == true
		local _row: TextButton = Instance.new("TextButton")
		_row.Name, _row.Size, _row.BackgroundColor3, _row.BackgroundTransparency, _row.Text, _row.AutoButtonColor, _row.LayoutOrder, _row.ZIndex, _row.Parent = `CmdRow_{_data.cmd}`, UDim2.new(1, -2, 0, 38), _0xPal.rowBg, 0.25, "", false, _idx, _0xUI.DropScroll.ZIndex + 1, _0xUI.DropScroll
		_0xF10V._0x07(_row, 9)
		local _rStroke: UIStroke = Instance.new("UIStroke")
		_rStroke.ApplyStrokeMode, _rStroke.Color, _rStroke.Thickness, _rStroke.Transparency, _rStroke.Parent = Enum.ApplyStrokeMode.Border, _0xPal.border, 1, 0.6, _row

		local _tName: TextLabel = Instance.new("TextLabel")
		_tName.Position, _tName.Size, _tName.BackgroundTransparency, _tName.Font, _tName.Text, _tName.TextColor3, _tName.TextSize, _tName.TextXAlignment, _tName.TextTruncate, _tName.ZIndex, _tName.Parent = if _data.desc ~= "" then UDim2.fromOffset(10, 5) else UDim2.fromOffset(10, 11), UDim2.new(1, -46, 0, 15), 1, Enum.Font.GothamBold, _data.cmd, _0xPal.white, 12, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, _row.ZIndex + 1, _row

		if _data.desc ~= "" then
			local _tDesc: TextLabel = Instance.new("TextLabel")
			_tDesc.Position, _tDesc.Size, _tDesc.BackgroundTransparency, _tDesc.Font, _tDesc.Text, _tDesc.TextColor3, _tDesc.TextSize, _tDesc.TextXAlignment, _tDesc.TextTruncate, _tDesc.ZIndex, _tDesc.Parent = UDim2.fromOffset(10, 20), UDim2.new(1, -46, 0, 13), 1, Enum.Font.Gotham, _data.desc, _0xPal.muted, 9, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, _row.ZIndex + 1, _row
		end

		local _starBtn: TextButton = Instance.new("TextButton")
		_starBtn.Name, _starBtn.AnchorPoint, _starBtn.Position, _starBtn.Size, _starBtn.BackgroundColor3, _starBtn.BackgroundTransparency, _starBtn.BorderSizePixel, _starBtn.AutoButtonColor, _starBtn.Font, _starBtn.Text, _starBtn.TextColor3, _starBtn.TextSize, _starBtn.ZIndex, _starBtn.Parent = "StarButton", Vector2.new(1, 0.5), UDim2.new(1, -8, 0.5, 0), UDim2.fromOffset(22, 22), _0xPal.white, if _isFav then 0.85 else 1, 0, false, Enum.Font.GothamBold, "★", if _isFav then _0xPal.white else _0xPal.muted, 12, _row.ZIndex + 2, _row
		_0xF10V._0x07(_starBtn, 11)

		_starBtn.Activated:Connect(function() _0xCfg.Favorites[_data.cmd] = not _0xCfg.Favorites[_data.cmd]; _0xF10V._0x02(); _0xF10V._0x13(); _0xF10V._0x1A(_filter) end)
		_row.MouseEnter:Connect(function() _0xS1:Create(_row, TweenInfo.new(0.12), { BackgroundColor3 = _0xPal.rowHover, BackgroundTransparency = 0.1 }):Play() end)
		_row.MouseLeave:Connect(function() _0xS1:Create(_row, TweenInfo.new(0.12), { BackgroundColor3 = _0xPal.rowBg, BackgroundTransparency = 0.25 }):Play() end)
		_row.Activated:Connect(function() _0xF10V._0x1D(_data.cmd) end)
	end

	local _computedH: number = math.clamp(72 + (math.max(1, #_matches) * 42), 114, _0xDims.DropMaxH)
	_0xS1:Create(_0xUI.CmdDrop, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(_0xDims.DropW, _computedH) }):Play()
	return _computedH
end

_0xF10V._0x1B = function(_filter: string): ()
	local _targetH: number = _0xF10V._0x1A(_filter)
	if _0xState.CmdListOpen then return end
	_0xState.CmdListOpen = true
	if _0xTweens.DropFade then _0xTweens.DropFade:Cancel(); _0xTweens.DropFade = nil end
	local _finalY: number = _0xF10V._0x0C() + (if _0xState.MenuOpen then 56 else 20)
	_0xUI.CmdDrop.Size, _0xUI.CmdDrop.Position, _0xUI.CmdDrop.GroupTransparency, _0xUI.CmdDrop.Visible = UDim2.fromOffset(_0xDims.DropW, _targetH), UDim2.new(0.5, 0, 0, _finalY - 8), 1, true
	local _tw: Tween = _0xS1:Create(_0xUI.CmdDrop, TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, _finalY), GroupTransparency = 0 })
	_0xTweens.DropFade = _tw
	_tw:Play()
end

_0xF10V._0x23 = function(_open: boolean): ()
	if _open then
		if _0xState.UsersActive then return end
		_0xState.UsersActive = true
		if _0xTweens.UsersFade then _0xTweens.UsersFade:Cancel(); _0xTweens.UsersFade = nil end
		local _topOffset: number = if _0xState.MenuOpen then 122 else 82
		_0xUI.UsersLayer.Position, _0xUI.UsersLayer.GroupTransparency, _0xUI.UsersLayer.Visible = UDim2.new(0.5, 0, 0, _topOffset - 8), 1, true
		_0xUpdateSubTabVisuals(false)
		_0xRenderUsers(true)
		local _tw = _0xS1:Create(_0xUI.UsersLayer, TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, _topOffset), GroupTransparency = 0 })
		_0xTweens.UsersFade = _tw
		_tw:Play()
	else
		if not _0xState.UsersActive then return end
		_0xState.UsersActive = false
		if _0xTweens.UsersFade then _0xTweens.UsersFade:Cancel(); _0xTweens.UsersFade = nil end
		for _, _c: Instance in ipairs(_0xUI.UsersCardsHost:GetChildren()) do
			local _sh = _c:FindFirstChildOfClass("UIShadow")
			if _sh then pcall(function() _0xS1:Create(_sh, TweenInfo.new(0.16), { Transparency = 1 }):Play() end) end
		end
		local _tw = _0xS1:Create(_0xUI.UsersLayer, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { GroupTransparency = 1 })
		_0xTweens.UsersFade = _tw
		_tw:Play()
		_tw.Completed:Connect(function(_st: EnumPlaybackState) if _st == Enum.PlaybackState.Completed and not _0xState.UsersActive then _0xUI.UsersLayer.Visible = false end end)
	end
end

_0xF10V._0x25 = function(_open: boolean): ()
	if _open then
		if _0xState.ServersActive then return end
		_0xState.ServersActive = true
		if _0xTweens.ServersFade then _0xTweens.ServersFade:Cancel(); _0xTweens.ServersFade = nil end
		local _topOffset: number = if _0xState.MenuOpen then 122 else 82
		_0xUI.ServersLayer.Position, _0xUI.ServersLayer.GroupTransparency, _0xUI.ServersLayer.Visible = UDim2.new(0.5, 0, 0, _topOffset - 8), 1, true
		_0xUpdateSrvTabVisuals(false)
		task.spawn(_0xFetchServers)
		_0xRenderServers(true)
		local _tw = _0xS1:Create(_0xUI.ServersLayer, TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, _topOffset), GroupTransparency = 0 })
		_0xTweens.ServersFade = _tw
		_tw:Play()
	else
		if not _0xState.ServersActive then return end
		_0xState.ServersActive = false
		if _0xTweens.ServersFade then _0xTweens.ServersFade:Cancel(); _0xTweens.ServersFade = nil end
		for _, _c: Instance in ipairs(_0xUI.ServersCardsHost:GetChildren()) do
			local _sh = _c:FindFirstChildOfClass("UIShadow")
			if _sh then pcall(function() _0xS1:Create(_sh, TweenInfo.new(0.16), { Transparency = 1 }):Play() end) end
		end
		local _tw = _0xS1:Create(_0xUI.ServersLayer, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { GroupTransparency = 1 })
		_0xTweens.ServersFade = _tw
		_tw:Play()
		_tw.Completed:Connect(function(_st: EnumPlaybackState) if _st == Enum.PlaybackState.Completed and not _0xState.ServersActive then _0xUI.ServersLayer.Visible = false end end)
	end
end

-- 14. APERTURA / CIERRE DE BARRA DE COMANDOS
_0xF10V._0x1E = function(): ()
	if not _0xState.CmdMode then return end
	_0xState.CmdMode, _0xState.ListeningBind, _0xState.CmdHasText, _0xUI.Caret.Visible, _0xUI.CmdInput.Text, _0xUI.CmdSuggest.Text, _0xState.CurrentSuggest = false, false, false, false, "", "", ""
	_0xUI.BindBtn.BackgroundColor3, _0xUI.BindBtn.TextColor3, _0xUI.BindBtn.Text = _0xPal.bindPill, _0xPal.white, _0xF10V._0x05(_0xBindKey)
	if _0xState.ActiveTab == "commands" then _0xState.ActiveTab = ""; _0xF10V._0x0F() end
	_0xF10V._0x19()
	if _0xUI.CmdInput:IsFocused() then _0xUI.CmdInput:ReleaseFocus() end

	local _colInfo: TweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local _fadeOut: Tween = _0xS1:Create(_0xUI.CmdBox, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { GroupTransparency = 1 })
	_fadeOut:Play()
	_0xS1:Create(_0xUI.Bar, _colInfo, { Size = UDim2.fromOffset(_0xDims.BaseW, _0xDims.BaseH) }):Play()
	_0xS1:Create(_0xUI.TriggerZone, _colInfo, { Position = UDim2.new(0.5, 0, 0, _0xF10V._0x0C()) }):Play()
	if _0xState.MenuOpen then
		_0xF10V._0x15()
		local _by: number = _0xF10V._0x0E()
		for _, _item: _0xT0 in ipairs(_0xTabs) do
			local _e: _0xT1? = _0xBtnMap[_item.id]
			if _e and _e.btn.Parent then _0xF10V._0x16(_0xS1:Create(_e.btn, _colInfo, { Position = UDim2.new(0.5, _e.targetX, 0, _by) })) end
		end
	end
	_0xUI.Icon.Visible = true
	_0xS1:Create(_0xUI.Icon, _colInfo, { ImageTransparency = 0, Position = UDim2.new(0, 13, 0.5, 0), Size = UDim2.fromOffset(22, 22) }):Play()
	_fadeOut.Completed:Connect(function(_st: EnumPlaybackState)
		if _st == Enum.PlaybackState.Completed and not _0xState.CmdMode then
			_0xUI.CmdBox.Visible = false
			if not _0xState.NotifActive then _0xUI.Lens.Visible = true end
		end
	end)
end

_0xF10V._0x1F = function(): ()
	if not _0xAlive then return end
	if _0xState.CmdMode then _0xF10V._0x1E(); return end
	_0xF10V._0x23(false)
	_0xF10V._0x25(false)
	_0xF10V._0x24(false)
	_0xState.NotifToken += 1
	_0xState.NotifActive, _0xUI.NotifBox.Visible, _0xUI.NotifBox.GroupTransparency = false, false, 1
	_0xState.CmdMode, _0xUI.Lens.Visible, _0xUI.CmdBox.Visible = true, false, true

	local _expInfo: TweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	_0xS1:Create(_0xUI.Bar, _expInfo, { Size = UDim2.fromOffset(_0xDims.CmdBarW, _0xDims.CmdBarH) }):Play()
	_0xS1:Create(_0xUI.TriggerZone, _expInfo, { Position = UDim2.new(0.5, 0, 0, _0xF10V._0x0C()) }):Play()
	if _0xState.MenuOpen then
		_0xF10V._0x15()
		local _ny: number = _0xF10V._0x0E()
		for _, _item: _0xT0 in ipairs(_0xTabs) do
			local _e: _0xT1? = _0xBtnMap[_item.id]
			if _e and _e.btn.Parent then _0xF10V._0x16(_0xS1:Create(_e.btn, _expInfo, { Position = UDim2.new(0.5, _e.targetX, 0, _ny) })) end
		end
	end
	local _hideIcon: Tween = _0xS1:Create(_0xUI.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 1 })
	_hideIcon:Play()
	_hideIcon.Completed:Connect(function() if _0xState.CmdMode then _0xUI.Icon.Visible = false end end)
	_0xS1:Create(_0xUI.CmdBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
	_0xF10V._0x1B("")
	task.defer(function() if _0xState.CmdMode and _0xUI.CmdInput.Parent then _0xUI.CmdInput:CaptureFocus(); _0xF10V._0x22() end end)
end

-- 15. EJECUCIÓN DE COMANDOS DESDE GITHUB
_0xF10V._0x1D = function(_rawInput: string): ()
	local _trimmed: string = string.match(_rawInput, "^%s*(.-)%s*$") or ""
	_0xF10V._0x1E()
	if _trimmed == "" then return end
	local _cleanInput: string, _args: { string } = string.gsub(_trimmed, "^[;/!%.]+", ""), {}
	for _w: string in string.gmatch(_cleanInput, "%S+") do table.insert(_args, _w) end
	local _typedCmd: string = _args[1] or ""
	if _typedCmd == "" then return end
	if string.lower(_typedCmd) == "destroy" then
		if type(_0xF10V._0x21) == "function" then _0xF10V._0x21() end
		return
	end
	local _cmdArgs: { string } = {}
	for _i = 2, #_args do table.insert(_cmdArgs, _args[_i]) end

	local _matchedKey: string?, _repoFile: string? = nil, nil
	for _k: string, _fn: string in pairs(_0xRepoFiles) do
		if _k == _typedCmd or string.lower(_k) == string.lower(_typedCmd) then _matchedKey, _repoFile = _k, _fn; break end
	end

	if _matchedKey and _repoFile then
		_0xNotify(`Ejecutando {_matchedKey}...`, 2.0, false)
		task.spawn(function()
			local _encodedPath: string = string.gsub(_repoFile, "[^/]+", function(_seg: string) return _0xS5:UrlEncode(_seg) end)
			local _code: string? = _0xScriptCache[_matchedKey] or _0xF10V._0x10(_0xR1 .. _encodedPath)
			if _code and _code ~= "" then
				_0xScriptCache[_matchedKey] = _code
				_0xG0.CommandArgs, _0xG0.CommandArgString = _cmdArgs, table.concat(_cmdArgs, " ")
				local _fn: any = (loadstring :: any)(_code)
				if type(_fn) == "function" then pcall(_fn, unpack(_cmdArgs)) end
			else
				_0xNotify(`Error al descargar {_matchedKey}`, 2.4, false)
			end
		end)
	else
		_0xNotify(`No existe en GitHub: {_typedCmd}`, 2.2, false)
	end
end

-- 16. EVENTOS DE TEXTO Y BINDEO
_0xUI.CmdInput:GetPropertyChangedSignal("Text"):Connect(function()
	local _txt: string = _0xUI.CmdInput.Text
	local _cleanTxt: string = string.gsub(_txt, "^[;/!%.]+", "")
	local _low: string = string.lower(_cleanTxt)
	_0xState.CurrentSuggest = ""
	_0xF10V._0x22()

	if _txt == "" then
		_0xState.CmdHasText, _0xUI.CmdSuggest.Text, _0xUI.CmdSuggest.Position = false, "", UDim2.new(0, 28, 0.5, 0)
		if _0xState.CmdMode then _0xF10V._0x1B("") end
		return
	end

	_0xState.CmdHasText = true
	_0xF10V._0x1B(_cleanTxt)
	local _suffix: string = ""
	for _, _data: _0xT3 in ipairs(_0xAvailableCmds) do
		local _folderOk: boolean = (_0xState.SelectedFolderFilter == "All" or _data.folder == _0xState.SelectedFolderFilter)
		if _folderOk and string.sub(string.lower(_data.cmd), 1, #_low) == _low then
			_suffix, _0xState.CurrentSuggest = string.sub(_data.cmd, #_cleanTxt + 1), _data.cmd
			break
		end
	end
	if _suffix ~= "" then
		local _sz: Vector2 = _0xS6:GetTextSize(_txt, _0xUI.CmdInput.TextSize, _0xUI.CmdInput.Font, Vector2.new(9999, 9999))
		_0xUI.CmdSuggest.Position = UDim2.new(0, 28 + _sz.X, 0.5, 0)
	end
	_0xUI.CmdSuggest.Text = _suffix
end)

_0xUI.CmdInput:GetPropertyChangedSignal("CursorPosition"):Connect(function() _0xF10V._0x22() end)
_0xUI.CmdInput.Focused:Connect(function() _0xF10V._0x22() end)
_0xUI.CmdInput.FocusLost:Connect(function(_enterPressed: boolean)
	_0xUI.Caret.Visible = false
	if _enterPressed then
		local _cmdToRun: string = _0xUI.CmdInput.Text
		local _noPrefix: string = string.gsub(_cmdToRun, "^[;/!%.]+", "")
		if _0xState.CurrentSuggest ~= "" and #_noPrefix < #_0xState.CurrentSuggest and not string.find(_noPrefix, "%s") then _cmdToRun = _0xState.CurrentSuggest end
		_0xF10V._0x1D(_cmdToRun)
	end
end)

_0xUI.BindBtn.Activated:Connect(function()
	if _0xState.ListeningBind then
		_0xState.ListeningBind, _0xUI.BindBtn.BackgroundColor3, _0xUI.BindBtn.TextColor3, _0xUI.BindBtn.Text = false, _0xPal.bindPill, _0xPal.white, _0xF10V._0x05(_0xBindKey)
		return
	end
	_0xState.ListeningBind = true
	if _0xUI.CmdInput:IsFocused() then _0xUI.CmdInput:ReleaseFocus() end
	_0xUI.BindBtn.BackgroundColor3, _0xUI.BindBtn.TextColor3, _0xUI.BindBtn.Text = _0xPal.bindListening, _0xPal.black, "..."
end)

-- 17. CONSTRUIR LOS 5 BOTONES CIRCULARES
do
	local _totalBtnsW: number = (#_0xTabs * _0xDims.BtnSize) + ((#_0xTabs - 1) * _0xDims.BtnGap)
	local _startX: number = -(_totalBtnsW / 2) + (_0xDims.BtnSize / 2)

	for _idx: number, _item: _0xT0 in ipairs(_0xTabs) do
		local _tx: number = _startX + (_idx - 1) * (_0xDims.BtnSize + _0xDims.BtnGap)
		local _btn: TextButton = Instance.new("TextButton")
		_btn.Name, _btn.AnchorPoint, _btn.Position, _btn.Size, _btn.BackgroundColor3, _btn.BackgroundTransparency, _btn.Text, _btn.AutoButtonColor, _btn.Visible, _btn.ZIndex, _btn.Parent = `Tab_{_item.id}`, Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, _0xF10V._0x0D()), UDim2.fromOffset(18, 18), _0xPal.black, 0.52, "", false, false, 6, _0xGui
		_0xF10V._0x07(_btn, _0xDims.BtnRad)
		_0xF10V._0xBubbleStroke(_btn)

		local _ic: ImageLabel = Instance.new("ImageLabel")
		_ic.Name, _ic.AnchorPoint, _ic.Position, _ic.Size, _ic.BackgroundTransparency, _ic.Image, _ic.ImageColor3, _ic.ImageTransparency, _ic.ScaleType, _ic.ZIndex, _ic.Parent = "Icon", Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(12, 12), 1, _item.asset, _0xPal.white, 0.85, Enum.ScaleType.Fit, _btn.ZIndex + 1, _btn
		_0xBtnMap[_item.id] = { btn = _btn, icon = _ic, targetX = _tx }

		_btn.MouseEnter:Connect(function()
			if not _0xState.MenuOpen then return end
			_0xS1:Create(_btn, TweenInfo.new(0.14, Enum.EasingStyle.Sine), { Size = UDim2.fromOffset(_0xDims.BtnSize + 3, _0xDims.BtnSize + 3) }):Play()
			_0xS1:Create(_ic, TweenInfo.new(0.14, Enum.EasingStyle.Sine), { Size = UDim2.fromOffset(21, 21) }):Play()
		end)
		_btn.MouseLeave:Connect(function()
			if not _0xState.MenuOpen then return end
			_0xS1:Create(_btn, TweenInfo.new(0.14, Enum.EasingStyle.Sine), { Size = UDim2.fromOffset(_0xDims.BtnSize, _0xDims.BtnSize) }):Play()
			_0xS1:Create(_ic, TweenInfo.new(0.14, Enum.EasingStyle.Sine), { Size = UDim2.fromOffset(19, 19) }):Play()
		end)
		_btn.Activated:Connect(function()
			if _0xState.ActiveTab == _item.id then
				_0xState.ActiveTab = ""
				_0xF10V._0x0F()
				if _item.id == "commands" and _0xState.CmdMode then _0xF10V._0x1E()
				elseif _item.id == "users" then _0xF10V._0x23(false)
				elseif _item.id == "servers" then _0xF10V._0x25(false)
				elseif _item.id == "config" then _0xF10V._0x24(false) end
				return
			end
			_0xState.ActiveTab, _0xCfg.LastTab = _item.id, _item.id
			_0xF10V._0x02()
			_0xF10V._0x0F()
			if _item.id == "commands" then
				_0xF10V._0x23(false); _0xF10V._0x25(false); _0xF10V._0x24(false); _0xF10V._0x1F()
			elseif _item.id == "users" then
				if _0xState.CmdMode then _0xF10V._0x1E(); _0xState.ActiveTab = "users"; _0xF10V._0x0F() end
				_0xF10V._0x25(false); _0xF10V._0x24(false); _0xF10V._0x23(true)
			elseif _item.id == "servers" then
				if _0xState.CmdMode then _0xF10V._0x1E(); _0xState.ActiveTab = "servers"; _0xF10V._0x0F() end
				_0xF10V._0x23(false); _0xF10V._0x24(false); _0xF10V._0x25(true)
			elseif _item.id == "config" then
				if _0xState.CmdMode then _0xF10V._0x1E(); _0xState.ActiveTab = "config"; _0xF10V._0x0F() end
				_0xF10V._0x23(false); _0xF10V._0x25(false); _0xF10V._0x24(true)
			else
				if _0xState.CmdMode then _0xF10V._0x1E() end
				_0xF10V._0x23(false); _0xF10V._0x25(false); _0xF10V._0x24(false)
			end
		end)
	end
end

-- 18. CERRAR AUTOMÁTICAMENTE AL DAR CLIC FUERA
local _0xIsPointInside = function(_obj: GuiObject, _pt: Vector2): boolean
	if not _obj.Visible then return false end
	local _p: Vector2, _s: Vector2 = _obj.AbsolutePosition, _obj.AbsoluteSize
	return _pt.X >= _p.X and _pt.X <= (_p.X + _s.X) and _pt.Y >= _p.Y and _pt.Y <= (_p.Y + _s.Y)
end

table.insert(_0xConns, _0xS2.InputBegan:Connect(function(_input: InputObject, _gp: boolean)
	if not _0xAlive then return end

	if _input.UserInputType == Enum.UserInputType.MouseButton1 or _input.UserInputType == Enum.UserInputType.Touch then
		if _0xState.CmdMode or _0xState.CmdListOpen or _0xState.UsersActive or _0xState.ServersActive or _0xState.ConfigActive or _0xState.MenuOpen then
			local _pt: Vector2 = Vector2.new(_input.Position.X, _input.Position.Y)
			local _insideAny: boolean = _0xIsPointInside(_0xUI.Bar, _pt) or _0xIsPointInside(_0xUI.TriggerZone, _pt) or _0xIsPointInside(_0xUI.CmdDrop, _pt) or _0xIsPointInside(_0xUI.DndRowBlock, _pt) or (_0xCfg.DoNotDisturb and _0xIsPointInside(_0xUI.DndSettingsGroup, _pt)) or _0xIsPointInside(_0xUI.SubTabsHost, _pt) or _0xIsPointInside(_0xUI.UsersSearchBox, _pt) or _0xIsPointInside(_0xUI.UsersPagBar, _pt) or _0xIsPointInside(_0xUI.ServersTopBar, _pt) or _0xIsPointInside(_0xUI.MainSrvCard, _pt) or _0xIsPointInside(_0xUI.ServersPagBar, _pt)
			if not _insideAny and _0xState.UsersActive then
				for _, _child: Instance in ipairs(_0xUI.UsersCardsHost:GetChildren()) do
					if _child:IsA("GuiObject") and _0xIsPointInside(_child :: GuiObject, _pt) then _insideAny = true; break end
				end
			end
			if not _insideAny and _0xState.ServersActive then
				for _, _child: Instance in ipairs(_0xUI.ServersCardsHost:GetChildren()) do
					if _child:IsA("GuiObject") and _0xIsPointInside(_child :: GuiObject, _pt) then _insideAny = true; break end
				end
			end
			if not _insideAny then
				for _, _entry: _0xT1 in pairs(_0xBtnMap) do
					if _0xIsPointInside(_entry.btn, _pt) then _insideAny = true; break end
				end
			end
			if not _insideAny then
				_0xState.ActiveTab = ""
				_0xF10V._0x0F()
				if _0xState.CmdMode then _0xF10V._0x1E() end
				if _0xState.CmdListOpen then _0xF10V._0x19() end
				if _0xState.UsersActive then _0xF10V._0x23(false) end
				if _0xState.ServersActive then _0xF10V._0x25(false) end
				if _0xState.ConfigActive then _0xF10V._0x24(false) end
				if _0xState.MenuOpen then _0xF10V._0x18() end
			end
		end
	end

	if _0xState.ListeningBind and _input.UserInputType == Enum.UserInputType.Keyboard then
		local _pressed: EnumKeyCode = _input.KeyCode
		if _pressed ~= Enum.KeyCode.Unknown then
			_0xState.ListeningBind, _0xUI.BindBtn.BackgroundColor3, _0xUI.BindBtn.TextColor3 = false, _0xPal.bindPill, _0xPal.white
			if _pressed ~= Enum.KeyCode.Escape then
				_0xBindKey, _0xCfg.CommandBarKey = _pressed, _pressed.Name
				_0xF10V._0x02()
			end
			_0xUI.BindBtn.Text = _0xF10V._0x05(_0xBindKey)
		end
		return
	end

	if _input.UserInputType == Enum.UserInputType.Keyboard and _input.KeyCode == _0xBindKey then
		if _0xState.CmdMode then _0xF10V._0x1E()
		elseif not _gp then _0xState.ActiveTab = "commands"; _0xF10V._0x0F(); _0xF10V._0x1F() end
		return
	end

	if (_0xState.UsersActive or _0xState.ServersActive) and not _gp and not _0xS2:GetFocusedTextBox() and _input.UserInputType == Enum.UserInputType.Keyboard then
		if _0xState.UsersActive then
			if _input.KeyCode == Enum.KeyCode.Q and _0xState.UsersPageNum > 1 then _0xState.UsersPageNum -= 1; _0xRenderUsers(true)
			elseif _input.KeyCode == Enum.KeyCode.E and _0xState.UsersPageNum < _0xState.UsersTotalPages then _0xState.UsersPageNum += 1; _0xRenderUsers(true) end
		elseif _0xState.ServersActive then
			if _input.KeyCode == Enum.KeyCode.Q and _0xState.ServersPageNum > 1 then _0xState.ServersPageNum -= 1; _0xRenderServers(true)
			elseif _input.KeyCode == Enum.KeyCode.E and _0xState.ServersPageNum < _0xState.ServersTotalPages then _0xState.ServersPageNum += 1; _0xRenderServers(true) end
		end
	end

	if _input.KeyCode == Enum.KeyCode.Escape then
		if _0xState.CmdMode then _0xF10V._0x1E() end
		if _0xState.UsersActive or _0xState.ServersActive or _0xState.ConfigActive then
			_0xState.ActiveTab = ""
			_0xF10V._0x0F()
			_0xF10V._0x23(false)
			_0xF10V._0x25(false)
			_0xF10V._0x24(false)
		end
	end
end))

-- 19. DETECCIÓN DEL CURSOR Y PARPADEO
_0xF10V._0x20 = function(): boolean
	if _0xState.CmdHasText or _0xState.CmdListOpen or _0xState.UsersActive or _0xState.ServersActive or _0xState.ConfigActive then return _0xState.MenuOpen end
	local _raw: Vector2, _inset: Vector2 = _0xS2:GetMouseLocation(), _0xS4:GetGuiInset()
	local _p1: Vector2, _p2: Vector2 = Vector2.new(_raw.X, _raw.Y), Vector2.new(_raw.X - _inset.X, _raw.Y - _inset.Y)
	local _bp: Vector2, _bs: Vector2, _tp: Vector2, _ts: Vector2, _oy: number = _0xUI.Bar.AbsolutePosition, _0xUI.Bar.AbsoluteSize, _0xUI.TriggerZone.AbsolutePosition, _0xUI.TriggerZone.AbsoluteSize, _0xF10V._0x0E()

	local function _chk(_pt: Vector2): boolean
		if not _0xState.MenuOpen then
			return _pt.X >= (math.min(_bp.X, _tp.X) - 14) and _pt.X <= (math.max(_bp.X + _bs.X, _tp.X + _ts.X) + 14) and _pt.Y >= (_bp.Y + (_bs.Y * 0.55)) and _pt.Y <= (_tp.Y + _ts.Y + 4)
		else
			return _pt.X >= (math.min(_bp.X, _tp.X) - 18) and _pt.X <= (math.max(_bp.X + _bs.X, _tp.X + _ts.X) + 18) and _pt.Y >= (_bp.Y - 6) and _pt.Y <= (_oy + _0xDims.BtnSize + 6)
		end
	end
	return _chk(_p1) or _chk(_p2)
end

table.insert(_0xConns, _0xS3.RenderStepped:Connect(function(_dt: number)
	if not _0xAlive then return end
	if _0xState.CmdMode and _0xUI.CmdInput:IsFocused() then
		_0xState.CaretAccum += _dt
		if _0xState.CaretAccum >= 0.45 then
			_0xState.CaretAccum, _0xState.CaretShown = 0, not _0xState.CaretShown
			_0xUI.Caret.Visible = _0xState.CaretShown
		end
	elseif _0xUI.Caret.Visible then
		_0xUI.Caret.Visible = false
	end
	if _0xState.CmdListOpen or _0xState.UsersActive or _0xState.ServersActive or _0xState.ConfigActive then return end
	local _inside: boolean = _0xF10V._0x20()
	if _inside and not _0xState.MenuOpen then _0xF10V._0x17() elseif not _inside and _0xState.MenuOpen then _0xF10V._0x18() end
end))

-- 20. LIMPIEZA Y CIERRE
_0xF10V._0x21 = function(): ()
	_0xAlive = false
	_0xState.NotifToken += 1
	_0xF10V._0x15()
	if _0xTweens.Spin then _0xTweens.Spin:Cancel(); _0xTweens.Spin = nil end
	pcall(function() _0xSupaRequest("PATCH", `/flow_presence?user_id=eq.{_0xP0.UserId}`, { is_active = false, job_id = "" }) end)
	for _, _c: RBXScriptConnection in ipairs(_0xConns) do _c:Disconnect() end
	table.clear(_0xConns)
	_0xState.MenuOpen, _0xState.ActiveTab = false, ""
	for _, _e: _0xT1 in pairs(_0xBtnMap) do if _e.btn.Parent then _e.btn.Visible = false end end
	if _0xUI.CmdDrop.Parent then _0xUI.CmdDrop.Visible = false end
	if _0xUI.ConfigWin.Parent then _0xUI.ConfigWin.Visible = false end
	if _0xUI.UsersLayer.Parent then _0xUI.UsersLayer.Visible = false end
	if _0xUI.ServersLayer.Parent then _0xUI.ServersLayer.Visible = false end
	if _0xUI.Indicator.Parent then _0xS1:Create(_0xUI.Indicator, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play() end
	if _0xUI.Bar.Parent then
		local _closeTw: Tween = _0xS1:Create(_0xUI.Bar, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 0, -50), GroupTransparency = 1 })
		_closeTw:Play()
		_closeTw.Completed:Wait()
	end
	if _0xGui.Parent then _0xGui:Destroy() end
	if _0xG0._0xF10V_Gui == _0xGui then _0xG0._0xF10V_Gui = nil end
	if _0xG0._0xF10V_Cleanup == _0xF10V._0x21 then _0xG0._0xF10V_Cleanup = nil end
end

_0xG0._0xF10V_Cleanup = _0xF10V._0x21
_0xG0.iPhoneNotify = function(_msg: string, _dur: number?): () _0xNotify(_msg, _dur, false) end

-- 21. ENTRADA ANIMADA
_0xS1:Create(_0xUI.Bar, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, _0xDims.TopY), GroupTransparency = 0 }):Play()
task.delay(0.22, function() if _0xAlive and _0xUI.Indicator.Parent then _0xS1:Create(_0xUI.Indicator, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = _0xDims.IndOff }):Play() end end)
task.delay(0.55, function() _0xNotify(`Welcome back, {if _0xP0.DisplayName ~= "" then _0xP0.DisplayName else _0xP0.Name}`, 3.2, true) end)
