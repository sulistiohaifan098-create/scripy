local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
while not player do
	player = Players.PlayerAdded:Wait()
end

local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 10)
if not playerGui then
	return
end

-- Pengaturan Auto-Equip Iron Sword & Posisi Adaptif
local PREFERRED_TOOL = "Iron Sword"
local ATTACK_COOLDOWN = 0.24
local REACH_DISTANCE = 7.0     -- Reach dasar 7 studs (bisa diatur + / - di UI)
local EXTRA_CLEARANCE = 2.2    -- Tambahan tinggi/jarak ekstra untuk zombie besar / Boss
local PRIORITIZE_LOW_HP = true
local USE_NOCLIP = true

-- Bersihkan UI lama jika ada
local oldGui = playerGui:FindFirstChild("SWORD_RANGE_UI")
if oldGui then
	pcall(function()
		oldGui:Destroy()
	end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "SWORD_RANGE_UI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(230, 166)
frame.Position = UDim2.new(0.5, -115, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -64, 0, 26)
title.Position = UDim2.fromOffset(8, 2)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "IRON SWORD AUTO KILL"
title.Parent = frame

local holder = Instance.new("Frame")
holder.Size = UDim2.new(1, 0, 1, -28)
holder.Position = UDim2.fromOffset(0, 28)
holder.BackgroundTransparency = 1
holder.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 18)
statusLabel.Position = UDim2.fromOffset(8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180, 190, 210)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Status: OFF"
statusLabel.Parent = holder

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(1, -90, 0, 24)
rangeLabel.Position = UDim2.fromOffset(8, 20)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.fromRGB(150, 255, 170)
rangeLabel.Font = Enum.Font.GothamBold
rangeLabel.TextSize = 10
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Text = string.format("Reach: %.1f", REACH_DISTANCE)
rangeLabel.Parent = holder

local minusRangeBtn = Instance.new("TextButton")
minusRangeBtn.Size = UDim2.fromOffset(34, 24)
minusRangeBtn.Position = UDim2.fromOffset(146, 20)
minusRangeBtn.BackgroundColor3 = Color3.fromRGB(55, 62, 80)
minusRangeBtn.TextColor3 = Color3.new(1, 1, 1)
minusRangeBtn.Font = Enum.Font.GothamBold
minusRangeBtn.TextSize = 13
minusRangeBtn.Text = "-"
minusRangeBtn.Parent = holder
Instance.new("UICorner", minusRangeBtn).CornerRadius = UDim.new(0, 6)

