--------------------------------------------------------
-- Lua API 接口存根
-- 注意：以下接口均为存根，仅用于代码提示和文档说明，
-- 实际实现由 C++ 提供。
-- 使用方法：
--  1. 在vscode中左侧打开扩展栏（或快捷键Ctrl+Shift+X）
--  2. 在搜索栏中搜索“lua”，安装Lua语言服务器插件(Lua Language Server coded by Lua)，插件作者为sumneko
--  3. 点击vscode中左下角齿轮，在弹出的二级菜单中点击“设置”（或快捷键Ctrl+,)，打开设置选项
--  4. 在弹出的设置页面上，点击右上角的"打开设置（json）"，弹出settings.json。（或通过快捷键Ctrl+P弹出搜索栏，在搜索栏内输入settings.json并打开）
--  5. 在settings.json中增加以下语句。通过vscode打开要编辑的插件目录，即可在代码中对API自动补全
--[[    这一行不要复制
   
    "Lua.runtime.version": "Lua 5.4",  
    "Lua.runtime.path": [
      "?.lua",
      "?/init.lua"
    ],
    "Lua.workspace.library": [
      "${workspaceFolder}/common"
    ],
    "Lua.telemetry.enable": false

]]-- 这一行不要复制
--------------------------------------------------------

--- 系统空间
System = System or {}

--------------------------------------------------------
-- 4.1 系统空间(System)
--------------------------------------------------------

--------------------------------------------------------
-- 4.1.1 日志类(Logger)
--------------------------------------------------------
System.Logger = System.Logger or {}

--- 输出调试级别的日志
-- @param text string 待输出的日志文本
function System.Logger.Debug(text) end

--- 输出正常级别的日志
-- @param text string 待输出的日志文本
function System.Logger.Normal(text) end

--- 输出提示级别的日志
-- @param text string 待输出的日志文本
function System.Logger.Info(text) end

--- 输出告警级别的日志
-- @param text string 待输出的日志文本
function System.Logger.Warning(text) end

--- 输出错误级别的日志
-- @param text string 待输出的日志文本
function System.Logger.Exception(text) end

--------------------------------------------------------
-- 4.1.3 通知类(Notify)
--------------------------------------------------------
System.Notify = System.Notify or {}

--- 发送喵提醒，该函数为阻塞函数，直至发送成功或达到重试次数后返回
-- @param text string 待发送的文本内容
-- @param retry_count number 发送失败时的重试次数
-- @return boolean 发送状态，true 表示成功
function System.Notify.Miao(text, retry_count) end

--- 使用指定的喵码发送喵提醒，该函数为阻塞函数，直至发送成功或达到重试次数后返回
-- @param text string 待发送的文本内容
-- @param retry_count number 发送失败时的重试次数
-- @param miao_code string 喵码，参考 httpsmiaotixing.comhow
-- @return boolean 发送状态，true 表示成功
function System.Notify.MiaoEx(text, retry_count, miao_code) end

--------------------------------------------------------
-- 4.1.4 内核参数(Notify)
--------------------------------------------------------
System.Core = System.Core or {}

--- 获取系统状态机当前的运行状态
-- @return 当前状态，状态值参考如下：
-- 0 - 初始化状态
-- 1 - 自动攻击状态
-- 2 - 移动到符文
-- 3 - 解符文
-- 4 - 原地待机
-- 5 - 识别并跟踪蘑菇
-- 6 - 等待蘑菇窗口出现
-- 7 - 识别并处理字符验证码
function System.Core.GetFsmState() end

--------------------------------------------------------
-- 4.1.5 时间类(Time)
--------------------------------------------------------
System.Time = System.Time or {}

--- 延迟一段时间，单位为毫秒。注意该函数是全局延迟，
-- 如果在延迟期间触发暂停（例如按下F8），则等待延迟结束后再响应。
-- 若延迟时间较长，建议使用 commontime.lua 中的 time.delay。
-- @param ms number 毫秒数
function System.Time.Delay(ms) end

--- 获取当前时间戳，单位为毫秒。使用操作系统时间，
-- 调整系统时间可能导致时间戳向前或向后跳跃。
-- @return number 毫秒时间戳
function System.Time.Now() end


