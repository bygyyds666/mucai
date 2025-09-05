local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))() 
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))() 
-- 增强的白名单系统
local WhitelistEnabled = true -- 是否启用白名单系统
local Whitelist = {            
    "djdu894",
    "djvoJGOO",
    "zhangcongc",
    "91789478",
    "dchdhhfhxb",
    "gouchaoxi2",     --添加白名单的账号
    "Chinese1522",
    "samcZSZ"
}

-- 检查当前用户是否在白名单中
local function IsUserWhitelisted()
    if not WhitelistEnabled then
        return true -- 如果未启用白名单，则允许所有用户
    end
    
    local playerName = game.Players.LocalPlayer.Name
    for _, name in ipairs(Whitelist) do
        if name == playerName then
            return true
        end
    end
    return false
end

-- 如果用户不在白名单中，显示通知并停止脚本
if not IsUserWhitelisted() then
    Notification:Notify( 
        {Title = "你没有白名单", Description = "添加此qq购买白名单3967418825"}, 
        {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 10, Type = "image"}, 
        {Image = "http://www.roblox.com/asset/?id=4483345998", ImageColor = Color3.fromRGB(255, 84, 84)} 
    )
    return -- 停止脚本执行
end

-- 用户在白名单中，继续加载脚本
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local bai = {
    waterwalk = false,
    awaysday = false,
    awaysdnight = false,
    nofog = false
}

-- 发送通知的函数
function SendNotification(Title, Text, Duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = Title;
        Text = Text;
        Icon = nil;
        Duration = Duration
    })
end
