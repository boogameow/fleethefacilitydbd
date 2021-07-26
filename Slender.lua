-- controlled variables

local coregui = game:GetService("CoreGui")
local inputservice = game:GetService("UserInputService")

local ps = game:GetService("Players")
local pl = ps.LocalPlayer

-- manipulated variables

local info
local version = 2.1

local volume = 2
local distance = 1000000

local state = {
    spoof = false
}

local color = {
    [true] = Color3.fromRGB(0, 255, 0),
    [false] = Color3.fromRGB(255, 0, 0)
}

-- functions

local function charsetup(char)
    local hrp = char:WaitForChild("HumanoidRootPart")
    local srf = hrp:FindFirstChild("srf")

    if srf then
        srf.MaxDistance = distance
        srf.Volume = volume
    end

    hrp.ChildAdded:Connect(function(child)
        if child.Name == "srf" then
            child.MaxDistance = distance
            child.Volume = volume
        end
    end)
end

local function newconnection(player)
    player.CharacterAdded:Connect(charsetup)

    if player.Character then
        coroutine.wrap(charsetup)(player.Character)
    end

    if player.UserId == pl.UserId then 
        pl.PlayerGui.ChildAdded:Connect(function(child)
            if child.Name == "CitizenGui" and state.spoof == true then 
                local static = child:WaitForChild("Static")
                static:WaitForChild("SeeingCheck").Disabled = true
            end
        end)
    end
end

-- events

ps.PlayerAdded:Connect(newconnection)

for _, player in pairs(ps:GetChildren()) do
    newconnection(player)
end

-- interface creation

local gui = Instance.new("ScreenGui")
    gui.ResetOnSpawn = false
local first = Instance.new("TextLabel", gui)
    first.BackgroundTransparency = 1
    first.BorderSizePixel = 0
    first.TextXAlignment = Enum.TextXAlignment.Left
    first.Font = Enum.Font.SourceSansBold
    first.TextSize = 35
    first.Text = "Slender v" .. tostring(version)
    first.TextColor3 = Color3.fromRGB(255, 255, 255)
    first.Position = UDim2.new(0.01, 0, 0.58, 0)
    first.AnchorPoint = Vector2.new(0, 0.5)
    first.Size = UDim2.new(0.15, 0, 0.05, 0)

local scale = first.Position.Y.Scale

-- keybind functions

info = {
    [Enum.KeyCode.M] = {
        Name = "Interface",
        Action = function()
            gui.Enabled = not gui.Enabled
        end
    },
    [Enum.KeyCode.B] = {
        Name = "Look Spoofer",
        BoolType = true,
        Action = function(key)
            local self = info[key]
            local newstate = not state.spoof
            local citizen = pl.PlayerGui:FindFirstChild("CitizenGui")
            
            if citizen then
                local static = citizen.Static
                static.SeeingCheck.Disabled = newstate
                static.looking.Value = false
            end

            state.spoof = newstate
            self.Object.TextColor3 = color[newstate]
        end
    },
}

-- loop create

for i, key in pairs(info) do
    local letter = string.split(tostring(i), ".")[3]

    scale += 0.025

    local text = first:Clone()
    text.Name = letter
    text.Font = Enum.Font.SourceSansSemibold
    text.TextSize = 24
    text.Text = letter .. " - " .. key.Name
    text.Position = UDim2.new(0.02, 0, scale, 0)

    if key.BoolType == true then
        text.TextColor3 = color[false]
    else 
        text.TextColor3 = Color3.fromRGB(235, 238, 9)
    end
    
    text.Parent = gui
    key.Object = text
end

-- handle input

inputservice.InputBegan:Connect(function(input, proc)
    local code = info[input.KeyCode]

    if code and not proc then
        code.Action(input.KeyCode)
    end
end)

-- parent gui

syn.protect_gui(gui)
gui.Parent = coregui