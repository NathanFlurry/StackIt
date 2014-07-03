ScrollView = class()

function ScrollView:init(contentSize,drawFunc,bounceAdjustmentDivisor)
    self.drawFunc = drawFunc
    
    self.contentPos = vec2(0,0)
    self.contentSize = contentSize
    
    self.vel = vec2(0,0)
    self.scrolling = nil
    self.friction = .95
    self.bounceAdjustment = vec2(0,0)
    self.bounceAdjustmentDivisor = (bounceAdjustmentDivisor or 6)
    self.tAvgs = {}
    self.avgMax = 5
    self.touchedThisFrame = false
end

function ScrollView:draw()
    self.vel = self.vel * self.friction
    self.contentPos = self.contentPos + self.vel * DeltaTime
    if not self.scrolling then
        self.contentPos = self.contentPos + self.bounceAdjustment / self.bounceAdjustmentDivisor
    end
    if self.contentPos.y > self.contentSize.y-HEIGHT then
        self.bounceAdjustment.y = self.contentSize.y-HEIGHT-self.contentPos.y
    end
    if self.contentPos.y < 0 then
        self.bounceAdjustment.y = -self.contentPos.y
    end
    if self.contentPos.x < -self.contentSize.x+WIDTH then
        self.bounceAdjustment.x = -self.contentSize.x+WIDTH-self.contentPos.x
    end
    if self.contentPos.x > 0 then
        self.bounceAdjustment.x = -self.contentPos.x
    end
    if self.contentSize.x == 0 then
        self.contentPos.x = 0
    end
    if self.contentSize.y == 0 then
        self.contentPos.y = 0
    end
    if not self.touchedThisFrame then
        table.insert(self.tAvgs,1,vec2(0,0))
    end
    if #self.tAvgs > self.avgMax then
        table.remove(self.tAvgs)
    end
    
    pushMatrix()
    translate(self.contentPos.x,self.contentPos.y)
    self.drawFunc()
    popMatrix()
end

function ScrollView:touched(t)
    if t.state == BEGAN then
        if self.scrolling == nil then
            self.tAvgs = {}
            self.vel = vec2(0,0)
            self.scrolling = t.id

            self.touchedThisFrame = true
        end
    elseif t.state == MOVING then
        if self.scrolling == t.id then
            self.contentPos.x = self.contentPos.x +  t.deltaX
            self.contentPos.y = self.contentPos.y +  t.deltaY
            table.insert(self.tAvgs,1,vec2(t.deltaX,t.deltaY))

            self.touchedThisFrame = true
        end
    elseif t.state == ENDED or t.state == CANCELLED then
        if self.scrolling == t.id then
            self.scrolling = nil

            local vel = vec2(0,0)
            for i,v in ipairs(self.tAvgs) do
                vel = vel + v
            end
            
            local velDivisor = #self.tAvgs
            if velDivisor == 0 then
                velDivisor = 1
            end
            self.vel.x = vel.x / velDivisor * 60
            self.vel.y = vel.y / velDivisor * 60
            self.tAvgs = {}

            self.touchedThisFrame = true
        end
    end
end