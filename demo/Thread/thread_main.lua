-- main.lua
local time = require("common.time")

System.Logger.Normal("Main script started.")

-- 用于存放线程ID的数组
local threadIds = {}

-- 启动线程：调用 System.Thread.Run 接口，
-- 传入 Lua 脚本文件名（这里假设文件名为 "thread_script_1.lua" 和 "thread_script_2.lua"）
threadIds[#threadIds + 1] = System.Thread.Run("code/thread_1.lua")
threadIds[#threadIds + 1] = System.Thread.Run("code/thread_2.lua")

System.Logger.Normal("Threads started, IDs:", threadIds[1], threadIds[2])

-- 定义一个简单的 sleep 函数，使用 os.clock 来模拟等待（适合于演示，不建议用于生产环境）
local function sleep(seconds)
  local t0 = os.clock()
  while os.clock() - t0 < seconds do end
end

System.Logger.Normal("Main script sleeping for 10 seconds...")
time.delay(10000)

System.Logger.Normal("Now stopping threads...")
-- 循环调用 System.Thread.Stop 停止所有已启动的线程
for i, tid in ipairs(threadIds) do

  System.Logger.Normal(string.format("Thread ID=%d", tid))
  local result = System.Thread.Terminate(tid)
  System.Logger.Normal("Thread ID", tid, "stopped:", result)
end

System.Logger.Normal("All threads have been stopped. Main script exiting.")

return false