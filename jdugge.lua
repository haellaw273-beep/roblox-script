local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RS               = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

if pg:FindFirstChild("InfStaminaUI") then
    pg:FindFirstChild("InfStaminaUI"):Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name="InfStaminaUI"; sg.ResetOnSpawn=false
sg.IgnoreGuiInset=true; sg.DisplayOrder=200; sg.Parent=pg

local function corner(p,r) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r or 8) end

-- ════ UI เล็กๆ ════
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,110,0,32)
btn.Position=UDim2.new(0,10,0.5,0)
btn.BackgroundColor3=Color3.fromRGB(15,60,25)
btn.Text="⚡ Stamina: ปิด"
btn.TextColor3=Color3.fromRGB(80,255,140)
btn.TextSize=11; btn.Font=Enum.Font.GothamBold
btn.BorderSizePixel=0; btn.ZIndex=20; btn.Parent=sg
corner(btn,16)
local s=Instance.new("UIStroke",btn)
s.Color=Color3.fromRGB(60,200,100); s.Thickness=1.5

-- Drag
do
    local dg,ds,sp=false,nil,nil
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dg=true;ds=i.Position;sp=btn.Position end end)
    UserInputService.InputChanged:Connect(function(i)
        if not dg then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-ds
            btn.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dg=false end end)
end

-- ════ Core ════
local isOn = false
local sprint = require(RS.Modules.Actions.Sprint)

-- เก็บ function เดิมไว้ก่อน
local origDrain  = sprint.GetDrainAmount
local origSpend  = sprint.GetSpendAmount
local origMult   = sprint.SetStaminaMultiplier

btn.MouseButton1Click:Connect(function()
    isOn=not isOn
    if isOn then
        sprint.GetDrainAmount      = function(...) return 0 end
        sprint.GetSpendAmount      = function(...) return 0 end
        sprint.SetStaminaMultiplier= function(...) end
        btn.Text="⚡ Stamina: เปิด"
        btn.TextColor3=Color3.fromRGB(255,80,80)
        btn.BackgroundColor3=Color3.fromRGB(60,15,15)
        s.Color=Color3.fromRGB(200,60,60)
    else
        -- คืน function เดิม
        sprint.GetDrainAmount      = origDrain
        sprint.GetSpendAmount      = origSpend
        sprint.SetStaminaMultiplier= origMult
        btn.Text="⚡ Stamina: ปิด"
        btn.TextColor3=Color3.fromRGB(80,255,140)
        btn.BackgroundColor3=Color3.fromRGB(15,60,25)
        s.Color=Color3.fromRGB(60,200,100)
    end
end)