--------------------------------------------------------
-- 4.1.6 线程类(Thread)
-- 线程模型（System.Thread）
-- *    - 通过 System.Thread.Run(filename) 启动独立的 LuaState 线程，并返回唯一的 threadId。
-- *    - 通过 System.Thread.Terminate(threadId) 停止指定线程，内部会对该线程及其所有协程统一设置 Hook，立即中断脚本执行。
-- *    - 每个 LuaState 生命周期独立、相互隔离，线程切换或者暂停时不会丢失各自的执行上下文和协程状态，方便在调试或脚本恢复时继续执行。
-- *    - 设计中，所有 LuaState 都由 C++ 统一管理，启动、停止、Hook 注入都可集中控制，避免线程泄漏。
--------------------------------------------------------
System.Thread = System.Thread or {}

--- 启动一个独立的 Lua 线程来执行指定脚本
-- @param filename string 要执行的 Lua 脚本文件名
-- @return number 返回线程 ID
function System.Thread.Run(filename) end

--- 停止指定的 Lua 线程
-- @param threadId number 要停止的线程 ID
-- @return boolean 停止是否成功
function System.Thread.Terminate(threadId) end

--------------------------------------------------------
-- 4.1.7 共享内存(SharedMemory)
-- 共享内存（System.SharedMemory）
--  *    - 全局唯一：SharedMemory 采用单例模式（SharedMemory::GetInstance()），所有线程/协程共享同一份数据存储。
--  *    - 线程安全：内部加锁，所有 Set/Get/Exists/Remove/Clear 操作在并发环境下保证原子性，无竞态。
--  *    - 数据类型：支持 boolean、integer、number、string，以及以 string 为键的嵌套 table。
--  *    - 持久性：脚本在任意线程中执行、暂停或切换都不会影响共享内存的内容，数据始终保持可见且不会丢失。
-- 注意事项：
-- *  - 共享内存仅支持 string 类型的键，不可存放函数、userdata 或带 metatable 的值。
-- *  - 高频读写场景下，内部锁可能成为瓶颈，不建议无延迟高频读写。
-- *  - 调用 System.SharedMemory.Clear() 会删除所有数据，谨慎使用，以免误伤其他线程正在读取的数据。
--------------------------------------------------------
System.SharedMemory = System.SharedMemory or {}

--- 设置键值
-- @param key string 键
-- @param value any 值，可以是 number|boolean|string|table
function System.SharedMemory.Set(key, value) end

--- 获取键值
-- @param key string 键
-- @return any 存储的值
function System.SharedMemory.Get(key) end

--- 判断指定键是否存在
-- @param key string 键
-- @return boolean 存在返回 true，否则 false
function System.SharedMemory.Exists(key) end

--- 删除指定键
-- @param key string 键
function System.SharedMemory.Remove(key) end

--- 清空所有键值
function System.SharedMemory.Clear() end

--------------------------------------------------------
-- 4.2 游戏空间(Game)
--------------------------------------------------------
Game = Game or {}

--------------------------------------------------------
-- 4.2.1 图像类(Graphics)
--------------------------------------------------------
Game.Graphics = Game.Graphics or {}

--- 查找屏幕上的图像内容
-- @param image string 被查找图片的资源ID
-- @param threshold number 查找的阈值，范围 0 - 1.0，不填写时默认为 0.8
-- @param x number 开始查找的左上角 x 坐标（可选，默认全屏）
-- @param y number 开始查找的左上角 y 坐标（可选，默认全屏）
-- @param w number 查找区域的宽度（可选，默认全屏）
-- @param h number 查找区域的高度（可选，默认全屏）
-- @return boolean 是否找到结果
-- @return string msg
-- @return number 结果阈值
-- @return number x 坐标
-- @return number y 坐标
-- @return number w 宽度
-- @return number h 高度
function Game.Graphics.Find(image, threshold, x, y, w, h) end

