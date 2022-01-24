local scriptVersion = "2.0"

local CurrentCamera = workspace.CurrentCamera
local Players = game.GetService(game, "Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local IS = game.getService(game,"UserInputService")
local RunService = game:GetService("RunService")
local worldToViewportPoint = CurrentCamera.worldToViewportPoint

local settings = {
    Teamcheck = false,
    Wallcheck = false,
    Aim_Enabled = false,
    Draw_FOV = false,
    FOV_Colour = Color3.fromRGB(15,255,25),
    FOV_Radius = 0,
    Sensitivity = 1,
    Offset = 36
}

--FOV Circle
local fovcircle = Drawing.new("Circle")
fovcircle.Visible = settings.Draw_FOV
fovcircle.Radius = settings.FOV_Radius
fovcircle.Thickness = .5
fovcircle.Filled = false
fovcircle.Transparency = 1
fovcircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
fovcircle.Color = Color3.fromRGB(15,255,25)

IS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.Aiming = true
    end
end)

IS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.Aiming = false
    end
end)

--Aimbot
local function aimAt(vector)
    local newpos = worldToViewportPoint(CurrentCamera, vector)
    mousemoverel((newpos.X - Mouse.X) * settings.Sensitivity, ((newpos.Y - Mouse.Y - settings.Offset) * settings.Sensitivity))
end

local function isVis(p)
    if not settings.Wallcheck then return true end
	ignoreList = {LocalPlayer.Character, CurrentCamera, p.Character}
	local parts = workspace.CurrentCamera:GetPartsObscuringTarget({p.Character.Head.Position, CurrentCamera.CFrame.Position}, ignoreList)
    return #parts == 0
end

function get_target_aimbot()
    local MaxDist, Closest = math.huge

    for I,V in pairs(Players.GetPlayers(Players)) do
        if V == LocalPlayer or V.Team == LocalPlayer or not V.Character then continue end
    
        local Head = V.Character.FindFirstChild(V.Character, "Head")
        if not Head then continue end
    
        local Pos, Vis = CurrentCamera.WorldToScreenPoint(CurrentCamera, Head.Position)
        if not Vis then continue end
        
        local Humanoid = V.Character.FindFirstChild(V.Character, "Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then continue end
        
        local ForceField = V.Character.FindFirstChild(V.Character, "ForceField")
        if ForceField then continue end
        
        if settings.Teamcheck and V.TeamColor == LocalPlayer.TeamColor then continue end
        local MousePos, TheirPos = Vector2.new(Mouse.X, Mouse.Y), Vector2.new(Pos.X, Pos.Y)
        local Dist = (TheirPos - MousePos).Magnitude
        
        if Dist < MaxDist and Dist <= settings.FOV_Radius then 
            MaxDist = Dist
            Closest = V
        end
    end
    return Closest
end

RunService.RenderStepped:Connect(function()
    if settings.Aim_Enabled and settings.Aiming then
        local t = get_target_aimbot()
        if t and isVis(t) then
            aimAt(t.Character.Head:GetRenderCFrame().Position)
        end
    end
    
    if settings.Aim_Enabled and settings.Draw_FOV then
        fovcircle.Visible = true
        fovcircle.Radius = settings.FOV_Radius
        fovcircle.Color = settings.FOV_Colour
        fovcircle.Position = Vector2.new(Mouse.X, Mouse.Y + settings.Offset)
    else
        fovcircle.Visible = false
    end

end)


--Esp
local espSettings = {
    Enabled = false,
    Teamcheck = false,
    Boxes = false,
    Box_Colour = Color3.fromRGB(255,15,25),
    Nametag_Colour = Color3.new(1,0.62,0),
    Healthbar_Colour = Color3.new(0.15,1,0.26),
    Nametags = false,
    Teamcheck = false,
    Healthbar = false
}

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0,3,0)

