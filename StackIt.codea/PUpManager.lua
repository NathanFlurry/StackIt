PUpManager = class()

function PUpManager:init()
    self.timers = {}
    self.size = vec2(200,20)
end

function PUpManager:draw()
    for i,v in ipairs(self.timers) do
        if update then
            v.timer:update()
        end
        
        if v.useFunc then
            v:useFunc(v)
        end
        pushMatrix()
        pushStyle()
        resetStyle()
        translate(WIDTH-275,(HEIGHT-100)-(i-1)*40)
        tint(v.col)
        sSprite(v.img,0,10)
        fill(textColor.r, textColor.g, textColor.b, 77)
        rect(20,0,self.size.x,self.size.y)
        fill(textColor.r, textColor.g, textColor.b, 255)
        rect(20,0,self.size.x-(v.timer:getTime()/v.lastTime*self.size.x),self.size.y)
        popMatrix()
        popStyle()
        if v.timer:getCount() >= 1 then
            if v.endFunc then
                v:endFunc(v)
            end
            table.remove(self.timers,i)
        end
    end
end

function PUpManager:addT(pUps)
    local insert = true
    for i,v in ipairs(self.timers) do
        if v.name == pUps.name then
            insert = false
            v.timer.time = 0
        end
    end
    if insert then
        table.insert(self.timers, pUps)
        self.timers[#self.timers].timer = Timer(pUps.lastTime)
    end
end