local plusRangeBtn = Instance.new("TextButton")
plusRangeBtn.Size = UDim2.fromOffset(34, 24)
plusRangeBtn.Position = UDim2.fromOffset(186, 20)
plusRangeBtn.BackgroundColor3 = Color3.fromRGB(55, 62, 80)
plusRangeBtn.TextColor3 = Color3.new(1, 1, 1)
plusRangeBtn.Font = Enum.Font.GothamBold
plusRangeBtn.TextSize = 13
plusRangeBtn.Text = "+"
plusRangeBtn.Parent = holder
Instance.new("UICorner", plusRangeBtn).CornerRadius = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -16, 0, 34)
toggleBtn.Position = UDim2.fromOffset(8, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(145, 45, 45)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.Text = "OFF"
toggleBtn.Parent = holder
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local errLabel = Instance.new("TextLabel")
errLabel.Size = UDim2.new(1, -16, 0, 34)
errLabel.Position = UDim2.fromOffset(8, 90)
errLabel.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
errLabel.TextColor3 = Color3.fromRGB(255, 170, 170)
errLabel.Font = Enum.Font.Code
errLabel.TextSize = 9
errLabel.TextWrapped = true
errLabel.TextXAlignment = Enum.TextXAlignment.Left
errLabel.TextYAlignment = Enum.TextYAlignment.Top
errLabel.Text = "Log: Ready (Iron Sword)"
errLabel.Parent = holder
Instance.new("UICorner", errLabel).CornerRadius = UDim.new(0, 6)

local minimized = false
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(26, 20)
minBtn.Position = UDim2.fromOffset(172, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(55, 62, 80)
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 11
minBtn.Text = "-"
minBtn.Parent = frame
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(26, 20)
closeBtn.Position = UDim2.fromOffset(200, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(135, 42, 42)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Text = "X"
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local enabled = false
local lastAttack = 0
local lockedModel = nil

local function logMsg(msg)
	pcall(function()
		errLabel.Text = tostring(msg)
	end)
end

local function updateRangeLabel()
	rangeLabel.Text = string.format("Reach: %.1f", REACH_DISTANCE)
end

minusRangeBtn.Activated:Connect(function()
	REACH_DISTANCE = math.max(2.0, REACH_DISTANCE - 0.5)
	updateRangeLabel()
end)

plusRangeBtn.Activated:Connect(function()
	REACH_DISTANCE = math.min(20.0, REACH_DISTANCE + 0.5)
	updateRangeLabel()
end)

local function setNoclip(char, active)
	if not USE_NOCLIP or not char then
		return
	end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function()
				part.CanCollide = not active
			end)
		end
	end
end

local function updateBtn()
	if enabled then
		toggleBtn.Text = "ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(38, 155, 70)
		statusLabel.Text = "Status: Hunting..."
		logMsg("Log: Auto-equip Iron Sword active")
	else
		lockedModel = nil
		toggleBtn.Text = "OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(145, 45, 45)
		statusLabel.Text = "Status: OFF"
		setNoclip(player.Character, false)
	end
end

toggleBtn.Activated:Connect(function()
	enabled = not enabled
	updateBtn()
end)

minBtn.Activated:Connect(function()
	minimized = not minimized
	holder.Visible = not minimized
	frame.Size = minimized and UDim2.fromOffset(230, 32) or UDim2.fromOffset(230, 166)
	minBtn.Text = minimized and "+" or "-"
end)

closeBtn.Activated:Connect(function()
	enabled = false
	updateBtn()
	pcall(function()
		gui:Destroy()
	end)
end)

local function getMonsterParts(model)
	if not model or not model:IsA("Model") or not model.Parent then
		return nil, nil
	end
	local hum = model:FindFirstChildOfClass("Humanoid")
	local mRoot = model:FindFirstChild("HumanoidRootPart")
		or model.PrimaryPart
		or model:FindFirstChild("Torso")
		or model:FindFirstChild("UpperTorso")
		or model:FindFirstChild("Head")
	if hum and mRoot and hum.Health > 0 and mRoot:IsA("BasePart") then
		return mRoot, hum
	end
	return nil, nil
end

local function getMonsterSize(model, mRoot)
	local ok, size = pcall(function()
		return model:GetExtentsSize()
	end)
	if ok and typeof(size) == "Vector3" and size.Magnitude > 0 then
		return size
	end
	return mRoot.Size + Vector3.new(2, 4, 2)
end

local function pickTarget(fromPos)
	local folder = workspace:FindFirstChild("ActiveMonsters")
	if not folder then
		return nil, nil, nil
	end

	local bestModel, bestRoot, bestHum
	local bestScore = math.huge

	for _, child in ipairs(folder:GetChildren()) do
		local mRoot, hum = getMonsterParts(child)
		if mRoot and hum then
			local score = PRIORITIZE_LOW_HP and hum.Health or (mRoot.Position - fromPos).Magnitude
			if score < bestScore then
				bestScore = score
				bestModel = child
				bestRoot = mRoot
				bestHum = hum
			end
		end
	end

	return bestModel, bestRoot, bestHum
end

local function ensureSwordEquipped(char, hum)
	local backpack = player:FindFirstChild("Backpack")
	local preferredInBackpack = backpack and backpack:FindFirstChild(PREFERRED_TOOL)
	local preferredInChar = char:FindFirstChild(PREFERRED_TOOL)

	if preferredInChar and preferredInChar:IsA("Tool") then
		return preferredInChar
	end

	if preferredInBackpack and preferredInBackpack:IsA("Tool") then
		pcall(function()
			hum:EquipTool(preferredInBackpack)
		end)
		return preferredInBackpack
	end

	-- Fallback ke tool lain jika Iron Sword belum tersedia di Backpack/Character
	local equipped = char:FindFirstChildOfClass("Tool")
	if equipped then
		return equipped
	end

	if backpack then
		local fallback = backpack:FindFirstChildOfClass("Tool")
		if fallback then
			pcall(function()
				hum:EquipTool(fallback)
			end)
			return fallback
		end
	end

	return nil
end

local function getSmartAbovePos(targetModel, targetRoot)
	local mSize = getMonsterSize(targetModel, targetRoot)
	local halfHeight = mSize.Y * 0.5
	local halfWidth = math.max(mSize.X, mSize.Z) * 0.5

	local desiredHeight = halfHeight + EXTRA_CLEARANCE
	local maxHoriz = math.max(1.5, math.sqrt(math.max(1.0, (REACH_DISTANCE ^ 2) - (math.min(desiredHeight, REACH_DISTANCE - 1.0) ^ 2))))
	local horizDist = math.clamp(halfWidth + 1.5, 2.0, maxHoriz)

	local backDir = -targetRoot.CFrame.LookVector
	local flatBack = Vector3.new(backDir.X, 0, backDir.Z)
	if flatBack.Magnitude < 0.01 then
		flatBack = Vector3.new(0, 0, 1)
	else
		flatBack = flatBack.Unit
	end

	local aimPoint = targetRoot.Position + Vector3.new(0, math.max(0.5, halfHeight * 0.35), 0)
	local pos = targetRoot.Position
		+ Vector3.new(0, desiredHeight, 0)
		+ (flatBack * horizDist)

	return pos, aimPoint
end

RunService.Heartbeat:Connect(function()
	if not enabled then
		return
	end

	local ok, err = pcall(function()
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health <= 0 then
			return
		end

		setNoclip(char, true)

		local targetModel, targetRoot, targetHum
		if lockedModel then
			local mRoot, mHum = getMonsterParts(lockedModel)
			if mRoot and mHum then
				targetModel, targetRoot, targetHum = lockedModel, mRoot, mHum
			else
				lockedModel = nil
			end
		end

		if not targetModel then
			targetModel, targetRoot, targetHum = pickTarget(root.Position)
			lockedModel = targetModel
		end

		if not targetModel or not targetRoot or not targetHum then
			statusLabel.Text = "No active monsters"
			return
		end

		local pos, aimPoint = getSmartAbovePos(targetModel, targetRoot)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = CFrame.lookAt(pos, aimPoint)

		statusLabel.Text = string.format("%s (%.0f HP)", targetModel.Name, targetHum.Health)

		local now = os.clock()
		if now - lastAttack >= ATTACK_COOLDOWN then
			local tool = ensureSwordEquipped(char, hum)
			if tool and tool:IsA("Tool") then
				tool:Activate()
			end
			lastAttack = now
		end
	end)

	if not ok then
		logMsg("Err: " .. tostring(err))
	end
end)
