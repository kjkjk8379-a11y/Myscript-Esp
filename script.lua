local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({ name = "ESP", subtitle = "كشف القاتل" })
local Tab = Window:CreateTab({ name = "الرئيسية" })

local espEnabled = false
local killerName = nil

local RED = Color3.fromRGB(255, 0, 0)
local GREEN = Color3.fromRGB(0, 255, 0)

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

local function detectKiller()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MaxHealth > 500 then
                return player.Name
            end
        end
    end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            for _, obj in pairs(player.Character:GetChildren()) do
                if obj:IsA("Tool") then
                    return player.Name
                end
            end
        end
    end
    local pg = game.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, gui in pairs(pg:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Visible and gui.Text ~= "" then
                local t = gui.Text
                if t:lower():find("killer") or t:find("قاتل") then
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if t:find(player.Name) then
                            return player.Name
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- دورة وحدة تمسح كل اللاعبين كل 0.4 ثانية
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
    name = "تفعيل ESP (القاتل أحمر / الناجي أخضر)",
    currentValue = false,
    callback = function(value)
        espEnabled = value
        if not espEnabled then
            clearESP()
            killerName = nil
        else
            task.spawn(refresh)
        end
    end
})

-- تحديث كل 0.4 ثانية بدل كل فريم
task.spawn(function()
    while true do
        task.wait(0.4)
        if espEnabled then
            local k = detectKiller()
            if k and k ~= killerName then
                killerName = k
            end
            refresh()
        end
    end
end)
