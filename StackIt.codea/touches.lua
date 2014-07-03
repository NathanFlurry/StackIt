touches = class()

function touches:init()
    self.list = {}
end

function touches:get()
    local sTouches = {}
    for i,t in pairs(self.list) do
        table.insert(sTouches,t)
    end
    return sTouches
end

function touches:update(t)
    self.list[t.id] = self:toTable(t)
    if t.state == ENDED or t.state == CANCELLED then
        self.list[t.id].deleteMe = ElapsedTime
    end
end

function touches:maitmence()
    for i,t in pairs(self.list) do
        if self.list[t.id].deleteMe ~= nil and self.list[t.id].deleteMe ~= ElapsedTime then
            self.list[t.id] = nil
        end
    end
end

function touches:toTable(t)
    local tt = {}
    tt.x = t.x
    tt.y = t.y
    tt.prevX = t.prevX
    tt.prevY = t.prevY
    tt.deltaX = t.deltaX
    tt.deltaY = t.deltaY
    tt.id = t.id
    tt.state = t.state
    tt.tapCount = t.tapCount
    return tt
end

function touches:count()
    local c = 0
    for i,t in pairs(self.list) do
        c = c + 1
    end
    return c
end
 
function touches:average()
    avg = vec2(0,0)
    for i,t in pairs(self.list) do
        avg = vec2(avg.x+t.x,avg.y+t.y)
    end
    avg = vec2(avg.x/self:count(),avg.y/self:count())
    return avg
end