--- 查找屏幕上指定区域内的图像内容，返回所有匹配目标
--- @param image string 被查找图片的资源ID，以 "image://" 开头
--- @param threshold number 查找的置信度阈值，范围 0–1.0，默认值为 0.8
--- @param x number 起始查找区域左上角的 x 坐标，默认 0
--- @param y number 起始查找区域左上角的 y 坐标，默认 0
--- @param w number 查找区域的宽度，默认全屏宽度
--- @param h number 查找区域的高度，默认全屏高度
--- @param x_sort number x 坐标排序规则：0 表示不排序，1 表示升序，2 表示降序（默认 0）
--- @param y_sort number y 坐标排序规则：0 表示不排序，1 表示升序，2 表示降序（默认 0）
--- @return number 匹配数量
--- @return table 匹配结果列表，每个匹配结果为一个 table，包含字段：
---         confidence number 匹配得分
---         x number 匹配位置 x 坐标
---         y number 匹配位置 y 坐标
---         w number 模板图像宽度
---         h number 模板图像高度
function Game.Graphics.FindAll(image, threshold, x, y, w, h, x_sort, y_sort) end



--- 判断当前是否是黑屏（通过采样屏幕多个点实现），
-- 返回 true 不一定意味着屏幕完全黑。
-- @return boolean true 表示黑屏
function Game.Graphics.IsBlack() end

--------------------------------------------------------
-- 4.2.2 小地图类(Minimap)
--------------------------------------------------------
Game.Minimap = Game.Minimap or {}

--- 获取小地图的识别状态和矩形包围框
-- @return boolean 小地图是否存在，存在返回 true，否则 false
-- @return number x 坐标，失败返回 -1
-- @return number y 坐标，失败返回 -1
-- @return number w 宽度，失败返回 -1
-- @return number h 高度，失败返回 -1
function Game.Minimap.GetMinimapRect() end

--- 判断是否有其他玩家存在（包括陌生玩家、好友及家族成员）
-- @return boolean 有其他玩家存在返回 true，否则 false
function Game.Minimap.IsOtherCharacterExist() end

--- 设置自动挂机左边界线
function Game.Minimap.SetLeftBoundary() end

--- 设置自动挂机上边界线
function Game.Minimap.SetTopBoundary() end

--- 设置自动挂机右边界线
function Game.Minimap.SetRightBoundary() end

--- 设置自动挂机下边界线
function Game.Minimap.SetBottomBoundary() end

--------------------------------------------------------
-- 4.2.3 游戏角色类(Character)
--------------------------------------------------------
Game.Character = Game.Character or {}

--- 启动自动攻击。该指令使用键盘配置页面中选定的配置进行自动攻击，
-- 启动后立即返回（异步执行），即使脚本退出自动攻击仍然运行。
-- 该指令可恢复除UI暂停外所有暂停信号，因此调用前建议判断当前条件以避免在不适合挂机的地方调用。
function Game.Character.ResumeAutoAttack() end

--- 停止自动攻击
function Game.Character.PauseAutoAttack() end

--- 检测当前是否处于暂停挂机状态（UI上的暂停选项勾选后，Lua插件立即被停止执行，因此无法检测到UI的暂停选项）
-- @return boolean true表示当前已经处于暂停状态
function Game.Character.IsAutoAttackPaused() end

--- 检测当前是否处于暂停挂机状态（UI上的暂停选项勾选后，Lua插件立即被停止执行，因此无法检测到UI的暂停选项）
-- @return boolean true表示当前已经处于暂停状态
-- @return table 当前暂停信号(暂停信号为string类型)的table
function Game.Character.IsAutoAttackPausedEx() end

--- 获取当前血量百分比（范围 0 - 100）
-- @return number 实际血量百分比
function Game.Character.GetHPPercentage() end

--- 获取当前蓝量百分比（范围 0 - 100）
-- @return number 实际蓝量百分比
function Game.Character.GetMPPercentage() end

--- 调用设定的加血按键
function Game.Character.HealHP() end

--- 调用加血按键若干次
-- @param nTimes number 调用次数
-- @param msInterval number 每次调用间隔，单位毫秒
function Game.Character.HealHPEx(nTimes, msInterval) end

--- 调用设定的加蓝按键
function Game.Character.HealMP() end

--- 调用加蓝按键若干次
-- @param nTimes number 调用次数
-- @param msInterval number 每次调用间隔，单位毫秒
function Game.Character.HealMPEx(nTimes, msInterval) end

--- 获取当前人物坐标
-- @return number x 坐标（失败返回 -1）
-- @return number y 坐标（失败返回 -1）
function Game.Character.GetCoodinate() end

--- 让人物移动到指定位置，到达后结束
-- @param x number x 坐标
-- @param y number y 坐标
function Game.Character.TryMoveTo(x, y) end

