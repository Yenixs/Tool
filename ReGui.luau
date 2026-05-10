--[[ 
    Dear-ReGui - Open Source Build By DayToDay2044
    Built from src/ directory
    All modules bundled in one file
]]

-- Module Loader
local Modules = {}
Modules.cache = {}

-- Module Definitions
Modules['lib.ide'] = function()
--[[
	@author biggaboy212 & LorekeeperZinnia???
	@description Integrated Development Environment to view and edit code within a ROBLOX experience.
]]

local IDEVersion = "8.0"

--// Compatibility 
local NewReference = cloneref or function(Ins): Instance 
	return Ins 
end

local Settings = {
	Theme = {
		Syntax = {
			Text = Color3.fromRGB(204, 204, 204),
			Background = Color3.fromRGB(20,20,20),
			Selection = Color3.fromRGB(255,255,255),
			SelectionBack = Color3.fromRGB(102, 161, 255),
			Operator = Color3.fromRGB(204, 204, 204),
			Number = Color3.fromRGB(255, 198, 0),
			String = Color3.fromRGB(172, 240, 148),
			Comment = Color3.fromRGB(102, 102, 102),
			Keyword = Color3.fromRGB(248, 109, 124),
			BuiltIn = Color3.fromRGB(132, 214, 247),
			LocalMethod = Color3.fromRGB(253, 251, 172),
			LocalProperty = Color3.fromRGB(97, 161, 241),
			Nil = Color3.fromRGB(255, 198, 0),
			Bool = Color3.fromRGB(255, 198, 0),
			Function = Color3.fromRGB(248, 109, 124),
			Local = Color3.fromRGB(248, 109, 124),
			Self = Color3.fromRGB(248, 109, 124),
			FunctionName = Color3.fromRGB(253, 251, 172),
			Bracket = Color3.fromRGB(204, 204, 204)
		},
	}
}

--// Service handlers
local Services = setmetatable({}, {
	__index = function(self, Name: string)
		local Service = game:GetService(Name)
		return NewReference(Service)
	end,
})

local UserInputTypes = {
	StartAndEnd = {
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.Touch
	},
	Movement = {
		Enum.UserInputType.MouseMovement,
		Enum.UserInputType.Touch
	}
}

--// Services
local Players: Players = Services.Players
local UserInputService: UserInputService = Services.UserInputService
local RunService: RunService = Services.RunService
local TweenService: TweenService = Services.TweenService

local LocalPlayer = NewReference(Players.LocalPlayer)
local Mouse = NewReference(LocalPlayer:GetMouse())

local function Merge(Base, New)
	for Key, Value in next, New do
		Base[Key] = Value
	end
	return Base
end

local function InputTypeAllowed(Key, Type: string)
	local InputType = Key.UserInputType
	return table.find(UserInputTypes[Type], InputType)
end

local function NewInstance(...)
	return NewReference(Instance.new(...))
end

local function createSimple(class,props)
	local inst = NewInstance(class)
	for i,v in next,props do
		inst[i] = v
	end
	return inst
end

local Lib = {}
local cursor = NewInstance("Frame")

Lib.CheckMouseInGui = function(gui)
	if gui == nil then return false end
	local guiPosition = gui.AbsolutePosition
	local guiSize = gui.AbsoluteSize	

	return Mouse.X >= guiPosition.X and Mouse.X < guiPosition.X + guiSize.X and Mouse.Y >= guiPosition.Y and Mouse.Y < guiPosition.Y + guiSize.Y
end

Lib.Signal = (function()
	local funcs = {}

	local disconnect = function(con)
		local pos = table.find(con.Signal.Connections,con)
		if pos then table.remove(con.Signal.Connections,pos) end
	end

	funcs.Connect = function(self,func)
		if type(func) ~= "function" then error("Attempt to connect a non-function") end		
		local con = {
			Signal = self,
			Func = func,
			Disconnect = disconnect
		}
		self.Connections[#self.Connections+1] = con
		return con
	end

	funcs.Fire = function(self,...)
		for i,v in next,self.Connections do
			xpcall(coroutine.wrap(v.Func),function(e) warn(e.."\n"..debug.traceback()) end,...)
		end
	end

	local mt = {
		__index = funcs,
		__tostring = function(self)
			return "Signal: " .. tostring(#self.Connections) .. " Connections"
		end
	}

	local function new()
		local obj = {}
		obj.Connections = {}

		return setmetatable(obj,mt)
	end

	return {new = new}
end)()

Lib.CreateArrow = function(size,num,dir)
	local max = num
	local arrowFrame = createSimple("Frame",{
		BackgroundTransparency = 1,
		Name = "Arrow",
		Size = UDim2.new(0,size,0,size)
	})
	if dir == "up" then
		for i = 1,num do
			createSimple("Frame",{
				BackgroundColor3 = Color3.new(220/255,220/255,220/255),
				BorderSizePixel = 0,
				Position = UDim2.new(0,math.floor(size/2)-(i-1),0,math.floor(size/2)+i-math.floor(max/2)-1),
				Size = UDim2.new(0,i+(i-1),0,1),
				Parent = arrowFrame
			})
		end
		return arrowFrame
	elseif dir == "down" then
		for i = 1,num do
			createSimple("Frame",{
				BackgroundColor3 = Color3.new(220/255,220/255,220/255),
				BorderSizePixel = 0,
				Position = UDim2.new(0,math.floor(size/2)-(i-1),0,math.floor(size/2)-i+math.floor(max/2)+1),
				Size = UDim2.new(0,i+(i-1),0,1),
				Parent = arrowFrame
			})
		end
		return arrowFrame
	elseif dir == "left" then
		for i = 1,num do
			createSimple("Frame",{
				BackgroundColor3 = Color3.new(220/255,220/255,220/255),
				BorderSizePixel = 0,
				Position = UDim2.new(0,math.floor(size/2)+i-math.floor(max/2)-1,0,math.floor(size/2)-(i-1)),
				Size = UDim2.new(0,1,0,i+(i-1)),
				Parent = arrowFrame
			})
		end
		return arrowFrame
	elseif dir == "right" then
		for i = 1,num do
			createSimple("Frame",{
				BackgroundColor3 = Color3.new(220/255,220/255,220/255),
				BorderSizePixel = 0,
				Position = UDim2.new(0,math.floor(size/2)-i+math.floor(max/2)+1,0,math.floor(size/2)-(i-1)),
				Size = UDim2.new(0,1,0,i+(i-1)),
				Parent = arrowFrame
			})
		end
		return arrowFrame
	end
	error("")
end

Lib.FastWait = (function(arg)
	return task.wait(arg)
end)

Lib.ScrollBar = (function()
	local funcs = {}
	local checkMouseInGui = Lib.CheckMouseInGui
	local createArrow = Lib.CreateArrow

	local function drawThumb(self)
		local total = self.TotalSpace
		local visible = self.VisibleSpace
		local scrollThumb = self.GuiElems.ScrollThumb
		local scrollThumbFrame = self.GuiElems.ScrollThumbFrame

		if not (self:CanScrollUp()	or self:CanScrollDown()) then
			scrollThumb.Visible = false
		else
			scrollThumb.Visible = true
		end

		if self.Horizontal then
			scrollThumb.Size = UDim2.new(visible/total,0,1,0)
			if scrollThumb.AbsoluteSize.X < 10 then
				scrollThumb.Size = UDim2.new(0,10,1,0)
			end
			local fs = scrollThumbFrame.AbsoluteSize.X
			local bs = scrollThumb.AbsoluteSize.X
			scrollThumb.Position = UDim2.new(self:GetScrollPercent()*(fs-bs)/fs,0,0,0)
		else
			scrollThumb.Size = UDim2.new(1,0,visible/total,0)
			if scrollThumb.AbsoluteSize.Y < 10 then
				scrollThumb.Size = UDim2.new(1,0,0,10)
			end
			local fs = scrollThumbFrame.AbsoluteSize.Y
			local bs = scrollThumb.AbsoluteSize.Y
			scrollThumb.Position = UDim2.new(0,0,self:GetScrollPercent()*(fs-bs)/fs,0)
		end
	end

	local function createFrame(self)
		local newFrame = createSimple("Frame",{Style=0,Active=true,AnchorPoint=Vector2.new(0,0),BackgroundColor3=Color3.new(0.35294118523598,0.35294118523598,0.35294118523598),BackgroundTransparency=0,BorderColor3=Color3.new(0.10588236153126,0.16470588743687,0.20784315466881),BorderSizePixel=0,ClipsDescendants=false,Draggable=false,Position=UDim2.new(1,-10,0,0),Rotation=0,Selectable=false,Size=UDim2.new(0,10,1,0),SizeConstraint=0,Visible=true,ZIndex=1,Name="ScrollBar",})
		local button1 = nil
		local button2 = nil

		if self.Horizontal then
			newFrame.Size = UDim2.new(1,0,0,10)
			button1 = createSimple("ImageButton",{
				Parent = newFrame,
				Name = "Left",
				Size = UDim2.new(0,10,0,10),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false
			})
			createArrow(10,4,"left").Parent = button1
			button2 = createSimple("ImageButton",{
				Parent = newFrame,
				Name = "Right",
				Position = UDim2.new(1,-10,0,0),
				Size = UDim2.new(0,10,0,10),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false
			})
			createArrow(10,4,"right").Parent = button2
		else
			newFrame.Size = UDim2.new(0,10,1,0)
			button1 = createSimple("ImageButton",{
				Parent = newFrame,
				Name = "Up",
				Size = UDim2.new(0,10,0,10),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false
			})
			createArrow(10,4,"up").Parent = button1
			button2 = createSimple("ImageButton",{
				Parent = newFrame,
				Name = "Down",
				Position = UDim2.new(0,0,1,-10),
				Size = UDim2.new(0,10,0,10),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false
			})
			createArrow(10,4,"down").Parent = button2
		end

		local scrollThumbFrame = createSimple("Frame",{
			BackgroundTransparency = 1,
			Parent = newFrame
		})
		if self.Horizontal then
			scrollThumbFrame.Position = UDim2.new(0,10,0,0)
			scrollThumbFrame.Size = UDim2.new(1,-20,1,0)
		else
			scrollThumbFrame.Position = UDim2.new(0,0,0,10)
			scrollThumbFrame.Size = UDim2.new(1,0,1,-20)
		end

		local scrollThumb = createSimple("Frame",{
			BackgroundColor3 = Color3.new(120/255,120/255,120/255),
			BorderSizePixel = 0,
			Parent = scrollThumbFrame
		})

		local markerFrame = createSimple("Frame",{
			BackgroundTransparency = 1,
			Name = "Markers",
			Size = UDim2.new(1,0,1,0),
			Parent = scrollThumbFrame
		})

		local buttonPress = false
		local thumbPress = false
		local thumbFramePress = false

		button1.InputBegan:Connect(function(input)
			if InputTypeAllowed(input, "Movement") and not buttonPress and self:CanScrollUp() then button1.BackgroundTransparency = 0.8 end
			if not InputTypeAllowed(input, "StartAndEnd") or not self:CanScrollUp() then return end
			buttonPress = true
			button1.BackgroundTransparency = 0.5
			if self:CanScrollUp() then 
				self:ScrollUp() 
				self.Scrolled:Fire() 
			end
			local buttonTick = tick()
			local releaseEvent
			releaseEvent = UserInputService.InputEnded:Connect(function(input)
				if not InputTypeAllowed(input, "StartAndEnd") then return end
				releaseEvent:Disconnect()
				if checkMouseInGui(button1) and self:CanScrollUp() then button1.BackgroundTransparency = 0.8 else button1.BackgroundTransparency = 1 end
				buttonPress = false
			end)
			while buttonPress do
				if tick() - buttonTick >= 0.3 and self:CanScrollUp() then
					self:ScrollUp()
					self.Scrolled:Fire()
				end
				task.wait()
			end
		end)
		button1.InputEnded:Connect(function(input)
			if InputTypeAllowed(input, "Movement") and not buttonPress then button1.BackgroundTransparency = 1 end
		end)
		button2.InputBegan:Connect(function(input)
			if InputTypeAllowed(input, "Movement") and not buttonPress and self:CanScrollDown() then button2.BackgroundTransparency = 0.8 end
			if not InputTypeAllowed(input, "StartAndEnd") or not self:CanScrollDown() then return end
			buttonPress = true
			button2.BackgroundTransparency = 0.5
			if self:CanScrollDown() then 
				self:ScrollDown() 
				self.Scrolled:Fire() 
			end
			local buttonTick = tick()
			local releaseEvent
			releaseEvent = UserInputService.InputEnded:Connect(function(input)
				if not InputTypeAllowed(input, "StartAndEnd") then return end
				releaseEvent:Disconnect()
				if checkMouseInGui(button2) and self:CanScrollDown() then button2.BackgroundTransparency = 0.8 else button2.BackgroundTransparency = 1 end
				buttonPress = false
			end)
			while buttonPress do
				if tick() - buttonTick >= 0.3 and self:CanScrollDown() then
					self:ScrollDown()
					self.Scrolled:Fire()
				end
				task.wait()
			end
		end)
		button2.InputEnded:Connect(function(input)
			if InputTypeAllowed(input, "Movement") and not buttonPress then button2.BackgroundTransparency = 1 end
		end)

		scrollThumb.InputBegan:Connect(function(input)
			if InputTypeAllowed(input, "Movement") and not thumbPress then 
				scrollThumb.BackgroundTransparency = 0.2 
				scrollThumb.BackgroundColor3 = self.ThumbSelectColor 
			end
			if not InputTypeAllowed(input, "StartAndEnd") then return end

			local dir = self.Horizontal and "X" or "Y"
			local lastThumbPos = nil

			buttonPress = false
			thumbFramePress = false			
			thumbPress = true
			scrollThumb.BackgroundTransparency = 0
			local mouseOffset = Mouse[dir] - scrollThumb.AbsolutePosition[dir]
			local releaseEvent
			local mouseEvent
			releaseEvent = UserInputService.InputEnded:Connect(function(input)
				if not InputTypeAllowed(input, "StartAndEnd") then return end
				releaseEvent:Disconnect()
				if mouseEvent then mouseEvent:Disconnect() end
				if checkMouseInGui(scrollThumb) then 
					scrollThumb.BackgroundTransparency = 0.2 
				else 
					scrollThumb.BackgroundTransparency = 0 
					scrollThumb.BackgroundColor3 = self.ThumbColor 
				end
				thumbPress = false
			end)
			self:Update()

			mouseEvent = UserInputService.InputChanged:Connect(function(input)
				if InputTypeAllowed(input, "Movement") and thumbPress and releaseEvent.Connected then
					local thumbFrameSize = scrollThumbFrame.AbsoluteSize[dir]-scrollThumb.AbsoluteSize[dir]
					local pos = Mouse[dir] - scrollThumbFrame.AbsolutePosition[dir] - mouseOffset
					if pos > thumbFrameSize then
						pos = thumbFrameSize
					elseif pos < 0 then
						pos = 0
					end
					if lastThumbPos ~= pos then
						lastThumbPos = pos
						self:ScrollTo(math.floor(0.5+pos/thumbFrameSize*(self.TotalSpace-self.VisibleSpace)))
					end
					task.wait()
				end
			end)
		end)
		scrollThumb.InputEnded:Connect(function(input)
			if InputTypeAllowed(input, "Movement") and not thumbPress then 
				scrollThumb.BackgroundTransparency = 0 
				scrollThumb.BackgroundColor3 = self.ThumbColor 
			end
		end)
		scrollThumbFrame.InputBegan:Connect(function(input)
			if not InputTypeAllowed(input, "StartAndEnd") or checkMouseInGui(scrollThumb) then return end

			local dir = self.Horizontal and "X" or "Y"
			local scrollDir = 0
			if Mouse[dir] >= scrollThumb.AbsolutePosition[dir] + scrollThumb.AbsoluteSize[dir] then
				scrollDir = 1
			end

			local function doTick()
				local scrollSize = self.VisibleSpace - 1
				if scrollDir == 0 and Mouse[dir] < scrollThumb.AbsolutePosition[dir] then
					self:ScrollTo(self.Index - scrollSize)
				elseif scrollDir == 1 and Mouse[dir] >= scrollThumb.AbsolutePosition[dir] + scrollThumb.AbsoluteSize[dir] then
					self:ScrollTo(self.Index + scrollSize)
				end
			end

			thumbPress = false			
			thumbFramePress = true
			doTick()
			local thumbFrameTick = tick()
			local releaseEvent
			releaseEvent = UserInputService.InputEnded:Connect(function(input)
				if not InputTypeAllowed(input, "StartAndEnd") then return end
				releaseEvent:Disconnect()
				thumbFramePress = false
			end)
			while thumbFramePress do
				if tick() - thumbFrameTick >= 0.3 and checkMouseInGui(scrollThumbFrame) then
					doTick()
				end
				task.wait()
			end
		end)

		newFrame.MouseWheelForward:Connect(function()
			self:ScrollTo(self.Index - self.WheelIncrement)
		end)

		newFrame.MouseWheelBackward:Connect(function()
			self:ScrollTo(self.Index + self.WheelIncrement)
		end)

		self.GuiElems.ScrollThumb = scrollThumb
		self.GuiElems.ScrollThumbFrame = scrollThumbFrame
		self.GuiElems.Button1 = button1
		self.GuiElems.Button2 = button2
		self.GuiElems.MarkerFrame = markerFrame

		return newFrame
	end

	funcs.Update = function(self,nocallback)
		local total = self.TotalSpace
		local visible = self.VisibleSpace
		local button1 = self.GuiElems.Button1
		local button2 = self.GuiElems.Button2

		self.Index = math.clamp(self.Index,0,math.max(0,total-visible))

		if self.LastTotalSpace ~= self.TotalSpace then
			self.LastTotalSpace = self.TotalSpace
			self:UpdateMarkers()
		end

		if self:CanScrollUp() then
			for i,v in pairs(button1.Arrow:GetChildren()) do
				v.BackgroundTransparency = 0
			end
		else
			button1.BackgroundTransparency = 1
			for i,v in pairs(button1.Arrow:GetChildren()) do
				v.BackgroundTransparency = 0.5
			end
		end
		if self:CanScrollDown() then
			for i,v in pairs(button2.Arrow:GetChildren()) do
				v.BackgroundTransparency = 0
			end
		else
			button2.BackgroundTransparency = 1
			for i,v in pairs(button2.Arrow:GetChildren()) do
				v.BackgroundTransparency = 0.5
			end
		end

		drawThumb(self)
	end

	funcs.UpdateMarkers = function(self)
		local markerFrame = self.GuiElems.MarkerFrame
		markerFrame:ClearAllChildren()

		for i,v in pairs(self.Markers) do
			if i < self.TotalSpace then
				createSimple("Frame",{
					BackgroundTransparency = 0,
					BackgroundColor3 = v,
					BorderSizePixel = 0,
					Position = self.Horizontal and UDim2.new(i/self.TotalSpace,0,1,-6) or UDim2.new(1,-6,i/self.TotalSpace,0),
					Size = self.Horizontal and UDim2.new(0,1,0,6) or UDim2.new(0,6,0,1),
					Name = "Marker"..tostring(i),
					Parent = markerFrame
				})
			end
		end
	end

	funcs.AddMarker = function(self,ind,color)
		self.Markers[ind] = color or Color3.new(0,0,0)
	end
	funcs.ScrollTo = function(self,ind,nocallback)
		self.Index = ind
		self:Update()
		if not nocallback then
			self.Scrolled:Fire()
		end
	end
	funcs.ScrollUp = function(self)
		self.Index = self.Index - self.Increment
		self:Update()
	end
	funcs.ScrollDown = function(self)
		self.Index = self.Index + self.Increment
		self:Update()
	end
	funcs.CanScrollUp = function(self)
		return self.Index > 0
	end
	funcs.CanScrollDown = function(self)
		return self.Index + self.VisibleSpace < self.TotalSpace
	end
	funcs.GetScrollPercent = function(self)
		return self.Index/(self.TotalSpace-self.VisibleSpace)
	end
	funcs.SetScrollPercent = function(self,perc)
		self.Index = math.floor(perc*(self.TotalSpace-self.VisibleSpace))
		self:Update()
	end

	funcs.Texture = function(self,data)
		self.ThumbColor = data.ThumbColor or Color3.new(0,0,0)
		self.ThumbSelectColor = data.ThumbSelectColor or Color3.new(0,0,0)
		self.GuiElems.ScrollThumb.BackgroundColor3 = data.ThumbColor or Color3.new(0,0,0)
		self.Gui.BackgroundColor3 = data.FrameColor or Color3.new(0,0,0)
		self.GuiElems.Button1.BackgroundColor3 = data.ButtonColor or Color3.new(0,0,0)
		self.GuiElems.Button2.BackgroundColor3 = data.ButtonColor or Color3.new(0,0,0)
		for i,v in pairs(self.GuiElems.Button1.Arrow:GetChildren()) do
			v.BackgroundColor3 = data.ArrowColor or Color3.new(0,0,0)
		end
		for i,v in pairs(self.GuiElems.Button2.Arrow:GetChildren()) do
			v.BackgroundColor3 = data.ArrowColor or Color3.new(0,0,0)
		end
	end

	funcs.SetScrollFrame = function(self,frame)
		if self.ScrollUpEvent then 
			self.ScrollUpEvent:Disconnect() 
			self.ScrollUpEvent = nil 
		end
		if self.ScrollDownEvent then 
			self.ScrollDownEvent:Disconnect() 
			self.ScrollDownEvent = nil 
		end
		self.ScrollUpEvent = frame.MouseWheelForward:Connect(function() self:ScrollTo(self.Index - self.WheelIncrement) end)
		self.ScrollDownEvent = frame.MouseWheelBackward:Connect(function() self:ScrollTo(self.Index + self.WheelIncrement) end)
	end

	local mt = {}
	mt.__index = funcs

	local function new(hor)
		local obj = setmetatable({
			Index = 0,
			VisibleSpace = 0,
			TotalSpace = 0,
			Increment = 1,
			WheelIncrement = 1,
			Markers = {},
			GuiElems = {},
			Horizontal = hor,
			LastTotalSpace = 0,
			Scrolled = Lib.Signal.new()
		},mt)
		obj.Gui = createFrame(obj)
		obj:Texture({
			ThumbColor = Color3.fromRGB(60,60,60),
			ThumbSelectColor = Color3.fromRGB(75,75,75),
			ArrowColor = Color3.new(1,1,1),
			FrameColor = Color3.fromRGB(40,40,40),
			ButtonColor = Color3.fromRGB(75,75,75)
		})
		return obj
	end

	return {new = new}
end)()

Lib.CodeFrame = (function()
	local funcs = {}

	local typeMap = {
		[1] = "String",
		[2] = "String",
		[3] = "String",
		[4] = "Comment",
		[5] = "Operator",
		[6] = "Number",
		[7] = "Keyword",
		[8] = "BuiltIn",
		[9] = "LocalMethod",
		[10] = "LocalProperty",
		[11] = "Nil",
		[12] = "Bool",
		[13] = "Function",
		[14] = "Local",
		[15] = "Self",
		[16] = "FunctionName",
		[17] = "Bracket"
	}

	local specialKeywordsTypes = {
		["nil"] = 11,
		["true"] = 12,
		["false"] = 12,
		["function"] = 13,
		["local"] = 14,
		["self"] = 15
	}

	local keywords = {
		["and"] = true,
		["break"] = true, 
		["do"] = true,
		["else"] = true,
		["elseif"] = true,
		["end"] = true,
		["false"] = true,
		["for"] = true,
		["function"] = true,
		["if"] = true,
		["in"] = true,
		["local"] = true,
		["nil"] = true,
		["not"] = true,
		["or"] = true,
		["repeat"] = true,
		["return"] = true,
		["then"] = true,
		["true"] = true,
		["until"] = true,
		["while"] = true,
		["plugin"] = true
	}

	local builtIns = {
		["delay"] = true,
		["elapsedTime"] = true,
		["require"] = true,
		["spawn"] = true,
		["tick"] = true,
		["time"] = true,
		["typeof"] = true,
		["UserSettings"] = true,
		["wait"] = true,
		["warn"] = true,
		["game"] = true,
		["shared"] = true,
		["script"] = true,
		["workspace"] = true,
		["assert"] = true,
		["collectgarbage"] = true,
		["error"] = true,
		["getfenv"] = true,
		["getmetatable"] = true,
		["ipairs"] = true,
		["loadstring"] = true,
		["newproxy"] = true,
		["next"] = true,
		["pairs"] = true,
		["pcall"] = true,
		["print"] = true,
		["rawequal"] = true,
		["rawget"] = true,
		["rawset"] = true,
		["select"] = true,
		["setfenv"] = true,
		["setmetatable"] = true,
		["tonumber"] = true,
		["tostring"] = true,
		["type"] = true,
		["unpack"] = true,
		["xpcall"] = true,
		["_G"] = true,
		["_VERSION"] = true,
		["coroutine"] = true,
		["debug"] = true,
		["math"] = true,
		["os"] = true,
		["string"] = true,
		["table"] = true,
		["bit32"] = true,
		["utf8"] = true,
		["Axes"] = true,
		["BrickColor"] = true,
		["CFrame"] = true,
		["Color3"] = true,
		["ColorSequence"] = true,
		["ColorSequenceKeypoint"] = true,
		["DockWidgetPluginGuiInfo"] = true,
		["Enum"] = true,
		["Faces"] = true,
		["Instance"] = true,
		["NumberRange"] = true,
		["NumberSequence"] = true,
		["NumberSequenceKeypoint"] = true,
		["PathWaypoint"] = true,
		["PhysicalProperties"] = true,
		["Random"] = true,
		["Ray"] = true,
		["Rect"] = true,
		["Region3"] = true,
		["Region3int16"] = true,
		["TweenInfo"] = true,
		["UDim"] = true,
		["UDim2"] = true,
		["Vector2"] = true,
		["Vector2int16"] = true,
		["Vector3"] = true,
		["Vector3int16"] = true,

		--// Libraries
		["Drawing"] = true,
		["syn"] = true, -- For compatability
		["crypt"] = true,
		["cache"] = true,
		["bit"] = true,

		--// Custom Lua Functions
		-- File Functions
		["readfile"] = true,
		["writefile"] = true,
		["isfile"] = true,
		["appendfile"] = true,
		["listfiles"] = true,
		["loadfile"] = true,
		["isfolder"] = true,
		["makefolder"] = true,
		["delfolder"] = true,
		["delfile"] = true,

		-- Misc Functions
		["setclipboard"] = true,
		["setfflag"] = true,
		["getnamecallmethod"] = true,
		["isluau"] = true, -- For compatability
		["setnonreplicatedproperty"] = true,
		["getspecialinfo"] = true,
		["saveinstance"] = true,
		--[=[ ["messagebox"] = true, ]=] -- Disabled for security

		-- Console Functions (for compatability)
		["rconsoleprint"] = true,
		["rconsoleinfo"] = true,
		["rconsolewarn"] = true,
		["rconsoleerr"] = true,
		["rconsoleclear"] = true,
		["rconsolename"] = true,
		["rconsoleinput"] = true,
		["rconsoleinputasync"] = true,
		["printconsole"] = true,

		--- Reflection Functions
		--[=[ ["loadstring"] = true, ]=] -- Disabled, already stated.
		["checkcaller"] = true,
		["islclosure"] = true,
		["iscclosure"] = true,
		["dumpstring"] = true,
		["decompile"] = true,

		-- Hooking Functions
		["hookfunction"] = true,
		["newcclosure"] = true,

		-- KB/M Functions
		["isrbxactive"] = true,
		["keypress"] = true,
		["keyrelease"] = true,

		["mouse1click"] = true,
		["mouse1press"] = true,
		["mouse1release"] = true,

		["mouse2click"] = true,
		["mouse2press"] = true,
		["mouse2release"] = true,

		["mousescroll"] = true,
		["mousemoveabs"] = true,
		["mousemoverel"] = true,

		-- Table Modification Functions
		["getrawmetatable"] = true,
		["setrawmetatable"] = true,
		["setreadonly"] = true,
		["isreadonly"] = true,

		-- Script Env Functions
		["getsenv"] = true,
		["getcallingscript"] = true,

		-- Env Helping Functions
		["getgenv"] = true,
		["getrenv"] = true,
		["getreg"] = true,
		["getgc"] = true,
		["getinstances"] = true,
		["getnilinstances"] = true,
		["getscripts"] = true,
		["getloadedmodules"] = true,
		["getconnections"] = true,
		["firesignal"] = true,
		["fireclickdetector"] = true,
		["firetouchinterest"] = true,
		["fireproximityprompt"] = true
	}

	local builtInInited = false

	local richReplace = {
		["'"] = "&apos;",
		["\""] = "&quot;",
		["<"] = "&lt;",
		[">"] = "&gt;",
		["&"] = "&amp;"
	}

	local tabSub = "\205"
	local tabReplacement = (" %s%s "):format(tabSub,tabSub)

	local tabJumps = {
		[("[^%s] %s"):format(tabSub,tabSub)] = 0,
		[(" %s%s"):format(tabSub,tabSub)] = -1,
		[("%s%s "):format(tabSub,tabSub)] = 2,
		[("%s [^%s]"):format(tabSub,tabSub)] = 1,
	}

	local lineTweens = {}

	local function initBuiltIn()
		local env = getfenv()
		local type = type
		local tostring = tostring
		for name,_ in next,builtIns do
			local envVal = env[name]
			if type(envVal) == "table" then
				local items = {}
				for i,v in next,envVal do
					items[i] = true
				end
				builtIns[name] = items
			end
		end

		local enumEntries = {}
		local enums = Enum:GetEnums()
		for i = 1,#enums do
			enumEntries[tostring(enums[i])] = true
		end
		builtIns["Enum"] = enumEntries

		builtInInited = true
	end

	local function setupEditBox(obj)
		local editBox = obj.GuiElems.EditBox

		editBox.Focused:Connect(function()
			obj:ConnectEditBoxEvent()
			obj.Editing = true
		end)

		editBox.FocusLost:Connect(function()
			obj:DisconnectEditBoxEvent()
			obj.Editing = false
		end)

		editBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = editBox.Text
			if #text == 0 or obj.EditBoxCopying then return end

			text = text:gsub("\t", "    ")

			editBox.Text = ""
			obj:AppendText(text)
		end)

	end

	local function setupMouseSelection(obj)
		local codeFrame = obj.GuiElems.LinesFrame
		local lines = obj.Lines

		codeFrame.InputBegan:Connect(function(input)
			if InputTypeAllowed(input, "StartAndEnd") then
				local fontSizeX,fontSizeY = math.ceil(obj.FontSize/2),obj.FontSize

				local relX = Mouse.X - codeFrame.AbsolutePosition.X
				local relY = Mouse.Y - codeFrame.AbsolutePosition.Y
				local selX = math.round(relX / fontSizeX) + obj.ViewX
				local selY = math.floor(relY / fontSizeY) + obj.ViewY

				local releaseEvent,mouseEvent,scrollEvent
				local scrollPowerV,scrollPowerH = 0,0
				selY = math.min(#lines-1,selY)
				local relativeLine = lines[selY+1] or ""
				selX = math.min(#relativeLine, selX + obj:TabAdjust(selX,selY))

				obj.SelectionRange = {{-1,-1},{-1,-1}}
				obj:MoveCursor(selX, selY)
				obj.FloatCursorX = selX

				local function updateSelection()
					local relX = Mouse.X - codeFrame.AbsolutePosition.X
					local relY = Mouse.Y - codeFrame.AbsolutePosition.Y
					local sel2X = math.max(0,math.round(relX / fontSizeX) + obj.ViewX)
					local sel2Y = math.max(0,math.floor(relY / fontSizeY) + obj.ViewY)

					sel2Y = math.min(#lines-1,sel2Y)
					local relativeLine = lines[sel2Y+1] or ""
					sel2X = math.min(#relativeLine, sel2X + obj:TabAdjust(sel2X,sel2Y))

					if sel2Y < selY or (sel2Y == selY and sel2X < selX) then
						obj.SelectionRange = {{sel2X,sel2Y},{selX,selY}}
					else						
						obj.SelectionRange = {{selX,selY},{sel2X,sel2Y}}
					end

					obj:MoveCursor(sel2X,sel2Y)
					obj.FloatCursorX = sel2X
					obj:Refresh()
				end

				releaseEvent = UserInputService.InputEnded:Connect(function(input)
					if InputTypeAllowed(input, "StartAndEnd") then
						releaseEvent:Disconnect()
						mouseEvent:Disconnect()
						scrollEvent:Disconnect()
						obj:SetCopyableSelection()
						--updateSelection()
					end
				end)

				mouseEvent = UserInputService.InputChanged:Connect(function(input)
					if InputTypeAllowed(input, "Movement") then
						local upDelta = Mouse.Y - codeFrame.AbsolutePosition.Y
						local downDelta = Mouse.Y - codeFrame.AbsolutePosition.Y - codeFrame.AbsoluteSize.Y
						local leftDelta = Mouse.X - codeFrame.AbsolutePosition.X
						local rightDelta = Mouse.X - codeFrame.AbsolutePosition.X - codeFrame.AbsoluteSize.X
						scrollPowerV = 0
						scrollPowerH = 0
						if downDelta > 0 then
							scrollPowerV = math.floor(downDelta*0.05) + 1
						elseif upDelta < 0 then
							scrollPowerV = math.ceil(upDelta*0.05) - 1
						end
						if rightDelta > 0 then
							scrollPowerH = math.floor(rightDelta*0.05) + 1
						elseif leftDelta < 0 then
							scrollPowerH = math.ceil(leftDelta*0.05) - 1
						end
						updateSelection()
					end
				end)

				scrollEvent = RunService.RenderStepped:Connect(function()
					if scrollPowerV ~= 0 or scrollPowerH ~= 0 then
						obj:ScrollDelta(scrollPowerH,scrollPowerV)
						updateSelection()
					end
				end)

				obj:Refresh()
			end
		end)
	end

	function funcs.MakeEditorFrame(self)
		local frame = NewInstance('TextButton')
		frame.BackgroundTransparency = 1
		frame.TextTransparency = 1
		frame.BackgroundColor3=Color3.fromRGB(40, 40, 40);
		frame.BorderSizePixel=0; 
		frame.Size=UDim2.fromOffset(100,100);
		frame.Visible=true;
		local elems = {}

		local linesFrame = NewInstance("Frame")
		linesFrame.Name = "Lines"
		linesFrame.BackgroundTransparency = 1
		linesFrame.Size = UDim2.new(1,0,1,0)
		linesFrame.ClipsDescendants = true
		linesFrame.Parent = frame

		local lineNumbersLabel = NewInstance("TextLabel")
		lineNumbersLabel.Name = "LineNumbers"
		lineNumbersLabel.BackgroundTransparency = 1
		lineNumbersLabel.FontFace = self.FontFace
		lineNumbersLabel.TextXAlignment = Enum.TextXAlignment.Right
		lineNumbersLabel.TextYAlignment = Enum.TextYAlignment.Top
		lineNumbersLabel.ClipsDescendants = true
		lineNumbersLabel.RichText = true
		lineNumbersLabel.Parent = frame

		cursor.Name = "Cursor"
		cursor.BackgroundColor3 = Color3.fromRGB(220,220,220)
		cursor.BorderSizePixel = 0
		cursor.Parent = frame

		local editBox = NewInstance("TextBox")
		editBox.Name = "EditBox"
		editBox.MultiLine = true
		editBox.Visible = false
		editBox.Parent = frame
		editBox.TextSize = self.FontSize
		editBox.FontFace = self.FontFace

		lineTweens.Invis = TweenService:Create(cursor,TweenInfo.new(0,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundTransparency = 1})
		lineTweens.Vis = TweenService:Create(cursor,TweenInfo.new(0,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundTransparency = 0})

		local scrcfrm = NewInstance('Frame')
		scrcfrm.BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945);scrcfrm.BorderSizePixel=0;scrcfrm.Name="ScrollCorner";scrcfrm.Position=UDim2.new(1,-10,1,-10);scrcfrm.Size=UDim2.new(0,10,0,10);scrcfrm.Visible=false;
		
		elems.ScrollCorner = scrcfrm
		elems.LinesFrame = linesFrame
		elems.LineNumbersLabel = lineNumbersLabel
		elems.Cursor = cursor
		elems.EditBox = editBox
		elems.ScrollCorner.Parent = frame
		
		linesFrame.InputBegan:Connect(function(input)
			if InputTypeAllowed(input, "StartAndEnd") then
				self:SetEditing(true,input)
			end
		end)

		self.Frame = frame
		self.Gui = frame
		self.GuiElems = elems
		setupEditBox(self)
		setupMouseSelection(self)

		return frame
	end

	funcs.GetSelectionText = function(self)
		if not self:IsValidRange() then return "" end

		local selectionRange = self.SelectionRange
		local selX,selY = selectionRange[1][1], selectionRange[1][2]
		local sel2X,sel2Y = selectionRange[2][1], selectionRange[2][2]
		local deltaLines = sel2Y-selY
		local lines = self.Lines

		if not lines[selY+1] or not lines[sel2Y+1] then return "" end

		if deltaLines == 0 then
			return self:ConvertText(lines[selY+1]:sub(selX+1,sel2X), false)
		end

		local leftSub = lines[selY+1]:sub(selX+1)
		local rightSub = lines[sel2Y+1]:sub(1,sel2X)

		local result = leftSub.."\n" 
		for i = selY+1,sel2Y-1 do
			result = result..lines[i+1].."\n"
		end
		result = result..rightSub

		return self:ConvertText(result,false)
	end

	funcs.SetCopyableSelection = function(self)
		local text = self:GetSelectionText()
		local editBox = self.GuiElems.EditBox

		self.EditBoxCopying = true
		editBox.Text = text
		editBox.SelectionStart = 1
		editBox.CursorPosition = #editBox.Text + 1
		self.EditBoxCopying = false
	end

	funcs.ConnectEditBoxEvent = function(self)
		if self.EditBoxEvent then
			self.EditBoxEvent:Disconnect()
		end

		self.EditBoxEvent = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

			local keycodes = Enum.KeyCode
			local keycode = input.KeyCode

			local function setupMove(key,func)
				local endCon,finished
				endCon = UserInputService.InputEnded:Connect(function(input)
					if input.KeyCode ~= key then return end
					endCon:Disconnect()
					finished = true
				end)
				func()
				Lib.FastWait(0.5)
				while not finished do 
					func() 
					Lib.FastWait(0.03) 
				end
			end

			if keycode == keycodes.Down then
				setupMove(keycodes.Down,function()
					self.CursorX = self.FloatCursorX
					self.CursorY = self.CursorY + 1
					self:UpdateCursor()
					self:JumpToCursor()
				end)
			elseif keycode == keycodes.Up then
				setupMove(keycodes.Up,function()
					self.CursorX = self.FloatCursorX
					self.CursorY = self.CursorY - 1
					self:UpdateCursor()
					self:JumpToCursor()
				end)
			elseif keycode == keycodes.Left then
				setupMove(keycodes.Left,function()
					local line = self.Lines[self.CursorY+1] or ""
					self.CursorX = self.CursorX - 1 - (line:sub(self.CursorX-3,self.CursorX) == tabReplacement and 3 or 0)
					if self.CursorX < 0 then
						self.CursorY = self.CursorY - 1
						local line2 = self.Lines[self.CursorY+1] or ""
						self.CursorX = #line2
					end
					self.FloatCursorX = self.CursorX
					self:UpdateCursor()
					self:JumpToCursor()
				end)
			elseif keycode == keycodes.Right then
				setupMove(keycodes.Right,function()
					local line = self.Lines[self.CursorY+1] or ""
					self.CursorX = self.CursorX + 1 + (line:sub(self.CursorX+1,self.CursorX+4) == tabReplacement and 3 or 0)
					if self.CursorX > #line then
						self.CursorY = self.CursorY + 1
						self.CursorX = 0
					end
					self.FloatCursorX = self.CursorX
					self:UpdateCursor()
					self:JumpToCursor()
				end)
			elseif keycode == keycodes.Backspace then
				setupMove(keycodes.Backspace,function()
					local startRange,endRange
					if self:IsValidRange() then
						startRange = self.SelectionRange[1]
						endRange = self.SelectionRange[2]
					else
						endRange = {self.CursorX,self.CursorY}
					end

					if not startRange then
						local line = self.Lines[self.CursorY+1] or ""
						self.CursorX = self.CursorX - 1 - (line:sub(self.CursorX-3,self.CursorX) == tabReplacement and 3 or 0)
						if self.CursorX < 0 then
							self.CursorY = self.CursorY - 1
							local line2 = self.Lines[self.CursorY+1] or ""
							self.CursorX = #line2
						end
						self.FloatCursorX = self.CursorX
						self:UpdateCursor()

						startRange = startRange or {self.CursorX,self.CursorY}
					end

					self:DeleteRange({startRange,endRange},false,true)
					self:ResetSelection(true)
					self:JumpToCursor()
				end)
			elseif keycode == keycodes.Delete then
				setupMove(keycodes.Delete,function()
					local startRange,endRange
					if self:IsValidRange() then
						startRange = self.SelectionRange[1]
						endRange = self.SelectionRange[2]
					else
						startRange = {self.CursorX,self.CursorY}
					end

					if not endRange then
						local line = self.Lines[self.CursorY+1] or ""
						local endCursorX = self.CursorX + 1 + (line:sub(self.CursorX+1,self.CursorX+4) == tabReplacement and 3 or 0)
						local endCursorY = self.CursorY
						if endCursorX > #line then
							endCursorY = endCursorY + 1
							endCursorX = 0
						end
						self:UpdateCursor()

						endRange = endRange or {endCursorX,endCursorY}
					end

					self:DeleteRange({startRange,endRange},false,true)
					self:ResetSelection(true)
					self:JumpToCursor()
				end)
			elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				if keycode == keycodes.A then
					self.SelectionRange = {{0,5},{#self.Lines[#self.Lines],#self.Lines-1}}
					self:SetCopyableSelection()
					self:Refresh()
				end
			end
		end)
	end

	funcs.DisconnectEditBoxEvent = function(self)
		if self.EditBoxEvent then
			self.EditBoxEvent:Disconnect()
			cursor.BackgroundTransparency = 1
			funcs.CursorAnim(self, false)
		end
	end

	funcs.ResetSelection = function(self,norefresh)
		self.SelectionRange = {{-1,-1},{-1,-1}}
		if not norefresh then self:Refresh() end
	end

	funcs.IsValidRange = function(self,range)
		local selectionRange = range or self.SelectionRange
		local selX,selY = selectionRange[1][1], selectionRange[1][2]
		local sel2X,sel2Y = selectionRange[2][1], selectionRange[2][2]

		if selX == -1 or (selX == sel2X and selY == sel2Y) then return false end

		return true
	end

	funcs.DeleteRange = function(self,range,noprocess,updatemouse)
		range = range or self.SelectionRange
		if not self:IsValidRange(range) then return end

		local lines = self.Lines
		local selX,selY = range[1][1], range[1][2]
		local sel2X,sel2Y = range[2][1], range[2][2]
		local deltaLines = sel2Y-selY

		if not lines[selY+1] or not lines[sel2Y+1] then return end

		local leftSub = lines[selY+1]:sub(1,selX)
		local rightSub = lines[sel2Y+1]:sub(sel2X+1)
		lines[selY+1] = leftSub..rightSub

		local remove = table.remove
		for i = 1,deltaLines do
			remove(lines,selY+2)
		end

		if range == self.SelectionRange then self.SelectionRange = {{-1,-1},{-1,-1}} end
		if updatemouse then
			self.CursorX = selX
			self.CursorY = selY
			self:UpdateCursor()
		end

		if not noprocess then
			self:ProcessTextChange()
		end
	end

	funcs.AppendText = function(self,text)
		self:DeleteRange(nil,true,true)
		local lines,cursorX,cursorY = self.Lines,self.CursorX,self.CursorY
		local line = lines[cursorY+1]
		local before = line:sub(1,cursorX)
		local after = line:sub(cursorX+1)

		text = text:gsub("\r\n","\n")
		text = self:ConvertText(text,true) -- Tab Convert

		local textLines = text:split("\n")
		local insert = table.insert

		for i = 1,#textLines do
			local linePos = cursorY+i
			if i > 1 then insert(lines,linePos,"") end

			local textLine = textLines[i]
			local newBefore = (i == 1 and before or "")
			local newAfter = (i == #textLines and after or "")

			lines[linePos] = newBefore..textLine..newAfter
		end

		if #textLines > 1 then cursorX = 0 end

		self:ProcessTextChange()
		self.CursorX = cursorX + #textLines[#textLines]
		self.CursorY = cursorY + #textLines-1
		self:UpdateCursor()
	end

	funcs.ScrollDelta = function(self,x,y)
		self.ScrollV:ScrollTo(self.ScrollV.Index + y)
		self.ScrollH:ScrollTo(self.ScrollH.Index + x)
	end

	-- x and y starts at 0
	funcs.TabAdjust = function(self,x,y)
		local lines = self.Lines
		local line = lines[y+1]
		x=x+1

		if line then
			local left = line:sub(x-1,x-1)
			local middle = line:sub(x,x)
			local right = line:sub(x+1,x+1)
			local selRange = (#left > 0 and left or " ") .. (#middle > 0 and middle or " ") .. (#right > 0 and right or " ")

			for i,v in pairs(tabJumps) do
				if selRange:find(i) then
					return v
				end
			end
		end
		return 0
	end

	funcs.SetEditing = function(self,on,input)			
		if input then
			self:UpdateCursor(input)
		end

		if on then
			if self.Editable then
				self.GuiElems.EditBox.Text = ""
				self.GuiElems.EditBox:CaptureFocus()
			end
		else
			self.GuiElems.EditBox:ReleaseFocus()
		end
	end

	funcs.CursorAnim = function(self,on)
		local cursor = self.GuiElems.Cursor
		local animTime = tick()
		self.LastAnimTime = animTime

		if not on then return end

		lineTweens.Invis:Cancel()
		lineTweens.Vis:Cancel()
		cursor.BackgroundTransparency = 0

		coroutine.wrap(function()
			while self.Editable do
				Lib.FastWait(0.5)
				if self.LastAnimTime ~= animTime then return end
				lineTweens.Invis:Play()
				Lib.FastWait(0.5)
				if self.LastAnimTime ~= animTime then return end
				lineTweens.Vis:Play()
				--Lib.FastWait(0.2)
			end
		end)()
	end

	funcs.MoveCursor = function(self,x,y)
		self.CursorX = x
		self.CursorY = y
		self:UpdateCursor()
		self:JumpToCursor()
	end

	funcs.JumpToCursor = function(self)
		self:Refresh()
	end

	funcs.UpdateCursor = function(self,input)
		local linesFrame = self.GuiElems.LinesFrame
		local cursor = self.GuiElems.Cursor			
		local hSize = math.max(0,linesFrame.AbsoluteSize.X)
		local vSize = math.max(0,linesFrame.AbsoluteSize.Y)
		local maxLines = math.ceil(vSize / self.FontSize)
		local maxCols = math.ceil(hSize / math.ceil(self.FontSize/2))
		local viewX,viewY = self.ViewX,self.ViewY
		local totalLinesStr = tostring(#self.Lines)
		local fontWidth = math.ceil(self.FontSize / 2)
		local linesOffset = #totalLinesStr*fontWidth + 4*fontWidth

		if input then
			local LinesFrame = self.GuiElems.LinesFrame
			local frameX,frameY = LinesFrame.AbsolutePosition.X,LinesFrame.AbsolutePosition.Y
			local mouseX,mouseY = input.Position.X,input.Position.Y
			local fontSizeX,fontSizeY = math.ceil(self.FontSize/2),self.FontSize

			self.CursorX = self.ViewX + math.round((mouseX - frameX) / fontSizeX)
			self.CursorY = self.ViewY + math.floor((mouseY - frameY) / fontSizeY)
		end

		local cursorX,cursorY = self.CursorX,self.CursorY

		local line = self.Lines[cursorY+1] or ""
		if cursorX > #line then cursorX = #line
		elseif cursorX < 0 then cursorX = 0 end

		if cursorY >= #self.Lines then
			cursorY = math.max(0,#self.Lines-1)
		elseif cursorY < 0 then
			cursorY = 0
		end

		cursorX = cursorX + self:TabAdjust(cursorX,cursorY)

		-- Update modified
		self.CursorX = cursorX
		self.CursorY = cursorY

		local cursorVisible = (cursorX >= viewX) and (cursorY >= viewY) and (cursorX <= viewX + maxCols) and (cursorY <= viewY + maxLines)
		if cursorVisible then
			local offX = (cursorX - viewX)
			local offY = (cursorY - viewY)
			cursor.Position = UDim2.new(0,linesOffset + offX*math.ceil(self.FontSize/2) - 1,0,offY*self.FontSize)
			cursor.Size = UDim2.new(0,1,0,self.FontSize+2)
			cursor.Visible = true
			self:CursorAnim(true)
		else
			cursor.Visible = false
		end
	end

	funcs.MapNewLines = function(self)
		local newLines = {}
		local count = 1
		local text = self.Text
		local find = string.find
		local init = 1

		local pos = find(text,"\n",init,true)
		while pos do
			newLines[count] = pos
			count = count + 1
			init = pos + 1
			pos = find(text,"\n",init,true)
		end

		self.NewLines = newLines
	end

	funcs.PreHighlight = function(self)
		local text = self.Text:gsub("\\\\","  ")
		local textLen = #text
		local found = {}
		local foundMap = {}
		local extras = {}
		local find = string.find
		local sub = string.sub
		self.ColoredLines = {}

		local function findAll(str,pattern,typ,raw)
			local count = #found+1
			local init = 1
			local x,y,extra = find(str,pattern,init,raw)
			while x do
				found[count] = x
				foundMap[x] = typ
				if extra then
					extras[x] = extra
				end

				count = count+1
				init = y+1
				x,y,extra = find(str,pattern,init,raw)
			end
		end

		findAll(text,'"',1,true)
		findAll(text,"'",2,true)
		findAll(text,"%[(=*)%[",3)
		findAll(text,"--",4,true)
		table.sort(found)

		local newLines = self.NewLines
		local curLine = 0
		local lineEnd = 0
		local lastEnding = 0
		local foundHighlights = {}

		for i = 1,#found do
			local pos = found[i]
			if pos <= lastEnding then continue end

			local ending = pos
			local typ = foundMap[pos]
			if typ == 1 then
				ending = find(text,'"',pos+1,true)
				while ending and sub(text,ending-1,ending-1) == "\\" do
					ending = find(text,'"',ending+1,true)
				end
				if not ending then ending = textLen end
			elseif typ == 2 then
				ending = find(text,"'",pos+1,true)
				while ending and sub(text,ending-1,ending-1) == "\\" do
					ending = find(text,"'",ending+1,true)
				end
				if not ending then ending = textLen end
			elseif typ == 3 then
				_,ending = find(text,"]"..extras[pos].."]",pos+1,true)
				if not ending then ending = textLen end
			elseif typ == 4 then
				local ahead = foundMap[pos+2]

				if ahead == 3 then
					_,ending = find(text,"]"..extras[pos+2].."]",pos+1,true)
					if not ending then ending = textLen end
				else
					ending = find(text,"\n",pos+1,true) or textLen
				end
			end

			while pos > lineEnd do
				curLine = curLine + 1
				--lineTableCount = 1
				lineEnd = newLines[curLine] or textLen+1
			end
			while true do
				local lineTable = foundHighlights[curLine]
				if not lineTable then 
					lineTable = {} 
					foundHighlights[curLine] = lineTable 
				end
				lineTable[pos] = {typ,ending}
				--lineTableCount = lineTableCount + 1

				if ending > lineEnd then
					curLine = curLine + 1
					lineEnd = newLines[curLine] or textLen+1
				else
					break
				end
			end

			lastEnding = ending
			--if i < 200 then print(curLine) end
		end
		self.PreHighlights = foundHighlights
		--print(tick()-start)
		--print(#found,curLine)
	end

	funcs.HighlightLine = function(self,line)
		local cached = self.ColoredLines[line]
		if cached then return cached end

		local sub = string.sub
		local find = string.find
		local match = string.match
		local highlights = {}
		local preHighlights = self.PreHighlights[line] or {}
		local lineText = self.Lines[line] or ""
		local lastEnding = 0
		local currentType = 0
		local lastWord = nil
		local wordBeginsDotted = false
		local funcStatus = 0
		local lineStart = self.NewLines[line-1] or 0

		local preHighlightMap = {}
		for pos,data in next,preHighlights do
			local relativePos = pos-lineStart
			if relativePos < 1 then
				currentType = data[1]
				lastEnding = data[2] - lineStart
				--warn(pos,data[2])
			else
				preHighlightMap[relativePos] = {data[1],data[2]-lineStart}
			end
		end

		for col = 1,#lineText do
			if col <= lastEnding then 
				highlights[col] = currentType 
				continue 
			end

			local pre = preHighlightMap[col]
			if pre then
				currentType = pre[1]
				lastEnding = pre[2]
				highlights[col] = currentType
				wordBeginsDotted = false
				lastWord = nil
				funcStatus = 0
			else
				local char = sub(lineText,col,col)
				if find(char,"[%a_]") then
					local word = match(lineText,"[%a%d_]+",col)
					local wordType = (keywords[word] and 7) or (builtIns[word] and 8)

					lastEnding = col+#word-1

					if wordType ~= 7 then
						if wordBeginsDotted then
							local prevBuiltIn = lastWord and builtIns[lastWord]
							wordType = (prevBuiltIn and type(prevBuiltIn) == "table" and prevBuiltIn[word] and 8) or 10
						end

						if wordType ~= 8 then
							local x,_,br = find(lineText,"^%s*([%({\"'])",lastEnding+1)
							if x then
								wordType = (funcStatus > 0 and br == "(" and 16) or 9
								funcStatus = 0
							end
						end
					else
						wordType = specialKeywordsTypes[word] or wordType
						funcStatus = (word == "function" and 1 or 0)
					end

					lastWord = word
					wordBeginsDotted = false
					if funcStatus > 0 then funcStatus = 1 end

					if wordType then
						currentType = wordType
						highlights[col] = currentType
					else
						currentType = nil
					end
				elseif find(char,"%p") then
					local isDot = (char == ".")
					local isNum = isDot and find(sub(lineText,col+1,col+1),"%d")
					highlights[col] = (isNum and 6 or 5)

					if not isNum then
						local dotStr = isDot and match(lineText,"%.%.?%.?",col)
						if dotStr and #dotStr > 1 then
							currentType = 5
							lastEnding = col+#dotStr-1
							wordBeginsDotted = false
							lastWord = nil
							funcStatus = 0
						else
							if isDot then
								if wordBeginsDotted then
									lastWord = nil
								else
									wordBeginsDotted = true
								end
							else
								wordBeginsDotted = false
								lastWord = nil
							end

							funcStatus = ((isDot or char == ":") and funcStatus == 1 and 2) or 0
						end
					end
				elseif find(char,"%d") then
					local _,endPos = find(lineText,"%x+",col)
					local endPart = sub(lineText,endPos,endPos+1)
					if (endPart == "e+" or endPart == "e-") and find(sub(lineText,endPos+2,endPos+2),"%d") then
						endPos = endPos + 1
					end
					currentType = 6
					lastEnding = endPos
					highlights[col] = 6
					wordBeginsDotted = false
					lastWord = nil
					funcStatus = 0
				else
					highlights[col] = currentType
					local _,endPos = find(lineText,"%s+",col)
					if endPos then
						lastEnding = endPos
					end
				end
			end
		end

		self.ColoredLines[line] = highlights
		return highlights
	end

	funcs.Refresh = function(self)
		local linesFrame = self.Frame.Lines
		local hSize = math.max(0,linesFrame.AbsoluteSize.X)
		local vSize = math.max(0,linesFrame.AbsoluteSize.Y)
		local maxLines = math.ceil(vSize / self.FontSize)
		local maxCols = math.ceil(hSize / math.ceil(self.FontSize/2))
		local gsub = string.gsub
		local sub = string.sub

		local viewX,viewY = self.ViewX,self.ViewY

		local lineNumberStr = ""

		for row = 1,maxLines do
			local lineFrame = self.LineFrames[row]
			if not lineFrame then
				lineFrame = NewInstance("Frame")
				lineFrame.Name = "Line"
				lineFrame.Position = UDim2.new(0,0,0,(row-1)*self.FontSize)
				lineFrame.Size = UDim2.new(1,0,0,self.FontSize)
				lineFrame.BorderSizePixel = 0
				lineFrame.BackgroundTransparency = 1

				local selectionHighlight = NewInstance("Frame")
				selectionHighlight.Name = "SelectionHighlight"
				selectionHighlight.BorderSizePixel = 0
				selectionHighlight.BackgroundColor3 = Settings.Theme.Syntax.SelectionBack
				selectionHighlight.Parent = lineFrame
				selectionHighlight.BackgroundTransparency = 0.7

				local label = NewInstance("TextLabel")
				label.Name = "Label"
				label.BackgroundTransparency = 1
				label.FontFace = self.FontFace
				label.TextSize = self.FontSize
				label.Size = UDim2.new(1,0,0,self.FontSize)
				label.RichText = true
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextColor3 = self.Colors.Text
				label.ZIndex = 2
				label.Parent = lineFrame

				lineFrame.Parent = linesFrame
				self.LineFrames[row] = lineFrame
			end

			local relaY = viewY + row
			local lineText = self.Lines[relaY] or ""
			local resText = ""
			local highlights = self:HighlightLine(relaY)
			local colStart = viewX + 1

			local richTemplates = self.RichTemplates
			local textTemplate = richTemplates.Text
			local selectionTemplate = richTemplates.Selection
			local curType = highlights[colStart]
			local curTemplate = richTemplates[typeMap[curType]] or textTemplate

			-- Selection Highlight
			local selectionRange = self.SelectionRange
			local selPos1 = selectionRange[1]
			local selPos2 = selectionRange[2]
			local _,selRelaY = viewX,relaY-1

			if selRelaY >= selPos1[2] and selRelaY <= selPos2[2] then
				local fontSizeX = math.ceil(self.FontSize/2)
				local posX = (selRelaY == selPos1[2] and selPos1[1] or 0) - viewX
				local sizeX = (selRelaY == selPos2[2] and selPos2[1]-posX-viewX or maxCols+viewX)

				lineFrame.SelectionHighlight.Position = UDim2.new(0,posX*fontSizeX,0,0)
				lineFrame.SelectionHighlight.Size = UDim2.new(0,sizeX*fontSizeX,1,0)
				lineFrame.SelectionHighlight.Visible = true
			else
				lineFrame.SelectionHighlight.Visible = false
			end

			for col = 2,maxCols do
				local relaX = viewX + col
				local posType = highlights[relaX]

				if posType ~= curType then
					local template = (false and selectionTemplate) or richTemplates[typeMap[posType]] or textTemplate

					if template ~= curTemplate then
						local nextText = gsub(sub(lineText,colStart,relaX-1),"['\"<>&]", richReplace)
						resText = resText .. (curTemplate ~= textTemplate and (curTemplate .. nextText .. "</font>") or nextText)
						colStart = relaX
						curTemplate = template
					end
					curType = posType
				end
			end

			local lastText = gsub(sub(lineText,colStart,viewX+maxCols),"['\"<>&]", richReplace)
			--warn("SUB",colStart,viewX+maxCols-1)
			if #lastText > 0 then
				resText = resText .. (curTemplate ~= textTemplate and (curTemplate .. lastText .. "</font>") or lastText)
			end

			if self.Lines[relaY] then
				lineNumberStr = lineNumberStr .. (relaY-1 == self.CursorY and ('<b>'..relaY.."</b>\n") or relaY .. "\n")
			end

			lineFrame.Label.Text = resText
		end

		for i = maxLines+1,#self.LineFrames do
			self.LineFrames[i]:Destroy()
			self.LineFrames[i] = nil
		end

		self.Frame.LineNumbers.Text = lineNumberStr
		self:UpdateCursor()

		--print("REFRESH TIME",tick()-start)
	end

	funcs.UpdateView = function(self)
		local totalLinesStr = tostring(#self.Lines)
		local fontWidth = math.ceil(self.FontSize / 2)
		local linesOffset = #totalLinesStr*fontWidth + 4*fontWidth

		local linesFrame = self.Frame.Lines
		local hSize = linesFrame.AbsoluteSize.X
		local vSize = linesFrame.AbsoluteSize.Y
		local maxLines = math.ceil(vSize / self.FontSize)
		local totalWidth = self.MaxTextCols*fontWidth
		local scrollV = self.ScrollV
		local scrollH = self.ScrollH

		scrollV.VisibleSpace = maxLines
		scrollV.TotalSpace = #self.Lines + 1
		scrollH.VisibleSpace = math.ceil(hSize/fontWidth)
		scrollH.TotalSpace = self.MaxTextCols + 1

		scrollV.Gui.Visible = #self.Lines + 1 > maxLines
		scrollH.Gui.Visible = totalWidth > hSize

		local oldOffsets = self.FrameOffsets
		self.FrameOffsets = Vector2.new(scrollV.Gui.Visible and -10 or 0, scrollH.Gui.Visible and -10 or 0)
		if oldOffsets ~= self.FrameOffsets then
			self:UpdateView()
		else
			scrollV:ScrollTo(self.ViewY,true)
			scrollH:ScrollTo(self.ViewX,true)

			if scrollV.Gui.Visible and scrollH.Gui.Visible then
				scrollV.Gui.Size = UDim2.new(0,10,1,-10)
				scrollH.Gui.Size = UDim2.new(1,-10,0,10)
				self.GuiElems.ScrollCorner.Visible = true
			else
				scrollV.Gui.Size = UDim2.new(0,10,1,0)
				scrollH.Gui.Size = UDim2.new(1,0,0,10)
				self.GuiElems.ScrollCorner.Visible = false
			end

			self.ViewY = scrollV.Index
			self.ViewX = scrollH.Index
			self.Frame.Lines.Position = UDim2.new(0,linesOffset,0,0)
			self.Frame.Lines.Size = UDim2.new(1,-linesOffset+oldOffsets.X,1,oldOffsets.Y)
			self.Frame.LineNumbers.Position = UDim2.new(0,fontWidth,0,0)
			self.Frame.LineNumbers.Size = UDim2.new(0,#totalLinesStr*fontWidth,1,oldOffsets.Y)
			self.Frame.LineNumbers.TextSize = self.FontSize
		end
	end

	funcs.ProcessTextChange = function(self)
		local maxCols = 0
		local lines = self.Lines

		for i = 1,#lines do
			local lineLen = #lines[i]
			if lineLen > maxCols then
				maxCols = lineLen
			end
		end

		self.MaxTextCols = maxCols
		self:UpdateView()	
		self.Text = table.concat(self.Lines,"\n")
		self:MapNewLines()
		self:PreHighlight()
		self:Refresh()
		--self.TextChanged:Fire()
	end

	funcs.ConvertText = function(self,text,toEditor)
		if toEditor then
			local new = text:gsub("\t", "    ")
			return new:gsub("\t",(" %s%s "):format(tabSub,tabSub))
		else
			return text:gsub((" %s%s "):format(tabSub,tabSub),"\t")
		end
	end

	funcs.GetText = function(self) -- TODO: better (use new tab format)
		local source = table.concat(self.Lines,"\n")
		return self:ConvertText(source,false) -- Tab Convert
	end

	funcs.SetText = function(self,txt)
		txt = self:ConvertText(txt,true) -- Tab Convert
		local lines = self.Lines
		table.clear(lines)
		local count = 1

		for line in txt:gmatch("([^\n\r]*)[\n\r]?") do
			lines[count] = line
			count = count + 1
		end

		self:ProcessTextChange()
	end

	funcs.ClearText = function(self)
		local txt = self:ConvertText('',true)
		local lines = self.Lines
		table.clear(lines)
		local count = 1

		for line in txt:gmatch("([^\n\r]*)[\n\r]?") do
			lines[count] = line
			count = count + 1
		end

		self:ProcessTextChange()
	end

	funcs.CompileText = function(self)
		local loaded = pcall(function()
			local source = table.concat(self.Lines, "\n")
			local convertedSource = self:ConvertText(source, false)
			loadstring(convertedSource)()
		end)

		return loaded
	end

	funcs.ReturnErrors = function(self)
		local loaded, err = pcall(function()
			local source = table.concat(self.Lines, "\n")
			local convertedSource = self:ConvertText(source, false)
			loadstring(convertedSource)()
		end)

		return not loaded and err or nil
	end

	funcs.GetVersion = function(self)
		return IDEVersion
	end

	funcs.MakeRichTemplates = function(self)
		local floor = math.floor
		local templates = {}

		for name,color in pairs(self.Colors) do
			templates[name] = ('<font color="rgb(%s,%s,%s)">'):format(floor(color.r*255),floor(color.g*255),floor(color.b*255))
		end

		self.RichTemplates = templates
	end

	funcs.ApplyTheme = function(self)
		local colors = Settings.Theme.Syntax
		self.Colors = colors
		self.Frame.LineNumbers.TextColor3 = colors.Text
		self.Frame.BackgroundColor3 = colors.Background
	end

	local mt = {__index = funcs}

	local function new(Overwrites)
		Overwrites = Overwrites or {}
		if not builtInInited then initBuiltIn() end

		local scrollV = Lib.ScrollBar.new()
		local scrollH = Lib.ScrollBar.new(true)
		scrollH.Gui.Position = UDim2.new(0,0,1,-10)
		
		local Base = {
			FontFace = Font.fromEnum(Enum.Font.Code),
			FontSize = 14,
			ViewX = 0,
			ViewY = 0,
			Colors = Settings.Theme.Syntax,
			ColoredLines = {},
			Lines = {""},
			LineFrames = {},
			Editable = true,
			Editing = false,
			CursorX = 0,
			CursorY = 0,
			FloatCursorX = 0,
			Text = "",
			PreHighlights = {},
			SelectionRange = {{-1,-1},{-1,-1}},
			NewLines = {},
			FrameOffsets = Vector2.new(0,0),
			MaxTextCols = 0,
			ScrollV = scrollV,
			ScrollH = scrollH
		}
		
		local Properties = Merge(Base, Overwrites)
		local obj = setmetatable(Properties, mt)

		funcs.SetTextMultiplier = (function(arg)
			obj.FontSize = arg
		end)
		funcs.GetTextMultiplier = (function()
			return obj.FontSize
		end)

		scrollV.WheelIncrement = 3
		scrollH.Increment = 2
		scrollH.WheelIncrement = 7

		scrollV.Scrolled:Connect(function()
			obj.ViewY = scrollV.Index
			obj:Refresh()
		end)

		scrollH.Scrolled:Connect(function()
			obj.ViewX = scrollH.Index
			obj:Refresh()
		end)

		obj:MakeEditorFrame(obj)
		obj:MakeRichTemplates()
		obj:ApplyTheme()
		scrollV:SetScrollFrame(obj.Frame.Lines)
		scrollV.Gui.Parent = obj.Frame
		scrollH.Gui.Parent = obj.Frame

		obj:UpdateView()
		obj:SetText(Properties.Text)

		obj.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			obj:UpdateView()
			obj:Refresh()
		end)

		return obj
	end

	return {new = new}
end)()

return Lib

end

Modules['classes.Wrappers'] = function()
local Wrappers = {
    Services = {},
    OnInitConnections = {}
}

export type table = {
    [any]: any
}

--// Compatibility 
local GetHiddenUI = get_hidden_gui or gethui
local NewReference = cloneref or function(...): Instance 
	return ... 
end

--// Service handlers
local Services = Wrappers.Services
setmetatable(Services, {
	__index = function(self, Name: string)
		local Service = game:GetService(Name)
		return NewReference(Service)
	end,
})

--// Services
local CoreGui = Services.CoreGui

--// Modules
local ReGui

function Wrappers:AddOnInit(Func: (table)->nil)
    local Connections = self.OnInitConnections
    table.insert(Connections, Func)
end

function Wrappers:NewReference(Object: Instance): Instance
	return NewReference(Object)
end

function Wrappers:CallOnInitConnections(ReGuiModule, ...)
    local Connections = self.OnInitConnections
    ReGui = ReGuiModule

    for _, Func in next, Connections do
        Func(ReGui, ...)
    end
end

function Wrappers:SetProperties(Object: Instance, Properties: table)
	for Key: string, Value in next, Properties do
		pcall(function()
			Object[Key] = Value
		end)
	end
end

function Wrappers:NewClass(Class: table, Merge: table?)
	Merge = Merge or {}
	Class.__index = Class
	return setmetatable(Merge, Class)
end

function Wrappers:CheckConfig(Source: table, Base: table, Call: boolean?, IgnoreKeys: table?)
	if not Source then return end 

	for Key: string?, Value in next, Base do
		if Source[Key] ~= nil then continue end

		--// Check the key should be ignored
		if IgnoreKeys then
			if table.find(IgnoreKeys, Key) then continue end
		end

		--// Call value function
		if Call then
			Value = Value()
		end

		--// Set value
		Source[Key] = Value
	end

	return Source
end

function Wrappers:ResolveUIParent(): GuiObject?
	local PlayerGui = ReGui.PlayerGui
	local Debug = ReGui.Debug

	local Steps = {
		[1] = function()
			local Parent = GetHiddenUI()
			if Parent.Parent == CoreGui then return end

			return Parent
		end,
		[2] = function()
			return CoreGui
		end,
		[3] = function()
			return PlayerGui
		end
	}

	local Test = ReGui:CreateInstance("ScreenGui")

	--// Test each step for a successful parent
	for Step, Func in next, Steps do
		--// Test fetching the parent
		local Success, Parent = pcall(Func)
		if not Success or not Parent then continue end

		--// Test parenting
		local CanParent = pcall(function()
			Test.Parent = Parent
		end)
		if not CanParent then continue end

		if Debug then
			ReGui:Warn(`Step: {Step} was chosen as the parent!: {Parent}`)
		end

		return Parent
	end

	--// Error message
	ReGui:Warn("The ReGui container does not have a parent defined")

	return nil
end

function Wrappers:GetChildOfClass(Object: GuiObject, ClassName: string): GuiObject
	local Child = Object:FindFirstChildOfClass(ClassName)

	--// Create missing child
	if not Child then
		Child = ReGui:CreateInstance(ClassName, Object)
	end

	return Child
end

function Wrappers:CheckAssetUrl(Url: (string|number)): string
	--// Convert Id number to asset URL
	if tonumber(Url) then
		return `rbxassetid://{Url}`
	end
	return Url
end

function Wrappers:SetPadding(UiPadding: UIPadding, Padding: UDim)
	if not UiPadding then return end

	self:SetProperties(UiPadding, {
		PaddingBottom = Padding,
		PaddingLeft = Padding,
		PaddingRight = Padding,
		PaddingTop = Padding
	})
end

return Wrappers
end

Modules['classes.Animations'] = function()
--// Animation class

type table = {
    [any]: any
}

export type ObjectTable = { 
	[GuiObject]: any 
}

local Wrappers = Modules.load("classes.Wrappers")
local Animation = {
    DefaultTweenInfo = TweenInfo.new(0.08),
}

local Services = Wrappers.Services
local TweenService = Services.TweenService

type AnimationTween = {
	Object: Instance,
	NoAnimation: boolean?,
	Tweeninfo: TweenInfo?,
    StartProperties: table?,
	EndProperties: table,
	Completed: (() -> any?)?
}
function Animation:Tween(Data: AnimationTween): Tween?
	local DefaultTweenInfo = self.DefaultTweenInfo

	--// Unpack animation data for the Tween
	local Object = Data.Object
	local NoAnimation = Data.NoAnimation
	local Tweeninfo = Data.Tweeninfo or DefaultTweenInfo
	local EndProperties = Data.EndProperties
	local StartProperties = Data.StartProperties
	local Completed = Data.Completed

	--// Apply Start Properties to the object
	if StartProperties then
		Wrappers:SetProperties(Object, StartProperties)
	end

	--// Set properties without a tween for NoAnimation flag
	if NoAnimation then
		Wrappers:SetProperties(Object, EndProperties)

		--// Invoke Completed event
		if Completed then
			Completed()
		end
		return
	end

	--// Create the tween animation
	local MasterTween = nil
	for Key, Value in next, EndProperties do
		local Properties = {
			[Key] = Value
		}

		--// Create the tween for the property
		local Success, Tween = pcall(function()
			return TweenService:Create(Object, Tweeninfo, Properties)
		end)

		--// Set Properties instead of tweening
		if not Success then
			Wrappers:SetProperties(Object, Properties)
			continue
		end

		--// Set the MasterTween if it does not exist
		if not MasterTween then
			MasterTween = Tween
		end

		Tween:Play()
	end

	--// Connect the TweenCompleted event
	if Completed then
		if MasterTween then
			MasterTween.Completed:Connect(Completed)
		else
			Completed()
		end
	end

	return MasterTween
end

type Animate = {
	NoAnimation: boolean?,
	Objects: ObjectTable,
	Tweeninfo: TweenInfo?,
	Completed: () -> any,
}
function Animation:Animate(Data: Animate): Tween
	local NoAnimation = Data.NoAnimation
	local Objects = Data.Objects
	local Tweeninfo = Data.Tweeninfo
	local Completed = Data.Completed

	local BaseTween = nil

	--// Create tweens
	for Object, EndProperties in next, Objects do
		local Tween = self:Tween({
			NoAnimation = NoAnimation,
			Object = Object,
			Tweeninfo = Tweeninfo, 
			EndProperties = EndProperties
		})

		if not BaseTween then
			BaseTween = Tween
		end
	end

	--// Connect completed event call
	if Completed then
		BaseTween.Completed:Connect(Completed)
	end

	return BaseTween
end

type HeaderCollapseToggle = {
	Rotations: {
		Open: number?,
		Closed: number?
	}?,
	Toggle: GuiObject,
	NoAnimation: boolean?,
	Collapsed: boolean,
	Tweeninfo: TweenInfo?,
}
function Animation:HeaderCollapseToggle(Data: HeaderCollapseToggle)
	--// Check configuration
	Wrappers:CheckConfig(Data, {
		Rotations = {
			Open = 90,
			Closed = 0
		}
	})

	--// Unpack configuration
	local Toggle = Data.Toggle
	local NoAnimation = Data.NoAnimation
	local Rotations = Data.Rotations
	local Collapsed = Data.Collapsed
	local Tweeninfo = Data.Tweeninfo

	local Rotation = Collapsed and Rotations.Closed or Rotations.Open

	--// Animate toggle
	self:Tween({
		Tweeninfo = Tweeninfo,
		NoAnimation = NoAnimation,
		Object = Toggle,
		EndProperties = {
			Rotation = Rotation,
		}
	})
end

type HeaderCollapse = {
	Collapsed: boolean,
	ClosedSize: UDim2,
	OpenSize: UDim2,
	Toggle: Instance,
	Resize: Instance?,
	Hide: Instance?,
	NoAnimation: boolean?,
	NoAutomaticSize: boolean?,
	Tweeninfo: TweenInfo?,
	IconOnly: boolean?,
	Completed: (() -> any)?,
	IconRotations: {
		Open: number?,
		Closed: number?
	}?
}
function Animation:HeaderCollapse(Data: HeaderCollapse): Tween
	--// Unpack config
	local Tweeninfo = Data.Tweeninfo
	local Collapsed = Data.Collapsed
	local ClosedSize = Data.ClosedSize
	local OpenSize: UDim2 = Data.OpenSize
	local Toggle = Data.Toggle
	local Resize = Data.Resize
	local Hide = Data.Hide
	local NoAnimation = Data.NoAnimation
	local NoAutomaticSize = Data.NoAutomaticSize
	local Rotations = Data.IconRotations
	local Completed = Data.Completed

	--// Apply base properties
	if not NoAutomaticSize then
		Resize.AutomaticSize = Enum.AutomaticSize.None
	end
	if not Collapsed then
		Hide.Visible = true
	end

	--// Build and play animation keyframes
	self:HeaderCollapseToggle({
		Tweeninfo = Tweeninfo,
		Collapsed = Collapsed,
		NoAnimation = NoAnimation,
		Toggle = Toggle,
		Rotations = Rotations
	})

	local Tween = self:Tween({
		Tweeninfo = Tweeninfo,
		NoAnimation = NoAnimation,
		Object = Resize,
		StartProperties = {
			Size = Collapsed and OpenSize or ClosedSize
		},
		EndProperties = {
			Size = Collapsed and ClosedSize or OpenSize
		},
		Completed = function()
			Hide.Visible = not Collapsed

			--// Invoke completed callback function
			if Completed then 
				Completed() 
			end

			--// Reset AutomaticSize after animation
			if Collapsed then return end
			if NoAutomaticSize then return end

			--// Reset sizes of the object
			Resize.Size = UDim2.fromScale(1, 0)
			Resize.AutomaticSize = Enum.AutomaticSize.Y
		end,
	})

	return Tween
end

return Animation
end

Modules['classes.Signaling'] = function()
--// Signal service
type SignalClass = {
	Connections: {
		[number]: (...any) -> nil	
	},
	Fire: (SignalClass, ...any) -> nil,
	GetConnections: (SignalClass) -> table,
	Connect: (SignalClass, (...any) -> nil) -> table,
	DisconnectConnections: (SignalClass) -> nil,
}

type table = {
    [any]: any
}

local Signal = {} :: SignalClass
Signal.__index = Signal

local Wrappers = Modules.load("classes.Wrappers")

function Signal:Fire(...)
	local Connections = self:GetConnections()
	if #Connections <= 0 then return end

	for _, Connection in next, Connections do
		Connection(...)
	end
end
function Signal:GetConnections(): table
	local Connections = self.Connections
	return Connections
end
function Signal:Connect(Func: (...any) -> nil)
	local Connections = self:GetConnections()
	table.insert(Connections, Func)
end
function Signal:DisconnectConnections()
	local Connections = self:GetConnections()
	table.clear(Connections)
end

function Signal:NewSignal(): SignalClass
	return Wrappers:NewClass(Signal, {
		Connections = {}
	})
end

return Signal
end

Modules['src.Demo Window'] = function()
return function(ReGui)
    --// Configuration saving demo
    local ConfigSavingWindow = ReGui:Window({
        Title = "Configuration saving",
        Size = UDim2.fromOffset(300, 200)
    })

    local Row = ConfigSavingWindow:Row()
    local MySaveString = nil

    Row:Button({
        Text = "Dump Ini",
        Callback = function()
            print(ReGui:DumpIni(true))
        end,
    })
    Row:Button({
        Text = "Save Ini",
        Callback = function()
            MySaveString = ReGui:DumpIni(true)
        end,
    })
    Row:Button({
        Text = "Load Ini",
        Callback = function()
            if not MySaveString then
                warn("No save data!")
                return
            end
            
            ReGui:LoadIni(MySaveString, true)
        end,
    })

    ConfigSavingWindow:Separator()
    ConfigSavingWindow:SliderInt({
        IniFlag = "MySlider",
        Value = 5,
        Minimum = 1,
        Maximum = 32,
    })
    ConfigSavingWindow:Checkbox({
        IniFlag = "MyCheckbox",
        Value = true,
    })
    ConfigSavingWindow:InputText({
        IniFlag = "MyInput",
        Value = "Hello world!"
    })
    ConfigSavingWindow:Keybind({
        IniFlag = "MyKeybind",
        Label = "Keybind (w/ Q & Left-Click blacklist)",
        KeyBlacklist = {
            Enum.UserInputType.MouseButton1,
            Enum.KeyCode.Q
        }
    })

    --// Tabs window demo
    local TabsWindow = ReGui:TabsWindow({
        Title = "Tabs window!",
        Visible = false,
        Size = UDim2.fromOffset(300, 200)
    })

    for _, Name in {"Avocado", "Broccoli", "Cucumber"} do
        local Tab = TabsWindow:CreateTab({Name=Name})
        Tab:Label({
            Text = `This is the {Name} tab!`
        })
    end

    --// Watermark demo
    local Watermark = ReGui.Elements:Label({ --> TextLabel
        Parent = ReGui.Container.Windows,
        Visible = false,
        UiPadding = UDim.new(0, 8),
        CornerRadius = UDim.new(0, 2),
        Position = UDim2.fromOffset(10,10),
        Size = UDim2.fromOffset(250, 50),
        Border = true,
        BorderThickness = 1,
        BorderColor = ReGui.Accent.Gray,
        BackgroundTransparency = 0.4,
        BackgroundColor3 = ReGui.Accent.Black,
    })

    game:GetService("RunService").RenderStepped:Connect(function(Delta)
        local FPS = math.round(1/Delta)
        local TimeString = DateTime.now():FormatLocalTime("dddd h:mm:ss A", "en-us")
        
        local String = `ReGui {ReGui:GetVersion()}\n`
        String ..= `FPS: {FPS}\n`
        String ..= `The time is {TimeString}`
        
        Watermark.Text = String
    end)

    --// Demo Window
    local Window = ReGui:Window({
        Title = "Dear ReGui Demo",
        Size = UDim2.new(0, 400, 0, 300),
        -- If you have a window with a single element with Fill enabled, you should disable Scroll on the window 
        -- Otherwise it will not fit correctly as automatic canvas size is enabled for the scrolling functionality
        NoScroll = true
    }):Center()

    --// MenuBar
    local MenuBar = Window:MenuBar()

    --// Menu
    local MenuItem = MenuBar:MenuItem({
        Text = "Menu"
    })
    MenuItem:Selectable({
        Text = "New"
    })
    MenuItem:Selectable({
        Text = "Open"
    })
    MenuItem:Selectable({
        Text = "Save"
    })
    MenuItem:Selectable({
        Text = "Save as"
    })
    MenuItem:Selectable({
        Text = "Exit",
        Callback = function()
            Window:Close()
        end,
    })

    --// Examples
    local MenuItem = MenuBar:MenuItem({
        Text = "Examples"
    })
    MenuItem:Selectable({
        Text = "Print hello world",
        Callback = function()
            print("Hello world!")
        end,
    })
    MenuItem:Selectable({
        Text = "Tabs window",
        Callback = function()
            TabsWindow:ToggleVisibility()
        end,
    })
    MenuItem:Selectable({
        Text = "Configuration saving",
        Callback = function()
            ConfigSavingWindow:ToggleVisibility()
        end,
    })
    MenuItem:Selectable({
        Text = "Watermark",
        Callback = function()
            Watermark.Visible = not Watermark.Visible
        end,
    })

    Window:Label({
        Text = `Dear ReGui says hello! ({ReGui:GetVersion()})`
    })

    --// The window has automatic scroll enable by default, 
    -- this is here to seperate the scroll so the positions of elements are static at the top
    local Content = Window:ScrollingCanvas({
        Fill = true,
        UiPadding = UDim.new(0, 0)
    })

    --// Help
    local Help = Content:CollapsingHeader({
        Title = "Help"
    })
    Help:Separator({
        Text = "ABOUT THIS DEMO:"	
    })
    Help:BulletText({
        Rows = {
            "Sections below are demonstrating many aspects of the library.",
        }
    })
    Help:Separator({
        Text = "PROGRAMMER GUIDE:"	
    })
    Help:BulletText({
        Rows = {
            "See example FAQ, examples, and documentation at https://depso.gitbook.io/regui",
        }
    })
    Help:Indent():BulletText({
        Rows = {
            "See example applications in the /demo folder.",
        }
    })

    --// Configuration
    local ConfigurationHeader = Content:CollapsingHeader({
        Title = "Configuration"
    })

    local BackendFlags = ConfigurationHeader:TreeNode({
        Title = "Backend Flags"
    })
    BackendFlags:Checkbox({Label="ReGui:IsMobileDevice", Disabled=true, Value=ReGui:IsMobileDevice()})
    BackendFlags:Checkbox({Label="ReGui:IsConsoleDevice", Disabled=true, Value=ReGui:IsConsoleDevice()})

    local Style = ConfigurationHeader:TreeNode({
        Title = "Style"
    })
    Style:Combo({
        Selected = "DarkTheme",
        Label = "Colors",
        Items = ReGui.ThemeConfigs,
        Callback = function(self, Name)
            Window:SetTheme(Name)
        end,
    })

    local WindowOptions = Content:CollapsingHeader({
        Title = "Window options"
    }):Table({
        MaxColumns = 3 -- Per row
    }):NextRow()

    local Options = {
        NoResize = false,
        NoTitleBar = false,
        NoClose = false,
        NoCollapse = false,
        --NoTabsBar = false, --:TabsWindow only
        OpenOnDoubleClick = true,
        NoBringToFrontOnFocus = false,
        NoMove = false,
        NoSelect = false,
        NoScrollBar = false,
        NoBackground = false
    }

    for Key, Value in pairs(Options) do
        local Column = WindowOptions:NextColumn()

        Column:Checkbox({
            Value = Value,
            Label = Key,
            Callback = function(self, Value)
                Window:UpdateConfig({
                    [Key] = Value
                })
            end,
        })
    end

    local Widgets = Content:CollapsingHeader({
        Title = "Widgets"
    })

    local DemosOrder = {
        "Basic", 
        "Tooltips", 
        "Tree Nodes", 
        "Collapsing Headers",
        "Bullets",
        "Text",
        "Images",
        "Videos",
        "Combo", 
        "Tabs", 
        "Plot widgets", 
        "Multi-component Widgets",
        "Progress Bars",
        "Picker Widgets",
        "Code editor",
        "Console",
        "List layout",
        --"Selectable", 
        --"Group", 
        "Indent", 
        "Viewport", 
        "Keybinds", 
        "Input",
        "Text Input", 
    }

    local WidgetDemos = {
        ["Basic"] = function(Header)
            --// General
            Header:Separator({Text="General"})

            local Row = Header:Row()
            local Label = Row:Label({
                Text = "Thanks for clicking me!",
                Visible = false,
                LayoutOrder = 2
            })
            Row:Button({
                Callback = function()
                    Label.Visible = not Label.Visible
                end,
            })

            Header:Checkbox()

            local RadioRow = Header:Row()
            RadioRow:Radiobox({Label="radio a"})
            RadioRow:Radiobox({Label="radio b"})
            RadioRow:Radiobox({Label="radio c"})
            
            local ButtonsRow = Header:Row()
            for i = 1,7 do
                local Hue = i / 7.0
                ButtonsRow:Button({
                    Text = "Click",
                    BackgroundColor3 = Color3.fromHSV(Hue, 0.6, 0.6)
                })
            end

            local Tooltip = Header:Button({
                Text = "Tooltip"
            })

            ReGui:SetItemTooltip(Tooltip, function(Canvas)
                Canvas:Label({
                    Text = "I am a tooltip"
                })
            end)

            --// Inputs
            Header:Separator({Text="Inputs"})

            Header:InputText({
                Value = "Hello world!"
            })
            Header:InputText({
                Placeholder = "Enter text here",
                Label = "Input text (w/ hint)",
                Value = ""
            })
            Header:InputInt({
                Value = 50,
            })
            Header:InputInt({
                Label = "Input Int (w/ limit)",
                Value = 5,
                Maximum = 10,
                Minimum = 1
            })

            --// Drags
            Header:Separator({Text="Drags"})

            Header:DragInt()

            Header:DragInt({
                Maximum = 100,
                Minimum = 0,
                Label = "Drag Int 0..100",
                Format = "%d%%"
            })

            Header:DragFloat({
                Maximum = 1,
                Minimum = 0,
                Value = 0.5
            })

            --// Sliders
            Header:Separator({Text="Sliders"})

            Header:SliderInt({
                Format = "%.d/%s",
                Value = 5,
                Minimum = 1,
                Maximum = 32,
                ReadOnly = false,
            }):SetValue(8)

            Header:SliderInt({
                Label = "Slider Int (w/ snap)",
                Value = 1,
                Minimum = 1,
                Maximum = 8,
                Type = "Snap"
            })

            Header:SliderFloat({
                Label = "Slider Float", 
                Minimum = 0.0, 
                Maximum = 1.0, 
                Format = "Ratio = %.3f"
            })

            Header:SliderFloat({
                Label = "Slider Angle", 
                Minimum = -360, 
                Maximum = 360, 
                Format = "%.f deg"
            })

            Header:SliderEnum({
                Items = {"Fire", "Earth", "Air", "Water"},
                Value = 2,
            })

            Header:SliderEnum({
                Items = {"Fire", "Earth", "Air", "Water"},
                Value = 2,
                Disabled = true,
                Label = "Disabled Enum"
            })

            Header:SliderProgress({
                Label = "Progress Slider",
                Value = 8,
                Minimum = 1,
                Maximum = 32,
            })

            --// Selectors/Pickers
            Header:Separator({Text="Selectors/Pickers"})

            Header:InputColor3({
                Value = ReGui.Accent.Light,
                Label = "Color 1",
                --Callback = print
            })

            Header:SliderColor3({
                Value = ReGui.Accent.Light,
                Label = "Color 2"
            })

            Header:InputCFrame({
                Value = CFrame.new(1,1,1),
                Minimum = CFrame.new(0,0,0),
                Maximum = CFrame.new(200, 100, 50),
                Label = "CFrame 1",
                --Callback = print
            })

            Header:SliderCFrame({
                Value = CFrame.new(1,1,1),
                Minimum = CFrame.new(0,0,0),
                Maximum = CFrame.new(200, 100, 50),
                Label = "CFrame 2"
            })

            Header:Combo({
                Selected = 1,
                Items = {
                    "AAAA", 
                    "BBBB", 
                    "CCCC", 
                    "DDDD", 
                    "EEEE", 
                    "FFFF", 
                    "GGGG", 
                    "HHHH", 
                    "IIIIIII", 
                    "JJJJ", 
                    "KKKKKKK"
                }
            })
        end,
        ["Tooltips"] = function(Header)
            --// General
            Header:Separator({Text="General"})
            
            --// Basic
            local Basic = Header:Button({
                Text = "Basic",
                Size = UDim2.fromScale(1, 0)
            })
            ReGui:SetItemTooltip(Basic, function(Canvas)
                Canvas:Label({
                    Text = "I am a tooltip"
                })
            end)
            
            --// Fancy
            local Fancy = Header:Button({
                Text = "Fancy",
                Size = UDim2.fromScale(1, 0)
            })
            ReGui:SetItemTooltip(Fancy, function(Canvas)
                Canvas:Label({
                    Text = "I am a fancy tooltip"
                })
                Canvas:Image({
                    Image = 18395893036
                })

                local Time = Canvas:Label()
                while task.wait() do
                    Time.Text = `Sin(time) = {math.sin(tick())}`
                end
            end)
            
            --// Double
            local Fancy = Header:Button({
                Text = "Double tooltip",
                Size = UDim2.fromScale(1, 0)
            })
            for i = 1,3 do
                ReGui:SetItemTooltip(Fancy, function(Canvas)
                    Canvas:Label({
                        Text = `I am tooltip {i}`
                    })
                end)
            end
        end,
        ["Videos"] = function(Header)
            local Video = Header:VideoPlayer({
                Video = 5608327482,
                Looped = true,
                Ratio = 16 / 9,
                RatioAspectType = Enum.AspectType.FitWithinMaxSize,
                RatioAxis = Enum.DominantAxis.Width,
                Size = UDim2.fromScale(1, 1)
            })
            Video:Play()

            local Controls = Header:Row({
                Expanded = true
            })
            Controls:Button({
                Text = "Pause",
                Callback = function()
                    Video:Pause()
                end,
            })
            Controls:Button({
                Text = "Play",
                Callback = function()
                    Video:Play()
                end,
            })

            --// Wait for the video to load
            if not Video.IsLoaded then 
                Video.Loaded:Wait()
            end

            local TimeSlider = Controls:SliderInt({
                Format = "%.f",
                Value = 0,
                Minimum = 0,
                Maximum = Video.TimeLength,
                Callback = function(self, Value)
                    Video.TimePosition = Value
                end,
            })

            game:GetService("RunService").RenderStepped:Connect(function(Delta)
                TimeSlider:SetValue(Video.TimePosition)
            end)
        end,
        ["Tree Nodes"] = function(Header)
            for i = 1,5 do
                local Tree = Header:TreeNode({
                    Title = `Child {i}`,
                    Collapsed = i ~= 1
                })

                local Row = Tree:Row()
                Row:Label({Text="Blah blah"})
                Row:SmallButton({Text="Button"})
            end
            
            Header:TreeNode({
                Title = `With icon & NoArrow`,
                NoArrow = true,
                Icon = ReGui.Icons.Image,
            })
        end,
        ["Collapsing Headers"] = function(Header)
            local Second

            Header:Checkbox({
                Value = true,
                Label = "Show 2nd header",
                Callback = function(self, Value)
                    if Second then 
                        Second:SetVisible(Value)
                    end
                end,
            })
            Header:Checkbox({
                Value = true,
                Label = "2nd has arrow",
                Callback = function(self, Value)
                    if Second then 
                        Second:SetArrowVisible(Value)
                    end
                end,
            })

            local First = Header:CollapsingHeader({
                Title = "Header",
            })
            for i = 1, 5 do 
                First:Label({Text=`Some content {i}`})
            end

            Second = Header:CollapsingHeader({
                Title = "Second Header",
            })

            for i = 1, 5 do 
                Second:Label({Text=`More content {i}`})
            end
        end,
        ["Bullets"] = function(Header)
            Header:BulletText({
                Rows = {
                    "Bullet point 1",
                    "Bullet point 2\nOn multiple lines",
                }
            })

            Header:TreeNode():BulletText({
                Rows = {"Another bullet point"}
            })

            Header:Bullet():Label({
                Text = "Bullet point 3 (two calls)"
            })

            Header:Bullet():SmallButton()
        end,
        ["Text"] = function(Header)
            local Colorful = Header:TreeNode({Title="Colorful Text"})
            Colorful:Label({
                TextColor3 = Color3.fromRGB(255, 0, 255),
                Text = "Pink",
                NoTheme = true
            })
            Colorful:Label({
                TextColor3 = Color3.fromRGB(255, 255, 0),
                Text = "Yellow",
                NoTheme = true
            })
            Colorful:Label({
                TextColor3 = Color3.fromRGB(59, 59, 59),
                Text = "Disabled",
                NoTheme = true
            })

            local Wrapping = Header:TreeNode({Title="Word Wrapping"})
            Wrapping:Label({
                Text = [[This text should automatically wrap on the edge of the window. The current implementation for text wrapping follows simple rules suitable for English and possibly other languages.]],
                TextWrapped = true
            })

            local Paragraph

            Wrapping:SliderInt({
                Label = "Wrap width",
                Value = 400,
                Minimum = 20,
                Maximum = 600,
                Callback = function(self, Value)
                    if not Paragraph then return end
                    Paragraph.Size = UDim2.fromOffset(Value, 0)
                end,
            })

            Wrapping:Label({Text="Test paragraph:"})
            Paragraph = Wrapping:Label({
                Text = [[The lazy dog is a good dog. This paragraph should fit. Testing a 1 character word. The quick brown fox jumps over the lazy dog.]],
                TextWrapped = true,
                Border = true,
                BorderColor = Color3.fromRGB(255, 255, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.fromOffset(400, 0)
            })
        end,
        ["Images"] = function(Header)
            Header:Label({
                TextWrapped = true,
                Text="Below we are displaying the icons (which are the ones builtin to ReGui in this demo). Hover the texture for a zoomed view!"
            })
            Header:Label({
                TextWrapped = true,
                Text=`There is a total of {ReGui:GetDictSize(ReGui.Icons)} icons in this demo!`
            })

            local List = Header:List({
                Border = true
            })

            local TooltipLabel 
            local TooltipImage

            --// Asign Tooltip to image for displaying the Icon name
            ReGui:SetItemTooltip(List, function(Canvas)
                TooltipLabel = Canvas:Label()
                TooltipImage = Canvas:Image({
                    Size = UDim2.fromOffset(50,50)
                })
            end)

            for Name, ImageUrl in ReGui.Icons do
                --// Create the Image object
                local Image = List:Image({
                    Image = ImageUrl,
                    Size = UDim2.fromOffset(30, 30)
                })

                ReGui:DetectHover(Image, {
                    MouseEnter = true,
                    OnInput = function()
                        TooltipLabel.Text = Name
                        TooltipImage.Image = ImageUrl
                    end,
                })
            end
        end,
        ["Tabs"] = function(Header)
            --// Basic
            local Basic = Header:TreeNode({Title="Basic"})
            local TabSelector = Basic:TabSelector()

            local Names = {"Avocado", "Broccoli", "Cucumber"}
            for _, Name in next, Names do
                TabSelector:CreateTab({Name=Name}):Label({
                    Text = `This is the {Name} tab!\nblah blah blah blah blah`
                })
            end

            --// Advanced 
            local Advanced = Header:TreeNode({Title="Advanced & Close Button"})
            local TabSelector = Advanced:TabSelector()

            local Names = {"Artichoke", "Beetroot", "Celery", "Daikon"}

            for _, Name in next, Names do
                local Tab = TabSelector:CreateTab({
                    Name = Name,
                    Closeable = true
                })

                Tab:Label({
                    Text = `This is the {Name} tab!\nblah blah blah blah blah`
                })
            end

            Advanced:Button({
                Text="Add tab",
                Callback = function()
                    TabSelector:CreateTab({
                        Closeable = true
                    }):Label({
                        Text = "I am an odd tab."
                    })
                end,
            })
        end,
        ["Plot widgets"] = function(Header)
            local Graph = Header:PlotHistogram({
                Points = {0.6, 0.1, 1.0, 0.5, 0.92, 0.1, 0.2}
            })

            Header:Button({
                Text = "Generate new graph",
                Callback = function()
                    local Points = {}

                    for I = 1, math.random(5, 10) do
                        table.insert(Points, math.random(1, 10))
                    end

                    Graph:PlotGraph(Points)
                end,
            })
        end,
        ["Multi-component Widgets"] = function(Header)
            Header:Separator({Text="2-wide"})

            Header:InputInt2({
                Value = {10, 50},
                Minimum = {0,0},
                Maximum = {20,100},
                Callback = function(self, Values)
                    print("1:", Values[1], "2:", Values[2])
                end,
            })
            Header:SliderInt2()
            Header:SliderFloat2()
            Header:DragInt2()
            Header:DragFloat2()

            Header:Separator({Text="3-wide"})

            Header:InputInt3()
            Header:SliderInt3()
            Header:SliderFloat3()
            Header:DragInt3()
            Header:DragFloat3()

            Header:Separator({Text="4-wide"})

            Header:InputInt4()
            Header:SliderInt4()
            Header:SliderFloat4()
            Header:DragInt4()
            Header:DragFloat4()
        end,
        ["Progress Bars"] = function(Header)
            local ProgressBar = Header:ProgressBar({
                Label = "Loading...",
                Value = 80
            })

            spawn(function()
                local Percentage = 0
                while wait(0.02) do
                    Percentage += 1
                    ProgressBar:SetPercentage(Percentage % 100)
                end
            end)
        end,
        ["Picker Widgets"] = function(Header)
            --// Color pickers
            Header:Separator({Text="Color pickers"})
            Header:DragColor3({
                Value = ReGui.Accent.Light
            })
            Header:SliderColor3({
                Value = ReGui.Accent.Red
            })
            Header:InputColor3({
                Value = ReGui.Accent.Green
            })

            --// CFrame pickers
            Header:Separator({Text="CFrame pickers"})
            Header:DragCFrame({
                Value = CFrame.new(1,1,1),
                Minimum = CFrame.new(0,0,0),
                Maximum = CFrame.new(200, 100, 50),
            })
            Header:SliderCFrame()
            Header:InputCFrame()
        end,
        ["Code editor"] = function(Header)
           Header:CodeEditor({
                Text = [[print("Hello from ReGui's editor!")]],
                Editable = true
            })
        end,
        ["Console"] = function(Header)
            --// Basic
            local Basic = Header:TreeNode({Title="Basic"})
            local BasicConsole = Basic:Console({
                ReadOnly = true,
                AutoScroll = true,
                MaxLines = 50
            })

            --// Advanced
            local Advanced = Header:TreeNode({Title="Advanced & RichText"})
            local AdvancedConsole = Advanced:Console({
                ReadOnly = true,
                AutoScroll = true,
                RichText = true,
                MaxLines = 50
            })

            --// Editor
            local Editor = Header:TreeNode({Title="Editor"})
            Editor:Console({
                Value = "print('Hello world!')",
                LineNumbers = true
            })

            coroutine.wrap(function()
                while task.wait() do
                    local Date = DateTime.now():FormatLocalTime("h:mm:ss A", "en-us")

                    AdvancedConsole:AppendText(
                        `<font color="rgb(240, 40, 10)">[Random]</font>`, 
                        math.random()
                    )
                    BasicConsole:AppendText(
                        `[{Date}] Hello world!`
                    )
                end
            end)()
        end,
        ["Combo"] = function(Header)
            Header:Combo({
                WidthFitPreview = true,
                Label = "WidthFitPreview",
                Selected = 1,
                Items = {
                    "AAAAAAAAAAAA",
                    "BBBBBBBB",
                    "CCCCC",
                    "DDD",
                },
            })

            Header:Separator({Text="One-liner variants"})

            Header:Combo({
                Label = "Combo 1 (array)",
                Selected = 1,
                Items = {
                    "AAAA", 
                    "BBBB", 
                    "CCCC", 
                    "DDDD", 
                    "EEEE", 
                    "FFFF", 
                    "GGGG", 
                    "HHHH", 
                    "IIIIIII", 
                    "JJJJ", 
                    "KKKKKKK"
                }
            })
            Header:Combo({
                Label = "Combo 1 (dict)",
                Selected = "AAA",
                Items = {
                    AAA = "Apple",
                    BBB = "Banana",
                    CCC = "Orange",
                },
                Callback = print,
            })
            Header:Combo({
                Label = "Combo 2 (function)",
                Selected = 1,
                GetItems = function()
                    return {
                        "aaa",
                        "bbb",
                        "ccc",
                    }
                end,
            })
        end,
        ["Indent"] = function(Header)
            Header:Label({Text="This is not indented"})

            local Indent = Header:Indent({Offset=30})
            Indent:Label({Text="This is indented by 30 pixels"})

            local Indent2 = Indent:Indent({Offset=30})
            Indent2:Label({Text="This is indented by 30 more pixels"})
        end,
        ["Viewport"] = function(Header)
            local Rig = ReGui:InsertPrefab("R15 Rig")

            local Viewport = Header:Viewport({
                Size = UDim2.new(1, 0, 0, 200),
                Clone = true, --// Otherwise will parent
                Model = Rig,
            })

            --// Fetch the new model from the viewport
            local Model = Viewport.Model
            Model:PivotTo(CFrame.new(0, -2.5, -5))

            --// Rotate the rig
            local RunService = game:GetService("RunService")
            RunService.RenderStepped:Connect(function(DeltaTime)
                local Rotation = CFrame.Angles(0, math.rad(30*DeltaTime), 0) 
                local Pivot = Model:GetPivot() * Rotation

                Model:PivotTo(Pivot)
            end)
        end,
        ["List layout"] = function(Header)
            local List = Header:List()

            for i = 1, 10 do
                List:Button({Text=`Resize the window! {i}`})
            end
        end,
        ["Keybinds"] = function(Header)
            local TestCheckbox = Header:Checkbox({
                Value = true
            })

            Header:Keybind({
                Label = "Toggle checkbox",
                --Value = Enum.KeyCode.Q,
                IgnoreGameProcessed = false,
                OnKeybindSet = function(self, KeyId) -- KeyId: (Enum.UserInputType | Enum.KeyCode)
                    warn("[OnKeybindSet] .Value ->", KeyId)
                end,
                Callback = function(self, KeyId)
                    print(KeyId)
                    TestCheckbox:Toggle()
                end,
            })

            Header:Keybind({
                Label = "Keybind (w/ Q & Left-Click blacklist)",
                KeyBlacklist = {
                    Enum.UserInputType.MouseButton1,
                    Enum.KeyCode.Q
                }
            })

            Header:Keybind({
                Label = "Toggle UI visibility",
                Value = Enum.KeyCode.E,
                Callback = function()
                    --local IsVisible = Window.Visible
                    --Window:SetVisible(not IsVisible)
                    
                    Window:ToggleVisibility()
                end,
            })
        end,
        ["Input"] = function(Header)
            Header:InputText({Label="One Line Text"})
            Header:InputTextMultiline({Label="Multiline Text"})
            Header:InputInt({Label="Input int"})
        end,
        ["Text Input"] = function(Header)
            --// Multiline
            local Multiline = Header:TreeNode({Title="Multiline"})
            Multiline:InputTextMultiline({
                Size = UDim2.new(1,0,0,117),
                Value = [[/*The Pentium FOOF bug, shorthand for FO OF C7 C8,
    the hexadecimal encoding of one offending instruction,
    more formally, the invalid operand with locked CMPXCHG8B
    instruction bug, is a design flaw in the majority of
    Intel Pentium, Pentium MMX, and Pentium OverDrive
    processors (all in the P5 microarchitecture).#
    */]]
            })
        end,
    }

    for _, Title in DemosOrder do
        local Header = Widgets:TreeNode({
            Title=Title
        })
        local Generate = WidgetDemos[Title]

        if Generate then
            task.spawn(Generate, Header)
        end
    end

    --// Popups & child windows
    local Windows = Content:CollapsingHeader({
        Title = "Popups & child windows"
    })

    --// Popups
    local Popups = Windows:TreeNode({Title="Popups"})
    local Row = Popups:Row()

    local SelectedText = Row:Label({
        Text = "<None>",
        LayoutOrder = 2
    })

    Row:Button({
        Text = "Select..",
        Callback = function(self)
            local Names = {"Bream", "Haddock", "Mackerel", "Pollock", "Tilefish"}

            local Popup = Popups:PopupCanvas({
                RelativeTo = self,
                MaxSizeX = 200,
            })

            Popup:Separator({Text="Aquarium"})

            for _, Name in Names do
                Popup:Selectable({
                    Text = Name,
                    Callback = function(self)
                        SelectedText.Text = Name
                        Popup:ClosePopup()
                    end,
                })
            end
        end,
    })

    --// ChildWindows
    local ChildWindows = Windows:TreeNode({Title="Child windows"})
    local ChildWindow = ChildWindows:Window({
        Size = UDim2.fromOffset(300, 200),
        NoMove = true,
        NoClose = true,
        NoCollapse = true,
        NoResize = true
    })

    ChildWindow:Label({Text="Hello, world!"})
    ChildWindow:Button({Text = "Save"})
    ChildWindow:InputText({Label="string"})
    ChildWindow:SliderFloat({Label = "float", Minimum = 0.0, Maximum = 1.0})

    --// Modals
    local Modals = Windows:TreeNode({Title="Modals"})
    Modals:Label({
        Text="Modal windows are like popups but the user cannot close them by clicking outside.",
        TextWrapped = true
    })

    Modals:Button({
        Text = "Delete..",
        Callback = function()
            local ModalWindow = Modals:PopupModal({
                Title = "Delete?"
            })

            ModalWindow:Label({
                Text = "All those beautiful files will be deleted.\nThis operation cannot be undone!",
                TextWrapped = true
            })
            ModalWindow:Separator()

            ModalWindow:Checkbox({
                Value = false,
                Label = "Don't ask me next time"
            })

            local Row = ModalWindow:Row({
                Expanded = true
            })
            Row:Button({
                Text = "Okay",
                Callback = function()
                    ModalWindow:ClosePopup()
                end,
            })
            Row:Button({
                Text = "Cancel",
                Callback = function()
                    ModalWindow:ClosePopup()
                end,
            })
        end,
    })

    Modals:Button({
        Text = "Stacked modals..",
        Callback = function()
            --// First window
            local Stacked1 = Modals:PopupModal({
                Title = "Stacked 1"
            })

            Stacked1:Label({
                Text = `Hello from Stacked The First\nUsing Theme["ModalWindowDimBg"] behind it.`,
                TextWrapped = true
            })
            Stacked1:Combo({
                Items = {"aaaa", "bbbb", "cccc", "dddd", "eeee"}
            })
            Stacked1:DragColor3({
                Value = Color3.fromRGB(102, 178, 0)
            })

            Stacked1:Button({
                Text = "Add another modal..",
                Callback = function()
                    --// Second window
                    local Stacked2 = Modals:PopupModal({
                        Title = "Stacked 2"
                    })

                    Stacked2:Label({
                        Text = "Hello from Stacked The Second!",
                        TextWrapped = true
                    })

                    Stacked2:DragColor3({
                        Value = Color3.fromRGB(102, 178, 0)
                    })

                    Stacked2:Button({
                        Text = "Close",
                        Callback = function()
                            Stacked2:ClosePopup()
                        end,
                    })
                end,
            })

            Stacked1:Button({
                Text = "Close",
                Callback = function()
                    Stacked1:ClosePopup()
                end,
            })
        end,
    })

    --// Tables & Columns
    local TablesNColumns = Content:CollapsingHeader({
        Title = "Tables & Columns"
    })
    local Basic = TablesNColumns:TreeNode({
        Title = "Basic"
    })

    local BasicTable = Basic:Table()
    for RowCount = 1, 3 do
        local Row = BasicTable:Row()
        for ColumnCount = 1, 3 do
            local Column = Row:Column()
            for i = 1, 4 do
                Column:Label({Text=`Row {i} Column {ColumnCount}`})
            end
        end
    end

    --// Borders, background
    local Borders = TablesNColumns:TreeNode({
        Title = "Borders, background"
    })

    local BasicTable = Borders:Table({
        RowBackground = true,
        Border = true,
        MaxColumns = 3 -- Per row
    })

    for RowCount = 1, 5 do
        local Row = BasicTable:NextRow()
        for ColumnCount = 1, 3 do
            local Column = Row:NextColumn()
            Column:Label({Text=`Hello {ColumnCount},{RowCount}`})
        end
    end

    --// With headers
    local Headers = TablesNColumns:TreeNode({
        Title = "With headers"
    })

    local HeadersTable = Headers:Table({
        Border = true,
        RowBackground = true,
        MaxColumns = 3 -- Per row
    })

    local Rows = {"One", "Two", "Three"}

    for Line = 1, 7 do
        if Line == 1 then
            Row = HeadersTable:HeaderRow()
        else
            Row = HeadersTable:Row()
        end
        
        for Count, RowHeader in Rows do
            if Line == 1 then
                local Column = Row:Column()
                Column:Label({Text=RowHeader})
                continue
            end
            
            local Column = Row:NextColumn()
            Column:Label({Text=`Hello {Count},{Line}`})
        end
    end
end
end

Modules['config.Icons'] = function()
return {
	Dot = "rbxasset://textures/whiteCircle.png",
	Arrow = "rbxasset://textures/ui/AvatarContextMenu_Arrow.png", -- textures\ui\Backpack\ScrollDownArrow.png"
	Close = "rbxasset://textures/loading/cancelButton.png", -- \textures\ui\ScreenshotHud\Close@3x.png" \textures\loading\cancelButton.png"
	Checkmark = "rbxasset://textures/ui/Lobby/Buttons/nine_slice_button.png",
	Cat = "rbxassetid://16211812161",
	Script = "rbxassetid://11570895459",
	Settings = "rbxassetid://9743465390",
	Info = "rbxassetid://18754976792",
	Move = "rbxassetid://6710235139",
	Roblox = "rbxassetid://7414445494",
	Warning = "rbxassetid://11745872910",
	Audio = "rbxassetid://302250236",
	Shop = "rbxassetid://6473525198",
	CharacterDance = "rbxassetid://11932783331",
	Pants = "rbxassetid://10098755331",
	Home = "rbxassetid://4034483344",
	Robux = "rbxassetid://5986143282",
	Badge = "rbxassetid://16170504068",
	SpawnLocation = "rbxassetid://6400507398",
	Sword = "rbxassetid://7485051715",
	Clover = "rbxassetid://11999300014",
	Star = "rbxassetid://3057073083",
	Code = "rbxassetid://11348555035",
	Paw = "rbxassetid://13001190533",
	Shield = "rbxassetid://7461510428",
	Shield2 = "rbxassetid://7169354142",
	File = "rbxassetid://7276823330",
	Book = "rbxassetid://16061686835",
	Location = "rbxassetid://13549782519",
	Puzzle = "rbxassetid://8898417863",
	Discord = "rbxassetid://84828491431270",
	Premium = "rbxassetid://6487178625",
	Friend = "rbxassetid://10885655986",
	User = "rbxassetid://18854794412",
	Duplicate = "rbxassetid://11833749507",
	ChatBox = "rbxassetid://15839118471",
	ChatBox2 = "rbxassetid://15839116089",
	Devices = "rbxassetid://4458812712",
	Weight = "rbxassetid://9855685269",
	Image = "rbxassetid://123311808092347",
	Profile = "rbxassetid://13585614795",
	Admin = "rbxassetid://11656483170",
	PaintBrush = "rbxassetid://12111879608",
	Speed = "rbxassetid://12641434961",
	NoConnection = "rbxassetid://9795340967",
	Connection = "rbxassetid://119759670842477",
	Globe = "rbxassetid://18870359747",
	Box = "rbxassetid://140217940575618",
	Crown = "rbxassetid://18826490498",
	Control = "rbxassetid://18979524646",
	Send = "rbxassetid://18940312887",
	FastForward = "rbxassetid://112963221295680",
	Pause = "rbxassetid://109949100737970",
	Reload = "rbxassetid://11570018242",
	Joystick = "rbxassetid://18749336354",
	Controller = "rbxassetid://11894535915",
	Lock = "rbxassetid://17783082088",
	Calculator = "rbxassetid://85861816563977",
	Sun = "rbxassetid://13492317832",
	Moon = "rbxassetid://8498174594",
	Prohibited = "rbxassetid://5248916036",
	Flag = "rbxassetid://251346532",
	Website = "rbxassetid://98455290625865",
	Telegram = "rbxassetid://115860270107061",
	MusicNote = "rbxassetid://18187351229",
	Music = "rbxassetid://253830398",
	Headphones = "rbxassetid://1311321471",
	Phone = "rbxassetid://8411963035",
	Smartphone = "rbxassetid://14040313879",
	Desktop = "rbxassetid://3120635703",
	Desktop2 = "rbxassetid://4728059490",
	Laptop = "rbxassetid://4728059725",
	Server = "rbxassetid://9692125126",
	Wedge = "rbxassetid://9086583059",
	Drill = "rbxassetid://11959189471",
	Character = "rbxassetid://13285102351",
}
end

Modules['config.Accent'] = function()
return {
	--// ReGui acent colors
	Light = Color3.fromRGB(50, 150, 250),
	Dark = Color3.fromRGB(30, 66, 115),
	ExtraDark = Color3.fromRGB(28, 39, 53),
	White = Color3.fromRGB(240, 240, 240),
	Gray = Color3.fromRGB(172, 171, 175),
	Black = Color3.fromRGB(15, 19, 24),
	Yellow = Color3.fromRGB(230, 180, 0),
	Orange = Color3.fromRGB(230, 150, 0),
	Green = Color3.fromRGB(130, 188, 91),
	Red = Color3.fromRGB(255, 69, 69),

	--// ImGui acent colors
	ImGui = {
		Light = Color3.fromRGB(66, 150, 250),
		Dark = Color3.fromRGB(41, 74, 122),
		Black = Color3.fromRGB(15, 15, 15),
		Gray = Color3.fromRGB(36, 36, 36)
	}
}
end

Modules['config.Themes'] = function()
type ThemeData = {
	[string]: any
}

local Accent = Modules.load("config.Accent")
local ThemeConfigs = {}

ThemeConfigs.DarkTheme = {
	Values = {
		AnimationTweenInfo = TweenInfo.new(0.08),
		TextFont = Font.fromEnum(Enum.Font.RobotoMono),
		TextSize = 14,
		Text = Accent.White,
		TextDisabled = Accent.Gray,
		ErrorText = Accent.Red,

		FrameBg = Accent.Dark,
		FrameBgTransparency = 0.4,
		FrameBgActive = Accent.Light,
		FrameBgTransparencyActive = 0.4,
		FrameRounding = UDim.new(0, 0),

		--// Elements
		SliderGrab = Accent.Light,
		ButtonsBg = Accent.Light,
		CollapsingHeaderBg = Accent.Light,
		CollapsingHeaderText = Accent.White,
		CheckMark = Accent.Light,
		ResizeGrab = Accent.Light,
		HeaderBg = Accent.Gray,
		HeaderBgTransparency = 0.7,
		HistogramBar = Accent.Yellow,
		ProgressBar = Accent.Yellow,
		RegionBg = Accent.Dark,
		RegionBgTransparency = 0.1,
		Separator = Accent.Gray,
		SeparatorTransparency = 0.5,
		ConsoleLineNumbers = Accent.White,
		LabelPaddingTop = UDim.new(0, 0),
		LabelPaddingBottom = UDim.new(0, 0),
		MenuBar = Accent.ExtraDark,
		MenuBarTransparency = 0.1,
		PopupCanvas = Accent.Black,

		--// TabSelector
		TabTextPaddingTop = UDim.new(0, 3),
		TabTextPaddingBottom = UDim.new(0, 8),
		TabText = Accent.Gray,
		TabBg = Accent.Dark,
		TabTextActive = Accent.White,
		TabBgActive = Accent.Light,
		TabsBarBg = Color3.fromRGB(36, 36, 36),
		TabsBarBgTransparency = 1,
		TabPagePadding = UDim.new(0, 8),

		--// Window
		ModalWindowDimBg = Color3.fromRGB(230, 230, 230),
		ModalWindowDimTweenInfo = TweenInfo.new(0.2),

		WindowBg = Accent.Black,
		WindowBgTransparency = 0.05,

		Border = Accent.Gray,
		BorderTransparency = 0.8,
		BorderTransparencyActive = 0.5,

		Title = Accent.White,
		TitleAlign = Enum.TextXAlignment.Left,
		TitleBarBg = Accent.Black,
		TitleBarTransparency = 0,
		TitleActive = Accent.White,
		TitleBarBgActive = Accent.Dark,
		TitleBarTransparencyActive = 0.05,
		TitleBarBgCollapsed = Color3.fromRGB(0, 0, 0),
		TitleBarTransparencyCollapsed = 0.6,
	}
}
ThemeConfigs.LightTheme = {
	BaseTheme = ThemeConfigs.DarkTheme,
	Values = {
		Text = Accent.Black,
		TextFont = Font.fromEnum(Enum.Font.Ubuntu),
		TextSize = 14,

		FrameBg = Accent.Gray,
		FrameBgTransparency = 0.4,
		FrameBgActive = Accent.Light,
		FrameBgTransparencyActive = 0.6,

		SliderGrab = Accent.Light,
		ButtonsBg = Accent.Light,
		CollapsingHeaderText = Accent.Black,
		Separator = Accent.Black,
		ConsoleLineNumbers = Accent.Yellow,
		MenuBar = Color3.fromRGB(219, 219, 219),
		PopupCanvas = Accent.White,

		TabText = Accent.Black,
		TabTextActive = Accent.Black,

		WindowBg = Accent.White,
		Border = Accent.Gray,
		ResizeGrab = Accent.Gray,

		Title = Accent.Black,
		TitleAlign = Enum.TextXAlignment.Center,
		TitleBarBg = Accent.Gray,
		TitleActive = Accent.Black,
		TitleBarBgActive = Color3.fromRGB(186, 186, 186),
		TitleBarBgCollapsed = Accent.Gray
	}
}
ThemeConfigs.ImGui = {
	BaseTheme = ThemeConfigs.DarkTheme,
	Values = {
		AnimationTweenInfo = TweenInfo.new(0),
		Text = Color3.fromRGB(255, 255, 255),

		FrameBg = Accent.ImGui.Dark,
		FrameBgTransparency = 0.4,
		FrameBgActive = Accent.ImGui.Light,
		FrameBgTransparencyActive = 0.5,
		FrameRounding = UDim.new(0, 0),

		ButtonsBg = Accent.ImGui.Light,
		CollapsingHeaderBg = Accent.ImGui.Light,
		CollapsingHeaderText = Accent.White,
		CheckMark = Accent.ImGui.Light,
		ResizeGrab = Accent.ImGui.Light,
		MenuBar = Accent.ImGui.Gray,
		MenuBarTransparency = 0,
		PopupCanvas = Accent.ImGui.Black,

		TabText = Accent.Gray,
		TabBg = Accent.ImGui.Dark,
		TabTextActive = Accent.White,
		TabBgActive = Accent.ImGui.Light,

		WindowBg = Accent.ImGui.Black,
		WindowBgTransparency = 0.05,
		Border = Accent.Gray,
		BorderTransparency = 0.7,
		BorderTransparencyActive = 0.4,

		Title = Accent.White,
		TitleBarBg = Accent.ImGui.Black,
		TitleBarTransparency = 0,
		TitleBarBgActive = Accent.ImGui.Dark,
		TitleBarTransparencyActive = 0,
	}
}

return ThemeConfigs
end

Modules['config.Flags'] = function()
--// Global flags for styling

type table = {
    [any]: any
}
type FlagFunc = {
	Data: {
		Class: {},
		WindowClass: table?
	},
	Object: GuiObject
}

local Wrappers = Modules.load("classes.Wrappers")
local ReGui = nil

Wrappers:AddOnInit(function(self)
	ReGui = self
end)

return {
	{
		Properties = {"Center"},
		Callback = function<FlagFunc>(Data, Object, Value)
			local Position = Object.Position
			Wrappers:SetProperties(Object, {
				Position = UDim2.new(
					Value:find("X") and 0.5 or Position.X.Scale,
					Position.X.Offset,
					Value:find("Y") and 0.5 or Position.Y.Scale,
					Position.Y.Offset
				),
				AnchorPoint = Vector2.new(
					Value:find("X") and 0.5 or 0,
					Value:find("Y") and 0.5 or 0
				)
			})
		end,
	},
	{
		Properties = {"ElementStyle"},
		Callback = function<StyleFunc>(Data, Object, Value)
			ReGui:ApplyStyle(Object, Value)
		end,
	},
	{
		Properties = {"ColorTag"},
		Callback = function<StyleFunc>(Data, Object, Value)
			local Class = Data.Class
			local WindowClass = Data.WindowClass
			local NoAutoTheme = Class.NoAutoTheme

			--// Check if theming is enabled
			if not WindowClass then return end
			if NoAutoTheme then return end

			ReGui:UpdateColors({
				Object = Object,
				Tag = Value,
				NoAnimation = true,
				Theme = WindowClass.Theme,
			})
		end,
	},
	{
		Properties = {"Animation"},
		Callback = function<StyleFunc>(Data, Object, Value)
			--// Check if animations are disabled
			local NoAnimation = Data.Class.NoAnimation
			if NoAnimation then return end

			ReGui:SetAnimation(Object, Value)
		end,
	},
	{
		Properties = {"Image"},
		Callback = function<StyleFunc>(Data, Object, Value)
			local WindowClass = Data.WindowClass
			Object.Image = Wrappers:CheckAssetUrl(Value)
			ReGui:DynamicImageTag(Object, Value, WindowClass)
		end,
	},
	{
		Properties = {"Icon", "IconSize", "IconRotation", "IconPadding"},
		Callback = function<StyleFunc>(Data, Object, Value)
			--// Locate icon element
			local Icon = Object:FindFirstChild("Icon", true)
			if not Icon then 
                ReGui:Warn("No icon for", Object) 
				return
			end 

			--// Check class data for missing values
			local Class = Data.Class
			Wrappers:CheckConfig(Class, {
				Icon = "",
				IconSize = UDim2.fromScale(1,1),
				IconRotation = 0,
				IconPadding = UDim2.new(0, 2)
			})

			--// Apply icon padding
			local Padding = Icon.Parent:FindFirstChild("UIPadding")
			Wrappers:SetPadding(Padding, Class.IconPadding)

			--// Check image asset url
			local Image = Class.Icon
			Image = Wrappers:CheckAssetUrl(Image)

			--// Dynamic image
			local WindowClass = Data.WindowClass
			ReGui:DynamicImageTag(Icon, Image, WindowClass)
			Wrappers:SetProperties(Icon, {
				Visible = Icon ~= "",
				Image = Wrappers:CheckAssetUrl(Image),
				Size = Class.IconSize,
				Rotation = Class.IconRotation
			})
		end,
	},
	{
		Properties = {"BorderThickness", "Border", "BorderColor"},
		Callback = function<StyleFunc>(Data, Object, Value)
			local Class = Data.Class
			local Enabled = Class.Border == true

			Wrappers:CheckConfig(Class, {
				BorderTransparency = Data:GetThemeKey("BorderTransparencyActive"),
				BorderColor = Data:GetThemeKey("Border"),
				BorderThickness = 1,
				BorderStrokeMode = Enum.ApplyStrokeMode.Border,
			})

			--// Apply properties to UIStroke
			local Stroke = Wrappers:GetChildOfClass(Object, "UIStroke")
			Wrappers:SetProperties(Stroke, {
				Transparency = Class.BorderTransparency,
				Thickness = Class.BorderThickness,
				Color = Class.BorderColor,
				ApplyStrokeMode = Class.BorderStrokeMode,
				Enabled = Enabled
			})
		end,
	},
	{
		Properties = {"Ratio"},
		Callback = function<StyleFunc>(Data, Object, Value)
			local Class = Data.Class

			Wrappers:CheckConfig(Class, {
				Ratio = 4/3,
				RatioAxis = Enum.DominantAxis.Height,
				RatioAspectType = Enum.AspectType.ScaleWithParentSize
			})

			--// Unpack data
			local AspectRatio = Class.Ratio
			local Axis = Class.RatioAxis
			local AspectType = Class.RatioAspectType

			local Ratio = Wrappers:GetChildOfClass(Object, "UIAspectRatioConstraint")
			Wrappers:SetProperties(Ratio, {
				DominantAxis = Axis,
				AspectType = AspectType,
				AspectRatio = AspectRatio
			})
		end,
	},
	{
		Properties = {"FlexMode"},
		Callback = function<StyleFunc>(Data, Object, Value)
			local FlexItem = Wrappers:GetChildOfClass(Object, "UIFlexItem")
			FlexItem.FlexMode = Value
		end,
	},
	{
		--Recursive = true,
		Properties = {"CornerRadius"},
		Callback = function<StyleFunc>(Data, Object, Value)
			local UICorner = Wrappers:GetChildOfClass(Object, "UICorner")
			UICorner.CornerRadius = Value
		end,
	},
	{
		Properties = {"Fill"},
		Callback = function<StyleFunc>(Data, Object, Value)
			if Value ~= true then return end

			local Class = Data.Class
			Wrappers:CheckConfig(Class, {
				Size = UDim2.fromScale(1, 1),
				UIFlexMode = Enum.UIFlexMode.Fill,
				AutomaticSize = Enum.AutomaticSize.None
			})

			--// Create FlexLayout property
			local Flex = Wrappers:GetChildOfClass(Object, "UIFlexItem")
			Flex.FlexMode = Class.UIFlexMode

			Object.Size = Class.Size
			Object.AutomaticSize = Class.AutomaticSize
		end,
	},
	{
		Properties = {"Label"},
		Callback = function<StyleFunc>(Data, Object, Value)
            local Class = Data.Class

			local Label = Object:FindFirstChild("Label")
			if not Label then return end
			
            Label.Text = tostring(Value)

			function Class:SetLabel(Text)
				Label.Text = Text
				return self
			end
		end,
	},
	{
		Properties = {"NoGradient"},
		WindowProperties = {"NoGradients"},
		Callback = function<StyleFunc>(Data, Object, Value)
			local UIGradient = Object:FindFirstChildOfClass("UIGradient")
			if not UIGradient then return end

			UIGradient.Enabled = Value
		end,
	},
	{
		Properties = {
			"UiPadding", 
			"PaddingBottom", 
			"PaddingTop",
			"PaddingRight", 
			"PaddingTop"
		},
		Callback = function<StyleFunc>(Data, Object, Value)
			Value = Value or 0

			--// Convert number value into a UDim
			if typeof(Value) == "number" then
				Value = UDim.new(0, Value)
			end

			local Class = Data.Class

			local IsUiPadding = Class.UiPadding
			if IsUiPadding then
				Wrappers:CheckConfig(Class, {
					PaddingBottom = Value,
					PaddingLeft = Value,
					PaddingRight = Value,
					PaddingTop = Value,
				})
			end

			local UIPadding = Wrappers:GetChildOfClass(Object, "UIPadding")
			Wrappers:SetProperties(UIPadding, {
				PaddingBottom = Class.PaddingBottom,
				PaddingLeft = Class.PaddingLeft,
				PaddingRight = Class.PaddingRight,
				PaddingTop = Class.PaddingTop,
			})
		end,
	},
	{
		Properties = {"Callback"},
		Callback = function<StyleFunc>(Data, Object)
			local Class = Data.Class

			function Class:SetCallback(NewCallback)
				self.Callback = NewCallback
				return self
			end
			function Class:FireCallback(NewCallback)
				self.Callback(Object)
				return self
			end
		end,
	},
	{
		Properties = {"Value"},
		Callback = function<StyleFunc>(Data, Object)
			local Class = Data.Class
			Wrappers:CheckConfig(Class, {
				GetValue = function(self)
					return Class.Value
				end,
			})
		end
	}
}

end

Modules['config.Tagging'] = function()
local Tags = {}

Tags.Coloring = {
	["MenuBar"] = {
		BackgroundColor3 = "MenuBar",
		BackgroundTransparency = "MenuBarTransparency",
	},
	["FrameRounding"] = {
		CornerRadius = "FrameRounding"
	},
	["PopupCanvas"] = {
		BackgroundColor3 = "PopupCanvas"
	},
	["ModalWindowDim"] = {
		BackgroundColor3 = "ModalWindowDimBg"
	},
	["Selectable"] = "Button",
	["MenuButton"] = "Button",
	["Separator"] = {
		BackgroundColor3 = "Separator",
		BackgroundTransparency = "SeparatorTransparency",
	},
	["Region"] = {
		BackgroundColor3 = "RegionBg",
		BackgroundTransparency = "RegionBgTransparency",
	},
	["Label"] = {
		TextColor3 = "Text",
		FontFace = "TextFont",
		TextSize = "TextSize",
	},
	["ImageFollowsText"] = {
		ImageColor3 = "Text",
	},
	["ConsoleLineNumbers"] = {
		TextColor3 = "ConsoleLineNumbers",
		FontFace = "TextFont",
		TextSize = "TextSize",
	},
	["ConsoleText"] = "Label",
	["LabelDisabled"] = {
		TextColor3 = "TextDisabled",
		FontFace = "TextFont",
		TextSize = "TextSize",
	},
	["Plot"] = {
		BackgroundColor3 = "HistogramBar",
	},
	["Header"] = {
		BackgroundColor3 = "HeaderBg",
		BackgroundTransparency = "HeaderBgTransparency",
	},
	["WindowTitle"] = {
		TextXAlignment = "TitleAlign",
		FontFace = "TextFont",
		TextSize = "TextSize",
	},
	["TitleBar"] = {
		BackgroundColor3 = "TitleBarBgActive"
	},
	["Window"] = {
		BackgroundColor3 = "WindowBg",
		BackgroundTransparency = "WindowBgTransparency"
	},
	["TitleBarBgCollapsed"] = {
		BackgroundColor3 = "TitleBarBgCollapsed",
		BackgroundTransparency = "TitleBarTransparencyCollapsed"
	},
	["TitleBarBgActive"] = {
		BackgroundColor3 = "TitleBarBgActive",
		BackgroundTransparency = "TitleBarTransparencyActive"
	},
	["TitleBarBg"] = {
		BackgroundColor3 = "TitleBarBg",
		BackgroundTransparency = "TitleBarTransparency"
	},
	["TabsBar"] = {
		BackgroundColor3 = "TabsBarBg",
		BackgroundTransparency = "TabsBarBgTransparency",
	},
	["Border"] = {
		Color = "Border",
		Transparency = "BorderTransparency"
	},
	["ResizeGrab"] = {
		TextColor3 = "ResizeGrab"
	},
	["BorderActive"] = {
		Transparency = "BorderTransparencyActive"
	},
	["Frame"] = {
		BackgroundColor3 = "FrameBg",
		BackgroundTransparency = "FrameBgTransparency",
		TextColor3 = "Text",
		FontFace = "TextFont",
		TextSize = "TextSize",
	},
	["FrameActive"] = {
		BackgroundColor3 = "FrameBgActive",
		BackgroundTransparency = "FrameBgTransparencyActive"
	},
	["SliderGrab"] = {
		BackgroundColor3 = "SliderGrab"
	},
	["Button"] = {
		BackgroundColor3 = "ButtonsBg",
		TextColor3 = "Text",
		FontFace = "TextFont",
		TextSize = "TextSize",
	},
	["CollapsingHeader"] = {
		FontFace = "TextFont",
		TextSize = "TextSize",
		TextColor3 = "CollapsingHeaderText",
		BackgroundColor3 = "CollapsingHeaderBg",
	},
	["Checkbox"] = {
		BackgroundColor3 = "FrameBg",
	},
	["CheckMark"] = {
		ImageColor3 = "CheckMark",
		BackgroundColor3 = "CheckMark",
	},
	["RadioButton"] = {
		BackgroundColor3 = "ButtonsBg",
		TextColor3 = "Text",
		FontFace = "TextFont",
		TextSize = "TextSize"
	}
}

Tags.Styles = {
	RadioButton = {
		Animation = "RadioButtons",
		CornerRadius = UDim.new(1, 0),
	},
	Button = {
		Animation = "Buttons"
	},
	CollapsingHeader = {
		Animation = "Buttons"
	},
	TreeNode = {
		Animation = "TransparentButtons"
	},
	TransparentButton = {
		Animation = "TransparentButtons"
	}
}

Tags.Animations = {
	["Invisible"] = {
		Connections = {
			MouseEnter = {
				Visible = true,
			},
			MouseLeave = {
				Visible = false,
			}
		},
		Init = "MouseLeave"
	},
	["Buttons"] = {
		Connections = {
			MouseEnter = {
				BackgroundTransparency = 0.3,
			},
			MouseLeave = {
				BackgroundTransparency = 0.7,
			}
		},
		Init = "MouseLeave"
	},
	["TextButtons"] = {
		Connections = {
			MouseEnter = {
				TextTransparency = 0.3,
			},
			MouseLeave = {
				TextTransparency = 0.7,
			}
		},
		Init = "MouseLeave"
	},
	["TransparentButtons"] = {
		Connections = {
			MouseEnter = {
				BackgroundTransparency = 0.3,
			},
			MouseLeave = {
				BackgroundTransparency = 1,
			}
		},
		Init = "MouseLeave"
	},
	["RadioButtons"] = {
		Connections = {
			MouseEnter = {
				BackgroundTransparency = 0.5,
			},
			MouseLeave = {
				BackgroundTransparency = 1,
			}
		},
		Init = "MouseLeave"
	},
	["Inputs"] = {
		Connections = {
			MouseEnter = {
				BackgroundTransparency = 0,
			},
			MouseLeave = {
				BackgroundTransparency = 0.5,
			},
		},
		Init = "MouseLeave"
	},
	["Plots"] = {
		Connections = {
			MouseEnter = {
				BackgroundTransparency = 0.3,
			},
			MouseLeave = {
				BackgroundTransparency = 0,
			},
		},
		Init = "MouseLeave"
	},
	["Border"] = {
		Connections = {
			Selected = {
				Transparency = 0,
				Thickness = 1
			},
			Deselected = {
				Transparency = 0.7,
				Thickness = 1
			}
		},
		Init = "Selected"
	},
}

return Tags
end

-- Load function
function Modules.load(moduleName)
    if not Modules.cache[moduleName] then
        local moduleFunc = Modules[moduleName]
        if not moduleFunc then
            error(" Module not found: " .. moduleName)
        end
        Modules.cache[moduleName] = moduleFunc()
    end
    return Modules.cache[moduleName]
end
-- Main Code (wrapped in function for loadstring)
return (function()
--[[

      _       ,-'REGUI`-._
    (,-.`._,'( By Depso |\`-/|
        `-.-' \ )-----`( , o o)
               `-       \`_---_
			
    Written by depso
    MIT License
    
    https://github.com/depthso
]]

local ReGui = {
	--// Package data
	Version = "1.4.7",
	Author = "Depso",
	License = "MIT",
	Repository = "https://github.com/Jibbefr/Dear-ReGui-Edited/",

	--// Configuration
	Debug = false,
	PrefabsId = 71968920594655,
	DefaultTitle = "ReGui",
	ContainerName = "ReGui",
	DoubleClickThreshold = 0.3,
	TooltipOffset = 15,
	IniToSave = {
		"Value"
	},
	ClassIgnored = {
		"Visible",
		"Text"
	},

	--// Objects
	Container = nil,
	Prefabs = nil,
	FocusedWindow = nil,
	HasTouchScreen = false,

	--// Classes
	Services = nil,
	Elements = {},

	--// Collections
	_FlagCache = {},
	_ErrorCache = {},
	_Connections = {},
	Windows = {},
	ActiveTooltips = {},
	IniSettings = {},
	AnimationConnections = {}	
}


--// Modules
local IDE = Modules.load("lib.ide")
local Wrappers = Modules.load("classes.Wrappers")
local Animation = Modules.load("classes.Animations")
local Signaling = Modules.load("classes.Signaling")
ReGui.DemoWindow = Modules.load("src.Demo Window")
ReGui.Services = Wrappers.Services
ReGui.Animation = Animation

--// Configurations
ReGui.Icons = Modules.load("config.Icons")
ReGui.Accent = Modules.load("config.Accent")
ReGui.ThemeConfigs = Modules.load("config.Themes")
ReGui.ElementFlags = Modules.load("config.Flags")

local Tags = Modules.load("config.Tagging")
ReGui.ElementColors = Tags.Coloring
ReGui.Animations = Tags.Animations
ReGui.Styles = Tags.Styles

--// Call OnInit connections
Wrappers:CallOnInitConnections(ReGui)

ReGui.DynamicImages = {
	[ReGui.Icons.Arrow] = "ImageFollowsText",
	[ReGui.Icons.Close] = "ImageFollowsText",
	[ReGui.Icons.Dot] = "ImageFollowsText",
}

type table = { 
	[any]: any 
}
type TagsList = {
	[GuiObject]: string 
}

--// Core functions 
--// Services
local Services = ReGui.Services
local HttpService = Services.HttpService
local Players = Services.Players
local UserInputService = Services.UserInputService
local RunService = Services.RunService
local InsertService = Services.InsertService 

--// LocalPlayer
local LocalPlayer = Wrappers:NewReference(Players.LocalPlayer)
ReGui.PlayerGui = Wrappers:NewReference(LocalPlayer.PlayerGui)
ReGui.Mouse = Wrappers:NewReference(LocalPlayer:GetMouse())

local EmptyFunction = function() end

function GetAndRemove(Key: string, Dict: table)
	local Value = Dict[Key]
	if Value then
		Dict[Key] = nil
	end
	return Value
end

function MoveTableItem(Table: table, Item, NewPosition: number)
	local Index = table.find(Table, Item)
	if not Index then return end

	local Value = table.remove(Table, Index)
	table.insert(Table, NewPosition, Value)
end

function Merge(Base, New)
	for Key, Value in next, New do
		Base[Key] = Value
	end
end

function Copy(Original: table, Insert: table?)
	local Table = table.clone(Original)

	--// Merge Insert values
	if Insert then
		Merge(Table, Insert)
	end

	return Table
end

local function GetMatchPercentage(Value, Query: string): number
	Value = tostring(Value):lower()
	Query = Query:lower()

	local Letters = Value:split("")
	local LetterCount = #Query
	local MatchedCount = 0

	for Index, Letter in Letters do
		local Match = Query:sub(Index, Index)

		--// Compare letters
		if Letter == Match then
			MatchedCount += 1
		end
	end

	local Percentage = (MatchedCount/LetterCount) * 100
	return math.round(Percentage)
end

local function SortByQuery(Table: table, Query: string): table
	local IsArray = Table[1]
	local Sorted = {}

	for A, B in Table do
		local Value = IsArray and B or A
		local Percentage = GetMatchPercentage(Value, Query)
		local Position = 100 - Percentage

		table.insert(Sorted, Position, Value)
	end

	return Sorted
end

function ReGui:Warn(...: string?)
	warn("[ReGui]::", ...)
end

function ReGui:Error(...: string?)
	local Concated = ReGui:Concat({...}, " ")
	local Message = `\n[ReGui]:: {Concated}`
	coroutine.wrap(error)(Message)
end

function ReGui:IsDoubleClick(TickRange: number): boolean
	local ClickThreshold = self.DoubleClickThreshold
	return TickRange < ClickThreshold
end

function ReGui:StyleContainers()
	local Container = self.Container
	local Overlays = Container.Overlays
	local Windows = Container.Windows
	
	self:SetProperties(Windows, {
		OnTopOfCoreBlur = true
	})
	self:SetProperties(Overlays, {
		OnTopOfCoreBlur = true
	})
end

function ReGui:Destroy()
	--// Disconnect all stored connections
	local Connections = self._Connections
	if Connections then
		for _, Connection in next, Connections do
			if typeof(Connection) == "RBXScriptConnection" then
				Connection:Disconnect()
			end
		end
		table.clear(Connections)
	end

	--// Destroy the container
	local Container = self.Container
	if Container then
		pcall(function()
			Container:Destroy()
		end)
	end

	--// Reset state
	self.Initialised = false
	self.Container = nil
	self.TooltipsContainer = nil
	self.FocusedWindow = nil
	self.Windows = {}
	self.ActiveTooltips = {}
end

function ReGui:Init(Overwrites: table?)
	Overwrites = Overwrites or {}

	--// Check if the library has already initalised
	if self.Initialised then return end

	--// Cleanup previous instance if re-executing
	if not (REGUI_WINDOWS or _G.REGUI_WINDOWS or (getgenv and getgenv().REGUI_WINDOWS)) then
		self:Destroy()
	end

	--// Merge overwrites
	Merge(self, Overwrites)
	Merge(self, {
		Initialised = true,
		HasGamepad = self:IsConsoleDevice(),
		HasTouchScreen = self:IsMobileDevice(),
	})

	--// Validate Prefabs before proceeding
	if not self.Prefabs then
		--// Try loading Prefabs
		self:CheckConfig(self, {
			Prefabs = function()
				return self:LoadPrefabs()
			end,
		}, true)
		
		--// If still nil, abort initialization
		if not self.Prefabs then
			self.Initialised = false
			self:Warn("Failed to load Prefabs! Cannot initialize.")
			return
		end
	end

	--// Fetch folders
	self:CheckConfig(self, {
		ContainerParent = function()
			return Wrappers:ResolveUIParent()
		end,
	}, true)

	--// Fetch required assets
	self:CheckConfig(self, {
		Container = function()
			return self:InsertPrefab("Container", {
				Parent = self.ContainerParent,
				Name = self.ContainerName
			})
		end,
	}, true)

	--// Containers
	local Container = self.Container
	if not Container then
		self.Initialised = false
		self:Warn("Failed to create Container! Cannot initialize.")
		return
	end

	local TooltipOffset = self.TooltipOffset
	local ActiveTooltips = self.ActiveTooltips
	local Overlays = Container.Overlays
	local LastClick = 0
	
	self:StyleContainers()

	--// Create tooltips container
	self.TooltipsContainer = self.Elements:Overlay({
		Parent = Overlays
	})

	--// Key press (store connection for cleanup)
	local InputBeganConn = UserInputService.InputBegan:Connect(function(Input: InputObject)
		if not self:IsMouseEvent(Input, true) then return end

		local ClickTick = tick()
		local ClickRange = ClickTick - LastClick
		local IsDoubleClick = self:IsDoubleClick(ClickRange)

		--// DoubleClick
		LastClick = IsDoubleClick and 0 or ClickTick

		--// WindowActiveStates
		self:UpdateWindowFocuses()
	end)
	table.insert(self._Connections, InputBeganConn)

	local function InputUpdate()
		local Tooltips = self.TooltipsContainer
		if not Tooltips then return end
		
		local Visible = #ActiveTooltips > 0
		Tooltips.Visible = Visible

		if not Visible then return end

		--// Set frame position to mosue location
		local X, Y = ReGui:GetMouseLocation()
		local Position = Overlays.AbsolutePosition

		Tooltips.Position = UDim2.fromOffset(
			X - Position.X + TooltipOffset, 
			Y - Position.Y + TooltipOffset
		)
	end

	--// Bind events (store connection for cleanup)
	local RenderConn = RunService.RenderStepped:Connect(InputUpdate)
	table.insert(self._Connections, RenderConn)
end

function ReGui:BuildInternalPrefabs()
    warn('[ReGui] Reverse Engineering By DayToDay2044')
    local inf = math.huge
    local ind = nil
    local function nan(...) return 0 end
    local Folder = Instance.new('Folder')
    Folder.Name = 'ReGui-Prefabs'
    local Prefabs = Instance.new('Folder')
    Prefabs.Name = 'Prefabs'
    Prefabs.Parent = Folder
    local Obj = {}
    local function Make(Class, Props, Parent)
        local Obj = Instance.new(Class)
        for k, v in pairs(Props) do
            if k == '_Attributes' then
                for attrName, attrVal in pairs(v) do Obj:SetAttribute(attrName, attrVal) end
            elseif k == '_Tags' then
                for _, tag in ipairs(v) do game:GetService('CollectionService'):AddTag(Obj, tag) end
            elseif k ~= 'Parent' then
                pcall(function() Obj[k] = v end)
            end
        end
        if Parent then Obj.Parent = Parent end
        return Obj
    end
    Obj[1] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(15, 15, 15), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Really black"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 2487, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.25, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Prefabs", Localize = false, AbsoluteSize = Vector2.new(800.000000, 600.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(0.000000, 0.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(0.000000, 0.000000, 800.000000, 600.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.25}, Prefabs)
    Obj[2] = Make('Frame', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 114, 114), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Persimmon"), Size = UDim2.new(0.000000, 372, 0.000000, 38), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 10, 0.000000, 10), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 73, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(110.000000, 5.000000, 210.000000, 85.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Window", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(110.000000, 5.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(110.000000, 5.000000, 210.000000, 85.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[3] = Make('TextButton', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "Button", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(-nan(ind), -nan(ind)), TextTransparency = 1, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 1.000000, 0), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "Content", ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Legacy, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "", FontSize = Enum.FontSize.Size8, OpenTypeFeaturesError = "", Interactable = true, DataCost = 59, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(110.000000, 5.000000, 210.000000, 85.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, ContentText = "Button", Transparency = 1, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(110.000000, 5.000000, 210.000000, 85.000000), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Black"), AbsoluteSize = Vector2.new(100.000000, 80.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Outline, AbsolutePosition = Vector2.new(110.000000, 5.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(0.000000, 0.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1, Selected = false, AutomaticSize = Enum.AutomaticSize.Y, MouseWheelForwardConnectionCount = 0, Selectable = false, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(27, 42, 53), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "Button", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 8}, Obj[2])
    Obj[4] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(100.000000, 19.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 0), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.Fill, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 0), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 0), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[3])
    Obj[5] = Make('UIDragDetector', {MinDragAngle = 0, SelectionModeRotateSpeed = 90, DataCost = 4, MinDragTranslation = UDim2.new(0.000000, 0, 0.000000, 0), AttributesReplicate = "", SelectionModeDragSpeed = UDim2.new(0.000000, 300, 0.000000, 300), DragRotation = 0, ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset, archivable = true, DragSpace = Enum.UIDragDetectorDragSpace.Parent, DragStyle = Enum.UIDragDetectorDragStyle.Scriptable, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, MaxDragTranslation = UDim2.new(0.000000, 0, 0.000000, 0), DragAxis = Vector2.new(1.000000, 0.000000), DragRelativity = Enum.UIDragDetectorDragRelativity.Relative, ClassName = "UIDragDetector", CursorIcon = "", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", BoundingBehavior = Enum.UIDragDetectorBoundingBehavior.Automatic, AttributesSerialize = "", MaxDragAngle = 0, HistoryId = "00000000000000000000000000000000", UIDragSpeedAxisMapping = Enum.UIDragSpeedAxisMapping.XY, UniqueId = "00000000000000000000000000000000", RobloxLocked = false, numExpectedDirectChildren = 0, Enabled = false, Name = "UIDragDetector", className = "UIDragDetector", DragUDim2 = UDim2.new(0.000000, 0, 0.000000, 0), DefinesCapabilities = false, Archivable = true, ActivatedCursorIcon = ""}, Obj[3])
    Obj[6] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(60, 150, 250), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Cyan"), Size = UDim2.new(1.000000, 0, 0.000000, 19), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 40, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.30000001192092896, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(110.000000, 5.000000, 210.000000, 24.000000), LayoutOrder = -2, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "TitleBar", Localize = false, AbsoluteSize = Vector2.new(100.000000, 19.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(110.000000, 5.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(110.000000, 5.000000, 210.000000, 24.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.30000001192092896}, Obj[3])
    Obj[7] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 1), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 4), PaddingTop = UDim.new(0.000000, 1), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 4), HistoryId = "00000000000000000000000000000000"}, Obj[6])
    Obj[8] = Make('UIGradient', {PredictionMode = Enum.PredictionMode.Automatic, Color = ColorSequence.new({ColorSequenceKeypoint.new(0.000000, Color3.new(1.000000, 1.000000, 1.000000)), ColorSequenceKeypoint.new(1.000000, Color3.new(0.666667, 0.666667, 0.666667))}), DataCost = 4, AttributesReplicate = "", Attributes = "", className = "UIGradient", Enabled = false, numExpectedDirectChildren = 0, Archivable = true, archivable = true, Offset = Vector2.new(0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, Rotation = 0, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0.000000, 0.000000, 0.000000), NumberSequenceKeypoint.new(1.000000, 0.000000, 0.000000)}), Name = "UIGradient", ClassName = "UIGradient", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[6])
    Obj[9] = Make('UIFlexItem', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, GrowRatio = 0, AttributesReplicate = "", Attributes = "", FlexMode = Enum.UIFlexMode.None, Archivable = true, className = "UIFlexItem", ItemLineAlignment = Enum.ItemLineAlignment.Automatic, numExpectedDirectChildren = 0, ShrinkRatio = 0, Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", Tags = "", SourceAssetId = -1, Name = "UIFlexItem", ClassName = "UIFlexItem", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[6])
    Obj[10] = Make('ImageLabel', {Visible = false, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, AbsoluteRotation = 0, Image = "", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Really black"), BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 16, 0.000000, 16), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), SliceScale = 1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 14, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScaleType = Enum.ScaleType.Stretch, AutoLocalize = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, className = "ImageLabel", Transparency = 1, ClassName = "ImageLabel", SelectionOrder = 0, LayoutOrder = 1, MouseWheelBackwardConnectionCount = 0, archivable = true, ClippedRect = Rect.new(110.000000, 5.000000, 210.000000, 24.000000), SourceAssetId = -1, RobloxLocked = false, BorderMode = Enum.BorderMode.Outline, Name = "Icon", GuiState = Enum.GuiState.Idle, AttributesSerialize = "", AnchorPoint = Vector2.new(0.000000, 0.000000), ImageColor3 = Color3.fromRGB(255, 255, 255), Attributes = "", ImageRectSize = Vector2.new(0.000000, 0.000000), SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Archivable = true, AutomaticSize = Enum.AutomaticSize.None, TotalGroupScale = 1, MouseMovedConnectionCount = 0, AbsoluteSize = Vector2.new(0.000000, 0.000000), IsNotOccluded = true, Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(114.000000, 6.000000), numExpectedDirectChildren = 0, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, Selectable = false, ResampleMode = Enum.ResamplerMode.Default, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(114.000000, 6.000000, 114.000000, 6.000000), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, ImageRectOffset = Vector2.new(0.000000, 0.000000)}, Obj[6])
    Obj[11] = Make('UIAspectRatioConstraint', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, DominantAxis = Enum.DominantAxis.Width, AttributesReplicate = "", AspectRatio = 1, Attributes = "", Archivable = true, className = "UIAspectRatioConstraint", DefinesCapabilities = false, Tags = "", Sandboxed = false, numExpectedDirectChildren = 0, PropertyStatusStudio = Enum.PropertyStatus.Ok, archivable = true, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, Name = "UIAspectRatioConstraint", ClassName = "UIAspectRatioConstraint", RobloxLocked = false, AspectType = Enum.AspectType.FitWithinMaxSize, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[10])
    Obj[12] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.Fill, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[6])
    Obj[13] = Make('UIStroke', {PredictionMode = Enum.PredictionMode.Automatic, className = "UIStroke", BorderOffset = UDim.new(0.000000, 0), StrokeSizingMode = Enum.StrokeSizingMode.FixedSize, DataCost = 4, numExpectedDirectChildren = 0, AttributesReplicate = "", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, archivable = true, Attributes = "", UniqueId = "00000000000000000000000000000000", AttributesSerialize = "", ZIndex = 1, Archivable = true, SourceAssetId = -1, Enabled = true, Color = Color3.fromRGB(135, 135, 148), Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HistoryId = "00000000000000000000000000000000", Thickness = 1, Transparency = 0, Name = "Border", ClassName = "UIStroke", RobloxLocked = false, DefinesCapabilities = false, LineJoinMode = Enum.LineJoinMode.Round, BorderStrokePosition = Enum.BorderStrokePosition.Outer}, Obj[2])
    Obj[14] = Make('Frame', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 5, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(15, 15, 15), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Really black"), Size = UDim2.new(0.000000, 200, 0.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 36, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.07199999690055847, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(215.000000, 5.000000, 315.000000, 85.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "OverlayScroll", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(215.000000, 5.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(215.000000, 5.000000, 315.000000, 85.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.07199999690055847}, Obj[1])
    Obj[15] = Make('ScrollingFrame', {LayoutOrder = 0, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png", HorizontalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), CanvasPosition = Vector2.new(0.000000, 0.000000), MaxCanvasPosition = Vector2.new(0.000000, 0.000000), VerticalScrollBarInset = Enum.ScrollBarInset.None, BackgroundColor3 = Color3.fromRGB(15, 15, 15), PredictionMode = Enum.PredictionMode.Automatic, Selectable = true, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AbsoluteCanvasSize = Vector2.new(100.000000, 80.000000), BackgroundColor = BrickColor.new("Really black"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ScrollBarImageColor3 = Color3.fromRGB(128, 128, 128), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, SmoothScroll = true, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), ScrollingEnabled = true, BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png", HistoryId = "00000000000000000000000000000000", className = "ScrollingFrame", ClassName = "ScrollingFrame", Interactable = true, AbsoluteWindowSize = Vector2.new(100.000000, 80.000000), MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ClippedRect = Rect.new(215.000000, 5.000000, 315.000000, 85.000000), archivable = true, ActiveQueryNames = "", ScrollingDirection = Enum.ScrollingDirection.XY, SizeConstraint = Enum.SizeConstraint.RelativeXY, VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right, CanvasSize = UDim2.new(0.000000, 0, 0.000000, 0), Tags = "", ScrollRate = 1, SourceAssetId = -1, Sandboxed = false, DraggingScrollBar = Enum.DraggingScrollBar.None, PropertyStatusStudio = Enum.PropertyStatus.Ok, RobloxLocked = false, Transparency = 1, TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png", SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, Name = "ContentFrame", HorizontalScrollBarInset = Enum.ScrollBarInset.None, ScrollVelocity = Vector2.new(0.000000, 0.000000), DefinesCapabilities = false, BorderMode = Enum.BorderMode.Outline, AutomaticCanvasSize = Enum.AutomaticSize.Y, GuiState = Enum.GuiState.Idle, DataCost = 18, AttributesSerialize = "", AnchorPoint = Vector2.new(0.000000, 0.000000), Archivable = true, TotalGroupScale = 1, ElasticBehavior = Enum.ElasticBehavior.WhenScrollable, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, AbsolutePosition = Vector2.new(215.000000, 5.000000), AutomaticSize = Enum.AutomaticSize.None, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(215.000000, 5.000000, 315.000000, 85.000000), AbsoluteSize = Vector2.new(100.000000, 80.000000), VerticalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScrollBarThickness = 5, numExpectedDirectChildren = 0, Visible = true, AutoLocalize = false, AbsoluteRotation = 0, MouseMovedConnectionCount = 0, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = true, ScrollBarImageTransparency = 0}, Obj[14])
    Obj[16] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[15])
    Obj[17] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 4), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 4), PaddingTop = UDim.new(0.000000, 4), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 4), HistoryId = "00000000000000000000000000000000"}, Obj[15])
    Obj[18] = Make('UIStroke', {PredictionMode = Enum.PredictionMode.Automatic, className = "UIStroke", BorderOffset = UDim.new(0.000000, 0), StrokeSizingMode = Enum.StrokeSizingMode.FixedSize, DataCost = 4, numExpectedDirectChildren = 0, AttributesReplicate = "", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, archivable = true, Attributes = "", UniqueId = "00000000000000000000000000000000", AttributesSerialize = "", ZIndex = 1, Archivable = true, SourceAssetId = -1, Enabled = true, Color = Color3.fromRGB(110, 110, 110), Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HistoryId = "00000000000000000000000000000000", Thickness = 1, Transparency = 0.20000000298023224, Name = "UIStroke", ClassName = "UIStroke", RobloxLocked = false, DefinesCapabilities = false, LineJoinMode = Enum.LineJoinMode.Round, BorderStrokePosition = Enum.BorderStrokePosition.Outer}, Obj[14])
    Obj[19] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 2), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[14])
    Obj[20] = Make('Frame', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 5, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(15, 15, 15), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Really black"), Size = UDim2.new(0.000000, 0, 0.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 26, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.07199999690055847, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(320.000000, 5.000000, 420.000000, 85.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.XY, Name = "Overlay", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(320.000000, 5.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(320.000000, 5.000000, 420.000000, 85.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.07199999690055847}, Obj[1])
    Obj[21] = Make('UIStroke', {PredictionMode = Enum.PredictionMode.Automatic, className = "UIStroke", BorderOffset = UDim.new(0.000000, 0), StrokeSizingMode = Enum.StrokeSizingMode.FixedSize, DataCost = 4, numExpectedDirectChildren = 0, AttributesReplicate = "", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, archivable = true, Attributes = "", UniqueId = "00000000000000000000000000000000", AttributesSerialize = "", ZIndex = 1, Archivable = true, SourceAssetId = -1, Enabled = true, Color = Color3.fromRGB(110, 110, 110), Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HistoryId = "00000000000000000000000000000000", Thickness = 1, Transparency = 0.20000000298023224, Name = "UIStroke", ClassName = "UIStroke", RobloxLocked = false, DefinesCapabilities = false, LineJoinMode = Enum.LineJoinMode.Round, BorderStrokePosition = Enum.BorderStrokePosition.Outer}, Obj[20])
    Obj[22] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 4), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 4), PaddingTop = UDim.new(0.000000, 4), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 4), HistoryId = "00000000000000000000000000000000"}, Obj[20])
    Obj[23] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[20])
    Obj[24] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 2), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[20])
    Obj[25] = Make('TextLabel', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 1, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", LocalizedText = "Label", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(0.000000, 0.000000), TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 5, 0.000000, 5), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Font = Enum.Font.Code, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, className = "TextLabel", HistoryId = "00000000000000000000000000000000", ClassName = "TextLabel", FontSize = Enum.FontSize.Size14, AbsoluteRotation = 0, OpenTypeFeaturesError = "", Interactable = true, DataCost = 15, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", Selectable = false, SizeConstraint = Enum.SizeConstraint.RelativeXY, SourceAssetId = -1, Name = "Label", RichText = true, AutoLocalize = false, Sandboxed = false, DefinesCapabilities = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, AttributesSerialize = "", ContentText = "Label", Transparency = 1, Archivable = true, SelectionOrder = 0, TotalGroupScale = 1, MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Institutional white"), Confidential = false, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, BorderMode = Enum.BorderMode.Outline, TextTransparency = 0, GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AnchorPoint = Vector2.new(0.000000, 0.000000), RawRect2D = Rect.new(425.000000, 5.000000, 525.000000, 85.000000), Localize = false, IsNotOccluded = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), Visible = true, AutomaticSize = Enum.AutomaticSize.XY, LineHeight = 1, MouseEnterConnectionCount = 0, AbsoluteSize = Vector2.new(100.000000, 80.000000), TextFits = false, TextColor3 = Color3.fromRGB(255, 255, 255), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "Label", numExpectedDirectChildren = 0, MouseMovedConnectionCount = 0, LocalizationMatchedSourceText = "", AbsolutePosition = Vector2.new(425.000000, 5.000000), BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 13}, Obj[1])
    Obj[26] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 0), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 0), PaddingTop = UDim.new(0.000000, 0), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 0), HistoryId = "00000000000000000000000000000000"}, Obj[25])
    Obj[27] = Make('TextButton', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "Button", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(0.000000, 0.000000), TextTransparency = 1, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 150, 0.000000, 150), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "Viewport", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Legacy, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "", FontSize = Enum.FontSize.Size8, OpenTypeFeaturesError = "", Interactable = true, DataCost = 35, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(530.000000, 5.000000, 630.000000, 85.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = true, ContentText = "Button", Transparency = 1, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(-inf, -inf, inf, inf), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Black"), AbsoluteSize = Vector2.new(100.000000, 80.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Outline, AbsolutePosition = Vector2.new(530.000000, 5.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(0.000000, 0.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1, Selected = false, AutomaticSize = Enum.AutomaticSize.None, MouseWheelForwardConnectionCount = 0, Selectable = false, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(27, 42, 53), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "Button", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 8}, Obj[1])
    Obj[28] = Make('UIStroke', {PredictionMode = Enum.PredictionMode.Automatic, className = "UIStroke", BorderOffset = UDim.new(0.000000, 0), StrokeSizingMode = Enum.StrokeSizingMode.FixedSize, DataCost = 4, numExpectedDirectChildren = 0, AttributesReplicate = "", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, archivable = true, Attributes = "", UniqueId = "00000000000000000000000000000000", AttributesSerialize = "", ZIndex = 1, Archivable = true, SourceAssetId = -1, Enabled = true, Color = Color3.fromRGB(135, 135, 148), Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HistoryId = "00000000000000000000000000000000", Thickness = 1, Transparency = 0.699999988079071, Name = "UIStroke", ClassName = "UIStroke", RobloxLocked = false, DefinesCapabilities = false, LineJoinMode = Enum.LineJoinMode.Round, BorderStrokePosition = Enum.BorderStrokePosition.Outer}, Obj[27])
    Obj[29] = Make('ViewportFrame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 1, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, Selectable = false, LightDirection = Vector3.new(-1.000000, -1.000000, -1.000000), Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Ambient = Color3.fromRGB(255, 255, 255), Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 20, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, IsMirrored = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, className = "ViewportFrame", ClassName = "ViewportFrame", Archivable = true, archivable = true, BorderMode = Enum.BorderMode.Outline, ClippedRect = Rect.new(-inf, -inf, inf, inf), GuiState = Enum.GuiState.Idle, SourceAssetId = -1, AnchorPoint = Vector2.new(0.000000, 0.000000), Name = "Viewport", ImageColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, AutoLocalize = false, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, LayoutOrder = 0, AttributesSerialize = "", AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(530.000000, 5.000000), numExpectedDirectChildren = 0, AbsoluteRotation = 0, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, LightColor = Color3.fromRGB(255, 255, 255), RawRect2D = Rect.new(530.000000, 5.000000, 630.000000, 85.000000), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, CameraFieldOfView = 1.2217305898666382}, Obj[27])
    Obj[30] = Make('WorldModel', {NeedsPivotMigration = false, Scale = 1, DataCost = 10, AttributesReplicate = "", PhysicsStepTime = 0, archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "WorldModel", LevelOfDetail = Enum.ModelLevelOfDetail.Automatic, SlimHash = "", SourceAssetId = -1, AttributesSerialize = "", ScaleFactor = 1, PredictionMode = Enum.PredictionMode.Automatic, Attributes = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, HistoryId = "00000000000000000000000000000000", Archivable = true, ModelMeshData = "", Name = "WorldModel", className = "WorldModel", RobloxLocked = false, DefinesCapabilities = false, ModelMeshSize = Vector3.new(0.000000, 0.000000, 0.000000), ModelStreamingMode = Enum.ModelStreamingMode.Default}, Obj[29])
    Obj[31] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(41, 74, 122), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Dark Royal blue"), Size = UDim2.new(0.650000, 0, 0.000000, 19), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 58, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.46000000834465027, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Slider", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(635.000000, 5.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(635.000000, 5.000000, 735.000000, 85.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.46000000834465027}, Obj[1])
    Obj[32] = Make('TextButton', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "0", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(0.000000, 0.000000), TextTransparency = 1, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "", BorderColor = BrickColor.new("Dark grey"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Dark Royal blue"), Size = UDim2.new(1.000000, 0, 1.000000, 0), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "Track", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(110, 110, 125), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Code, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "", FontSize = Enum.FontSize.Size14, OpenTypeFeaturesError = "", Interactable = true, DataCost = 44, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(635.000000, 5.000000, 735.000000, 85.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, ContentText = "0", Transparency = 1, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(-inf, -inf, inf, inf), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Institutional white"), AbsoluteSize = Vector2.new(100.000000, 80.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Inset, AbsolutePosition = Vector2.new(635.000000, 5.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(0.000000, 0.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1, Selected = false, AutomaticSize = Enum.AutomaticSize.None, MouseWheelForwardConnectionCount = 0, Selectable = true, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(255, 255, 255), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "0", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(41, 74, 122), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 13}, Obj[31])
    Obj[33] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(66, 150, 250), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Medium blue"), Size = UDim2.new(0.000000, 10, 1.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.500000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 14, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.30000001192092896, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.500000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Grab", Localize = false, AbsoluteSize = Vector2.new(10.000000, 76.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(637.000000, 7.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(637.000000, 7.000000, 647.000000, 83.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.30000001192092896}, Obj[32])
    Obj[34] = Make('UISizeConstraint', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", MinSize = Vector2.new(10.000000, 0.000000), Archivable = true, className = "UISizeConstraint", MaxSize = Vector2.new(inf, inf), Tags = "", Sandboxed = false, numExpectedDirectChildren = 0, PropertyStatusStudio = Enum.PropertyStatus.Ok, archivable = true, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, Name = "UISizeConstraint", ClassName = "UISizeConstraint", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[33])
    Obj[35] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 2), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 2), PaddingTop = UDim.new(0.000000, 2), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 2), HistoryId = "00000000000000000000000000000000"}, Obj[32])
    Obj[36] = Make('TextLabel', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 2, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", LocalizedText = "0", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(0.000000, 0.000000), TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Medium stone grey"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Font = Enum.Font.Code, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, className = "TextLabel", HistoryId = "00000000000000000000000000000000", ClassName = "TextLabel", FontSize = Enum.FontSize.Size14, AbsoluteRotation = 0, OpenTypeFeaturesError = "", Interactable = true, DataCost = 11, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", Selectable = false, SizeConstraint = Enum.SizeConstraint.RelativeXY, SourceAssetId = -1, Name = "ValueText", RichText = false, AutoLocalize = false, Sandboxed = false, DefinesCapabilities = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, AttributesSerialize = "", ContentText = "0", Transparency = 1, Archivable = true, SelectionOrder = 0, TotalGroupScale = 1, MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Institutional white"), Confidential = false, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, BorderMode = Enum.BorderMode.Outline, TextTransparency = 0, GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AnchorPoint = Vector2.new(0.000000, 0.000000), RawRect2D = Rect.new(637.000000, 7.000000, 733.000000, 83.000000), Localize = false, IsNotOccluded = true, ClippedRect = Rect.new(637.000000, 7.000000, 733.000000, 83.000000), Visible = true, AutomaticSize = Enum.AutomaticSize.None, LineHeight = 1, MouseEnterConnectionCount = 0, AbsoluteSize = Vector2.new(96.000000, 76.000000), TextFits = false, TextColor3 = Color3.fromRGB(255, 255, 255), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "0", numExpectedDirectChildren = 0, MouseMovedConnectionCount = 0, LocalizationMatchedSourceText = "", AbsolutePosition = Vector2.new(637.000000, 7.000000), BackgroundColor3 = Color3.fromRGB(163, 162, 165), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 13}, Obj[32])
    Obj[37] = Make('UIDragDetector', {MinDragAngle = 0, SelectionModeRotateSpeed = 90, DataCost = 4, MinDragTranslation = UDim2.new(0.000000, 0, 0.000000, 0), AttributesReplicate = "", SelectionModeDragSpeed = UDim2.new(0.000000, 300, 0.000000, 300), DragRotation = 0, ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset, archivable = true, DragSpace = Enum.UIDragDetectorDragSpace.Parent, DragStyle = Enum.UIDragDetectorDragStyle.Scriptable, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, MaxDragTranslation = UDim2.new(0.000000, 0, 0.000000, 0), DragAxis = Vector2.new(1.000000, 0.000000), DragRelativity = Enum.UIDragDetectorDragRelativity.Absolute, ClassName = "UIDragDetector", CursorIcon = "", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", BoundingBehavior = Enum.UIDragDetectorBoundingBehavior.Automatic, AttributesSerialize = "", MaxDragAngle = 0, HistoryId = "00000000000000000000000000000000", UIDragSpeedAxisMapping = Enum.UIDragSpeedAxisMapping.XY, UniqueId = "00000000000000000000000000000000", RobloxLocked = false, numExpectedDirectChildren = 0, Enabled = false, Name = "UIDragDetector", className = "UIDragDetector", DragUDim2 = UDim2.new(0.000000, 0, 0.000000, 0), DefinesCapabilities = false, Archivable = true, ActivatedCursorIcon = ""}, Obj[32])
    Obj[38] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 2), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[31])
    Obj[39] = Make('TextButton', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "â—¢", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(0.000000, 0.000000), TextTransparency = 0.6000000238418579, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Medium stone grey"), Size = UDim2.new(0.000000, 17, 0.000000, 17), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "ResizeGrab", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Legacy, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(1.000000, 0, 1.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "", FontSize = Enum.FontSize.Size18, OpenTypeFeaturesError = "", Interactable = true, DataCost = 15, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(5.000000, 90.000000, 105.000000, 170.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, ContentText = "â—¢", Transparency = 1, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(-inf, -inf, inf, inf), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Cyan"), AbsoluteSize = Vector2.new(100.000000, 80.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Outline, AbsolutePosition = Vector2.new(5.000000, 90.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(1.000000, 1.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1.100000023841858, Selected = false, AutomaticSize = Enum.AutomaticSize.None, MouseWheelForwardConnectionCount = 0, Selectable = false, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(60, 150, 250), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "â—¢", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(163, 162, 165), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 17}, Obj[1])
    Obj[40] = Make('UIDragDetector', {MinDragAngle = 0, SelectionModeRotateSpeed = 90, DataCost = 4, MinDragTranslation = UDim2.new(0.000000, 0, 0.000000, 0), AttributesReplicate = "", SelectionModeDragSpeed = UDim2.new(0.000000, 300, 0.000000, 300), DragRotation = 0, ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset, archivable = true, DragSpace = Enum.UIDragDetectorDragSpace.Parent, DragStyle = Enum.UIDragDetectorDragStyle.Scriptable, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, MaxDragTranslation = UDim2.new(0.000000, 0, 0.000000, 0), DragAxis = Vector2.new(1.000000, 0.000000), DragRelativity = Enum.UIDragDetectorDragRelativity.Absolute, ClassName = "UIDragDetector", CursorIcon = "", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", BoundingBehavior = Enum.UIDragDetectorBoundingBehavior.Automatic, AttributesSerialize = "", MaxDragAngle = 0, HistoryId = "00000000000000000000000000000000", UIDragSpeedAxisMapping = Enum.UIDragSpeedAxisMapping.XY, UniqueId = "00000000000000000000000000000000", RobloxLocked = false, numExpectedDirectChildren = 0, Enabled = false, Name = "UIDragDetector", className = "UIDragDetector", DragUDim2 = UDim2.new(0.000000, 0, 0.000000, 0), DefinesCapabilities = false, Archivable = true, ActivatedCursorIcon = ""}, Obj[39])
    Obj[41] = Make('TextButton', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(0.000000, 0.000000), TextTransparency = 0, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Medium blue"), Size = UDim2.new(0.000000, 17, 0.000000, 17), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "RadioButton", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Legacy, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(1.000000, 0, 0.500000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "", FontSize = Enum.FontSize.Size8, OpenTypeFeaturesError = "", Interactable = true, DataCost = 25, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(110.000000, 90.000000, 210.000000, 170.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, ContentText = "", Transparency = 1, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(-inf, -inf, inf, inf), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Institutional white"), AbsoluteSize = Vector2.new(100.000000, 80.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Outline, AbsolutePosition = Vector2.new(110.000000, 90.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(0.000000, 0.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1, Selected = false, AutomaticSize = Enum.AutomaticSize.None, MouseWheelForwardConnectionCount = 0, Selectable = true, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(255, 255, 255), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(66, 150, 250), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 8}, Obj[1])
    Obj[42] = Make('ImageLabel', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(163, 162, 165), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, AbsoluteRotation = 0, Image = "", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Black"), BackgroundColor = BrickColor.new("Medium stone grey"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.500000, 0, 0.500000, 0), SliceScale = 1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 10, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScaleType = Enum.ScaleType.Fit, AutoLocalize = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, className = "ImageLabel", Transparency = 1, ClassName = "ImageLabel", SelectionOrder = 0, LayoutOrder = 0, MouseWheelBackwardConnectionCount = 0, archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), SourceAssetId = -1, RobloxLocked = false, BorderMode = Enum.BorderMode.Outline, Name = "Icon", GuiState = Enum.GuiState.Idle, AttributesSerialize = "", AnchorPoint = Vector2.new(0.500000, 0.500000), ImageColor3 = Color3.fromRGB(255, 255, 255), Attributes = "", ImageRectSize = Vector2.new(0.000000, 0.000000), SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Archivable = true, AutomaticSize = Enum.AutomaticSize.None, TotalGroupScale = 1, MouseMovedConnectionCount = 0, AbsoluteSize = Vector2.new(96.000000, 76.000000), IsNotOccluded = true, Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(112.000000, 92.000000), numExpectedDirectChildren = 0, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, Selectable = false, ResampleMode = Enum.ResamplerMode.Default, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(112.000000, 92.000000, 208.000000, 168.000000), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, ImageRectOffset = Vector2.new(0.000000, 0.000000)}, Obj[41])
    Obj[43] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 2), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 2), PaddingTop = UDim.new(0.000000, 2), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 2), HistoryId = "00000000000000000000000000000000"}, Obj[41])
    Obj[44] = Make('Folder', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 12, AttributesReplicate = "", Attributes = "", Archivable = true, className = "Folder", Name = "Container", Tags = "", Sandboxed = false, numExpectedDirectChildren = 0, PropertyStatusStudio = Enum.PropertyStatus.Ok, archivable = true, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, ReplicatedGuiInsertionOrder = 2147483647, ClassName = "Folder", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[1])
    Obj[45] = Make('ScreenGui', {SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, IgnoreGuiInset = false, AttributesReplicate = "", ActiveQueryNames = "", DisplayOrder = 100, archivable = true, ReplicatedInsertionOrder = 2147483647, Localize = false, AutoLocalize = false, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClipToDeviceSafeArea = true, PredictionMode = Enum.PredictionMode.Automatic, className = "ScreenGui", SafeAreaCompatibility = Enum.SafeAreaCompatibility.None, ClassName = "ScreenGui", AbsoluteRotation = 0, SourceAssetId = -1, ResetOnSpawn = false, UniqueId = "00000000000000000000000000000000", RobloxLocked = false, Attributes = "", Name = "Windows", SelectionBehaviorDown = Enum.SelectionBehavior.Escape, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, Archivable = true, RawRect2D = Rect.new(0.000000, 0.000000, 800.000000, 600.000000), Enabled = true, AbsoluteSize = Vector2.new(800.000000, 600.000000), ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets, TotalGroupScale = 1, DataCost = 4, AbsolutePosition = Vector2.new(0.000000, 0.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", OnTopOfCoreBlur = false, IsNotOccluded = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), ZIndexBehavior = Enum.ZIndexBehavior.Sibling, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, DefinesCapabilities = false, SelectionGroup = false, HistoryId = "00000000000000000000000000000000"}, Obj[44])
    Obj[46] = Make('ScreenGui', {SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, IgnoreGuiInset = true, AttributesReplicate = "", ActiveQueryNames = "", DisplayOrder = 101, archivable = true, ReplicatedInsertionOrder = 2147483647, Localize = false, AutoLocalize = false, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClipToDeviceSafeArea = true, PredictionMode = Enum.PredictionMode.Automatic, className = "ScreenGui", SafeAreaCompatibility = Enum.SafeAreaCompatibility.None, ClassName = "ScreenGui", AbsoluteRotation = 0, SourceAssetId = -1, ResetOnSpawn = false, UniqueId = "00000000000000000000000000000000", RobloxLocked = false, Attributes = "", Name = "Overlays", SelectionBehaviorDown = Enum.SelectionBehavior.Escape, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, Archivable = true, RawRect2D = Rect.new(0.000000, 0.000000, 800.000000, 600.000000), Enabled = true, AbsoluteSize = Vector2.new(800.000000, 600.000000), ScreenInsets = Enum.ScreenInsets.None, TotalGroupScale = 1, DataCost = 4, AbsolutePosition = Vector2.new(0.000000, 0.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", OnTopOfCoreBlur = false, IsNotOccluded = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), ZIndexBehavior = Enum.ZIndexBehavior.Sibling, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, DefinesCapabilities = false, SelectionGroup = false, HistoryId = "00000000000000000000000000000000"}, Obj[44])
    Obj[47] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 0.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 14, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(215.000000, 90.000000, 315.000000, 170.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "List", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(215.000000, 90.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(215.000000, 90.000000, 315.000000, 170.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[48] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = true, HistoryId = "00000000000000000000000000000000"}, Obj[47])
    Obj[49] = Make('TextButton', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "\000\000\000\
\000\000\000Background\000\000\000Tickbox", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(-nan(ind), -nan(ind)), TextTransparency = 1, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "\000\000\000\
\000\000\000Background\000\000\000Tickbox", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Medium stone grey"), Size = UDim2.new(0.000000, 10, 0.000000, 0), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "CheckBox", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Legacy, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "\000\000\000\
\000\000\000Background\000\000\000Tickbox", FontSize = Enum.FontSize.Size8, OpenTypeFeaturesError = "", Interactable = true, DataCost = 47, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(320.000000, 90.000000, 420.000000, 170.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, ContentText = "", Transparency = 1, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(-inf, -inf, inf, inf), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Black"), AbsoluteSize = Vector2.new(100.000000, 80.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Outline, AbsolutePosition = Vector2.new(320.000000, 90.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(0.000000, 0.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1, Selected = false, AutomaticSize = Enum.AutomaticSize.XY, MouseWheelForwardConnectionCount = 0, Selectable = true, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(27, 42, 53), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(163, 162, 165), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 8, _Attributes = {['Background'] = "Tickbox"}}, Obj[1])
    Obj[50] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(19.000000, 19.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[49])
    Obj[51] = Make('ImageButton', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, BackgroundColor3 = Color3.fromRGB(41, 74, 122), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, Selectable = false, Image = "", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Dark grey"), BackgroundColor = BrickColor.new("Dark Royal blue"), Size = UDim2.new(0.000000, 19, 0.000000, 19), HoverImage = "", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(110, 110, 125), DragBeginConnectionCount = 0, Rotation = 0, className = "ImageButton", BackgroundTransparency = 0.46000000834465027, Position = UDim2.new(0.000000, 0, 0.000000, 0), SliceScale = 1, DefinesCapabilities = false, ClassName = "ImageButton", HistoryId = "00000000000000000000000000000000", AbsoluteSize = Vector2.new(19.000000, 19.000000), MouseButton2ClickConnectionCount = 0, archivable = true, ResampleMode = Enum.ResamplerMode.Default, Interactable = true, DataCost = 32, MouseLeaveConnectionCount = 0, MouseButton1UpConnectionCount = 0, Tags = "", ActiveQueryNames = "", SourceAssetId = -1, SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), MouseButton2DownConnectionCount = 0, ScaleType = Enum.ScaleType.Stretch, AutoLocalize = false, RobloxLocked = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, Name = "Tickbox", Transparency = 0.46000000834465027, SelectionOrder = 0, AttributesSerialize = "", MouseWheelBackwardConnectionCount = 0, Attributes = "", Archivable = true, TotalGroupScale = 1, ImageRectOffset = Vector2.new(0.000000, 0.000000), SelectionBehaviorUp = Enum.SelectionBehavior.Escape, BorderMode = Enum.BorderMode.Inset, MouseButton1DownConnectionCount = 0, GuiState = Enum.GuiState.Idle, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AnchorPoint = Vector2.new(0.000000, 0.000000), RawRect2D = Rect.new(320.000000, 120.500000, 339.000000, 139.500000), Localize = false, ImageRectSize = Vector2.new(0.000000, 0.000000), IsNotOccluded = true, Selected = false, AutomaticSize = Enum.AutomaticSize.None, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 1, MouseButton2UpConnectionCount = 0, AbsoluteRotation = 0, MouseEnterConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(320.000000, 120.500000), numExpectedDirectChildren = 0, PressedImage = "", MouseButton1ClickConnectionCount = 0, MouseMovedConnectionCount = 0, ImageColor3 = Color3.fromRGB(66, 150, 250), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, Style = Enum.ButtonStyle.Custom}, Obj[49])
    Obj[52] = Make('ImageLabel', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 1, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(66, 150, 250), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, AbsoluteRotation = 0, Image = "", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Black"), BackgroundColor = BrickColor.new("Medium blue"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.500000, 0, 0.500000, 0), SliceScale = 1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = false, DataCost = 14, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScaleType = Enum.ScaleType.Fit, AutoLocalize = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, className = "ImageLabel", Transparency = 1, ClassName = "ImageLabel", SelectionOrder = 0, LayoutOrder = 1, MouseWheelBackwardConnectionCount = 0, archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), SourceAssetId = -1, RobloxLocked = false, BorderMode = Enum.BorderMode.Outline, Name = "Tick", GuiState = Enum.GuiState.NonInteractable, AttributesSerialize = "", AnchorPoint = Vector2.new(0.500000, 0.500000), ImageColor3 = Color3.fromRGB(66, 150, 250), Attributes = "", ImageRectSize = Vector2.new(0.000000, 0.000000), SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Archivable = true, AutomaticSize = Enum.AutomaticSize.None, TotalGroupScale = 1, MouseMovedConnectionCount = 0, AbsoluteSize = Vector2.new(13.000000, 13.000000), IsNotOccluded = true, Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(323.000000, 123.500000), numExpectedDirectChildren = 0, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, Selectable = false, ResampleMode = Enum.ResamplerMode.Default, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(323.000000, 123.500000, 336.000000, 136.500000), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, ImageRectOffset = Vector2.new(0.000000, 0.000000)}, Obj[51])
    Obj[53] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(1.000000, 0), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "UICorner", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[52])
    Obj[54] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 3), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 3), PaddingTop = UDim.new(0.000000, 3), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 3), HistoryId = "00000000000000000000000000000000"}, Obj[51])
    Obj[55] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 2), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[51])
    Obj[56] = Make('TextButton', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.SplitWord, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "Skibidi toliet", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(-nan(ind), -nan(ind)), TextTransparency = 0, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Medium blue"), Size = UDim2.new(0.000000, 10, 0.000000, 19), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "Button", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Unknown, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(0.185185, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "", FontSize = Enum.FontSize.Size14, OpenTypeFeaturesError = "", Interactable = true, DataCost = 19, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 0.30000001192092896, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(425.000000, 90.000000, 525.000000, 170.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, ContentText = "Skibidi toliet", Transparency = 0.30000001192092896, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(-inf, -inf, inf, inf), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Institutional white"), AbsoluteSize = Vector2.new(100.000000, 80.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Outline, AbsolutePosition = Vector2.new(425.000000, 90.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(0.000000, 0.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1, Selected = false, AutomaticSize = Enum.AutomaticSize.XY, MouseWheelForwardConnectionCount = 0, Selectable = true, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(255, 255, 255), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "Skibidi toliet", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(66, 150, 250), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 13}, Obj[1])
    Obj[57] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 3), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 4), PaddingTop = UDim.new(0.000000, 3), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 4), HistoryId = "00000000000000000000000000000000"}, Obj[56])
    Obj[58] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 2), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[56])
    Obj[59] = Make('ImageButton', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, BackgroundColor3 = Color3.fromRGB(66, 150, 250), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, Selectable = true, Image = "", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Black"), BackgroundColor = BrickColor.new("Medium blue"), Size = UDim2.new(0.000000, 100, 0.000000, 100), HoverImage = "", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, className = "ImageButton", BackgroundTransparency = 1, Position = UDim2.new(0.185185, 0, 0.000000, 0), SliceScale = 1, DefinesCapabilities = false, ClassName = "ImageButton", HistoryId = "00000000000000000000000000000000", AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseButton2ClickConnectionCount = 0, archivable = true, ResampleMode = Enum.ResamplerMode.Default, Interactable = true, DataCost = 18, MouseLeaveConnectionCount = 0, MouseButton1UpConnectionCount = 0, Tags = "", ActiveQueryNames = "", SourceAssetId = -1, SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), MouseButton2DownConnectionCount = 0, ScaleType = Enum.ScaleType.Stretch, AutoLocalize = false, RobloxLocked = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, Name = "Image", Transparency = 1, SelectionOrder = 0, AttributesSerialize = "", MouseWheelBackwardConnectionCount = 0, Attributes = "", Archivable = true, TotalGroupScale = 1, ImageRectOffset = Vector2.new(0.000000, 0.000000), SelectionBehaviorUp = Enum.SelectionBehavior.Escape, BorderMode = Enum.BorderMode.Outline, MouseButton1DownConnectionCount = 0, GuiState = Enum.GuiState.Idle, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AnchorPoint = Vector2.new(0.000000, 0.000000), RawRect2D = Rect.new(530.000000, 90.000000, 630.000000, 170.000000), Localize = false, ImageRectSize = Vector2.new(0.000000, 0.000000), IsNotOccluded = true, Selected = false, AutomaticSize = Enum.AutomaticSize.XY, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, MouseButton2UpConnectionCount = 0, AbsoluteRotation = 0, MouseEnterConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(530.000000, 90.000000), numExpectedDirectChildren = 0, PressedImage = "", MouseButton1ClickConnectionCount = 0, MouseMovedConnectionCount = 0, ImageColor3 = Color3.fromRGB(255, 255, 255), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, Style = Enum.ButtonStyle.Custom}, Obj[1])
    Obj[60] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 4), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 10), PaddingTop = UDim.new(0.000000, 4), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 10), HistoryId = "00000000000000000000000000000000"}, Obj[59])
    Obj[61] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 2), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[59])
    Obj[62] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 0.000000, 80), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 42, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(635.000000, 90.000000, 735.000000, 170.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "TabSelector", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(635.000000, 90.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(635.000000, 90.000000, 735.000000, 170.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[63] = Make('ScrollingFrame', {LayoutOrder = 2, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png", HorizontalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), CanvasPosition = Vector2.new(0.000000, 0.000000), MaxCanvasPosition = Vector2.new(0.000000, 0.000000), VerticalScrollBarInset = Enum.ScrollBarInset.None, BackgroundColor3 = Color3.fromRGB(139, 199, 101), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AbsoluteCanvasSize = Vector2.new(100.000000, 80.000000), BackgroundColor = BrickColor.new("Olivine"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ScrollBarImageColor3 = Color3.fromRGB(128, 128, 128), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, SmoothScroll = true, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), ScrollingEnabled = true, BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png", HistoryId = "00000000000000000000000000000000", className = "ScrollingFrame", ClassName = "ScrollingFrame", Interactable = true, AbsoluteWindowSize = Vector2.new(100.000000, 80.000000), MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ClippedRect = Rect.new(635.000000, 90.000000, 735.000000, 170.000000), archivable = true, ActiveQueryNames = "", ScrollingDirection = Enum.ScrollingDirection.XY, SizeConstraint = Enum.SizeConstraint.RelativeXY, VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right, CanvasSize = UDim2.new(0.000000, 0, 0.000000, 0), Tags = "", ScrollRate = 1, SourceAssetId = -1, Sandboxed = false, DraggingScrollBar = Enum.DraggingScrollBar.None, PropertyStatusStudio = Enum.PropertyStatus.Ok, RobloxLocked = false, Transparency = 1, TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png", SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, Name = "Body", HorizontalScrollBarInset = Enum.ScrollBarInset.None, ScrollVelocity = Vector2.new(0.000000, 0.000000), DefinesCapabilities = false, BorderMode = Enum.BorderMode.Outline, AutomaticCanvasSize = Enum.AutomaticSize.Y, GuiState = Enum.GuiState.Idle, DataCost = 28, AttributesSerialize = "", AnchorPoint = Vector2.new(0.000000, 0.000000), Archivable = true, TotalGroupScale = 1, ElasticBehavior = Enum.ElasticBehavior.Never, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, AbsolutePosition = Vector2.new(635.000000, 90.000000), AutomaticSize = Enum.AutomaticSize.None, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(635.000000, 90.000000, 735.000000, 170.000000), AbsoluteSize = Vector2.new(100.000000, 80.000000), VerticalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScrollBarThickness = 7, numExpectedDirectChildren = 0, Visible = true, AutoLocalize = false, AbsoluteRotation = 0, MouseMovedConnectionCount = 0, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = true, ScrollBarImageTransparency = 0}, Obj[62])
    Obj[64] = Make('Frame', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 0, 0.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 18, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(635.000000, 90.000000, 651.000000, 106.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.XY, Name = "PageTemplate", Localize = false, AbsoluteSize = Vector2.new(16.000000, 16.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(635.000000, 90.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(635.000000, 90.000000, 651.000000, 106.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[63])
    Obj[65] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[64])
    Obj[66] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 8), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 8), PaddingTop = UDim.new(0.000000, 8), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 8), HistoryId = "00000000000000000000000000000000"}, Obj[64])
    Obj[67] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(100.000000, 80.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 1), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.Fill, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 1), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 1), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.Fill, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[62])
    Obj[68] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 0.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 58, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(5.000000, 175.000000, 105.000000, 255.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "Table", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(5.000000, 175.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(5.000000, 175.000000, 105.000000, 255.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[69] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 1), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 0), PaddingTop = UDim.new(0.000000, 0), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 0), HistoryId = "00000000000000000000000000000000"}, Obj[68])
    Obj[70] = Make('UIStroke', {PredictionMode = Enum.PredictionMode.Automatic, className = "UIStroke", BorderOffset = UDim.new(0.000000, 0), StrokeSizingMode = Enum.StrokeSizingMode.FixedSize, DataCost = 4, numExpectedDirectChildren = 0, AttributesReplicate = "", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, archivable = true, Attributes = "", UniqueId = "00000000000000000000000000000000", AttributesSerialize = "", ZIndex = 1, Archivable = true, SourceAssetId = -1, Enabled = true, Color = Color3.fromRGB(135, 135, 148), Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HistoryId = "00000000000000000000000000000000", Thickness = 1, Transparency = 0.699999988079071, Name = "UIStroke", ClassName = "UIStroke", RobloxLocked = false, DefinesCapabilities = false, LineJoinMode = Enum.LineJoinMode.Round, BorderStrokePosition = Enum.BorderStrokePosition.Outer}, Obj[68])
    Obj[71] = Make('Frame', {Visible = false, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = false, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(135, 135, 148), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Silver flip/flop"), Size = UDim2.new(1.000000, 0, 0.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 36, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(5.000000, 175.000000, 105.000000, 255.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "RowTemp", Localize = false, AbsoluteSize = Vector2.new(100.000000, 0.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(5.000000, 175.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(5.000000, 175.000000, 105.000000, 175.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[68])
    Obj[72] = Make('Frame', {Visible = false, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = false, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 0, 0.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 22, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(1.000000, 173.000000, 1.000000, 173.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "ColumnTemp", Localize = false, AbsoluteSize = Vector2.new(0.000000, 0.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(5.000000, 175.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(5.000000, 175.000000, 5.000000, 175.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[71])
    Obj[73] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[72])
    Obj[74] = Make('UIStroke', {PredictionMode = Enum.PredictionMode.Automatic, className = "UIStroke", BorderOffset = UDim.new(0.000000, 0), StrokeSizingMode = Enum.StrokeSizingMode.FixedSize, DataCost = 4, numExpectedDirectChildren = 0, AttributesReplicate = "", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, archivable = true, Attributes = "", UniqueId = "00000000000000000000000000000000", AttributesSerialize = "", ZIndex = 1, Archivable = true, SourceAssetId = -1, Enabled = true, Color = Color3.fromRGB(135, 135, 148), Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HistoryId = "00000000000000000000000000000000", Thickness = 0.800000011920929, Transparency = 0.699999988079071, Name = "UIStroke", ClassName = "UIStroke", RobloxLocked = false, DefinesCapabilities = false, LineJoinMode = Enum.LineJoinMode.Round, BorderStrokePosition = Enum.BorderStrokePosition.Outer}, Obj[72])
    Obj[75] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 2), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 4), PaddingTop = UDim.new(0.000000, 2), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 4), HistoryId = "00000000000000000000000000000000"}, Obj[72])
    Obj[76] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 1), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.Fill, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 1), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 1), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.Fill, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[71])
    Obj[77] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 1), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 1), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 1), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[68])
    Obj[78] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(163, 162, 165), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Medium stone grey"), Size = UDim2.new(1.000000, 0, 0.000000, 2), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 34, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(110.000000, 175.000000, 210.000000, 255.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "SeparatorText", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(110.000000, 175.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(110.000000, 175.000000, 210.000000, 255.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[79] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(112.000000, 2.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 0), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 0), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 0), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[78])
    Obj[80] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(110, 110, 128), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Dark grey"), Size = UDim2.new(0.000000, 12, 0.000000, 2), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 10, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.5, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(1.000000, 0.500000), archivable = true, ClippedRect = Rect.new(110.000000, 175.000000, 210.000000, 255.000000), LayoutOrder = 1, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Left", Localize = false, AbsoluteSize = Vector2.new(12.000000, 2.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(110.000000, 214.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(110.000000, 214.000000, 122.000000, 216.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.5}, Obj[78])
    Obj[81] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(110, 110, 128), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Dark grey"), Size = UDim2.new(1.000000, 0, 0.000000, 2), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 10, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.5, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(1.000000, 0.500000), archivable = true, ClippedRect = Rect.new(110.000000, 175.000000, 210.000000, 255.000000), LayoutOrder = 3, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Right", Localize = false, AbsoluteSize = Vector2.new(100.000000, 2.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(122.000000, 214.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(122.000000, 214.000000, 222.000000, 216.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.5}, Obj[78])
    Obj[82] = Make('ScrollingFrame', {LayoutOrder = 0, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png", HorizontalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), CanvasPosition = Vector2.new(0.000000, 0.000000), MaxCanvasPosition = Vector2.new(0.000000, 0.000000), VerticalScrollBarInset = Enum.ScrollBarInset.None, BackgroundColor3 = Color3.fromRGB(139, 199, 101), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AbsoluteCanvasSize = Vector2.new(100.000000, 80.000000), BackgroundColor = BrickColor.new("Olivine"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ScrollBarImageColor3 = Color3.fromRGB(128, 128, 128), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, SmoothScroll = true, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), ScrollingEnabled = true, BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png", HistoryId = "00000000000000000000000000000000", className = "ScrollingFrame", ClassName = "ScrollingFrame", Interactable = true, AbsoluteWindowSize = Vector2.new(100.000000, 80.000000), MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ClippedRect = Rect.new(215.000000, 175.000000, 315.000000, 255.000000), archivable = true, ActiveQueryNames = "", ScrollingDirection = Enum.ScrollingDirection.XY, SizeConstraint = Enum.SizeConstraint.RelativeXY, VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right, CanvasSize = UDim2.new(0.000000, 0, 0.000000, 0), Tags = "", ScrollRate = 1, SourceAssetId = -1, Sandboxed = false, DraggingScrollBar = Enum.DraggingScrollBar.None, PropertyStatusStudio = Enum.PropertyStatus.Ok, RobloxLocked = false, Transparency = 1, TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png", SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, Name = "ScrollingCanvas", HorizontalScrollBarInset = Enum.ScrollBarInset.None, ScrollVelocity = Vector2.new(0.000000, 0.000000), DefinesCapabilities = false, BorderMode = Enum.BorderMode.Outline, AutomaticCanvasSize = Enum.AutomaticSize.Y, GuiState = Enum.GuiState.Idle, DataCost = 18, AttributesSerialize = "", AnchorPoint = Vector2.new(0.000000, 0.000000), Archivable = true, TotalGroupScale = 1, ElasticBehavior = Enum.ElasticBehavior.Never, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, AbsolutePosition = Vector2.new(215.000000, 175.000000), AutomaticSize = Enum.AutomaticSize.Y, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(215.000000, 175.000000, 315.000000, 255.000000), AbsoluteSize = Vector2.new(100.000000, 80.000000), VerticalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScrollBarThickness = 7, numExpectedDirectChildren = 0, Visible = true, AutoLocalize = false, AbsoluteRotation = 0, MouseMovedConnectionCount = 0, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = true, ScrollBarImageTransparency = 0}, Obj[1])
    Obj[83] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[82])
    Obj[84] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 8), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 8), PaddingTop = UDim.new(0.000000, 8), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 8), HistoryId = "00000000000000000000000000000000"}, Obj[82])
    Obj[85] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 0, 0.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 22, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(320.000000, 175.000000, 420.000000, 255.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.XY, Name = "Canvas", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(320.000000, 175.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(320.000000, 175.000000, 420.000000, 255.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[86] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[85])
    Obj[87] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 8), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 8), PaddingTop = UDim.new(0.000000, 8), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 8), HistoryId = "00000000000000000000000000000000"}, Obj[85])
    Obj[88] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 0), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[85])
    Obj[89] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 0.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 14, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(425.000000, 175.000000, 525.000000, 255.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "Row", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(425.000000, 175.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(425.000000, 175.000000, 525.000000, 255.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[90] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[89])
    Obj[91] = Make('TextButton', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "Button", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(0.000000, 0.000000), TextTransparency = 1, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Pearl"), Size = UDim2.new(1.000000, 0, 1.000000, 0), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "ModalEffect", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Legacy, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "", FontSize = Enum.FontSize.Size8, OpenTypeFeaturesError = "", Interactable = true, DataCost = 11, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(530.000000, 175.000000, 630.000000, 255.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, ContentText = "Button", Transparency = 1, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(-inf, -inf, inf, inf), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Black"), AbsoluteSize = Vector2.new(100.000000, 80.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Outline, AbsolutePosition = Vector2.new(530.000000, 175.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(0.000000, 0.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1, Selected = false, AutomaticSize = Enum.AutomaticSize.None, MouseWheelForwardConnectionCount = 0, Selectable = false, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(27, 42, 53), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "Button", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(230, 230, 230), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 8}, Obj[1])
    Obj[92] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 0.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 14, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(635.000000, 175.000000, 735.000000, 255.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "Group", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(635.000000, 175.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(635.000000, 175.000000, 735.000000, 255.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[93] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Start, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = true, HistoryId = "00000000000000000000000000000000"}, Obj[92])
    Obj[94] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(41, 74, 122), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Dark Royal blue"), Size = UDim2.new(0.650000, 0, 0.000000, 19), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 43, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "InputBox", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(5.000000, 260.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(5.000000, 260.000000, 105.000000, 340.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[95] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 33, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Frame", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(5.000000, 260.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(5.000000, 260.000000, 105.000000, 340.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[94])
    Obj[96] = Make('TextBox', {TextInputType = Enum.TextInputType.Default, TextWrapped = false, LineHeight = 1, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", SelectionStart = -1, DragStoppedConnectionCount = 0, LocalizationMatchedSourceText = "", ZIndex = 1, BorderSizePixel = 0, TextEditable = true, Draggable = false, ReturnKeyType = Enum.ReturnKeyType.Default, className = "TextBox", ManualFocusRelease = false, ClassName = "TextBox", DragBeginConnectionCount = 0, archivable = true, TextYAlignment = Enum.TextYAlignment.Center, TextSize = 13, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(0.000000, 0.000000), Tags = "", SourceAssetId = -1, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), ClippedRect = Rect.new(5.000000, 260.000000, 105.000000, 340.000000), Archivable = true, AbsoluteRotation = 0, Name = "Input", Attributes = "", BorderColor = BrickColor.new("Dark grey"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, PlaceholderText = "Text", BackgroundColor = BrickColor.new("Dark Royal blue"), ShowNativeInput = true, ShouldEmitUpAndDownArrowEvents = false, DefinesCapabilities = false, TextTruncate = Enum.TextTruncate.AtEnd, ClipsDescendants = true, BorderColor3 = Color3.fromRGB(110, 110, 125), ShouldEmitReturnEvents = false, AttributesSerialize = "", Rotation = 0, Font = Enum.Font.Code, BackgroundTransparency = 0.5, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, ClearTextOnFocus = false, TotalGroupScale = 1, HistoryId = "00000000000000000000000000000000", CursorPosition = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, OpenTypeFeaturesError = "", Interactable = true, DataCost = 19, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, LocalizationMatchIdentifier = "", ActiveQueryNames = "", ReplicatedInsertionOrder = 2147483647, SizeConstraint = Enum.SizeConstraint.RelativeXY, RawRect2D = Rect.new(5.000000, 260.000000, 105.000000, 340.000000), Localize = false, IsNotOccluded = true, RichText = false, AutoLocalize = false, Sandboxed = false, PlaceholderColor3 = Color3.fromRGB(128, 128, 128), PropertyStatusStudio = Enum.PropertyStatus.Ok, AbsolutePosition = Vector2.new(5.000000, 260.000000), ContentText = "", Transparency = 0.5, Visible = true, SelectionOrder = 0, Size = UDim2.new(1.000000, 0, 1.000000, 0), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Institutional white"), LayoutOrder = 1, BorderMode = Enum.BorderMode.Inset, Selectable = true, GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", AnchorPoint = Vector2.new(0.000000, 0.000000), MultiLine = false, FontSize = Enum.FontSize.Size14, TextDirection = Enum.TextDirection.Auto, MouseMovedConnectionCount = 0, ShouldEmitTabEvents = false, Confidential = false, LocalizedPlaceholderText = "Text", TextStrokeTransparency = 1, AbsoluteSize = Vector2.new(100.000000, 80.000000), TextFits = false, TextColor3 = Color3.fromRGB(255, 255, 255), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "", numExpectedDirectChildren = 0, OverlayNativeInput = false, TextTransparency = 0, BackgroundColor3 = Color3.fromRGB(41, 74, 122), AutomaticSize = Enum.AutomaticSize.None, TextXAlignment = Enum.TextXAlignment.Left, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, MaxVisibleGraphemes = -1}, Obj[95])
    Obj[97] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 3), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 5), PaddingTop = UDim.new(0.000000, 3), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 5), HistoryId = "00000000000000000000000000000000"}, Obj[96])
    Obj[98] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 2), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[96])
    Obj[99] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(100.000000, 80.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.Fill, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[95])
    Obj[100] = Make('ScrollingFrame', {LayoutOrder = 0, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png", HorizontalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), CanvasPosition = Vector2.new(0.000000, 0.000000), MaxCanvasPosition = Vector2.new(0.000000, 0.000000), VerticalScrollBarInset = Enum.ScrollBarInset.None, BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = true, Attributes = "", BorderColor = BrickColor.new("Silver flip/flop"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AbsoluteCanvasSize = Vector2.new(100.000000, 80.000000), BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 0.000000, 150), ScrollBarImageColor3 = Color3.fromRGB(128, 128, 128), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(135, 135, 148), DragBeginConnectionCount = 0, SmoothScroll = true, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), ScrollingEnabled = true, BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png", HistoryId = "00000000000000000000000000000000", className = "ScrollingFrame", ClassName = "ScrollingFrame", Interactable = true, AbsoluteWindowSize = Vector2.new(100.000000, 80.000000), MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ClippedRect = Rect.new(110.000000, 260.000000, 210.000000, 340.000000), archivable = true, ActiveQueryNames = "", ScrollingDirection = Enum.ScrollingDirection.XY, SizeConstraint = Enum.SizeConstraint.RelativeXY, VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right, CanvasSize = UDim2.new(0.000000, 0, 0.000000, 0), Tags = "", ScrollRate = 1, SourceAssetId = -1, Sandboxed = false, DraggingScrollBar = Enum.DraggingScrollBar.None, PropertyStatusStudio = Enum.PropertyStatus.Ok, RobloxLocked = false, Transparency = 1, TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png", SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, Name = "Console", HorizontalScrollBarInset = Enum.ScrollBarInset.None, ScrollVelocity = Vector2.new(0.000000, 0.000000), DefinesCapabilities = false, BorderMode = Enum.BorderMode.Outline, AutomaticCanvasSize = Enum.AutomaticSize.Y, GuiState = Enum.GuiState.Idle, DataCost = 74, AttributesSerialize = "", AnchorPoint = Vector2.new(0.000000, 0.000000), Archivable = true, TotalGroupScale = 1, ElasticBehavior = Enum.ElasticBehavior.Never, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, AbsolutePosition = Vector2.new(110.000000, 260.000000), AutomaticSize = Enum.AutomaticSize.None, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(110.000000, 260.000000, 210.000000, 340.000000), AbsoluteSize = Vector2.new(100.000000, 80.000000), VerticalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScrollBarThickness = 5, numExpectedDirectChildren = 0, Visible = true, AutoLocalize = false, AbsoluteRotation = 0, MouseMovedConnectionCount = 0, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = true, ScrollBarImageTransparency = 0}, Obj[1])
    Obj[101] = Make('TextBox', {TextInputType = Enum.TextInputType.Default, TextWrapped = true, LineHeight = 1, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", SelectionStart = -1, DragStoppedConnectionCount = 0, LocalizationMatchedSourceText = "", ZIndex = 13, BorderSizePixel = 1, TextEditable = true, Draggable = false, ReturnKeyType = Enum.ReturnKeyType.Default, className = "TextBox", ManualFocusRelease = false, ClassName = "TextBox", DragBeginConnectionCount = 0, archivable = true, TextYAlignment = Enum.TextYAlignment.Top, TextSize = 14, TextWrap = true, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(-nan(ind), -nan(ind)), Tags = "", SourceAssetId = -1, TextStrokeColor3 = Color3.fromRGB(255, 255, 255), ClippedRect = Rect.new(110.000000, 260.000000, 210.000000, 340.000000), Archivable = true, AbsoluteRotation = 0, Name = "Source", Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, PlaceholderText = "", BackgroundColor = BrickColor.new("Institutional white"), ShowNativeInput = true, ShouldEmitUpAndDownArrowEvents = false, DefinesCapabilities = false, TextTruncate = Enum.TextTruncate.None, ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), ShouldEmitReturnEvents = false, AttributesSerialize = "", Rotation = 0, Font = Enum.Font.Code, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, ClearTextOnFocus = false, TotalGroupScale = 1, HistoryId = "00000000000000000000000000000000", CursorPosition = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, OpenTypeFeaturesError = "", Interactable = true, DataCost = 41, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, LocalizationMatchIdentifier = "", ActiveQueryNames = "", ReplicatedInsertionOrder = 2147483647, SizeConstraint = Enum.SizeConstraint.RelativeXY, RawRect2D = Rect.new(120.000000, 260.000000, 210.000000, 270.000000), Localize = false, IsNotOccluded = true, RichText = false, AutoLocalize = false, Sandboxed = false, PlaceholderColor3 = Color3.fromRGB(204, 204, 204), PropertyStatusStudio = Enum.PropertyStatus.Ok, AbsolutePosition = Vector2.new(120.000000, 260.000000), ContentText = "Hello world!", Transparency = 1, Visible = true, SelectionOrder = 0, Size = UDim2.new(1.000000, 0, 0.000000, 0), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Institutional white"), LayoutOrder = 2, BorderMode = Enum.BorderMode.Outline, Selectable = true, GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", AnchorPoint = Vector2.new(0.000000, 0.000000), MultiLine = true, FontSize = Enum.FontSize.Size14, TextDirection = Enum.TextDirection.Auto, MouseMovedConnectionCount = 0, ShouldEmitTabEvents = false, Confidential = false, LocalizedPlaceholderText = "", TextStrokeTransparency = 1, AbsoluteSize = Vector2.new(90.000000, 10.000000), TextFits = false, TextColor3 = Color3.fromRGB(255, 255, 255), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "Hello world!", numExpectedDirectChildren = 0, OverlayNativeInput = false, TextTransparency = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AutomaticSize = Enum.AutomaticSize.Y, TextXAlignment = Enum.TextXAlignment.Left, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, MaxVisibleGraphemes = -1}, Obj[100])
    Obj[102] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 5), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 5), PaddingTop = UDim.new(0.000000, 5), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 5), HistoryId = "00000000000000000000000000000000"}, Obj[101])
    Obj[103] = Make('TextBox', {TextInputType = Enum.TextInputType.Default, TextWrapped = false, LineHeight = 1, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", SelectionStart = -1, DragStoppedConnectionCount = 0, LocalizationMatchedSourceText = "", ZIndex = 13, BorderSizePixel = 1, TextEditable = false, Draggable = false, ReturnKeyType = Enum.ReturnKeyType.Default, className = "TextBox", ManualFocusRelease = false, ClassName = "TextBox", DragBeginConnectionCount = 0, archivable = true, TextYAlignment = Enum.TextYAlignment.Top, TextSize = 14, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(-nan(ind), -nan(ind)), Tags = "", SourceAssetId = -1, TextStrokeColor3 = Color3.fromRGB(255, 255, 255), ClippedRect = Rect.new(110.000000, 260.000000, 210.000000, 340.000000), Archivable = true, AbsoluteRotation = 0, Name = "Highlight", Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, PlaceholderText = "", BackgroundColor = BrickColor.new("Institutional white"), ShowNativeInput = true, ShouldEmitUpAndDownArrowEvents = false, DefinesCapabilities = false, TextTruncate = Enum.TextTruncate.None, ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), ShouldEmitReturnEvents = false, AttributesSerialize = "", Rotation = 0, Font = Enum.Font.Code, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, ClearTextOnFocus = false, TotalGroupScale = 1, HistoryId = "00000000000000000000000000000000", CursorPosition = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, OpenTypeFeaturesError = "", Interactable = false, DataCost = 11, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, LocalizationMatchIdentifier = "", ActiveQueryNames = "", ReplicatedInsertionOrder = 2147483647, SizeConstraint = Enum.SizeConstraint.RelativeXY, RawRect2D = Rect.new(125.000000, 265.000000, 205.000000, 265.000000), Localize = false, IsNotOccluded = true, RichText = true, AutoLocalize = false, Sandboxed = false, PlaceholderColor3 = Color3.fromRGB(204, 204, 204), PropertyStatusStudio = Enum.PropertyStatus.Ok, AbsolutePosition = Vector2.new(125.000000, 265.000000), ContentText = "", Transparency = 1, Visible = true, SelectionOrder = 0, Size = UDim2.new(1.000000, 0, 0.000000, 0), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Institutional white"), LayoutOrder = 2, BorderMode = Enum.BorderMode.Outline, Selectable = false, GuiState = Enum.GuiState.NonInteractable, OpenTypeFeatures = "", AnchorPoint = Vector2.new(0.000000, 0.000000), MultiLine = true, FontSize = Enum.FontSize.Size14, TextDirection = Enum.TextDirection.Auto, MouseMovedConnectionCount = 0, ShouldEmitTabEvents = false, Confidential = false, LocalizedPlaceholderText = "", TextStrokeTransparency = 1, AbsoluteSize = Vector2.new(80.000000, 0.000000), TextFits = false, TextColor3 = Color3.fromRGB(255, 255, 255), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "", numExpectedDirectChildren = 0, OverlayNativeInput = false, TextTransparency = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AutomaticSize = Enum.AutomaticSize.Y, TextXAlignment = Enum.TextXAlignment.Left, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, MaxVisibleGraphemes = -1}, Obj[101])
    Obj[104] = Make('TextLabel', {LayoutOrder = 2, TextWrapped = true, TextDirection = Enum.TextDirection.Auto, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 13, BorderSizePixel = 1, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", LocalizedText = "", TextYAlignment = Enum.TextYAlignment.Top, TextWrap = true, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(0.000000, 0.000000), TextStrokeColor3 = Color3.fromRGB(255, 255, 255), Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 0.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Font = Enum.Font.Code, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, className = "TextLabel", HistoryId = "00000000000000000000000000000000", ClassName = "TextLabel", FontSize = Enum.FontSize.Size14, AbsoluteRotation = 0, OpenTypeFeaturesError = "", Interactable = false, DataCost = 11, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", Selectable = false, SizeConstraint = Enum.SizeConstraint.RelativeXY, SourceAssetId = -1, Name = "HighlightLine", RichText = true, AutoLocalize = false, Sandboxed = false, DefinesCapabilities = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, AttributesSerialize = "", ContentText = "", Transparency = 1, Archivable = true, SelectionOrder = 0, TotalGroupScale = 1, MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Institutional white"), Confidential = false, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, BorderMode = Enum.BorderMode.Outline, TextTransparency = 0, GuiState = Enum.GuiState.NonInteractable, OpenTypeFeatures = "", SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AnchorPoint = Vector2.new(0.000000, 0.000000), RawRect2D = Rect.new(125.000000, 265.000000, 205.000000, 265.000000), Localize = false, IsNotOccluded = true, ClippedRect = Rect.new(110.000000, 260.000000, 210.000000, 340.000000), Visible = true, AutomaticSize = Enum.AutomaticSize.Y, LineHeight = 1, MouseEnterConnectionCount = 0, AbsoluteSize = Vector2.new(80.000000, 0.000000), TextFits = false, TextColor3 = Color3.fromRGB(255, 255, 255), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "", numExpectedDirectChildren = 0, MouseMovedConnectionCount = 0, LocalizationMatchedSourceText = "", AbsolutePosition = Vector2.new(125.000000, 265.000000), BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 14}, Obj[101])
    Obj[105] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(80.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 0), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 0), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 0), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[101])
    Obj[106] = Make('TextLabel', {LayoutOrder = 1, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 14, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", LocalizedText = "1", TextYAlignment = Enum.TextYAlignment.Top, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(-nan(ind), -nan(ind)), TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 0, 0.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Font = Enum.Font.Code, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, className = "TextLabel", HistoryId = "00000000000000000000000000000000", ClassName = "TextLabel", FontSize = Enum.FontSize.Size14, AbsoluteRotation = 0, OpenTypeFeaturesError = "", Interactable = true, DataCost = 19, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", Selectable = false, SizeConstraint = Enum.SizeConstraint.RelativeXY, SourceAssetId = -1, Name = "Lines", RichText = false, AutoLocalize = false, Sandboxed = false, DefinesCapabilities = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, AttributesSerialize = "", ContentText = "1", Transparency = 1, Archivable = true, SelectionOrder = 0, TotalGroupScale = 1, MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Institutional white"), Confidential = false, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, BorderMode = Enum.BorderMode.Outline, TextTransparency = 0, GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AnchorPoint = Vector2.new(0.000000, 0.000000), RawRect2D = Rect.new(110.000000, 260.000000, 120.000000, 270.000000), Localize = false, IsNotOccluded = true, ClippedRect = Rect.new(110.000000, 260.000000, 210.000000, 340.000000), Visible = true, AutomaticSize = Enum.AutomaticSize.XY, LineHeight = 1, MouseEnterConnectionCount = 0, AbsoluteSize = Vector2.new(10.000000, 10.000000), TextFits = false, TextColor3 = Color3.fromRGB(255, 255, 255), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "1", numExpectedDirectChildren = 0, MouseMovedConnectionCount = 0, LocalizationMatchedSourceText = "", AbsolutePosition = Vector2.new(110.000000, 260.000000), BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 14}, Obj[100])
    Obj[107] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 5), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 5), PaddingTop = UDim.new(0.000000, 5), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 5), HistoryId = "00000000000000000000000000000000"}, Obj[106])
    Obj[108] = Make('UIFlexItem', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, GrowRatio = 0, AttributesReplicate = "", Attributes = "", FlexMode = Enum.UIFlexMode.None, Archivable = true, className = "UIFlexItem", ItemLineAlignment = Enum.ItemLineAlignment.Automatic, numExpectedDirectChildren = 0, ShrinkRatio = 0, Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", Tags = "", SourceAssetId = -1, Name = "UIFlexItem", ClassName = "UIFlexItem", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[106])
    Obj[109] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(100.000000, 10.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 0), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 0), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 0), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.Fill, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[100])
    Obj[110] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(163, 162, 165), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Medium stone grey"), Size = UDim2.new(1.000000, 0, 0.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 83, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "CollapsingHeader", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(215.000000, 260.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(215.000000, 260.000000, 315.000000, 340.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[111] = Make('TextButton', {LayoutOrder = 1, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(-nan(ind), -nan(ind)), TextTransparency = 0, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "", BorderColor = BrickColor.new("Dark grey"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Electric blue"), Size = UDim2.new(1.000000, 0, 0.000000, 19), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "TitleBar", ClipsDescendants = true, BorderColor3 = Color3.fromRGB(110, 110, 125), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Legacy, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "", FontSize = Enum.FontSize.Size8, OpenTypeFeaturesError = "", Interactable = true, DataCost = 69, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 0.699999988079071, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(215.000000, 260.000000, 315.000000, 279.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, ContentText = "", Transparency = 0.699999988079071, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(215.000000, 260.000000, 315.000000, 279.000000), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Black"), AbsoluteSize = Vector2.new(100.000000, 19.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Inset, AbsolutePosition = Vector2.new(215.000000, 260.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(0.000000, 0.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1, Selected = false, AutomaticSize = Enum.AutomaticSize.Y, MouseWheelForwardConnectionCount = 0, Selectable = true, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(27, 42, 53), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(58, 134, 221), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 8}, Obj[110])
    Obj[112] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(19.000000, 19.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.Fill, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[111])
    Obj[113] = Make('UIGradient', {PredictionMode = Enum.PredictionMode.Automatic, Color = ColorSequence.new({ColorSequenceKeypoint.new(0.000000, Color3.new(1.000000, 1.000000, 1.000000)), ColorSequenceKeypoint.new(1.000000, Color3.new(0.545098, 0.741176, 0.729412))}), DataCost = 4, AttributesReplicate = "", Attributes = "", className = "UIGradient", Enabled = false, numExpectedDirectChildren = 0, Archivable = true, archivable = true, Offset = Vector2.new(0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, Rotation = 0, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0.000000, 0.000000, 0.000000), NumberSequenceKeypoint.new(1.000000, 0.000000, 0.000000)}), Name = "UIGradient", ClassName = "UIGradient", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[111])
    Obj[114] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 0), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 2), PaddingTop = UDim.new(0.000000, 0), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 0), HistoryId = "00000000000000000000000000000000"}, Obj[111])
    Obj[115] = Make('Frame', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 17, 0.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 28, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(215.000000, 260.000000, 315.000000, 279.000000), LayoutOrder = 1, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.X, Name = "Collapse", Localize = false, AbsoluteSize = Vector2.new(19.000000, 19.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(217.000000, 260.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(217.000000, 260.000000, 236.000000, 279.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[111])
    Obj[116] = Make('UIAspectRatioConstraint', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, DominantAxis = Enum.DominantAxis.Width, AttributesReplicate = "", AspectRatio = 1, Attributes = "", Archivable = true, className = "UIAspectRatioConstraint", DefinesCapabilities = false, Tags = "", Sandboxed = false, numExpectedDirectChildren = 0, PropertyStatusStudio = Enum.PropertyStatus.Ok, archivable = true, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, Name = "UIAspectRatioConstraint", ClassName = "UIAspectRatioConstraint", RobloxLocked = false, AspectType = Enum.AspectType.FitWithinMaxSize, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[115])
    Obj[117] = Make('ImageButton', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 1, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, Selectable = true, Image = "rbxasset://textures/DeveloperFramework/button_arrow_right.png", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Black"), BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 1.000000, 0), HoverImage = "", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, className = "ImageButton", BackgroundTransparency = 1, Position = UDim2.new(0.500000, 0, 0.500000, 0), SliceScale = 1, DefinesCapabilities = false, ClassName = "ImageButton", HistoryId = "00000000000000000000000000000000", AbsoluteSize = Vector2.new(15.000000, 15.000000), MouseButton2ClickConnectionCount = 0, archivable = true, ResampleMode = Enum.ResamplerMode.Default, Interactable = true, DataCost = 10, MouseLeaveConnectionCount = 0, MouseButton1UpConnectionCount = 0, Tags = "", ActiveQueryNames = "", SourceAssetId = -1, SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), MouseButton2DownConnectionCount = 0, ScaleType = Enum.ScaleType.Stretch, AutoLocalize = false, RobloxLocked = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = true, Name = "CollapseIcon", Transparency = 1, SelectionOrder = 0, AttributesSerialize = "", MouseWheelBackwardConnectionCount = 0, Attributes = "", Archivable = true, TotalGroupScale = 1, ImageRectOffset = Vector2.new(0.000000, 0.000000), SelectionBehaviorUp = Enum.SelectionBehavior.Escape, BorderMode = Enum.BorderMode.Outline, MouseButton1DownConnectionCount = 0, GuiState = Enum.GuiState.Idle, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AnchorPoint = Vector2.new(0.500000, 0.500000), RawRect2D = Rect.new(219.000000, 262.000000, 234.000000, 277.000000), Localize = false, ImageRectSize = Vector2.new(0.000000, 0.000000), IsNotOccluded = true, Selected = false, AutomaticSize = Enum.AutomaticSize.None, ClippedRect = Rect.new(215.000000, 260.000000, 315.000000, 279.000000), LayoutOrder = 0, MouseButton2UpConnectionCount = 0, AbsoluteRotation = 0, MouseEnterConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(219.000000, 262.000000), numExpectedDirectChildren = 0, PressedImage = "", MouseButton1ClickConnectionCount = 0, MouseMovedConnectionCount = 0, ImageColor3 = Color3.fromRGB(255, 255, 255), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, Style = Enum.ButtonStyle.Custom}, Obj[115])
    Obj[118] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 2), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 2), PaddingTop = UDim.new(0.000000, 2), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 2), HistoryId = "00000000000000000000000000000000"}, Obj[115])
    Obj[119] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 2), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[111])
    Obj[120] = Make('ImageButton', {Visible = false, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 1, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, Selectable = true, Image = "", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Black"), BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 17, 0.000000, 0), HoverImage = "", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, className = "ImageButton", BackgroundTransparency = 1, Position = UDim2.new(0.500000, 0, 0.500000, 0), SliceScale = 1, DefinesCapabilities = false, ClassName = "ImageButton", HistoryId = "00000000000000000000000000000000", AbsoluteSize = Vector2.new(0.000000, 0.000000), MouseButton2ClickConnectionCount = 0, archivable = true, ResampleMode = Enum.ResamplerMode.Default, Interactable = true, DataCost = 14, MouseLeaveConnectionCount = 0, MouseButton1UpConnectionCount = 0, Tags = "", ActiveQueryNames = "", SourceAssetId = -1, SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), MouseButton2DownConnectionCount = 0, ScaleType = Enum.ScaleType.Stretch, AutoLocalize = false, RobloxLocked = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = true, Name = "Icon", Transparency = 1, SelectionOrder = 0, AttributesSerialize = "", MouseWheelBackwardConnectionCount = 0, Attributes = "", Archivable = true, TotalGroupScale = 1, ImageRectOffset = Vector2.new(0.000000, 0.000000), SelectionBehaviorUp = Enum.SelectionBehavior.Escape, BorderMode = Enum.BorderMode.Outline, MouseButton1DownConnectionCount = 0, GuiState = Enum.GuiState.Idle, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AnchorPoint = Vector2.new(0.500000, 0.500000), RawRect2D = Rect.new(217.000000, 260.000000, 217.000000, 260.000000), Localize = false, ImageRectSize = Vector2.new(0.000000, 0.000000), IsNotOccluded = false, Selected = false, AutomaticSize = Enum.AutomaticSize.None, ClippedRect = Rect.new(215.000000, 260.000000, 315.000000, 279.000000), LayoutOrder = 2, MouseButton2UpConnectionCount = 0, AbsoluteRotation = 0, MouseEnterConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(217.000000, 260.000000), numExpectedDirectChildren = 0, PressedImage = "", MouseButton1ClickConnectionCount = 0, MouseMovedConnectionCount = 0, ImageColor3 = Color3.fromRGB(255, 255, 255), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, Style = Enum.ButtonStyle.Custom}, Obj[111])
    Obj[121] = Make('UIAspectRatioConstraint', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, DominantAxis = Enum.DominantAxis.Width, AttributesReplicate = "", AspectRatio = 1, Attributes = "", Archivable = true, className = "UIAspectRatioConstraint", DefinesCapabilities = false, Tags = "", Sandboxed = false, numExpectedDirectChildren = 0, PropertyStatusStudio = Enum.PropertyStatus.Ok, archivable = true, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, Name = "UIAspectRatioConstraint", ClassName = "UIAspectRatioConstraint", RobloxLocked = false, AspectType = Enum.AspectType.FitWithinMaxSize, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[120])
    Obj[122] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(100.000000, 19.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 0), FillDirection = Enum.FillDirection.Vertical, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 0), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 0), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Right, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[110])
    Obj[123] = Make('VideoFrame', {LayoutOrder = 0, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, PlayingReplicating = false, ReplicatedInsertionOrder = 2147483647, Localize = false, Tags = "", Video = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, AbsoluteRotation = 0, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 100, 0.000000, 100), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), Looped = false, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 18, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", Volume = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, Playing = false, AutoLocalize = false, Sandboxed = false, IsLoaded = false, TimeLength = 0, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, className = "VideoFrame", ClassName = "VideoFrame", BorderSizePixel = 0, archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), BorderMode = Enum.BorderMode.Outline, SourceAssetId = -1, GuiState = Enum.GuiState.Idle, PropertyStatusStudio = Enum.PropertyStatus.Ok, Resolution = Vector2.new(0.000000, 0.000000), AnchorPoint = Vector2.new(0.000000, 0.000000), Name = "VideoPlayer", Visible = true, AttributesSerialize = "", TimePositionReplicating = 0, AutomaticSize = Enum.AutomaticSize.None, TimePosition = 0, Draggable = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), Archivable = true, MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(320.000000, 260.000000), numExpectedDirectChildren = 0, TotalGroupScale = 1, Active = false, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, Selectable = false, RawRect2D = Rect.new(320.000000, 260.000000, 420.000000, 340.000000), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, DragBeginConnectionCount = 0}, Obj[1])
    Obj[124] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 4), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 10), PaddingTop = UDim.new(0.000000, 4), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 10), HistoryId = "00000000000000000000000000000000"}, Obj[123])
    Obj[125] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 4), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "UICorner", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[123])
    Obj[126] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(110, 110, 128), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Dark grey"), Size = UDim2.new(1.000000, 0, 0.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 24, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(1.000000, 0.500000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "Bullet", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(425.000000, 260.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(425.000000, 260.000000, 525.000000, 340.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[127] = Make('ImageLabel', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, AbsoluteRotation = 0, Image = "rbxasset://textures/whiteCircle.png", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Really black"), BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 5, 0.000000, 5), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), SliceScale = 1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 10, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScaleType = Enum.ScaleType.Stretch, AutoLocalize = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, className = "ImageLabel", Transparency = 1, ClassName = "ImageLabel", SelectionOrder = 0, LayoutOrder = -1, MouseWheelBackwardConnectionCount = 0, archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), SourceAssetId = -1, RobloxLocked = false, BorderMode = Enum.BorderMode.Outline, Name = "Icon", GuiState = Enum.GuiState.Idle, AttributesSerialize = "", AnchorPoint = Vector2.new(0.000000, 0.000000), ImageColor3 = Color3.fromRGB(255, 255, 255), Attributes = "", ImageRectSize = Vector2.new(0.000000, 0.000000), SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Archivable = true, AutomaticSize = Enum.AutomaticSize.None, TotalGroupScale = 1, MouseMovedConnectionCount = 0, AbsoluteSize = Vector2.new(5.000000, 5.000000), IsNotOccluded = true, Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(425.000000, 297.500000), numExpectedDirectChildren = 0, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, Selectable = false, ResampleMode = Enum.ResamplerMode.Default, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(425.000000, 297.500000, 430.000000, 302.500000), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, ImageRectOffset = Vector2.new(0.000000, 0.000000)}, Obj[126])
    Obj[128] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(5.000000, 5.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[126])
    Obj[129] = Make('Model', {NeedsPivotMigration = false, Scale = 1, DataCost = 326, AttributesReplicate = "", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, LevelOfDetail = Enum.ModelLevelOfDetail.Automatic, SlimHash = "", SourceAssetId = -1, Attributes = "", AttributesSerialize = "", ScaleFactor = 1, ModelMeshSize = Vector3.new(0.000000, 0.000000, 0.000000), ClassName = "Model", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, PredictionMode = Enum.PredictionMode.Automatic, Archivable = true, ModelMeshData = "", Name = "R6 Rig", className = "Model", RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", ModelStreamingMode = Enum.ModelStreamingMode.Default}, Obj[1])
    Obj[130] = Make('Part', {RightParamB = 0.5, DraggingV1 = false, NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, RightSurface = Enum.SurfaceType.Smooth, Mass = 1.399999976158142, archivable = true, size = Vector3.new(2.000000, 1.000000, 1.000000), Friction = 0.30000001192092896, FrontParamB = 0.5, BottomSurface = Enum.SurfaceType.Inlet, ExtentsSize = Vector3.new(2.000000, 1.000000, 1.000000), CollisionGroup = "Default", BackSurfaceInput = Enum.InputType.NoInput, AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, shape = Enum.PartType.Block, MaterialVariant = "", CollisionGroupReplicate = "\000", RightParamA = -0.5, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), formFactorRaw = Enum.FormFactor.Symmetric, Material = Enum.Material.Plastic, Size = Vector3.new(2.000000, 1.000000, 1.000000), FrontSurface = Enum.SurfaceType.Smooth, LocalTransparencyModifier = 0, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, Name = "Head", AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, className = "Part", DataCost = 44, numExpectedDirectChildren = 0, TopSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, LeftParamB = 0.5, FrontSurfaceInput = Enum.InputType.NoInput, Tags = "", SourceAssetId = -1, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, BottomParamB = 0.5, HistoryId = "00000000000000000000000000000000", AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = true, RootPriority = 0, MaterialVariantSerialized = "", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, DefinesCapabilities = false, Transparency = 0, ClassName = "Part", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), AttributesSerialize = "", LeftSurfaceInput = Enum.InputType.NoInput, AttributesReplicate = "", CanQuery = true, Attributes = "", Locked = false, NetworkIsSleeping = false, brickColor = BrickColor.new("Sand green"), Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopSurface = Enum.SurfaceType.Smooth, TopParamB = 0.5, TopParamA = -0.5, SpecificGravity = 0.699999988079071, BottomParamA = -0.5, RightSurfaceInput = Enum.InputType.NoInput, Archivable = true, Anchored = false, formFactor = Enum.FormFactor.Symmetric, ResizeIncrement = 1, Reflectance = 0, BackParamA = -0.5, Position = Vector3.new(-50.646458, 168.115570, -91.609375), CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), CanTouch = true, AssemblyCenterOfMass = Vector3.new(-50.646458, 168.115570, -91.609375), AssemblyMass = 1.399999976158142, FormFactor = Enum.FormFactor.Symmetric, BrickColor = BrickColor.new("Sand green"), BackParamB = 0.5, BackSurface = Enum.SurfaceType.Smooth, UniqueId = "00000000000000000000000000000000", Shape = Enum.PartType.Block, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[129])
    Obj[131] = Make('SpecialMesh', {PredictionMode = Enum.PredictionMode.Automatic, Scale = Vector3.new(1.250000, 1.250000, 1.250000), DataCost = 4, AttributesReplicate = "", VertexColor = Vector3.new(1.000000, 1.000000, 1.000000), Attributes = "", className = "SpecialMesh", numExpectedDirectChildren = 0, Archivable = true, archivable = true, Offset = Vector3.new(0.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", Tags = "", Sandboxed = false, MeshId = "", PropertyStatusStudio = Enum.PropertyStatus.Ok, TextureId = "", SourceAssetId = -1, Name = "Mesh", MeshType = Enum.MeshType.Head, ClassName = "SpecialMesh", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[130])
    Obj[132] = Make('Decal', {DataCost = 4, AttributesReplicate = "", ZIndex = 1, archivable = true, Texture = "rbxasset://textures/face.png", NormalMap = "", Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, UVScale = Vector2.new(1.000000, 1.000000), Transparency = 0, Color3 = Color3.fromRGB(255, 255, 255), ClassName = "Decal", PredictionMode = Enum.PredictionMode.Automatic, TexturePack = "", SourceAssetId = -1, Attributes = "", Specular = 0, Archivable = true, Face = Enum.NormalId.Front, ColorMap = "rbxasset://textures/face.png", UniqueId = "00000000000000000000000000000000", LocalTransparencyModifier = 0, AttributesSerialize = "", UVOffset = Vector2.new(0.000000, 0.000000), RoughnessMap = "", numExpectedDirectChildren = 0, MetalnessMap = "", TexturePackMetadata = "", Name = "face", className = "Decal", RobloxLocked = false, DefinesCapabilities = false, Shiny = 20, HistoryId = "00000000000000000000000000000000"}, Obj[130])
    Obj[133] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 168.715576, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, 0.600000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "HairAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[130])
    Obj[134] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 168.715576, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, 0.600000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "HatAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[130])
    Obj[135] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 168.115570, -91.009377), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, 0.000000, -0.600000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "FaceFrontAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[130])
    Obj[136] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 168.115570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, 0.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "FaceCenterAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[130])
    Obj[137] = Make('Part', {RightParamB = 0, DraggingV1 = false, NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, RightSurface = Enum.SurfaceType.Weld, Mass = 2.799999952316284, archivable = true, size = Vector3.new(2.000000, 2.000000, 1.000000), Friction = 0.30000001192092896, FrontParamB = 0.5, BottomSurface = Enum.SurfaceType.Inlet, ExtentsSize = Vector3.new(2.000000, 2.000000, 1.000000), CollisionGroup = "Default", BackSurfaceInput = Enum.InputType.NoInput, AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, shape = Enum.PartType.Block, MaterialVariant = "", CollisionGroupReplicate = "\000", RightParamA = 0, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), formFactorRaw = Enum.FormFactor.Symmetric, Material = Enum.Material.Plastic, Size = Vector3.new(2.000000, 2.000000, 1.000000), FrontSurface = Enum.SurfaceType.Smooth, LocalTransparencyModifier = 0, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, Name = "Torso", AudioCanCollide = true, RobloxLocked = false, LeftParamA = 0, CastShadow = true, className = "Part", DataCost = 96, numExpectedDirectChildren = 0, TopSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, LeftParamB = 0, FrontSurfaceInput = Enum.InputType.NoInput, Tags = "", SourceAssetId = -1, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, BottomParamB = 0.5, HistoryId = "00000000000000000000000000000000", AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = true, RootPriority = 0, MaterialVariantSerialized = "", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Weld, DefinesCapabilities = false, Transparency = 0, ClassName = "Part", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), AttributesSerialize = "", LeftSurfaceInput = Enum.InputType.NoInput, AttributesReplicate = "", CanQuery = true, Attributes = "", Locked = false, NetworkIsSleeping = false, brickColor = BrickColor.new("Sand green"), Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopSurface = Enum.SurfaceType.Studs, TopParamB = 0.5, TopParamA = -0.5, SpecificGravity = 0.699999988079071, BottomParamA = -0.5, RightSurfaceInput = Enum.InputType.NoInput, Archivable = true, Anchored = false, formFactor = Enum.FormFactor.Symmetric, ResizeIncrement = 1, Reflectance = 0, BackParamA = -0.5, Position = Vector3.new(-50.646458, 166.615570, -91.609375), CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), CanTouch = true, AssemblyCenterOfMass = Vector3.new(-50.646458, 166.615570, -91.609375), AssemblyMass = 2.799999952316284, FormFactor = Enum.FormFactor.Symmetric, BrickColor = BrickColor.new("Sand green"), BackParamB = 0.5, BackSurface = Enum.SurfaceType.Smooth, UniqueId = "00000000000000000000000000000000", Shape = Enum.PartType.Block, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[129])
    Obj[138] = Make('Decal', {DataCost = 4, AttributesReplicate = "", ZIndex = 1, archivable = true, Texture = "", NormalMap = "", Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, UVScale = Vector2.new(1.000000, 1.000000), Transparency = 0, Color3 = Color3.fromRGB(255, 255, 255), ClassName = "Decal", PredictionMode = Enum.PredictionMode.Automatic, TexturePack = "", SourceAssetId = -1, Attributes = "", Specular = 0, Archivable = true, Face = Enum.NormalId.Front, ColorMap = "", UniqueId = "00000000000000000000000000000000", LocalTransparencyModifier = 0, AttributesSerialize = "", UVOffset = Vector2.new(0.000000, 0.000000), RoughnessMap = "", numExpectedDirectChildren = 0, MetalnessMap = "", TexturePackMetadata = "", Name = "roblox", className = "Decal", RobloxLocked = false, DefinesCapabilities = false, Shiny = 20, HistoryId = "00000000000000000000000000000000"}, Obj[137])
    Obj[139] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 167.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, 1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "NeckAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[137])
    Obj[140] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 166.615570, -91.109375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, 0.000000, -0.500000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "BodyFrontAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[137])
    Obj[141] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 166.615570, -92.109375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, 0.000000, 0.500000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "BodyBackAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[137])
    Obj[142] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.646458, 167.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(-1.000000, 1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftCollarAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[137])
    Obj[143] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.646458, 167.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(1.000000, 1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightCollarAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[137])
    Obj[144] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 165.615570, -91.109375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, -1.000000, -0.500000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "WaistFrontAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[137])
    Obj[145] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 165.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, -1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "WaistCenterAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[137])
    Obj[146] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 165.615570, -92.109375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, -1.000000, 0.500000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "WaistBackAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[137])
    Obj[147] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "Torso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "Right Arm", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0.10000000149011612, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "Right Shoulder", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[137])
    Obj[148] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "Torso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "Left Arm", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0.10000000149011612, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "Left Shoulder", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[137])
    Obj[149] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "Torso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "Right Leg", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0.10000000149011612, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "Right Hip", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[137])
    Obj[150] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "Torso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "Left Leg", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0.10000000149011612, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "Left Hip", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[137])
    Obj[151] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "Torso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "Head", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0.10000000149011612, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "Neck", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[137])
    Obj[152] = Make('Part', {RightParamB = 0.5, DraggingV1 = false, NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, RightSurface = Enum.SurfaceType.Smooth, Mass = 1.399999976158142, archivable = true, size = Vector3.new(1.000000, 2.000000, 1.000000), Friction = 0.30000001192092896, FrontParamB = 0.5, BottomSurface = Enum.SurfaceType.Inlet, ExtentsSize = Vector3.new(1.000000, 2.000000, 1.000000), CollisionGroup = "Default", BackSurfaceInput = Enum.InputType.NoInput, AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, shape = Enum.PartType.Block, MaterialVariant = "", CollisionGroupReplicate = "\000", RightParamA = -0.5, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), formFactorRaw = Enum.FormFactor.Symmetric, Material = Enum.Material.Plastic, Size = Vector3.new(1.000000, 2.000000, 1.000000), FrontSurface = Enum.SurfaceType.Smooth, LocalTransparencyModifier = 0, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, Name = "Left Arm", AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, className = "Part", DataCost = 28, numExpectedDirectChildren = 0, TopSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, LeftParamB = 0.5, FrontSurfaceInput = Enum.InputType.NoInput, Tags = "", SourceAssetId = -1, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, BottomParamB = 0.5, HistoryId = "00000000000000000000000000000000", AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MaterialVariantSerialized = "", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, DefinesCapabilities = false, Transparency = 0, ClassName = "Part", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), AttributesSerialize = "", LeftSurfaceInput = Enum.InputType.NoInput, AttributesReplicate = "", CanQuery = true, Attributes = "", Locked = false, NetworkIsSleeping = false, brickColor = BrickColor.new("Sand green"), Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopSurface = Enum.SurfaceType.Studs, TopParamB = 0.5, TopParamA = -0.5, SpecificGravity = 0.699999988079071, BottomParamA = -0.5, RightSurfaceInput = Enum.InputType.NoInput, Archivable = true, Anchored = false, formFactor = Enum.FormFactor.Symmetric, ResizeIncrement = 1, Reflectance = 0, BackParamA = -0.5, Position = Vector3.new(-49.146458, 166.615570, -91.609375), CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), CanTouch = true, AssemblyCenterOfMass = Vector3.new(-49.146458, 166.615570, -91.609375), AssemblyMass = 1.399999976158142, FormFactor = Enum.FormFactor.Symmetric, BrickColor = BrickColor.new("Sand green"), BackParamB = 0.5, BackSurface = Enum.SurfaceType.Smooth, UniqueId = "00000000000000000000000000000000", Shape = Enum.PartType.Block, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[129])
    Obj[153] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.146458, 167.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, 1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftShoulderAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[152])
    Obj[154] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.146458, 165.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, -1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftGripAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[152])
    Obj[155] = Make('Part', {RightParamB = 0.5, DraggingV1 = false, NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, RightSurface = Enum.SurfaceType.Smooth, Mass = 1.399999976158142, archivable = true, size = Vector3.new(1.000000, 2.000000, 1.000000), Friction = 0.30000001192092896, FrontParamB = 0.5, BottomSurface = Enum.SurfaceType.Inlet, ExtentsSize = Vector3.new(1.000000, 2.000000, 1.000000), CollisionGroup = "Default", BackSurfaceInput = Enum.InputType.NoInput, AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, shape = Enum.PartType.Block, MaterialVariant = "", CollisionGroupReplicate = "\000", RightParamA = -0.5, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), formFactorRaw = Enum.FormFactor.Symmetric, Material = Enum.Material.Plastic, Size = Vector3.new(1.000000, 2.000000, 1.000000), FrontSurface = Enum.SurfaceType.Smooth, LocalTransparencyModifier = 0, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, Name = "Right Arm", AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, className = "Part", DataCost = 28, numExpectedDirectChildren = 0, TopSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, LeftParamB = 0.5, FrontSurfaceInput = Enum.InputType.NoInput, Tags = "", SourceAssetId = -1, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, BottomParamB = 0.5, HistoryId = "00000000000000000000000000000000", AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MaterialVariantSerialized = "", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, DefinesCapabilities = false, Transparency = 0, ClassName = "Part", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), AttributesSerialize = "", LeftSurfaceInput = Enum.InputType.NoInput, AttributesReplicate = "", CanQuery = true, Attributes = "", Locked = false, NetworkIsSleeping = false, brickColor = BrickColor.new("Sand green"), Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopSurface = Enum.SurfaceType.Studs, TopParamB = 0.5, TopParamA = -0.5, SpecificGravity = 0.699999988079071, BottomParamA = -0.5, RightSurfaceInput = Enum.InputType.NoInput, Archivable = true, Anchored = false, formFactor = Enum.FormFactor.Symmetric, ResizeIncrement = 1, Reflectance = 0, BackParamA = -0.5, Position = Vector3.new(-52.146458, 166.615570, -91.609375), CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), CanTouch = true, AssemblyCenterOfMass = Vector3.new(-52.146458, 166.615570, -91.609375), AssemblyMass = 1.399999976158142, FormFactor = Enum.FormFactor.Symmetric, BrickColor = BrickColor.new("Sand green"), BackParamB = 0.5, BackSurface = Enum.SurfaceType.Smooth, UniqueId = "00000000000000000000000000000000", Shape = Enum.PartType.Block, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[129])
    Obj[156] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-52.146458, 167.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, 1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightShoulderAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[155])
    Obj[157] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-52.146458, 165.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, -1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightGripAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[155])
    Obj[158] = Make('Part', {RightParamB = 0.5, DraggingV1 = false, NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, RightSurface = Enum.SurfaceType.Smooth, Mass = 1.399999976158142, archivable = true, size = Vector3.new(1.000000, 2.000000, 1.000000), Friction = 0.30000001192092896, FrontParamB = 0.5, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 2.000000, 1.000000), CollisionGroup = "Default", BackSurfaceInput = Enum.InputType.NoInput, AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, shape = Enum.PartType.Block, MaterialVariant = "", CollisionGroupReplicate = "\000", RightParamA = -0.5, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), formFactorRaw = Enum.FormFactor.Symmetric, Material = Enum.Material.Plastic, Size = Vector3.new(1.000000, 2.000000, 1.000000), FrontSurface = Enum.SurfaceType.Smooth, LocalTransparencyModifier = 0, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, Name = "Left Leg", AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, className = "Part", DataCost = 24, numExpectedDirectChildren = 0, TopSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, LeftParamB = 0.5, FrontSurfaceInput = Enum.InputType.NoInput, Tags = "", SourceAssetId = -1, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, BottomParamB = 0.5, HistoryId = "00000000000000000000000000000000", AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MaterialVariantSerialized = "", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, DefinesCapabilities = false, Transparency = 0, ClassName = "Part", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), AttributesSerialize = "", LeftSurfaceInput = Enum.InputType.NoInput, AttributesReplicate = "", CanQuery = true, Attributes = "", Locked = false, NetworkIsSleeping = false, brickColor = BrickColor.new("Sand green"), Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopSurface = Enum.SurfaceType.Studs, TopParamB = 0.5, TopParamA = -0.5, SpecificGravity = 0.699999988079071, BottomParamA = -0.5, RightSurfaceInput = Enum.InputType.NoInput, Archivable = true, Anchored = false, formFactor = Enum.FormFactor.Symmetric, ResizeIncrement = 1, Reflectance = 0, BackParamA = -0.5, Position = Vector3.new(-50.146458, 164.615570, -91.609375), CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), CanTouch = true, AssemblyCenterOfMass = Vector3.new(-50.146458, 164.615570, -91.609375), AssemblyMass = 1.399999976158142, FormFactor = Enum.FormFactor.Symmetric, BrickColor = BrickColor.new("Sand green"), BackParamB = 0.5, BackSurface = Enum.SurfaceType.Smooth, UniqueId = "00000000000000000000000000000000", Shape = Enum.PartType.Block, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[129])
    Obj[159] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.146458, 163.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, -1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftFootAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[158])
    Obj[160] = Make('Part', {RightParamB = 0.5, DraggingV1 = false, NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, RightSurface = Enum.SurfaceType.Smooth, Mass = 1.399999976158142, archivable = true, size = Vector3.new(1.000000, 2.000000, 1.000000), Friction = 0.30000001192092896, FrontParamB = 0.5, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 2.000000, 1.000000), CollisionGroup = "Default", BackSurfaceInput = Enum.InputType.NoInput, AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, shape = Enum.PartType.Block, MaterialVariant = "", CollisionGroupReplicate = "\000", RightParamA = -0.5, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), formFactorRaw = Enum.FormFactor.Symmetric, Material = Enum.Material.Plastic, Size = Vector3.new(1.000000, 2.000000, 1.000000), FrontSurface = Enum.SurfaceType.Smooth, LocalTransparencyModifier = 0, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, Name = "Right Leg", AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, className = "Part", DataCost = 24, numExpectedDirectChildren = 0, TopSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, LeftParamB = 0.5, FrontSurfaceInput = Enum.InputType.NoInput, Tags = "", SourceAssetId = -1, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, BottomParamB = 0.5, HistoryId = "00000000000000000000000000000000", AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MaterialVariantSerialized = "", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, DefinesCapabilities = false, Transparency = 0, ClassName = "Part", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), AttributesSerialize = "", LeftSurfaceInput = Enum.InputType.NoInput, AttributesReplicate = "", CanQuery = true, Attributes = "", Locked = false, NetworkIsSleeping = false, brickColor = BrickColor.new("Sand green"), Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopSurface = Enum.SurfaceType.Studs, TopParamB = 0.5, TopParamA = -0.5, SpecificGravity = 0.699999988079071, BottomParamA = -0.5, RightSurfaceInput = Enum.InputType.NoInput, Archivable = true, Anchored = false, formFactor = Enum.FormFactor.Symmetric, ResizeIncrement = 1, Reflectance = 0, BackParamA = -0.5, Position = Vector3.new(-51.146458, 164.615570, -91.609375), CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), CanTouch = true, AssemblyCenterOfMass = Vector3.new(-51.146458, 164.615570, -91.609375), AssemblyMass = 1.399999976158142, FormFactor = Enum.FormFactor.Symmetric, BrickColor = BrickColor.new("Sand green"), BackParamB = 0.5, BackSurface = Enum.SurfaceType.Smooth, UniqueId = "00000000000000000000000000000000", Shape = Enum.PartType.Block, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[129])
    Obj[161] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.146458, 163.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, -1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightFootAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[160])
    Obj[162] = Make('Humanoid', {AutoRotate = true, HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged, HealthDisplayDistance = 100, WalkSpeed = 16, MaxSlopeAngle = 89, Tags = "", NameOcclusion = Enum.NameOcclusion.OccludeAll, WalkAngleError = 0, WalkToPoint = Vector3.new(0.000000, 0.000000, 0.000000), AutomaticScalingEnabled = true, MaxHealth = 100, PredictionMode = Enum.PredictionMode.Automatic, UseJumpPower = true, InternalOriginalHipHeight = 0, CameraMode = Enum.CameraMode.Classic, InternalHeadScale = 1, Attributes = "", NameDisplayDistance = 100, RigType = Enum.HumanoidRigType.R6, TargetPoint = Vector3.new(0.000000, 0.000000, 0.000000), MoveDirectionInternal = Vector3.new(0.000000, 0.000000, 0.000000), Name = "Humanoid", className = "Humanoid", RobloxLocked = false, InternalDisplayName = "", HistoryId = "00000000000000000000000000000000", DataCost = 36, EvaluateStateMachine = true, RequiresNeck = true, Jump = false, CameraMinDistance = 0, PropertyStatusStudio = Enum.PropertyStatus.Ok, DisplayName = "", Health = 100, ClassName = "Humanoid", FloorMaterial = Enum.Material.Air, NetworkHumanoidState = Enum.HumanoidStateType.FallingDown, InternalBodyScale = Vector3.new(1.000000, 1.000000, 1.000000), AutoJumpEnabled = true, RotationType = Enum.RotationType.MovementRelative, SourceAssetId = -1, archivable = true, DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer, Sandboxed = false, MoveDirection = Vector3.new(0.000000, 0.000000, 0.000000), Health_XML = 100, CollisionType = Enum.HumanoidCollisionType.OuterBox, BreakJointsOnDeath = true, CameraOffset = Vector3.new(0.000000, 0.000000, 0.000000), Archivable = true, JumpHeight = 7.199999809265137, JumpReplicate = false, WalkDirection = Vector3.new(0.000000, 0.000000, 0.000000), AttributesReplicate = "", Sit = false, DefinesCapabilities = false, numExpectedDirectChildren = 0, HipHeight = 0, OverrideDefaultCollisions = false, CameraMaxDistance = 400, JumpPower = 50, PlatformStand = false, AttributesSerialize = "", UniqueId = "00000000000000000000000000000000", maxHealth = 100, Strafe = false}, Obj[129])
    Obj[163] = Make('Animator', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", RootMotionWeight = 0, Archivable = true, className = "Animator", PreferLodEnabled = true, numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, EvaluationThrottled = false, Name = "Animator", ClassName = "Animator", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[162])
    Obj[164] = Make('HumanoidDescription', {SwimAnimation = 0, MoodAnimation = 0, Torso = 0, AttributesReplicate = "", Shirt = 0, AccessoryBlob = "[]", archivable = true, HairAccessory = "", RightArm = 0, Head = 0, FallAnimation = 0, TorsoColor = Color3.fromRGB(127, 127, 127), NumberEmotesLoaded = -1, HeightScale = 1, WaistAccessory = "", PredictionMode = Enum.PredictionMode.Automatic, EquippedEmotesDataInternal = "", RightLegColor = Color3.fromRGB(127, 127, 127), EmotesDataInternal = "", BodyTypeScale = 0, RunAnimation = 0, Attributes = "", GraphicTShirt = 0, HeadColor = Color3.fromRGB(127, 127, 127), Name = "HumanoidDescription", className = "HumanoidDescription", RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", WalkAnimation = 0, DataCost = 28, ProportionScale = 0, ClimbAnimation = 0, FaceAccessory = "", RightArmColor = Color3.fromRGB(127, 127, 127), Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, UseAvatarSettings = false, DepthScale = 1, LeftArm = 0, SourceAssetId = -1, WidthScale = 1, BackAccessory = "", LeftArmColor = Color3.fromRGB(127, 127, 127), HatAccessory = "", Archivable = true, ClassName = "HumanoidDescription", RightLeg = 0, Face = 0, ResetIncludesBodyParts = true, AttributesSerialize = "", FrontAccessory = "", Tags = "", numExpectedDirectChildren = 0, LeftLeg = 0, NeckAccessory = "", LeftLegColor = Color3.fromRGB(127, 127, 127), IdleAnimation = 0, JumpAnimation = 0, HeadScale = 1, UniqueId = "00000000000000000000000000000000", Pants = 0, ShouldersAccessory = ""}, Obj[162])
    Obj[165] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.Head}, Obj[164])
    Obj[166] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.LeftArm}, Obj[164])
    Obj[167] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.LeftLeg}, Obj[164])
    Obj[168] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.RightArm}, Obj[164])
    Obj[169] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.RightLeg}, Obj[164])
    Obj[170] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.Torso}, Obj[164])
    Obj[171] = Make('Part', {RightParamB = 0, DraggingV1 = false, NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, RightSurface = Enum.SurfaceType.Smooth, Mass = 2.799999952316284, archivable = true, size = Vector3.new(2.000000, 2.000000, 1.000000), Friction = 0.30000001192092896, FrontParamB = 0.5, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(2.000000, 2.000000, 1.000000), CollisionGroup = "Default", BackSurfaceInput = Enum.InputType.NoInput, AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, shape = Enum.PartType.Block, MaterialVariant = "", CollisionGroupReplicate = "\000", RightParamA = 0, Color = Color3.fromRGB(163, 162, 165), Massless = false, CollisionGroupId = 0, RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), formFactorRaw = Enum.FormFactor.Symmetric, Material = Enum.Material.Plastic, Size = Vector3.new(2.000000, 2.000000, 1.000000), FrontSurface = Enum.SurfaceType.Smooth, LocalTransparencyModifier = 0, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, Name = "HumanoidRootPart", AudioCanCollide = true, RobloxLocked = false, LeftParamA = 0, CastShadow = true, className = "Part", DataCost = 32, numExpectedDirectChildren = 0, TopSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, LeftParamB = 0, FrontSurfaceInput = Enum.InputType.NoInput, Tags = "", SourceAssetId = -1, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, BottomParamB = 0.5, HistoryId = "00000000000000000000000000000000", AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MaterialVariantSerialized = "", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, DefinesCapabilities = false, Transparency = 1, ClassName = "Part", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), AttributesSerialize = "", LeftSurfaceInput = Enum.InputType.NoInput, AttributesReplicate = "", CanQuery = true, Attributes = "", Locked = false, NetworkIsSleeping = false, brickColor = BrickColor.new("Medium stone grey"), Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopSurface = Enum.SurfaceType.Smooth, TopParamB = 0.5, TopParamA = -0.5, SpecificGravity = 0.699999988079071, BottomParamA = -0.5, RightSurfaceInput = Enum.InputType.NoInput, Archivable = true, Anchored = false, formFactor = Enum.FormFactor.Symmetric, ResizeIncrement = 1, Reflectance = 0, BackParamA = -0.5, Position = Vector3.new(-50.646458, 166.615570, -91.609375), CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), CanTouch = true, AssemblyCenterOfMass = Vector3.new(-50.646458, 166.615570, -91.609375), AssemblyMass = 2.799999952316284, FormFactor = Enum.FormFactor.Symmetric, BrickColor = BrickColor.new("Medium stone grey"), BackParamB = 0.5, BackSurface = Enum.SurfaceType.Smooth, UniqueId = "00000000000000000000000000000000", Shape = Enum.PartType.Block, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[129])
    Obj[172] = Make('Attachment', {Visible = false, DataCost = 4, WorldSecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, -0.000005, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 166.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, 0.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RootAttachment", WorldAxis = Vector3.new(-1.000000, 0.000000, 0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[171])
    Obj[173] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "HumanoidRootPart", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "Torso", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0.10000000149011612, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "RootJoint", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[171])
    Obj[174] = Make('BodyColors', {DataCost = 4, AttributesReplicate = "", RightArmColor = BrickColor.new("Silver flip/flop"), archivable = true, LeftArmColor3 = Color3.fromRGB(127, 127, 127), Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, TorsoColor = BrickColor.new("Silver flip/flop"), ClassName = "BodyColors", PredictionMode = Enum.PredictionMode.Automatic, RightLegColor = BrickColor.new("Silver flip/flop"), LeftLegColor = BrickColor.new("Silver flip/flop"), HeadColor3 = Color3.fromRGB(127, 127, 127), LeftLegColor3 = Color3.fromRGB(127, 127, 127), Attributes = "", Archivable = true, TorsoColor3 = Color3.fromRGB(127, 127, 127), SourceAssetId = -1, AttributesSerialize = "", LeftArmColor = BrickColor.new("Silver flip/flop"), RightArmColor3 = Color3.fromRGB(127, 127, 127), numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", HeadColor = BrickColor.new("Silver flip/flop"), DefinesCapabilities = false, Name = "Body Colors", className = "BodyColors", RobloxLocked = false, RightLegColor3 = Color3.fromRGB(127, 127, 127), HistoryId = "00000000000000000000000000000000"}, Obj[129])
    Obj[175] = Make('Model', {NeedsPivotMigration = false, Scale = 1, DataCost = 1034, AttributesReplicate = "", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, LevelOfDetail = Enum.ModelLevelOfDetail.Automatic, SlimHash = "", SourceAssetId = -1, Attributes = "", AttributesSerialize = "", ScaleFactor = 1, ModelMeshSize = Vector3.new(0.000000, 0.000000, 0.000000), ClassName = "Model", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, PredictionMode = Enum.PredictionMode.Automatic, Archivable = true, ModelMeshData = "", Name = "R15 Rig", className = "Model", RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", ModelStreamingMode = Enum.ModelStreamingMode.Default}, Obj[1])
    Obj[176] = Make('Part', {RightParamB = 0.5, DraggingV1 = false, NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, RightSurface = Enum.SurfaceType.Smooth, Mass = 2.799999952316284, archivable = true, size = Vector3.new(2.000000, 2.000000, 1.000000), Friction = 0.30000001192092896, FrontParamB = 0.5, BottomSurface = Enum.SurfaceType.Inlet, ExtentsSize = Vector3.new(2.000000, 2.000000, 1.000000), CollisionGroup = "Default", BackSurfaceInput = Enum.InputType.NoInput, AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, shape = Enum.PartType.Block, MaterialVariant = "", CollisionGroupReplicate = "\000", RightParamA = -0.5, Color = Color3.fromRGB(163, 162, 165), Massless = false, CollisionGroupId = 0, RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), formFactorRaw = Enum.FormFactor.Brick, Material = Enum.Material.Plastic, Size = Vector3.new(2.000000, 2.000000, 1.000000), FrontSurface = Enum.SurfaceType.Smooth, LocalTransparencyModifier = 0, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, Name = "HumanoidRootPart", AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, className = "Part", DataCost = 40, numExpectedDirectChildren = 0, TopSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, LeftParamB = 0.5, FrontSurfaceInput = Enum.InputType.NoInput, Tags = "", SourceAssetId = -1, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, BottomParamB = 0.5, HistoryId = "00000000000000000000000000000000", AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = true, RootPriority = 0, MaterialVariantSerialized = "", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, DefinesCapabilities = false, Transparency = 1, ClassName = "Part", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), AttributesSerialize = "", LeftSurfaceInput = Enum.InputType.NoInput, AttributesReplicate = "", CanQuery = true, Attributes = "", Locked = false, NetworkIsSleeping = false, brickColor = BrickColor.new("Medium stone grey"), Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopSurface = Enum.SurfaceType.Studs, TopParamB = 0.5, TopParamA = -0.5, SpecificGravity = 0.699999988079071, BottomParamA = -0.5, RightSurfaceInput = Enum.InputType.NoInput, Archivable = true, Anchored = false, formFactor = Enum.FormFactor.Brick, ResizeIncrement = 1, Reflectance = 0, BackParamA = -0.5, Position = Vector3.new(-50.646458, 166.615570, -91.609375), CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), CanTouch = true, AssemblyCenterOfMass = Vector3.new(-50.646458, 166.615570, -91.609375), AssemblyMass = 2.799999952316284, FormFactor = Enum.FormFactor.Brick, BrickColor = BrickColor.new("Medium stone grey"), BackParamB = 0.5, BackSurface = Enum.SurfaceType.Smooth, UniqueId = "00000000000000000000000000000000", Shape = Enum.PartType.Block, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[175])
    Obj[177] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 165.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, -1.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RootRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[176])
    Obj[178] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, -0.350000, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[177])
    Obj[179] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(2.000000, 2.000000, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[176])
    Obj[180] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 166.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, 0.000000, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RootAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[176])
    Obj[181] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, 0.000000, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[180])
    Obj[182] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 1.2077209949493408, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.197840, 1.202400, 1.197901), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.197840, 1.202400, 1.197901), CollisionGroup = "Default", AssemblyMass = 1.2077209949493408, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "Head", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.414181, 0.412607, 0.414160), Size = Vector3.new(1.197840, 1.202400, 1.197901), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 80, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.197840, 1.202400, 1.197901), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430070993", MeshSize = Vector3.new(1.197840, 1.202400, 1.197901), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430070993", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 1.725315809249878, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-50.646458, 168.115570, -91.609650), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(-0.000000, -0.500000, -0.000272), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-50.646458, 168.115570, -91.609650), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[183] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071113", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297521", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "Head", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[182])
    Obj[184] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 167.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.500000, -0.000272), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "NeckRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[182])
    Obj[185] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.500000, -0.000272), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[184])
    Obj[186] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(0.000000, 0.000000, -0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 168.115570, -91.009377), Axis = Vector3.new(1.000000, -0.000000, -0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, 0.000000, -0.600272), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "FaceFrontAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[182])
    Obj[187] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, 0.000000, -0.600272), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[186])
    Obj[188] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(0.000000, 0.000000, -0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 168.715576, -91.609375), Axis = Vector3.new(1.000000, -0.000000, -0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, 0.600000, -0.000272), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "HatAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[182])
    Obj[189] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, 0.600000, -0.000272), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[188])
    Obj[190] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(0.000000, 0.000000, -0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 168.715576, -91.609375), Axis = Vector3.new(1.000000, -0.000000, -0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, 0.600000, -0.000272), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "HairAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[182])
    Obj[191] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, 0.600000, -0.000272), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[190])
    Obj[192] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(0.000000, 0.000000, -0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 168.115570, -91.609375), Axis = Vector3.new(1.000000, -0.000000, -0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, 0.000000, -0.000272), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "FaceCenterAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[182])
    Obj[193] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, 0.000000, -0.000272), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[192])
    Obj[194] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "UpperTorso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "Head", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "Neck", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[182])
    Obj[195] = Make('Decal', {DataCost = 4, AttributesReplicate = "", ZIndex = 1, archivable = true, Texture = "rbxasset://textures/face.png", NormalMap = "", Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, UVScale = Vector2.new(1.000000, 1.000000), Transparency = 0, Color3 = Color3.fromRGB(255, 255, 255), ClassName = "Decal", PredictionMode = Enum.PredictionMode.Automatic, TexturePack = "", SourceAssetId = -1, Attributes = "", Specular = 0, Archivable = true, Face = Enum.NormalId.Front, ColorMap = "rbxasset://textures/face.png", UniqueId = "00000000000000000000000000000000", LocalTransparencyModifier = 0, AttributesSerialize = "", UVOffset = Vector2.new(0.000000, 0.000000), RoughnessMap = "", numExpectedDirectChildren = 0, MetalnessMap = "", TexturePackMetadata = "", Name = "face", className = "Decal", RobloxLocked = false, DefinesCapabilities = false, Shiny = 20, HistoryId = "00000000000000000000000000000000"}, Obj[182])
    Obj[196] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.197840, 1.202400, 1.197901), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[182])
    Obj[197] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.21007022261619568, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 0.300100, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 0.300100, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.21007022261619568, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "LeftHand", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.027261, 0.050017, 0.027261), Size = Vector3.new(1.000000, 0.300100, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 52, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 0.300100, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430070991", MeshSize = Vector3.new(1.000000, 0.300100, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430070991", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 0.30010032653808594, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-49.146454, 165.765518, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(0.000479, 0.125045, 0.000000), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-49.146454, 165.765518, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[198] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071100", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297526", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "LeftHand", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[197])
    Obj[199] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.146935, 165.890564, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000479, 0.125045, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftWristRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[197])
    Obj[200] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000479, 0.125045, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[199])
    Obj[201] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 0.000000, 1.000000), SecondaryAxis = Vector3.new(0.000000, 0.000000, -1.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-90.000000, -0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-90.000000, -0.000002, -179.999985), className = "Attachment", WorldPosition = Vector3.new(-49.146454, 165.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-90.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, -0.149955, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-90.000000, -0.000000, -0.000000), AttributesSerialize = "", Name = "LeftGripAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[197])
    Obj[202] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, -0.149955, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[201])
    Obj[203] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "LeftLowerArm", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "LeftHand", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "LeftWrist", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[197])
    Obj[204] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 0.300100, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[197])
    Obj[205] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.21007022261619568, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 0.300100, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 0.300100, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.21007022261619568, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "RightHand", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.027261, 0.050017, 0.027261), Size = Vector3.new(1.000000, 0.300100, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 52, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 0.300100, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430070997", MeshSize = Vector3.new(1.000000, 0.300100, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430070997", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 0.30010032653808594, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-52.146461, 165.765518, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(0.000000, 0.125045, 0.000000), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-52.146461, 165.765518, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[206] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071147", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297529", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "RightHand", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[205])
    Obj[207] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-52.146461, 165.890564, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, 0.125045, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightWristRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[205])
    Obj[208] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, 0.125045, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[207])
    Obj[209] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 0.000000, 1.000000), SecondaryAxis = Vector3.new(0.000000, 0.000000, -1.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-90.000000, -0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-90.000000, -0.000002, -179.999985), className = "Attachment", WorldPosition = Vector3.new(-52.146461, 165.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-90.000000, -179.999985, 0.000000), Position = Vector3.new(0.000000, -0.149955, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-90.000000, -0.000000, -0.000000), AttributesSerialize = "", Name = "RightGripAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[205])
    Obj[210] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, -0.149955, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[209])
    Obj[211] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "RightLowerArm", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "RightHand", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "RightWrist", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[205])
    Obj[212] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 0.300100, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[205])
    Obj[213] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.7363292574882507, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 1.051899, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 1.051899, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.7363292574882507, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "LeftLowerArm", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.184651, 0.175316, 0.184651), Size = Vector3.new(1.000000, 1.051899, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 52, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 1.051899, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071005", MeshSize = Vector3.new(1.000000, 1.051899, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071005", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 1.0518989562988281, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-49.146454, 166.391495, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(0.000479, 0.258688, 0.000000), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-49.146454, 166.391495, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[214] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071121", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297522", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "LeftLowerArm", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[213])
    Obj[215] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.146931, 166.650177, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000479, 0.258688, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftElbowRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[213])
    Obj[216] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000479, 0.258688, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[215])
    Obj[217] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.146931, 165.890564, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000479, -0.500929, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftWristRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[213])
    Obj[218] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000479, -0.500929, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[217])
    Obj[219] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "LeftUpperArm", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "LeftLowerArm", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "LeftElbow", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[213])
    Obj[220] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 1.051899, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[213])
    Obj[221] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.7363292574882507, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 1.051899, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 1.051899, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.7363292574882507, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "RightLowerArm", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.184651, 0.175316, 0.184651), Size = Vector3.new(1.000000, 1.051899, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 52, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 1.051899, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071013", MeshSize = Vector3.new(1.000000, 1.051899, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071013", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 1.0518989562988281, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-52.146461, 166.391495, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(0.000000, 0.258579, 0.000000), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-52.146461, 166.391495, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[222] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071157", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297525", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "RightLowerArm", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[221])
    Obj[223] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-52.146461, 166.650070, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, 0.258579, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightElbowRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[221])
    Obj[224] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, 0.258579, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[223])
    Obj[225] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-52.146461, 165.890564, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, -0.500929, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightWristRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[221])
    Obj[226] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, -0.500929, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[225])
    Obj[227] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "RightUpperArm", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "RightLowerArm", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "RightElbow", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[221])
    Obj[228] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 1.051899, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[221])
    Obj[229] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.818089485168457, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 1.168699, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 1.168699, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.818089485168457, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "LeftUpperArm", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.230415, 0.194783, 0.230415), Size = Vector3.new(1.000000, 1.168699, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 60, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 1.168699, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071044", MeshSize = Vector3.new(1.000000, 1.168699, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071044", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 1.1686992645263672, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-49.146454, 166.984238, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(0.500000, 0.394327, 0.000000), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-49.146454, 166.984238, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[230] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071112", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297524", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "LeftUpperArm", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[229])
    Obj[231] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.646454, 167.378571, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.500000, 0.394327, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftShoulderRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[229])
    Obj[232] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.500000, 0.394327, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[231])
    Obj[233] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.146935, 166.650177, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000479, -0.334056, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftElbowRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[229])
    Obj[234] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000479, -0.334056, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[233])
    Obj[235] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.146454, 167.568573, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, 0.584327, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftShoulderAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[229])
    Obj[236] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, 0.584327, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[235])
    Obj[237] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "UpperTorso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "LeftUpperArm", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "LeftShoulder", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[229])
    Obj[238] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 1.168699, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[229])
    Obj[239] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.818089485168457, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 1.168699, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 1.168699, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.818089485168457, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "RightUpperArm", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.230415, 0.194783, 0.230415), Size = Vector3.new(1.000000, 1.168699, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 60, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 1.168699, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071041", MeshSize = Vector3.new(1.000000, 1.168699, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071041", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 1.1686992645263672, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-52.146461, 166.984238, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(-0.500001, 0.394327, 0.000000), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-52.146461, 166.984238, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[240] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071148", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297523", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "RightUpperArm", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[239])
    Obj[241] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.646461, 167.378571, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.500001, 0.394327, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightShoulderRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[239])
    Obj[242] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.500001, 0.394327, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[241])
    Obj[243] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-52.146461, 166.650070, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000001, -0.334165, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightElbowRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[239])
    Obj[244] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000001, -0.334165, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[243])
    Obj[245] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-52.146461, 167.568573, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000001, 0.584327, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightShoulderAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[239])
    Obj[246] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000001, 0.584327, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[245])
    Obj[247] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "UpperTorso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "RightUpperArm", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "RightShoulder", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[239])
    Obj[248] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 1.168699, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[239])
    Obj[249] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.2099994570016861, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 0.299999, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 0.299999, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.2099994570016861, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "LeftFoot", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.027250, 0.050000, 0.027250), Size = Vector3.new(1.000000, 0.299999, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 52, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 0.299999, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071039", MeshSize = Vector3.new(1.000000, 0.299999, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071039", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 0.2999992370605469, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-50.146458, 163.765564, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(-0.000000, 0.101940, -0.000002), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-50.146458, 163.765564, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[250] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071146", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297527", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "LeftFoot", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[249])
    Obj[251] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.146458, 163.867508, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, 0.101940, -0.000002), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftAnkleRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[249])
    Obj[252] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, 0.101940, -0.000002), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[251])
    Obj[253] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(0.000000, -0.000000, -0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.164734, 163.612106, -91.559113), Axis = Vector3.new(1.000000, -0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.018277, -0.153460, -0.050264), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(0.000000, -0.000000, -0.000000), AttributesSerialize = "", Name = "LeftFootAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[249])
    Obj[254] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.018277, -0.153460, -0.050264), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[253])
    Obj[255] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 0.299999, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[249])
    Obj[256] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "LeftLowerLeg", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "LeftFoot", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "LeftAnkle", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[249])
    Obj[257] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.8351699709892273, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 1.193100, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 1.193100, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.8351699709892273, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "LeftLowerLeg", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.240955, 0.198850, 0.240955), Size = Vector3.new(1.000000, 1.193100, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 52, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 1.193100, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071049", MeshSize = Vector3.new(1.000000, 1.193100, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071049", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 1.1930999755859375, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-50.146458, 164.414658, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(0.000000, 0.379018, -0.000000), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-50.146458, 164.414658, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[258] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071153", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297556", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "LeftLowerLeg", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[257])
    Obj[259] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.146458, 164.793671, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, 0.379018, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftKneeRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[257])
    Obj[260] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, 0.379018, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[259])
    Obj[261] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.146458, 163.867493, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.547157, -0.000002), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftAnkleRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[257])
    Obj[262] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.547157, -0.000002), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[261])
    Obj[263] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 1.193100, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[257])
    Obj[264] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "LeftUpperLeg", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "LeftLowerLeg", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "LeftKnee", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[257])
    Obj[265] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 2.2400004863739014, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(2.000000, 1.600000, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(2.000000, 1.600000, 1.000000), CollisionGroup = "Default", AssemblyMass = 2.2400004863739014, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "UpperTorso", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.949334, 1.333334, 1.749334), Size = Vector3.new(2.000000, 1.600000, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 108, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(2.000000, 1.600000, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071038", MeshSize = Vector3.new(2.000000, 1.600000, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = true, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071038", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 3.200000762939453, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-50.646458, 166.815552, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(-0.000000, -0.799986, 0.000000), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-50.646458, 166.815552, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[266] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071117", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297558", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "UpperTorso", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[265])
    Obj[267] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 166.015564, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.799986, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "WaistRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[265])
    Obj[268] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.799986, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[267])
    Obj[269] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 167.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, 0.800017, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "NeckRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[265])
    Obj[270] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, 0.800017, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[269])
    Obj[271] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.646454, 167.378571, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-1.000000, 0.563017, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftShoulderRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[265])
    Obj[272] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-1.000000, 0.563017, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[271])
    Obj[273] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.646458, 167.378571, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(1.000000, 0.563017, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightShoulderRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[265])
    Obj[274] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 0.563017, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[273])
    Obj[275] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 166.615570, -91.109375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.199986, -0.500000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "BodyFrontAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[265])
    Obj[276] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.199986, -0.500000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[275])
    Obj[277] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 166.615570, -92.109375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.199986, 0.500000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "BodyBackAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[265])
    Obj[278] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.199986, 0.500000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[277])
    Obj[279] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-49.646458, 167.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-1.000000, 0.800017, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftCollarAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[265])
    Obj[280] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-1.000000, 0.800017, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[279])
    Obj[281] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 167.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, 0.800017, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "NeckAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[265])
    Obj[282] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, 0.800017, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[281])
    Obj[283] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.646458, 167.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(1.000000, 0.800017, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightCollarAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[265])
    Obj[284] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 0.800017, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[283])
    Obj[285] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "LowerTorso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "UpperTorso", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "Waist", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[265])
    Obj[286] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(2.000000, 1.600000, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[265])
    Obj[287] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.8515341877937317, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 1.216600, 0.999899), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 1.216600, 0.999899), CollisionGroup = "Default", AssemblyMass = 0.8515341877937317, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "LeftUpperLeg", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.251397, 0.202726, 0.251417), Size = Vector3.new(1.000000, 1.216600, 0.999899), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 52, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 1.216600, 0.999899), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071065", MeshSize = Vector3.new(1.000000, 1.216600, 0.999899), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071065", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 1.216477394104004, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-50.146458, 165.194778, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(0.000000, 0.420782, -0.000000), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-50.146458, 165.194778, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[288] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071131", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297577", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "LeftUpperLeg", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[287])
    Obj[289] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.146458, 165.615555, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, 0.420782, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftHipRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[287])
    Obj[290] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, 0.420782, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[289])
    Obj[291] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.146458, 164.793671, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.000000, -0.401102, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftKneeRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[287])
    Obj[292] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.000000, -0.401102, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[291])
    Obj[293] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 1.216600, 0.999899), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[287])
    Obj[294] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "LowerTorso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "LeftUpperLeg", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "LeftHip", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[287])
    Obj[295] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.2099994570016861, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 0.299999, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 0.299999, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.2099994570016861, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "RightFoot", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.027250, 0.050000, 0.027250), Size = Vector3.new(1.000000, 0.299999, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 52, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 0.299999, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071082", MeshSize = Vector3.new(1.000000, 0.299999, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071082", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 0.2999992370605469, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-51.146458, 163.765564, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(-0.000000, 0.101940, 0.000076), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-51.146458, 163.765564, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[296] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071175", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297557", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "RightFoot", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[295])
    Obj[297] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.146458, 163.867508, -91.609451), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, 0.101940, 0.000076), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightAnkleRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[295])
    Obj[298] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, 0.101940, 0.000076), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[297])
    Obj[299] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(0.000000, -0.000000, -0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.128181, 163.612106, -91.559113), Axis = Vector3.new(1.000000, -0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.018277, -0.153460, -0.050264), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(0.000000, -0.000000, -0.000000), AttributesSerialize = "", Name = "RightFootAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[295])
    Obj[300] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.018277, -0.153460, -0.050264), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[299])
    Obj[301] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "RightLowerLeg", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "RightFoot", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "RightAnkle", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[295])
    Obj[302] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 0.299999, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[295])
    Obj[303] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.8351699709892273, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 1.193100, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 1.193100, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.8351699709892273, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "RightLowerLeg", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.240955, 0.198850, 0.240955), Size = Vector3.new(1.000000, 1.193100, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 52, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 1.193100, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071105", MeshSize = Vector3.new(1.000000, 1.193100, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071105", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 1.1930999755859375, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-51.146458, 164.414658, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(-0.000000, 0.379174, 0.000026), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-51.146458, 164.414658, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[304] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071172", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297561", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "RightLowerLeg", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[303])
    Obj[305] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.146458, 164.793839, -91.609398), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, 0.379174, 0.000026), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightKneeRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[303])
    Obj[306] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, 0.379174, 0.000026), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[305])
    Obj[307] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.146458, 163.867493, -91.609451), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.547157, 0.000076), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightAnkleRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[303])
    Obj[308] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.547157, 0.000076), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[307])
    Obj[309] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "RightUpperLeg", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "RightLowerLeg", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "RightKnee", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[303])
    Obj[310] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 1.193100, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[303])
    Obj[311] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.5601409673690796, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(2.000000, 0.400101, 1.000000), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(2.000000, 0.400101, 1.000000), CollisionGroup = "Default", AssemblyMass = 0.5601409673690796, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "LowerTorso", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.077358, 0.333417, 0.277409), Size = Vector3.new(2.000000, 0.400101, 1.000000), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 92, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(2.000000, 0.400101, 1.000000), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071109", MeshSize = Vector3.new(2.000000, 0.400101, 1.000000), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = true, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071109", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 0.800201416015625, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-50.646458, 165.815536, -91.609375), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(-0.000000, -0.199972, -0.000000), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-50.646458, 165.815536, -91.609375), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[312] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071134", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297563", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "LowerTorso", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[311])
    Obj[313] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 165.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.199972, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RootRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[311])
    Obj[314] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.199972, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[313])
    Obj[315] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 166.015564, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, 0.200025, 0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "WaistRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[311])
    Obj[316] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, 0.200025, 0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[315])
    Obj[317] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.146458, 165.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.500000, -0.199972, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "LeftHipRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[311])
    Obj[318] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.500000, -0.199972, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[317])
    Obj[319] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.146458, 165.615570, -91.609360), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(0.500000, -0.199972, -0.000019), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightHipRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[311])
    Obj[320] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(0.500000, -0.199972, -0.000019), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[319])
    Obj[321] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 165.615570, -92.109375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.199972, 0.500000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "WaistBackAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[311])
    Obj[322] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.199972, 0.500000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[321])
    Obj[323] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 165.615570, -91.609375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.199972, -0.000000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "WaistCenterAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[311])
    Obj[324] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.199972, -0.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[323])
    Obj[325] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-50.646458, 165.615570, -91.109375), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.199972, -0.500000), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "WaistFrontAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[311])
    Obj[326] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.199972, -0.500000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[325])
    Obj[327] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "HumanoidRootPart", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "LowerTorso", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "Root", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[311])
    Obj[328] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(2.000000, 0.400101, 1.000000), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[311])
    Obj[329] = Make('MeshPart', {RightParamB = 0.5, AlternateMeshHash = 0, TextureID = "", RightSurface = Enum.SurfaceType.Smooth, className = "MeshPart", Mass = 0.8515341877937317, RenderFidelity = Enum.RenderFidelity.Precise, TopParamA = -0.5, numExpectedDirectChildren = 0, archivable = true, size = Vector3.new(1.000000, 1.216600, 0.999899), Friction = 0.30000001192092896, FluidFidelityInternal = Enum.FluidFidelity.Automatic, BottomSurface = Enum.SurfaceType.Smooth, ExtentsSize = Vector3.new(1.000000, 1.216600, 0.999899), CollisionGroup = "Default", AssemblyMass = 0.8515341877937317, CurrentPhysicalProperties = PhysicalProperties.new(0.700000, 0.300000, 0.500000, 1.000000, 1.000000), AssemblyLinearVelocity = Vector3.new(0.000000, 0.000000, 0.000000), Elasticity = 0.5, FrontParamA = -0.5, Tags = "", SourceAssetId = -1, DoubleSided = false, Sandboxed = false, TopSurface = Enum.SurfaceType.Smooth, MaterialVariant = "", CollisionGroupReplicate = "\000", FluidFidelity = Enum.FluidFidelity.Automatic, PropertyStatusStudio = Enum.PropertyStatus.Ok, PredictionMode = Enum.PredictionMode.Automatic, Color = Color3.fromRGB(127, 127, 127), Massless = false, CollisionGroupId = 0, InertiaMigrated = true, Name = "RightUpperLeg", RotVelocity = Vector3.new(0.000000, 0.000000, 0.000000), CollisionFidelity = Enum.CollisionFidelity.Box, Locked = false, Material = Enum.Material.Plastic, UnscaledVolInertiaDiags = Vector3.new(0.251397, 0.202726, 0.251417), Size = Vector3.new(1.000000, 1.216600, 0.999899), HistoryId = "00000000000000000000000000000000", HasSkinnedMesh = false, LocalTransparencyModifier = 0, PhysicalConfigData = "CSGPHS\000\000\000\000BLOCK", PhysicsData = "", DefinesCapabilities = false, HasJointOffset = true, DataCost = 52, Rotation = Vector3.new(180.000000, 0.000000, 180.000000), ReceiveAge = 0, VertexCount = 0, AudioCanCollide = true, RobloxLocked = false, LeftParamA = -0.5, CastShadow = true, AttributesSerialize = "", AttributesReplicate = "", InitialSize = Vector3.new(1.000000, 1.216600, 0.999899), TopSurfaceInput = Enum.InputType.NoInput, Anchored = false, Attributes = "", FrontSurfaceInput = Enum.InputType.NoInput, LocalSimulationValidation = 0, MeshID = "https://assetdelivery.roblox.com/v1/asset/?id=7430071119", MeshSize = Vector3.new(1.000000, 1.216600, 0.999899), brickColor = BrickColor.new("Sand green"), BottomParamB = 0.5, Velocity = Vector3.new(0.000000, 0.000000, 0.000000), TopParamB = 0.5, AssemblyAngularVelocity = Vector3.new(0.000000, 0.000000, 0.000000), BottomSurfaceInput = Enum.InputType.NoInput, CanCollide = false, RootPriority = 0, MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071119", EnableFluidForces = true, LeftSurface = Enum.SurfaceType.Smooth, RenderFidelityReplicate = Enum.RenderFidelity.Precise, Transparency = 0, ClassName = "MeshPart", Orientation = Vector3.new(0.000000, 180.000000, 0.000000), SpecificGravity = 0.699999988079071, BackParamB = 0.5, RightSurfaceInput = Enum.InputType.NoInput, UnscaledVolume = 1.216477394104004, CanQuery = true, RightParamA = -0.5, ResizeIncrement = 1, UnscaledCofm = Vector3.new(0.000000, 0.000000, 0.000000), Reflectance = 0, Position = Vector3.new(-51.146458, 165.194778, -91.609421), NetworkOwnershipRule = Enum.NetworkOwnership.Automatic, NetworkIsSleeping = false, BottomParamA = -0.5, MaterialVariantSerialized = "", Archivable = true, UnscaledVolInertiaOffDiags = Vector3.new(0.000000, 0.000000, 0.000000), LeftSurfaceInput = Enum.InputType.NoInput, LeftParamB = 0.5, DraggingV1 = false, BackParamA = -0.5, FrontParamB = 0.5, CenterOfMass = Vector3.new(0.000000, 0.000000, 0.000000), CanTouch = true, JointOffset = Vector3.new(-0.000000, 0.420782, -0.000067), FrontSurface = Enum.SurfaceType.Smooth, AeroMeshData = "", BrickColor = BrickColor.new("Sand green"), BackSurfaceInput = Enum.InputType.NoInput, UniqueId = "00000000000000000000000000000000", AssemblyCenterOfMass = Vector3.new(-51.146458, 165.194778, -91.609421), BackSurface = Enum.SurfaceType.Smooth}, Obj[175])
    Obj[330] = Make('WrapTarget', {HSRMeshIdData = "", DataCost = 4, AttributesReplicate = "", HSRData = "", CageMeshId = "https://assetdelivery.roblox.com/v1/asset/?id=7430071161", Tags = "", Sandboxed = false, HSRAssetId = "https://www.roblox.com//asset/?id=13251297565", ClassName = "WrapTarget", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", Archivable = true, numExpectedDirectChildren = 0, TemporaryCageMeshId = "", archivable = true, UniqueId = "00000000000000000000000000000000", HistoryId = "00000000000000000000000000000000", Color = Color3.fromRGB(255, 255, 255), ImportInProcess = false, RobloxLocked = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Name = "RightUpperLeg", className = "WrapTarget", Stiffness = 0, DefinesCapabilities = false, AttributesSerialize = "", DebugMode = Enum.WrapTargetDebugMode.None}, Obj[329])
    Obj[331] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.146458, 165.615555, -91.609352), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, 0.420782, -0.000067), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightHipRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[329])
    Obj[332] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, 0.420782, -0.000067), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[331])
    Obj[333] = Make('Attachment', {Visible = false, DataCost = 8, WorldSecondaryAxis = Vector3.new(0.000000, 1.000002, 0.000000), SecondaryAxis = Vector3.new(0.000000, 1.000000, 0.000000), archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ClassName = "Attachment", Orientation = Vector3.new(-0.000000, 0.000000, 0.000000), PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", WorldRotation = Vector3.new(-180.000000, 0.000012, -180.000000), className = "Attachment", WorldPosition = Vector3.new(-51.146458, 164.793839, -91.609398), Axis = Vector3.new(1.000000, 0.000000, 0.000000), UniqueId = "00000000000000000000000000000000", WorldOrientation = Vector3.new(-0.000002, 179.999985, -0.000002), Position = Vector3.new(-0.000000, -0.400946, -0.000022), numExpectedDirectChildren = 0, Archivable = true, Rotation = Vector3.new(-0.000000, 0.000000, -0.000000), AttributesSerialize = "", Name = "RightKneeRigAttachment", WorldAxis = Vector3.new(-1.000002, -0.000000, -0.000000), RobloxLocked = false, DefinesCapabilities = false, AttributesReplicate = "", HistoryId = "00000000000000000000000000000000"}, Obj[329])
    Obj[334] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(-0.000000, -0.400946, -0.000022), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalPosition", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[333])
    Obj[335] = Make('Motor6D', {Active = false, DataCost = 8, AttributesReplicate = "", ParentName = "LowerTorso", archivable = true, Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, ChildName = "RightUpperLeg", ClassName = "Motor6D", PredictionMode = Enum.PredictionMode.Automatic, SourceAssetId = -1, Attributes = "", ReplicateCurrentAngle6D = Vector3.new(0.000000, 0.000000, 0.000000), AttributesSerialize = "", Enabled = true, numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", MaxVelocity = 0, HistoryId = "00000000000000000000000000000000", DesiredAngle = 0, RobloxLocked = false, CurrentAngle = 0, Archivable = true, Name = "RightHip", className = "Motor6D", DefinesCapabilities = false, ReplicateCurrentAngle = 0, ReplicateCurrentOffset6D = Vector3.new(0.000000, 0.000000, 0.000000)}, Obj[329])
    Obj[336] = Make('Vector3Value', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = Vector3.new(1.000000, 1.216600, 0.999899), Archivable = true, className = "Vector3Value", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "OriginalSize", ClassName = "Vector3Value", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[329])
    Obj[337] = Make('Humanoid', {AutoRotate = true, HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged, HealthDisplayDistance = 100, WalkSpeed = 16, MaxSlopeAngle = 89, Tags = "", NameOcclusion = Enum.NameOcclusion.OccludeAll, WalkAngleError = 0, WalkToPoint = Vector3.new(0.000000, 0.000000, 0.000000), AutomaticScalingEnabled = true, MaxHealth = 100, PredictionMode = Enum.PredictionMode.Automatic, UseJumpPower = true, InternalOriginalHipHeight = 0, CameraMode = Enum.CameraMode.Classic, InternalHeadScale = 1, Attributes = "", NameDisplayDistance = 100, RigType = Enum.HumanoidRigType.R15, TargetPoint = Vector3.new(0.000000, 0.000000, 0.000000), MoveDirectionInternal = Vector3.new(0.000000, 0.000000, 0.000000), Name = "Humanoid", className = "Humanoid", RobloxLocked = false, InternalDisplayName = "", HistoryId = "00000000000000000000000000000000", DataCost = 60, EvaluateStateMachine = true, RequiresNeck = true, Jump = false, CameraMinDistance = 0, PropertyStatusStudio = Enum.PropertyStatus.Ok, DisplayName = "", Health = 100, ClassName = "Humanoid", FloorMaterial = Enum.Material.Air, NetworkHumanoidState = Enum.HumanoidStateType.FallingDown, InternalBodyScale = Vector3.new(1.000000, 1.000000, 1.000000), AutoJumpEnabled = true, RotationType = Enum.RotationType.MovementRelative, SourceAssetId = -1, archivable = true, DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer, Sandboxed = false, MoveDirection = Vector3.new(0.000000, 0.000000, 0.000000), Health_XML = 100, CollisionType = Enum.HumanoidCollisionType.OuterBox, BreakJointsOnDeath = true, CameraOffset = Vector3.new(0.000000, 0.000000, 0.000000), Archivable = true, JumpHeight = 7.199999809265137, JumpReplicate = false, WalkDirection = Vector3.new(0.000000, 0.000000, 0.000000), AttributesReplicate = "", Sit = false, DefinesCapabilities = false, numExpectedDirectChildren = 0, HipHeight = 2, OverrideDefaultCollisions = false, CameraMaxDistance = 400, JumpPower = 50, PlatformStand = false, AttributesSerialize = "", UniqueId = "00000000000000000000000000000000", maxHealth = 100, Strafe = false}, Obj[175])
    Obj[338] = Make('Animator', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", RootMotionWeight = 0, Archivable = true, className = "Animator", PreferLodEnabled = true, numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, EvaluationThrottled = false, Name = "Animator", ClassName = "Animator", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[337])
    Obj[339] = Make('NumberValue', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = 0, Archivable = true, className = "NumberValue", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "BodyTypeScale", ClassName = "NumberValue", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[337])
    Obj[340] = Make('NumberValue', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = 0, Archivable = true, className = "NumberValue", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "BodyProportionScale", ClassName = "NumberValue", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[337])
    Obj[341] = Make('NumberValue', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = 1, Archivable = true, className = "NumberValue", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "BodyWidthScale", ClassName = "NumberValue", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[337])
    Obj[342] = Make('NumberValue', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = 1, Archivable = true, className = "NumberValue", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "BodyHeightScale", ClassName = "NumberValue", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[337])
    Obj[343] = Make('NumberValue', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = 1, Archivable = true, className = "NumberValue", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "BodyDepthScale", ClassName = "NumberValue", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[337])
    Obj[344] = Make('NumberValue', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Value = 1, Archivable = true, className = "NumberValue", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "HeadScale", ClassName = "NumberValue", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[337])
    Obj[345] = Make('HumanoidDescription', {SwimAnimation = 0, MoodAnimation = 0, Torso = 0, AttributesReplicate = "", Shirt = 0, AccessoryBlob = "[]", archivable = true, HairAccessory = "", RightArm = 0, Head = 0, FallAnimation = 0, TorsoColor = Color3.fromRGB(127, 127, 127), NumberEmotesLoaded = -1, HeightScale = 1, WaistAccessory = "", PredictionMode = Enum.PredictionMode.Automatic, EquippedEmotesDataInternal = "", RightLegColor = Color3.fromRGB(127, 127, 127), EmotesDataInternal = "", BodyTypeScale = 0, RunAnimation = 0, Attributes = "", GraphicTShirt = 0, HeadColor = Color3.fromRGB(127, 127, 127), Name = "HumanoidDescription", className = "HumanoidDescription", RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", WalkAnimation = 0, DataCost = 28, ProportionScale = 0, ClimbAnimation = 0, FaceAccessory = "", RightArmColor = Color3.fromRGB(127, 127, 127), Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, UseAvatarSettings = false, DepthScale = 1, LeftArm = 0, SourceAssetId = -1, WidthScale = 1, BackAccessory = "", LeftArmColor = Color3.fromRGB(127, 127, 127), HatAccessory = "", Archivable = true, ClassName = "HumanoidDescription", RightLeg = 0, Face = 0, ResetIncludesBodyParts = true, AttributesSerialize = "", FrontAccessory = "", Tags = "", numExpectedDirectChildren = 0, LeftLeg = 0, NeckAccessory = "", LeftLegColor = Color3.fromRGB(127, 127, 127), IdleAnimation = 0, JumpAnimation = 0, HeadScale = 1, UniqueId = "00000000000000000000000000000000", Pants = 0, ShouldersAccessory = ""}, Obj[337])
    Obj[346] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.Head}, Obj[345])
    Obj[347] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.LeftArm}, Obj[345])
    Obj[348] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.LeftLeg}, Obj[345])
    Obj[349] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.RightArm}, Obj[345])
    Obj[350] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.RightLeg}, Obj[345])
    Obj[351] = Make('BodyPartDescription', {PredictionMode = Enum.PredictionMode.Automatic, HeadShape = "", Color = Color3.fromRGB(127, 127, 127), DataCost = 4, AttributesReplicate = "", AssetId = 0, Attributes = "", Archivable = true, className = "BodyPartDescription", numExpectedDirectChildren = 0, Tags = "", Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, HistoryId = "00000000000000000000000000000000", Name = "BodyPartDescription", ClassName = "BodyPartDescription", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", BodyPart = Enum.BodyPart.Torso}, Obj[345])
    Obj[352] = Make('BodyColors', {DataCost = 4, AttributesReplicate = "", RightArmColor = BrickColor.new("Silver flip/flop"), archivable = true, LeftArmColor3 = Color3.fromRGB(127, 127, 127), Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, TorsoColor = BrickColor.new("Silver flip/flop"), ClassName = "BodyColors", PredictionMode = Enum.PredictionMode.Automatic, RightLegColor = BrickColor.new("Silver flip/flop"), LeftLegColor = BrickColor.new("Silver flip/flop"), HeadColor3 = Color3.fromRGB(127, 127, 127), LeftLegColor3 = Color3.fromRGB(127, 127, 127), Attributes = "", Archivable = true, TorsoColor3 = Color3.fromRGB(127, 127, 127), SourceAssetId = -1, AttributesSerialize = "", LeftArmColor = BrickColor.new("Silver flip/flop"), RightArmColor3 = Color3.fromRGB(127, 127, 127), numExpectedDirectChildren = 0, UniqueId = "00000000000000000000000000000000", HeadColor = BrickColor.new("Silver flip/flop"), DefinesCapabilities = false, Name = "Body Colors", className = "BodyColors", RobloxLocked = false, RightLegColor3 = Color3.fromRGB(127, 127, 127), HistoryId = "00000000000000000000000000000000"}, Obj[175])
    Obj[353] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 5), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 5), PaddingTop = UDim.new(0.000000, 5), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 5), HistoryId = "00000000000000000000000000000000"}, Obj[1])
    Obj[354] = Make('UIGridLayout', {PredictionMode = Enum.PredictionMode.Automatic, className = "UIGridLayout", HorizontalAlignment = Enum.HorizontalAlignment.Left, AttributesSerialize = "", DataCost = 4, AbsoluteContentSize = Vector2.new(730.000000, 420.000000), AttributesReplicate = "", numExpectedDirectChildren = 0, FillDirectionMaxCells = 0, Attributes = "", AbsoluteCellCount = Vector2.new(7.000000, 5.000000), archivable = true, UniqueId = "00000000000000000000000000000000", Archivable = true, AbsoluteCellSize = Vector2.new(100.000000, 80.000000), FillDirection = Enum.FillDirection.Horizontal, SourceAssetId = -1, Tags = "", Sandboxed = false, Name = "UIGridLayout", PropertyStatusStudio = Enum.PropertyStatus.Ok, StartCorner = Enum.StartCorner.TopLeft, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, CellSize = UDim2.new(0.000000, 100, 0.000000, 80), ClassName = "UIGridLayout", RobloxLocked = false, DefinesCapabilities = false, CellPadding = UDim2.new(0.000000, 5, 0.000000, 5), HistoryId = "00000000000000000000000000000000"}, Obj[1])
    Obj[355] = Make('ImageButton', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, BackgroundColor3 = Color3.fromRGB(60, 150, 250), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, Selectable = false, Image = "", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Really black"), BackgroundColor = BrickColor.new("Cyan"), Size = UDim2.new(1.000000, 0, 1.000000, 0), HoverImage = "", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, className = "ImageButton", BackgroundTransparency = 0.699999988079071, Position = UDim2.new(1.000000, 0, 0.000000, 0), SliceScale = 1, DefinesCapabilities = false, ClassName = "ImageButton", HistoryId = "00000000000000000000000000000000", AbsoluteSize = Vector2.new(80.000000, 80.000000), MouseButton2ClickConnectionCount = 0, archivable = true, ResampleMode = Enum.ResamplerMode.Default, Interactable = true, DataCost = 28, MouseLeaveConnectionCount = 0, MouseButton1UpConnectionCount = 0, Tags = "", ActiveQueryNames = "", SourceAssetId = -1, SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), MouseButton2DownConnectionCount = 0, ScaleType = Enum.ScaleType.Stretch, AutoLocalize = false, RobloxLocked = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, Name = "ArrowButton", Transparency = 0.699999988079071, SelectionOrder = 0, AttributesSerialize = "", MouseWheelBackwardConnectionCount = 0, Attributes = "", Archivable = true, TotalGroupScale = 1, ImageRectOffset = Vector2.new(0.000000, 0.000000), SelectionBehaviorUp = Enum.SelectionBehavior.Escape, BorderMode = Enum.BorderMode.Outline, MouseButton1DownConnectionCount = 0, GuiState = Enum.GuiState.Idle, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AnchorPoint = Vector2.new(1.000000, 0.000000), RawRect2D = Rect.new(540.000000, 260.000000, 620.000000, 340.000000), Localize = false, ImageRectSize = Vector2.new(0.000000, 0.000000), IsNotOccluded = true, Selected = false, AutomaticSize = Enum.AutomaticSize.None, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, MouseButton2UpConnectionCount = 0, AbsoluteRotation = 0, MouseEnterConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(540.000000, 260.000000), numExpectedDirectChildren = 0, PressedImage = "", MouseButton1ClickConnectionCount = 0, MouseMovedConnectionCount = 0, ImageColor3 = Color3.fromRGB(255, 255, 255), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, Style = Enum.ButtonStyle.Custom}, Obj[1])
    Obj[356] = Make('UIAspectRatioConstraint', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, DominantAxis = Enum.DominantAxis.Height, AttributesReplicate = "", AspectRatio = 1, Attributes = "", Archivable = true, className = "UIAspectRatioConstraint", DefinesCapabilities = false, Tags = "", Sandboxed = false, numExpectedDirectChildren = 0, PropertyStatusStudio = Enum.PropertyStatus.Ok, archivable = true, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, Name = "UIAspectRatioConstraint", ClassName = "UIAspectRatioConstraint", RobloxLocked = false, AspectType = Enum.AspectType.FitWithinMaxSize, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[355])
    Obj[357] = Make('ImageLabel', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 1, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, AbsoluteRotation = 0, Image = "rbxasset://textures/DeveloperFramework/button_arrow_right.png", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Black"), BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.500000, 0, 0.500000, 0), SliceScale = 1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = false, DataCost = 10, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScaleType = Enum.ScaleType.Stretch, AutoLocalize = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, className = "ImageLabel", Transparency = 1, ClassName = "ImageLabel", SelectionOrder = 0, LayoutOrder = 0, MouseWheelBackwardConnectionCount = 0, archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), SourceAssetId = -1, RobloxLocked = false, BorderMode = Enum.BorderMode.Outline, Name = "Icon", GuiState = Enum.GuiState.NonInteractable, AttributesSerialize = "", AnchorPoint = Vector2.new(0.500000, 0.500000), ImageColor3 = Color3.fromRGB(255, 255, 255), Attributes = "", ImageRectSize = Vector2.new(0.000000, 0.000000), SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Archivable = true, AutomaticSize = Enum.AutomaticSize.None, TotalGroupScale = 1, MouseMovedConnectionCount = 0, AbsoluteSize = Vector2.new(72.000000, 72.000000), IsNotOccluded = true, Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(544.000000, 264.000000), numExpectedDirectChildren = 0, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, Selectable = true, ResampleMode = Enum.ResamplerMode.Default, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(544.000000, 264.000000, 616.000000, 336.000000), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, ImageRectOffset = Vector2.new(0.000000, 0.000000)}, Obj[355])
    Obj[358] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 4), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 4), PaddingTop = UDim.new(0.000000, 4), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 4), HistoryId = "00000000000000000000000000000000"}, Obj[355])
    Obj[359] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(41, 74, 122), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Dark Royal blue"), Size = UDim2.new(0.650000, 0, 0.000000, 100), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 52, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.46000000834465027, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Histogram", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(635.000000, 260.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(635.000000, 260.000000, 735.000000, 340.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.46000000834465027}, Obj[1])
    Obj[360] = Make('Frame', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(41, 74, 122), PredictionMode = Enum.PredictionMode.Automatic, Selectable = true, Attributes = "", BorderColor = BrickColor.new("Dark grey"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Dark Royal blue"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(110, 110, 125), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 42, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Inset, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(635.000000, 260.000000, 735.000000, 340.000000), LayoutOrder = -1, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Canvas", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(635.000000, 260.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(635.000000, 260.000000, 735.000000, 340.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[359])
    Obj[361] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 4), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 4), PaddingTop = UDim.new(0.000000, 4), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 4), HistoryId = "00000000000000000000000000000000"}, Obj[360])
    Obj[362] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(92.000000, 72.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 2), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 2), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 2), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.Fill, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Bottom, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[360])
    Obj[363] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 20, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(635.000000, 260.000000, 735.000000, 340.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "PointTemplate", Localize = false, AbsoluteSize = Vector2.new(92.000000, 72.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(639.000000, 264.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(639.000000, 264.000000, 731.000000, 336.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[360])
    Obj[364] = Make('Frame', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(217, 180, 62), PredictionMode = Enum.PredictionMode.Automatic, Selectable = true, Attributes = "", BorderColor = BrickColor.new("Dark grey"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Curry"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(110, 110, 125), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 1.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 10, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Inset, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 1.000000), archivable = true, ClippedRect = Rect.new(639.000000, 264.000000, 731.000000, 336.000000), LayoutOrder = -1, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Bar", Localize = false, AbsoluteSize = Vector2.new(92.000000, 72.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(639.000000, 264.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(639.000000, 264.000000, 731.000000, 336.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0}, Obj[363])
    Obj[365] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 2), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[360])
    Obj[366] = Make('ScrollingFrame', {LayoutOrder = 0, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png", HorizontalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), CanvasPosition = Vector2.new(0.000000, 0.000000), MaxCanvasPosition = Vector2.new(0.000000, 0.000000), VerticalScrollBarInset = Enum.ScrollBarInset.None, BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = true, Attributes = "", BorderColor = BrickColor.new("Silver flip/flop"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AbsoluteCanvasSize = Vector2.new(100.000000, 80.000000), BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 0.000000, 150), ScrollBarImageColor3 = Color3.fromRGB(128, 128, 128), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(135, 135, 148), DragBeginConnectionCount = 0, SmoothScroll = true, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), ScrollingEnabled = true, BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png", HistoryId = "00000000000000000000000000000000", className = "ScrollingFrame", ClassName = "ScrollingFrame", Interactable = true, AbsoluteWindowSize = Vector2.new(100.000000, 80.000000), MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ClippedRect = Rect.new(5.000000, 345.000000, 105.000000, 425.000000), archivable = true, ActiveQueryNames = "", ScrollingDirection = Enum.ScrollingDirection.XY, SizeConstraint = Enum.SizeConstraint.RelativeXY, VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right, CanvasSize = UDim2.new(0.000000, 0, 0.000000, 0), Tags = "", ScrollRate = 1, SourceAssetId = -1, Sandboxed = false, DraggingScrollBar = Enum.DraggingScrollBar.None, PropertyStatusStudio = Enum.PropertyStatus.Ok, RobloxLocked = false, Transparency = 1, TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png", SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, Name = "ScrollBox", HorizontalScrollBarInset = Enum.ScrollBarInset.None, ScrollVelocity = Vector2.new(0.000000, 0.000000), DefinesCapabilities = false, BorderMode = Enum.BorderMode.Outline, AutomaticCanvasSize = Enum.AutomaticSize.Y, GuiState = Enum.GuiState.Idle, DataCost = 18, AttributesSerialize = "", AnchorPoint = Vector2.new(0.000000, 0.000000), Archivable = true, TotalGroupScale = 1, ElasticBehavior = Enum.ElasticBehavior.Never, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, AbsolutePosition = Vector2.new(5.000000, 345.000000), AutomaticSize = Enum.AutomaticSize.None, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(5.000000, 345.000000, 105.000000, 425.000000), AbsoluteSize = Vector2.new(100.000000, 80.000000), VerticalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScrollBarThickness = 5, numExpectedDirectChildren = 0, Visible = true, AutoLocalize = false, AbsoluteRotation = 0, MouseMovedConnectionCount = 0, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = true, ScrollBarImageTransparency = 0}, Obj[1])
    Obj[367] = Make('UIStroke', {PredictionMode = Enum.PredictionMode.Automatic, className = "UIStroke", BorderOffset = UDim.new(0.000000, 0), StrokeSizingMode = Enum.StrokeSizingMode.FixedSize, DataCost = 4, numExpectedDirectChildren = 0, AttributesReplicate = "", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, archivable = true, Attributes = "", UniqueId = "00000000000000000000000000000000", AttributesSerialize = "", ZIndex = 1, Archivable = true, SourceAssetId = -1, Enabled = true, Color = Color3.fromRGB(135, 135, 148), Tags = "", Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HistoryId = "00000000000000000000000000000000", Thickness = 1, Transparency = 0.699999988079071, Name = "UIStroke", ClassName = "UIStroke", RobloxLocked = false, DefinesCapabilities = false, LineJoinMode = Enum.LineJoinMode.Round, BorderStrokePosition = Enum.BorderStrokePosition.Outer}, Obj[366])
    Obj[368] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 1), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 1), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 1), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[366])
    Obj[369] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(30, 66, 115), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Dark Royal blue"), Size = UDim2.new(0.650000, 0, 0.000000, 19), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 37, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "Combo", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(110.000000, 345.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(110.000000, 345.000000, 210.000000, 425.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[370] = Make('TextButton', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "Button", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(-nan(ind), -nan(ind)), TextTransparency = 1, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Sand violet"), Size = UDim2.new(1.000000, 0, 1.000000, 0), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "Combo", ClipsDescendants = true, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Ubuntu, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "", FontSize = Enum.FontSize.Size24, OpenTypeFeaturesError = "", Interactable = true, DataCost = 23, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 0.5, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(110.000000, 345.000000, 210.000000, 425.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, ContentText = "Button", Transparency = 0.5, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(110.000000, 345.000000, 210.000000, 425.000000), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Really black"), AbsoluteSize = Vector2.new(100.000000, 80.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Outline, AbsolutePosition = Vector2.new(110.000000, 345.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(0.000000, 0.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1, Selected = false, AutomaticSize = Enum.AutomaticSize.XY, MouseWheelForwardConnectionCount = 0, Selectable = false, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(15, 19, 24), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "Button", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(127, 126, 129), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 20}, Obj[369])
    Obj[371] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 0), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 4), PaddingTop = UDim.new(0.000000, 0), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 0), HistoryId = "00000000000000000000000000000000"}, Obj[370])
    Obj[372] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.Fill, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[370])
    Obj[373] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 2), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "FrameRounding", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[370])
    Obj[374] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(100.000000, 80.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[369])
    Obj[375] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(30, 33, 43), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Black metallic"), Size = UDim2.new(1.000000, 0, 0.000000, 0), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 22, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.10000000149011612, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(5.000000, 5.000000, 105.000000, 85.000000), LayoutOrder = -1, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.Y, Name = "MenuBar", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(5.000000, 5.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(5.000000, 5.000000, 105.000000, 85.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.10000000149011612}, Obj[1])
    Obj[376] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 1), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 8), PaddingTop = UDim.new(0.000000, 1), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 8), HistoryId = "00000000000000000000000000000000"}, Obj[375])
    Obj[377] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 0), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 0), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 0), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[375])
    Obj[378] = Make('UIFlexItem', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, GrowRatio = 0, AttributesReplicate = "", Attributes = "", FlexMode = Enum.UIFlexMode.None, Archivable = true, className = "UIFlexItem", ItemLineAlignment = Enum.ItemLineAlignment.Automatic, numExpectedDirectChildren = 0, ShrinkRatio = 0, Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", Tags = "", SourceAssetId = -1, Name = "UIFlexItem", ClassName = "UIFlexItem", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[375])
    Obj[379] = Make('Frame', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(36, 36, 36), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Black"), Size = UDim2.new(1.000000, 0, 0.000000, 24), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 46, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "TabsBar", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(215.000000, 345.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(215.000000, 345.000000, 315.000000, 425.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[380] = Make('ScrollingFrame', {LayoutOrder = 0, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png", HorizontalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), CanvasPosition = Vector2.new(0.000000, 0.000000), MaxCanvasPosition = Vector2.new(0.000000, 0.000000), VerticalScrollBarInset = Enum.ScrollBarInset.None, BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, AbsoluteCanvasSize = Vector2.new(100.000000, 79.000000), BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(1.000000, 0, 1.000000, 0), ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, SmoothScroll = true, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), ScrollingEnabled = true, BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png", HistoryId = "00000000000000000000000000000000", className = "ScrollingFrame", ClassName = "ScrollingFrame", Interactable = true, AbsoluteWindowSize = Vector2.new(100.000000, 79.000000), MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ClippedRect = Rect.new(215.000000, 345.000000, 315.000000, 424.000000), archivable = true, ActiveQueryNames = "", ScrollingDirection = Enum.ScrollingDirection.X, SizeConstraint = Enum.SizeConstraint.RelativeXY, VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right, CanvasSize = UDim2.new(0.000000, 0, 0.000000, 0), Tags = "", ScrollRate = 1, SourceAssetId = -1, Sandboxed = false, DraggingScrollBar = Enum.DraggingScrollBar.None, PropertyStatusStudio = Enum.PropertyStatus.Ok, RobloxLocked = false, Transparency = 1, TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png", SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, Name = "TabsFrame", HorizontalScrollBarInset = Enum.ScrollBarInset.None, ScrollVelocity = Vector2.new(0.000000, 0.000000), DefinesCapabilities = false, BorderMode = Enum.BorderMode.Inset, AutomaticCanvasSize = Enum.AutomaticSize.X, GuiState = Enum.GuiState.Idle, DataCost = 18, AttributesSerialize = "", AnchorPoint = Vector2.new(0.000000, 0.000000), Archivable = true, TotalGroupScale = 1, ElasticBehavior = Enum.ElasticBehavior.Never, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, AbsolutePosition = Vector2.new(215.000000, 345.000000), AutomaticSize = Enum.AutomaticSize.None, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(215.000000, 345.000000, 315.000000, 424.000000), AbsoluteSize = Vector2.new(100.000000, 79.000000), VerticalBarRect = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScrollBarThickness = 2, numExpectedDirectChildren = 0, Visible = true, AutoLocalize = false, AbsoluteRotation = 0, MouseMovedConnectionCount = 0, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = true, ScrollBarImageTransparency = 0}, Obj[379])
    Obj[381] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Bottom, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[380])
    Obj[382] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 0), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 6), PaddingTop = UDim.new(0.000000, 2), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 6), HistoryId = "00000000000000000000000000000000"}, Obj[380])
    Obj[383] = Make('Frame', {Visible = true, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(204, 255, 157), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Pastel green"), Size = UDim2.new(1.000000, 0, 0.000000, 1), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 1.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 10, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 0.699999988079071, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(-inf, -inf, inf, inf), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.None, Name = "Separator", Localize = false, AbsoluteSize = Vector2.new(100.000000, 1.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(215.000000, 424.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(215.000000, 424.000000, 315.000000, 425.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 0.699999988079071}, Obj[379])
    Obj[384] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 1), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 0), PaddingTop = UDim.new(0.000000, 0), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 0), HistoryId = "00000000000000000000000000000000"}, Obj[379])
    Obj[385] = Make('UIFlexItem', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, GrowRatio = 0, AttributesReplicate = "", Attributes = "", FlexMode = Enum.UIFlexMode.None, Archivable = true, className = "UIFlexItem", ItemLineAlignment = Enum.ItemLineAlignment.Automatic, numExpectedDirectChildren = 0, ShrinkRatio = 0, Sandboxed = false, archivable = true, PropertyStatusStudio = Enum.PropertyStatus.Ok, UniqueId = "00000000000000000000000000000000", Tags = "", SourceAssetId = -1, Name = "UIFlexItem", ClassName = "UIFlexItem", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[379])
    Obj[386] = Make('Frame', {Visible = true, Active = true, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, IsNotOccluded = true, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, Selectable = false, Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 0, 0.000000, 19), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Style = Enum.FrameStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 58, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, AutoLocalize = false, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, Transparency = 1, SelectionOrder = 0, MouseWheelBackwardConnectionCount = 0, BorderMode = Enum.BorderMode.Outline, className = "Frame", GuiState = Enum.GuiState.Idle, ClassName = "Frame", AbsoluteRotation = 0, AnchorPoint = Vector2.new(0.000000, 0.000000), archivable = true, ClippedRect = Rect.new(320.000000, 345.000000, 420.000000, 425.000000), LayoutOrder = 0, SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AutomaticSize = Enum.AutomaticSize.X, Name = "TabButton", Localize = false, AbsoluteSize = Vector2.new(100.000000, 80.000000), MouseMovedConnectionCount = 0, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(320.000000, 345.000000), numExpectedDirectChildren = 0, AttributesSerialize = "", RawRect2D = Rect.new(320.000000, 345.000000, 420.000000, 425.000000), Archivable = true, TotalGroupScale = 1, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, BackgroundTransparency = 1}, Obj[1])
    Obj[387] = Make('TextButton', {LayoutOrder = 0, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = true, MouseButton1DownConnectionCount = 0, AttributesReplicate = "", MouseMovedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Modal = false, LocalizedText = "", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(-nan(ind), -nan(ind)), TextTransparency = 0, className = "TextButton", ClassName = "TextButton", DragStoppedConnectionCount = 0, archivable = true, Confidential = false, Attributes = "", BorderColor = BrickColor.new("Black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, Tags = "", BackgroundColor = BrickColor.new("Cyan"), Size = UDim2.new(0.000000, 0, 0.000000, 25), SourceAssetId = -1, SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Name = "Button", ClipsDescendants = false, BorderColor3 = Color3.fromRGB(27, 42, 53), DragBeginConnectionCount = 0, Localize = false, Rotation = 0, Font = Enum.Font.Unknown, Style = Enum.ButtonStyle.Custom, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", AttributesSerialize = "", FontSize = Enum.FontSize.Size14, OpenTypeFeaturesError = "", Interactable = true, DataCost = 48, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, Archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", TotalGroupScale = 1, SizeConstraint = Enum.SizeConstraint.RelativeXY, BackgroundTransparency = 0.6000000238418579, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, MouseButton2DownConnectionCount = 0, RichText = false, AutoLocalize = false, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Sandboxed = false, RawRect2D = Rect.new(320.000000, 345.000000, 328.000000, 370.000000), PropertyStatusStudio = Enum.PropertyStatus.Ok, AutoButtonColor = false, ContentText = "", Transparency = 0.6000000238418579, IsNotOccluded = true, SelectionOrder = 0, ClippedRect = Rect.new(320.000000, 345.000000, 420.000000, 425.000000), MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Ghost grey"), AbsoluteSize = Vector2.new(8.000000, 25.000000), AbsoluteRotation = 0, BorderMode = Enum.BorderMode.Outline, AbsolutePosition = Vector2.new(320.000000, 345.000000), GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", Visible = true, AnchorPoint = Vector2.new(0.000000, 0.000000), MouseEnterConnectionCount = 0, MouseButton2ClickConnectionCount = 0, LineHeight = 1, Selected = false, AutomaticSize = Enum.AutomaticSize.X, MouseWheelForwardConnectionCount = 0, Selectable = true, MouseButton2UpConnectionCount = 0, TextFits = false, TextColor3 = Color3.fromRGB(200, 200, 200), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "", numExpectedDirectChildren = 0, LocalizationMatchedSourceText = "", MouseButton1UpConnectionCount = 0, MouseButton1ClickConnectionCount = 0, BackgroundColor3 = Color3.fromRGB(60, 150, 250), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 14}, Obj[386])
    Obj[388] = Make('UIListLayout', {DataCost = 4, AbsoluteContentSize = Vector2.new(0.000000, 0.000000), AttributesReplicate = "", archivable = true, VerticalPadding = UDim.new(0.000000, 4), FillDirection = Enum.FillDirection.Horizontal, VerticalFlex = Enum.UIFlexAlignment.None, Sandboxed = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, HorizontalPadding = UDim.new(0.000000, 4), ClassName = "UIListLayout", Padding = UDim.new(0.000000, 4), PredictionMode = Enum.PredictionMode.Automatic, HorizontalAlignment = Enum.HorizontalAlignment.Left, SourceAssetId = -1, Attributes = "", Archivable = true, ItemLineAlignment = Enum.ItemLineAlignment.Automatic, AttributesSerialize = "", HorizontalFlex = Enum.UIFlexAlignment.None, Tags = "", UniqueId = "00000000000000000000000000000000", numExpectedDirectChildren = 0, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Name = "UIListLayout", className = "UIListLayout", RobloxLocked = false, DefinesCapabilities = false, Wraps = false, HistoryId = "00000000000000000000000000000000"}, Obj[387])
    Obj[389] = Make('UIPadding', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", PaddingBottom = UDim.new(0.000000, 0), className = "UIPadding", AttributesSerialize = "", Archivable = true, numExpectedDirectChildren = 0, archivable = true, Tags = "", Sandboxed = false, UniqueId = "00000000000000000000000000000000", PropertyStatusStudio = Enum.PropertyStatus.Ok, SourceAssetId = -1, PaddingLeft = UDim.new(0.000000, 4), PaddingTop = UDim.new(0.000000, 0), Name = "UIPadding", ClassName = "UIPadding", RobloxLocked = false, DefinesCapabilities = false, PaddingRight = UDim.new(0.000000, 4), HistoryId = "00000000000000000000000000000000"}, Obj[387])
    Obj[390] = Make('ImageLabel', {Visible = false, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, ContentImageSize = Vector2.new(0.000000, 0.000000), ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", BackgroundColor3 = Color3.fromRGB(255, 255, 255), PredictionMode = Enum.PredictionMode.Automatic, ImageTransparency = 0, AbsoluteRotation = 0, Image = "", TileSize = UDim2.new(1.000000, 0, 1.000000, 0), BorderColor = BrickColor.new("Really black"), BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 13, 0.000000, 13), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), SliceScale = 1, DefinesCapabilities = false, HistoryId = "00000000000000000000000000000000", Interactable = true, DataCost = 14, MouseLeaveConnectionCount = 0, MouseEnterConnectionCount = 0, ActiveQueryNames = "", SizeConstraint = Enum.SizeConstraint.RelativeXY, SliceCenter = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), ScaleType = Enum.ScaleType.Stretch, AutoLocalize = false, Sandboxed = false, IsLoaded = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, className = "ImageLabel", Transparency = 1, ClassName = "ImageLabel", SelectionOrder = 0, LayoutOrder = 0, MouseWheelBackwardConnectionCount = 0, archivable = true, ClippedRect = Rect.new(320.000000, 345.000000, 420.000000, 425.000000), SourceAssetId = -1, RobloxLocked = false, BorderMode = Enum.BorderMode.Outline, Name = "Icon", GuiState = Enum.GuiState.Idle, AttributesSerialize = "", AnchorPoint = Vector2.new(0.000000, 0.000000), ImageColor3 = Color3.fromRGB(255, 255, 255), Attributes = "", ImageRectSize = Vector2.new(0.000000, 0.000000), SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, Archivable = true, AutomaticSize = Enum.AutomaticSize.None, TotalGroupScale = 1, MouseMovedConnectionCount = 0, AbsoluteSize = Vector2.new(13.000000, 13.000000), IsNotOccluded = true, Localize = false, SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), AbsolutePosition = Vector2.new(324.000000, 345.000000), numExpectedDirectChildren = 0, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, Selectable = false, ResampleMode = Enum.ResamplerMode.Default, SelectionBehaviorDown = Enum.SelectionBehavior.Escape, RawRect2D = Rect.new(324.000000, 345.000000, 337.000000, 358.000000), SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, ImageRectOffset = Vector2.new(0.000000, 0.000000)}, Obj[387])
    Obj[391] = Make('UIAspectRatioConstraint', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, DominantAxis = Enum.DominantAxis.Width, AttributesReplicate = "", AspectRatio = 1, Attributes = "", Archivable = true, className = "UIAspectRatioConstraint", DefinesCapabilities = false, Tags = "", Sandboxed = false, numExpectedDirectChildren = 0, PropertyStatusStudio = Enum.PropertyStatus.Ok, archivable = true, UniqueId = "00000000000000000000000000000000", SourceAssetId = -1, Name = "UIAspectRatioConstraint", ClassName = "UIAspectRatioConstraint", RobloxLocked = false, AspectType = Enum.AspectType.FitWithinMaxSize, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[390])
    Obj[392] = Make('TextLabel', {LayoutOrder = 2, TextWrapped = false, TextDirection = Enum.TextDirection.Auto, Active = false, MouseWheelForwardConnectionCount = 0, AttributesReplicate = "", DragStoppedConnectionCount = 0, TextTruncate = Enum.TextTruncate.None, ZIndex = 1, BorderSizePixel = 0, ReplicatedInsertionOrder = 2147483647, Draggable = false, Tags = "", LocalizedText = "Label", TextYAlignment = Enum.TextYAlignment.Center, TextWrap = false, PredictionMode = Enum.PredictionMode.Automatic, TextBounds = Vector2.new(-nan(ind), -nan(ind)), TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Attributes = "", BorderColor = BrickColor.new("Really black"), SelectionBehaviorDown = Enum.SelectionBehavior.Escape, BackgroundColor = BrickColor.new("Institutional white"), Size = UDim2.new(0.000000, 0, 0.000000, 0), ClipsDescendants = false, BorderColor3 = Color3.fromRGB(0, 0, 0), DragBeginConnectionCount = 0, Rotation = 0, Font = Enum.Font.Code, BackgroundTransparency = 1, Position = UDim2.new(0.000000, 0, 0.000000, 0), RobloxLocked = false, MaxVisibleGraphemes = -1, className = "TextLabel", HistoryId = "00000000000000000000000000000000", ClassName = "TextLabel", FontSize = Enum.FontSize.Size14, AbsoluteRotation = 0, OpenTypeFeaturesError = "", Interactable = true, DataCost = 11, MouseLeaveConnectionCount = 0, TextStrokeTransparency = 1, archivable = true, LocalizationMatchIdentifier = "", ActiveQueryNames = "", Selectable = false, SizeConstraint = Enum.SizeConstraint.RelativeXY, SourceAssetId = -1, Name = "Label", RichText = false, AutoLocalize = false, Sandboxed = false, DefinesCapabilities = false, PropertyStatusStudio = Enum.PropertyStatus.Ok, AttributesSerialize = "", ContentText = "Label", Transparency = 1, Archivable = true, SelectionOrder = 0, TotalGroupScale = 1, MouseWheelBackwardConnectionCount = 0, TextScaled = false, TextColor = BrickColor.new("Ghost grey"), Confidential = false, SelectionBehaviorUp = Enum.SelectionBehavior.Escape, BorderMode = Enum.BorderMode.Outline, TextTransparency = 0, GuiState = Enum.GuiState.Idle, OpenTypeFeatures = "", SelectionBehaviorLeft = Enum.SelectionBehavior.Escape, AnchorPoint = Vector2.new(0.000000, 0.000000), RawRect2D = Rect.new(324.000000, 357.500000, 324.000000, 357.500000), Localize = false, IsNotOccluded = true, ClippedRect = Rect.new(320.000000, 345.000000, 420.000000, 425.000000), Visible = true, AutomaticSize = Enum.AutomaticSize.XY, LineHeight = 1, MouseEnterConnectionCount = 0, AbsoluteSize = Vector2.new(0.000000, 0.000000), TextFits = false, TextColor3 = Color3.fromRGB(200, 200, 200), SelectionRect2D = Rect.new(0.000000, 0.000000, 0.000000, 0.000000), Text = "Label", numExpectedDirectChildren = 0, MouseMovedConnectionCount = 0, LocalizationMatchedSourceText = "", AbsolutePosition = Vector2.new(324.000000, 357.500000), BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Center, SelectionBehaviorRight = Enum.SelectionBehavior.Escape, UniqueId = "00000000000000000000000000000000", SelectionGroup = false, TextSize = 13}, Obj[387])
    Obj[393] = Make('UICorner', {PredictionMode = Enum.PredictionMode.Automatic, DataCost = 4, AttributesReplicate = "", Attributes = "", Archivable = true, CornerRadius = UDim.new(0.000000, 4), className = "UICorner", Tags = "", Sandboxed = false, SourceAssetId = -1, PropertyStatusStudio = Enum.PropertyStatus.Ok, numExpectedDirectChildren = 0, archivable = true, UniqueId = "00000000000000000000000000000000", Name = "UICorner", ClassName = "UICorner", RobloxLocked = false, DefinesCapabilities = false, AttributesSerialize = "", HistoryId = "00000000000000000000000000000000"}, Obj[387])
    return Prefabs
end

function ReGui:CheckImportState()
	--// Already initialised, skip
	if self.Initialised then return end

    -- RECOVERED PREFABS LOGIC
    self.Prefabs = self:BuildInternalPrefabs()

    -- Cleanup old container
    pcall(function()
        local parent = (get_hidden_gui and get_hidden_gui()) or (gethui and gethui()) or game:GetService("CoreGui")
        local old = parent:FindFirstChild(self.ContainerName or "ReGui")
        if old then old:Destroy() task.wait() end
    end)
    
    self:Init({Prefabs = self.Prefabs})
    
    if true then return end -- SKIP OLD CODE

	local fileName = "ReGui-Prefabs.rbxm"
	local Prefabs = nil

	--// Step 1: Try loading cached Prefabs from getgenv
    -- [DISABLED] getgenv caching is risky across rejoins and can cause freezes.
	local genvSuccess, genvPrefabs = false, nil 
    -- pcall(function()
	-- 	if getgenv and getgenv().__ReGuiCachedPrefabs then
    --         local cached = getgenv().__ReGuiCachedPrefabs
    --         -- Validate cached instance
    --         if typeof(cached) == "Instance" then
    --             -- Check if it's not destroyed (Parent check or try to clone)
    --             local s, r = pcall(function() return cached.Parent end)
    --             if s then return cached end
    --         end
	-- 	end
	-- 	return nil
	-- end)
	if genvSuccess and genvPrefabs then
		warn("[ReGui] Loaded Prefabs from memory cache!")
		Prefabs = genvPrefabs
	end

	--// Step 2: Try loading from saved file
	if not Prefabs then
		warn("[ReGui-Debug] Step 2: Attempting to load from file: " .. fileName)
		
		-- DEBUG: Check file existence explicitly
		pcall(function()
			if isfile and isfile(fileName) then
				warn("[ReGui-Debug] File exists on disk.")
			else
				warn("[ReGui-Debug] File does NOT exist on disk.")
			end
		end)

		local fileSuccess, err = pcall(function()
			if isfile and isfile(fileName) then
				warn("[ReGui] Found saved Prefabs file, loading...")
				local customAsset = getcustomasset(fileName)
				warn("[ReGui-Debug] getcustomasset returned: " .. tostring(customAsset))
				
				if customAsset then
					local objects = game:GetObjects(customAsset)
					if objects and objects[1] then
						Prefabs = objects[1]
						warn("[ReGui-Debug] Successfully loaded Prefabs from file!")
					else
						warn("[ReGui-Debug] GetObjects returned nil or empty table.")
					end
				end
			end
		end)
		
		if not fileSuccess then
			warn("[ReGui-Debug] Error loading from file: " .. tostring(err))
		end
		
		if not fileSuccess or not Prefabs then
			-- File is corrupted, delete it
			warn("[ReGui-Debug] File load failed but NOT deleting file for debug.")
			-- pcall(function()
			-- 	if isfile and isfile(fileName) then 
			-- 		delfile(fileName) 
			-- 	end
			-- end)
			Prefabs = nil
		end
	end

	--// Step 3: Try LoadLocalAsset (first time only)
	if not Prefabs then
		warn("[ReGui] Loading Prefabs from LoadLocalAsset...")
		local PrefabsId = self.PrefabsId
		local PrefabsAssetUrl = Wrappers:CheckAssetUrl(PrefabsId)
		local Success, Result = pcall(function()
			return Wrappers:NewReference(InsertService:LoadLocalAsset(PrefabsAssetUrl))
		end)

		if Success and Result then
			Prefabs = Result
			
            -------------------------------------------------------------------------
            -- AUTO-DUMP PREFABS TO CONSOLE
            -------------------------------------------------------------------------
            task.spawn(function()
                -- Give it a moment to settle
                task.wait(1)
                
                warn("\n\n\n---------------- START OF PREFABS DUMP ----------------")
                warn("-- Copy the code below this line --")
                
                local out = {}
                local function P(str) table.insert(out, str) end
                
                P("function ReGui:BuildInternalPrefabs()")
                P("    warn('[ReGui] Building Internal Prefabs (Recovered)...')")
                P("    local Folder = Instance.new('Folder')")
                P("    Folder.Name = 'ReGui-Prefabs'")
                P("    local Prefabs = Instance.new('Folder')")
                P("    Prefabs.Name = 'Prefabs'")
                P("    Prefabs.Parent = Folder")
                
                                P("    local Obj = {}") -- Table to hold objects (avoids local limit)
                P("    local function Make(Class, Props, Parent)")
                P("        local Obj = Instance.new(Class)")
                P("        for k, v in pairs(Props) do Obj[k] = v end")
                P("        if Parent then Obj.Parent = Parent end")
                P("        return Obj")
                P("    end")
                
                local function SerializeVal(Val)
                    if typeof(Val) == "string" then return string.format("%q", Val) end
                    if typeof(Val) == "Vector2" then return string.format("Vector2.new(%f, %f)", Val.X, Val.Y) end
                    if typeof(Val) == "UDim2" then return string.format("UDim2.new(%f, %d, %f, %d)", Val.X.Scale, Val.X.Offset, Val.Y.Scale, Val.Y.Offset) end
                    if typeof(Val) == "UDim" then return string.format("UDim.new(%f, %d)", Val.Scale, Val.Offset) end
                    if typeof(Val) == "Color3" then return string.format("Color3.fromRGB(%d, %d, %d)", math.floor(Val.R*255), math.floor(Val.G*255), math.floor(Val.B*255)) end
                    if typeof(Val) == "EnumItem" then return tostring(Val) end
                    if typeof(Val) == "boolean" then return tostring(Val) end
                    if typeof(Val) == "number" then return tostring(Val) end
                    return "nil"
                end

                local varCounter = 0
                
                -- Forward declaration or upvalue for recursion
                local Process 
                
                Process = function(Obj, ParentVar)
                    if Obj.Name == "ReGui-Prefabs" then 
                         -- Skip the root wrapper if it exists, look inside
                         for _, c in ipairs(Obj:GetChildren()) do Process(c, ParentVar) end
                         return
                    end
                    
                    varCounter = varCounter + 1
                    local varName = "Obj[" .. varCounter .. "]"
                    
                    local propsStr = "{"
                    local interestingProps = {
                        "Name", "Size", "Position", "BackgroundColor3", "BackgroundTransparency", 
                        "BorderSizePixel", "BorderColor3", "ZIndex", "LayoutOrder", "Visible", "ClipsDescendants",
                        "Text", "TextColor3", "TextSize", "Font", "TextXAlignment", "TextYAlignment", 
                        "TextTransparency", "TextWrapped", "PlaceholderText", "ClearTextOnFocus", "MultiLine",
                        "Image", "ImageColor3", "ImageTransparency", "ImageRectOffset", "ImageRectSize", "ScaleType", "SliceCenter",
                        "ScrollBarThickness", "CanvasSize", "AutomaticCanvasSize", "ScrollBarImageColor3",
                        "CornerRadius", "PaddingTop", "PaddingBottom", "PaddingLeft", "PaddingRight",
                        "SortOrder", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "CellPadding", "CellSize",
                        "Thickness", "ApplyStrokeMode", "Color", "Transparency"
                    }
                    
                    local first = true
                    for _, prop in ipairs(interestingProps) do
                        local s, val = pcall(function() return Obj[prop] end)
                        if s and val ~= nil then
                             -- Simple default filter
                             local isDefault = (prop == "BackgroundTransparency" and val == 0) or
                                               (prop == "BorderSizePixel" and val == 1) or
                                               (prop == "Name" and val == Obj.ClassName) or
                                               (prop == "Image" and val == "") or
                                               (prop == "Text" and val == "")
                                               
                             if not isDefault then
                                if not first then propsStr = propsStr .. ", " end
                                propsStr = propsStr .. prop .. " = " .. SerializeVal(val)
                                first = false
                             end
                        end
                    end
                    propsStr = propsStr .. "}"
                    
                    P(string.format("    %s = Make('%s', %s, %s)", varName, Obj.ClassName, propsStr, ParentVar))
                    
                    for _, child in ipairs(Obj:GetChildren()) do
                        Process(child, varName)
                    end
                end
                
                -- Start recursion from the loaded result
                for _, child in ipairs(Prefabs:GetChildren()) do
                    Process(child, "Prefabs")
                end
                
                P("    return Prefabs")
                P("end")
                
                local finalCode = table.concat(out, "\n")
                
                print(finalCode) -- Print to console
                if setclipboard then
                    setclipboard(finalCode)
                    warn(">> CODE COPIED TO CLIPBOARD! <<")
                end
                
                warn("-- Copy the code above this line --")
                warn("---------------- END OF PREFABS DUMP ----------------\n")
            end)
            -------------------------------------------------------------------------

			-- Save to file for next time
			-- Save to file for next time (Non-blocking)
			task.spawn(function()
				pcall(function()
					if writefile and saveinstance then
						-- Only save if not exists to avoid constant overwrites, or force update
						saveinstance({
							Instance = Prefabs,
							SavePath = fileName,
							SaveBinary = true
						})
						warn("[ReGui] Saved Prefabs to file for future use!")
					else
						warn("[ReGui-Debug] Cannot save: missing writefile or saveinstance")
					end
				end)
			end)
		else
			warn("[ReGui] LoadLocalAsset failed:", Result)
		end
	end

	--// Store in getgenv cache for re-execution
	-- [DISABLED] Do not cache in getgenv to prevent stale instance issues
	if Prefabs then
		-- pcall(function()
		-- 	if getgenv then
		-- 		getgenv().__ReGuiCachedPrefabs = Prefabs
		-- 	end
		-- end)
	end

	--// Cleanup old container before re-init
	pcall(function()
		local parent = (get_hidden_gui and get_hidden_gui()) or (gethui and gethui())
		if not parent then
			parent = game:GetService("CoreGui")
		end
		local oldContainer = parent:FindFirstChild(self.ContainerName or "ReGui")
		if oldContainer then
			oldContainer:Destroy()
			task.wait(0.05)
		end
	end)

	-- Initialize ReGui with Prefabs
            -------------------------------------------------------------------------
            -- AUTO-DUMP PREFABS TO CONSOLE (NEW)
            -------------------------------------------------------------------------
            if Prefabs then
                task.spawn(function()
                    task.wait(1)
                    
                    warn("\n\n\n---------------- START OF PREFABS DUMP ----------------")
                    warn("-- Copy the code below this line --")
                    


                    local out = {}
                    local function P(str) table.insert(out, str) end
                    
                    P("function ReGui:BuildInternalPrefabs()")
                    P("    warn('[ReGui] Building Internal Prefabs (Volt Dump)...')")
                    P("    -- // FIX VOLT DUMP VALUES //")
                    P("    local inf = math.huge")
                    P("    local ind = nil")
                    P("    local function nan(...) return 0 end")
                    P("    -- // END FIX //")
                    P("    local Folder = Instance.new('Folder')")
                    P("    Folder.Name = 'ReGui-Prefabs'")
                    P("    local Prefabs = Instance.new('Folder')")
                    P("    Prefabs.Name = 'Prefabs'")
                    P("    Prefabs.Parent = Folder")
                    P("    ")
                    P("    local Obj = {}")
                    P("    local function Make(Class, Props, Parent)")
                    P("        local Obj = Instance.new(Class)")
                    P("        for k, v in pairs(Props) do")
                    P("            if k == '_Attributes' then")
                    P("                for attrName, attrVal in pairs(v) do Obj:SetAttribute(attrName, attrVal) end")
                    P("            elseif k == '_Tags' then")
                    P("                for _, tag in ipairs(v) do game:GetService('CollectionService'):AddTag(Obj, tag) end")
                    P("            elseif k ~= 'Parent' then")
                    P("                pcall(function() Obj[k] = v end)")
                    P("            end")
                    P("        end")
                    P("        if Parent then Obj.Parent = Parent end")
                    P("        return Obj")
                    P("    end")
                    
                    local function SerializeVal(Val)
                        if typeof(Val) == "string" then return string.format("%q", Val) end
                        if typeof(Val) == "boolean" then return tostring(Val) end
                        if typeof(Val) == "number" then return tostring(Val) end
                        if typeof(Val) == "Vector2" then return string.format("Vector2.new(%f, %f)", Val.X, Val.Y) end
                        if typeof(Val) == "Vector3" then return string.format("Vector3.new(%f, %f, %f)", Val.X, Val.Y, Val.Z) end
                        if typeof(Val) == "UDim2" then return string.format("UDim2.new(%f, %d, %f, %d)", Val.X.Scale, Val.X.Offset, Val.Y.Scale, Val.Y.Offset) end
                        if typeof(Val) == "UDim" then return string.format("UDim.new(%f, %d)", Val.Scale, Val.Offset) end
                        if typeof(Val) == "Color3" then return string.format("Color3.fromRGB(%d, %d, %d)", math.floor(Val.R*255), math.floor(Val.G*255), math.floor(Val.B*255)) end
                        if typeof(Val) == "BrickColor" then return string.format("BrickColor.new(%q)", tostring(Val)) end
                        if typeof(Val) == "EnumItem" then return tostring(Val) end
                        if typeof(Val) == "Rect" then return string.format("Rect.new(%f, %f, %f, %f)", Val.Min.X, Val.Min.Y, Val.Max.X, Val.Max.Y) end
                        if typeof(Val) == "PhysicalProperties" then 
                             return string.format("PhysicalProperties.new(%f, %f, %f, %f, %f)", Val.Density, Val.Friction, Val.Elasticity, Val.FrictionWeight, Val.ElasticityWeight)
                        end
                        if typeof(Val) == "ColorSequence" then
                            local keypoints = ""
                            for i, kp in ipairs(Val.Keypoints) do
                                if i > 1 then keypoints = keypoints .. ", " end
                                keypoints = keypoints .. string.format("ColorSequenceKeypoint.new(%f, Color3.new(%f, %f, %f))", kp.Time, kp.Value.R, kp.Value.G, kp.Value.B)
                            end
                            return string.format("ColorSequence.new({%s})", keypoints)
                        end
                         if typeof(Val) == "NumberSequence" then
                            local keypoints = ""
                            for i, kp in ipairs(Val.Keypoints) do
                                if i > 1 then keypoints = keypoints .. ", " end
                                keypoints = keypoints .. string.format("NumberSequenceKeypoint.new(%f, %f, %f)", kp.Time, kp.Value, kp.Envelope)
                            end
                            return string.format("NumberSequence.new({%s})", keypoints)
                        end
                        return "nil"
                    end

                    local varCounter = 0
                    local function Process(Obj, ParentVar)
                        if Obj.Name == "ReGui-Prefabs" then 
                             -- Skip the wrapper itself
                             for _, c in ipairs(Obj:GetChildren()) do Process(c, ParentVar) end
                             return
                        end
                        
                        varCounter = varCounter + 1
                        local varName = "Obj[" .. varCounter .. "]"
                        
                        local props = {}
                        local success = false
                        
                        if getproperties then
                             -- 1. Try Volt/Executor 'getproperties' (Most Complete)
                             local s, p = pcall(getproperties, Obj)
                             if s and p then
                                 success = true
                                 props = p
                             end
                        end
                        
                        if not success then
                             -- 2. Fallback to Manual List
                            props = {}
                            local commonProps = {
                                "Name", "Visible", "Size", "Position", "AnchorPoint", "Rotation", "ZIndex", "LayoutOrder", 
                                "BackgroundColor3", "BackgroundTransparency", "BorderColor3", "BorderSizePixel", "BorderMode",
                                "ClipsDescendants", "Active", "Selectable", "AutoLocalize", "Interactable", "SelectionOrder"
                            }
                            local classProps = {
                                TextLabel = {"Text", "TextColor3", "TextSize", "TextTransparency", "TextStrokeColor3", "TextStrokeTransparency", "Font", "TextScaled", "TextWrapped", "TextXAlignment", "TextYAlignment", "RichText", "MaxVisibleGraphemes", "LineHeight", "TextTruncate", "TextDirection"},
                                TextButton = {"Text", "TextColor3", "TextSize", "TextTransparency", "TextStrokeColor3", "TextStrokeTransparency", "Font", "TextScaled", "TextWrapped", "TextXAlignment", "TextYAlignment", "RichText", "MaxVisibleGraphemes", "LineHeight", "AutoButtonColor", "Modal", "Selected", "Style", "TextTruncate"},
                                TextBox = {"Text", "TextColor3", "TextSize", "TextTransparency", "TextStrokeColor3", "TextStrokeTransparency", "Font", "TextScaled", "TextWrapped", "TextXAlignment", "TextYAlignment", "RichText", "MaxVisibleGraphemes", "LineHeight", "PlaceholderText", "PlaceholderColor3", "ClearTextOnFocus", "MultiLine", "TextEditable", "CursorPosition", "SelectionStart", "TextTruncate"},
                                ImageLabel = {"Image", "ImageColor3", "ImageTransparency", "ImageRectOffset", "ImageRectSize", "ScaleType", "SliceCenter", "SliceScale", "TileSize", "ResampleMode"},
                                ImageButton = {"Image", "ImageColor3", "ImageTransparency", "ImageRectOffset", "ImageRectSize", "ScaleType", "SliceCenter", "SliceScale", "TileSize", "ResampleMode", "AutoButtonColor", "Modal", "HoverImage", "PressedImage"},
                                ScrollingFrame = {"CanvasSize", "CanvasPosition", "ScrollBarThickness", "ScrollBarImageColor3", "ScrollBarImageTransparency", "ScrollingDirection", "ElasticBehavior", "VerticalScrollBarPosition", "AutomaticCanvasSize", "TopImage", "MidImage", "BottomImage", "ScrollingEnabled", "VerticalScrollBarInset"},
                                CanvasGroup = {"GroupColor3", "GroupTransparency"},
                                UIListLayout = {"FillDirection", "SortOrder", "HorizontalAlignment", "VerticalAlignment", "Padding", "ItemLineAlignment"},
                                UIGridLayout = {"FillDirection", "SortOrder", "HorizontalAlignment", "VerticalAlignment", "CellPadding", "CellSize", "FillDirectionMaxCells", "StartCorner"},
                                UIPadding = {"PaddingTop", "PaddingBottom", "PaddingLeft", "PaddingRight"},
                                UICorner = {"CornerRadius"},
                                UIStroke = {"Color", "Transparency", "Thickness", "ApplyStrokeMode", "LineJoinMode"},
                                UIGradient = {"Color", "Transparency", "Offset", "Rotation"},
                                UIAspectRatioConstraint = {"AspectRatio", "AspectType", "DominantAxis"},
                                UISizeConstraint = {"MaxSize", "MinSize"},
                                UITextSizeConstraint = {"MaxTextSize", "MinTextSize"},
                                UIDragDetector = {"DragStyle", "ResponseStyle", "ReferenceUI", "BoundingUI", "DragAxis"},
                                Frame = {"Style"},
                                VideoFrame = {"Video", "TimePosition", "Playing", "Looped", "Volume"}
                            }
                            
                            for _, p in ipairs(commonProps) do 
                                local s, v = pcall(function() return Obj[p] end)
                                if s then props[p] = v end
                            end
                            local specific = classProps[Obj.ClassName]
                            if specific then
                                for _, p in ipairs(specific) do 
                                    local s, v = pcall(function() return Obj[p] end)
                                    if s then props[p] = v end
                                end
                            end
                        end
                        
                        -- Process Props (Serialization & Filtering)
                        local propsStr = "{"
                        local first = true
                        
                        -- Sort keys for consistent output? Not strictly necessary but nicer.
                        -- Loop through props
                        for p, val in pairs(props) do
                            if val ~= nil then
                                 -- Defaults Logic (REMOVED: User requested full dump)
                                 local isDefault = (p == "Parent") -- Don't dump Parent in properties
                                 
                                 -- Extra check: Is it serializable?
                                 local sVal = SerializeVal(val)
                                 if sVal == "nil" and typeof(val) ~= "nil" then isDefault = true end
                                 
                                 if not isDefault then
                                    if not first then propsStr = propsStr .. ", " end
                                    propsStr = propsStr .. p .. " = " .. sVal
                                    first = false
                                 end
                            end
                        end
                        
                        -- 2. ATTRIBUTES
                        local attrs = Obj:GetAttributes()
                        if next(attrs) then
                            if not first then propsStr = propsStr .. ", " end
                            propsStr = propsStr .. "_Attributes = {"
                            local firstAttr = true
                            for n, v in pairs(attrs) do
                                if not firstAttr then propsStr = propsStr .. ", " end
                                propsStr = propsStr .. "['" .. n .. "'] = " .. SerializeVal(v)
                                firstAttr = false
                            end
                            propsStr = propsStr .. "}"
                            first = false
                        end
                        
                        -- 3. TAGS
                        local tags = game:GetService("CollectionService"):GetTags(Obj)
                        if #tags > 0 then
                            if not first then propsStr = propsStr .. ", " end
                            propsStr = propsStr .. "_Tags = {"
                            for i, t in ipairs(tags) do
                                if i > 1 then propsStr = propsStr .. ", " end
                                propsStr = propsStr .. string.format("%q", t)
                            end
                            propsStr = propsStr .. "}"
                        end

                        propsStr = propsStr .. "}"
                        
                        P(string.format("    %s = Make('%s', %s, %s)", varName, Obj.ClassName, propsStr, ParentVar))
                        
                        for _, child in ipairs(Obj:GetChildren()) do
                            Process(child, varName)
                        end
                    end
                    
                    for _, child in ipairs(Prefabs:GetChildren()) do
                        Process(child, "Prefabs")
                    end
                    
                    P("    return Prefabs")
                    P("end")
                    
                    local finalCode = table.concat(out, "\n")
                    print(finalCode)
                    if setclipboard then
                        setclipboard(finalCode)
                        warn(">> FULL DUMP COPIED TO CLIPBOARD! <<")
                    end
                    
                    warn("-- Copy the code above this line --")
                    warn("---------------- END OF FULL DUMP ----------------\n")
                end)
            end
            -------------------------------------------------------------------------
	self:Init({
		Prefabs = Prefabs
	})
end

function ReGui:GetVersion(): string
	return self.Version
end

function ReGui:IsMobileDevice(): boolean
	return UserInputService.TouchEnabled
end

function ReGui:IsConsoleDevice(): boolean
	return UserInputService.GamepadEnabled
end

function ReGui:GetScreenSize(): Vector2
	return workspace.CurrentCamera.ViewportSize
end

function ReGui:LoadPrefabs(): Folder?
	local PlayerGui = self.PlayerGui
	local Name = "ReGui-Prefabs"

	--// Check script for prefabs
	local ScriptUi = script:WaitForChild(Name, 2)
	if ScriptUi then return ScriptUi end

	--// Check PlayerGui for prefabs (Studio Debug)
	local PlayerUI = PlayerGui:WaitForChild(Name, 2)
	if PlayerUI then return PlayerUI end

	return nil
end

function ReGui:CheckConfig(Source: table, Base: table, Call: boolean?, IgnoreKeys: table?)
	return Wrappers:CheckConfig(Source, Base, Call, IgnoreKeys)
end

function ReGui:CreateInstance(Class, Parent, Properties): Instance
	local Object = Instance.new(Class, Parent)

	--// Apply Properties
	if Properties then
		local UseProps = Properties.UsePropertiesList

		if not UseProps then
			self:SetProperties(Object, Properties)
		else
			self:ApplyFlags({
				Object = Object,
				Class = Properties
			})
		end
	end

	return Object
end

function ReGui:ConnectMouseEvent(Object: GuiButton, Config)
	local Callback = Config.Callback
	local DoubleClick = Config.DoubleClick
	local OnlyMouseHovering = Config.OnlyMouseHovering

	local LastClick = 0
	local HoverSignal = nil

	if OnlyMouseHovering then
		HoverSignal = self:DetectHover(OnlyMouseHovering)
	end

	Object.Activated:Connect(function(...)
		local ClickTick = tick()
		local ClickRange = ClickTick-LastClick

		--// OnlyMouseHovering
		if HoverSignal and not HoverSignal.Hovering then return end

		--// DoubleClick
		if DoubleClick then
			if not ReGui:IsDoubleClick(ClickRange) then
				LastClick = ClickTick
				return
			end
			LastClick = 0
		end

		Callback(...)
	end)
end

function ReGui:GetAnimation(Animate: boolean?)
	return Animate and self.Animation or TweenInfo.new(0)
end

function ReGui:DynamicImageTag(Object: Instance, Image: string, WindowClass: table)
	local Tags = self.DynamicImages
	local Tag = Tags[Image]

	if not Tag then return end
	if not WindowClass then return end

	WindowClass:TagElements({
		[Object] = Tag
	})
end

function ReGui:GetDictSize(Dict: table): number
	local Count = 0
	for Key, Value in Dict do
		Count += 1
	end
	return Count
end

function ReGui:RemoveAnimations(Object: GuiObject)
	local Data = self:GetAnimationData(Object)
	local Connections = Data.Connections

	--// Disconnect each connection 
	for _, Connection in next, Connections do
		Connection:Disconnect()
	end
end

function ReGui:GetAnimationData(Object: GuiObject): table
	local Connections = self.AnimationConnections
	local Existing = Connections[Object]

	--// Check for existing
	if Existing then return Existing end

	local Data = {
		Connections = {}
	}

	Connections[Object] = Data
	return Data
end

function ReGui:AddAnimationSignal(Object: GuiObject, Connection: RBXScriptSignal)
	local Data = self:GetAnimationData(Object)
	local Connections = Data.Connections

	table.insert(Connections, Connection)
end

function ReGui:SetAnimationsEnabled(Enabled: boolean)
	self.NoAnimations = not Enabled
end

function ReGui:SetAnimation(Object: GuiObject, Reference: (string|table), Listener: GuiObject?)
	Listener = Listener or Object

	local Animations = self.Animations
	local IsMobile = self.HasTouchScreen

	--// Get animation properties
	local Data = Reference 
	if typeof(Reference) ~= "table" then
		Data = Animations[Reference]
	end

	assert(Data, `No animation data for Class {Reference}!`)

	--// Disconnect previous
	self:RemoveAnimations(Listener)

	--// Unpack data
	local Init = Data.Init
	local Connections = Data.Connections
	local Tweeninfo = Data.Tweeninfo
	local NoAnimation = Data.NoAnimation

	--// Get animation data
	local StateData = self:GetAnimationData(Object)
	local State = StateData.State

	--// Connect signals
	local InitFunc = nil
	local AnimationEnabled = true
	local CurrentSignal = nil
	local Signals = {}

	--// Interface for the animation
	local Module = {}
	function Module:Reset(NoAnimation: boolean?)
		if not InitFunc then return end
		InitFunc(NoAnimation)
	end
	function Module:FireSignal(SignalName: string, NoAnimation: boolean?)
		Signals[SignalName](NoAnimation)
	end
	function Module:Refresh(NoAnimation: boolean?)
		if not CurrentSignal then return end
		Signals[CurrentSignal](NoAnimation)
	end
	function Module:SetEnabled(Enabled: boolean)
		AnimationEnabled = Enabled
	end

	for SignalName: string, Properties in next, Connections do
		local function OnSignal(NoAnim: boolean?)
			NoAnim = NoAnim == true --// Convert to boolean
			CurrentSignal = SignalName

			--// Check if animations are enabled
			local NoAnimations = self.NoAnimations
			if NoAnimations then return end

			--// Check if the animation is enabled
			if not AnimationEnabled then return end

			StateData.State = SignalName

			Animation:Tween({
				NoAnimation = NoAnim or NoAnimation,
				Object = Object,
				Tweeninfo = Tweeninfo, 
				EndProperties = Properties
			})
		end

		--// Connect animation to signal
		local Signal = Listener[SignalName]

		--// Prevent animations for mobile devices
		if not IsMobile then
			local Connection = Signal:Connect(OnSignal)
			self:AddAnimationSignal(Listener, Connection)
		end

		Signals[SignalName] = OnSignal

		--// Call init connection
		if SignalName == Init then
			InitFunc = OnSignal
		end
	end

	if State then
		--// Update the animation to the previous state, e.g MouseHover
		Module:FireSignal(State)
	else
		--// Update the animation state to default
		Module:Reset(true)
	end

	return Module
end

export type ConnectDrag = {
	DragStart: () -> nil,
	DragEnd: () -> nil,
	DragMovement: () -> nil,
}
function ReGui:ConnectDrag(Frame: GuiObject, Data)
	self:CheckConfig(Data, {
		DragStart = EmptyFunction,
		DragEnd = EmptyFunction,
		DragMovement = EmptyFunction,
		OnDragStateChange = EmptyFunction,
	})

	--// Unpack Configuration
	local DragStart = Data.DragStart
	local DragEnd = Data.DragEnd
	local DragMovement = Data.DragMovement
	local OnDragStateChange = Data.OnDragStateChange

	--// Whitelist
	local UserInputTypes = {
		StartAndEnd = {
			Enum.UserInputType.MouseButton1,
			Enum.UserInputType.Touch
		},
		Movement = {
			Enum.UserInputType.MouseMovement,
			Enum.UserInputType.Touch
		}
	}

	local IsDragging = false

	local function InputTypeAllowed(Key, Type: string)
		local InputType = Key.UserInputType
		return table.find(UserInputTypes[Type], InputType)
	end
	local function KeyToVector(Key): Vector2
		local InputPosition = Key.Position
		return Vector2.new(InputPosition.X, InputPosition.Y)
	end
	local function SetIsDragging(DraggingState: boolean)
		--// Globally disable drag on other objects
		self._DraggingDisabled = DraggingState

		IsDragging = DraggingState
		OnDragStateChange(DraggingState)
	end
	local function MakeSignal(Data)
		local IsDraggingState = Data.IsDragging
		local InputType = Data.InputType
		local Callback = Data.Callback

		return function(Key)
			if Data.DraggingRequired ~= IsDragging then return end
			if Data.CheckDraggingDisabled and self._DraggingDisabled then return end
			if not InputTypeAllowed(Key, InputType) then return end

			--// Update drag state
			if Data.UpdateState then
				SetIsDragging(IsDraggingState)
			end

			local InputVector = KeyToVector(Key)
			Callback(InputVector)
		end
	end

	--// Connect movement events
	Frame.InputBegan:Connect(MakeSignal({
		CheckDraggingDisabled = true,
		DraggingRequired = false,
		UpdateState = true,
		IsDragging = true,
		InputType = "StartAndEnd",
		Callback = DragStart,
	}))
	UserInputService.InputEnded:Connect(MakeSignal({
		DraggingRequired = true,
		UpdateState = true,
		IsDragging = false,
		InputType = "StartAndEnd",
		Callback = DragEnd,
	}))
	UserInputService.InputChanged:Connect(MakeSignal({
		DraggingRequired = true,
		InputType = "Movement",
		Callback = DragMovement,
	}))
end

type MakeDraggableFlags = {
	Move: Instance,
	Grab: Instance,
	Enabled: boolean?,
	SetPosition: (MakeDraggableFlags, Position: UDim2) -> nil,
	OnUpdate: ((Vector2) -> ...any)?,
	DragBegin: ((InputObject) -> ...any)?,
	StateChanged: ((MakeDraggableFlags) -> any)?,
	OnDragStateChange: ((IsDragging: boolean) -> any)?,
}
function ReGui:MakeDraggable(Config: MakeDraggableFlags)
	--// Unpack config
	local Move = Config.Move
	local Grab = Config.Grab
	local OnDragStateChange = Config.OnDragStateChange

	local PositionOrgin = nil
	local InputOrgin = nil

	--// Interface
	local Interface = {}
	function Interface:SetEnabled(State: boolean)
		local StateChanged = Config.StateChanged
		self.Enabled = State
		--DragDetector.Enabled = State

		--// Invoke the state changed callback function
		if StateChanged then 
			StateChanged(self)
		end
	end
	function Interface:CanDrag(Key): boolean
		return self.Enabled
	end

	--// Movement event functions
	local function DragStart(InputVector)
		if not Interface:CanDrag() then return end
		local DragBegin = Config.DragBegin

		InputOrgin = InputVector
		DragBegin(InputOrgin)
	end

	local function DragMovement(InputVector)
		if not Interface:CanDrag() then return end

		local Delta = InputVector - InputOrgin
		local OnUpdate = Config.OnUpdate

		OnUpdate(Delta)
	end

	--// Movement functions
	local function PositionBegan(Key)
		PositionOrgin = Move.Position
	end
	local function UpdatePosition(Delta: Vector2)
		local Position = UDim2.new(
			PositionOrgin.X.Scale, 
			PositionOrgin.X.Offset + Delta.X, 
			PositionOrgin.Y.Scale, 
			PositionOrgin.Y.Offset + Delta.Y
		)
		Config:SetPosition(Position)
	end
	local function SetPosition(self, Position: UDim2)
		--// Tween frame element to the new size
		Animation:Tween({
			Object = Move,
			EndProperties = {
				Position = Position
			}
		})
	end

	--// Check configuration
	self:CheckConfig(Config, {
		Enabled = true,
		OnUpdate = UpdatePosition,
		SetPosition = SetPosition,
		DragBegin = PositionBegan
	})

	--// Connect movement events
	self:ConnectDrag(Grab, {
		DragStart = DragStart,
		DragMovement = DragMovement,
		OnDragStateChange = OnDragStateChange
	})

	--// Set enabled state
	local Enabled = Config.Enabled
	Interface:SetEnabled(Enabled)

	return Interface
end

export type MakeResizableFlags = {
	MinimumSize: Vector2,
	MaximumSize: Vector2?,
	--Grab: Instance,
	Resize: Instance,
	OnUpdate: (UDim2) -> ...any
}
function ReGui:MakeResizable(Config: MakeResizableFlags)
	ReGui:CheckConfig(Config, {
		MinimumSize = Vector2.new(160, 90),
		MaximumSize = Vector2.new(math.huge, math.huge)
	})

	--// Unpack config
	local MaximumSize = Config.MaximumSize
	local MinimumSize = Config.MinimumSize
	local Resize = Config.Resize
	local OnUpdate = Config.OnUpdate

	local SizeOrgin = nil

	--// Create grab element
	local Grab = ReGui:InsertPrefab("ResizeGrab", {
		Parent = Resize
	})
	Grab.BackgroundTransparency = 1
	Grab.Text = "◢"
	Grab.Size = UDim2.fromOffset(25, 25)
	Grab.Position = UDim2.new(1, 0, 1, 0)
	Grab.AnchorPoint = Vector2.new(1, 1)

	local function StateChanged(Interface)
		Grab.Visible = Interface.Enabled
	end

	--// Resize functions
	local function UpdateSize(Delta)
		local NewSize = SizeOrgin + Delta

		--// Clamp size
		local Size = UDim2.fromOffset(
			math.clamp(NewSize.X, MinimumSize.X, MaximumSize.X), 
			math.clamp(NewSize.Y, MinimumSize.Y, MaximumSize.Y)
		)

		--// Call update function instead of tweening
		if OnUpdate then
			OnUpdate(Size)
			return
		end

		--// Tween frame element to the new size
		Animation:Tween({
			Object = Resize,
			EndProperties = {
				Size = Size
			}
		})
	end
	local function ResizeBegin(InputPosition)
		SizeOrgin = Resize.AbsoluteSize
	end

	--// Connect movement events
	local DragDetection = self:MakeDraggable({
		Grab = Grab,
		OnUpdate = UpdateSize,
		DragBegin = ResizeBegin,
		StateChanged = StateChanged
	})

	DragDetection.Grab = Grab

	return DragDetection
end

function ReGui:IsMouseEvent(Input: InputObject, IgnoreMovement: boolean)
	local Name = Input.UserInputType.Name

	--// IgnoreMovement 
	if IgnoreMovement and Name:find("Movement") then return end

	return Name:find("Touch") or Name:find("Mouse")
end

export type DetectHover = {
	OnInput: ((boolean, InputObject?) -> ...any?)?,
	Anykey: boolean?,
	MouseMove: boolean?,
	MouseOnly: boolean?,
	MouseEnter: boolean?,
	Hovering: boolean?,
}
function ReGui:DetectHover(Object: GuiObject, Configuration: DetectHover?)
	local Config = Configuration or {}
	Config.Hovering = false

	--// Unpack configuration
	local OnInput = Config.OnInput
	local OnHoverChange = Config.OnHoverChange
	local Anykey = Config.Anykey
	local MouseMove = Config.MouseMove
	local MouseEnter = Config.MouseEnter
	local MouseOnly = Config.MouseOnly

	local function Update(Input, IsHovering: boolean?, IsMouseEvent: boolean?)
		--// Check if the input is mouse or touch
		if Input and MouseOnly then
			if not ReGui:IsMouseEvent(Input, true) then return end
		end

		--// Set new IsHovering state
		if IsHovering ~= nil then
			local Previous = Config.Hovering
			Config.Hovering = IsHovering

			--// Invoke OnHoverChange
			if IsHovering ~= Previous and OnHoverChange then
				OnHoverChange(IsHovering)
			end
		end

		--// Mouse Enter events
		if not MouseEnter and IsMouseEvent then return end

		--// Call OnInput function
		if OnInput then
			local Value = Config.Hovering
			OnInput(Value, Input)
			return 
		end
	end

	--// Connect Events
	local Connections = {
		Object.MouseEnter:Connect(function()
			Update(nil, true, true)
		end),
		Object.MouseLeave:Connect(function()
			Update(nil, false, true)
		end)
	}

	--// Update on keyboard events or Mouse eveents
	if Anykey or MouseOnly then
		table.insert(Connections, UserInputService.InputBegan:Connect(function(Input)
			Update(Input)
		end))
	end

	--// Update on mouse move
	if MouseMove then
		local Connection = Object.MouseMoved:Connect(function()
			Update()
		end)
		table.insert(Connections, Connection)
	end

	function Config:Disconnect()
		for _, Connection in next, Connections do
			Connection:Disconnect()
		end
	end

	return Config
end

function ReGui:StackWindows()
	local Windows = self.Windows
	local Offset = 20

	for Index, Class in next, Windows do
		local Window = Class.WindowFrame

		local Position = UDim2.fromOffset(Offset*Index, Offset*Index)

		Class:Center()
		Window.Position += Position
	end
end

function ReGui:GetElementFlags(Object: GuiObject): table?
	local Cache = self._FlagCache
	return Cache[Object]
end

type UpdateColors = {
	Object: GuiObject,
	Tag: (string|table),
	NoAnimation: boolean?,
	Theme: string?,
	TagsList: TagsList?,
	Tweeninfo: TweenInfo?
}
function ReGui:UpdateColors(Config: UpdateColors)
	--// Unpack config
	local Object = Config.Object
	local Tag = Config.Tag
	local NoAnimation = Config.NoAnimation
	local Elements = Config.TagsList
	local Theme = Config.Theme
	local Tweeninfo = Config.Tweeninfo

	--// Unpack global configuration
	local ElementColors = self.ElementColors
	local Flags = self:GetElementFlags(Object)
	local Debug = self.Debug
	
	local Coloring = ElementColors[Tag]

	--// Resolve string into color data
	if typeof(Coloring) == "string" then
		Coloring = ElementColors[Coloring]
	end

	if typeof(Tag) == "table" then
		Coloring = Tag
	elseif Elements then
		Elements[Object] = Tag --// Update the element's tag in the dict
	end

	--// Check if coloring data exists
	if not Coloring then return end

	--// Add coloring data to properties
	local Properties = {}
	for Key: string, Name: string in next, Coloring do
		local Color = self:GetThemeKey(Theme, Name)

		--// Ignore if flags has a overwrite
		if Flags and Flags[Key] then 
			continue 
		end

		--// Color not found debug
		if not Color then 
			if Debug then
				self:Warn(`Color: '{Name}' does not exist!`)
			end
			continue
		end

		Properties[Key] = Color
	end

	--// Tween new properties
	Animation:Tween({
		Tweeninfo = Tweeninfo,
		Object = Object,
		NoAnimation = NoAnimation,
		EndProperties = Properties
	})
end

export type MultiUpdateColorsConfig = {
	Objects: ObjectsTable,
	TagsList: TagsList?,
	Theme: string?,
	Animate: boolean?,
	Tweeninfo: TweenInfo?
}
function ReGui:MultiUpdateColors(Config: MultiUpdateColorsConfig)
	local Objects = Config.Objects

	for Object: GuiObject, Tag: string? in next, Objects do
		self:UpdateColors({
			TagsList = Config.TagsList,
			Theme = Config.Theme,
			NoAnimation = not Config.Animate,
			Tweeninfo = Config.Tweeninfo,

			Object = Object,
			Tag = Tag,
		})
	end
end

function ReGui:ApplyStyle(Object: GuiObject, StyleName: string)
	local Styles = self.Styles

	local Style = Styles[StyleName]
	if not Style then return end

	--// Apply style properties
	self:ApplyFlags({
		Object = Object,
		Class = Style
	})
end

function ReGui:ClassIgnores(Key: string): boolean
	local Ignores = self.ClassIgnored
	local Index = table.find(Ignores, Key)

	return Index and true or false
end

function ReGui:MergeMetatables(Class, Object: GuiObject)
	local Debug = self.Debug
	local Metadata = {}

	Metadata.__index = function(_, Key: string)
		local Ignored = self:ClassIgnores(Key)

		--// Fetch value from class
		local Value = Class[Key]
		if Value ~= nil and not Ignored then 
			return Value 
		end

		--// Fetch value from Object
		local Success, ObjectValue = pcall(function()
			local Value = Object[Key]
			return self:PatchSelf(Object, Value)  
		end)

		return Success and ObjectValue or nil
	end

	Metadata.__newindex = function(_, Key: string, Value)
		local Ignored = self:ClassIgnores(Key)
		local IsFunc = typeof(Value) == "function"

		--// Class only
		local IsClass = Class[Key] ~= nil or IsFunc
		if IsClass and not Ignored then
			Class[Key] = Value
			return
		end

		--// Test on Object
		xpcall(function()
			Object[Key] = Value
		end, function(err)
			if Debug then
				self:Warn(`Newindex Error: {Object}.{Key} = {Value}\n{err}`)
			end

			Class[Key] = Value
		end)
	end

	return setmetatable({}, Metadata)
end

function ReGui:Concat(Table, Separator: " ") 
	local Concatenated = ""
	for Index, String in next, Table do
		Concatenated ..= tostring(String) .. (Index ~= #Table and Separator or "")
	end
	return Concatenated
end

function ReGui:GetValueFromAliases(Aliases, Table)
	for _, Alias: string in Aliases do
		local Value = Table[Alias]
		if Value ~= nil then
			return Value
		end
	end

	return nil
end

function ReGui:RecursiveCall(Object: GuiObject, Func: (GuiObject)->...any)
	for _, Child in next, Object:GetDescendants() do
		Func(Child)
	end
end

export type ApplyFlags = {
	Object: Instance,
	Class: table,
	WindowClass: table?,
	GetThemeKey: (ApplyFlags, Tag: string) -> any
}
function ReGui:ApplyFlags(Config: ApplyFlags)
	local Properties = self.ElementFlags

	--// Unpack config
	local Object = Config.Object
	local Class = Config.Class
	local WindowClass = Config.WindowClass

	function Config:GetThemeKey(Tag: string)
		if WindowClass then
			return WindowClass:GetThemeKey(Tag)
		else
			return ReGui:GetThemeKey(nil, Tag)
		end
	end

	--// Set base properties
	self:SetProperties(Object, Class)

	--// Check for callbacks
	for _, Flag in next, Properties do
		local Aliases = Flag.Properties
		local Callback = Flag.Callback
		local Recursive = Flag.Recursive
		local WindowFlags = Flag.WindowProperties

		--// Find value from element class
		local Value = self:GetValueFromAliases(Aliases, Class)

		--// Find value from window class
		if WindowClass and WindowFlags and Value == nil then
			Value = self:GetValueFromAliases(WindowFlags, WindowClass)
		end

		if Value == nil then continue end

		--// Apply flag
		Callback(Config, Object, Value)

		--// Recursively apply flag
		if Recursive then
			self:RecursiveCall(Object, function(Child)
				Callback(Config, Child, Value)
			end)
		end
	end
end

function ReGui:SetProperties(Object: Instance, Properties: table)
	return Wrappers:SetProperties(Object, Properties)
end

function ReGui:InsertPrefab(Name: string, Properties): GuiObject
	local Folder = self.Prefabs
	if not Folder then
		self:Warn("Prefabs folder is nil! Cannot insert:", Name)
		return nil
	end
	
	local Prefabs = Folder:FindFirstChild("Prefabs") or Folder
	if not Prefabs then
		self:Warn("Prefabs container not found! Cannot insert:", Name)
		return nil
	end

	--// Use FindFirstChild with timeout instead of WaitForChild (prevents freeze)
	local Child = Prefabs:FindFirstChild(Name)
	if not Child then
		-- Fallback: try WaitForChild with a short timeout
		Child = Prefabs:WaitForChild(Name, 5)
	end
	
	if not Child then
		self:Warn("Prefab not found:", Name)
		return nil
	end

	local Object = Wrappers:NewReference(Child:Clone())

	--// Apply properties
	if Properties then 
		local UseProps = Properties.UsePropertiesList

		if not UseProps then
			self:SetProperties(Object, Properties)
		else
			self:ApplyFlags({
				Object = Object,
				Class = Properties
			})
		end
	end

	return Object
end

function ReGui:GetContentSize(Object: GuiObject, IngoreUIList: boolean?): Vector2
	local UIListLayout = Object:FindFirstChildOfClass("UIListLayout")
	local UIPadding = Object:FindFirstChildOfClass("UIPadding")
	local UIStroke = Object:FindFirstChildOfClass("UIStroke")

	local ContentSize: Vector2

	--// Fetch absolute size
	if UIListLayout and not IngoreUIList then
		ContentSize = UIListLayout.AbsoluteContentSize
	else
		ContentSize = Object.AbsoluteSize
	end

	--// Apply padding
	if UIPadding then
		local Top = UIPadding.PaddingTop.Offset
		local Bottom = UIPadding.PaddingBottom.Offset
		local Left = UIPadding.PaddingLeft.Offset
		local Right = UIPadding.PaddingRight.Offset

		ContentSize += Vector2.new(Left+Right, Top+Bottom)
	end

	if UIStroke then
		local Thickness = UIStroke.Thickness
		ContentSize += Vector2.new(Thickness/2, Thickness/2)
	end

	return ContentSize
end

function ReGui:PatchSelf(Self, Func, ...)
	--// Check if the passed value is a function
	if typeof(Func) ~= "function" then 
		return Func, ...
	end

	return function(_, ...)
		return Func(Self, ...)
	end
end

type MakeCanvas = {
	Element: Instance,
	WindowClass: WindowFlags?,
	Class: {}?
}
function ReGui:MakeCanvas(Config: MakeCanvas)
	--// Unpack ReGui data
	local ElementsClass = self.Elements
	local Debug = self.Debug

	--// Unpack configuration
	local Element = Config.Element
	local WindowClass = Config.WindowClass
	local Class = Config.Class
	local OnChildChange = Config.OnChildChange

	local ChildChangeSignal = Signaling:NewSignal()

	--// Connect OnChildChange argument
	if OnChildChange then
		ChildChangeSignal:Connect(OnChildChange)
	end

	--// Debug report
	if not WindowClass and Debug then
		self:Warn(`No WindowClass for {Element}`)
		self:Warn(Config)
	end

	--// Create new canvas class
	local Canvas = Wrappers:NewClass(ElementsClass, {
		Class = Class,
		RawObject = Element,
		WindowClass = WindowClass or false,
		OnChildChange = ChildChangeSignal,
		Elements = {}
	})

	--// Create metatable merge
	local Meta = {
		__index = function(_, Key: string)
			--// Check Canvas class for value
			local CanvasValue = Canvas[Key]
			if CanvasValue ~= nil then 
				return self:PatchSelf(Canvas, CanvasValue)  
			end

			--// Check class for value
			local ClassValue = Class[Key]
			if ClassValue ~= nil then 
				return self:PatchSelf(Class, ClassValue)  
			end

			--// Fetch value from Element
			local ElementValue = Element[Key]
			return self:PatchSelf(Element, ElementValue)  
		end,
		__newindex = function(self, Key: string, Value)
			local IsClassValue = Class[Key] ~= nil

			--// Update key value
			if IsClassValue then
				Class[Key] = Value
			else
				Element[Key] = Value
			end
		end,
	}

	return setmetatable({}, Meta)
end

--// Ini service
function ReGui:GetIniData(Class): table
	local IniToSave = self.IniToSave
	local Ini = {}

	for _, Name in next, IniToSave do
		Ini[Name] = Class[Name]
	end

	return Ini
end

function ReGui:DumpIni(JsonEncode: boolean?): table
	local IniSettings = self.IniSettings
	local Parsed = {}

	for Flag, Element in next, IniSettings do
		Parsed[Flag] = self:GetIniData(Element)
	end

	--// Parse into Json string
	if JsonEncode then
		return HttpService:JSONEncode(Parsed)
	end

	return Parsed
end

function ReGui:LoadIniIntoElement(Element, Values: table)
	local ValueFunctions = {
		["Value"] = function(Value)
			Element:SetValue(Value)
		end,
	}

	for Name, Value in next, Values do
		--// Check if setting the value requires a function call
		local SetValue = ValueFunctions[Name]
		if SetValue then
			SetValue(Value)
			continue
		end

		Element[Name] = Value
	end
end

function ReGui:LoadIni(NewSettings: (table|string), JsonEncoded: boolean?)
	local IniSettings = self.IniSettings
	assert(NewSettings, "No Ini configuration was passed")

	--// Decode Json into a dict table
	if JsonEncoded then
		NewSettings = HttpService:JSONDecode(NewSettings)
	end

	for Flag, Values in next, NewSettings do
		local Element = IniSettings[Flag]
		self:LoadIniIntoElement(Element, Values)
	end
end

function ReGui:AddIniFlag(Flag: string, Element: table)
	local IniSettings = self.IniSettings
	IniSettings[Flag] = Element
end

type OnElementCreateData = {
	Flags: table,
	Object: GuiObject,
	Canvas: table,
	Class: table?
}
function ReGui:OnElementCreate(Data: OnElementCreateData)
	local FlagCache = self._FlagCache

	local Flags = Data.Flags
	local Object = Data.Object
	local Canvas = Data.Canvas
	local Class = Data.Class

	local WindowClass = Canvas.WindowClass

	local NoAutoTag = Flags.NoAutoTag
	local NoAutoFlags = Flags.NoAutoFlags
	local ColorTag = Flags.ColorTag
	local NoStyle = Flags.NoStyle
	local IniFlag = Flags.IniFlag

	--// Cache element flags
	FlagCache[Object] = Flags

	--// Registor element into IniSettings
	if IniFlag then
		self:AddIniFlag(IniFlag, Class)
	end

	--// NoStyle
	if NoStyle then return end

	--// Registor element into WindowClass
	if not NoAutoTag and WindowClass then
		WindowClass:TagElements({
			[Object] = ColorTag
		})
	end

	--// Apply style functions to the element
	if WindowClass then
		WindowClass:LoadStylesIntoElement(Data)
	end

	if not NoAutoFlags then
		--// Apply flags to the element
		self:ApplyFlags({
			Object = Object,
			Class = Flags,
			WindowClass = WindowClass
		})
	end
end

function ReGui:VisualError(Canvas, Parent, Message: string)
	local Visual = self.Initialised and Canvas.Error

	--// Print error message
	if not Visual then
		self:Error("Class:", Message)
		return
	end

	--// Create error label
	Canvas:Error({
		Parent = Parent,
		Text = Message
	})
end

function ReGui:WrapGeneration(Function, Data: table)
	local ErrorCache = self._ErrorCache

	local Base = Data.Base
	local IgnoreDefaults = Data.IgnoreDefaults

	return function(Canvas, Flags, ...)
		Flags = Flags or {}

		--// Check Flags with Base flags from the Element
		self:CheckConfig(Flags, Base)

		--// Get generation flags
		local CloneTable = Flags.CloneTable

		--// Clone configuration table flag
		if CloneTable then
			Flags = table.clone(Flags)
		end

		local Parent = Canvas.RawObject
		local Elements = Canvas.Elements
		local OnChildChange = Canvas.OnChildChange

		--// Check flags again as the element generation may have modified
		self:CheckConfig(Flags, {
			Parent = Parent,
			Name = Flags.ColorTag
		}, nil, IgnoreDefaults)

		--// Convert self from 'ReGui' to 'Elements'
		if Canvas == self then
			Canvas = self.Elements
		end

		--// Create element and apply properties
		--local Class, Element = Function(Canvas, Flags, ...)
		local Success, Class, Element = pcall(Function, Canvas, Flags, ...)

		--// Check for errors
		if Success == false then
			if Parent then
				if ErrorCache[Parent] then return end
				ErrorCache[Parent] = Class
			end

			--// Create visual error message
			self:VisualError(Canvas, Parent, Class)
			self:Error("Class:", Class)
			self:Error(debug.traceback())
		end

		--// Some elements may return the instance without a class
		if Element == nil then
			Element = Class
		end

		--// Invoke OnChildChange
		if OnChildChange then
			OnChildChange:Fire(Class)
		end

		--// Add element into the flag Cache
		if Element then
			if Elements then
				table.insert(Elements, Element)
			end

			self:OnElementCreate({
				Object = Element,
				Flags = Flags,
				Class = Class,
				Canvas = Canvas
			})
		end

		return Class, Element
	end
end

function ReGui:DefineElement(Name: string, Data)
	local Elements = self.Elements
	local Themes = self.ThemeConfigs
	local ElementColors = self.ElementColors

	local BaseTheme = Themes.DarkTheme

	--// Element data
	local Base = Data.Base
	local Create = Data.Create
	local Export = Data.Export
	local ThemeTags = Data.ThemeTags
	local ColorData = Data.ColorData

	--// Add missing keys to base config
	self:CheckConfig(Base, {
		ColorTag = Name,
		ElementStyle = Name
	})

	--// Declare new coloring variables into theme
	if ThemeTags then
		Merge(BaseTheme, ThemeTags)
	end

	--// Declare new ColorData
	if ColorData then
		Merge(ElementColors, ColorData)
	end

	--// Create element function wrap
	local Generate = self:WrapGeneration(Create, Data)

	--// Export creation function into ReGui dict
	if Export then
		self[Name] = Generate
	end

	--// Add element into the Elements class
	Elements[Name] = Generate

	return Generate
end

function ReGui:DefineGlobalFlag(Flag)
	local Flags = self.ElementFlags
	table.insert(Flags, Flag)
end

function ReGui:DefineTheme(Name: string, ThemeData: ThemeData)
	local Themes = self.ThemeConfigs

	--// Check theme configuration for missing data
	self:CheckConfig(ThemeData, {
		BaseTheme = Themes.DarkTheme
	})

	local BaseTheme = GetAndRemove("BaseTheme", ThemeData)
	local Theme = {
		BaseTheme = BaseTheme,
		Values = ThemeData
	}

	--// Push theme into the ThemeConfigs dict
	Themes[Name] = Theme

	return Theme
end

function ReGui:GetMouseLocation(): (number, number)
	local Mouse = self.Mouse
	return Mouse.X, Mouse.Y
end

function ReGui:SetWindowFocusesEnabled(Enabled: boolean)
	self.WindowFocusesEnabled = Enabled
end

function ReGui:UpdateWindowFocuses()
	local Windows = self.Windows
	local FocusesEnabled = self.WindowFocusesEnabled

	if not FocusesEnabled then return end

	--// Update each window state
	for _, Class in Windows do
		local Connection = Class.HoverConnection
		if not Connection then continue end

		--// Check hover state
		local Hovering = Connection.Hovering
		if Hovering then
			self:SetFocusedWindow(Class)
			return
		end
	end

	self:SetFocusedWindow(nil)
end

function ReGui:WindowCanFocus(WindowClass: table): boolean
	if WindowClass.NoSelect then return false end
	if WindowClass.Collapsed then return false end
	if WindowClass._SelectDisabled then return false end

	return true
end

function ReGui:GetFocusedWindow(): table?
	return self.FocusedWindow
end

function ReGui:BringWindowToFront(WindowClass: table)
	local Windows = self.Windows

	--// Check if the NoBringToFrontOnFocus flag is enabled
	local NoBringToFront = WindowClass.NoBringToFrontOnFocus
	if NoBringToFront then return end

	--// Change position of window in the Windows array to 1
	MoveTableItem(Windows, WindowClass, 1)
end

function ReGui:SetFocusedWindow(ActiveClass: table?)
	local Previous = self:GetFocusedWindow()
	local Windows = self.Windows

	--// Check if the Active window is the same as previous
	if Previous == ActiveClass then return end
	self.FocusedWindow = ActiveClass

	--// Only update the window if the NoSelect flag is enabled
	if ActiveClass then
		local CanSelect = self:WindowCanFocus(ActiveClass)
		if not CanSelect then return end

		--// Bring Window to the front
		self:BringWindowToFront(ActiveClass)
	end

	--// Update active state for each window
	local ZIndex = #Windows
	for _, Class in Windows do
		local CanSelect = self:WindowCanFocus(Class)
		local Window = Class.WindowFrame

		--// Ignore NoSelect windows with NoSelect flag
		if not CanSelect then continue end

		ZIndex -= 1

		--// Set Window ZIndex
		if ZIndex then
			Window.ZIndex = ZIndex
		end

		--// Update Window focus state
		local Active = Class == ActiveClass
		Class:SetFocused(Active, ZIndex)
	end
end

function ReGui:SetItemTooltip(Parent: GuiObject, Render: (Elements) -> ...any)
	local Elements = self.Elements
	local Tooltips = self.TooltipsContainer
	local ActiveTooltips = self.ActiveTooltips

	--// Create canvas object
	local Canvas, Object = Tooltips:Canvas({
		Visible = false,
		UiPadding = UDim.new()
	})

	--// Create content
	task.spawn(Render, Canvas)

	--// Connect events
	ReGui:DetectHover(Parent, {
		MouseMove = true,
		MouseEnter = true,
		OnHoverChange = function(Hovering: boolean)
			--// Registor tooltip into ActiveTooltips
			if Hovering then
				table.insert(ActiveTooltips, Canvas)
				return 
			end

			--// Remove from ActiveTooltips
			local Index = table.find(ActiveTooltips, Canvas)
			table.remove(ActiveTooltips, Index)
		end,
		OnInput = function(Hovering: boolean, Input)
			Object.Visible = Hovering
		end,
	})
end

function ReGui:CheckFlags(Flags, Config)
	for Name: string, Func in next, Flags do
		local Value = Config[Name]
		if not Value then continue end

		Func(Value)
	end
end

function ReGui:GetThemeKey(Theme: (string|table)?, Key: string)
	local Themes = self.ThemeConfigs

	--// Fetch theme data from the name
	if typeof(Theme) == "string" then
		Theme = Themes[Theme]
	end

	local DarkTheme = Themes.DarkTheme
	Theme = Theme or DarkTheme

	local BaseTheme = Theme.BaseTheme
	local Values = Theme.Values

	--// Test for a direct value
	local Value = Values[Key]
	if Value then return Value end

	--// Fetch value from the base theme
	if BaseTheme then
		return self:GetThemeKey(BaseTheme, Key)
	end

	return
end

function ReGui:SelectionGroup(Elements)
	local Previous = nil
	local Debounce = false

	local function ForEach(Func, Ignore)
		for _, Element in next, Elements do
			if typeof(Element) == "Instance" then continue end
			if Element == Ignore then continue end

			Func(Element)
		end
	end

	local function Callback(self)
		if Debounce then return end
		Debounce = true

		local Value = Previous
		Previous = self:GetValue()

		if not Value then
			Value = Previous
		end

		ForEach(function(Element)
			Element:SetValue(Value)
		end, self)

		Debounce = false
	end

	ForEach(function(Element)
		Element.Callback = Callback
	end)
end

--// Container class
local Elements = ReGui.Elements
Elements.__index = Elements

function Elements:GetObject()
	return self.RawObject
end

function Elements:ApplyFlags(Object, Flags)
	local WindowClass = self.WindowClass

	ReGui:ApplyFlags({
		WindowClass = WindowClass,
		Object = Object,
		Class = Flags
	})
end

function Elements:Remove()
	local OnChildChange = self.OnChildChange
	local Object = self:GetObject()
	local Class = self.Class

	--// Check if the class has a remove function
	local ClassRemove = Class.Remove
	if ClassRemove then
		return ClassRemove(Class)
	end

	--// Invoke OnChildChange
	if OnChildChange then
		OnChildChange:Fire(Class or self)
	end

	if Class then
		table.clear(Class)
	end

	Object:Destroy()
	table.clear(self)
end

function Elements:GetChildElements(): table
	local Elements = self.Elements
	return Elements
end

function Elements:ClearChildElements()
	local Elements = self:GetChildElements()
	for _, Object in next, Elements do
		Object:Destroy()
	end
end

function Elements:TagElements(Objects: table)
	local WindowClass = self.WindowClass
	local Debug = ReGui.Debug

	--// Missing WindowClass
	if not WindowClass then 	
		if Debug then
			ReGui:Warn("No WindowClass for TagElements:", Objects)
		end
		return
	end

	WindowClass:TagElements(Objects)
end

function Elements:GetThemeKey(Key: string)
	local WindowClass = self.WindowClass

	if WindowClass then 
		return WindowClass:GetThemeKey(Key)
	end

	return ReGui:GetThemeKey(nil, Key)
end

function Elements:SetColorTags(Objects: tables, Animate: boolean?)
	local WindowClass = self.WindowClass
	if not WindowClass then return end

	local Elements = WindowClass.TagsList
	local Theme = WindowClass.Theme

	ReGui:MultiUpdateColors({
		Animate = Animate,
		Theme = Theme,
		TagsList = Elements,
		Objects = Objects,
	})
end

function Elements:SetElementFocused(Object: GuiObject, Data)
	local WindowClass = self.WindowClass
	local IsMobileDevice = ReGui.HasTouchScreen

	local Focused = Data.Focused
	local Animation = Data.Animation

	--// Change global animation state
	ReGui:SetAnimationsEnabled(not Focused)

	--// Reset animation state
	if not Focused and Animation then
		Animation:Refresh()
	end

	--// Window modification
	if not WindowClass then return end
	if not IsMobileDevice then return end
	local ContentCanvas = WindowClass.ContentCanvas

	--// Disable interaction with other elements for touchscreens
	ContentCanvas.Interactable = not Focused
end

ReGui:DefineElement("Dropdown", {
	Base = {
		ColorTag = "PopupCanvas",
		Disabled = false,
		AutoClose = true,
		OnSelected = EmptyFunction
	},
	Create = function(Canvas, Config)
		Config.Parent = ReGui.Container.Overlays

		--// Unpack configuration
		local Selected = Config.Selected
		local Items = Config.Items
		local OnSelected = Config.OnSelected

		--// Create overlay object
		local Popup, Object = Canvas:PopupCanvas(Config)
		local Class = ReGui:MergeMetatables(Config, Popup)

		local Entries = {}

		local function SetValue(Value)
			OnSelected(Value) -- Invoke selected callback
		end

		function Config:ClearEntries()
			for _, Entry in Entries do
				Entry:Remove()
			end
		end

		function Config:SetItems(Items: table, Selected)
			local IsArray = Items[1]

			--// Clear previous entries
			self:ClearEntries()

			--// Append items
			for A, B in Items do
				local Value = IsArray and B or A
				local IsSelected = A == Selected or B == Selected

				--// Create selectable
				local Entry = Popup:Selectable({
					Text = tostring(Value),
					Selected = IsSelected,
					ZIndex = 6,
					Callback = function()
						return SetValue(Value)
					end,
				})

				table.insert(Entries, Entry)
			end
		end

		--// Update object
		if Items then
			Config:SetItems(Items, Selected)
		end

		return Class, Object
	end,
})

ReGui:DefineElement("OverlayScroll", {
	Base = {
		ElementClass = "OverlayScroll",
		Spacing = UDim.new(0, 4),
	},
	Create = function(self, Config)
		local WindowClass = self.WindowClass

		local ElementClass = Config.ElementClass
		local Spacing = Config.Spacing

		--// Create overlay object
		local Object = ReGui:InsertPrefab(ElementClass, Config)
		local ContentFrame = Object:FindFirstChild("ContentFrame") or Object
		local ListLayout = Object:FindFirstChild("UIListLayout", true)

		ListLayout.Padding = Spacing

		local Class = ReGui:MergeMetatables(self, Config)

		--// Content canvas
		local Canvas = ReGui:MakeCanvas({
			Element = ContentFrame,
			WindowClass = WindowClass,
			Class = Class
		})

		function Config:GetCanvasSize()
			return ContentFrame.AbsoluteCanvasSize
		end

		return Canvas, Object
	end,
})

ReGui:DefineElement("Overlay", {
	Base = {
		ElementClass = "Overlay"
	},
	Create = Elements.OverlayScroll,
})

export type Image = {
	Image: (string|number),
	Callback: ((...any) -> unknown)?
}
ReGui:DefineElement("Image", {
	Base = {
		Image = "",
		Callback = EmptyFunction
	},
	Create = function(self, Config: Image): ImageButton
		--// Create image object
		local Object = ReGui:InsertPrefab("Image", Config)
		Object.Activated:Connect(function(...)
			local Func = Config.Callback
			return Func(Object, ...)
		end)

		return Object
	end,
})

export type VideoPlayer = {
	Video: (string|number),
	Callback: ((...any) -> unknown)?
}
ReGui:DefineElement("VideoPlayer", {
	Base = {
		Video = "",
		Callback = EmptyFunction
	},
	Create = function(self, Config: VideoPlayer): VideoFrame
		--// Correct configuration
		local Video = Config.Video
		Config.Video = Wrappers:CheckAssetUrl(Video)

		--// Create object
		local Object = ReGui:InsertPrefab("VideoPlayer", Config)
		return Object
	end,
})

export type Button = {
	Text: string?,
	DoubleClick: boolean?,
	Callback: ((...any) -> unknown)?,
	Disabled: boolean?,
	SetDisabled: (Button, Disabled: boolean) -> Button
}
ReGui:DefineElement("Button", {
	Base = {
		Text = "Button",
		DoubleClick = false,
		Callback = EmptyFunction
	},
	Create = function(self, Config: Button): TextButton
		--// Create button object
		local Object = ReGui:InsertPrefab("Button", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local DoubleClick = Config.DoubleClick
		function Config:SetDisabled(Disabled: boolean)
			self.Disabled = Disabled
		end

		--// MouseEvents
		ReGui:ConnectMouseEvent(Object, {
			DoubleClick = DoubleClick,
			Callback = function(...)
				if Config.Disabled then return end
				local Func = Config.Callback
				return Func(Class, ...)
			end,
		})

		return Class, Object
	end,
})

export type Selectable = {
	Text: string?,
	Selected: boolean?,
	Disabled: boolean?,
	Callback: ((...any) -> unknown)?,
	SetSelected: (Selectable, Selected: boolean?) -> Selectable,
	SetDisabled: (Selectable, Disabled: boolean?) -> Selectable
}
ReGui:DefineElement("Selectable", {
	Base = {
		Text = "Selectable",
		Callback = EmptyFunction,
		Selected = false,
		Disabled = false,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Left,
		AnimationTags = {
			Selected = "Buttons",
			Unselected = "TransparentButtons"
		},
	},
	Create = function(self, Config: Selectable): (table, TextButton)
		local AfterClick = self.Class.AfterClick

		local Selected = Config.Selected
		local Disabled = Config.Disabled

		--// Create button object
		local Object = ReGui:InsertPrefab("Button", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		Object.Activated:Connect(function(...)
			--// Invoke callback
			local Func = Config.Callback
			Func(Object, ...)

			--// The canvas after click event
			if AfterClick then
				AfterClick(Object, ...)
			end
		end)

		function Config:SetSelected(Selected: boolean?)
			local Animations = self.AnimationTags
			local Animation = Selected and Animations.Selected or Animations.Unselected

			self.Selected = Selected
			ReGui:SetAnimation(Object, Animation)
			return self
		end

		function Config:SetDisabled(Disabled: boolean?)
			self.Disabled = Disabled
			Object.Interactable = not Disabled
			return self
		end

		--// Update object state
		Config:SetSelected(Selected)
		Config:SetDisabled(Disabled)

		return Class, Object
	end,
})

export type ImageButton = {
	Image: (string|number),
	Callback: ((...any) -> unknown)?
}
ReGui:DefineElement("ImageButton", {
	Base = {
		ElementStyle = "Button",
		Callback = EmptyFunction
	},
	Create = Elements.Image,
})

ReGui:DefineElement("SmallButton", {
	Base = {
		Text = "Button",
		PaddingTop = UDim.new(),
		PaddingBottom = UDim.new(),
		PaddingLeft = UDim.new(0, 2),
		PaddingRight = UDim.new(0, 2),
		ColorTag = "Button",
		ElementStyle = "Button",
		Callback = EmptyFunction,
	},
	Create = Elements.Button
})

type KeyId = (Enum.UserInputType | Enum.KeyCode)?
export type Keybind = {
	Value: Enum.KeyCode?,
	DeleteKey: Enum.KeyCode?,
	Enabled: boolean?,
	IgnoreGameProcessed: boolean?,
	Callback: ((KeyId) -> any)?,
	OnKeybindSet: ((KeyId) -> any)?,
	OnBlacklistedKeybindSet: ((KeyId) -> any)?,
	KeyBlacklist: {
		[number]: KeyId
	},
	Label: string?,
	Disabled: boolean?,

	_WaitingForNewKey: boolean?,
	SetValue: (Keybind, New: Enum.KeyCode) -> Keybind,
	SetDisabled: (Keybind, Disabled: boolean) -> Keybind,
	WaitForNewKey: (Keybind) -> any,
	Connection: RBXScriptConnection
}
ReGui:DefineElement("Keybind", {
	Base = {
		Label = "Keybind",
		ColorTag = "Frame",
		Value = nil,
		DeleteKey = Enum.KeyCode.Backspace,
		IgnoreGameProcessed = true,
		Enabled = true,
		Disabled = false,
		Callback = EmptyFunction,
		OnKeybindSet = EmptyFunction,
		OnBlacklistedKeybindSet = EmptyFunction,
		KeyBlacklist = {},
		UiPadding = UDim.new(),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(0.3, 0, 0, 19)
	},
	Create = function(Canvas, Config: Keybind)
		local Value = Config.Value
		local LabelText = Config.Label
		local Disabled = Config.Disabled
		local KeyBlacklist = Config.KeyBlacklist

		--// Create keybind object
		local Object = ReGui:InsertPrefab("Button", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local Label = Canvas:Label({
			Parent = Object, 
			Text = LabelText,
			Position = UDim2.new(1, 4, 0.5),
			AnchorPoint = Vector2.new(0, 0.5)
		})

		local function Callback(Func, ...)
			return Func(Object, ...)
		end

		local function KeyIsBlacklisted(KeyId: KeyId)
			return table.find(KeyBlacklist, KeyId)
		end

		function Config:SetDisabled(Disabled: boolean)
			self.Disabled = Disabled
			Object.Interactable = not Disabled
			Canvas:SetColorTags({
				[Label] = Disabled and "LabelDisabled" or "Label"
			}, true)
			return self
		end

		function Config:SetValue(KeyId: KeyId)
			local OnKeybindSet = self.OnKeybindSet
			local DeleteKey = self.DeleteKey

			--// Remove keybind 
			if KeyId == DeleteKey then
				KeyId = nil
			end

			self.Value = KeyId
			Object.Text = KeyId and KeyId.Name or "Not set"

			--// Invoke OnKeybindSet callback
			Callback(OnKeybindSet, KeyId)
			return self
		end

		function Config:WaitForNewKey()
			self._WaitingForNewKey = true
			Object.Text = "..."
			Object.Interactable = false
		end

		local function GetKeyId(Input: InputObject)
			local KeyCode = Input.KeyCode
			local InputType = Input.UserInputType

			--// Convert mouse input
			if InputType ~= Enum.UserInputType.Keyboard then
				return InputType
			end

			return KeyCode
		end

		local function CheckNewKey(Input: InputObject)
			local OnBlacklistedKeybindSet = Config.OnBlacklistedKeybindSet
			local Previous = Config.Value

			local KeyId = GetKeyId(Input)

			--// Check if window is focused
			if not UserInputService.WindowFocused then return end 

			--// Check if keycode is blacklisted
			if KeyIsBlacklisted(KeyId) then
				--// Invoke OnKeybindSet callback
				Callback(OnBlacklistedKeybindSet, KeyId)
				return
			end

			Object.Interactable = true
			Config._WaitingForNewKey = false

			--// Reset back to previous if new key is unknown
			if KeyId.Name == "Unknown" then
				return Config:SetValue(Previous)
			end

			--// Set new keybind
			Config:SetValue(KeyId)
			return
		end

		local function InputBegan(Input: InputObject, GameProcessed: boolean)
			local IgnoreGameProcessed = Config.IgnoreGameProcessed
			local DeleteKey = Config.DeleteKey
			local Enabled = Config.Enabled
			local Value = Config.Value
			local Func = Config.Callback

			local KeyId = GetKeyId(Input)

			--// OnKeybindSet
			if Config._WaitingForNewKey then
				CheckNewKey(Input)
				return
			end

			--// Check input state
			if not Enabled and Object.Interactable then return end
			if not IgnoreGameProcessed and GameProcessed then return end

			--// Check KeyCode
			if not Value then return end
			if KeyId == DeleteKey then return end
			if KeyId.Name ~= Value.Name then return end 

			--// Invoke callback
			Callback(Func, KeyId)
		end

		--// Update object state
		Config:SetValue(Value)
		Config:SetDisabled(Disabled)

		--// Connect events
		Config.Connection = UserInputService.InputBegan:Connect(InputBegan)
		Object.Activated:Connect(function()
			Config:WaitForNewKey()
		end)

		ReGui:SetAnimation(Object, "Inputs")

		return Class, Object
	end
})

ReGui:DefineElement("ArrowButton", {
	Base = {
		Direction = "Left",
		ColorTag = "Button",
		Icon = ReGui.Icons.Arrow,
		Size = UDim2.fromOffset(21, 21),
		IconSize = UDim2.fromScale(1, 1),
		IconPadding = UDim.new(0, 4),
		Rotations = {
			Left = 180,
			Right = 0,
		}
	},
	Create = function(self, Config): ScrollingFrame
		--// Unpack configuration
		local Direction = Config.Direction
		local Rotations = Config.Rotations

		local Rotation = Rotations[Direction]
		Config.IconRotation = Rotation

		--// Create object
		local Object = ReGui:InsertPrefab("ArrowButton", Config)
		Object.Activated:Connect(function(...)
			local Func = Config.Callback
			return Func(Object, ...)
		end)

		return Object
	end,
})

export type Label = {
	Text: string,
	Bold: boolean?,
	Italic: boolean?,
	Font: string?,
	FontFace: Font?
}
ReGui:DefineElement("Label", {
	Base = {
		Font = "Inconsolata"
	},
	ColorData = {
		["LabelPadding"] = {
			PaddingTop = "LabelPaddingTop",
			PaddingBottom = "LabelPaddingBottom"
		},
	},
	Create = function(self, Config: Label): TextLabel
		--// Unpack config
		local IsBold = Config.Bold
		local IsItalic = Config.Italic
		local FontName = Config.Font
		local FontFace = Config.FontFace

		--// Weghts
		local Medium = Enum.FontWeight.Medium
		local Bold = Enum.FontWeight.Bold

		--// Styles
		local Normal = Enum.FontStyle.Normal
		local Italic = Enum.FontStyle.Italic

		local Weight = IsBold and Bold or Medium
		local Style = IsItalic and Italic or Normal
		local AddFlag = IsBold or IsItalic

		if not FontFace and AddFlag then
			Config.FontFace = Font.fromName(FontName, Weight, Style)
		end

		local Label = ReGui:InsertPrefab("Label", Config)
		local Padding = Label:FindFirstChildOfClass("UIPadding")

		self:TagElements({
			[Padding] = "LabelPadding",
		})

		--// Create label
		return Label
	end,
})

ReGui:DefineElement("Error", {
	Base = {
		RichText = true,
		TextWrapped = true
	},
	ColorData = {
		["Error"] = {
			TextColor3 = "ErrorText",
			FontFace = "TextFont",
		},
	},
	Create = function(self, Config: Label)
		local Message = Config.Text
		Config.Text = `<b>⛔ Error:</b> {Message}`

		return self:Label(Config)
	end,
})

export type CodeEditor = {
    Editable: boolean?,
    FontSize: number?,
    FontFace: Font?,
	Text: string?,
    
    --// Methods
    ApplyTheme: (CodeEditor) -> nil,
    GetVersion: (CodeEditor) -> string,
    ClearText: (CodeEditor) -> nil,
    SetText: (CodeEditor, Text: string) -> nil,
    GetText: (CodeEditor) -> string,
    SetEditing: (CodeEditor, Editing: boolean) -> nil,
    AppendText: (CodeEditor, Text: string) -> nil,
    ResetSelection: (CodeEditor, NoRefresh: boolean?) -> nil,
    GetSelectionText: (CodeEditor) -> string,
    
    --// Properties
    Gui: Frame,
    Editing: boolean
}
ReGui:DefineElement("CodeEditor", {
	Base = {
		Editable = true,
		Fill = true,
		Text = ""
	},
	Create = function(self, Config: CodeEditor)
		local Window = self.WindowClass
		local CodeEditor = IDE.CodeFrame.new(Config)
		local Frame = CodeEditor.Gui

		Config.Parent = self:GetObject()

		ReGui:ApplyFlags({
			Object = Frame,
			WindowClass = Window,
			Class = Config
		})

		return CodeEditor, Frame
	end,
})

------// MenuBar class
local MenuBar = {
	Engaged = false
}
MenuBar.__index = MenuBar

function MenuBar:SetEngaged(Engaged: boolean)
	local Window = self.WindowClass
	self.Engaged = Engaged

	--// Set the Window interaction state based on the MenuBar enagement
	if Window then
		Window:SetCanvasInteractable(not Engaged)
	end
end

function MenuBar:IsHovering(): boolean
	local Hovering = false

	--// Check the hover state for each menu
	self:Foreach(function(Data)
		Hovering = Data.Popup:IsMouseHovering()
		return Hovering
	end)

	return Hovering
end

function MenuBar:Foreach(Func)
	local Menus = self.Menus
	for _, Data in next, Menus do
		--// Invoke callback
		local Break = Func(Data)
		if Break then break end
	end
end

function MenuBar:SetFocusedMenu(Menu)
	self:Foreach(function(Data)
		--// Set active state based on if MenuItem is the requested
		local Active = Data == Menu
		Data:SetActiveState(Active)
	end)
end

function MenuBar:Close()
	self:SetEngaged(false)
	self:SetFocusedMenu(nil)
end

function MenuBar:MenuItem(Config)
	local Canvas = self.Canvas
	local Menus = self.Menus

	--// Create elements
	local Selectable = Canvas:MenuButton(Config)
	local Popup = Canvas:PopupCanvas({
		RelativeTo = Selectable,
		MaxSizeX = 210,
		Visible = false,
		AutoClose = false,
		AfterClick = function()
			self:Close()
		end,
	})

	--// Menu data for the array
	local MenuData = {
		Popup = Popup,
		Button = Selectable
	}

	--// Connect mouse focus events
	ReGui:DetectHover(Selectable, {
		MouseEnter = true,
		OnInput = function()
			if not self.Engaged then return end
			self:SetFocusedMenu(MenuData)
		end,
	})

	function MenuData:SetActiveState(Active: boolean)
		Popup:SetPopupVisible(Active)
		Selectable:SetSelected(Active)
	end

	--// Engage button connections
	Selectable.Activated:Connect(function()
		self:SetFocusedMenu(MenuData)
		self:SetEngaged(true)
	end)

	--// Add menu to the Menu array
	table.insert(Menus, MenuData)

	return Popup, MenuData
end

ReGui:DefineElement("MenuBar", {
	Base = {},
	Create = function(self, Config): Elements
		local WindowClass = self.WindowClass

		--// Create object
		local Object = ReGui:InsertPrefab("MenuBar", Config)

		--// Content canvas
		local Canvas = ReGui:MakeCanvas({
			Element = Object,
			WindowClass = WindowClass,
			Class = Config
		})

		--// Make menu bar class
		local Class = Wrappers:NewClass(MenuBar, {
			WindowClass = WindowClass,
			Canvas = Canvas,
			Object = Object,
			Menus = {}
		})
		Merge(Class, Config)

		--// Mouse click detection for closure
		ReGui:DetectHover(Object, {
			MouseOnly = true,
			OnInput = function()
				if not Class.Engaged then return end
				if Class:IsHovering() then return end

				Class:Close()
			end,
		})

		local Meta = ReGui:MergeMetatables(Class, Canvas)
		return Meta, Object
	end,
})

ReGui:DefineElement("MenuButton", {
	Base = {
		Text = "MenuButton",
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Size = UDim2.fromOffset(0, 19),
		AutomaticSize = Enum.AutomaticSize.XY
	},
	Create = Elements.Selectable
})

----// TabsBar class
local TabBarClass = {
	ColorTags = {
		BGSelected = {
			[true] = "SelectedTab",
			[false] = "DeselectedTab"
		},
		LabelSelected = {
			[true] = "SelectedTabLabel",
			[false] = "DeselectedTabLabel"
		},
	}
}
function TabBarClass:SetButtonSelected(Tab: table, Selected: boolean)	
	--// Ignore update if the value is identical
	if Tab.IsSelected == Selected then return end
	Tab.IsSelected = Selected

	local NoAnimation = self.NoAnimation
	local WindowClass = self.WindowClass
	local ColorTags = self.ColorTags

	--// Coloring dicts
	local Theme = WindowClass.Theme
	local Elements = WindowClass.TagsList

	--// Colors tags
	local BGSelected = ColorTags.BGSelected
	local LabelSelected = ColorTags.LabelSelected

	local TabButton = Tab.TabButton
	local Button = TabButton.Button
	local Label = Button.Label

	ReGui:MultiUpdateColors({
		Animate = not NoAnimation,
		Theme = Theme,
		TagsList = Elements,
		Objects = {
			[Button] = BGSelected[Selected],
			[Label] = LabelSelected[Selected],
		},
	})
end

function TabBarClass:CompareTabs(Tab, Match)
	if not Tab then return false end
	return Tab.MatchBy == Match or Tab == Match
end

function TabBarClass:ForEachTab(Match: (Tab|string), Func: (Tab, IsMatch: boolean, Index: number) -> nil)
	local CompareName = typeof(Match) == "string"
	local Tabs = self.Tabs

	for Index, Tab in Tabs do
		local Name = Tab.Name
		local IsMatch = false

		--// Match for requested content type
		if CompareName then
			IsMatch = Name == Match
		else
			IsMatch = self:CompareTabs(Tab, Match)
		end

		--// Invoke callback
		Func(Tab, IsMatch, Index)
	end
end

function TabBarClass:RemoveTab(Target: (Tab|string))
	local OnTabRemove = self.OnTabRemove
	local Tabs = self.Tabs

	self:ForEachTab(Target, function(Tab, IsMatch, Index)
		if not IsMatch then return end
		local TabButton = Tab.TabButton
		local OnClosure = Tab.OnClosure

		--// Remove
		table.remove(Tabs, Index)
		TabButton:Destroy()

		--// Invoke OnClosure
		OnTabRemove(self, Tab)
		OnClosure(Tab)
	end)

	return self
end

export type Tab = {
	Name: string,
	Focused: boolean?,
	TabButton: boolean?,
	Closeable: boolean?,
	OnClosure: (Tab) -> nil,
	Icon: (string|number)?
}
function TabBarClass:CreateTab(Config: Tab): Elements
	Config = Config or {}
	ReGui:CheckConfig(Config, {
		Name = "Tab",
		AutoSize = "Y",
		Focused = false,
		OnClosure = EmptyFunction
	})

	--// Unpack class data
	local AutoSelectNewTabs = self.AutoSelectNewTabs
	local WindowClass = self.WindowClass
	local ParentCanvas = self.ParentCanvas
	local Tabs = self.Tabs
	local TabsFrame = self.TabsFrame
	local OnTabCreate = self.OnTabCreate

	--// Unpack config
	local Focused = Config.Focused
	local Name = Config.Name
	local Icon = Config.Icon
	local IsFocused = Focused or #Tabs <= 0 and AutoSelectNewTabs

	--// Template sources
	local TabButton = ReGui:InsertPrefab("TabButton", Config)
	TabButton.Parent = TabsFrame

	--// Create new tab button
	local Button = TabButton.Button
	local TextPadding = Button:FindFirstChildOfClass("UIPadding")
	local Label = Button.Label
	Label.Text = tostring(Name)

	Merge(Config, {
		TabButton = TabButton
	})

	local function SetActive()
		self:SetActiveTab(Config)
	end

	--// Addional flags
	local ExtraFlags = {
		["Closeable"] = function()
			local Button = ParentCanvas:RadioButton({
				Parent = Button,
				Visible = not self.NoClose,
				Icon = ReGui.Icons.Close,
				IconSize = UDim2.fromOffset(11,11),
				LayoutOrder = 3,
				ZIndex = 2,
				UsePropertiesList = true,
				Callback = function()
					self:RemoveTab(Config)
				end,
			})

			--// Animate close icon on hover
			local Icon = Button.Icon
			ReGui:SetAnimation(Icon, {
				Connections = {
					MouseEnter = {
						ImageTransparency = 0,
					},
					MouseLeave = {
						ImageTransparency = 1,
					}
				},
				Init = "MouseLeave"
			}, TabButton)
		end,
	}

	--// Connect events
	Button.Activated:Connect(SetActive)

	--// Apply flags
	ReGui:CheckFlags(ExtraFlags, Config)

	--// Add to tabs dict
	table.insert(Tabs, Config)

	--// Add color infomation
	if WindowClass then
		WindowClass:TagElements({
			[TextPadding] = "TabPadding",
		})
	end

	--// Set animation for tab button
	ReGui:SetAnimation(Button, "Buttons")
	self:SetButtonSelected(Config, IsFocused)	

	--// Apply flags
	ParentCanvas:ApplyFlags(TabButton, Config)

	local Responce = OnTabCreate(self, Config)

	--// Change tab focus
	if IsFocused then
		self:SetActiveTab(Config)
	end

	return Responce or Config
end

function TabBarClass:SetActiveTab(Target: (table|string))
	--// Unpack class data
	local Tabs = self.Tabs
	local NoAnimation = self.NoAnimation
	local Previous = self.ActiveTab
	local OnActiveTabChange = self.OnActiveTabChange

	local MatchName = typeof(Target) == "string"
	local MatchedTab = nil
	local IsVisible = false

	self:ForEachTab(Target, function(Tab, IsMatch, Index)
		if IsMatch then
			MatchedTab = Tab
		end
		self:SetButtonSelected(Tab, IsMatch)
	end)

	if not MatchedTab then return self end
	if self:CompareTabs(MatchedTab, Previous) then return self end

	self.ActiveTab = MatchedTab

	--// Invoke OnActiveTabChange
	OnActiveTabChange(self, MatchedTab, Previous)

	return self
end

export type TabBar = {
	AutoSelectNewTabs: boolean,
	OnActiveTabChange: ((TabBar, Tab: Tab, Previous: Tab) -> nil)?,
	OnTabCreate: ((TabBar, Tab: Tab) -> nil)?,
	OnTabRemove: ((TabBar, Tab: Tab) -> nil)?
}
ReGui:DefineElement("TabBar", {
	Base = {
		AutoSelectNewTabs = true,
		OnActiveTabChange = EmptyFunction,
		OnTabCreate = EmptyFunction,
		OnTabRemove = EmptyFunction,
	},
	ColorData = {
		["DeselectedTab"] = {
			BackgroundColor3 = "TabBg"
		},
		["SelectedTab"] = {
			BackgroundColor3 = "TabBgActive"
		},
		["DeselectedTabLabel"] = {
			FontFace = "TextFont",
			TextColor3 = "TabText",
		},
		["SelectedTabLabel"] = {
			FontFace = "TextFont",
			TextColor3 = "TabTextActive",
		},
		["TabsBarSeparator"] = {
			BackgroundColor3 = "TabBgActive",
		},
		["TabPadding"] = {
			PaddingTop = "TabTextPaddingTop",
			PaddingBottom = "TabTextPaddingBottom"
		},
		["TabPagePadding"] = {
			PaddingBottom = "TabPagePadding",
			PaddingLeft = "TabPagePadding",
			PaddingRight = "TabPagePadding",
			PaddingTop = "TabPagePadding",
		}
	},
	Create = function(self, Config: TabBar)
		local WindowClass = self.WindowClass

		--// Create object
		local Object = ReGui:InsertPrefab("TabsBar", Config)
		local Class = Wrappers:NewClass(TabBarClass)

		local Separator = Object.Separator
		local TabsFrame = Object.TabsFrame

		--// Create canvas
		local TabsRailCanvas = ReGui:MakeCanvas({
			Element = TabsFrame,
			WindowClass = WindowClass,
			Class = Class
		})

		--// Merge configurations into the class
		Merge(Class, Config)
		Merge(Class, {
			ParentCanvas = self,
			Object = Object,
			TabsFrame = TabsFrame,
			WindowClass = WindowClass,
			Tabs = {}
		})

		--// Tag elementss
		self:TagElements({
			[Object] = "TabsBar",
			[Separator] = "TabsBarSeparator",
		})

		local Merged = ReGui:MergeMetatables(TabsRailCanvas, Object)
		return Merged, Object
	end,
})

export type TabSelector = {
	NoTabsBar: boolean?,
	NoAnimation: boolean?
} & TabBar
ReGui:DefineElement("TabSelector", {
	Base = {
		NoTabsBar = false,
		OnActiveTabChange = EmptyFunction,
		OnTabCreate = EmptyFunction,
		OnTabRemove = EmptyFunction,
	},
	Create = function(Canvas, Config: TabSelector): (TabSelector, GuiObject)
		local WindowClass = Canvas.WindowClass

		local NoTabsBar = Config.NoTabsBar
		local NoAnimation = Config.NoAnimation

		--// Create TabSelector object
		local Object = ReGui:InsertPrefab("TabSelector", Config)

		local Body = Object.Body
		local PageTemplate = Body.PageTemplate
		PageTemplate.Visible = false

		--// TabsBar functions
		local function OnTabCreate(self, Tab, ...)
			local AutoSize = Tab.AutoSize
			local Name = Tab.Name

			--// Create page
			local Page = PageTemplate:Clone()
			local PagePadding = Wrappers:GetChildOfClass(Page, "UIPadding")

			ReGui:SetProperties(Page, {
				Parent = Body,
				Name = Name,
				AutomaticSize = Enum.AutomaticSize[AutoSize],
				Size = UDim2.fromScale(
					AutoSize == "Y" and 1 or 0, 
					AutoSize == "X" and 1 or 0
				)
			})

			--// Page padding
			Canvas:TagElements({
				[PagePadding] = "TabPagePadding",
			})

			--// Create canvas
			local Canvas = ReGui:MakeCanvas({
				Element = Page,
				WindowClass = WindowClass,
				Class = Tab
			})

			--// Invoke user callback
			Config.OnTabCreate(self, Tab, ...)

			Merge(Tab, {
				Page = Page,
				MatchBy = Canvas
			})

			return Canvas
		end
		local function OnActiveTabChange(self, Tab, ...)
			self:ForEachTab(Tab, function(Tab, IsMatch, Index)
				local Page = Tab.Page
				Page.Visible = IsMatch

				if not IsMatch then return end

				--// Slide in effect
				local Tweeninfo = Canvas:GetThemeKey("AnimationTweenInfo")
				Animation:Tween({
					Object = Page,
					Tweeninfo = Tweeninfo,
					NoAnimation = NoAnimation,
					StartProperties = {
						Position = UDim2.fromOffset(0, 4)
					},
					EndProperties = {
						Position = UDim2.fromOffset(0, 0)
					}
				})
			end)

			--// Invoke user callback
			Config.OnActiveTabChange(self, Tab, ...)
		end

		--// Create tabs bar
		local TabsBar = Canvas:TabBar({
			Parent = Object,
			Visible = not NoTabsBar,
			OnTabCreate = OnTabCreate,
			OnActiveTabChange = OnActiveTabChange,
			OnTabRemove = function(self, Tab, ...)
				Tab.Page:Remove()
				Config.OnTabRemove(...) --// Invoke user callback
			end,
		})

		local Class = ReGui:MergeMetatables(TabsBar, Object)
		return Class, Object
	end,
})

export type RadioButton = {
	Icon: string?,
	IconRotation: number?,
	Callback: ((...any) -> unknown)?,
}
ReGui:DefineElement("RadioButton", {
	Base = {
		Callback = EmptyFunction,
	},
	Create = function(self, Config: RadioButton): GuiButton
		local Object = ReGui:InsertPrefab("RadioButton", Config)
		Object.Activated:Connect(function(...)
			local Callback = Config.Callback
			return Callback(Object, ...)
		end)

		return Object
	end,
})

export type Checkbox = {
	Label: string?,
	IsRadio: boolean?,
	Value: boolean,
	Disabled: boolean?,
	NoAnimation: boolean?,
	Callback: ((...any) -> unknown)?,
	SetValue: (self: Checkbox, Value: boolean, NoAnimation: boolean) -> ...any,
	Toggle: (self: Checkbox) -> ...any,
	TickedImageSize: UDim2,
	UntickedImageSize: UDim2,
	SetTicked: (Checkbox, Value: boolean) -> any, --(Use SetValue instead)
	SetDisabled: (Checkbox, Disabled: boolean) -> Checkbox
}
ReGui:DefineElement("Checkbox", {
	Base = {
		Label = "Checkbox",
		IsRadio = false,
		Value = false,
		NoAutoTag = true,
		TickedImageSize = UDim2.fromScale(1, 1),
		UntickedImageSize = UDim2.fromScale(0,0),
		Callback = EmptyFunction,
		Disabled = false
	},
	Create = function(Canvas, Config: Checkbox): Checkbox
		--// Unpack configuration
		local IsRadio = Config.IsRadio
		local Value = Config.Value
		local Text = Config.Label
		local TickedSize = Config.TickedImageSize
		local UntickedSize = Config.UntickedImageSize
		local Disabled = Config.Disabled

		--// Check checkbox object
		local Object = ReGui:InsertPrefab("CheckBox", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local Tickbox = Object.Tickbox
		local Tick = Tickbox.Tick
		Tick.Image = ReGui.Icons.Checkmark

		--// Styles
		local UIPadding = Tickbox:FindFirstChildOfClass("UIPadding")
		local UICorner = Wrappers:GetChildOfClass(Tickbox, "UICorner")

		--// Create label
		local Label = Canvas:Label({
			Text = Text,
			Parent = Object,
			LayoutOrder = 2
		})

		--// Stylise to correct type
		local PaddingSize = UDim.new(0, 3)
		if IsRadio then
			Tick.ImageTransparency = 1
			Tick.BackgroundTransparency = 0
			UICorner.CornerRadius = UDim.new(1, 0)
		else
			PaddingSize = UDim.new(0, 2)
		end

		--// Apply UIPadding sizes
		ReGui:SetProperties(UIPadding, {
			PaddingBottom = PaddingSize,
			PaddingLeft = PaddingSize,
			PaddingRight = PaddingSize,
			PaddingTop = PaddingSize,
		})

		--// Callback
		local function Callback(...)
			local func = Config.Callback
			return func(Class, ...)
		end

		local function SetStyle(Value: boolean, NoAnimation: boolean)
			local Tweeninfo = Canvas:GetThemeKey("AnimationTweenInfo")

			--// Animate tick
			local Size = Value and TickedSize or UntickedSize
			Animation:Tween({
				Object = Tick,
				Tweeninfo = Tweeninfo,
				NoAnimation = NoAnimation,
				EndProperties = {
					Size = Size
				}
			})
		end

		function Config:SetDisabled(Disabled: boolean)
			self.Disabled = Disabled
			Object.Interactable = not Disabled
			Canvas:SetColorTags({
				[Label] = Disabled and "LabelDisabled" or "Label"
			}, true)
			return self
		end

		function Config:SetValue(Value: boolean, NoAnimation: boolean)
			self.Value = Value

			--// Animate
			SetStyle(Value, NoAnimation)

			--// Fire callback
			Callback(Value)

			return self
		end

		function Config:SetTicked(...)
			ReGui:Warn("Checkbox:SetTicked is deprecated, please use :SetValue")
			return self:SetValue(...)
		end

		function Config:Toggle()
			local Value = not self.Value
			self.Value = Value
			self:SetValue(Value)

			return self
		end

		--// Connect functions
		local function Clicked()
			Config:Toggle()
		end

		--// Connect events
		Object.Activated:Connect(Clicked)
		Tickbox.Activated:Connect(Clicked)

		--// Update object state
		Config:SetValue(Value, true)
		Config:SetDisabled(Disabled)

		--// Style elements
		ReGui:SetAnimation(Tickbox, "Buttons", Object)
		Canvas:TagElements({
			[Tick] = "CheckMark",
			[Tickbox] = "Checkbox"
		})

		return Class, Object
	end,
})

ReGui:DefineElement("Radiobox", {
	Base = {
		IsRadio = true,
		CornerRadius = UDim.new(1,0),
	},
	Create = Elements.Checkbox,
})

export type PlotHistogram = {
	Label: string?,
	Points: {
		[number]: number
	},
	Minimum: number?,
	Maximum: number?,
	GetBaseValues: (PlotHistogram) -> (number, number),
	UpdateGraph: (PlotHistogram) -> PlotHistogram,
	PlotGraph: (PlotHistogram, Points: {
		[number]: number
	}) -> PlotHistogram,
	Plot: (PlotHistogram, Value: number) -> {
		SetValue: (PlotHistogram, Value: number) -> nil,
		GetPointIndex: (PlotHistogram) -> number,
		Remove: (PlotHistogram, Value: number) -> nil,
	},
}
ReGui:DefineElement("PlotHistogram", {
	Base = {
		ColorTag = "Frame",
		Label = "Histogram"
	},
	Create = function(Canvas, Config: PlotHistogram)
		--// Unpack configuration
		local LabelText = Config.Label
		local Points = Config.Points

		--// Create Object
		local Object = ReGui:InsertPrefab("Histogram", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local GraphCanvas = Object.Canvas
		local PointTemplate = GraphCanvas.PointTemplate
		PointTemplate.Visible = false --// Hide template

		Canvas:Label({
			Text = LabelText,
			Parent = Object,
			Position = UDim2.new(1, 4)
		})

		--// Create tooltip
		local ValueLabel = nil
		ReGui:SetItemTooltip(Object, function(Canvas)
			ValueLabel = Canvas:Label()
		end)

		Merge(Config, {
			_Plots = {},
			_Cache = {}
		})

		function Config:GetBaseValues(): (number, number)
			local Minimum = self.Minimum
			local Maximum = self.Maximum

			--// User defined minimum
			if Minimum and Maximum then
				return Minimum, Maximum
			end

			local Plots = self._Plots

			for _, Data in Plots do
				local Value = Data.Value

				--// Minimum
				if not Minimum or Value < Minimum then
					Minimum = Value
				end

				--// Maximum
				if not Maximum or Value > Maximum then
					Maximum = Value
				end
			end

			return Minimum, Maximum
		end

		function Config:UpdateGraph()
			local Plots = self._Plots

			local Minimum, Maximum = self:GetBaseValues()
			if not Minimum or not Maximum then return end

			local Difference = Maximum - Minimum

			--// Update each plot on the graph
			for _, Data in Plots do
				local Point = Data.Point
				local Value = Data.Value

				local Scale = (Value - Minimum) / Difference
				Scale = math.clamp(Scale, 0.05, 1)

				Point.Size = UDim2.fromScale(1, Scale)
			end

			return self
		end

		function Config:Plot(Value)
			local Plots = self._Plots
			local Module = {}

			--// Create a new plot Object
			local Plot = PointTemplate:Clone()
			local Point = Plot.Bar

			ReGui:SetProperties(Plot, {
				Parent = GraphCanvas,
				Visible = true
			})

			local HoverConnection = ReGui:DetectHover(Plot, {
				MouseEnter = true,
				OnInput = function()
					Module:UpdateTooltip()
				end,
			})

			local Data = {
				Object = Plot,
				Point = Point,
				Value = Value
			}

			function Module:UpdateTooltip()
				local Index = Module:GetPointIndex()
				ValueLabel.Text = `{Index}:	{Data.Value}`
			end

			function Module:SetValue(Value)
				Data.Value = Value
				Config:UpdateGraph()

				--// Update tooltip value if hovered
				if HoverConnection.Hovering then
					self:UpdateTooltip()
				end
			end

			function Module:GetPointIndex(): number
				return table.find(Plots, Data)
			end

			function Module:Remove(Value)
				table.remove(Plots, self:GetPointIndex())
				Plot:Remove()
				Config:UpdateGraph()
			end

			--// Registor plot
			table.insert(Plots, Data)

			--// Update the graph with new values
			self:UpdateGraph()

			--// Style the plot object
			ReGui:SetAnimation(Point, "Plots", Plot)
			Canvas:TagElements({
				[Point] = "Plot"
			})

			return Module
		end

		function Config:PlotGraph(Points)
			local Cache = self._Cache

			--// Remove unsused graph points
			local Extra = #Cache-#Points 
			if Extra >= 1 then
				--// Remove unused graph points
				for Index = 1, Extra do
					local Point = table.remove(Cache, Index)
					if Point then
						Point:Remove()
					end
				end
			end

			for Index, Value in Points do
				--// Use existing point
				local Point = Cache[Index]
				if Point then
					Point:SetValue(Value)
					continue
				end

				--// Create new point
				Cache[Index] = self:Plot(Value)
			end

			return self
		end

		--// Display points
		if Points then
			Config:PlotGraph(Points)
		end

		return Class, Object
	end,
})


export type Viewport = {
	Model: Instance,
	WorldModel: WorldModel?,
	Viewport: ViewportFrame?,
	Camera: Camera?,
	Clone: boolean?,

	SetCamera: (self: Viewport, Camera: Camera) -> Viewport,
	SetModel: (self: Viewport, Model: Model, PivotTo: CFrame?) -> Model,
}
ReGui:DefineElement("Viewport", {
	Base = {
		IsRadio = true,
	},
	Create = function(self, Config: Viewport): Viewport
		--// Unpack configuration
		local Model = Config.Model
		local Camera = Config.Camera 

		--// Create viewport object
		local Object = ReGui:InsertPrefab("Viewport", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local Viewport = Object.Viewport
		local WorldModel = Viewport.WorldModel

		if not Camera then
			Camera = ReGui:CreateInstance("Camera", Viewport)
			Camera.CFrame = CFrame.new(0,0,0)
		end

		Merge(Config, {
			Camera = Camera,
			WorldModel = WorldModel,
			Viewport = Viewport
		})

		function Config:SetCamera(Camera)
			self.Camera = Camera
			Viewport.CurrentCamera = Camera
			return self
		end

		function Config:SetModel(Model: Model, PivotTo: CFrame?)
			local CreateClone = self.Clone

			WorldModel:ClearAllChildren()

			--// Set new model
			if CreateClone then
				Model = Model:Clone()
			end

			if PivotTo then
				Model:PivotTo(PivotTo)
			end

			Model.Parent = WorldModel
			self.Model = Model

			return Model
		end

		--// Set model
		if Model then
			Config:SetModel(Model)
		end

		Config:SetCamera(Camera)

		return Class, Object
	end,
})

export type InputText = {
	Value: string,
	Placeholder: string?,
	MultiLine: boolean?,
	Label: string?,
	Disabled: boolean?,

	Callback: ((string, ...any) -> unknown)?,
	Clear: (InputText) -> InputText,
	SetValue: (InputText, Value: string) -> InputText,
	SetDisabled: (InputText, Disabled: boolean) -> InputText,
}
ReGui:DefineElement("InputText", {
	Base = {
		Value = "",
		Placeholder = "",
		Label = "Input text",
		Callback = EmptyFunction,
		MultiLine = false,
		NoAutoTag = true,
		Disabled = false
	},
	Create = function(Canvas, Config: InputText): InputText
		--// Unpack configuration
		local MultiLine = Config.MultiLine
		local Placeholder = Config.Placeholder
		local Label = Config.Label
		local Disabled = Config.Disabled
		local Value = Config.Value

		--// Create Text input object
		local Object = ReGui:InsertPrefab("InputBox", Config)
		local Frame = Object.Frame
		local TextBox = Frame.Input

		local Class = ReGui:MergeMetatables(Config, Object)

		Canvas:Label({
			Parent = Object,
			Text = Label,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 19),
			Position = UDim2.new(1, 4),
			LayoutOrder = 2
		})

		ReGui:SetProperties(TextBox, {
			PlaceholderText = Placeholder,
			MultiLine = MultiLine
		})

		local function Callback(...)
			local Func = Config.Callback
			Func(Class, ...)
		end

		function Config:SetValue(Value: string?)
			TextBox.Text = tostring(Value)
			self.Value = Value
			return self
		end

		function Config:SetDisabled(Disabled: boolean)
			self.Disabled = Disabled
			Object.Interactable = not Disabled
			Canvas:SetColorTags({
				[Label] = Disabled and "LabelDisabled" or "Label"
			}, true)
			return self
		end

		function Config:Clear()
			TextBox.Text = ""
			return self
		end

		local function TextChanged()
			local Value = TextBox.Text
			Config.Value = Value
			Callback(Value)
		end

		--// Connect events
		TextBox:GetPropertyChangedSignal("Text"):Connect(TextChanged)

		--// Update object state
		Config:SetDisabled(Disabled)
		Config:SetValue(Value)

		Canvas:TagElements({
			[TextBox] = "Frame"
		})

		return Class, Object
	end,
})

export type InputInt = {
	Value: number,
	Maximum: number?,
	Minimum: number?,
	Placeholder: string?,
	MultiLine: boolean?,
	NoButtons: boolean?,
	Disabled: boolean?,
	Label: string?,
	Increment: number?,
	Callback: ((string, ...any) -> unknown)?,
	SetValue: (InputInt, Value: number, NoTextUpdate: boolean?) -> InputInt,
	Decrease: (InputInt) -> nil,
	Increase: (InputInt) -> nil,
	SetDisabled: (InputInt, Disabled: boolean) -> InputInt
}
ReGui:DefineElement("InputInt", {
	Base = {
		Value = 0,
		Increment = 1,
		Placeholder = "",
		Label = "Input Int",
		Callback = EmptyFunction,
	},
	Create = function(Canvas, Config: InputInt): InputInt
		--// Unpack configuration
		local Value = Config.Value
		local Placeholder = Config.Placeholder
		local LabelText = Config.Label
		local Disabled = Config.Disabled
		local NoButtons = Config.NoButtons

		--// Create Text input object
		local Object = ReGui:InsertPrefab("InputBox", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local Frame = Object.Frame
		local TextBox = Frame.Input
		TextBox.PlaceholderText = Placeholder

		--// Decrease
		local Decrease = Canvas:Button({
			Text = "-",
			Parent = Frame,
			LayoutOrder = 2,
			Ratio = 1,
			AutomaticSize = Enum.AutomaticSize.None,
			FlexMode = Enum.UIFlexMode.None,
			Size = UDim2.fromScale(1,1),
			Visible = not NoButtons,
			Callback = function()
				Config:Decrease()
			end,
		})

		--// Increase
		local Increase = Canvas:Button({
			Text = "+",
			Parent = Frame,
			LayoutOrder = 3,
			Ratio = 1,
			AutomaticSize = Enum.AutomaticSize.None,
			FlexMode = Enum.UIFlexMode.None,
			Size = UDim2.fromScale(1,1),
			Visible = not NoButtons,
			Callback = function()
				Config:Increase()
			end,
		})

		local Label = Canvas:Label({
			Parent = Object,
			Text = LabelText,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 19),
			Position = UDim2.new(1, 4),
			LayoutOrder = 4
		})

		local function Callback(...)
			local Func = Config.Callback
			Func(Class, ...)
		end

		function Config:Increase()
			local Value = self.Value
			local Increment = self.Increment
			Config:SetValue(Value + Increment)
		end

		function Config:Decrease()
			local Value = self.Value
			local Increment = self.Increment
			Config:SetValue(Value - Increment)
		end

		function Config:SetDisabled(Disabled: boolean)
			self.Disabled = Disabled
			Object.Interactable = not Disabled
			Canvas:SetColorTags({
				[Label] = Disabled and "LabelDisabled" or "Label"
			}, true)
			return self
		end

		function Config:SetValue(Value: number|string)
			local Previous = self.Value
			local Minimum = self.Minimum
			local Maximum = self.Maximum

			--// Replace empty string value with 0
			Value = tonumber(Value)

			--// Check if value is accepted
			if not Value then 
				Value = Previous
			end

			--// Clamp value into a limied range
			if Minimum and Maximum then
				Value = math.clamp(Value, Minimum, Maximum)
			end

			--// Update values
			TextBox.Text = Value
			Config.Value = Value
			Callback(Value)

			return self
		end

		local function TextChanged()
			local New = TextBox.Text
			Config:SetValue(New)
		end

		--// Update object state
		Config:SetValue(Value)
		Config:SetDisabled(Disabled)

		--// Connect events
		TextBox.FocusLost:Connect(TextChanged)

		--// Register elements
		Canvas:TagElements({
			[Increase] = "Button",
			[Decrease] = "Button",
			[TextBox] = "Frame",
		})

		return Class, Object
	end,
})

ReGui:DefineElement("InputTextMultiline", {
	Base = {
		Label = "",
		Size = UDim2.new(1, 0, 0, 39),
		Border = false,
		ColorTag = "Frame"
	},
	Create = function(self, Config)
		return self:Console(Config)
	end,
})

export type Console = {
	Enabled: boolean?,
	ReadOnly: boolean?,
	Value: string?,
	RichText: boolean?,
	TextWrapped: boolean?,
	LineNumbers: boolean?,
	AutoScroll: boolean,
	LinesFormat: string,
	MaxLines: number,
	Callback: (Console, Value: string) -> nil,
	Placeholder: string?,

	Update: (Console) -> nil,
	CountLines: (Console) -> number,
	UpdateLineNumbers: (Console) -> Console,
	UpdateScroll: (Console) -> Console,
	SetValue: (Console, Value: string) -> Console,
	GetValue: (Console) -> string,
	Clear: (Console) -> Console,
	AppendText: (Console, ...string) -> Console,
	CheckLineCount: (Console) -> Console
}
ReGui:DefineElement("Console", {
	Base = {
		Enabled = true,
		Value = "",
		TextWrapped = false,
		Border = true,
		MaxLines = 300,
		LinesFormat = "%s",
		Callback = EmptyFunction,
	},
	Create = function(self, Config: Console): Console
		--// Unpack configuration
		local ReadOnly = Config.ReadOnly
		local LineNumbers = Config.LineNumbers
		local Value = Config.Value
		local Placeholder = Config.Placeholder

		--// Create console object
		local Object = ReGui:InsertPrefab("Console", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local Source: TextBox = Object.Source
		local Lines = Object.Lines
		Lines.Visible = LineNumbers

		function Config:CountLines(ExcludeEmpty: boolean?): number
			local Lines = Source.Text:split("\n")
			local Count = #Lines

			if Count == 1 and Lines[1] == "" then
				return 0 
			end

			return Count
		end

		function Config:UpdateLineNumbers()
			--// configuration
			local LineNumbers = self.LineNumbers
			local Format = self.LinesFormat

			--// If line counts are disabled
			if not LineNumbers then return end

			--// Update lines text
			local LinesCount = self:CountLines()
			Lines.Text = ""

			for Line = 1, LinesCount do
				local Text = Format:format(Line)
				local End = Line ~= LinesCount and '\n' or ''
				Lines.Text ..= `{Text}{End}`
			end

			--// Update console size to fit line numbers
			local LinesWidth = Lines.AbsoluteSize.X
			Source.Size = UDim2.new(1, -LinesWidth, 0, 0)

			return self
		end

		function Config:CheckLineCount()
			--// configuration
			local MaxLines = Config.MaxLines
			if not MaxLines then return end

			local Text = Source.Text
			local Lines = Text:split("\n")

			--// Cut the first line
			if #Lines > MaxLines then
				local Line = `{Lines[1]}\\n`
				local Cropped = Text:sub(#Line)
				self:SetValue(Cropped)
			end

			return self
		end

		function Config:UpdateScroll()
			local CanvasSize = Object.AbsoluteCanvasSize
			Object.CanvasPosition = Vector2.new(0, CanvasSize.Y)
			return self
		end

		function Config:SetValue(Text: string?)
			if not self.Enabled then return end

			Source.Text = tostring(Text)
			self:Update()

			return self
		end

		function Config:GetValue()
			return Source.Text
		end

		function Config:Clear()
			Source.Text = ""
			self:Update()
			return self
		end

		function Config:AppendText(...)
			local Lines = self:CountLines(true)
			local Concated = ReGui:Concat({...}, " ")

			--// Set the content if there are no lines
			if Lines == 0 then
				return self:SetValue(Concated)
			end

			local Value = self:GetValue()
			local NewString = `{Value}\n{Concated}`

			--// Write new content
			self:SetValue(NewString)

			return self
		end

		function Config:Update()
			--// Configuration
			local AutoScroll = self.AutoScroll

			self:CheckLineCount()
			self:UpdateLineNumbers()

			--// Automatically scroll to bottom
			if AutoScroll then
				self:UpdateScroll()
			end
		end

		local function Changed()
			local Value = Config:GetValue()
			Config:Update()
			Config:Callback(Value)
		end

		--// Update element
		Config:SetValue(Value)

		--// Set properties
		ReGui:SetProperties(Source, Config)
		ReGui:SetProperties(Source, {
			TextEditable = not ReadOnly,
			Parent = Object,
			PlaceholderText = Placeholder
		})

		self:TagElements({
			[Source] = "ConsoleText",
			[Lines] = "ConsoleLineNumbers",
		})

		--// Connect events
		Source:GetPropertyChangedSignal("Text"):Connect(Changed)

		return Class, Object
	end,
})

export type Table = {
	Align: string?,
	Border: boolean?,
	RowBackground: boolean?,
	RowBgTransparency: number?,
	MaxColumns: number?,
	NextRow: (Table) -> Row,
	HeaderRow: (Table) -> Row,

	Row: (Table) -> {
		Column: (Row) -> Elements
	},
	ClearRows: (Table) -> unknown,
}
ReGui:DefineElement("Table", {
	Base = {
		VerticalAlignment = Enum.VerticalAlignment.Top,
		RowBackground = false,
		RowBgTransparency = 0.87,
		Border = false,
		Spacing = UDim.new(0, 4)
	},
	Create = function(Canvas, Config: Table): Table
		local WindowClass = Canvas.WindowClass

		--// Unpack configuration
		local RowTransparency = Config.RowBgTransparency
		local RowBackground = Config.RowBackground
		local Border = Config.Border
		local VerticalAlignment = Config.VerticalAlignment
		local MaxColumns = Config.MaxColumns
		local Spacing = Config.Spacing

		--// Create table object
		local Object = ReGui:InsertPrefab("Table", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local RowTemplate = Object.RowTemp
		local RowsCount = 0
		local Rows = {}
		local HasStyling = Border and RowBackground

		function Config:Row(Config)
			Config = Config or {}

			local IsHeader = Config.IsHeader

			local ColumnIndex = 0
			local Columns = {}

			--// Create Row object (Different to :Row)
			local Row = RowTemplate:Clone()
			ReGui:SetProperties(Row, {
				Name = "Row",
				Visible = true,
				Parent = Object,
			})

			--// Set alignment
			local UIListLayout = Row:FindFirstChildOfClass("UIListLayout")
			ReGui:SetProperties(UIListLayout, {
				VerticalAlignment = VerticalAlignment,
				Padding = not HasStyling and Spacing or UDim.new(0, 1)
			})

			--// Apply header styles
			if IsHeader then
				Canvas:TagElements({
					[Row] = "Header"
				})
			else
				RowsCount += 1
			end

			--// RowBackground background colors for rows
			if RowBackground and not IsHeader then
				local Transparency = RowsCount % 2 ~= 1 and RowTransparency or 1
				Row.BackgroundTransparency = Transparency
			end

			--// Row class
			local RowClass = {}
			local Class = ReGui:MergeMetatables(RowClass, Row)

			function RowClass:Column(Config)
				Config = Config or {}

				ReGui:CheckConfig(Config, {
					HorizontalAlign = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				})

				--// Create column object
				local Column = Row.ColumnTemp:Clone()

				--// ListLayout Properties
				local ListLayout = Column:FindFirstChildOfClass("UIListLayout")
				ReGui:SetProperties(ListLayout, Config)

				--// Set border enabled based on Flag
				local Stroke = Column:FindFirstChildOfClass("UIStroke")
				Stroke.Enabled = Border

				--// Remove padding if there is no styling
				local UIPadding = Column:FindFirstChildOfClass("UIPadding")
				if not HasStyling then
					UIPadding:Destroy()
				end

				--// Column Properties
				ReGui:SetProperties(Column, {
					Parent = Row,
					Visible = true,
					Name = "Column"
				})

				--// Content canvas
				return ReGui:MakeCanvas({
					Element =  Column,
					WindowClass = WindowClass,
					Class = Class
				})
			end

			function RowClass:NextColumn()
				ColumnIndex += 1

				local Index = ColumnIndex % MaxColumns + 1
				local Column = Columns[Index]

				--// Create Column
				if not Column then
					Column = self:Column()	
					Columns[Index] = Column
				end

				return Column
			end

			table.insert(Rows, RowClass)

			--// Content canvas
			return Class
		end

		--// TODO: 
		function Config:NextRow()
			return self:Row()
		end

		function Config:HeaderRow()
			return self:Row({
				IsHeader = true
			})
		end

		function Config:ClearRows()
			RowsCount = 0

			--// Destroy each row
			for _, Row: Frame in next, Object:GetChildren() do
				if not Row:IsA("Frame") then continue end
				if Row == RowTemplate then continue end

				Row:Destroy()
			end

			return Config
		end

		return Class, Object
	end,
})

export type List = {
	Spacing: number?
}
ReGui:DefineElement("List", {
	Base = {
		Spacing = 4,
		HorizontalFlex = Enum.UIFlexAlignment.None,
		VerticalFlex = Enum.UIFlexAlignment.None,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		FillDirection = Enum.FillDirection.Horizontal,
	},
	Create = function(self, Config)
		local WindowClass = self.WindowClass

		--// Unpack configuration
		local Spacing = Config.Spacing
		local HorizontalFlex = Config.HorizontalFlex
		local VerticalFlex = Config.VerticalFlex
		local HorizontalAlignment = Config.HorizontalAlignment
		local VerticalAlignment = Config.VerticalAlignment
		local FillDirection = Config.FillDirection

		--// Create object
		local Object = ReGui:InsertPrefab("List", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local ListLayout: UIListLayout = Object.UIListLayout
		ReGui:SetProperties(ListLayout, {
			Padding = UDim.new(0, Spacing),
			HorizontalFlex = HorizontalFlex,
			VerticalFlex = VerticalFlex,
			HorizontalAlignment = HorizontalAlignment,
			VerticalAlignment = VerticalAlignment,
			FillDirection = FillDirection,
		})

		--// Content canvas
		local Canvas = ReGui:MakeCanvas({
			Element = Object,
			WindowClass = WindowClass,
			Class = Class
		})

		return Canvas, Object
	end,
})

export type CollapsingHeader = {
	Title: string,
	CollapseIcon: string?,
	Icon: string?,
	NoAnimation: boolean?,
	Collapsed: boolean?,
	Offset: number?,
	NoArrow: boolean?,
	OpenOnDoubleClick: boolean?, -- Need double-click to open node
	OpenOnArrow: boolean?, -- Only open when clicking on the arrow
	Activated: (CollapsingHeader) -> nil,
	TitleBarProperties: table?,
	IconPadding: UDim?,

	Remove: (CollapsingHeader) -> nil,
	SetArrowVisible: (CollapsingHeader, Visible: boolean) -> nil,
	SetTitle: (CollapsingHeader, Title: string) -> nil,
	SetIcon: (CollapsingHeader, Icon: string) -> nil,
	SetVisible: (CollapsingHeader, Visible: boolean) -> nil,
	SetCollapsed: (CollapsingHeader, Open: boolean) -> CollapsingHeader
}
ReGui:DefineElement("CollapsingHeader", {
	Base = {
		Title = "Collapsing Header",
		CollapseIcon = ReGui.Icons.Arrow,
		Collapsed = true,
		Offset = 0,
		NoAutoTag = true,
		NoAutoFlags = true,
		IconPadding = UDim.new(0, 4),
		Activated = EmptyFunction
	},
	Create = function(Canvas, Config: CollapsingHeader): CollapsingHeader
		--// Unpack config
		local Title = Config.Title
		local Collapsed = Config.Collapsed
		local Style = Config.ElementStyle
		local Offset = Config.Offset
		local TitleProperties = Config.TitleBarProperties
		local OpenOnDoubleClick = Config.OpenOnDoubleClick
		local OpenOnArrow = Config.OpenOnArrow
		local CollapseIcon = Config.CollapseIcon
		local IconPadding = Config.IconPadding
		local Icon = Config.Icon
		local NoArrow = Config.NoArrow

		--// Create header object
		local Object = ReGui:InsertPrefab("CollapsingHeader", Config)

		local Titlebar = Object.TitleBar
		local Collapse = Titlebar.Collapse
		local IconImage = Titlebar.Icon
		Canvas:ApplyFlags(IconImage, {
			Image = Icon
		})

		local CollapseButton = Collapse.CollapseIcon
		local CollapsePadding = Collapse.UIPadding
		Wrappers:SetPadding(CollapsePadding, IconPadding)
		Canvas:ApplyFlags(CollapseButton, {
			Image = CollapseIcon
		})

		local TitleText = Canvas:Label({
			ColorTag = "CollapsingHeader",
			Parent = Titlebar,
			LayoutOrder = 2
		})

		--// Content canvas
		local Canvas, ContentFrame = Canvas:Indent({
			Class = Config,
			Parent = Object,
			Offset = Offset,
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 1),
		})

		local function Activated()
			local Callback = Config.Activated
			Callback(Canvas)
		end

		function Config:Remove()
			Object:Destroy()
			table.clear(self)
		end
		function Config:SetArrowVisible(Visible: boolean)
			CollapseButton.Visible = Visible
		end
		function Config:SetTitle(Title: string)
			TitleText.Text = Title
		end
		function Config:SetVisible(Visible: boolean)
			Object.Visible = Visible
		end
		function Config:SetIcon(Icon: string|number)
			local Visible = Icon and Icon ~= ""
			IconImage.Visible = Visible

			if Visible then 
				IconImage.Image = Wrappers:CheckAssetUrl(Icon) 
			end
		end

		--// Open Animations
		function Config:SetCollapsed(Collapsed)
			self.Collapsed = Collapsed

			local ContentSize = ReGui:GetContentSize(ContentFrame)
			local Tweeninfo = Canvas:GetThemeKey("AnimationTweenInfo")

			--// Sizes
			local ClosedSize = UDim2.fromScale(1, 0)
			local OpenSize = ClosedSize + UDim2.fromOffset(0, ContentSize.Y)

			Animation:HeaderCollapse({
				Tweeninfo = Tweeninfo,
				Collapsed = Collapsed,
				Toggle = CollapseButton,
				Resize = ContentFrame,
				Hide = ContentFrame,

				--// Sizes
				ClosedSize = ClosedSize,
				OpenSize = OpenSize,
			})

			return self
		end

		local function Toggle()
			Config:SetCollapsed(not Config.Collapsed)
		end

		--// Apply flags
		if TitleProperties then
			Canvas:ApplyFlags(Titlebar, TitleProperties)
		end

		--// Connect events
		if not OpenOnArrow then
			ReGui:ConnectMouseEvent(Titlebar, {
				DoubleClick = OpenOnDoubleClick,
				Callback = Toggle,
			})
		end
		CollapseButton.Activated:Connect(Toggle)
		Titlebar.Activated:Connect(Activated)

		--// Update object state
		Config:SetCollapsed(Collapsed)
		Config:SetTitle(Title)
		Config:SetArrowVisible(not NoArrow)

		--// Style elements
		ReGui:ApplyStyle(Titlebar, Style)
		Canvas:TagElements({
			[Titlebar] = "CollapsingHeader",
		})

		return Canvas, Object
	end,
})

ReGui:DefineElement("TreeNode", {
	Base = {
		Offset = 21,
		IconPadding = UDim.new(0, 2),
		TitleBarProperties = {
			Size = UDim2.new(1, 0, 0, 13)
		}
	},
	Create = Elements.CollapsingHeader,
})

export type Separator = {
	Text: string?
}
ReGui:DefineElement("Separator", {
	Base = {
		NoAutoTag = true,
		NoAutoTheme = true
	},
	Create = function(self, Config)
		local Text = Config.Text

		--// Create septator object
		local Object = ReGui:InsertPrefab("SeparatorText", Config)

		self:Label({
			Text = tostring(Text),
			Visible = Text ~= nil,
			Parent = Object,
			LayoutOrder = 2,
			Size = UDim2.new(),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		})

		self:TagElements({
			[Object.Left] = "Separator",
			[Object.Right] = "Separator",
		})

		return Object
	end,
})

export type Canvas = {
	Scroll: boolean?,
	Class: table?
}
ReGui:DefineElement("Canvas", {
	Base = {},
	Create = function(self, Config: Canvas)
		local WindowClass = self.WindowClass

		local Scroll = Config.Scroll
		local Class = Config.Class or Config

		--// Create object
		local ObjectClass = Scroll and "ScrollingCanvas" or "Canvas"
		local Object = ReGui:InsertPrefab(ObjectClass, Config)

		--// Content canvas
		local Canvas = ReGui:MakeCanvas({
			Element = Object,
			WindowClass = WindowClass,
			Class = Class
		})

		return Canvas, Object
	end,
})

ReGui:DefineElement("ScrollingCanvas", {
	Base = {
		Scroll = true
	},
	Create = Elements.Canvas
})

export type Region = {
	Scroll: boolean?
}
ReGui:DefineElement("Region", {
	Base = {
		Scroll = false,
		AutomaticSize = Enum.AutomaticSize.Y
	},
	Create = function(self, Config: Region)
		local WindowClass = self.WindowClass

		local Scroll = Config.Scroll
		local Class = Scroll and "ScrollingCanvas" or "Canvas"

		--// Create object
		local Object = ReGui:InsertPrefab(Class, Config)

		--// Content canvas
		local Canvas = ReGui:MakeCanvas({
			Element = Object,
			WindowClass = WindowClass,
			Class = Config
		})

		return Canvas, Object
	end,
})

ReGui:DefineElement("Group", {
	Base = {
		Scroll = false,
		AutomaticSize = Enum.AutomaticSize.Y
	},
	Create = function(self, Config)
		local WindowClass = self.WindowClass

		--// Create object
		local Object = ReGui:InsertPrefab("Group", Config)

		--// Content canvas
		local Canvas = ReGui:MakeCanvas({
			Element = Object,
			WindowClass = WindowClass,
			Class = Config
		})

		return Canvas, Object
	end,
})

export type Indent = {
	Offset: number?,
	PaddingTop: UDim?,
	PaddingBottom: UDim?,
	PaddingRight: UDim?,
	PaddingLeft: UDim?,
}
ReGui:DefineElement("Indent", {
	Base = {
		Offset = 15,
		PaddingTop = UDim.new(),
		PaddingBottom = UDim.new(),
		PaddingRight = UDim.new(),
	},
	Create = function(self, Config: Indent)
		local Offset = Config.Offset
		Config.PaddingLeft = UDim.new(0, Offset)

		return self:Canvas(Config)
	end,
})

export type BulletText = {
	Padding: number,
	Icon: (string|number)?,
	Rows: {
		[number]: string?,
	}
} 
ReGui:DefineElement("BulletText", {
	Base = {},
	Create = function(self, Config: BulletText)
		local Rows = Config.Rows

		--// Create each row
		for _, Text in next, Rows do
			local Object = self:Bullet(Config)
			Object:Label({
				Text = tostring(Text),
				LayoutOrder = 2,
				Size = UDim2.fromOffset(0,14),
			})
		end
	end,
})

export type Bullet = {
	Padding: number?
}
ReGui:DefineElement("Bullet", {
	Base = {
		Padding = 3,
		Icon = ReGui.Icons.Dot,
		IconSize = UDim2.fromOffset(5,5)
	},
	Create = function(self, Config: Bullet)
		local WindowClass = self.WindowClass

		--// Unpack configuration
		local Padding = Config.Padding

		--// Create object
		local Object = ReGui:InsertPrefab("Bullet", Config)

		--// Content canvas
		local Canvas = ReGui:MakeCanvas({
			Element = Object,
			WindowClass = WindowClass,
			Class = self
		})

		--// Apply padding
		local ListLayout = Object.UIListLayout
		ListLayout.Padding = UDim.new(0, Padding)

		return Canvas, Object
	end,
})

export type Row = {
	Spacing: number?,
	Expanded: boolean?,
	HorizontalFlex: Enum.UIFlexAlignment?,
	VerticalFlex: Enum.UIFlexAlignment?,
	Expand: (Row) -> Row
}
ReGui:DefineElement("Row", {
	Base = {
		Spacing = 4,
		Expanded = false, 
		HorizontalFlex = Enum.UIFlexAlignment.None,
		VerticalFlex = Enum.UIFlexAlignment.None,
	},
	Create = function(self, Config: Row)
		local WindowClass = self.WindowClass

		--// Unpack configuration
		local Spacing = Config.Spacing
		local Expanded = Config.Expanded
		local HorizontalFlex = Config.HorizontalFlex
		local VerticalFlex = Config.VerticalFlex

		--// Create row object
		local Object = ReGui:InsertPrefab("Row", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local UIListLayout = Object:FindFirstChildOfClass("UIListLayout")
		UIListLayout.Padding = UDim.new(0, Spacing)
		UIListLayout.HorizontalFlex = HorizontalFlex
		UIListLayout.VerticalFlex = VerticalFlex

		--// Content canvas
		local Canvas = ReGui:MakeCanvas({
			Element = Object,
			WindowClass = WindowClass,
			Class = Class
		})

		function Config:Expand()
			UIListLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
			return self
		end

		--// Expand if Fill flag is enabled
		if Expanded then
			Config:Expand()
		end

		return Canvas, Object
	end,
})

--TODO
-- Vertical
export type SliderIntFlags = {
	Value: number?,
	Format: string?,
	Label: string?,
	Progress: boolean?,
	NoGrab: boolean?,
	Minimum: number,
	Maximum: number,
	NoAnimation: boolean?,
	Callback: (number) -> any?,
	ReadOnly: boolean?,
	SetValue: (SliderIntFlags, Value: number, IsSlider: boolean?) -> SliderIntFlags?,
	SetDisabled: (SliderIntFlags, Disabled: boolean) -> SliderIntFlags,
	MakeProgress: (SliderIntFlags) -> nil?,
}
ReGui:DefineElement("SliderBase", {
	Base = {
		Format = "%.f", -- "%.f/%s",
		Label = "",
		Type = "Slider",
		Callback = EmptyFunction,
		NoGrab = false,
		NoClick = false,
		Minimum = 0,
		Maximum = 100,
		ColorTag = "Frame",
		Disabled = false,
	},
	Create = function(Canvas, Config)
		--// Unpack config
		local Value = Config.Value or Config.Minimum
		local Format = Config.Format
		local LabelText = Config.Label
		local NoAnimation = Config.NoAnimation
		local NoGrab = Config.NoGrab
		local NoClick = Config.NoClick
		local Type = Config.Type
		local Disabled = Config.Disabled

		--// Create slider element
		local Object = ReGui:InsertPrefab("Slider")
		local Track = Object.Track
		local Grab = Track.Grab
		local ValueText = Track.ValueText

		local Class = ReGui:MergeMetatables(Config, Object)
		local GrabSize = Grab.AbsoluteSize

		--// Set object animations
		local HoverAnimation = ReGui:SetAnimation(Object, "Inputs")

		local Label = Canvas:Label({
			Parent = Object, 
			Text = LabelText,
			Position = UDim2.new(1, 4),
			Size = UDim2.fromScale(0, 1)
		})

		Merge(Config, {
			Grab = Grab,
			Name = LabelText,
		})

		--// Temporary solution
		if Type == "Slider" then
			Track.Position = UDim2.fromOffset(GrabSize.X/2, 0)
			Track.Size = UDim2.new(1, -GrabSize.X, 1, 0)
		end

		local Types = {
			["Slider"] = function(Percentage)
				return {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(Percentage, 0.5)
				}
			end,
			["Progress"] = function(Percentage)
				return {
					Size = UDim2.fromScale(Percentage, 1)
				}
			end,
			["Snap"] = function(Percentage, Value, Minimum, Maximum)
				local X = (math.round(Value) - Minimum) / Maximum
				return {
					Size = UDim2.fromScale(1 / Maximum, 1),
					Position = UDim2.fromScale(X, 0.5)
				}
			end,
		}

		local function Callback(...)
			local func = Config.Callback
			return func(Class, ...)
		end

		function Config:SetDisabled(Disabled: boolean)
			self.Disabled = Disabled
			Object.Interactable = not Disabled
			Canvas:SetColorTags({
				[Label] = Disabled and "LabelDisabled" or "Label"
			}, true)
			return self
		end

		function Config:SetValueText(Text: string)
			ValueText.Text = tostring(Text)
		end

		function Config:SetValue(Value, IsPercentage: boolean)
			local Tweeninfo = Canvas:GetThemeKey("AnimationTweenInfo")

			local Minimum = Config.Minimum
			local Maximum = Config.Maximum

			local Percentage = Value
			local Difference = Maximum - Minimum

			--// Convert Value into a Percentage
			if not IsPercentage then
				Percentage = (Value - Minimum) / Difference
			else
				--// Convert Percentage into Value
				Value = Minimum + (Difference * Percentage)
			end

			--// Clamp the percentage to ensure the grab stays within bounds
			Percentage = math.clamp(Percentage, 0, 1)

			--// Get properties for the Grab
			local Props = Types[Type](Percentage, Value, Minimum, Maximum) 

			--// Animate
			Animation:Tween({
				Object = Grab,
				Tweeninfo = Tweeninfo,
				NoAnimation = NoAnimation,
				EndProperties = Props
			})

			--// Update object state
			self.Value = Value
			self:SetValueText(Format:format(Value, Maximum))

			--// Fire callback
			Callback(Value)

			return self
		end

		local function SetFocused(Focused: boolean)
			--// Update object colors from a style
			Canvas:SetColorTags({
				[Object] = Focused and "FrameActive" or "Frame"
			}, true)
			Canvas:SetElementFocused(Object, {
				Focused = Focused,
				Animation = HoverAnimation
			})
		end

		------// Move events
		local function CanDrag()
			if Config.Disabled then return end
			if Config.ReadOnly then return end

			return true 
		end
		local function DragMovement(InputPosition)
			if not CanDrag() then return end

			--// Track Position and Size
			local TrackLeft = Track.AbsolutePosition.X
			local TrackWidth = Track.AbsoluteSize.X

			--// Get the mouse position relative to the track
			local MouseX = InputPosition.X
			local RelativeX = MouseX - TrackLeft

			--// Get the percentage based on the width of the track
			local Percentage = math.clamp(RelativeX / TrackWidth, 0, 1)

			Config:SetValue(Percentage, true)
		end
		local function DragBegan(...)
			if not CanDrag() then return end

			SetFocused(true)

			if not NoClick then
				DragMovement(...)
			end
		end
		local function DragEnded()
			SetFocused(false)
		end

		--// Update object state
		Grab.Visible = not NoGrab
		Config:SetValue(Value) -- Ensure the grab is positioned correctly on initialization
		Config:SetDisabled(Disabled)

		Canvas:TagElements({
			[ValueText] = "Label",
			[Grab] = "SliderGrab"
		})

		--// Connect movement events
		ReGui:ConnectDrag(Track, {
			DragStart = DragBegan,
			DragMovement = DragMovement,
			DragEnd = DragEnded,
		})

		return Class, Object
	end,
})

export type SliderEnumFlags = {
	Items: {
		[number]: any
	},
	Label: string,
	Value: number,
} & SliderIntFlags
ReGui:DefineElement("SliderEnum", {
	Base = {
		Items = {},
		Label = "Slider Enum",
		Type = "Snap",
		Minimum = 1,
		Maximum = 10,
		Value = 1,
		Callback = EmptyFunction,
		ColorTag = "Frame"
	},
	Create = function(self, Config: SliderEnumFlags)
		--// Unpack configuration
		local Callback = Config.Callback
		local Value = Config.Value

		local function Calculate(self, Value: number)
			Value = math.round(Value)

			--// Dynamic size
			local Items = self.Items
			self.Maximum = #Items

			--// Get value from array
			return Items[Value]
		end

		--// Custom callback for the Enum type
		Config.Callback = function(self, Index)
			local Value = Calculate(self, Index)
			self:SetValueText(Value)

			Config.Value = Value

			return Callback(self, Value)
		end

		Calculate(Config, Value)

		--// Create object 
		return self:SliderBase(Config)
	end,
})

ReGui:DefineElement("SliderInt", {
	Base = {
		Label = "Slider Int",
		ColorTag = "Frame",
	},
	Create = Elements.SliderBase,
})

ReGui:DefineElement("SliderFloat", {
	Base = {
		Label = "Slider Float",
		Format = "%.3f", --"%.3f/%s",
		ColorTag = "Frame",
	},
	Create = Elements.SliderBase,
})

export type DragIntFlags = {
	Format: string?,
	Label: string?,
	Callback: (DragIntFlags, number) -> any,
	Minimum: number?,
	Maximum: number?,
	Value: number?,
	ReadOnly: boolean?,
	Disabled: boolean?,

	SetDisabled: (DragIntFlags, Disabled: boolean) -> DragIntFlags,
	SetValue: (DragIntFlags, Value: number, IsPercentage: boolean?) -> DragIntFlags,
}
ReGui:DefineElement("DragInt", {
	Base = {
		Format = "%.f",
		Label = "Drag Int",
		Callback = EmptyFunction,
		Minimum = 0,
		Maximum = 100,
		ColorTag = "Frame",
		Disabled = false
	},
	Create = function(Canvas, Config: DragIntFlags)
		--// Unpack config
		local Value = Config.Value or Config.Minimum
		local Format = Config.Format
		local LabelText = Config.Label
		local Disabled = Config.Disabled

		--// Create slider element
		local Object = ReGui:InsertPrefab("Slider")
		local Class = ReGui:MergeMetatables(Config, Object)

		local Track = Object.Track
		local ValueText = Track.ValueText
		local Grab = Track.Grab
		Grab.Visible = false

		local Label = Canvas:Label({
			Parent = Object, 
			Text = LabelText,
			Position = UDim2.new(1, 7),
			Size = UDim2.fromScale(0, 1)
		})

		local InputBeganPosition = nil
		local Percentage = 0
		local BeganPercentage = 0

		--// Set object animations
		local HoverAnimation = ReGui:SetAnimation(Object, "Inputs")

		local function Callback(...)
			local Func = Config.Callback
			return Func(Class, ...)
		end

		function Config:SetValue(Value, IsPercentage)
			local Minimum = self.Minimum
			local Maximum = self.Maximum

			local Difference = Maximum - Minimum

			--// Convert Value into a Percentage
			if not IsPercentage then
				Percentage = ((Value - Minimum) / Difference) * 100
			else
				--// Convert Percentage into Value
				Value = Minimum + (Difference * (Percentage / 100))
			end

			Value = math.clamp(Value, Minimum, Maximum)

			--// Update object state
			self.Value = Value
			ValueText.Text = Format:format(Value, Maximum) 

			--// Fire callback
			Callback(Value)

			return self
		end
		function Config:SetDisabled(Disabled)
			self.Disabled = Disabled
			Canvas:SetColorTags({
				[Label] = Disabled and "LabelDisabled" or "Label"
			}, true)
			return self
		end

		local function SetFocused(Focused)
			--// Update object colors from a style
			Canvas:SetColorTags({
				[Object] = Focused and "FrameActive" or "Frame"
			}, true)

			Canvas:SetElementFocused(Object, {
				Focused = Focused,
				Animation = HoverAnimation
			})
		end

		------// Move events
		local function CanDrag(): boolean?
			if Config.Disabled then return end
			if Config.ReadOnly then return end

			return true
		end
		local function DragStart(InputPosition)
			if not CanDrag() then return end
			SetFocused(true)

			InputBeganPosition = InputPosition
			BeganPercentage = Percentage
		end
		local function DragMovement(InputPosition)
			if not CanDrag() then return end

			local Delta = InputPosition.X - InputBeganPosition.X
			local New = BeganPercentage + (Delta/2)

			Percentage = math.clamp(New, 0, 100)
			Config:SetValue(Percentage, true)
		end
		local function DragEnded()
			SetFocused(false)
		end

		--// Update object state
		Config:SetValue(Value)
		Config:SetDisabled(Disabled)

		--// Connect movement events
		ReGui:ConnectDrag(Track, {
			DragStart = DragStart,
			DragEnd = DragEnded,
			DragMovement = DragMovement,
		})

		Canvas:TagElements({
			[ValueText] = "Label"
		})

		return Class, Object
	end,
})

ReGui:DefineElement("DragFloat", {
	Base = {
		Format = "%.3f", --"%.3f/%s",
		Label = "Drag Float",
		ColorTag = "Frame"
	},
	Create = Elements.DragInt,
})

ReGui:DefineElement("MultiElement", {
	Base = {
		Callback = EmptyFunction,
		Label = "",
		Disabled = false,
		BaseInputConfig = {},
		InputConfigs = {},
		Value = {},
		Minimum = {},
		Maximum = {},
		MultiCallback = EmptyFunction,
	},
	Create = function(Canvas, Config)
		--// Unpack configuration
		local LabelText = Config.Label
		local BaseInputConfig = Config.BaseInputConfig
		local InputConfigs = Config.InputConfigs
		local InputType = Config.InputType
		local Disabled = Config.Disabled
		local Value = Config.Value
		local Minimum = Config.Minimum
		local Maximum = Config.Maximum

		assert(InputType, "No input type provided for MultiElement")
		--assert(#Minimum ~= #InputConfigs, `Minimum does not match input count ({Minimum} != {#InputConfigs})`)
		--assert(#Maximum ~= #InputConfigs, `Maximum does not match input count ({Maximum} != {#InputConfigs})`)

		--// Create container row
		local ContainerRow, Object = Canvas:Row({
			Spacing = 4
		})

		local Row = ContainerRow:Row({
			Size = UDim2.fromScale(0.65, 0),
			Expanded = true,
		})

		local Label = ContainerRow:Label({
			Size = UDim2.fromScale(0.35, 0),
			LayoutOrder = 2,
			Text = LabelText
		})

		local Class = ReGui:MergeMetatables(Config, ContainerRow)
		local Inputs = {}
		local _CallbackEnabled = false

		local function GetValue()
			local Value = {}
			for Index, Input in Inputs do
				Value[Index] = Input:GetValue()
			end

			Config.Value = Value
			return Value
		end

		local function Callback(...)
			local Callback = Config.MultiCallback
			Callback(Class, ...)
		end

		local function InputChanged()
			--// Check if all the elements have loaded
			if #Inputs ~= #InputConfigs then return end
			if not _CallbackEnabled then return end

			local Values = GetValue()
			Callback(Values)
		end

		function Config:SetDisabled(Disabled: boolean)
			self.Disabled = Disabled

			--// Chaneg the tag of the Label
			Canvas:SetColorTags({
				[Label] = Disabled and "LabelDisabled" or "Label"
			}, true)

			--// Set state of each Drag element
			for _, Input in Inputs do
				Input:SetDisabled(Disabled)
			end
		end

		function Config:SetValue(Values)
			_CallbackEnabled = false

			--// Invoke :SetValue on each input object
			for Index, Value in Values do
				local Input = Inputs[Index]
				assert(Input, `No input object for index: {Index}`)

				Input:SetValue(Value)
			end

			_CallbackEnabled = true
			Callback(Values)
		end

		--// BaseInputConfig
		BaseInputConfig = Copy(BaseInputConfig, {
			Size = UDim2.new(1, 0, 0, 19),
			Label = "",
			Callback = InputChanged,
		})

		--// Create DragInt elements
		for Index, Overwrites in InputConfigs do
			local Flags = Copy(BaseInputConfig, Overwrites)
			ReGui:CheckConfig(Flags, {
				Minimum = Minimum[Index],
				Maximum = Maximum[Index],
			})

			--// Create input object
			local Input = Row[InputType](Row, Flags)
			table.insert(Inputs, Input)
		end

		--// Merge properties into the configuration
		Merge(Config, {
			Row = Row,
			Inputs = Inputs
		})

		_CallbackEnabled = true

		--// Update object states
		Config:SetDisabled(Disabled)
		Config:SetValue(Value)

		return Class, Object
	end,
})

local function GenerateMultiInput(Name: string, Class: string, InputCount: number, Extra)
	ReGui:DefineElement(Name, {
		Base = {
			Label = Name,
			Callback = EmptyFunction,
			InputType = Class,
			InputConfigs = table.create(InputCount, {}),
			BaseInputConfig = {},
		},
		Create = function(self, Config)
			local BaseInputConfig = Config.BaseInputConfig
			local Object = nil

			if Extra then
				Merge(BaseInputConfig, Extra)
			end

			ReGui:CheckConfig(BaseInputConfig, {
				ReadOnly = Config.ReadOnly,
				Format = Config.Format,
			})

			Config.MultiCallback = function(...)
				local Callback = Config.Callback
				Callback(...)
			end

			return self:MultiElement(Config)
		end,
	})
end

export type InputColor3Flags = {
	Label: string?,
	Value: Color3?,
	Callback: (InputColor3Flags, Value: Color3) -> any,
	InputConfigs: table,

	ValueChanged: (InputColor3Flags) -> nil,
	SetValue: (InputColor3Flags, Value: Color3) -> InputColor3Flags,
}
local function GenerateColor3Input(Name: string, InputType: string)
	ReGui:DefineElement(Name, {
		Base = {
			Label = Name,
			Callback = EmptyFunction,
			Value = ReGui.Accent.Light,
			Disabled = false,
			Minimum = {0,0,0},
			Maximum = {255,255,255,100},
			BaseInputConfig = {},
			InputConfigs = {
				[1] = {Format = "R: %.f"},
				[2] = {Format = "G: %.f"},
				[3] = {Format = "B: %.f"},
			}
		},
		Create = function(self, Config: InputColor3Flags)
			--// Unpack configuration
			local Value = Config.Value
			--local InputConfigs = Config.InputConfigs

			--// Add alpha slider
			-- if Extra.Color4 then
			-- 	InputConfigs[4] = {Format = "A: %.f"}
			-- end

			--// Create Object
			local InputConfig = Copy(Config, {
				Value = {1,1,1},
				Callback = function(self, ...)
					if Config.ValueChanged then
						Config:ValueChanged(...)
					end
				end,
			})

			local Element, Object = self[InputType](self, InputConfig)
			local Class = ReGui:MergeMetatables(Config, Element)
			local Row = Element.Row

			--// Preview frame
			local Preview = Row:Button({
				BackgroundTransparency = 0,
				Size = UDim2.fromOffset(19, 19),
				UiPadding = 0,
				Text = "",
				Ratio = 1,
				ColorTag = "",
				ElementStyle = ""
			})

			local function Callback(...)
				local func = Config.Callback
				return func(Class, ...)
			end

			local function SetPreview(Color: Color3)
				Preview.BackgroundColor3 = Color
				Callback(Color)
			end

			function Config:ValueChanged(Value)
				local R, G, B = Value[1], Value[2], Value[3]
				local Color = Color3.fromRGB(R, G, B)

				self.Value = Color
				SetPreview(Color)
			end

			function Config:SetValue(Color: Color3)
				self.Value = Color
				SetPreview(Color)

				--// Update Drag elements
				Element:SetValue({
					math.round(Color.R*255),
					math.round(Color.G*255),
					math.round(Color.B*255)
				})
			end

			--// Update object state
			Config:SetValue(Value)

			return Class, Object
		end,
	})
end

export type InputCFrameFlags = {
	Label: string?,
	Value: CFrame?,
	Maximum: CFrame,
	Minimum: CFrame,
	Callback: (InputCFrameFlags, Value: CFrame) -> any,

	ValueChanged: (InputCFrameFlags) -> nil,
	SetValue: (InputCFrameFlags, Value: CFrame) -> InputCFrameFlags,
}
local function GenerateCFrameInput(Name: string, InputType: string)
	ReGui:DefineElement(Name, {
		Base = {
			Label = Name,
			Callback = EmptyFunction,
			Disabled = false,
			Value = CFrame.new(10,10,10),
			Minimum = CFrame.new(0,0,0),
			Maximum = CFrame.new(100,100,100),
			BaseInputConfig = {},
			InputConfigs = {
				[1] = {Format = "X: %.f"},
				[2] = {Format = "Y: %.f"},
				[3] = {Format = "Z: %.f"}
			}
		},
		Create = function(self, Config: InputCFrameFlags)
			--// Unpack configuration
			local Value = Config.Value
			local Maximum = Config.Maximum
			local Minimum = Config.Minimum

			local InputConfig = Copy(Config, {
				Maximum = {Maximum.X, Maximum.Y, Maximum.Z},
				Minimum = {Minimum.X, Minimum.Y, Minimum.Z},
				Value = {Value.X, Value.Y, Value.Z},
				Callback = function(self, ...)
					if Config.ValueChanged then
						Config:ValueChanged(...)
					end
				end,
			})

			--// Create Object
			local Element, Object = self[InputType](self, InputConfig)
			local Class = ReGui:MergeMetatables(Config, Element)

			local function Callback(...)
				local func = Config.Callback
				return func(Class, ...)
			end

			function Config:ValueChanged(Values)
				local X, Y, Z = Values[1], Values[2], Values[3]
				local Value = CFrame.new(X, Y, Z)
				self.Value = Value
				Callback(Value)
			end

			function Config:SetValue(Value: CFrame)
				self.Value = Value

				--// Update Drag elements
				Element:SetValue({
					math.round(Value.X),
					math.round(Value.Y),
					math.round(Value.Z)
				})
			end

			--// Update object state
			Config:SetValue(Value)

			return Class, Object
		end,
	})
end

ReGui:DefineElement("SliderProgress", {
	Base = {
		Label = "Slider Progress",
		Type = "Progress",
		ColorTag = "Frame",
	},
	Create = Elements.SliderBase,
})

export type ProgressBar = {
	SetPercentage: (ProgressBar, Value: number) -> nil
}
ReGui:DefineElement("ProgressBar", {
	Base = {
		Label = "Progress Bar",
		Type = "Progress",
		ReadOnly = true,
		MinValue = 0,
		MaxValue = 100,
		Format = "% i%%",
		Interactable = false,
		ColorTag = "Frame"
	},
	Create = function(self, Config)
		function Config:SetPercentage(Value: number)
			Config:SetValue(Value)
		end

		local Slider, Object = self:SliderBase(Config)
		local Grab = Slider.Grab

		self:TagElements({
			[Grab] = {
				BackgroundColor3 = "ProgressBar"
			}
		})

		return Slider, Object
	end,
})

export type Combo = {
	Label: string?,
	Placeholder: string?,
	Callback: (Combo, Value: any) -> any,
	Items: {[number?]: any}?,
	GetItems: (() -> table)?,
	NoAnimation: boolean?,
	Selected: any,
	WidthFitPreview: boolean?,
	Disabled: boolean?,
	Open: boolean?,
	ClosePopup: (Combo) -> nil,
	SetValueText: (Combo, Value: string) -> nil,
	SetDisabled: (Combo, Disabled: boolean) -> Combo,
	SetValue: (Combo, Value: any) -> Combo,
	SetOpen: (Combo, Open: boolean) -> Combo
}
ReGui:DefineElement("Combo", {
	Base = {
		Value = "",
		Placeholder = "",
		Callback = EmptyFunction,
		Items = {},
		Disabled = false,
		WidthFitPreview = false,
		Label = "Combo"
	},
	Create = function(Canvas, Config: Combo)
		--// Unpack configuration
		local Placeholder = Config.Placeholder
		local NoAnimation = Config.NoAnimation
		local Selected = Config.Selected
		local LabelText = Config.Label
		local Disabled = Config.Disabled
		local WidthFitPreview = Config.WidthFitPreview
		--local NoPreview = Config.NoPreview

		--// Create combo element
		local Object = ReGui:InsertPrefab("Combo", Config)
		local Class = ReGui:MergeMetatables(Config, Object)

		local Combo = Object.Combo
		local Dropdown = nil

		--// Elements
		local ValueText = Canvas:Label({
			Text = tostring(Placeholder),
			Parent = Combo,
			--Visible = not NoPreview,
			Name = "ValueText"
		})
		local ArrowButton = Canvas:ArrowButton({
			Parent = Combo,
			Interactable = false,
			Size = UDim2.fromOffset(19, 19),
			LayoutOrder = 2,
		})
		local Label = Canvas:Label({
			Text = LabelText,
			Parent = Object,
			LayoutOrder = 2,
		})

		--// Enable automatic sizes
		if WidthFitPreview then
			ReGui:SetProperties(Object, {
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.new(0, 0, 0, 0)
			})
			ReGui:SetProperties(Combo, {
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.fromScale(0, 1)
			})
		end

		local function Callback(Value, ...)
			Config:SetOpen(false)
			return Config.Callback(Class, Value, ...)
		end

		local function SetAnimationState(Open: boolean, NoAnimation: boolean?)
			local Tweeninfo = Canvas:GetThemeKey("AnimationTweenInfo")

			Object.Interactable = not Open

			--// Animate Arrow button
			Animation:HeaderCollapseToggle({
				Tweeninfo = Tweeninfo,
				NoAnimation = NoAnimation,
				Collapsed = not Open,
				Toggle = ArrowButton.Icon,
			})
		end

		local function GetItems()
			local GetItems = Config.GetItems
			local Items = Config.Items

			--// Invoke the GetItems function
			if GetItems then
				return GetItems()
			end

			--// Return Dict/Array
			return Items
		end

		function Config:SetValueText(Value: string?)
			ValueText.Text = tostring(Value)
		end

		function Config:ClosePopup()
			if not Dropdown then return end
			Dropdown:ClosePopup(true)
		end

		function Config:SetDisabled(Disabled: boolean)
			self.Disabled = Disabled
			Object.Interactable = not Disabled
			Canvas:SetColorTags({
				[Label] = Disabled and "LabelDisabled" or "Label"
			}, true)
			return self
		end

		function Config:SetValue(Selected)
			local Items = GetItems()
			local DictValue = Items[Selected]
			local Value = DictValue or Selected

			self.Selected = Selected
			self.Value = Value

			self:ClosePopup()

			--// Update Value text with selected item
			if typeof(Selected) == "number" then
				self:SetValueText(Value)
			else
				self:SetValueText(Selected)
			end

			Callback(Selected, Value)
			return self
		end

		function Config:SetOpen(Open: boolean)
			local Selected = self.Selected

			self.Open = Open
			SetAnimationState(Open, NoAnimation)

			if not Open	then 
				--// Close open dropdown
				self:ClosePopup()
				return 
			end

			--// Create dropdown
			Dropdown = Canvas:Dropdown({
				RelativeTo = Combo,
				Items = GetItems(),
				Selected = Selected,
				OnSelected = function(...)
					Config:SetValue(...)
				end,
				OnClosed = function()
					self:SetOpen(false)
				end,
			})

			return self
		end

		local function ToggleOpen()
			local IsOpen = Config.Open
			Config:SetOpen(not IsOpen)
		end

		--// Connect events
		Combo.Activated:Connect(ToggleOpen)

		--// Update object state
		SetAnimationState(false, true)
		Config:SetDisabled(Disabled)

		if Selected then
			Config:SetValue(Selected)
		end

		--// Set object animations
		ReGui:SetAnimation(Combo, "Inputs")

		Canvas:TagElements({
			[Combo] = "Frame",
		})

		return Class, Object 
	end,
})

--ReGui:DefineElement("ComboFilter", {
--	Base = {
--		Value = "",
--		Placeholder = "",
--		Callback = EmptyFunction,
--		Items = {},
--		Disabled = false,
--		Label = "Combo Filter"
--	},
--	Create = function(Canvas, Config: Combo)
--		--// Unpack configuration
--		local Placeholder = Config.Placeholder
--		local NoAnimation = Config.NoAnimation
--		local Selected = Config.Selected
--		local LabelText = Config.Label
--		local Disabled = Config.Disabled

--		local InputConfig = Copy(Config, {
--			Callback = function(self, ...)
--				print("InputText", ...)

--				if Config.ResolveQuery then
--					print("ResolveQuery", ...)
--					Config:ResolveQuery(...)
--				end
--			end,
--		})

--		--// Create inputText element
--		local Object = Canvas:InputText(InputConfig)
--		local Class = ReGui:MergeMetatables(Config, Object)
--		local Dropdown = nil

--		local function Callback(Value, ...)
--			local Func = Config.Callback
--			Config:SetOpen(false)

--			return Func(Class, Value, ...)
--		end

--		local function GetItems()
--			local GetItems = Config.GetItems
--			local Items = Config.Items

--			--// Invoke the GetItems function
--			if GetItems then
--				return GetItems()
--			end

--			--// Return Dict/Array
--			return Items
--		end

--		function Config:SetDropdownVisible(Visible: boolean)
--			if self.Open == Visible then return end
--			self.Open = Visible

--			--// Close open dropdown
--			if not Visible	then 
--				if Dropdown then
--					Dropdown:Close()
--				end
--				return 
--			end

--			--// Create dropdown
--			Dropdown = Canvas:Dropdown({
--				ParentObject = Object,
--				Selected = Selected,
--				OnSelected = function(...)
--					Config:SetValue(...)
--				end,
--				OnClosed = function()
--					self:SetOpen(false)
--				end,
--			})
--		end

--		function Config:ResolveQuery(Query: string)
--			local Items = GetItems()
--			local Sorted = SortByQuery(Items, Query)

--			--// Create dropdown
--			self:SetDropdownVisible(true)

--			--// Set dropdown items
--			Dropdown:SetItems(Sorted, 1)
--		end

--		function Config:SetValue(Selected)
--			--local Items = GetItems()

--			--local DictValue = Items[Selected]
--			--local Value = DictValue or Selected

--			--self.Selected = Selected
--			--self.Value = Value

--			----// Update Value text with selected item
--			--if typeof(Selected) == "number" then
--			--	self:SetValueText(Value)
--			--else
--			--	self:SetValueText(Selected)
--			--end

--			--return Callback(Selected, Value)
--		end

--		return Class, Object 
--	end,
--})

local WindowClass = {
	--// Icons
	TileBarConfig = {
		Close = {
			Image = ReGui.Icons.Close,
			IconPadding = UDim.new(0, 3)
		},
		Collapse = {
			Image = ReGui.Icons.Arrow,
			IconPadding = UDim.new(0, 3)
		},
	},

	CloseCallback = EmptyFunction, --// Placeholder

	--// States
	Collapsible = true,
	Open = true,
	Focused = false
}

function WindowClass:Tween(Data)
	ReGui:CheckConfig(Data, {
		Tweeninfo = self:GetThemeKey("AnimationTweenInfo")
	})
	return Animation:Tween(Data)
end

function WindowClass:TagElements(Objects: table)
	--// Unpack WindowClass
	local Elements = self.TagsList
	local Theme = self.Theme

	ReGui:MultiUpdateColors({
		Theme = Theme,
		TagsList = Elements,
		Objects = Objects
	})
end

export type TitleBarCanvas = {
	Right: table,
	Left: table,
}
function WindowClass:MakeTitleBarCanvas(): TitleBarCanvas
	local TitleBar = self.TitleBar

	--// Create canvas for each side
	local Canvas = ReGui:MakeCanvas({
		WindowClass = self,
		Element = TitleBar
	})
	self.TitleBarCanvas = Canvas

	return Canvas
end

function WindowClass:AddDefaultTitleButtons()
	local Config = self.TileBarConfig
	local Toggle = Config.Collapse
	local Close = Config.Close

	--// Check for Titlebar canvas
	local Canvas = self.TitleBarCanvas
	if not Canvas then
		Canvas = self:MakeTitleBarCanvas()
	end

	ReGui:CheckConfig(self, {
		--// Create window interaction buttons
		Toggle = Canvas:RadioButton({
			Icon = Toggle.Image,
			IconPadding = Toggle.IconPadding,
			LayoutOrder = 1,
			Ratio = 1,
			Size = UDim2.new(0, 0),
			Callback = function()
				self:ToggleCollapsed()
			end,
		}),
		CloseButton = Canvas:RadioButton({
			Icon = Close.Image,
			IconPadding = Close.IconPadding,
			LayoutOrder = 3,
			Ratio = 1,
			Size = UDim2.new(0, 0),
			Callback = function()
				self:SetVisible(false)
			end,
		}),
		TitleLabel = Canvas:Label({
			ColorTag = "Title",
			LayoutOrder = 2,
			Size = UDim2.new(1, 0),
			Active = false,
			Fill = true,
			ClipsDescendants = true,
			AutomaticSize = Enum.AutomaticSize.XY
		})
	})

	--// Registor Elements into Window class
	self:TagElements({
		[self.TitleLabel] = "WindowTitle"
	})
end

function WindowClass:Close()
	local Callback = self.CloseCallback

	--// Test for interupt
	if Callback then
		local ShouldClose = Callback(self)
		if ShouldClose == false then return end
	end

	self:Remove()
	self.IsClosed = true
end

function WindowClass:SetVisible(Visible: boolean): WindowFlags
	local Window = self.WindowFrame
	local NoFocusOnAppearing = self.NoFocusOnAppearing

	self.Visible = Visible
	Window.Visible = Visible

	--// Update window focus
	if Visible and not NoFocusOnAppearing then
		ReGui:SetFocusedWindow(self)
	end

	return self
end

function WindowClass:ToggleVisibility(Visible: boolean)
	local IsVisible = self.Visible
	self:SetVisible(not IsVisible)
end

function WindowClass:GetWindowSize(): Vector2
	return self.WindowFrame.AbsoluteSize
end

function WindowClass:GetTitleBarSizeY(): number
	local TitleBar = self.TitleBar
	return TitleBar.Visible and TitleBar.AbsoluteSize.Y or 0
end

function WindowClass:SetTitle(Text: string?): WindowFlags
	self.TitleLabel.Text = tostring(Text)
	return self
end

function WindowClass:SetPosition(Position): WindowFlags
	self.WindowFrame.Position = Position
	return self
end

function WindowClass:SetSize(Size: (Vector2|UDim2), NoAnimation: boolean): WindowFlags
	local Window = self.WindowFrame

	--// Convert Vector2 to UDim2
	if typeof(Size) == "Vector2" then
		Size = UDim2.fromOffset(Size.X, Size.Y)
	end

	Window.Size = Size
	self.Size = Size

	return self
end

function WindowClass:SetCanvasInteractable(Interactable: boolean)
	local Body = self.Body 
	Body.Interactable = Interactable
end

function WindowClass:Center(): WindowFlags --// Without an Anchor point
	local Size = self:GetWindowSize() / 2
	local Position = UDim2.new(0.5, -Size.X, 0.5, -Size.Y)

	self:SetPosition(Position)
	return self
end

function WindowClass:LoadStylesIntoElement(Data)
	local Flags = Data.Flags
	local Object = Data.Object
	local Canvas = Data.Canvas

	local TagFunctions = {
		["FrameRounding"] = function()
			if Flags.CornerRadius then return end
			if not Canvas then return end

			local UICorner = Object:FindFirstChild("FrameRounding", true)
			if not UICorner then return end

			Canvas:TagElements({
				[UICorner] = "FrameRounding"
			})
		end,
	}

	for Tag, Func in TagFunctions do
		local Value = self:GetThemeKey(Tag)
		if Value == nil then continue end

		task.spawn(Func, Value)
	end
end

function WindowClass:SetTheme(ThemeName: string): WindowFlags
	local Themes = ReGui.ThemeConfigs
	local Elements = self.TagsList
	local WindowState = self.WindowState

	--// Use the current theme if no theme is defined
	ThemeName = ThemeName or self.Theme

	--// Check if the theme actually exists
	assert(Themes[ThemeName], `{ThemeName} is not a valid theme!`)
	
	self.Theme = ThemeName

	--// Update elements with new colors
	ReGui:MultiUpdateColors({
		Animate = false,
		Theme = ThemeName,
		Objects = Elements
	})

	--// Refresh Focus styles
	self:SetFocusedColors(WindowState)
	return self
end

function WindowClass:SetFocusedColors(State: string)
	--// Unpack class values
	local WindowFrame = self.WindowFrame
	local TitleBar = self.TitleBar
	local Theme = self.Theme
	local TitleLabel = self.TitleLabel
	local Tweeninfo = self:GetThemeKey("AnimationTweenInfo")

	local Border = WindowFrame:FindFirstChildOfClass("UIStroke")

	--// Color tags
	local Tags = {
		Focused = {
			[TitleBar] = "TitleBarBgActive",
			[TitleLabel] = {
				TextColor3 = "TitleActive"
			}
		},
		UnFocused = {
			[TitleBar] = "TitleBarBg",
			[TitleLabel] = {
				TextColor3 = "Title"
			}
		},
		Collapsed = {
			[TitleBar] = "TitleBarBgCollapsed",
			[TitleLabel] = {
				TextColor3 = "Title"
			}
		}
	}

	--// Apply border colors if it exists
	if Border then
		Tags.Focused[Border] = "BorderActive"
		Tags.UnFocused[Border] = "Border"
		Tags.Collapsed[Border] = "Border"
	end

	--// Update colors
	ReGui:MultiUpdateColors({
		Tweeninfo = Tweeninfo,
		Animate = true,
		Objects = Tags[State],
		Theme = Theme,
	})
end

function WindowClass:SetFocused(Focused: boolean?)
	Focused = Focused == nil and true or Focused

	--// Unpack class values
	local Collapsed = self.Collapsed
	local CurrentState = self.WindowState

	--// Update Window focus
	if Focused then
		ReGui:SetFocusedWindow(self)
	end

	--// Theme tags for Window state
	local NewState = Collapsed and "Collapsed" or Focused and "Focused" or "UnFocused"

	--// Check if the window state is identical
	if NewState == CurrentState then return end
	self.Focused = Focused
	self.WindowState = NewState

	--// Update colors
	self:SetFocusedColors(NewState)
end

function WindowClass:GetThemeKey(Key: string)
	return ReGui:GetThemeKey(self.Theme, Key)
end

function WindowClass:SetCollapsible(Collapsible: boolean): WindowFlags
	self.Collapsible = Collapsible
	return self
end

function WindowClass:ToggleCollapsed(NoCheck: boolean?): WindowFlags
	local Collapsed = self.Collapsed
	local Collapsible = self.Collapsible

	--// Check if the window can be opened
	if not NoCheck and not Collapsible then return self end

	self:SetCollapsed(not Collapsed)
	return self
end

function WindowClass:SetCollapsed(Collapsed: boolean, NoAnimation: false): WindowFlags
	local Window = self.WindowFrame
	local Body = self.Body
	local Toggle = self.Toggle
	local ResizeGrab = self.ResizeGrab
	local OpenSize = self.Size
	local AutoSize = self.AutoSize
	local Tweeninfo = self:GetThemeKey("AnimationTweenInfo")

	local WindowSize = self:GetWindowSize()
	local TitleBarSizeY = self:GetTitleBarSizeY()

	local ToggleIcon = Toggle.Icon
	local ClosedSize = UDim2.fromOffset(WindowSize.X, TitleBarSizeY)

	self.Collapsed = Collapsed
	self:SetCollapsible(false)

	--// Change the window focus
	self:SetFocused(not Collapsed)

	--// Animate the closing
	Animation:HeaderCollapse({
		Tweeninfo = Tweeninfo,
		NoAnimation = NoAnimation,
		Collapsed = Collapsed,
		Toggle = ToggleIcon,
		Resize = Window,
		NoAutomaticSize = not AutoSize,
		Hide = Body,
		--// Sizes
		ClosedSize = ClosedSize,
		OpenSize = OpenSize,
		Completed = function()
			self:SetCollapsible(true)
		end
	})

	--// ResizeGrab
	self:Tween({
		Object = ResizeGrab,
		NoAnimation = NoAnimation,
		EndProperties = {
			TextTransparency = Collapsed and 1 or 0.6,
			Interactable = not Collapsed
		}
	})

	return self
end

function WindowClass:UpdateConfig(Config)
	local Flags = {
		NoTitleBar = function(Value)
			local Object = self.TitleBar
			Object.Visible = not Value
		end,
		NoClose = function(Value)
			local Object = self.CloseButton
			Object.Visible = not Value
		end,
		NoCollapse = function(Value)
			local Object = self.Toggle
			Object.Visible = not Value
		end,
		NoTabsBar = function(Value)
			local Object = self.WindowTabSelector
			if not Object then return end

			local TabsBar = Object.TabsBar
			TabsBar.Visible = not Value
		end,
		NoScrollBar = function(Value)
			local ScrollBarThickness = Value and 0 or 9
			local NoScroll = self.NoScroll
			local TabSelector = self.WindowTabSelector
			local ContentCanvas = self.ContentCanvas

			--// TabSelector
			if TabSelector then 
				TabSelector.Body.ScrollBarThickness = ScrollBarThickness
			end
			--// Check if the window is a scrolling type
			if not NoScroll then
				ContentCanvas.ScrollBarThickness = ScrollBarThickness
			end
		end,
		NoScrolling = function(Value)
			local NoScroll = self.NoScroll
			local TabSelector = self.WindowTabSelector
			local ContentCanvas = self.ContentCanvas

			if TabSelector then 
				TabSelector.Body.ScrollingEnabled = not Value
			end
			if not NoScroll then
				ContentCanvas.ScrollingEnabled = not Value
			end
		end,
		NoMove = function(Value)
			local Drag = self.DragConnection
			Drag:SetEnabled(not Value)
		end,
		NoResize = function(Value)
			local Drag = self.ResizeConnection
			Drag:SetEnabled(not Value)
		end,
		NoBackground = function(Value)
			local Transparency = self:GetThemeKey("WindowBgTransparency")
			local Frame = self.CanvasFrame
			Frame.BackgroundTransparency = Value and 1 or Transparency
		end,
	}

	--// Update class data
	Merge(self, Config)

	--// Invoke functions connected to flags
	for Key, Value in Config do
		local Func = Flags[Key]
		if Func then
			Func(Value)
		end
	end

	return self
end

--// Window removal function 
function WindowClass:Remove()
	local Window = self.WindowFrame
	local WindowClass = self.WindowClass
	local Windows = ReGui.Windows

	--// Remove Window from the Windows array
	local Index = table.find(Windows, WindowClass)
	if Index then
		table.remove(Windows, Index)
	end

	--// Destroy the Window frame
	Window:Destroy()
end

function WindowClass:MenuBar(Config, ...)
	local ContentCanvas = self.ContentCanvas
	local ContentFrame = self.ContentFrame

	Config = Config or {}

	Merge(Config, {
		Parent = ContentFrame,
		Layout = -1
	})

	return ContentCanvas:MenuBar(Config, ...)
end

export type WindowFlags = {
	AutoSize: string?,
	CloseCallback: (WindowFlags) -> boolean?,
	IsClosed: boolean?,
	Collapsed: boolean?,
	IsDragging: boolean?,
	MinSize: Vector2?,
	Theme: any?,
	Title: string?,
	NoTabs: boolean?,
	NoMove: boolean?,
	NoResize: boolean?,
	NoTitleBar: boolean?,
	NoClose: boolean?,
	NoCollapse: boolean?,
	NoScrollBar: boolean?,
	NoSelectEffect: boolean?,
	NoFocusOnAppearing: boolean?,
	NoDefaultTitleBarButtons: boolean?,
	NoWindowRegistor: boolean?,
	OpenOnDoubleClick: boolean?,
	NoScroll: boolean?,
	AutoSelectNewTabs: boolean?,
	MinimumSize: Vector2?,
	SetTheme: (WindowFlags, ThemeName: string) -> WindowFlags,
	SetTitle: (WindowFlags, Title: string) -> WindowFlags,
	UpdateConfig: (WindowFlags, Config: table) -> WindowFlags,
	SetCollapsed: (WindowFlags, Collapsed: boolean, NoAnimation: boolean?) -> WindowFlags,
	SetCollapsible: (WindowFlags, Collapsible: boolean) -> WindowFlags,
	SetFocused: (WindowFlags, Focused: boolean) -> WindowFlags,
	Center: (WindowFlags) -> WindowFlags,
	SetVisible: (WindowFlags, Visible: boolean) -> WindowFlags,
	TagElements: (WindowFlags, Objects: {
		[GuiObject]: string
	}) -> nil,
	Close: (WindowFlags) -> nil,
	Parent: Instance,
	AutomaticSize: string?
}
ReGui:DefineElement("Window", {
	Export = true,
	Base = {
		Theme = "DarkTheme",
		NoSelect = false,
		NoTabs = true,
		NoScroll = false,
		Collapsed = false,
		Visible = true,
		AutoSize = false,
		MinimumSize = Vector2.new(160, 90),
		OpenOnDoubleClick = true,
		NoAutoTheme = true,
		NoWindowRegistor = false,
		NoBringToFrontOnFocus = false,
		IsDragging = false,
	},
	Create = function(self, Config: WindowFlags)
		--// Check if ReGui has prefabs
		ReGui:CheckImportState()

		--// Global config unpack
		local Windows = ReGui.Windows
        
        --// Validate Container existence to prevent crash
        if not ReGui.Container then
            ReGui:Warn("Window creation aborted: ReGui Container is missing (Initialization Failed)")
            -- Return a dummy object to prevent calling code from crashing on nil access
            local DummyClass = {}
            function DummyClass:TagElements() end
            setmetatable(DummyClass, {__index = function() return function() end end})
            return DummyClass, Instance.new("Frame")
        end

		local WindowsContainer = ReGui.Container.Windows

		ReGui:CheckConfig(Config, {
			Parent = WindowsContainer,
			Title = ReGui.DefaultTitle
		})

		--// Unpack config
		local NoTitleButtons = Config.NoDefaultTitleBarButtons
		local Collapsed = Config.Collapsed
		local MinimumSize = Config.MinimumSize
		local Title = Config.Title
		local NoTabs = Config.NoTabs
		local NoScroll = Config.NoScroll
		local Theme = Config.Theme
		local AutomaticSize = Config.AutomaticSize
		local NoWindowRegistor = Config.NoWindowRegistor
		local AutoSelectNewTabs = Config.AutoSelectNewTabs
		local _SelectDisabled = Config.Parent ~= WindowsContainer

		local CanvasConfig = {
			Scroll = not NoScroll,
			Fill = not AutomaticSize and true or nil,
			UiPadding = UDim.new(0, NoTabs and 8 or 0),
			AutoSelectNewTabs = AutoSelectNewTabs
		}

		--// Merge AutomaticSize configuration 
		if AutomaticSize then
			Merge(CanvasConfig, {
				AutomaticSize = AutomaticSize,
				Size = UDim2.new(1, 0)
			})
		end

		--// Create Window frame
		local Window = ReGui:InsertPrefab("Window", Config)
		local ContentFrame = Window.Content
		local TitleBar = ContentFrame.TitleBar

		--// Create window class
		local Class = Wrappers:NewClass(WindowClass)

		--// Content canvas
		local BaseCanvas = ReGui:MakeCanvas({
			Element = ContentFrame,
			WindowClass = Class,
			Class = Class
		})

		--// Create Window content canvas
		local Canvas, Body, WindowClass = nil, nil, nil
		local WindowCanvas, CanvasFrame = BaseCanvas:Canvas(Copy(CanvasConfig, {
			Parent = ContentFrame,
			CornerRadius = UDim.new(0, 0),
			--NoStyle = true
		}))

		--// Make the window resizable
		local ResizeConnection = ReGui:MakeResizable({
			MinimumSize = MinimumSize,
			Resize = Window,
			OnUpdate = function(Size)
				Class:SetSize(Size, true)
			end,
		})

		--// Merge tables
		Merge(Class, Config)
		Merge(Class, {
			WindowFrame = Window,  
			ContentFrame = ContentFrame,
			CanvasFrame = CanvasFrame,
			ResizeGrab = ResizeConnection.Grab,
			TitleBar = TitleBar,
			Elements = Elements,
			TagsList = {},
			_SelectDisabled = _SelectDisabled,

			--// Connections
			ResizeConnection = ResizeConnection,
			HoverConnection = ReGui:DetectHover(ContentFrame),
			DragConnection = ReGui:MakeDraggable({
				Grab = ContentFrame,
				Move = Window,
				SetPosition = function(self, Position: UDim2)
					local Tweeninfo = Canvas:GetThemeKey("AnimationTweenInfo")
					--// Tween frame element to the new size
					Animation:Tween({
						Tweeninfo = Tweeninfo,
						Object = self.Move,
						EndProperties = {
							Position = Position
						}
					})
				end,
				OnDragStateChange = function(IsDragging: boolean)
					Class.IsDragging = IsDragging
					CanvasFrame.Interactable = not IsDragging

					--// Change window focus on drag
					if IsDragging then
						ReGui:SetFocusedWindow(WindowClass)
					end

					--// Disable other window focuses if dragging
					ReGui:SetWindowFocusesEnabled(not IsDragging)
				end,
			}),
		})

		--// Create canvas for Window type
		if NoTabs then
			--// Window
			Canvas, Body = WindowCanvas, CanvasFrame
		else
			--// TabsWindow
			Canvas, Body = WindowCanvas:TabSelector(CanvasConfig)
			Class.WindowTabSelector = Canvas
		end

		--// Create Window class from Canvas and Class merge
		WindowClass = ReGui:MergeMetatables(Class, Canvas)

		--// Merge canvas data
		Merge(Class, {
			ContentCanvas = Canvas,
			WindowClass = WindowClass,
			Body = Body
		})

		--// Connect double click events to the collapse
		ReGui:ConnectMouseEvent(ContentFrame, {
			DoubleClick = true,
			OnlyMouseHovering = TitleBar,
			Callback = function(...)
				if not Class.OpenOnDoubleClick then return end
				if Class.NoCollapse then return end

				Class:ToggleCollapsed()
			end,
		})

		--// Create default title bar
		if not NoTitleButtons then
			Class:AddDefaultTitleButtons()
		end

		--// Update window UI
		Class:SetTitle(Title)
		Class:SetCollapsed(Collapsed, true)

		--// Update window configuration
		Class:SetTheme(Theme)
		Class:UpdateConfig(Config)

		--// Update selection
		Class:SetFocused()

		--// Append to Windows array
		if not NoWindowRegistor then
			table.insert(Windows, WindowClass)
		end

		--// Register elements into Window Class
		local ResizeGrab = ResizeConnection.Grab
		ReGui:SetAnimation(ResizeGrab, "TextButtons")
		ReGui:SetFocusedWindow(WindowClass)

		WindowClass:TagElements({
			[ResizeGrab] = "ResizeGrab",
			[TitleBar] = "TitleBar",
			[CanvasFrame] = "Window"
		})

		return WindowClass, Window
	end,
})

export type TabsWindowFlags = {
	AutoSelectNewTabs: boolean?,
} & WindowFlags
ReGui:DefineElement("TabsWindow", {
	Export = true,
	Base = {
		NoTabs = false,
		AutoSelectNewTabs = true
	},
	Create = function(self, Config: TabsWindowFlags)
		return self:Window(Config)
	end,
})

export type PopupCanvas = {
	Scroll: boolean?,
	AutoClose: boolean?,
	RelativeTo: GuiObject,
	MaxSizeY: number?,
	MinSizeX: number?,
	MaxSizeX: number?,
	Visible: boolean?,
	NoAnimation: boolean?,

	Parent: Instance,
	UpdateScale: (PopupCanvas) -> nil,
	UpdatePosition: (PopupCanvas) -> nil,
	ClosePopup: (PopupCanvas) -> nil,
	FetchScales: (PopupCanvas) -> nil,
	IsMouseHovering: (PopupCanvas) -> boolean,
	OnFocusLost: (PopupCanvas) -> nil,
	UpdateScales: (PopupCanvas, Visible: boolean, NoAnimation: boolean, Wait: boolean?) -> nil,
	GetScale: (PopupCanvas, Visible: boolean) -> UDim2,
	SetPopupVisible: (PopupCanvas, Visible: boolean) -> nil
}
ReGui:DefineElement("PopupCanvas", {
	Base = {
		AutoClose = false,
		Scroll = false,
		Visible = true,
		Spacing = UDim.new(0, 1),
		AutomaticSize = Enum.AutomaticSize.XY,
		MaxSizeY = 150,
		MinSizeX = 100,
		MaxSizeX = math.huge,
		OnClosed = EmptyFunction
	},
	Create = function(self, Config: PopupCanvas)
		local RelativeTo = Config.RelativeTo
		local MaxSizeY = Config.MaxSizeY
		local MinSizeX = Config.MinSizeX
		local MaxSizeX = Config.MaxSizeX
		local Visible = Config.Visible
		local AutoClose = Config.AutoClose
		local NoAnimation = Config.NoAnimation
		Config.Parent = ReGui.Container.Overlays

		--// Create object
		local Canvas, Object = self:OverlayScroll(Config)
		local UIStroke = Object.UIStroke

		local Padding = UIStroke.Thickness
		local Relative = Object.Parent.AbsolutePosition
		local Position, Size, YSize, XSize

		--// Connect mouse events
		local Hover = ReGui:DetectHover(Object, {
			MouseOnly = true,
			OnInput = function(MouseHovering, Input)
				if MouseHovering then return end
				if not Object.Visible then return end
				Config:OnFocusLost()
			end,
		})

		function Config:FetchScales()
			--// Roblox does not support UISizeConstraint on a scrolling frame grr
			local CanvasSize = Canvas:GetCanvasSize()

			Position = RelativeTo.AbsolutePosition
			Size = RelativeTo.AbsoluteSize

			YSize = math.clamp(CanvasSize.Y, Size.Y, MaxSizeY)
			XSize = math.clamp(Size.X, MinSizeX, MaxSizeX)
		end

		function Config:UpdatePosition()
			Object.Position = UDim2.fromOffset(
				Position.X - Relative.X + Padding,
				Position.Y - Relative.Y + Size.Y
			)
		end

		function Config:GetScale(Visible: boolean): UDim2
			local OpenSize = UDim2.fromOffset(XSize, YSize)
			local ClosedSize = UDim2.fromOffset(XSize, 0)

			return Visible and OpenSize or ClosedSize
		end

		function Config:IsMouseHovering(): boolean
			return Hover.Hovering
		end

		function Config:OnFocusLost()
			local OnClosed = self.OnClosed

			self:SetPopupVisible(false)
			OnClosed(self) -- Invoke closed callback

			--// Automatically destroy popup
			if AutoClose then
				self:ClosePopup()
			end
		end

		function Config:ClosePopup(Wait: boolean?)
			self:SetPopupVisible(false, NoAnimation, Wait)
			Hover:Disconnect()
			Object:Remove()
		end

		function Config:SetPopupVisible(Visible: boolean, Wait: boolean?)
			--// Check if the visiblity is the same
			if Object.Visible == Visible then return end

			RelativeTo.Interactable = not Visible
			self:UpdateScales(Visible, NoAnimation, Wait)
			self.Visible = Visible
		end

		function Config:UpdateScales(Visible: boolean, NoAnimation: boolean, Wait: boolean?)
			local Tweeninfo = Canvas:GetThemeKey("AnimationTweenInfo")
			Visible = Visible == nil and Object.Visible or Visible

			Config:FetchScales()
			Config:UpdatePosition()

			local Tween = Animation:Tween({
				Tweeninfo = Tweeninfo,
				Object = Object,
				NoAnimation = NoAnimation,
				EndProperties = {
					Size = Config:GetScale(Visible),
					Visible = Visible,
				}
			})

			--// Wait for tween to finish
			if Tween and Wait then
				Tween.Completed:Wait()
			end
		end

		--// Update object
		Config:UpdateScales(false, true)
		Config:SetPopupVisible(Visible)
		Canvas.OnChildChange:Connect(Config.UpdateScales)

		return Canvas, Object
	end,
})

export type PopupModal = {
	ClosePopup: (PopupModal) -> nil,
	NoAnimation: boolean?,
	Parent: Instance
} & WindowFlags
ReGui:DefineElement("PopupModal", {
	Export = true,
	Base = {
		NoAnimation = false,
		NoCollapse = true,
		NoClose = true,
		NoResize = true,
		NoSelect = true,
		NoAutoFlags = true,
		NoWindowRegistor = true,
		NoScroll = true,
	},
	Create = function(self, Config: PopupModal)
		local WindowClass = self.WindowClass

		--// Unpack configuration
		local NoAnimation = Config.NoAnimation
		local WindowDimTweenInfo = nil
		Config.Parent = ReGui.Container.Overlays

		--// Get addional configuration from the Window Class
		if WindowClass then 
			WindowDimTweenInfo = WindowClass:GetThemeKey("ModalWindowDimTweenInfo")
			Config.Theme = WindowClass.Theme
		end

		--// Create Effect object
		local ModalEffect = ReGui:InsertPrefab("ModalEffect", Config)

		--// Create window used for the modal
		local Window = self:Window(Copy(Config, {
			NoAutoFlags = false,
			Parent = ModalEffect,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(372, 38),
			AutomaticSize = Enum.AutomaticSize.Y
		}))

		function Config:ClosePopup()
			Animation:Tween({
				Object = ModalEffect,
				Tweeninfo = WindowDimTweenInfo,
				NoAnimation = NoAnimation,
				EndProperties = {
					BackgroundTransparency = 1
				},
				Completed = function()
					ModalEffect:Destroy()
				end
			})

			Window:Close()

		end

		--// Fade modal effect 
		Animation:Tween({
			Object = ModalEffect,
			Tweeninfo = WindowDimTweenInfo,
			NoAnimation = NoAnimation,
			StartProperties = {
				BackgroundTransparency = 1
			},
			EndProperties = {
				BackgroundTransparency = 0.8
			}
		})

		--// Tag elements into the theme
		self:TagElements({
			[ModalEffect] = "ModalWindowDim"
		})

		--// Create the modal class
		local ModalClass = ReGui:MergeMetatables(Config, Window)
		return ModalClass, ModalEffect
	end,
})

GenerateMultiInput("InputInt2", "InputInt", 2, {NoButtons=true})
GenerateMultiInput("InputInt3", "InputInt", 3, {NoButtons=true})
GenerateMultiInput("InputInt4", "InputInt", 4, {NoButtons=true})
GenerateMultiInput("SliderInt2", "SliderInt", 2)
GenerateMultiInput("SliderInt3", "SliderInt", 3)
GenerateMultiInput("SliderInt4", "SliderInt", 4)
GenerateMultiInput("SliderFloat2", "SliderFloat", 2)
GenerateMultiInput("SliderFloat3", "SliderFloat", 3)
GenerateMultiInput("SliderFloat4", "SliderFloat", 4)
GenerateMultiInput("DragInt2", "DragInt", 2)
GenerateMultiInput("DragInt3", "DragInt", 3)
GenerateMultiInput("DragInt4", "DragInt", 4)
GenerateMultiInput("DragFloat2", "DragFloat", 2)
GenerateMultiInput("DragFloat3", "DragFloat", 3)
GenerateMultiInput("DragFloat4", "DragFloat", 4)

GenerateColor3Input("InputColor3", "InputInt3")
GenerateColor3Input("SliderColor3", "SliderInt3")
GenerateColor3Input("DragColor3", "DragInt3")

GenerateCFrameInput("InputCFrame", "InputInt3")
GenerateCFrameInput("SliderCFrame", "SliderInt3")
GenerateCFrameInput("DragCFrame", "DragInt3")

return ReGui
end)()
