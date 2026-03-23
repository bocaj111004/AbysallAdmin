local UI = {
	ToggleKeybind = "Quote"
}

local function CloneReference(Object)
	if typeof(cloneref) == "function" then
		return cloneref(Object)
	end
	return Object
end

local function MakeRandom()
	local Template = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
	local Chars = "1234567890abcdef"

	return Template:gsub("x", function()
		local Index = math.random(1, #Chars)
		return Chars:sub(Index, Index)
	end)
end

local Services = setmetatable({}, {
	__index = function(self, Key)
		return CloneReference(game:GetService(Key))
	end,
})

local Workspace = Services.Workspace
local CoreGui = Services.CoreGui
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local TextService = Services.TextService
local StarterGui = Services.StarterGui
local TeleportService = Services.TeleportService

local LocalPlayer = CloneReference(Players.LocalPlayer)
local Mouse = CloneReference(LocalPlayer:GetMouse())
local Camera = CloneReference(Workspace.CurrentCamera)

local function GetHiddenUI()
	if typeof(gethui) == "function" then
		return gethui()
	else
		return CoreGui
	end
end

local function GetTextBounds(Text, Font, Size, Width)
	local Params = Instance.new("GetTextBoundsParams")
	Params.Text = Text
	Params.RichText = true
	Params.Font = Font
	Params.Size = Size
	Params.Width = Width or workspace.CurrentCamera.ViewportSize.X - 32

	local Bounds = TextService:GetTextBoundsAsync(Params)
	return Bounds.X, Bounds.Y
end

local function MakeResizable(Frame, DragFrame, MinimumSize, Side)
	local StartSize
	local StartDragPosition
	local Delta
	local Dragging = false

	DragFrame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			StartDragPosition = Input.Position
			StartSize = Frame.Size
			Dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = false
		end
	end)

	local LastSize = Frame.Size
	UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			if Dragging and Frame:GetAttribute("Locked") ~= true then
				local Delta = Input.Position - StartDragPosition
				if Side == "Left" then
					local TargetSize = UDim2.new(
						StartSize.X.Scale,
						math.clamp(StartSize.X.Offset - Delta.X, MinimumSize.X.Offset, math.huge),
						StartSize.Y.Scale,
						math.clamp(StartSize.Y.Offset + Delta.Y, MinimumSize.Y.Offset, math.huge)
					)
					local Difference
					local TargetPosition = UDim2.new(
						Frame.Position.X.Scale,
						Frame.Position.X.Offset - (TargetSize.X.Offset - Frame.Size.X.Offset),
						Frame.Position.Y.Scale,
						Frame.Position.Y.Offset
					)
					LastSize = TargetSize
					TweenService:Create(Frame, TweenInfo.new(0, Enum.EasingStyle.Exponential), {Size = TargetSize}):Play()	
					TweenService:Create(Frame, TweenInfo.new(0, Enum.EasingStyle.Exponential), {Position = TargetPosition}):Play()	
				else
					local TargetSize = UDim2.new(
						StartSize.X.Scale,
						math.clamp(StartSize.X.Offset + Delta.X, MinimumSize.X.Offset, math.huge),
						StartSize.Y.Scale,
						math.clamp(StartSize.Y.Offset + Delta.Y, MinimumSize.Y.Offset, math.huge)
					)
					TweenService:Create(Frame, TweenInfo.new(0, Enum.EasingStyle.Exponential), {Size = TargetSize}):Play()
				end
			end
		end
	end)
end

local function MakeDraggable(Frame, DragFrame)
	local StartPosition
	local StartDragPosition
	local Delta
	local Dragging = false

	DragFrame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			StartDragPosition = Input.Position
			StartPosition = Frame.Position
			Dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			if Dragging then
				local Delta = Input.Position - StartDragPosition
				local TargetPosition = UDim2.new(
					StartPosition.X.Scale,
					StartPosition.X.Offset + Delta.X,
					StartPosition.Y.Scale,
					StartPosition.Y.Offset + Delta.Y
				)
				TweenService:Create(Frame, TweenInfo.new(0, Enum.EasingStyle.Exponential), {Position = TargetPosition}):Play()
			end
		end
	end)
end

