-- common/time.lua

local time = {}

-- delay: 延迟指定的毫秒数
function time.delay(ms)
    -- 获取当前时间（毫秒），假定 System.Time.Now() 返回毫秒级的当前时间
    local startTime = System.Time.Now()
    local targetTime = startTime + ms

    if ms <= 50 then
        -- 如果延迟时间很短，直接调用一次延迟
        System.Time.Delay(ms)
        return
    end

    while true do
        local now = System.Time.Now()
        local remaining = targetTime - now
        if remaining <= 0 then
            break
        end
        -- 每次延迟50毫秒或者剩余时间，如果剩余时间不足50ms就延迟剩余时间
        System.Time.Delay(math.min(50, remaining))
    end
end

return time
