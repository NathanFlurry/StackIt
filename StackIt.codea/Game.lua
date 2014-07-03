Game = class()

function Game:init()
    self.paused = false
    self.sharePhoto = false
    self.gameover = false
    
    -- Gameover data:
    --[[self.names = {
        {
            name = "Did you read the manual?",
            score = 0
        },
        {
            name = "You know, you're supposed to catch the objects...",
            score = 2000
        },
        {
            name = "You beat my grandma!",
            score = 4000
        },
        {
            name = "First timer?",
            score = 8000
        },
        {
            name = "Texting and balancing is dangerous",
            score = 10000
        },
        {
            name = "You can do better...",
            score = 12500
        },
        {
            name = "You're getting the hang of it...",
            score = 15000
        },
        {
            name = "Fair enough",
            score = 20000
        },
        {
            name = "Getting there...",
            score = 30000
        },
        {
            name = "Stacker's apprentice",
            score = 50000
        },
        {
            name = "Wow...",
            score = 70000
        },
        {
            name = "Addict",
            score = 100000
        },
        {
            name = "Mega addict",
            score = 130000
        },
        {
            name = "Seriously, get a life",
            score = 175000
        },
        {
            name = "Ain't nothing but a cheater... Cheatin all the time...",
            score = 300000
        },
    }]]

    self.gameOverTrans = HEIGHT
    self.pauseTrans = 0

    self.stackPoints = 0

    self.score = 0
    self.score = self.score + bonuses.score + (purchases.extraScore or 0)*1000
    self.sI = 1
    self.sM = 1
    self.sMPos = vec2(170,HEIGHT-40)
    self.sT = Timer(.1,function() self.score = self.score + self.sI*self.sM end)
    
    self.lives = {}
    self.addLife = function()
        table.insert(self.lives,{size = 0})
        tween(.2,self.lives[#self.lives],{size = 1},tween.easing.sineOut)
    end
    self.subtractLife = function()
        if #self.lives > 0 then
            tween(.2,self.lives[#self.lives],{size = 0},tween.easing.sineOut,function()
                                                                        table.remove(self.lives)
                                                                    end)
        end
    end
    for i = 1,5+bonuses.life+(purchases.extraLives or 0) do
        self:addLife()
    end
    
    self.timePlayed = 0
    self.timePlayedTimer = Timer(1,function()
                self.timePlayed = self.timePlayed + 1
            end)
    
    self.gravity = -2000
    
    self.paddle = Paddle()
    self.objectManager = ObjectManager()
    self.pupManager = PUpManager()
    self.objectManager:addObject()
end

function Game:draw()
    if update then
        self.sT:update()
    end
    
    physics.gravity(0,self.gravity)
    self.paddle:draw()
    self.objectManager:draw()
    
    -- HUD
    pushMatrix()
    pushStyle()

    -- Score
    if self.score < 0 then
        self.score = 0
    end

    local textFill,shadowFill
    if self.score > highscore then
        textFill = color(255, 219, 0, 255)
        shadowFill = color(187, 112, 19, 255)
        tint(255, 219, 0, 255)
        if not self.highscored then
            emitters.highscore:emit(vec2(55,HEIGHT-15),100)
            -- RisingText:addText("Highest score: "..highscore,nil, nil,color(255, 189, 0, 255))
            Notification:add("Highscore: "..tostring(highscore))
            self.highscored = true
        end
    else
        textFill = textColor
        shadowFill = color(127, 127, 127, 255)
        tint(255)
    end
    font(globalFont)
    fontSize(25)

    -- Draw score
    local scoreStr = tostring(self.score)
    local scoreTable = {}
    for i = 6,1,-1 do
        local num = string.sub(scoreStr,-i,-i)
        if type(tonumber(num)) ~= "number" then
            num = "0"
        end
        table.insert(scoreTable,num)
    end
    for i,v in ipairs(scoreTable) do
        sText(v,fontSize()*i*.7,HEIGHT-fontSize(),1,textFill,shadowFill)
    end

    -- Draw StackPoints
    local sPStr = tostring(self.stackPoints)
    local sPTable = {}
    if (purchases.stackPointMultiplier or 1) > 1 then
        table.insert(sPTable,tostring(purchases.stackPointMultiplier))
        table.insert(sPTable,"x")
    end
    for i = 1,string.len(sPStr) do
        local num = string.sub(sPStr,-i,-i)
        if type(tonumber(num)) ~= "number" then
            num = "0"
        end
        table.insert(sPTable,num)
    end
    table.insert(sPTable,"IMG")
    for i,v in ipairs(sPTable) do
        if v == "IMG" then
            sSprite(imgs.coin,fontSize()*(#scoreTable-i+1)*.7-fontSize()/2,HEIGHT-fontSize()*2,1,fontSize()*.8)
        else
            sText(v,fontSize()*(#scoreTable-i+1)*.7,HEIGHT-fontSize()*2,1,textFill,shadowFill)
        end
    end
    
    -- Draw score multiplier
    local sMStr = tostring(self.sM)
    local sMTable = {}
    for i = 1,string.len(self.sM) do
        local num = string.sub(sMStr,-i,-i)
        if type(tonumber(num)) ~= "number" then
            num = "0"
        end
        table.insert(sMTable,num)
    end
    table.insert(sMTable,"x")
    for i,v in ipairs(sMTable) do
        sText(v,fontSize()*(#scoreTable-i+1)*.7,HEIGHT-fontSize()*3,1,textFill,shadowFill)
    end

    -- Highscore particles
    -- Draw lives
    fontSize(30)
    tint(255, 0, 0, 255)
    for i,v in ipairs(self.lives) do
        pushMatrix()
        translate((WIDTH-(i+1)*25)+0,HEIGHT-20)
        scale(v.size)
        sSprite(imgs.heart,0,0)
        popMatrix()
    end

    -- Draw TimerDisplay
    if not self.gameover then
        self.pupManager:draw()
    end

    -- Pause
    tint(255, 255, 255, 255)
    sSprite(imgs.pause,WIDTH-20,HEIGHT-20)
    if testTouchRegion(WIDTH-20,HEIGHT-20,60,60) and currentT.state == BEGAN and update then --and not self.paused
        self.paused = true
        update = false
        physics.pause()
    end
        
    popMatrix()
    popStyle()
    if #self.lives < 1 then
        self.gameover = true
        update = false
        physics.pause()
    end

    -- Capture screen

    pushStyle()
    tint(255)
    sprite(imgs.picture,WIDTH-25,25)
    if testTouchRegion(WIDTH-25,25,50,50) and currentT.state == BEGAN and not self.gameover and not self.paused and not self.sharePhoto then
        captureScreen = 1
    end
    popStyle()

    if captureScreen == 3 then
        self.sharePhoto = true
        update = false
        captureScreen = 0
        physics.pause()
    end

    -- Power ups
    pushMatrix()
    local pos = vec2(20,HEIGHT-115)
    fontSize(20)
    fill(255)
    local textX = 15
    local sizeY = 45
    for i = 1,4 do
        local img
        local txt
        local col
        local canUse
        local storeIndex
        if i == 1 then
            col = color(255,0,0)
            img = imgs.heart
            txt = (purchases.addLife or 0)
            storeIndex = 5
        elseif i == 2 then
            col = color(255,197,0)
            img = imgs.nuke
            txt = (purchases.nuke or 0)
            storeIndex = 6
        elseif i == 3 then
            col = color(255,255,255)
            img = imgs.glue
            txt = (purchases.glue or 0)
            storeIndex = 7
        elseif i == 4 then
            col = color(50, 160, 255, 255)
            img = imgs.nullGravity
            txt = (purchases.nullGravity or 0)
            storeIndex = 8
        end

        pushStyle()
        tint(col)
        sprite(img,pos.x,pos.y)
        text(txt,pos.x+textX+textSize(txt)/2,pos.y)
        popStyle()
        
        if testTouchRegion(pos.x,pos.y,100,sizeY) and currentT.state == BEGAN and not self.gameover and not self.paused and not self.sharePhoto then

            local activate = false
            local subractWhenActivate = true
            if txt > 0 and currentT.tapCount == 1 then
                --[[if i == 1 then
                    self.objectManager.powerups.addLife:catchFunc()
                    purchases.addLife = purchases.addLife - 1
                elseif i == 2 then
                    self.objectManager.powerups.nuke:touchFunc()
                    purchases.nuke = purchases.nuke - 1
                elseif i == 3 then
                    self.objectManager.powerups.glue:touchFunc()
                    purchases.glue = purchases.glue - 1
                elseif i == 4 then
                    self.objectManager.powerups.nullGravity:touchFunc()
                    self.pupManager:addT(self.objectManager.powerups.nullGravity)
                    purchases.nullGravity = purchases.nullGravity - 1
                end]]
                activate = true
            elseif currentT.tapCount == 2 then
                local cost = Store().items[storeIndex].cost
                if stackPoints - cost >= 0 then
                    if i == 1 then
                        -- purchases.addLife = (purchases.addLife or 0) + 1
                        addStackPoints(-cost)
                    elseif i == 2 then
                        -- purchases.nuke = (purchases.nuke or 0) + 1
                        addStackPoints(-cost)
                    elseif i == 3 then
                        -- purchases.glue = (purchases.glue or 0) + 1
                        addStackPoints(-cost)
                    elseif i == 4 then
                        -- purchases.nullGravity = (purchases.nullGravity or 0) + 1
                        addStackPoints(-cost)
                    end
                    activate = true
                    subractWhenActivate = false
                    -- Notification:add("Purchased")
                else
                    Notification:add("You cannot afford this")
                end
            elseif currentT.tapCount == 1 then
                -- Notification:add("Double tap to purchase and use more")
            end

            if activate then
                if i == 1 then
                    self.objectManager.powerups.addLife:catchFunc()
                    if subractWhenActivate then
                        purchases.addLife = purchases.addLife - 1
                    end
                elseif i == 2 then
                    self.objectManager.powerups.nuke:touchFunc()
                    if subractWhenActivate then
                        purchases.nuke = purchases.nuke - 1
                    end
                elseif i == 3 then
                    self.objectManager.powerups.glue:touchFunc()
                    if subractWhenActivate then
                        purchases.glue = purchases.glue - 1
                    end
                elseif i == 4 then
                    self.objectManager.powerups.nullGravity:touchFunc()
                    self.pupManager:addT(self.objectManager.powerups.nullGravity)
                    if subractWhenActivate then
                        purchases.nullGravity = purchases.nullGravity - 1
                    end
                end
            end

            saveLocalData("purchases",tToS("purchases",purchases))
        end

        pos.y = pos.y - sizeY
    end
    popMatrix()

    -- Special overlays
    if self.paused then
        if not self.pauseInit then
            self.pauseAnimation = tween(.5,self,{pauseTrans = 1},tween.easing.elasticOut)

            self.pauseInit = true
        end
    
        physics.pause()
        pushStyle()
        pushMatrix()
        

        scale(self.pauseTrans)
        translate(WIDTH/2/self.pauseTrans-WIDTH/2,HEIGHT/2/self.pauseTrans-HEIGHT/2)
        
        fill(127, 127, 127, 57)
        rect(0,0,WIDTH,HEIGHT)
        fill(textColor)
        fontSize(75)
        sText("Paused",WIDTH/2,HEIGHT/3*2)
        fontSize(35*gScale)
        sText("Menu",WIDTH/3,HEIGHT/2)
        sText("Resume",WIDTH/3*2,HEIGHT/2)
        if testTouchRegion(WIDTH/4,HEIGHT/2,WIDTH/2,70) and currentT.state == BEGAN then
            touchUsed()
            update = true
            physics.resume()
            self.pauseInit = nil
            addStackPoints(self.stackPoints*(purchases.stackPointMultiplier or 1))
            changeScene("start")
        elseif testTouchRegion(WIDTH/4*3,HEIGHT/2,WIDTH/2,70) and currentT.state == BEGAN then
            touchUsed()
            self.pauseTrans = 0
            self.pauseAnimation = nil
            scene.paddle.prevT = nil
            self.paused = false
            update = true
            physics.resume()
            self.paddle.startGrav = Gravity.x-(self.paddle.dR/self.paddle.sensitivity)
            self.pauseInit = nil
        end

        tint(255)
        sSprite(imgs.restart,WIDTH/2,35)
        if testTouchRegion(WIDTH/2,35,60,60) and currentT.state == 0 then
            update = true
            physics.resume()
            addStackPoints(self.stackPoints*(purchases.stackPointMultiplier or 1))
            changeScene("game")
        end
        
        fontSize(17)
        text("Highscore: "..highscore,WIDTH/2,HEIGHT/4)

        drawStackPoints(vec2(WIDTH/2,HEIGHT/4-fontSize()*2),self.stackPoints)
        
        popStyle()
        popMatrix()

    elseif self.sharePhoto then

        pushStyle()
        pushMatrix()

        fill(127, 127, 127, 57)
        rect(0,0,WIDTH,HEIGHT)
        fill(textColor)
        fontSize(75*gScale)
        tint(255)

        sText("Share screenshot:",WIDTH/2,HEIGHT/3*2)


        sSprite(imgs.twitter,WIDTH/4,HEIGHT/2,2,stackPointsCoinSize*gScale)
        if testTouchRegion(WIDTH/4,HEIGHT/2,200*gScale,200*gScale) and currentT.state == 0 then
            sendTweet("Check out my structure in #StackItGame! bit.ly/1gyCGV8",capturedScreen)
            
            self.sharePhoto = false
            self.paused = true
        end

        sSprite(imgs.download,WIDTH/2,HEIGHT/2,2,stackPointsCoinSize*gScale)
        if testTouchRegion(WIDTH/2,HEIGHT/2,200*gScale,200*gScale) and currentT.state == 0 then
            savePhoto(capturedScreen)
            alert("Photo saved")

            self.sharePhoto = false
            self.paused = true
        end

        sSprite(imgs.facebook,WIDTH/4*3,HEIGHT/2,2,stackPointsCoinSize*gScale)
        if testTouchRegion(WIDTH/4*3,HEIGHT/2,200*gScale,200*gScale) and currentT.state == 0 then
            sendFaceBook("Check out my structure in #StackItGame! bit.ly/1gyCGV8",capturedScreen)

            self.sharePhoto = false
            self.paused = true
        end

        fontSize(17)
        sText("Cancel",40,20)
        if testTouchRegion(40,20,80,30) and currentT.state == 0 then
            self.sharePhoto = false
            self.paused = true
        end

        popStyle()
        popMatrix()
    elseif self.gameover then
        if not self.gameOverInit then
            self.gameOverAnimation = tween.sequence(tween.delay(0.2),tween(.2,self,{gameOverTrans = 0},tween.easing.linear))

            -- sound(sounds.loose) --v1.1

            addStackPoints(self.stackPoints*(purchases.stackPointMultiplier or 1))

            local reportIncrement = 2500
            local scoreTester = self.score
            scoreTester = scoreTester / reportIncrement
            scoreTester = math.floor(scoreTester)
            scoreTester = scoreTester * reportIncrement

            --[[for i,v in ipairs(self.names) do
                if v.score <= self.score then
                    self.name = v.name
                end
            end]]

            reportScore(self.score,"highscore")

            lastScore = self.score
            saveLocalData("lastScore",lastScore)
            
            strobeOn = false

            self.lighting = getGradient(vec2(WIDTH,HEIGHT),color(255,200),color(255,0))
            
            table.insert(scoreHistory,self.score)
            table.sort(scoreHistory,function(v1,v2)
                                        if v1 > v2 then
                                            return true
                                        else
                                            return false
                                        end
                                    end)
            for i,v in ipairs(scoreHistory) do
                if self.score == v then
                    self.rank = i
                end
            end
            if self.rank == nil then
                self.rank = 0
            end
            
            saveLocalData("scoreHistory",tToS("scoreHistory",scoreHistory))
            if self.score > highscore then
                highscore = self.score
                saveLocalData("highscore",self.score)
                reportScore(self.score,"highscore")
            end
            if self.timePlayed > longestPlay then
                longestPlay = self.timePlayed
                saveLocalData("longestPlay",self.timePlayed)
                reportScore(self.timePlayed,"longestplay")
            end
            totalPlayTime = totalPlayTime + self.timePlayed
            saveLocalData("totalPlayTime",totalPlayTime)

            addHTMLWebView("topScores",HTMLScoreDisplay(scoreHistory,self.rank),0,0 --[[Set later in code]],WIDTH,HEIGHT-HEIGHT/9-HEIGHT/8-200*gScale)

            if #scoreHistory > 12 and math.random() < .1 then
                local titles = {
                        "Aw, come on.",
                        "Seriously?",
                        "Really?"
                    }
                local title = titles[math.random(#titles)]
                local message = "You've played StackIt "..#scoreHistory.." times for a total of "..math.ceil(totalPlayTime/60).." minutes. Don't you think it's time to give StackIt a litle love?"
                advancedAlert(title,message,"Maybe later",{"Rate StackIt","Tweet about StackIt","Post on FaceBook about StackIt"},
                    function(index,title)
                        if index == 1 then
                            --rateApp("741575975")
                            openURL("http://appstore.com/StackItGame",false)
                        elseif index == 2 then
                            sendTweet("Check out #StackIt on the App Store: bit.ly/1gyCGV8")
                        elseif index == 3 then
                            sendFaceBook("Check out #StackIt on the App Store: bit.ly/1gyCGV8")
                        end
                    end)
            end

            self.gameOverShareWidget = ShareWidget("I got "..self.score.." points in #StackItGame! bit.ly/1gyCGV8")

            self.gameOverInit = true
        end

        setWebViewY("topScores",-self.gameOverTrans+HEIGHT/9+150*gScale)

        pushStyle()
        pushMatrix()
        resetStyle()
        
        translate(0,self.gameOverTrans)
        
        fill(textColor)
        font(globalFont)
        fill(0, 0, 0, 100)
        rect(0,0,WIDTH,HEIGHT)
        pushMatrix()
        translate(WIDTH/2,HEIGHT/4*3)
        self.lighting:draw()
        popMatrix()
        fill(textColor)

        -- Draw title
        
        fontSize(100*gScale)
        textWrapWidth(WIDTH-50)
        textAlign(CENTER)
        sText("Game Over",WIDTH/2,HEIGHT/9*8)
        
        self.gameOverShareWidget:draw(vec2(WIDTH/2,HEIGHT/9*8-100*gScale))

        local buttonHeightDivisor = 8
        fontSize(35*gScale)
        sText("Menu",WIDTH/3,HEIGHT/buttonHeightDivisor)
        sText("Play Again",WIDTH/3*2,HEIGHT/buttonHeightDivisor)
        if currentT.y < HEIGHT/buttonHeightDivisor+35 and currentT.y > HEIGHT/buttonHeightDivisor-35 and currentT.state == 0 and touchReady() then
            if currentT.x < WIDTH/2 then
                touchUsed()
                update = true
                physics.resume()
                changeScene("start")
            elseif currentT.x > WIDTH/2 then
                touchUsed()
                update = true
                physics.resume()
                changeScene("game")
            end
    end

    drawStackPoints(vec2(WIDTH/2,fontSize()),0,true)

    

    popStyle()
    popMatrix()

    elseif update then
        self.timePlayedTimer:update()
    end
end

function Game:collide(c)
    self.objectManager:contact(c.bodyA,c.bodyB,c.position)
end

function Game:exit()
    if self.gameover then
        removeWebView("topScores")
    end
    for i,v in ipairs(self.pupManager.timers) do
        v:endFunc()
    end
    self.objectManager:destroyAll()
    for i,v in ipairs(self.paddle.paddles) do
        v.body:destroy()
    end
    self.paddles = nil
    self.paddle = nil
    self.objectManager = nil
    self.pupManager = nil
end