for i,v in pairs(game.Players:GetChildren()) do
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255,15,25)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false
    
    local Nametag = Drawing.new("Text")
    Nametag.Visible = false
    Nametag.Color = Color3.new(1,0.62,0)
    Nametag.Size = 20
    
    local HealthBar = Drawing.new("Square")
    HealthBar.Thickness = 1
    HealthBar.Filled = false
    HealthBar.Color = Color3.new(0.15,1,0.26)
    HealthBar.Transparency = 1 
    HealthBar.Visible = false
    
    function boxesp()
        game:GetService("RunService").RenderStepped:Connect(function()
            if v.Character ~= nil and v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("HumanoidRootPart") ~= nil and v ~= LocalPlayer and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("Head") ~= nil then
                 if espSettings.Teamcheck and LocalPlayer.TeamColor ~= v.TeamColor or not espSettings.Teamcheck then
                    local Vector, onScreen = CurrentCamera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)
        
                    local RootPart = v.Character.HumanoidRootPart
                    local Head = v.Character.Head
                    local RootPosition, RootVis = worldToViewportPoint(CurrentCamera, RootPart.Position)
                    local HeadPosition = worldToViewportPoint(CurrentCamera, Head.Position + HeadOff)
                    local LegPosition = worldToViewportPoint(CurrentCamera, RootPart.Position - LegOff)
                    local name = v.Name .. " (" .. v.DisplayName ..")" 
                  
                    if onScreen and espSettings.Enabled then
                        Box.Size = Vector2.new(1700 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                        Box.Position = Vector2.new(RootPosition.X - Box.Size.X / 2, RootPosition.Y - Box.Size.Y / 2)
                        if espSettings.Boxes then
                            Box.Visible = true 
                            Box.Color = espSettings.Box_Colour
                        else
                            Box.Visible = false
                        end
                       
                        Nametag.Text = name 
                        Nametag.Position = Vector2.new(HeadPosition.X + Box.Size.X + 0.5 / 2, HeadPosition.Y - 7)
                        if espSettings.Nametags then 
                            Nametag.Visible = true
                            Nametag.Color = espSettings.Nametag_Colour
                        else
                            Nametag.Visible = false
                        end
                        
                        HealthBar.Size = Vector2.new(2, (HeadPosition.Y - LegPosition.Y) * (v.Character.Humanoid.Health / v.Character.Humanoid.MaxHealth))
                        HealthBar.Position = Vector2.new(Box.Position.X - 5, Box.Position.Y + (1/HealthBar.Size.Y))
                        if espSettings.Healthbar then
                            HealthBar.Visible = true
                            HealthBar.Color = espSettings.Healthbar_Colour
                        else
                            HealthBar.Visible = false
                        end
                    else
                        Box.Visible = false
                        Nametag.Visible = false
                        HealthBar.Visible = false
                    end
                else
                    Box.Visible = false
                    Nametag.Visible = false
                    HealthBar.Visible = false
                end
            else
                Box.Visible = false
                Nametag.Visible = false
                HealthBar.Visible = false
            end
        end)
    end
    coroutine.wrap(boxesp)()
end

game.Players.PlayerAdded:Connect(function(v)
 local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255,15,25)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false
    
    local Nametag = Drawing.new("Text")
    Nametag.Visible = false
    Nametag.Color = Color3.new(1,0.62,0)
    Nametag.Size = 20
    
    local HealthBar = Drawing.new("Square")
    HealthBar.Thickness = 1
    HealthBar.Filled = false
    HealthBar.Color = Color3.new(0.15,1,0.26)
    HealthBar.Transparency = 1 
    HealthBar.Visible = false
    
    function boxesp()
        game:GetService("RunService").RenderStepped:Connect(function()
            if v.Character ~= nil and v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("HumanoidRootPart") ~= nil and v ~= LocalPlayer and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("Head") ~= nil then
                if espSettings.Teamcheck and LocalPlayer.TeamColor ~= v.TeamColor or not espSettings.Teamcheck then
                    local Vector, onScreen = CurrentCamera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)
        
                    local RootPart = v.Character.HumanoidRootPart
                    local Head = v.Character.Head
                    local RootPosition, RootVis = worldToViewportPoint(CurrentCamera, RootPart.Position)
                    local HeadPosition = worldToViewportPoint(CurrentCamera, Head.Position + HeadOff)
                    local LegPosition = worldToViewportPoint(CurrentCamera, RootPart.Position - LegOff)
                    local name = v.Name .. " (" .. v.DisplayName ..")" 
                  
                    if onScreen and espSettings.Enabled then
                        Box.Size = Vector2.new(1700 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                        Box.Position = Vector2.new(RootPosition.X - Box.Size.X / 2, RootPosition.Y - Box.Size.Y / 2)
                        if espSettings.Boxes then
                            Box.Visible = true 
                            Box.Color = espSettings.Box_Colour
                        else
                            Box.Visible = false
                        end
                       
                        Nametag.Text = name 
                        Nametag.Position = Vector2.new(HeadPosition.X + Box.Size.X + 0.5 / 2, HeadPosition.Y - 7)
                        if espSettings.Nametags then 
                            Nametag.Visible = true
                            Nametag.Color = espSettings.Nametag_Colour
                        else
                            Nametag.Visible = false
                        end
                        
                        HealthBar.Size = Vector2.new(2, (HeadPosition.Y - LegPosition.Y) * (v.Character.Humanoid.Health / v.Character.Humanoid.MaxHealth))
                        HealthBar.Position = Vector2.new(Box.Position.X - 5, Box.Position.Y + (1/HealthBar.Size.Y))
                        if espSettings.Healthbar then
                            HealthBar.Visible = true
                            HealthBar.Color = espSettings.Healthbar_Colour
                        else
                            HealthBar.Visible = false
                        end
                    else
                        Box.Visible = false
                        Nametag.Visible = false
                        HealthBar.Visible = false
                    end
                else
                    Box.Visible = false
                    Nametag.Visible = false
                    HealthBar.Visible = false
                end
            else
                Box.Visible = false
                Nametag.Visible = false
                HealthBar.Visible = false
            end
        end)
    end
    coroutine.wrap(boxesp)()
