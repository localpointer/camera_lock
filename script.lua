getgenv().Aimbot = {
    Status = true,
    Keybind  = 'C',
    Hitpart = 'HumanoidRootPart',  
    ['Prediction'] = {
        Enabled = false, 
        X = 0.165,
        Y = 0.1,
    },
    Smoothness = 0.2,  
    FOV = 100,      
    MaxDistance = math.huge, 
    AimbotMode = "snap", -- "smooth" or "snap"
}

if getgenv().AimbotRan then
    return
else
    getgenv().AimbotRan = true
end

local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Player = nil 


local function GetClosestPlayer()
    local closestDistance, closestPlayer = math.huge, nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.Hitpart) then
            local Hitpart = player.Character[Aimbot.Hitpart]
            local ScreenPosition, Visible = Camera:WorldToScreenPoint(Hitpart.Position)
            
            if not Visible then
                continue
            end

            local RootDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPosition.X, ScreenPosition.Y)).Magnitude
            if RootDist < closestDistance then
                local DistanceFromCamera = (Hitpart.Position - Camera.CFrame.Position).Magnitude
                if DistanceFromCamera <= Aimbot.MaxDistance and RootDist <= Aimbot.FOV then
                    closestPlayer = player
                    closestDistance = RootDist
                end
            end
        end
    end
    return closestPlayer
end


Mouse.KeyDown:Connect(function(key)
    if key == Aimbot.Keybind:lower() then
        Player = not Player and GetClosestPlayer() or nil
    end
end)


RunService.RenderStepped:Connect(function()
    if not Player or not Aimbot.Status then
        return
    end

    local Hitpart = Player.Character:FindFirstChild(Aimbot.Hitpart)
    if not Hitpart then
        return
    end


    local TargetPosition = Hitpart.Position
    if Aimbot.Prediction.Enabled then
        TargetPosition = Hitpart.Position + Hitpart.Velocity * Vector3.new(Aimbot.Prediction.X, Aimbot.Prediction.Y, Aimbot.Prediction.X)
    end


    local CurrentCameraPosition = Camera.CFrame.Position
    local DirectionToTarget = (TargetPosition - CurrentCameraPosition).Unit

    if Aimbot.AimbotMode == "smooth" then
   
        local SmoothCameraPosition = CurrentCameraPosition + DirectionToTarget * Aimbot.Smoothness
        Camera.CFrame = CFrame.new(SmoothCameraPosition, TargetPosition)
    elseif Aimbot.AimbotMode == "snap" then

        Camera.CFrame = CFrame.new(CurrentCameraPosition, TargetPosition)
    end
end)
