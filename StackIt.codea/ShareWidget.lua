ShareWidget = class()

function ShareWidget:init(txt,size)
    self.txt = txt
    self.size = size or 50
end

function ShareWidget:draw(pos)
    sSprite(imgs.twitter,pos.x-self.size,pos.y,3,self.size)
    sSprite(imgs.facebook,pos.x+self.size,pos.y,3,self.size)
    if testTouchRegion(pos.x-self.size,pos.y,self.size*1.5,self.size*1.5) then
    	sendTweet(self.txt)
    elseif testTouchRegion(pos.x+self.size,pos.y,self.size*1.5,self.size*1.5) then
    	sendFaceBook(self.txt)
    end
end