Emitter = class()

function Emitter:init(args)
    self.particleMesh = mesh()
    self.particleMesh.texture = args.tex
    self.minLife = args.minLife or 1
    self.maxLife = args.maxLife or 1
    self.spread = args.spread or 360
    self.angle = args.angle or 0
    self.minSpeed = args.minSpeed or 10
    self.maxSpeed = args.maxSpeed or 50
    self.minSize = args.minSize or 10
    self.maxSize = args.maxSize or 15
    self.growth = args.growth or 1
    self.startColor = args.startColor or color(255, 255, 255, 255)
    self.endColor = args.endColor or color(0, 0, 0, 0)
    self.streak = args.streak or false
    self.streakMult = args.streakMult or 2
    self.accel = args.accel or vec2(0,0)
    self.rAccel = args.rAccel or vec2(0,0) 
    
    self.particles = {}
    self.pCount = 0
    for i = 1,1000 do
        table.insert(self.particles, Particle())
    end
end

function Emitter:emit(pos,count)
    for i = 1,#self.particles do
        local p = self.particles[i]
        if p.dead then
            self.pCount = math.max(i, self.pCount)
            p.dead = false
            p.pos = pos
            p.life = math.random(self.minLife, self.maxLife)
            p.size = math.random(self.minSize, self.maxSize)
            p.maxLife = p.life
            p.vel = vec2(0, math.random(self.minSpeed, self.maxSpeed))
            p.vel = p.vel:rotate(math.rad(self.angle + 
                                          math.random(-self.spread/2,
                                                       self.spread/2)))
            count = count - 1
            if count == 0 then return end
        end
    end
end

function Emitter:draw()
    -- update
    self.particleMesh:clear()
    
    for i = 1,self.pCount do
        
        local p = self.particles[i]
        
        if not p.dead then
            p.prevPos = p.pos
            
            p.pos = p.pos + p.vel * DeltaTime
            
            p.vel = p.vel + (self.accel + 
                             vec2(math.random(-self.rAccel.x, 
                                               self.rAccel.x), 
                                  math.random(-self.rAccel.y,
                                               self.rAccel.y)))
                                            * DeltaTime
                                            
            p.life = math.max(0, p.life - DeltaTime)
            p.size = p.size + DeltaTime * self.growth
            if p.life == 0 then p.dead = true end
            local interp = p.life / p.maxLife
           
            p.col.r = interp * self.startColor.r + 
                        (1-interp) * self.endColor.r
            p.col.g = interp * self.startColor.g + 
                        (1-interp) * self.endColor.g
            p.col.b = interp * self.startColor.b + 
                        (1-interp) * self.endColor.b
            p.col.a = interp * self.startColor.a + 
                        (1-interp) * self.endColor.a
           
            local ind = self.particleMesh:addRect(p.pos.x, 
                                                  p.pos.y, 
                                                  p.size, p.size)
            self.particleMesh:setRectColor(ind, p.col)
            
            if self.streak then
                local dir = (p.pos - p.prevPos)
                local len = dir:len()
                local pos = (p.pos + p.prevPos) * 0.5
                local ang = math.atan2(dir.y, dir.x)
                
                self.particleMesh:setRect(ind, pos.x, pos.y, 
                                          p.size * self.streakMult,
                                          p.size, ang)
            end
        end
    end
    self.particleMesh:draw()
end


Particle = class()

function Particle:init()
    self.pos = vec2(0,0)
    self.prevPos = vec2(0,0)
    self.vel = vec2(0,0)
    self.life = 0
    self.maxLife = 0
    self.dead = true
    self.col = color(0, 0, 0, 255)
    self.size = 0
end