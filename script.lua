local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({ name = "ESP", subtitle = "ÙƒØ´Ù Ø§Ù„Ù‚Ø§ØªÙ„" })
local Tab = Window:CreateTab({ name = "Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©" })

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
    name = "ØªÙØ¹ÙŠÙ„ ESP",
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
        if not inArena() then
            clearESP()
            killerName = nil
            continue
        end
        if not iAmAlive() then
            clearESP()
            killerName = nil
            continue
        end
        local k = getKiller()
        if k then killerName = k end
        if killerName then refresh() end
    end
end)

-- ==========================================
-- Generator Proximity Auto-Complete
-- ==========================================

local AutoGenEnabled = false
local GenDelay = 3.5

-- Proximity radius â€” tune if needed
local ENTER_RADIUS = 12

-- Returns the root part position of local player
local function getPlayerPos()
    local char = game.Players.LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    return root.Position
end

-- Returns all generator objects under workspace.Map.Ingame.Map
local function getGenerators()
    local ok, mapChildren = pcall(function()
        return workspace.Map.Ingame.Map:GetChildren()
    end)
    if not ok then return {} end
    local gens = {}
    for _, child in ipairs(mapChildren) do
        local remotes = child:FindFirstChild("Remotes")
        if remotes and remotes:FindFirstChild("RE") and remotes:FindFirstChild("RF") then
            table.insert(gens, child)
        end
    end
    return gens
end

-- Returns the closest generator within ENTER_RADIUS, or nil
local function getNearestGenerator()
    local pos = getPlayerPos()
    if not pos then return nil end
    local gens = getGenerators()
    local closest = nil
    local closestDist = ENTER_RADIUS

    for _, gen in ipairs(gens) do
        -- Use PrimaryPart or first BasePart for position
        local part = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
        if part then
            local dist = (pos - part.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = gen
            end
        end
    end
    return closest
end

local currentGen = nil  -- generator we're currently inside
local enteredGen = false

task.spawn(function()
    while true do
        task.wait(0.1)
        if not AutoGenEnabled then
            currentGen = nil
            enteredGen = false
            continue
        end

        local nearby = getNearestGenerator()

        if nearby and nearby ~= currentGen then
            -- Entered a new generator zone
            currentGen = nearby
            enteredGen = true
            local rf = nearby.Remotes.RF
            pcall(function()
                rf:InvokeServer("Enter")
            end)
            print("[AutoGen] Entered generator:", nearby.Name)

        elseif not nearby and currentGen then
            -- Left the generator zone
            print("[AutoGen] Left generator:", currentGen.Name)
            currentGen = nil
            enteredGen = false
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(GenDelay)
        if not AutoGenEnabled then continue end
        if not currentGen or not enteredGen then continue end

        local re = currentGen.Remotes.RE
        pcall(function()
            re:FireServer()
        end)
        print("[AutoGen] Fired RE on:", currentGen.Name)
    end
end)

local GeneratorsTab = Window:CreateTab({ Name = "Generators", Icon = 4483362458 })

GeneratorsTab:CreateToggle({
    Name = "Loop complete current puzzle",
    CurrentValue = false,
    Flag = "AutoPuzzle_Toggle",
    Callback = function(Value)
        AutoGenEnabled = Value
        if not Value then
            currentGen = nil
            enteredGen = false
        end
    end,
})

GeneratorsTab:CreateSlider({
    Name = "Wait after doing a puzzle",
    Range = {0, 10},
    Increment = 0.5,
    Suffix = "seconds",
    CurrentValue = 3.5,
    Flag = "PuzzleDelay_Slider",
    Callback = function(Value)
        GenDelay = Value
    end,
})
