-- services

local cam = workspace.CurrentCamera
local inputservice = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local ps = game:GetService("Players")
local pl = ps.LocalPlayer

-- vars

local clone, char = nil
local phasing = false

-- instances

local cor = Instance.new("ColorCorrectionEffect") -- phasing color
cor.Enabled = true
cor.TintColor = Color3.fromRGB(15, 183, 255)

local sound = Instance.new("Sound") -- phasing sound
sound.SoundId = "rbxassetid://362395087"
sound.Volume = 1
sound.Looped = true

-- misc functions

local function setop(char, tr)
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = tr
		end
	end
end

local function setgui(st)
	for _, v in pairs(pl.PlayerGui:GetChildren()) do
		if v:IsA("ScreenGui") then
			v.ResetOnSpawn = st
		end
	end
end

-- main functions

local function destroy(tp)
	if phasing == true then
		sound:Stop()
		sound.Parent = nil
		cor.Parent = nil
		setgui(false)
		
		if tp == true then
			char.HumanoidRootPart.CFrame = clone.HumanoidRootPart.CFrame
		end
		
		clone.Parent = nil
		pl.Character = char
		cam.CameraSubject = char
		
		setgui(true)
		setop(char, 0)
		
		phasing = false
	end
end

local function create()
	if clone ~= nil and char ~= nil and phasing == false and char.Humanoid.Health > 0 then
		cor.Parent = lighting
		sound.Parent = workspace
		sound:Play()
		setgui(false)
		
		clone.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (char.HumanoidRootPart.CFrame.LookVector * -3)
		clone.Parent = workspace
		
		pl.Character = clone
		cam.CameraSubject = clone.Humanoid
		
		clone.Animate.Disabled = true
		clone.Animate.Disabled = false -- fix animations
		
		setgui(true)
		setop(char, 0.5)
		phasing = true
	end
end

-- character setup & cloning

local function setupchar(detchar)
	if clone then
		clone:Destroy()
		clone = nil
	end

	if phasing == true then
		sound:Stop()
		sound.Parent = nil
		cor.Parent = nil
		phasing = false
	end

	char = pl.Character
	char.Archivable = true
	clone = char:Clone()

	clone:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	char.Humanoid.Died:Connect(destroy)
end

-- input handling

inputservice.InputBegan:Connect(function(input, proc)
	if proc then return elseif input.KeyCode == Enum.KeyCode.F1 then
		if phasing == false then
			create() -- F1 to start phase
		else
			destroy() -- F1 to end phase (return back to character)
		end
	elseif input.KeyCode == Enum.KeyCode.F2 and phasing == true then
		destroy(true) -- F2 to end phase (teleport character to phaser)
	end
end)

-- hooking events

pl.CharacterAppearanceLoaded:Connect(setupchar)

if pl.Character and pl:HasAppearanceLoaded() == true then
	setupchar()
end