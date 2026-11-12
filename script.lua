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
    {prefix = "CoilLabyrinth", name = "Coil Labyrinth"},
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
        return obj:GetPivot().Position
    end
    return nil
end

local function triggerInteraction(obj)
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
        return true
    end
    local click = obj:FindFirstChildWhichIsA("ClickDetector", true)
    if click then
        fireclickdetector(click)
        return true
    end
    return false
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
                for _, area in ipairs(areas) do
                    if not getgenv().AutoSpectral then break end
                    
                    for i = 1, 5 do
                        if not getgenv().AutoSpectral then break end
                        
                        local namaKunci = area.prefix .. "_Key" .. i
                        local namaPadlock = area.prefix .. "_Padlock" .. i
                        
                        -- 1. PROSES KUNCI
                        statusLabel.Text = "[" .. area.name .. "] Cari: Key " .. i
                        local kunciObj = Workspace:FindFirstChild(namaKunci, true)
                        
                        if kunciObj then
                            local posKunci = getPosition(kunciObj)
                            if posKunci and getgenv().AutoSpectral then
                                statusLabel.Text = "[" .. area.name .. "] TP Key " .. i
                                pcall(function()
                                    hrp.CFrame = CFrame.new(posKunci + Vector3.new(0, 3, 0))
                                end)
                                
                                -- Jeda sedikit lebih stabil agar game mendeteksi posisi dan sentuhan kunci
                                task.wait(0.4)
                                
                                if getgenv().AutoSpectral then
                                    triggerInteraction(kunciObj)
                                    pcall(function()
                                        -- Mengulang firetouchinterest beberapa kali agar kunci pasti terambil
                                        firetouchinterest(hrp, kunciObj, 0)
                                        task.wait(0.1)
                                        firetouchinterest(hrp, kunciObj, 1)
                                    end)
                                end
                                
                                local elapsed = 0
                                while elapsed < 5.0 do
                                    if not getgenv().AutoSpectral then break end
                                    statusLabel.Text = "[" .. area.name .. "] Jeda Key " .. i .. " (" .. math.ceil(5.0 - elapsed) .. "s)"
                                    task.wait(0.1)
                                    elapsed = elapsed + 0.1
                                end
                            end
                        else
                            statusLabel.Text = namaKunci .. " tdk ada!"
                            task.wait(1)
                        end
                        
                        if not getgenv().AutoSpectral then break end
                        
                        -- 2. PROSES PADLOCK
                        statusLabel.Text = "[" .. area.name .. "] Cari: Padlock " .. i
                        local padlockObj = Workspace:FindFirstChild(namaPadlock, true)
                        
                        if padlockObj then
                            local posPadlock = getPosition(padlockObj)
                            if posPadlock and getgenv().AutoSpectral then
                                statusLabel.Text = "[" .. area.name .. "] TP Padlock " .. i
                                pcall(function()
                                    hrp.CFrame = CFrame.new(posPadlock + Vector3.new(0, 3, 0))
                                end)
                                
                                task.wait(0.4)
                                
                                if getgenv().AutoSpectral then
                                    triggerInteraction(padlockObj)
                                end
                                
                                local elapsed = 0
                                while elapsed < 5.0 do
                                    if not getgenv().AutoSpectral then break end
                                    statusLabel.Text = "[" .. area.name .. "] Jeda Padlock " .. i .. " (" .. math.ceil(5.0 - elapsed) .. "s)"
                                    task.wait(0.1)
                                    elapsed = elapsed + 0.1
                                end
                            end
                        else
                            statusLabel.Text = namaPadlock .. " tdk ada!"
                            task.wait(1)
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
                            
                            -- Delay teleport ke portal diubah menjadi 13 detik
                            local elapsed = 0
                            while elapsed < 13.0 do
                                if not getgenv().AutoSpectral then break end
                                statusLabel.Text = "Portal " .. area.name .. " (" .. math.ceil(13.0 - elapsed) .. "s)"
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