function UI:MakeWindow(Options)
	assert(typeof(Options) == "table", "'Options' should be a table")	
	local Window = {}

	local WindowContainer = Instance.new("ScreenGui", GetHiddenUI())
	WindowContainer.Name = MakeRandom()
	WindowContainer.IgnoreGuiInset = true
	WindowContainer.DisplayOrder = 2000000000
	WindowContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local MainFrame = Instance.new("Frame", WindowContainer)
	MainFrame.Size = Options.Size or UDim2.new(0, 480, 0, 360)
	MainFrame.BackgroundTransparency = 0.5
	MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	MainFrame.Position = UDim2.new(0, (Camera.ViewportSize.X / 2) - (MainFrame.Size.X.Offset / 2), 0, (Camera.ViewportSize.y / 2) - (MainFrame.Size.Y.Offset / 2))

	local MainCorner = Instance.new("UICorner", MainFrame)
	MainCorner.CornerRadius = UDim.new(0, 4)

	local TitleFrame = Instance.new("Frame", MainFrame)
	TitleFrame.BackgroundTransparency = 1
	TitleFrame.Size = UDim2.new(1, 0, 0, 16)
	TitleFrame.Position = UDim2.new(0, 0, 0, 6)

	local TitleText = Instance.new("TextLabel", TitleFrame)
	TitleText.BackgroundTransparency = 1
	TitleText.Size = UDim2.new(1, -12, 1, 0)
	TitleText.Position = UDim2.new(0.5, 6, 0.5, 0)
	TitleText.AnchorPoint = Vector2.new(0.5, 0.5)
	TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.TextSize = 16
	TitleText.Font = Enum.Font.SourceSans
	TitleText.Text = Options.Title or "Window"

	local InnerFrame = Instance.new("Frame", MainFrame)
	InnerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	InnerFrame.BorderSizePixel = 0
	InnerFrame.Size = UDim2.new(1, -12, 1, -34)
	InnerFrame.Position = UDim2.new(0, 6, 0, 28)

	local InnerCorner = Instance.new("UICorner", InnerFrame)
	InnerCorner.CornerRadius = UDim.new(0, 4)

	local CloseButton = Instance.new("TextButton", TitleFrame)
	CloseButton.Size = UDim2.new(0, 32, 0, 18)
	CloseButton.Position = UDim2.new(1, -40, 0.5, 0)
	CloseButton.AnchorPoint = Vector2.new(0, 0.5)
	CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	CloseButton.BorderSizePixel = 0
	CloseButton.Text = "X"
	CloseButton.Font = Enum.Font.Cartoon
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextSize = 16

	local CloseButtonCorner = Instance.new("UICorner", CloseButton)
	CloseButtonCorner.CornerRadius = UDim.new(0, 4)

	local MinimiseButton = Instance.new("TextButton", TitleFrame)
	MinimiseButton.Size = UDim2.new(0, 32, 0, 18)
	MinimiseButton.Position = UDim2.new(1, -78, 0.5, 0)
	MinimiseButton.AnchorPoint = Vector2.new(0, 0.5)
	MinimiseButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	MinimiseButton.BorderSizePixel = 0
	MinimiseButton.Text = "-"
	MinimiseButton.Font = Enum.Font.Cartoon
	MinimiseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	MinimiseButton.TextSize = 16

	local MinimiseButtonCorner = Instance.new("UICorner", MinimiseButton)
	MinimiseButtonCorner.CornerRadius = UDim.new(0, 4)

	CloseButton.MouseButton1Click:Connect(function()
		WindowContainer:Destroy()
	end)

	local OldSize = MainFrame.Size
	local Minimised = false
	MinimiseButton.MouseButton1Click:Connect(function()
		if Minimised then
			InnerFrame.Visible = true
			MainFrame:SetAttribute("Locked", nil)
			MainFrame.Size = UDim2.new(
				MainFrame.Size.X.Scale,
				OldSize.X.Offset,
				MainFrame.Size.Y.Scale,
				OldSize.Y.Offset
			)
			MinimiseButton.Text = "-"
			Minimised = false
		else
			local X, Y = GetTextBounds(TitleText.Text, TitleText.FontFace, TitleText.TextSize)
			InnerFrame.Visible = false
			MainFrame:SetAttribute("Locked", true)
			MainFrame.Size = UDim2.new(
				MainFrame.Size.X.Scale,
				98 + X,
				MainFrame.Size.Y.Scale,
				30
			)
			MinimiseButton.Text = "+"
			Minimised = true
		end
	end)

	MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
		if MainFrame:GetAttribute("Locked") ~= true then
			OldSize = MainFrame.Size
		end
	end)

	local LeftScale = Instance.new("Frame", MainFrame)
	LeftScale.BackgroundTransparency = 1
	LeftScale.Size = UDim2.new(0, 16, 0, 16)
	LeftScale.Position = UDim2.new(0, 0, 1, -16)

	local RightScale = Instance.new("Frame", MainFrame)
	RightScale.BackgroundTransparency = 1
	RightScale.Size = UDim2.new(0, 16, 0, 16)
	RightScale.Position = UDim2.new(1, -16, 1, -16)

	MakeDraggable(MainFrame, TitleFrame)
	MakeResizable(MainFrame, LeftScale, UDim2.new(0, 240, 0, 240), "Left")
	MakeResizable(MainFrame, RightScale, UDim2.new(0, 240, 0, 240), "Right")

	Window.Frame = MainFrame
	return Window
