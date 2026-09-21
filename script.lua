local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({ name = "ESP", subtitle = "كشف القاتل" })
local Tab = Window:CreateTab({ name = "الرئيسية" })

local espEnabled = false
local killerName = nil

local function clearESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local hl = player.Character:FindFirstChild("ESP_Highlight")
            if hl then hl:Destroy() end
        end
    end
end

local function createESP(character, color)
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
    hl.FillColor = color
    hl.OutlineColor = color
end

local function detectKiller()
    -- الطريقة 1: HP عالي
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MaxHealth > 500 then
                return player.Name
            end
        end
    end

    -- الطريقة 2: أدوات
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            for _, obj in pairs(player.Character:GetChildren()) do
                if obj:IsA("Tool") then
                    return player.Name
                end
            end
        end
    end

    -- الطريقة 3: نص واجهة
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

Tab:CreateToggle({
    name = "تفعيل ESP (القاتل أحمر / الناجي أخضر)",
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
        task.wait(0.5)
        if espEnabled then
            local k = detectKiller()
            if k then killerName = k end
        end
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if not espEnabled then return end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if player.Name == killerName then
                    createESP(char, Color3.fromRGB(255, 0, 0))
                else
                    createESP(char, Color3.fromRGB(0, 255, 0))
                end
            end
        end
    end
end)
