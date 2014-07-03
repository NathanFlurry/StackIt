RisingText = class()

function RisingText:init()
    self.txts = {}
end

function RisingText:draw()
    for i,v in ipairs(self.txts) do
        pushStyle()
        fill(v.color.r,v.color.g,v.color.b,v.alpha)
        font("Arial-BoldMT")
        fontSize(30)
        textAlign(CENTER)
        textWrapWidth(WIDTH-50)
        local sameCount = 0
        for ni,nv in ipairs(self.txts) do
            if nv.x == v.x and ni > i then
                sameCount = sameCount + 1
            end
        end
        text(v.txt,v.x,v.y+40*sameCount)
        popStyle()
    end
end

function RisingText:addText(txt,x,y,col)
    table.insert(self.txts,{
        txt = txt,
        x = x or WIDTH/2,
        y = y or 50,
        color = col or textColor,
        alpha = 255
    })
    tween(3,self.txts[#self.txts],{ y = self.txts[#self.txts].y+20, alpha = 0},tween.easing.cubicOut, function()
                                                                    table.remove(self.txts,1)
                                                                end)
end
