-- lsm.lua
-- LuaStateMachine 类，负责管理各个状态的注册、切换与循环调用

local LuaStateMachine = {}
LuaStateMachine.__index = LuaStateMachine

function LuaStateMachine:new()
    local obj = {
        states = {},    -- 表：stateObj.id -> stateObj
        current = nil,  -- 当前状态 id
    }
    setmetatable(obj, self)
    return obj
end

-- 注册一个状态对象，stateObj 必须有 .id 字段，以及 OnEnter/OnLoop/OnExit 方法
function LuaStateMachine:RegisterState(stateObj)
    if not stateObj.id then
        error("State object must have an 'id' field")
    end
    self.states[stateObj.id] = stateObj
end

-- 切换到新状态（根据 ID），会依次调用旧状态的 OnExit 和新状态的 OnEnter
function LuaStateMachine:ChangeState(new_id)
    local nextObj = self.states[new_id]
    if not nextObj then
        error(string.format("State '%s' not registered", tostring(new_id)))
    end

    if self.current then
        local prevObj = self.states[self.current]
        if prevObj and prevObj.OnExit then
            prevObj:OnExit(new_id)
        end
    end

    local prev = self.current
    self.current = new_id

    if nextObj.OnEnter then
        nextObj:OnEnter(prev)
    end

end

-- 每帧调用：执行当前状态的 OnLoop，若返回一个不同的状态 ID 则自动切换
function LuaStateMachine:Update()
    local currObj = self.states[self.current]
    if currObj and currObj.OnLoop then
        local next_id = currObj:OnLoop()
        if next_id and next_id ~= self.current then
            self:ChangeState(next_id)
        end
    end
end

return LuaStateMachine
