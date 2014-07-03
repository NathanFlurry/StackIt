FadingImage = class()

function FadingImage:init()
    self.imgs = {}
end

function FadingImage:draw()
    for i,v in ipairs(self.imgs) do
        pushStyle()
        local sameCount = 0
        for ni,nv in ipairs(self.imgs) do
            if nv.x == v.x and ni > i then
                sameCount = sameCount + 1
            end
        end
        tint(v.color.r,v.color.g,v.color.b,v.alpha)
        sSprite(v.img,v.x,v.y+40*sameCount)
        popStyle()
    end
end

function FadingImage:addImg(img,x,y,col)
    table.insert(self.imgs,{
        img = img,
        x = x,
        y = y,
        color = col or color(0,0,0),
        alpha = 255
    })
    tween(3,self.imgs[#self.imgs],{alpha = 0},tween.easing.cubicOut, function()
                                                                    table.remove(self.imgs,1)
                                                                end)
end
