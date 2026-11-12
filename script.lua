local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Tunggu sampai PlayerGui siap
local playerGui = player:WaitForChild("PlayerGui")

getgenv().AutoSpectral = false

-- Daftar Area / Dunia secara berurutan
local areas = {
    {prefix = "SpectralPrison", name = "Spectral Prison"},
    {prefix = "SteamworksPrison", name = "Steamworks Prison"},
    {prefix = "SilentSanatorium", name = "Silent Sanatorium"},
    {prefix = "FrozenWard", name = "Frozen Ward"},
    {prefix = "BellGallery", name = "Bell Gallery"},
    {prefix = "ClockGallery", name = "Clock Gallery"},
    {prefix = "RootGarden", name = "Root Garden"},
    {prefix = "CoilLabyrinth", name = "Coil Labyrinth"}, -- Index 8 (Stage 8)
    {prefix = "WatchfulArchive", name = "Watchful Archive"},
    {prefix = "PrisonHeart", name = "Prison Heart"},
    {prefix = "LostSands", name = "Lost Sands"},
    {prefix = "ChainAbyss", name = "Chain Abyss"},
}

-- Hapus GUI lama jika ada agar tidak menumpuk
if playerGui:FindFirstChild("MultiAreaAutoGui") then
    playerGui.MultiAreaAutoGui:Destroy()
end

