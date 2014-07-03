HTMLNewsView = class()

function HTMLNewsView:init()
    self.transX = WIDTH
    self.transitioning = false
    tween(.2,self,{transX = 0},tween.easing.sinOut)

    addHTMLWebView("htmlNewsView",HTMLPage(0,newsTitle,newsData),0,40,WIDTH,HEIGHT-40)
end

function HTMLNewsView:draw()
    setWebViewX("htmlNewsView",self.transX)

    pushStyle()
    pushMatrix()
    resetStyle()
    translate(self.transX,0)

    textAlign(CENTER)
    fill(textColor)
    font(globalFont)
    fill(255)
    fontSize(25)
    sText("Back",40,HEIGHT-20)
    if currentT.x < 80 and currentT.y > HEIGHT-60 and not self.transitioning and touchReady() then
        touchUsed()
        self:leaveTrans()
    end
    
    popStyle()
    popMatrix()
end

function HTMLNewsView:leaveTrans()
    self.transitioning = true
    mainReverTrans = true
    tween(.2,self,{transX = WIDTH},tween.easing.sinOut,function() changeScene("start") end)
end

function HTMLNewsView:exit()
    removeWebView("htmlNewsView")
end