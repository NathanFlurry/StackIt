GStroke = class()

function GStroke:init(pos1,pos2,width,col)
    self.pos1 = pos1
    self.pos2 = pos2
    self.m = mesh()
    self.m.shader = shader(glowLineShader())
    self.m.shader.color = vec4(col.r/255,col.g/255,col.b/255,0.5)
    local d = (pos1-pos2)
    self.m.shader.len = d:len()/5
    self.r = self.m:addRect(pos1.x-d.x/2,pos1.y-d.y/2,d:len(),width*5,angleOfPoint(d)/mp)
    self.width = width
end

function GStroke:setPositions(pos1,pos2)
    self.pos1 = pos1
    self.pos2 = pos2
    local d = (pos1-pos2)
    self.m.shader.len = d:len()/5
    self.m:setRect(self.r,pos1.x-d.x/2,pos1.y-d.y/2,d:len(),self.width*5,angleOfPoint(d)/mp)
end

function GStroke:draw()
    self.m.shader.time = ElapsedTime*5
    self.m:draw()
end
