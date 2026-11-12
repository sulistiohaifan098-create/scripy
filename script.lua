local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

local playerGui = player.PlayerGui or player:WaitForChild("PlayerGui")
getgenv().AutoFarmFull = false

local areas = {
    {prefix = "SpectralPrison", name = "Spectral Prison"},
    {prefix = "SteamworksPrison", name = "Steamworks Prison"},
    {prefix = "SilentSanatorium", name = "Silent Sanatorium"},
    {prefix = "FrozenWard", name = "Frozen Ward"},
    {prefix = "BellGallery", name = "Bell Gallery"},
    {prefix = "ClockGallery", name = "Clock Gallery"},
    {prefix = "RootGarden", name = "Root Garden"},
}

if playerGui:FindFirstChild("AutoFarmFullGui") then
    playerGui.AutoFarmFullGui:Destroy()
end

-- Membuat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmFullGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Membuat Frame Utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 110)
mainFrame.Position = UDim2.new(0.5, -120, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Label Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 35)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle (Siap Lobi & Farm)"
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Tombol ON/OFF
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 45)
toggleBtn.Position = UDim2.new(0, 10, 0, 55)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
toggleBtn.Text = "AUTO SCRIPT: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

local function getPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        local success, pivot = pcall(function() return obj:GetPivot().Position end)
        if success and pivot then return pivot end
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local part = obj:FindFirstChildWhichIsA("BasePart", true)
        if part then return part.Position end
    end
    return nil
end

local function triggerInteraction(obj)
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then pcall(function() fireproximityprompt(prompt) end) end
    local click = obj:FindFirstChildWhichIsA("ClickDetector", true)
    if click then pcall(function() fireclickdetector(click) end) end
end

-- Fungsi otomatisasi lobi (TP ke 601, 4, 322 -> Setup PartyUI -> CreateParty -> StartNow)
local function runLobbySetup()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    statusLabel.Text = "Lobi: TP ke koordinat (601, 4, 322)..."
    pcall(function()
        hrp.CFrame = CFrame.new(601, 4, 322)
    end)
    task.wait(1.5)

    -- Cari trigger / proximity prompt di sekitar lobi atau interaksi area
    statusLabel.Text = "Lobi: Berinteraksi dengan area..."
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not getgenv().AutoFarmFull then break end
        local nameLower = string.lower(obj.Name)
        if nameLower:find("create") or nameLower:find("party") or nameLower:find("gate") then
            local pos = getPosition(obj)
            if pos and (pos - hrp.Position).Magnitude < 15 then
                triggerInteraction(obj)
                pcall(function()
                    firetouchinterest(hrp, obj, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, obj, 1)
                end)
            end
        end
    end
    task.wait(1.0)

    -- Mengatur PartyUI (Difficulty Easy, Players 1, Monster 3) berdasarkan struktur Dex
    statusLabel.Text = "Lobi: Mengatur Easy, 1 Player, 3 Monsters..."
    local partyUI = playerGui:FindFirstChild("PartyUI")
    if partyUI then
        -- Cari tombol-tombol terkait pengaturan di dalam Fields / Body / CreateWindow
        for _, descendant in ipairs(partyUI:GetDescendants()) do
            if not getgenv().AutoFarmFull then break end
            if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                local textLower = string.lower(descendant.Text or "")
                local nameLower = string.lower(descendant.Name)
                
                if textLower:find("easy") or textLower:find("1") or textLower:find("solo") or textLower:find("3") or
                   nameLower:find("easy") or nameLower:find("1") or nameLower:find("solo") or nameLower:find("3") then
                    pcall(function()
                        if getconnections then
                            for _, conn in ipairs(getconnections(descendant.MouseButton1Click)) do conn:Fire() end
                            for _, conn in ipairs(getconnections(descendant.Activated)) do conn:Fire() end
                        end
                    end)
                    task.wait(0.2)
                end
            end
        end
        
        -- Klik CreateParty
        statusLabel.Text = "Lobi: Mengklik Create Party..."
        local createPartyBtn = partyUI:FindFirstChild("CreateParty", true)
        if createPartyBtn and (createPartyBtn:IsA("GuiButton") or createPartyBtn:IsA("ImageButton")) then
            pcall(function()
                if getconnections then
                    for _, conn in ipairs(getconnections(createPartyBtn.MouseButton1Click)) do conn:Fire() end
                    for _, conn in ipairs(getconnections(createPartyBtn.Activated)) do conn:Fire() end
                end
            end)
        end
        task.wait(1.0)

        -- Klik StartNow
        statusLabel.Text = "Lobi: Mengklik Start Now..."
        local startNowBtn = partyUI:FindFirstChild("StartNow", true)
        if startNowBtn and (startNowBtn:IsA("GuiButton") or startNowBtn:IsA("ImageButton")) then
            pcall(function()
                if getconnections then
                    for _, conn in ipairs(getconnections(startNowBtn.MouseButton1Click)) do conn:Fire() end
                    for _, conn in ipairs(getconnections(startNowBtn.Activated)) do conn:Fire() end
                end
            end)
        end
    end
    task.wait(2.0)
