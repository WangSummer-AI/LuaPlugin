-- setter.lua
-- 持续向 SharedMemory 中写入随机键值对
local time = require("common.time")

local tid = System.Thread.Run("code/shm_getter.lua")
System.Logger.Normal(string.format("Create getter thread, id=%d", tid))

local shm = System.SharedMemory.GetInstance()

math.randomseed(os.time())

local shm = System.SharedMemory.GetInstance()
while true do
    -- 随机 key，示例用 “key1”…“key10”
    local key = "key" .. math.random(1, 10)

    -- 随机选一种类型：1=int, 2=float, 3=boolean, 4=string, 5=table
    local typ = math.random(1, 5)
    local val
    if typ == 1 then
        val = math.random(1, 100)
    elseif typ == 2 then
        val = math.random() * 100
    elseif typ == 3 then
        val = (math.random() > 0.5)
    elseif typ == 4 then
        val = "str" .. math.random(1, 100)
    else
        val = { x = math.random(), y = math.random() }
    end

    shm:Set(key, val)
    System.Logger.Normal(string.format("SET [%s] = %s", key,
        (type(val) == "table"
         and string.format("{x=%.3f,y=%.3f}", val.x, val.y)
         or tostring(val))
    ))

    -- 等待 0.5 秒
    time.delay(500)
end
