HowToPlay = class()

function HowToPlay:init()
    self.transX = WIDTH
    self.transitioning = false
    tween(.2,self,{transX = 0},tween.easing.sinOut)

    --addWebView("helpScreen","Help",WIDTH/2-350*gScale+self.transX,HEIGHT/2-350*gScale,700*gScale,700*gScale)
    addWebView("helpScreen","Help",0,HEIGHT/2-WIDTH/2,WIDTH,WIDTH)
    setWebViewScrollingAllowed("helpScreen",false)
end

function HowToPlay:draw()
    --setWebViewX("helpScreen",WIDTH/2-350*gScale+self.transX)
    setWebViewX("helpScreen",self.transX)

    pushStyle()
    pushMatrix()
    resetStyle()
    translate(self.transX,0)

    fontSize(25)
    textWrapWidth(WIDTH-50)
    fill(255)
    font(globalFont)
    
    fill(0, 0, 0, 100)
    rect(0,0,WIDTH,HEIGHT)

    fill(255)
    if firstRun then
        sText("Done",40,HEIGHT-20)
    else
        sText("Back",40,HEIGHT-20)
    end
    if currentT.x < 80 and currentT.y > HEIGHT-60 and not self.transitioning and touchReady() then
        touchUsed()
        if firstRun then
            firstRun = false
            saveLocalData("firstRun",false)
        end
        self:leaveTrans()
    end
    
    popStyle()
    popMatrix()
end

function HowToPlay:leaveTrans()
    self.transitioning = true
    mainReverTrans = true
    tween(.2,self,{transX = WIDTH},tween.easing.sinOut,function() changeScene("start") end)
end

function HowToPlay:exit()
    removeWebView("helpScreen")
end