end

toggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarmFull = not getgenv().AutoFarmFull
    if getgenv().AutoFarmFull then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
        toggleBtn.Text = "AUTO SCRIPT: ON"
        statusLabel.Text = "Status: Memulai Lobi..."
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        toggleBtn.Text = "AUTO SCRIPT: OFF"
        statusLabel.Text = "Status: Berhenti"
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if getgenv().AutoFarmFull then
            -- Jalankan setup lobi terlebih dahulu
            runLobbySetup()
            
            if not getgenv().AutoFarmFull then break end
            statusLabel.Text = "Status: Memulai Auto Farm Stage 1-7..."
            
            -- Proses Auto Farm Stage 1-7
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                for index, area in ipairs(areas) do
                    if not getgenv().AutoFarmFull then break end
                    
                    for i = 1, 5 do
                        if not getgenv().AutoFarmFull then break end
                        
                        local namaKunci = area.prefix .. "_Key" .. i
                        local namaPadlock = area.prefix .. "_Padlock" .. i
                        
                        -- 1. Proses Kunci
                        local kunciBerhasil = false
                        local percobaanKunci = 0
                        local maxPercobaan = (i == 3) and 5 or 3
                        
                        while not kunciBerhasil and getgenv().AutoFarmFull and percobaanKunci < maxPercobaan do
                            percobaanKunci = percobaanKunci + 1
                            statusLabel.Text = "[" .. area.name .. "] Key " .. i .. " (Coba " .. percobaanKunci .. ")"
                            
                            local kunciObj = Workspace:FindFirstChild(namaKunci, true)
                            if kunciObj then
                                local posKunci = getPosition(kunciObj)
                                if posKunci then
                                    pcall(function() hrp.CFrame = CFrame.new(posKunci + Vector3.new(0, 3, 0)) end)
                                    task.wait(0.3)
                                    triggerInteraction(kunciObj)
                                    pcall(function()
                                        firetouchinterest(hrp, kunciObj, 0)
                                        task.wait(0.1)
                                        firetouchinterest(hrp, kunciObj, 1)
                                    end)
                                    
                                    if not kunciObj.Parent or not kunciObj:IsDescendantOf(Workspace) then
                                        kunciBerhasil = true
                                    else
                                        task.wait(0.3)
                                    end
                                end
                            else
                                task.wait(0.3)
                            end
                        end
                        
                        if not getgenv().AutoFarmFull then break end
                        
                        -- 2. Proses Padlock (Tanpa jeda dari Key ke Padlock)
                        local padlockBerhasil = false
                        local percobaanPadlock = 0
                        
                        while not padlockBerhasil and getgenv().AutoFarmFull and percobaanPadlock < 3 do
                            percobaanPadlock = percobaanPadlock + 1
                            statusLabel.Text = "[" .. area.name .. "] Padlock " .. i .. " (Coba " .. percobaanPadlock .. ")"
                            
                            local padlockObj = Workspace:FindFirstChild(namaPadlock, true)
                            if padlockObj then
                                local posPadlock = getPosition(padlockObj)
                                if posPadlock then
                                    pcall(function() hrp.CFrame = CFrame.new(posPadlock + Vector3.new(0, 3, 0)) end)
                                    task.wait(0.3)
                                    triggerInteraction(padlockObj)
                                    
                                    if not padlockObj.Parent or not padlockObj:IsDescendantOf(Workspace) then
                                        padlockBerhasil = true
                                    else
                                        task.wait(0.3)
                                    end
                                end
                            else
                                task.wait(0.3)
                            end
                        end
                        
                        if not getgenv().AutoFarmFull then break end
                    end
                    
                    if not getgenv().AutoFarmFull then break end
                    local exitName = area.prefix .. "_ExitPortal"
                    statusLabel.Text = "Cari " .. exitName
                    local exitObj = Workspace:FindFirstChild(exitName, true)
                    
                    if exitObj then
                        local posExit = getPosition(exitObj)
                        if posExit and getgenv().AutoFarmFull then
                            statusLabel.Text = "TP ke " .. exitName
                            pcall(function() hrp.CFrame = CFrame.new(posExit + Vector3.new(0, 3, 0)) end)
                            task.wait(0.4)
                            if getgenv().AutoFarmFull then triggerInteraction(exitObj) end
                            
                            -- Jeda portal aman 17 detik
                            local elapsed = 0
                            while elapsed < 17.0 do
                                if not getgenv().AutoFarmFull then break end
                                statusLabel.Text = "Portal " .. area.name .. " (" .. math.ceil(17.0 - elapsed) .. "s)"
                                task.wait(0.1)
                                elapsed = elapsed + 0.1
                            end
                        end
                    end
                end
                
                -- Selesai Stage 7 -> Rejoin Otomatis
                statusLabel.Text = "Selesai Stage 7 -> Rejoin..."
                task.wait(1)
                pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
                getgenv().AutoFarmFull = false
                break
            else
                statusLabel.Text = "Error: Karakter tidak ada!"
                task.wait(1)
            end
        end
    end
end)
