local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({ name = "ESP", subtitle = "كشف القاتل" })
local Tab = Window:CreateTab({ name = "الرئيسية" })

local espEnabled = false
local killerName = nil
local roundActive = false

local RED = Color3.fromRGB(255, 0, 0)
local GREEN = Color3.fromRGB(0, 255, 0)

-- ═══ كشف الجولة بشكل صارم ═══
local function inRound()
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    -- نبحث عن نص الجولة (Round ends in / Round starts)
    local pg = lp:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, gui in pairs(pg:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Visible and gui.Text ~= "" then
                local t = gui.Text
                if t:find("Round ends") or t:find("Round starts") or t:find("round ends") then
                    return true
                end
            end
        end
    end

    -- نشوف إذا فيه قاتل موجود أصلاً (ما يظهر إلا بالجولة)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MaxHealth > 500 then
                return true
            end
        end
    end

    return false
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
        hl.FillTransparency = 0.7
        hl.OutlineTransparency = 0.3
        hl.DepthMode = Enum.HighlightDepthMode.Occluded
    end
    if hl.FillColor ~= color then
        hl.FillColor = color
        hl.OutlineColor = color
    end
end

local function detectKiller()
    -- HP عالي
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MaxHealth > 500 then
                return player.Name
            end
        end
    end
    -- أدوات
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
            roundActive = false
        end
    end
})

-- ═══ الحلقة ═══
task.spawn(function()
    while true do
        task.wait(0.6)
        if not espEnabled then continue end

        local nowInRound = inRound()

        -- إذا انتقلنا من اللوبي للجولة أو العكس
        if nowInRound ~= roundActive then
            roundActive = nowInRound
            clearESP()
            killerName = nil
        end

        if not roundActive then
            continue
        end

        local k = detectKiller()
        if k then killerName = k end
        refresh()
    end
end)
