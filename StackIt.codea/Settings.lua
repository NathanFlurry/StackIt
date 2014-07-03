Settings = class()

function Settings:init()
    self.transX = WIDTH
    self.transitioning = false
    tween(.2,self,{transX = 0},tween.easing.sinOut)

    self.settings = {
        {
            name = "Music",
            values = {"On","Off"},
            callback = function(value)
                        if value == 2 then
                            music.paused = true
                            musicOn = false
                            saveLocalData("musicOn",false)
                        elseif value == 1 then
                            music.paused = false
                            musicOn = true
                            saveLocalData("musicOn",true)
                        end
                    end,
            setInit = function()
                        if musicOn then
                            return 1
                        else
                            return 2
                        end
                    end
        },
        {
            name = "Object theme",
            values = {"Colorful","Neon","Black and White"},
            callback = function(value)
                        colorScheme = value
                        saveLocalData("colorScheme",colorScheme)
                        ObjectStyles:setTheme()
                    end,
            setInit = function()
                        return colorScheme
                    end
        },
        {
            name = "Conrol mode",
            values = {"Touch","Tilt","Tilt Reversed"},
            callback = function(value)
                        if value == 3 then
                            saveLocalData("controlMode","tiltReversed")
                            controlMode = "tiltReversed"
                        elseif value == 2 then
                            saveLocalData("controlMode","tilt")
                            controlMode = "tilt"
                        elseif value == 1 then
                            saveLocalData("controlMode","touch")
                            controlMode = "touch"
                        end
                    end,
            setInit = function()
                        if controlMode == "touch" then
                            return 1
                        elseif controlMode == "tilt" then
                            return 2
                        else
                            return 3
                        end
                    end
        },
        {
            name = "Allow strobe powerup",
            values = {"On","Off"},
            callback = function(value)
                        if value == 2 then
                            allowStrobe = false
                            saveLocalData("allowStrobe",false)
                            alert("If you disable this, you will loose 25,000 points instead of activating the strobe light.","Caution")
                        elseif value == 1 then
                            allowStrobe = true
                            saveLocalData("allowStrobe",true)
                        end
                    end,
            setInit = function()
                        if allowStrobe then
                            return 1
                        else
                            return 2
                        end
                    end
        },
        {
            name = "Notify achievements",
            values = {"All the time","Every 5","Every 10","Never"},
            callback = function(value)
                        if value == 1 then
                            achievementMultiplier = 1
                        elseif value == 2 then
                            achievementMultiplier = 5
                        elseif value == 3 then
                            achievementMultiplier = 10
                        elseif value == 4 then
                            achievementMultiplier = 0
                        end
                        saveLocalData("achievementMultiplier",achievementMultiplier)
                    end,
            setInit = function()
                        if achievementMultiplier == 1 then
                            return 1
                        elseif achievementMultiplier == 5 then
                            return 2
                        elseif achievementMultiplier == 10 then
                            return 3
                        else -- achievementMultiplier == 0
                            return 4
                        end
                    end
        },
        {
            name = "Show touches",
            values = {"On","Off"},
            callback = function(value)
                        if value == 2 then
                            showTouches = false
                            saveLocalData("showTouches",false)
                        elseif value == 1 then
                            showTouches = true
                            saveLocalData("showTouches",true)
                        end
                    end,
            setInit = function()
                        if showTouches then
                            return 1
                        else
                            return 2
                        end
                    end
        },
        {
            name = "Touch range",
            values = {"None","5","10","20"},
            callback = function(value)
                        if value == 1 then
                            touchRange = 0
                        elseif value == 2 then
                            touchRange = 5
                        elseif value == 3 then
                            touchRange = 10
                        elseif value == 4 then
                            touchRange = 20
                        end
                        saveLocalData("touchRange",touchRange)
                    end,
            setInit = function()
                        if touchRange == 0 then
                            return 1
                        elseif touchRange == 5 then
                            return 2
                        elseif touchRange == 10 then
                            return 3
                        else -- touchRange == 20
                            return 4
                        end
                    end
        },
        {
            name = "Tips",
            values = {"On","Off"},
            callback = function(value)
                        if value == 2 then
                            showTips = false
                            saveLocalData("showTips",false)
                        elseif value == 1 then
                            showTips = true
                            saveLocalData("showTips",true)
                        end
                    end,
            setInit = function()
                        if showTips then
                            return 1
                        else
                            return 2
                        end
                    end
        },
        {
            name = "Show weather",
            values = {"On","Off"},
            callback = function(value)
                        if value == 2 then
                            showWeather = false
                            saveLocalData("showWeather",false)
                        elseif value == 1 then
                            showWeather = true
                            saveLocalData("showWeather",true)
                        end
                        Background:init()
                    end,
            setInit = function()
                        if showWeather then
                            return 1
                        else
                            return 2
                        end
                    end
        }
    }

    if purchases.extraPaddles then
        table.insert(self.settings,{
            name = "Use extra paddle",
            values = {"On","Off"},
            callback = function(value)
                        if value == 1 then
                            useExtraPaddle = true
                        else --if value == 2 then
                            useExtraPaddle = false
                        end
                        saveLocalData("useExtraPaddle",useExtraPaddle)
                    end,
            setInit = function()
                        if useExtraPaddle then
                            return 1
                        else
                            return 2
                        end
                    end
        })
    end

    if debugMode then
        self.settings = {}
        table.insert(self.settings,{
            name = "Reset app",
            values = {"Do it","Should be done"},
            callback = function(value)
                        clearLocalData()
                        restart()
                    end,
            setInit = function()
                        return 1
                    end
        })
        table.insert(self.settings,{
            name = "Beast Mode",
            values = {"On","Off"},
            callback = function(value)
                        if value == 2 then
                            beastMode = false
                            saveLocalData("beastMode",beastMode)
                        elseif value == 1 then
                            beastMode = true
                            saveLocalData("beastMode",beastMode)
                        end
                    end,
            setInit = function()
                        if beastMode then
                            return 1
                        else
                            return 2
                        end
                    end
        })
        table.insert(self.settings,{
            name = "Raininess",
            values = {"0",".25",".5",".75","1"},
            callback = function(value)
                        Background.weather.raininess = (value-1)*.25
                    end,
            setInit = function()
                        return 1--Background.weather.raininess*4+1
                    end
        })
        table.insert(self.settings,{
            name = "Snowiness",
            values = {"0",".25",".5",".75","1"},
            callback = function(value)
                        Background.weather.snowiness = (value-1)*.25
                    end,
            setInit = function()
                        return 1--Background.weather.snowiness*4+1
                    end
        })
        table.insert(self.settings,{
            name = "Windiness",
            values = {"-1","-.75","-.5","-.25","0",".25",".5",".75","1"},
            callback = function(value)
                        Background.weather.windiness = (value-5)*.25
                    end,
            setInit = function()
                        return 1--Background.weather.windiness*4+5
                    end
        })
        table.insert(self.settings,{
            name = "Storminess",
            values = {"0",".25",".5",".75","1"},
            callback = function(value)
                        Background.weather.storminess = (value-1)*.25
                    end,
            setInit = function()
                        return 1--Background.weather.storminess*4+1
                    end
        })
        table.insert(self.settings,{
            name = "Cloudiness",
            values = {"0",".25",".5",".75","1"},
            callback = function(value)
                        Background.weather.cloudiness = (value-1)*.25
                    end,
            setInit = function()
                        return 1--Background.weather.cloudiness*4+1
                    end
        })
        table.insert(self.settings,{
            name = "Time",
            values = {"0",".1",".2",".3",".4",".5",".6",".7",".8",".9","1"},
            callback = function(value)
                        Background.time = (value-1)/10
                    end,
            setInit = function()
                        return 1
                    end
        })
    end


    for i,v in ipairs(self.settings) do
        if not v.action then
            v.value = v.setInit()
        end
    end
    self.startY = HEIGHT/3*2
    self.margin = WIDTH/12