end

local NotificationWindowContainer = Instance.new("ScreenGui", GetHiddenUI())
NotificationWindowContainer.Name = MakeRandom()
NotificationWindowContainer.IgnoreGuiInset = true
NotificationWindowContainer.DisplayOrder = 2000000000
NotificationWindowContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local NotificationFrame = Instance.new("Frame", NotificationWindowContainer)
NotificationFrame.BackgroundTransparency = 1
NotificationFrame.Size = UDim2.new(0, 280, 1, -32)
NotificationFrame.Position = UDim2.new(1, -280, 0, 0)

local NotificationListLayout = Instance.new("UIListLayout", NotificationFrame)
NotificationListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NotificationListLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotificationListLayout.Padding = UDim.new(0, 8)

function UI:Notify(Title, Text)
	local Counter = 15
	
	local MainFrame = Instance.new("Frame", NotificationFrame)
	MainFrame.BackgroundTransparency = 0.5
	MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	MainFrame.Size = UDim2.new(0, 280, 0, 64)
	
	local Divider = Instance.new("Frame", MainFrame)
	Divider.Size = UDim2.new(1, -8, 0, 1)
	Divider.Position = UDim2.new(0, 4, 0, 32)
	Divider.BorderSizePixel = 0
	
	local TitleLabel = Instance.new("TextLabel", MainFrame)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Size = UDim2.new(1, -16, 0, 32)
	TitleLabel.Position = UDim2.new(0, 8, 0, 0)
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 16
	TitleLabel.Font = Enum.Font.SourceSansBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Text = Title .. " (" .. Counter .. ")"
	
	local BodyLabel = Instance.new("TextLabel", MainFrame)
	BodyLabel.BackgroundTransparency = 1
	BodyLabel.Size = UDim2.new(1, -16, 0, 32)
	BodyLabel.Position = UDim2.new(0, 8, 0, 32)
	BodyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	BodyLabel.TextSize = 18
	BodyLabel.Font = Enum.Font.SourceSans
	BodyLabel.TextXAlignment = Enum.TextXAlignment.Left
	BodyLabel.Text = Text
	BodyLabel.TextWrapped = true
	
	local X, Y = GetTextBounds(BodyLabel.Text, BodyLabel.FontFace, BodyLabel.TextSize)
	local Lines = math.floor(X/232)
	
	MainFrame.Size = UDim2.new(0, 240, 0, 48 + (Lines * 16) + Y)
	BodyLabel.Size = UDim2.new(1, -8, 0, 16 + (Lines * 16) + Y)
	
	local CloseButton = Instance.new("TextButton", MainFrame)
	CloseButton.Size = UDim2.new(0, 20, 0, 20)
	CloseButton.Position = UDim2.new(1, -28, 0, 6)
	CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	CloseButton.BorderSizePixel = 0
	CloseButton.Text = "X"
	CloseButton.Font = Enum.Font.FredokaOne
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextSize = 16
	CloseButton.BackgroundTransparency = 0.25
	
	CloseButton.MouseButton1Click:Connect(function()
		MainFrame:Destroy()
	end)
	
	local MainFrameCorner = Instance.new("UICorner", MainFrame)
	MainFrameCorner.CornerRadius = UDim.new(0, 4)
	
	local CloseButtonCorner = Instance.new("UICorner", CloseButton)
	CloseButtonCorner.CornerRadius = UDim.new(0, 4)
	
	local Sound = Instance.new("Sound", MainFrame)
	Sound.SoundId = "rbxassetid://4590662766"
	Sound.PlayOnRemove = true
	Sound.Volume = 3
	Sound:Play()
	Sound:Destroy()
	
	task.spawn(function()
		while task.wait(1) do
			Counter = Counter - 1
			TitleLabel.Text = Title .. " (" .. Counter .. ")"
			if Counter == 0 then
				MainFrame:Destroy()
			end
		end
	end)
