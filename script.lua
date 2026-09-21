local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({ name = "ESP", subtitle = "كشف القاتل" })
local Tab = Window:CreateTab({ name = "الرئيسية" })

local espEnabled = false
local killerName = nil

local RED = Color3.fromRGB(255, 0, 0)
local GREEN = Color3.fromRGB(0, 255, 0)

local function inRound()
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local pg = lp:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, gui in pairs(pg:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Visible and gui.Text ~= "" then
                if gui.Text:find("Round ends") or gui.Text:find("Round starts") then
                    return true
                end
            end
        end
    end
    return hrp.Position.Y > 30
end

local function clearESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local b = player.Character:FindFirstChild("ESP_Box")
            if b then b:Destroy() end
        end
    end
end

local function applyColor(character, color)
    if not character then return end
    local box = character:FindFirstChild("ESP_Box")
    if not box then
        box = Instance.new("SelectionBox")
        box.Name = "ESP_Box"
        box.Adornee = character
        box.LineThickness = 0.05
        box.SurfaceTransparency = 1
        box.Transparency = 0.5
        box.Parent = character
    end
    if box.Color3 ~= color then
        box.Color3 = color
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
    return nil
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

-- تحديث كل 1.2 ثانية، وكل شي مرة وحدة
task.spawn(function()
    while true do
        task.wait(1.2)
        if not espEnabled then continue end

        if not inRound() then
            clearESP()
            killerName = nil
            continue
        end

        local k = detectKiller()
        if k then killerName = k end
        refresh()
    end
end)
