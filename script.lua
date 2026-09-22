local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({ name = "ESP", subtitle = "كشف القاتل" })
local Tab = Window:CreateTab({ name = "الرئيسية" })

local espEnabled = false
local killerName = nil

local RED = Color3.fromRGB(255, 0, 0)
local GREEN = Color3.fromRGB(0, 255, 0)

local function getKiller()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MaxHealth > 500 and hum.Health > 0 then
                return player.Name
            end
        end
    end
    return nil
end

-- الساحة = AbilityContainer موجود (زر Punch/Block)
local function inArena()
    local pg = game.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pg then return false end
    local mainUI = pg:FindFirstChild("MainUI")
    if not mainUI then return false end
    local ability = mainUI:FindFirstChild("AbilityContainer")
    return ability ~= nil and ability.Visible
end

local function iAmAlive()
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if workspace.CurrentCamera.CameraSubject ~= hum then return false end
    return true
end

local function clearESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local hl = player.Character:FindFirstChild("ESP_Highlight")
            if hl then hl:Destroy() end
        end
    end
end

local function applyColor(character, color)
    if not character then return end
    local hl = character:FindFirstChild("ESP_Highlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "ESP_Highlight"
        hl.Parent = character
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    if hl.FillColor ~= color then
        hl.FillColor = color
        hl.OutlineColor = color
    end
end

local function refresh()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if player.Name == killerName then
                    applyColor(char, RED)
                else
                    applyColor(char, GREEN)
                end
            end
        end
    end
end

Tab:CreateToggle({
    name = "تفعيل ESP",
    currentValue = false,
    callback = function(value)
        espEnabled = value
        if not espEnabled then
            clearESP()
            killerName = nil
        end
    end
})

task.spawn(function()
    while true do
        task.wait(0.3)
        if not espEnabled then continue end

        -- 1) لازم بالساحة (AbilityContainer)
        if not inArena() then
            clearESP()
            killerName = nil
            continue
        end

        -- 2) لازم حي ومو سپكتيت
        if not iAmAlive() then
            clearESP()
            killerName = nil
            continue
        end

        -- 3) القاتل
        local k = getKiller()
        if k then
            killerName = k
        end

        if killerName then
            refresh()
        end
    end
end)

local function SolveCurrentPuzzle()
    local RS = game:GetService("ReplicatedStorage")
    local puzzleRemote = RS:FindFirstChild("SolvePuzzle")
    
    if not puzzleRemote then
        -- Print all children so we can find the real remote name
        print("=== ReplicatedStorage children ===")
        for _, v in pairs(RS:GetChildren()) do
            print(v.ClassName, v.Name)
        end
        return
    end
    
    puzzleRemote:FireServer()
end