end

function UI:CreateCommandBar(Callback)
	local CommandBar = {}
	local RegisteredCommands = {}

	local WindowContainer = Instance.new("ScreenGui", GetHiddenUI())
	WindowContainer.Name = MakeRandom()
	WindowContainer.IgnoreGuiInset = true
	WindowContainer.DisplayOrder = 2000000000
	WindowContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local MainFrame = Instance.new("Frame", WindowContainer)
	MainFrame.Size = UDim2.new(1, -72, 0, 32)
	MainFrame.Position = UDim2.new(0, 36, 0, 64)
	MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	MainFrame.BackgroundTransparency = 0.2
	MainFrame.Visible = false
	
	local SuggestionsFrame = Instance.new("ScrollingFrame", MainFrame)
	SuggestionsFrame.Parent = MainFrame
	SuggestionsFrame.ScrollBarThickness = 0
	SuggestionsFrame.BackgroundTransparency = 1
	SuggestionsFrame.Size = UDim2.new(1, -16, 1, -24)
	SuggestionsFrame.Position = UDim2.new(0, 8, 0, 32)
	
	local SuggestionsListLayout = Instance.new("UIListLayout", SuggestionsFrame)
	SuggestionsListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	SuggestionsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	SuggestionsListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local MainFrameCorner = Instance.new("UICorner", MainFrame)
	MainFrameCorner.CornerRadius = UDim.new(0, 4)

	local CommandBarText = Instance.new("TextBox", MainFrame)
	CommandBarText.BackgroundTransparency = 1
	CommandBarText.Size = UDim2.new(1, -16, 0, 16)
	CommandBarText.Position = UDim2.new(0, 8, 0, 8)
	CommandBarText.TextColor3 = Color3.fromRGB(255, 255, 255)
	CommandBarText.TextXAlignment = Enum.TextXAlignment.Left
	CommandBarText.TextSize = 18
	CommandBarText.Font = Enum.Font.SourceSansBold
	CommandBarText.PlaceholderText = "Enter Command"

	CommandBarText:GetPropertyChangedSignal("Text"):Connect(function()
		for Index, Object in pairs(SuggestionsFrame:GetChildren()) do
			if Object:IsA("Frame") then
				Object.Visible = false
			end
		end
		for Index, Command in pairs(RegisteredCommands) do
			local Valid = true
			for Index = 1, #CommandBarText.Text, 1 do
				local Char = Command.Name:sub(Index, Index)
				if Char ~= CommandBarText.Text:sub(Index, Index) then
					Valid = false
				end
			end
			if Valid and #CommandBarText.Text > 0 then
				Command.Frame.Visible = true
			end
		end
		MainFrame.Size = UDim2.new(1, -48, 0, 32 + SuggestionsListLayout.AbsoluteContentSize.Y)
		SuggestionsFrame.CanvasSize = UDim2.new(0, 0, 0, SuggestionsListLayout.AbsoluteContentSize.Y)
	end)

	local Old = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
	UserInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode == Enum.KeyCode[UI.ToggleKeybind] and not CommandBarText:IsFocused() then
			task.wait()
			Old = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
			CommandBarText.Text = ""
			MainFrame.Visible = true
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
			CommandBarText:CaptureFocus()
		end
	end)

	CommandBarText.FocusLost:Connect(function(Pressed)
		MainFrame.Visible = false
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, Old)
		if Pressed then
			Callback(CommandBarText.Text)
		end
		CommandBarText.Text = ""
	end)
	
	function CommandBar:AddCommand(Name, Description)
		local Frame = Instance.new("Frame", SuggestionsFrame)
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, 0, 0, 24)
		Frame.BackgroundTransparency = 1
		Frame.Visible = false
		
		local Text = Instance.new("TextLabel", Frame)
		Text.BackgroundTransparency = 1
		Text.Size = UDim2.new(1, 0, 1, -16)
		Text.Font = Enum.Font.SourceSansBold
		Text.TextColor3 = Color3.fromRGB(255, 255, 255)
		Text.TextXAlignment = Enum.TextXAlignment.Left
		Text.TextSize = 16
		Text.Text = Name .. " " .. Description
		
		table.insert(RegisteredCommands, {
			Name = Name,
			Desc = Description,
			Frame = Frame
		})
	end

	return CommandBar
end

return UI
