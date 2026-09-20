local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window = Rayfield:CreateWindow({ name = "ESP", subtitle = "كشف اللاعبين" })
local Tab = Window:CreateTab({ name = "الرئيسية" })

local espEnabled = false

local function createESP(character, color, text)
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end
    if head:FindFirstChild("ESP") then return end
    
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

Tab:CreateToggle({
    name = "تفعيل ESP",
    currentValue = false,
    callback = function(value)
        espEnabled = value
        if not espEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head and head:FindFirstChild("ESP") then
                        head.ESP:Destroy()
                    end
                end
            end
        end
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if not espEnabled then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local color = Color3.fromRGB(0, 255, 0)
            local text = player.Name
            createESP(player.Character, color, text)
        end
    end
end)
