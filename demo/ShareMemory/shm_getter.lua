-- getter.lua
-- 不断扫描 key1…key10，如果存在就读出并打印

    local time = require("common.time")
local shm = System.SharedMemory.GetInstance()

while true do
    for i = 1, 10 do
        local key = "key" .. i
        if shm:Exists(key) then
            local val = shm:Get(key)
            if type(val) == "table" then
                System.Logger.Normal(string.format("GET [%s] = { x=%.3f, y=%.3f }", key, val.x, val.y))
            else
                System.Logger.Normal(string.format("GET [%s] = %s", key, tostring(val)))
            end
        end
    end

    -- 每秒查询一次
    time.delay(1000)
end
