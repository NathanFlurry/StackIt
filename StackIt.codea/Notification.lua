Notification = class()

function Notification:init()
    self.queue = {}
end

function Notification:draw()
    local n = self.queue[1]
    if n then
        if not n.animation then
            local speed = .5
            local length = 1
            n.animation = tween.sequence(
                                    tween(speed,n,{ y = 1 },tween.easing.linear),
                                    -- tween.delay(4),
                                    tween(length,n,{ y = 1 },tween.easing.linear),
                                    tween(speed,n,{ y = 0 },tween.easing.linear,function()
                                                                                    table.remove(self.queue,1)
                                                                                end ))
        end

        pushMatrix()
        pushStyle()
        translate(0,(1-n.y)*200)
        local nWidth, nHeight = WIDTH*2,400
        fill(n.col)
        ellipse(WIDTH/2,HEIGHT+nHeight/3,nWidth,nHeight)

        font("Futura-CondensedMedium")
        fontSize(30)
        fill(0)
        text(n.txt,WIDTH/2,HEIGHT-fontSize())
        popMatrix()
        popStyle()
    end
end

function Notification:add(txt,col)
    local n = {}
    n.txt = txt
    if col then
        n.col = color(col.r,col.g,col.b,200)
    else
        n.col = color(255,200)
    end
    n.y = 0
    table.insert(self.queue,n)

end

function  Notification:clearAll()
    self.queue = {self.queue[1]}
end