Paddle = class()

function Paddle:init()
    self.dX = WIDTH/2
    self.dY = HEIGHT/3
    self.dR = 0
    self.moveSpeed = 12
    self.rotateSpeed = 8

    self.sensitivity = 50
    self.startGrav = Gravity.x

    self.evenOutThreshold = 5
    self.evenOutSpeed = 2
    
    self.paddleDist = HEIGHT/5
    self.paddles = {}

    local numPaddles = purchases.extraPaddles or 0
    if not useExtraPaddle then
        numPaddles = 0
    end

    for i = 0,numPaddles do
        local o = ObjectFunctions:getObject(
            (function()
                if beastMode then
                    local validObjects = {
                        "square",
                        "triangle",
                        "corner",
                        "doubleSquare",
                        "t",
                        "circleCatcher",
                        "star",
                        "cow"
                    }
                    return validObjects[math.random(#validObjects)]
                else
                    return {
                                name = "Paddle",
                                pGen = pRect,
                                pArgs = {5+(purchases.paddleSize or 0)*.5,1},
                                chance = .001,
                                worth = 10,
                                level = 500
                            }
                    --"largePlank"
                end
            end)(),
            20*gScale)
        --if i == 0 then
            o.body.type = KINEMATIC
        --end
        o.body.x = self.dX
        o.body.y = -self.paddleDist*(i-1)
        o.body.angle = self.dR
        o.body.gravityScale = 0
        o.body.friction = 2
        --o.body.mass = 100

        o.color = ObjectStyles.colors.compliment
        o.m:setColors(o.color)
        
        table.insert(self.paddles,o)
    end

    self.offset = nil
end

function Paddle:draw()
    self.moveSpeed = 12*(1-DeltaTime)

    if update then
        if controlMode == "tilt" then
            self.dR = (Gravity.x+self.startGrav)*self.sensitivity
        elseif controlMode == "tiltReversed" then
             self.dR = (Gravity.x-self.startGrav)*self.sensitivity
        end
        if touches:count() >= 1 then
            self:update()
        else
            self.prevR = nil
            self.prevT = nil
        end
        if touches:count() == 0 then
            if self.dR > -self.evenOutThreshold and self.dR < 0 then
                self.dR = self.dR + 2--self.evenOutSpeed
            elseif self.dR < self.evenOutThreshold and self.dR > 0 then
                self.dR = self.dR - 2--self.evenOutSpeed
            end
            if self.dR > -2 and self.dR < 2 then
                self.dR = 0
            end
        end
    end
    
    -- Move body
    for i,p in ipairs(self.paddles) do
        p.body.linearVelocity = vec2(
                                    ((self.dX+math.cos(math.rad(self.paddles[1].body.angle-90))*self.paddleDist*(i-1)) - p.body.x)*self.moveSpeed, 
                                    ((self.dY+math.sin(math.rad(self.paddles[1].body.angle-90))*self.paddleDist*(i-1)) - p.body.y)*self.moveSpeed
                                )
        local angleDiff = (self.dR - p.body.angle + 180 + 360) % 360 - 180
        p.body.angularVelocity = angleDiff*self.rotateSpeed
        ObjectFunctions:renderMesh(p.m,p.body.x,p.body.y,p.body.angle)
    end
end

function Paddle:update()
    local t1,t2,tR
    t1 = touches:get()[1]
    
    if touches:count() == 2 and controlMode == "touch" then
        t2 = touches:get()[2]
        
        if self.prevR == nil then
            self.prevR = anglify(vec2(t1.x,t1.y),vec2(t2.x,t2.y),self.dR)
            self.prevT = nil
        end
        if self.prevT == nil then
            self.prevT = vec2(t1.x+t2.x/2,t1.y+t2.y/2)
        end
        
        self.dX = self.dX+((t1.x+t2.x/2)-self.prevT.x)
        self.prevT = vec2(t1.x+t2.x/2,t1.y+t2.y/2)
        
        local currentR = anglify(vec2(t1.x,t1.y),vec2(t2.x,t2.y),self.dR)
        self.dR = self.dR + (currentR - self.prevR)
        self.prevR = currentR
    
    elseif touches:count() == 1 then
        if self.prevR then
                self.prevR = nil
                self.prevT = nil
        end
        
        if self.prevT == nil then
            self.prevT = vec2(t1.x,t1.y)
        end
        
        if math.abs(t1.x-self.prevT.x) < 100 then
            self.dX = self.dX+(t1.x-self.prevT.x)
        end
        --self.dY = t1.x-self.prevT.y
        self.prevT = vec2(t1.x,t1.y)
    end


    if self.dX >= WIDTH then
        self.dX = WIDTH
    elseif self.dX <= 0 then
        self.dX = 0
    end
end
