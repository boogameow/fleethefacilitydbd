local cam = workspace.CurrentCamera
local inputservice = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local ps = game:GetService("Players")
local pl = ps.LocalPlayer

local clone, old, con, con2 = nil
local phasing = false

local cor = Instance.new("ColorCorrectionEffect") -- phasing color
cor.Enabled = true
cor.TintColor = Color3.fromRGB(15, 183, 255)

local sound = Instance.new("Sound") -- phasing sound
sound.SoundId = "rbxassetid://362395087"
sound.Volume = 1
sound.Looped = true

local function setop(char, tr)
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = tr
		end
	end
end

local function destroy(tp)
	if phasing == true then
		if con then
			con:Disconnect()
			con2:Disconnect()
			con, con2 = nil
		end
		
		sound:Stop()
		sound.Parent = nil
		cor.Parent = nil
		
		if tp == true then
			old.HumanoidRootPart.CFrame = clone.HumanoidRootPart.CFrame
		end
		
		clone:Destroy()
		pl.Character = old
		cam.CameraSubject = old
		
		setop(old, 0)
		
		clone, old = nil
		phasing = false
	end
end

local function create()
	if clone == nil and phasing == false and pl.Character and pl.Character.Humanoid.Health > 0 then -- fail-safes
		cor.Parent = lighting
		sound.Parent = workspace
		sound:Play()
		
		pl.Character.Archivable = true
		old = pl.Character
		clone = pl.Character:Clone()
		
		clone.HumanoidRootPart.CFrame += (clone.HumanoidRootPart.CFrame.LookVector * -3) -- move clone behind original
		clone.Parent = workspace
		
		pl.Character = clone
		cam.CameraSubject = clone.Humanoid

		clone.Animate.Disabled = true -- fix animations on the new char
		clone.Animate.Disabled = false
		clone.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		con = old.Humanoid.Died:Connect(destroy) -- if the husk dies
		con2 = pl.CharacterAdded:Connect(destroy) -- if LoadCharacter() is forced by the server
		
		setop(old, 0.5)
		phasing = true
	end
end

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