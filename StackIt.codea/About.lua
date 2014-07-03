About = class()

function About:init()
    self.transX = WIDTH
    self.transitioning = false
    tween(.2,self,{transX = 0},tween.easing.sinOut)

    self.scrollView = ScrollView(vec2(0,0),function() self:drawContent() end,6*gScale)

    local appVersion, buildVersion, bundleName = getAppVersion()

    self.credits = {
        "Coding:\nNathan Flurry",
        "Graphics:\nNathan Flurry",
        "Musics:\n\"Free Fall\"\nBy Spencer Hewitt\nArranged by Nathan Flurry",
        "Concept:\n\"Stack3r\" by John Millard",
        "Weather powered by forecast.io",
        "Sound effects from freesound.org",
        "Particle system:\nJohn Millard",
        "WeatherLib library:\nTuomas Jormola",
        "LuaDate library:\nPeter Drahoš",
        "In-App Purcahse library:\nCaleb Jonassaint",
        "Beta testers:\nAndrew Stacey\nCaleb Jonassaint\nDavid Cohen\nJohn Millard\nJuan Belón Pérez\nTheo Arrouye",
        "Thank you for purchasing StackIt!\nVersion "..appVersion.." ("..buildVersion..")",
        "Made with Codea",
        "Created by Interdazzle.\nInteractive, dazzling, original."
    }
end

function About:draw()
    pushStyle()
    pushMatrix()
    resetStyle()
    translate(self.transX,0)

    textAlign(CENTER)
    fill(textColor)
    font(globalFont)
    textWrapWidth(WIDTH-50)
    fontSize(25)

    self.scrollView:draw()

    sText("Back",40,HEIGHT-20)
    if currentT.x < 80 and currentT.y > HEIGHT-60 and not self.transitioning and touchReady() then
        touchUsed()
        self:leaveTrans()
    end

    pushStyle()
    fontSize(17)
    fill(255,200)
    rect(0,0,WIDTH,60)
    fill(0)
    sText("Feedback",WIDTH/2,30)
    if testTouchRegion(WIDTH/2,30,WIDTH,60) and currentT.state == BEGAN and not self.transitioning then
        leaveFeedback()
    end
    popStyle()

    popStyle()
    popMatrix()
end

function About:drawContent()
    titleText("About",HEIGHT/5*4)

    pushStyle()
    stroke(255)
    strokeWidth(2)
    fontSize(35)
    local spacing = 20
    local yPos = HEIGHT/5*3
    for i,v in ipairs(self.credits) do
        local _, sY = textSize(v)
        if i > 1 then
            line(WIDTH/3,yPos+spacing/2,WIDTH/3*2,yPos+spacing/2)
        end
        sText(v,WIDTH/2,yPos-sY/2)
        yPos = yPos - sY - spacing
    end
    if self.scrollView.contentSize.y == 0 then
        self.scrollView.contentSize.y = math.abs(yPos)+HEIGHT+60
    end
    popStyle()
end

function About:touched(t)
    self.scrollView:touched(t)
end

function About:leaveTrans()
    self.transitioning = true
    mainReverTrans = true
    tween(.2,self,{transX = WIDTH},tween.easing.sinOut,function() changeScene("start") end)
end

function About:exit()
end