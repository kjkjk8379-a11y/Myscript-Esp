local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({ name = "ESP", subtitle = "كشف القاتل" })
local Tab = Window:CreateTab({ name = "الرئيسية" })

local espEnabled = false

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
        local esp = head.ESP
        local label = esp:FindFirstChildOfClass("TextLabel")
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

local function isKiller(character)
    local name = character.Name:lower()
    if name:find("killer") or name:find("murderer") then
        return true
    end
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            return true
        end
    end
    return false
end

local function inArena()
    local myChar = game.Players.LocalPlayer.Character
    if not myChar then return false end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end
    return myRoot.Position.Y > 50
end

Tab:CreateToggle({
    name = "تفعيل ESP (القاتل أحمر / الناجي أخضر)",
    currentValue = false,
    callback = function(value)
        espEnabled = value
        if not espEnabled then
            clearESP()
        end
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if not espEnabled then return end
    if not inArena() then return end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local char = player.Character
            local head = char:FindFirstChild("Head")
            if head and head:FindFirstChild("Humanoid") and head.Humanoid.Health > 0 then
                if isKiller(char) then
                    createESP(char, Color3.fromRGB(255, 0, 0), player.Name)
                else
                    createESP(char, Color3.fromRGB(0, 255, 0), player.Name)
                end
            end
        end
    end
end)
