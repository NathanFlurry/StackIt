-- StackIt

supportedOrientations(PORTRAIT_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
--displayMode(OVERLAY)


function setup()
    --getLineCount()
    
    rad = math.pi*2

    json = require('json')
    weatherLib = require('weatherlib')

    debugMode = false
    
    gScale = WIDTH/768
    gScaleHeight = HEIGHT/1024

    imgNames = {
        about = "About",
        bounce = "Bouncy",
        check = "Checkmark",
        cloud1 = "Cloud1",
        cloud1Plain = "Cloud1Plain",
        cloud2 = "Cloud2",
        cloud2Plain = "Cloud2Plain",
        cloud3 = "Cloud3",
        cloud3Plain = "Cloud3Plain",
        coin = "Coin",
        coinSmall = "CoinSmall",
        download = "Download",
        drop = "Drop",
        expandPaddle = "ExpandPaddle",
        explosion = "Explosion",
        extraPaddle = "ExtraPaddle",
        facebook = "FaceBook",
        gamecenter = "GameCenter",
        glue = "Glue",
        heart = "Heart",
        interDazzleSmall = "InterDazzleSmall",
        locationError = "LocationError",
        logo = "Logo",
        nuke = "Nuke",
        nullGravity = "Null Gravity",
        pause = "Pause",
        picture = "Picture",
        play = "Play",
        purchase = "Purchase",
        raindrop = "Raindrop",
        restart = "Restart",
        settings = "Settings",
        snowflake = "Snowflake",
        stackPointDoubler = "StackPointDoubler",
        stackPointTripler = "StackPointTripler",
        star = "Star",
        stickyPaddleSides = "StickyPaddleSides",
        storeSmall = "StoreLogoSmall",
        strobe = "Strobe",
        triangle = "Triangle",
        twitter = "Twitter",
        weatherError = "WeatherError",
        x = "X"
    }

    imgs = {}
    for i,v in pairs(imgNames) do
        --imgs[i] = readImage("Documents:"..v)
        imgs[i] = "Documents:"..v
    end

    stackPointsCoinSize = readImage(imgs.coin).width
    
    mainReverTrans = false
    
    tUsedID = 0

    firstRun = readLocalData("firstRun",true)
    
    font("Futura-Medium")
    textColor = color(255, 255, 255, 255)
    globalFont = font()
    
    overlayColor = color(0,0,0,255)
    initOverlayDelay = tween(1.0,overlayColor,{r = 0, g = 0, b = 0, a = 255})
    initOverlayFadeIn = tween(2.0,overlayColor,{r = 0, g = 0, b = 0, a = 0})
    tween.sequence(initOverlayDelay,initOverlayFadeIn)

    shadowColor = color(0, 0, 0, 50)
    shadowOffset = vec2(0,0)
    shadowBlur = 10*ContentScaleFactor
    
    strobeFrameSkip = 10
    strobeFrameCount = 0

    stackPoints = readLocalData("stackPoints",100)
    
    colorScheme = readLocalData("colorScheme",1)
    highscore = readLocalData("highscore",0)
    lastScore = readLocalData("lastScore",0)
    mostObjects = readLocalData("mostObjects",0)
    mostScoreAddition = readLocalData("mostScoreAddition",0)
    tallestTower = readLocalData("tallestTower",0)
    longestPlay = readLocalData("longestPlay",0)
    totalPlayTime = readLocalData("totalPlayTime",0)
    totalEarned = readLocalData("totalEarned",0)
    totalSpent = readLocalData("totalSpent",0)

    allowStrobe = readLocalData("allowStrobe",true)

    achievementMultiplier = readLocalData("achievementMultiplier",5)
    
    scoreHistory = readLocalData("scoreHistory","scoreHistory = {}")
    assert(loadstring(scoreHistory))()
    
    seenObjects = readLocalData("seenObjects","seenObjects = {}")
    assert(loadstring(seenObjects))()
    
    beastMode = readLocalData("beastMode",false)

    musicOn = readLocalData("musicOn",true)
    music("Documents:FreeFall",true)
    if musicOn then
        music.paused = false
    else
        music.paused = true
    end
    music.volume = .7
    sfxOn = true

    controlMode = readLocalData("controlMode","touch")

    showTouches = readLocalData("showTouches",false)

    touchRange = readLocalData("touchRange",5)

    showTips = readLocalData("showTips",true)

    showWeather = readLocalData("showWeather",true)
    
    strobeOn = false
    showStrobe = false
    strobeTimer = Timer(.5,function()
                                showStrobe = true
                            end)

    purchases = readLocalData("purchases","purchases = {}")
    assert(loadstring(purchases))()
    if purchases.stackPointMultiplier == nil then
        purchases.stackPointMultiplier = 1
    end

    useExtraPaddle = readLocalData("useExtraPaddle",true)

    bonuses = {
        score = 0,
        life = 0
    }

    iapItems = {}
    registerItem("stackPointDoubler")
    registerItem("stackPointTripler")
    initStore()
    storeReady = false
    purchasePending = false

    feedbackCallback = nil

    update = true

    savedDataNeedsUpdate = false

    captureScreen = 0
    capturedScreen = image(WIDTH,HEIGHT)

    emitters = {
        collide = Emitter( {
                            startColor = textColor,
                            endColor = color(textColor.r, textColor.g, textColor.b,0),
                            minSize = 2,
                            maxSize = 2,
                            minSpeed = 50,
                            maxSpeed = 75,
                            minLife = .5,
                            maxLife = 1,
                            accel = vec2(0,-300),
                            rAccel = vec2(500,500),
                            streak = true
                           } ),
        highscore = Emitter( { 
                        tex = imgs.star,
                        startColor = color(255, 200, 0, 149),
                        endColor = color(68, 59, 30, 0),
                        minSize = 5,
                        maxSize = 15,
                        minSpeed = 100,
                        maxSpeed = 150,
                        minLife = 3,
                        maxLife = 8,
                        accel = vec2(0,-300),
                        rAccel = vec2(500,500),
                        streak = false
                       } ),
        touch = Emitter( {
                            startColor = color(195, 195, 195, 255),
                            endColor = color(127, 127, 127, 0),
                            minSize = 1,
                            maxSize = 1,
                            minSpeed = 50,
                            maxSpeed = 75,
                            minLife = .5,
                            maxLife = 1,
                            accel = vec2(0,-300),
                            rAccel = vec2(500,500),
                            streak = true
                           } ),
        tnt = Emitter( {
                            startColor = color(255, 69, 0, 255),
                            endColor = color(255, 142, 0, 0),
                            minSize = 2,
                            maxSize = 2,
                            minSpeed = 200,
                            maxSpeed = 500,
                            minLife = .1,
                            maxLife = 1,
                            accel = vec2(0,-100),
                            rAccel = vec2(500,500),
                            streak = true
                           } ),
        slippery = Emitter( {
                            tex = imgs.drop,
                            startColor = color(0, 170, 255, 255),
                            endColor = color(0, 170, 255, 0),
                            minSize = 10,
                            maxSize = 10,
                            minSpeed = 50,
                            maxSpeed = 75,
                            minLife = .5,
                            maxLife = 1,
                            accel = vec2(0,-500),
                            rAccel = vec2(100,100),
                            streak = false
                           } ),
        bouncy = Emitter( {
                            tex = imgs.bounce,
                            startColor = color(174, 99, 228, 255),
                            endColor = color(174, 99, 228, 0),
                            minSize = 10,
                            maxSize = 10,
                            minSpeed = 50,
                            maxSpeed = 75,
                            minLife = .5,
                            maxLife = 1,
                            accel = vec2(0,-500),
                            rAccel = vec2(100,100),
                            streak = false
                           } ),
        nullGravity = Emitter( {
                            tex = imgs.nullGravity,
                            startColor = color(48, 0, 255, 255),
                            endColor = color(48, 0, 255, 0),
                            minSize = 10,
                            maxSize = 10,
                            minSpeed = 50,
                            maxSpeed = 75,
                            minLife = .5,
                            maxLife = 1,
                            accel = vec2(0,-500),
                            rAccel = vec2(100,100),
                            streak = false
                           } ),
        glue = Emitter( {
                            tex = imgs.drop,
                            startColor = color(255, 255, 255, 255),
                            endColor = color(255, 255, 255, 0),
                            minSize = 10,
                            maxSize = 10,
                            minSpeed = 50,
                            maxSpeed = 75,
                            minLife = .5,
                            maxLife = 1,
                            accel = vec2(0,-500),
                            rAccel = vec2(100,100),
                            streak = false
                           } ),
    }
    

    ObjectStyles:init()
    touches:init()
    Background:init()
    ObjectFunctions:init()
    RisingText:init()
    FadingImage:init()
    Notification:init()
    
    sounds = {
        hit = "Documents:Thump",
        oReady = "Documents:ObjectReady",
        looseObject = "Documents:LooseObject",
        loose = "Documents:GameOver"
    }

    authenticatePlayer()

    if firstRun then
        changeScene("howtoplay")
    else
        changeScene("start")
    end

    lastPlayDate = readLocalData("lastPlayDate","lastPlayDate = {}")
    assert(loadstring(lastPlayDate))()
    local d = os.date("*t")
    if lastPlayDate.year ~= d.year or lastPlayDate.month ~= d.month or lastPlayDate.day ~= d.day then
        addStackPoints(20)
        local title
        if firstRun then
            title = "Welcome to StackIt!"
        else
            title = "Thank you for coming back!"
        end
        alert("You have been awarded 20 StackPoints. Come back tomorrow for 20 more.",title)
    end
    lastPlayDate = d
    saveLocalData("lastPlayDate",tToS("lastPlayDate",lastPlayDate))
end

function draw()
    
    background(255,255,255)
    noSmooth()
    
    music.pan = Gravity.x
    
    if touches:count() >= 1 then
        currentT = touches:get()[1]
    else
        currentT = {
            id = 1234,
            x = 10000,
            y = 10000,
            prevX = 10000,
            prevY = 10000,
            deltaX = 0,
            deltaY = 0,
            state = 0,
            tapCount = 1
        }
    end
    
    setShadow()

    -- Capture screen
    if captureScreen == 1 then
        --capturedScreen = image(WIDTH,HEIGHT)
        setContext(capturedScreen)
        captureScreen = 2
    end

    -- Do drawing
    Background:draw()
    
    pushMatrix()
    
    scene:draw()
    popMatrix()

    feedbackCallbackTest()
    
    RisingText:draw()
    FadingImage:draw()
    
    -- Draw particles
    for i,v in pairs(emitters) do
        v:draw()
    end

    -- End capture screen
    if captureScreen == 2 then
        setContext()

        pushStyle()
        tint(255)
        sprite(capturedScreen,WIDTH/2,HEIGHT/2)
        popStyle()

        captureScreen = 3
    end
    
    if strobeOn then
        strobeTimer:update()
        if not showStrobe then
            pushStyle()
            noStroke()
            fill(0, 0, 0, 255)
            rect(-1,-1,WIDTH+2,HEIGHT+2)
            popStyle()
        else
            showStrobe = false
        end
    end

    Notification:draw()

    pushStyle()

    fill(overlayColor)
    noStroke()
    rect(-1,-1,WIDTH+2,HEIGHT+2)

    popStyle()

    if showTouches then
        pushStyle()
        fill(255,100)
        for i,t in pairs(touches:get()) do
            ellipse(t.x,t.y,50)
        end
        popStyle()
    end
    
    touches:maitmence()
    
    frameCount = (frameCount or 0) + 1

    gcAddOn_GarbageCollect()

end

function displayLuaMemory()
    text(math.floor(collectgarbage("count")), WIDTH/2, HEIGHT / 4)    
end

function displayFrameRates()
    local frameRate = math.floor(1 / DeltaTime)
    if frameRate < 50 then
        if frameRate < 20 then
            frameRate_reallySlow = frameRate
        else
            frameRate_slow = frameRate
        end
    end
    text(frameRate.."\n"..(frameRate_slow or 0).."\n"..(frameRate_reallySlow or 0), WIDTH/2, HEIGHT / 8)
end

function feedbackCallbackTest()
    if feedbackCallback == 1 then
        advancedAlert("What would you like to do?","","Cancel",{"Write a review","Contact InterDazzle","Tweet about StackIt","Post on FaceBook about StackIt"},
            function(index,title)
                if index == 1 then
                    --rateApp("741575975")
                    openURL("http://appstore.com/StackItGame",false)
                elseif index == 2 then
                    sendEmail("support@interdazzle.com","I love StackIt",getSupportMessage())
                elseif index == 3 then
                    sendTweet("Check out #StackIt on the App Store: https://itunes.apple.com/us/app/stackit-game/id741575975?ls=1&mt=8")
                elseif index == 4 then
                    sendFaceBook("Check out #StackIt on the App Store: https://itunes.apple.com/us/app/stackit-game/id741575975?ls=1&mt=8")
                end
            end)
    elseif feedbackCallback == 2 then
        advancedAlert("What would you like to do?","","Cancel",{"Got to help screen","Contact InterDazzle"},
            function(index,title)
                if index == 1 then
                    changeScene("howtoplay")
                elseif index == 2 then
                    sendEmail("support@interdazzle.com","I'm confused about StackIt",getSupportMessage())
                end
            end)
    elseif feedbackCallback == 3 then
        sendEmail("support@interdazzle.com","I'm disappointed with Stackit",getSupportMessage())
    elseif feedbackCallback == 4 then
        sendEmail("support@interdazzle.com","I'd like to talk to you",getSupportMessage())
    end

    if feedbackCallback then
        feedbackCallback = nil
    end
end

function setShadow()
    shadowOffset = Gravity
end

function touched(t)
    if sID ~= "game" then
        if debugMode then
            local emitterCount = 0
            for i,v in pairs(emitters) do
                emitterCount = emitterCount + 1
            end
            local emitterSelection = math.random(emitterCount)
            emitterCount = 0
            for i,v in pairs(emitters) do
                emitterCount = emitterCount + 1
                if emitterCount == emitterSelection then
                    v:emit(vec2(t.x,t.y),5)
                end
            end
        else
            emitters.touch:emit(vec2(t.x,t.y),5)
        end
    end
    touches:update(t)

    if scene.touched then
        scene:touched(t)
    end

    -- Enable debug
    local threshold = 10
    if t.x > WIDTH-threshold and t.y > HEIGHT-threshold and t.tapCount >= 5 then
        if debugMode then
            debugMode = false
        else
            debugMode = true
        end
    end
end

function collide(c)

    if sID == "game" then
        scene:collide(c)
    end
end

function resetGame()
    clearLocalData()
    restart()
end