end

function Settings:draw()
    pushStyle()
    pushMatrix()
    resetStyle()
    translate(self.transX,0)
    titleText("Settings",HEIGHT/5*4)
    fontSize(17*gScale)
    textWrapWidth(WIDTH-50)
    textAlign(CENTER)
    fill(textColor)
    font(globalFont)
    fontSize(25)
    sText("Back",40,HEIGHT-20)
    if currentT.x < 80 and currentT.y > HEIGHT-60 and not self.transitioning and touchReady() then
        touchUsed()
        self:leaveTrans()
    end

    local buttonY = 0
    for i,v in ipairs(self.settings) do
        if i > 1 then
            buttonY = buttonY + fontSize()+10*gScale
        end
        fontSize(42)
        fontSize(fontSize()*gScale)
        if v.action then
            sText(v.name,WIDTH/2,self.startY-buttonY)
        else
            sText(v.name,self.margin+textSize(v.name)/2,self.startY-buttonY)
            sText(v.values[v.value],WIDTH-self.margin-textSize(v.values[v.value])/2,self.startY-buttonY)
        end
        if currentT.y < self.startY-buttonY+10 and currentT.y > self.startY-(buttonY + fontSize()+10)+10 and currentT.state == 0 and not self.transitioning and touchReady() and update then
            touchUsed()
            if v.action then
                v.callback()
            else
                v.value = v.value + 1
                if v.value > #v.values then
                    v.value = 1
                end
                v.callback(v.value)
            end
        end
    end


    popStyle()
    popMatrix()
end

function Settings:leaveTrans()
    self.transitioning = true
    mainReverTrans = true
    tween(.2,self,{transX = WIDTH},tween.easing.sinOut,function() changeScene("start") end)
end

function Settings:exit()
    --collectgarbage()
end