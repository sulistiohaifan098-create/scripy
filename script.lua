local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

local playerGui = player.PlayerGui or player:WaitForChild("PlayerGui")
getgenv().AutoFarmFull = false

-- Daftar Full Stage
local areas = {
    {prefix = "SpectralPrison", name = "Spectral Prison"},
    {prefix = "SteamworksPrison", name = "Steamworks Prison"},
    {prefix = "SilentSanatorium", name = "Silent Sanatorium"},
    {prefix = "FrozenWard", name = "Frozen Ward"},
    {prefix = "BellGallery", name = "Bell Gallery"},
    {prefix = "ClockGallery", name = "Clock Gallery"},
    {prefix = "RootGarden", name = "Root Garden"},
    {prefix = "SunkenArchives", name = "Sunken Archives"}, -- Stage 8
    {prefix = "GildedHalls", name = "Gilded Halls"},       -- Stage 9
    {prefix = "AbyssalSanctum", name = "Abyssal Sanctum"}, -- Stage 10
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
statusLabel.Text = "Status: Idle (Fixed Key/Padlock TP)"
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

-- Fungsi pencarian fleksibel untuk Kunci, Padlock, dan Portal
local function findTargetObject(prefix, keyword, index)
    -- 1. Coba cari dengan format standar baku
    local targetName = prefix .. "_" .. keyword .. index
    local obj = Workspace:FindFirstChild(targetName, true)
    if obj then return obj end
    
    -- 2. Jika tidak ketemu, cari secara fleksibel berdasarkan kata kunci di Workspace
    for _, item in ipairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(item.Name)
        local prefixLower = string.lower(prefix)
        if nameLower:find(prefixLower) and nameLower:find(string.lower(keyword)) then
            -- Jika ada angka index-nya atau cocok
            if nameLower:find(tostring(index)) or not item:IsA("Model") then
                return item
            end
        end
    end
    
    -- 3. Fallback terakhir: cari objek apa saja yang mengandung keyword di Workspace
    for _, item in ipairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(item.Name)
        if nameLower == string.lower(keyword) or nameLower:find(string.lower(keyword) .. tostring(index)) then
            return item
        end
    end
    
    return nil
end

toggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarmFull = not getgenv().AutoFarmFull
    if getgenv().AutoFarmFull then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
        toggleBtn.Text = "AUTO SCRIPT: ON"
        statusLabel.Text = "Status: Memulai Auto Farm..."
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
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                for index, area in ipairs(areas) do
                    if not getgenv().AutoFarmFull then break end
                    
                    local delayItem = (index >= 8) and 10.0 or 2.0
                    
                    for i = 1, 5 do
                        if not getgenv().AutoFarmFull then break end
                        
                        -- 1. Proses Kunci dengan pencarian fleksibel
                        local kunciBerhasil = false
                        local percobaanKunci = 0
                        local maxPercobaan = (i == 3) and 5 or 3
                        
                        while not kunciBerhasil and getgenv().AutoFarmFull and percobaanKunci < maxPercobaan do
                            percobaanKunci = percobaanKunci + 1
                            statusLabel.Text = "[" .. area.name .. "] Key " .. i .. " (Coba " .. percobaanKunci .. ")"
                            
                            local kunciObj = findTargetObject(area.prefix, "Key", i)
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
                                task.wait(0.4)
                            end
                        end
                        
                        if not getgenv().AutoFarmFull then break end
                        
                        -- Jeda setelah Kunci (2s atau 10s)
                        local elapsed = 0
                        while elapsed < delayItem do
                            if not getgenv().AutoFarmFull then break end
                            statusLabel.Text = "[" .. area.name .. "] Jeda Key " .. i .. " (" .. math.ceil(delayItem - elapsed) .. "s)"
                            task.wait(0.1)
                            elapsed = elapsed + 0.1
                        end
                        
                        if not getgenv().AutoFarmFull then break end
                        
                        -- 2. Proses Padlock dengan pencarian fleksibel
                        local padlockBerhasil = false
                        local percobaanPadlock = 0
                        
                        while not padlockBerhasil and getgenv().AutoFarmFull and percobaanPadlock < 3 do
                            percobaanPadlock = percobaanPadlock + 1
                            statusLabel.Text = "[" .. area.name .. "] Padlock " .. i .. " (Coba " .. percobaanPadlock .. ")"
                            
                            local padlockObj = findTargetObject(area.prefix, "Padlock", i)
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
                                task.wait(0.4)
                            end
                        end
                        
                        if not getgenv().AutoFarmFull then break end
                        
                        -- Jeda setelah Padlock (2s atau 10s)
                        elapsed = 0
                        while elapsed < delayItem do
                            if not getgenv().AutoFarmFull then break end
                            statusLabel.Text = "[" .. area.name .. "] Jeda Padlock " .. i .. " (" .. math.ceil(delayItem - elapsed) .. "s)"
                            task.wait(0.1)
                            elapsed = elapsed + 0.1
                        end
                        
                        if not getgenv().AutoFarmFull then break end
                    end
                    
                    if not getgenv().AutoFarmFull then break end
                    
                    -- Cari Exit Portal
                    statusLabel.Text = "Cari Portal di " .. area.name
                    local exitObj = findTargetObject(area.prefix, "ExitPortal", "")
                    if not exitObj then
                        exitObj = findTargetObject(area.prefix, "Portal", "")
                    end
                    
                    if exitObj then
                        local posExit = getPosition(exitObj)
                        if posExit and getgenv().AutoFarmFull then
                            statusLabel.Text = "TP ke Portal " .. area.name
                            pcall(function() hrp.CFrame = CFrame.new(posExit + Vector3.new(0, 3, 0)) end)
                            task.wait(0.4)
                            if getgenv().AutoFarmFull then triggerInteraction(exitObj) end
                            
                            -- Jeda portal 17 detik
                            local elapsed = 0
                            while elapsed < 17.0 do
                                if not getgenv().AutoFarmFull then break end
                                statusLabel.Text = "Portal " .. area.name .. " (" .. math.ceil(17.0 - elapsed) .. "s)"
                                task.wait(0.1)
                                elapsed = elapsed + 0.1
                            end
                        end
                    else
                        statusLabel.Text = "Portal " .. area.name .. " tidak ditemukan, lanjut..."
                        task.wait(2.0)
                    end
                end
                
                -- Selesai Full Stage -> Rejoin Otomatis
                statusLabel.Text = "Selesai Full Stage -> Rejoin..."
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