-- Membuat UI & Label Status
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MultiAreaAutoGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 125)
mainFrame.Position = UDim2.new(0.5, -120, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Multi-Area Auto Teleport"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0, 25)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 55)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
toggleBtn.Text = "STATUS: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

local function getPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        local success, pivot = pcall(function() return obj:GetPivot().Position end)
        if success and pivot then
            return pivot
        elseif obj.PrimaryPart then
            return obj.PrimaryPart.Position
        else
            local part = obj:FindFirstChildWhichIsA("BasePart", true)
            if part then return part.Position end
        end
    end
    return nil
end

local function triggerInteraction(obj)
    local success = false
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        pcall(function()
            fireproximityprompt(prompt)
            success = true
        end)
    end
    local click = obj:FindFirstChildWhichIsA("ClickDetector", true)
    if click then
        pcall(function()
            fireclickdetector(click)
            success = true
        end)
    end
    return success
end

toggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoSpectral = not getgenv().AutoSpectral
    if getgenv().AutoSpectral then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
        toggleBtn.Text = "STATUS: ON"
        statusLabel.Text = "Status: Running..."
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        toggleBtn.Text = "STATUS: OFF"
        statusLabel.Text = "Status: Stopped"
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if getgenv().AutoSpectral then
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                for index, area in ipairs(areas) do
                    if not getgenv().AutoSpectral then break end
                    
                    local delayItem = (index <= 7) and 2.0 or 5.0
                    
                    for i = 1, 5 do
                        if not getgenv().AutoSpectral then break end
                        
                        local namaKunci = area.prefix .. "_Key" .. i
                        local namaPadlock = area.prefix .. "_Key" .. i -- (Placeholder aman)
                        namaPadlock = area.prefix .. "_Padlock" .. i
                        
                        -- 1. PROSES KUNCI
                        local kunciBerhasil = false
                        local percobaanKunci = 0
                        local maxPercobaan = (i == 3) and 5 or 3
                        
                        while not kunciBerhasil and getgenv().AutoSpectral and percobaanKunci < maxPercobaan do
                            percobaanKunci = percobaanKunci + 1
                            statusLabel.Text = "[" .. area.name .. "] Key " .. i .. " (Coba " .. percobaanKunci .. ")"
                            
                            local kunciObj = Workspace:FindFirstChild(namaKunci, true)
                            if kunciObj then
                                local posKunci = getPosition(kunciObj)
                                if posKunci then
                                    pcall(function()
                                        -- KHUSUS STAGE 8 KE ATAS (TERUTAMA KUNCI 3): Berikan sedikit elevasi tinggi (Y + 5) 
                                        -- agar karakter tidak langsung tertanam di dalam tembok/lantai pembatas
                                        local tinggiTP = (index >= 8 and i == 3) and 6 or 3
                                        hrp.CFrame = CFrame.new(posKunci + Vector3.new(0, tinggiTP, 0))
                                    end)
                                    
                                    -- Waktu tunggu ekstra khusus stage 8+ kunci ke-3 agar game tidak mendeteksi noclip instan
                                    local waitTime = (index >= 8 and i == 3) and 1.0 or (index <= 7 and 0.3 or 0.6)
                                    task.wait(waitTime)
                                    
                                    triggerInteraction(kunciObj)
                                    pcall(function()
                                        firetouchinterest(hrp, kunciObj, 0)
                                        task.wait(0.1)
                                        firetouchinterest(hrp, kunciObj, 1)
                                    end)
                                    
                                    if not kunciObj.Parent or not kunciObj:IsDescendantOf(Workspace) then
                                        kunciBerhasil = true
                                    else
                                        task.wait(0.6)
                                    end
                                end
                            else
                                task.wait(0.8)
                            end
                        end
                        
                        if not getgenv().AutoSpectral then break end
                        
                        -- Jeda dinamis setelah kunci
                        local elapsed = 0
                        while elapsed < delayItem do
                            if not getgenv().AutoSpectral then break end
                            statusLabel.Text = "[" .. area.name .. "] Jeda Key " .. i .. " (" .. math.ceil(delayItem - elapsed) .. "s)"
                            task.wait(0.1)
                            elapsed = elapsed + 0.1
                        end
                        
                        if not getgenv().AutoSpectral then break end
                        
                        -- 2. PROSES PADLOCK
                        local padlockBerhasil = false
                        local percobaanPadlock = 0
                        
                        while not padlockBerhasil and getgenv().AutoSpectral and percobaanPadlock < 3 do
                            percobaanPadlock = percobaanPadlock + 1
                            statusLabel.Text = "[" .. area.name .. "] Padlock " .. i .. " (Coba " .. percobaanPadlock .. ")"
                            
                            local padlockObj = Workspace:FindFirstChild(namaPadlock, true)
                            if padlockObj then
                                local posPadlock = getPosition(padlockObj)
                                if posPadlock then
                                    pcall(function()
                                        local tinggiTPPadlock = (index >= 8 and i == 3) and 6 or 3
                                        hrp.CFrame = CFrame.new(posPadlock + Vector3.new(0, tinggiTPPadlock, 0))
                                    end)
                                    task.wait(index <= 7 and 0.3 or 0.6)
                                    
                                    triggerInteraction(padlockObj)
                                    
                                    if not padlockObj.Parent or not padlockObj:IsDescendantOf(Workspace) then
                                        padlockBerhasil = true
                                    else
                                        task.wait(0.5)
                                    end
                                end
                            else
                                task.wait(0.5)
                            end
                        end
                        
                        if not getgenv().AutoSpectral then break end
                        
                        elapsed = 0
                        while elapsed < delayItem do
                            if not getgenv().AutoSpectral then break end
                            statusLabel.Text = "[" .. area.name .. "] Jeda Padlock " .. i .. " (" .. math.ceil(delayItem - elapsed) .. "s)"
                            task.wait(0.1)
                            elapsed = elapsed + 0.1
                        end
                        
                        if not getgenv().AutoSpectral then break end
                    end
                    
                    if not getgenv().AutoSpectral then break end
                    local exitName = area.prefix .. "_ExitPortal"
                    statusLabel.Text = "Cari " .. exitName
                    local exitObj = Workspace:FindFirstChild(exitName, true)
                    
                    if exitObj then
                        local posExit = getPosition(exitObj)
                        if posExit and getgenv().AutoSpectral then
                            statusLabel.Text = "TP ke " .. exitName
                            pcall(function()
                                hrp.CFrame = CFrame.new(posExit + Vector3.new(0, 3, 0))
                            end)
                            
                            task.wait(0.4)
                            if getgenv().AutoSpectral then
                                triggerInteraction(exitObj)
                            end
                            
                            local elapsed = 0
                            while elapsed < 17.0 do
                                if not getgenv().AutoSpectral then break end
                                statusLabel.Text = "Portal " .. area.name .. " (" .. math.ceil(17.0 - elapsed) .. "s)"
                                task.wait(0.1)
                                elapsed = elapsed + 0.1
                            end
                        end
                    end
                end
                
                getgenv().AutoSpectral = false
                toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
                toggleBtn.Text = "STATUS: OFF"
                statusLabel.Text = "Status: Semua Area Selesai!"
            else
                statusLabel.Text = "Error: Karakter tidak ditemukan!"
                    task.wait(1)
            end
        end
    end
end)
