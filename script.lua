local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({ name = "ESP", subtitle = "كشف القاتل" })
local Tab = Window:CreateTab({ name = "الرئيسية" })

local espEnabled = false
local killerName = nil

local function clearESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head and head:FindFirstChild("ESP") then
                head.ESP:Destroy()
            end
        end
    end
end

local function createESP(character, color, text)
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end
    if head:FindFirstChild("ESP") then
        local label = head.ESP:FindFirstChildOfClass("TextLabel")
        if label then
            label.Text = text
            label.TextColor3 = color
        end
        return
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Parent = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
end

-- كشف القاتل: 3 طرق
local function detectKiller()
    -- الطريقة 1: HP عالي (القاتل بالفورسيكن HP أكبر بكثير)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MaxHealth > 500 then
                return player.Name
            end
        end
    end

    -- الطريقة 2: أدوات مميزة بالشخصية
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            for _, obj in pairs(player.Character:GetChildren()) do
                if obj:IsA("Tool") then
                    return player.Name
                end
            end
        end
    end

    -- الطريقة 3: نص من واجهة اللعبة
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

-- نحدّث القاتل باستمرار
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
                    createESP(char, Color3.fromRGB(255, 0, 0), player.Name)
                else
                    createESP(char, Color3.fromRGB(0, 255, 0), player.Name)
                end
            end
        end
    end
end)