--- 让人物移动到指定位置（带误差和持续监测选项）
-- @param x number x 坐标
-- @param y number y 坐标
-- @param xThreshold number 水平方向允许的误差（例如设置为 3 表示在 3 像素内认为到达）
-- @param yThreshold number 竖直方向允许的误差
-- @param bHoldCoodinate boolean 如果为 true，到达后持续监测，超出范围则重新移动；为 false则移动后不再关注位置
function Game.Character.TryMoveToEx(x, y, xThreshold, yThreshold, bHoldCoodinate) end

--- 取消当前移动
function Game.Character.CancelMoveTo() end

--- 调用配置中设置的上跳按键
function Game.Character.JumpUp() end

--- 调用配置中设置的下跳按键
function Game.Character.JumoDown() end

--- 调用配置中设置的NPC采集按键
function Game.Character.NPC() end

--------------------------------------------------------
-- 4.2.4 键盘类(Keyboard)
--------------------------------------------------------
Game.Keyboard = Game.Keyboard or {}

--- 模拟按键点击
-- @param key string 按键，示例：A，Esc，Space 等
function Game.Keyboard.KeyClick(key) end

--- 模拟带延迟和多次点击的按键点击
-- @param key string 按键
-- @param msDelayBefore number 按之前的延迟（毫秒）
-- @param msDelayAfter number 按之后的延迟（毫秒）
-- @param nClickTimes number 点击次数
-- @param msDelayBetweenClick number 每次点击之间的延迟（毫秒）
-- @param msPressTime number 单次点击按下保持时间（毫秒）
function Game.Keyboard.KeyClickEx(key, msDelayBefore, msDelayAfter, nClickTimes, msDelayBetweenClick, msPressTime) end

--- 模拟按下一个按键但不松开
-- @param key string 按键
function Game.Keyboard.KeyPress(key) end

--- 模拟按下一个按键（带延迟），不松开
-- @param key string 按键
-- @param msDelayBefore number 按之前的延迟（毫秒）
-- @param msDelayAfter number 按之后的延迟（毫秒），此延迟后按键仍保持按下状态
function Game.Keyboard.KeyPressEx(key, msDelayBefore, msDelayAfter) end

--- 模拟释放一个之前按下的按键
-- @param key string 按键
function Game.Keyboard.KeyRelease(key) end

--- 模拟带延迟的按键释放
-- @param key string 按键
-- @param msDelayBefore number 释放之前的延迟（毫秒）
-- @param msDelayAfter number 释放之后的延迟（毫秒）
function Game.Keyboard.KeyReleaseEx(key, msDelayBefore, msDelayAfter) end

--- 松开所有按键
function Game.Keyboard.ReleaseAll() end

--------------------------------------------------------
-- 4.2.5 鼠标类(Mouse)
--------------------------------------------------------
Game.Mouse = Game.Mouse or {}

--- 将鼠标移动到指定位置
-- @param x number x 坐标（通常应使用查找图片的返回结果）
-- @param y number y 坐标
function Game.Mouse.MoveTo(x, y) end

--- 模拟一次鼠标左键点击
function Game.Mouse.LButtonClick() end

--- 模拟鼠标滚轮向上滚动
function Game.Mouse.WheelUp() end

--- 模拟鼠标滚轮向下滚动
function Game.Mouse.WheelDown() end

--------------------------------------------------------
-- 4.3 按键列表（仅作为参考）
-- 以下按键名称仅供参考，不作为API部分
--[[

字母：A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
数字：1 2 3 4 5 6 7 8 9 0 `
Alt Ctrl Delete End PageUp PageDown Home Shift Space Insert Esc Enter
Left Right Up Down
功能按键：F1-F3,F5-F7,F9-F12（即除了F4和F8之外，其余功能键均可使用）
LeftBracket - 左方括号 [
RightBracket - 右方括号 ]
Semicolon - 分号 ;
SingleQuote - 单引号 '
Comma - 逗号 , . / , 几个按键
SingleQuote - 单引号 '
Period - 句号 .
ForwardSlash - 正斜杠 / 
BackSlash - 反斜杠 \
TildeKey - 1左侧的按键 `，注意该按键兼容之前使用`的情况，也可以使用新的TildeKey按键

]]