end)

--Silent Aim
local silentAimSettings = {
    Enabled = true,
    Aim_FOV = 1,
    Teamcheck = false,
    Draw_FOV = false,
    FOV_Colour = Color3.fromRGB(255,15,25),
    Offset = 36
}

local silentfovcircle = Drawing.new("Circle")
silentfovcircle.Visible = silentAimSettings.Draw_FOV
silentfovcircle.Radius = silentAimSettings.Aim_FOV
silentfovcircle.Thickness = .5
silentfovcircle.Filled = false
silentfovcircle.Transparency = 1
silentfovcircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
silentfovcircle.Color = Color3.fromRGB(255,15,25)

local function isVisSilent(p)
	ignoreList = {LocalPlayer.Character, CurrentCamera, p.Character}
	local parts = workspace.CurrentCamera:GetPartsObscuringTarget({p.Character.Head.Position, CurrentCamera.CFrame.Position}, ignoreList)
    return #parts == 0
end

function get_target_silent()
    local MaxDist, Closest = math.huge
    for I,V in pairs(Players.GetPlayers(Players)) do
        if not silentAimSettings.Enabled then continue end
        
        if V == LocalPlayer or V.Team == LocalPlayer or not V.Character then continue end
    
        local Head = V.Character.FindFirstChild(V.Character, "Head")
        if not Head then continue end
    
        local Pos, Vis = CurrentCamera.WorldToScreenPoint(CurrentCamera, Head.Position)
        if not Vis then continue end
        
        local Humanoid = V.Character.FindFirstChild(V.Character, "Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then continue end
        
        local ForceField = V.Character.FindFirstChild(V.Character, "ForceField")
        if ForceField then continue end
        
        if silentAimSettings.Teamcheck and V.TeamColor == LocalPlayer.TeamColor then continue end
        local MousePos, TheirPos = Vector2.new(Mouse.X, Mouse.Y), Vector2.new(Pos.X, Pos.Y)
        local Dist = (TheirPos - MousePos).Magnitude
        
        if Dist < MaxDist and Dist <= silentAimSettings.Aim_FOV then 
            MaxDist = Dist
            Closest = V
        end
    end
    return Closest
end

local MT = getrawmetatable(game)
local OldNC = MT.__namecall
local OldIDX = MT.__index
setreadonly(MT, false)
MT.__namecall = newcclosure(function(self, ...)
    local Args, Method = {...}, getnamecallmethod()
    if Method == "FindPartOnRayWithIgnoreList" and not checkcaller() then
        local T = get_target_silent()
        if T and T.Character and T.Character.FindFirstChild(T.Character, "Head") then
            Args[1] = Ray.new(CurrentCamera.CFrame.Position, (T.Character.Head.Position - CurrentCamera.CFrame.Position).Unit * 1000)
            return OldNC(self, unpack(Args))
        end
    end
    return OldNC(self, ...)
end)

MT.__index = newcclosure(function(self, K)
    if K == "Clips" then
        return workspace.Map
    end
    return OldIDX(self, K)
end)
setreadonly(MT, true)

game:GetService("RunService").RenderStepped:Connect(function()
     if silentAimSettings.Enabled and silentAimSettings.Draw_FOV then
        silentfovcircle.Visible = true
        silentfovcircle.Radius = silentAimSettings.Aim_FOV
        silentfovcircle.Position = Vector2.new(Mouse.X, Mouse.Y + silentAimSettings.Offset)
    else
        silentfovcircle.Visible = false
    end
end)

local flySettings = {
    fly = false,
    flyspeed = 50
}

local c
local h
local bv
local bav
local cam
local flying
local p = game.Players.LocalPlayer
local buttons = {W = false, S = false, A = false, D = false, Moving = false}

local startFly = function () -- Call this function to begin flying 
	if not p.Character or not p.Character.Head or flying then return end
	c = p.Character
	h = c.Humanoid
	h.PlatformStand = true
	cam = workspace:WaitForChild('Camera')
	bv = Instance.new("BodyVelocity")
	bav = Instance.new("BodyAngularVelocity")
	bv.Velocity, bv.MaxForce, bv.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
	bav.AngularVelocity, bav.MaxTorque, bav.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
	bv.Parent = c.Head
	bav.Parent = c.Head
	flying = true
	h.Died:connect(function() flying = false end)
end

local endFly = function () -- Call this function to stop flying
	if not p.Character or not flying then return end
	h.PlatformStand = false
	bv:Destroy()
	bav:Destroy()
	flying = false
end

game:GetService("UserInputService").InputBegan:connect(function (input, GPE) 
	if GPE then return end
	for i, e in pairs(buttons) do
		if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
			buttons[i] = true
			buttons.Moving = true
		end
	end
end)

game:GetService("UserInputService").InputEnded:connect(function (input, GPE) 
	if GPE then return end
	local a = false
	for i, e in pairs(buttons) do
		if i ~= "Moving" then
			if input.KeyCode == Enum.KeyCode[i] then
				buttons[i] = false
			end
			if buttons[i] then a = true end
		end
	end
	buttons.Moving = a
end)

local setVec = function (vec)
	return vec * (flySettings.flyspeed / vec.Magnitude)
end

game:GetService("RunService").Heartbeat:connect(function (step) -- The actual fly function, called every frame
	if flying and c and c.PrimaryPart then
		local p = c.PrimaryPart.Position
		local cf = cam.CFrame
		local ax, ay, az = cf:toEulerAnglesXYZ()
		c:SetPrimaryPartCFrame(CFrame.new(p.x, p.y, p.z) * CFrame.Angles(ax, ay, az))
		if buttons.Moving then
			local t = Vector3.new()
			if buttons.W then t = t + (setVec(cf.lookVector)) end
			if buttons.S then t = t - (setVec(cf.lookVector)) end
			if buttons.A then t = t - (setVec(cf.rightVector)) end
			if buttons.D then t = t + (setVec(cf.rightVector)) end
			c:TranslateBy(t * step)
		end
	end
end)









local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Byte Ware", "BloodTheme")

--combat tab
local CombatTab = Window:NewTab("Combat")

--aimbot section
local Aimbot = CombatTab:NewSection("Aimbot")
Aimbot:NewToggle("Enabled", "Aims for you", function(state)
    if state then
        settings.Aim_Enabled = true
    else
        settings.Aim_Enabled = false
    end
end)
Aimbot:NewSlider("Smoothness", "Smoothens the aimbot", 80, 1, function(s)
    settings.Sensitivity = s / 100
end)
--wallcheck
Aimbot:NewToggle("Wallcheck", "Checks if a player is visible", function(state)
    if state then
        settings.Wallcheck = true
    else
        settings.Wallcheck = false
    end
end)
--teamcheck
Aimbot:NewToggle("Teamcheck", "Checks if a player is in your team", function(state)
    if state then
        settings.Teamcheck = true
    else
        settings.Teamcheck = false
    end
end)

--drawfov section
Aimbot:NewToggle("Draw FOV", "Draws an FOV on the screen", function(state)
    if state then
        settings.Draw_FOV = true
    else
        settings.Draw_FOV = false
    end
end)
Aimbot:NewSlider("Draw FOV Radius", "The max distance from the mouse that a player can be targeted at", 800, 1, function(s)
    settings.FOV_Radius = s
end)
Aimbot:NewColorPicker("Draw FOV Color", "Changes the color of the FOV circle", Color3.fromRGB(15,255,25), function(color)
    settings.FOV_Colour = color
    fovcircle.Color = settings.FOV_Colour
end)

--Silent tab
local SilentAim = Window:NewTab("Silent Aim")
local silent = SilentAim:NewSection("Slient Aim")

silent:NewToggle("Enabled", "Silent Aim", function(state)
    if state then
        silentAimSettings.Enabled = true
    else
        silentAimSettings.Enabled = false
    end
end)
silent:NewToggle("Teamcheck", "Checks if a player is on your team", function(state)
    if state then
        silentAimSettings.Teamcheck = true
    else
        silentAimSettings.Teamcheck = false
    end
end)
silent:NewToggle("Draw FOV", "Draws an FOV on your screen", function(state)
    if state then
        silentAimSettings.Draw_FOV = true
    else
        silentAimSettings.Draw_FOV = false
    end
end)
silent:NewSlider("Draw FOV Radius", "The max distance from the mouse that a player can be targeted at", 800, 1, function(s)
    silentAimSettings.Aim_FOV = s
end)
silent:NewColorPicker("Draw FOV Color", "Changes the color of the FOV circle", Color3.fromRGB(255,15,25), function(color)
    silentAimSettings.FOV_Colour = color
    silentfovcircle.Color = silentAimSettings.FOV_Colour
end)

--Visual tab
local Visuals = Window:NewTab("Visuals")

local esp = Visuals:NewSection("ESP")
esp:NewToggle("Enabled", "Allows you too see others through walls", function(state)
    if state then
        espSettings.Enabled = true
    else
        espSettings.Enabled = false
    end
end)
esp:NewToggle("Boxes", "Draws box over players", function(state)
    if state then
        espSettings.Boxes = true
    else
        espSettings.Boxes = false
    end
end)
esp:NewToggle("Teamcheck", "Checks if player is in your team", function(state)
    if state then
        espSettings.Teamcheck = true
    else
        espSettings.Teamcheck = false
    end
end)
esp:NewToggle("Nametags", "Displays nametags for players", function(state)
    if state then
        espSettings.Nametags = true
    else
        espSettings.Nametags = false
    end
end)
esp:NewColorPicker("Nametag Color", "What colour the nametags are...", Color3.new(1,0.62,0), function(color)
    espSettings.Nametag_Colour = color
end)
esp:NewColorPicker("Box Color", "Changes the color of the ESP Boxes", Color3.fromRGB(255,15,25), function(color)
    espSettings.Box_Colour = color
end)

--player tab
local PlayerTab = Window:NewTab("Player")
--fly
local Fly = PlayerTab:NewSection("Movement")
Fly:NewToggle("Fly", "Allows the player to fly", function(state)
    if state then
        startFly()
    else
        endFly()
    end
end)
Fly:NewSlider("Fly Speed", "Allows for faster/slower flight", 100, 1, function(s)
    flySettings.flyspeed = s
end)

--world settings
local WorldTab = Window:NewTab("World")
--server
local Server = WorldTab:NewSection("Server")
Server:NewButton("Rejoin Server", "Rejoins the same server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
end)
--fps
local FPSboost = WorldTab:NewSection("FPS")
FPSboost:NewButton("FPS Boost", "Increases FPS", function()
    for _,v in pairs(workspace:GetDescendants()) do
        if v.ClassName == "Part"
        or v.ClassName == "SpawnLocation"
        or v.ClassName == "WedgePart"
        or v.ClassName == "Terrain"
        or v.ClassName == "MeshPart" then
        v.Material = "Plastic"
        end
    end
end)

--other tab
local OtherTab = Window:NewTab("Other")
--Gui settings
local GUISection = OtherTab:NewSection("GUI")
GUISection:NewKeybind("Toggle GUI", "Toggles the GUI", Enum.KeyCode.RightShift, function()
	Library:ToggleUI()
end)

--info tab
local InfoTab = Window:NewTab("Info")
--info details
local InfoSection = InfoTab:NewSection("Version ".. scriptVersion)
InfoSection:NewLabel("Created by !Luckfiel#6969")
