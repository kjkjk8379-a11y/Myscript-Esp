local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({ name = "ESP", subtitle = "كشف Survivors و Killer" })
local Tab = Window:CreateTab({ name = "الرئيسية" })
local espEnabled = false

local function createESP(character, color)
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if root:FindFirstChild("ESP") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP"
    highlight.Parent = root
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
end

local function isKiller(character)
    local name = character.Name:lower()
    if name:find("killer") or name:find("murderer") then return true end
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then return true end
    end
    return false
end

Tab:CreateToggle({
    name = "تفعيل ESP",
    currentValue = false,
    callback = function(value) espEnabled = value end
})

game:GetService("RunService").RenderStepped.Conncet(function()
    if not espEnabled then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local color
            if isKiller(player.Character) then
                color = Color3.fromRGB(255, 0, 0)
            else
                color = Color3.fromRGB(0, 255, 0)
            end
            createESP(player.Character, color)
        end
    end
end)
