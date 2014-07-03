ObjectManager = class()

function ObjectManager:init()
    -- Define powerups (Variables: name, img(replace with vector shape later), catchFunc, useFunc, lastTime, endFunc, level)
    self.powerups =
    {
        addLife = {
            -- Required
            name = "Add life",
            col = color(255, 0, 0, 255),
            img = imgs.heart,
            level = 5,
            chance = 3,
            bad = false,
            
            -- Not required
            catchFunc = function() scene:addLife() end
        },
        scoreBonus = {
            -- Required
            name = "Score bonus",
            col = color(255, 200, 0, 255),
            img = imgs.star,
            level = 0,
            chance = 2,
            bad = false,
            
            -- Not required
            catchFunc = function()
                scene.score = scene.score + 500
            end
        },
        megaScoreBonus = {
            -- Required
            name = "Mega score bonus",
            col = color(0, 189, 255, 255),
            img = imgs.star,
            level = 5,
            chance = .5,
            bad = false,
            
            -- Not required
            catchFunc = function()
                scene.score = scene.score + 2500
            end
        },
        coinBonus = {
            -- Required
            name = "StackPoint bonus",
            col = color(255, 200, 0, 255),
            img = imgs.coinSmall,
            level = 0,
            chance = .5,
            bad = false,
            
            -- Not required
            catchFunc = function()
                scene.stackPoints = scene.stackPoints + 20
            end
        },
        megaCointBonus = {
            -- Required
            name = "Mega StackPoint bonus",
            col = color(0, 189, 255, 255),
            img = imgs.coinSmall,
            level = 5,
            chance = .2,
            bad = false,
            
            -- Not required
            catchFunc = function()
                scene.stackPoints = scene.stackPoints + 50
            end
        },
        makeSlippery = {
            -- Required
            name = "Make slippery",
            col = color(0, 170, 255, 255),
            img = imgs.drop,
            level = 6,
            chance = 1.5,
            bad = true,
            
            -- Not required
            touchFunc = function(p,o)
                self:setPProperties("friction",0)
                emitters.slippery:emit(vec2(o.body.x,o.body.y),100)
                self:destroyObject(o)
            end,
        },
        makeBouncy = {
            -- Required
            name = "Make bouncy",
            col = color(174, 99, 228, 255),
            img = imgs.bounce,
            level = 6,
            chance = 1.5,
            bad = true,
            
            -- Not required
            touchFunc = function(p,o)
                self:setPProperties("restitution",1.2)
                emitters.bouncy:emit(vec2(o.body.x,o.body.y),50)
                self:destroyObject(o)
            end
        },
        tnt = {
            -- Required
            name = "TNT",
            col = color(255, 69, 0, 255),
            img = imgs.explosion,
            level = 3,
            chance = 2,
            bad = true,
            
            -- Not required
            touchFunc = function(p,o)
                for i,o in ipairs(self.oList) do
                    o.body.linearVelocity = vec2(math.random(-5000,5000),math.random(-5000,5000))
                end
                emitters.tnt:emit(vec2(o.body.x,o.body.y),100)
                self:destroyObject(o)
            end
        },
        nuke = {
            -- Required
            name = "Nuke",
            col = color(255, 197, 0, 255),
            img = imgs.nuke,
            level = 3,
            chance = .7,
            bad = true,
            mightBeGood = true,
            
            -- Not required
            touchFunc = function()
                overlayColor = color(255, 255, 255, 255)
                tween.sequence(
                    tween.delay(1),
                    tween(3,overlayColor,{a = 0})
                )
                self:destroyAll(false,true)
            end
        },
        strobe = {
            -- Required
            name = "Strobe light",
            col = color(255, 255, 255, 255),
            img = imgs.strobe,
            level = 3,
            chance = 1,
            bad = true,
            
            -- Not required
            touchFunc = function(p,o)
                self:destroyObject(o)
                if not allowStrobe then
                    scene.score = scene.score - 25000
                    Notification:add("Strobe light disabled")
                    RisingText:addText("-25000",scene.sMPos.x,scene.sMPos.y,color(255,0,0))
                end
            end,
            
            useFunc = function()
                if allowStrobe then
                    strobeOn = true
                end
            end,
            
            endFunc = function()
                strobeOn = false
            end,

            lastTime = 20,
            onImpact = true
        },
        nullGravity = {
            -- Required
            name = "Null gravity",
            col = color(50, 160, 255, 255),
            img = imgs.nullGravity,
            level = 6,
            chance = 1,
            bad = true,
            mightBeGood = true,
            
            -- Not required
            touchFunc = function(p,o)
                if o then
                    emitters.nullGravity:emit(vec2(o.body.x,o.body.y),100)
                    self:destroyObject(o)
                end
            end,
            
            useFunc = function()
                scene.gravity = 0
            end,
            
            endFunc = function()
                scene.gravity = -2000
            end,

            lastTime = 20,
            onImpact = true
        },
        scoreMultiplier = {
            -- Required
            name = "Score multiplier",
            col = color(255, 0, 0, 255),
            img = imgs.star,
            level = 3,
            chance = .8,
            bad = false,
            
            -- Not required
            catchFunc = function(p,o)
                scene.sM = scene.sM + 30
                scene.displacement = (scene.displacement or 0) + 10
            end,
            
            useFunc = function()
            end,
            
            endFunc = function()
                scene.sM = scene.sM - scene.displacement
                scene.displacement = 0
            end,

            lastTime = 20
        },
        glue = {
            -- Required
            name = "Glue",
            col = color(255, 255, 255, 255),
            img = imgs.glue,
            level = 9,
            chance = 1.5,
            bad = false,
            
            -- Not required
            touchFunc = function(p,o)
                --[[for i1,o1 in ipairs(self.oList) do
                    for i2,o2 in ipairs(self.oList) do
                        local addJoint = true
                        if o1 == o2 or o1.phase == 0 or o2.phase == 0 then
                            addJoint = false
                        end
                        for i,j in ipairs(self.oJointList) do
                            if j.uID == o1.id + o2.id then
                                addJoint = false
                            end
                        end
                        if addJoint then
                            local j = physics.joint(WELD,
                                            o1.body,
                                            o2.body,
                                            vec2(
                                                (o1.body.x+o2.body.x)/2,
                                                (o1.body.y+o2.body.y)/2
                                            )
                                        )
                            j.uID = o1.id + o2.id
                            j.frequency = 0

                            table.insert(self.oJointList,j)
                        end
                    end
                end]]
                for i,o in ipairs(self.oList) do
                    ObjectFunctions:jointObject(o)
                end
                if o then
                    emitters.glue:emit(vec2(o.body.x,o.body.y),100)
                    self:destroyObject(o)
                end
            end
        }
    }
    self.chanceOfPUp = .33

    if not allowStrobe then
        self.powerups.strobe.lastTime = 0
    end
    
    self.maxSpeed = -100

    self.maxRotateSpeed = 100
    self.rotateLevel = 5000
    self.rotateChance = .2

    self.maxWaveSpeed = 3
    self.maxWaveAmnt = 100
    self.waveLevel = 8000
    self.waveChance = .16
    
    self.objectSpawnSpeed = 6
    self.objectLife = 4.5
    self.timerSize = 15*gScale
    
    self.fixedRotation = false

    self.oSize = 20*gScale
    
    if beastMode then
        self.chanceOfPUp = .8
        self.maxSpeed = -200
        self.maxRotateSpeed = 100
        self.rotateLevel = 0
        self.rotateChance = .3
        self.objectSpawnSpeed = 3
        self.objectLife = 1.5
        self.fixedRotation = true
    end
        
    
    self.oList = {}
    self.oJointList = {}
    self.objectTimer = Timer(self.objectSpawnSpeed,function() self:addObject() end)
    self.speedUpT = Timer(3,function()
                            -- Speed up spawn speed
                            self.objectSpawnSpeed = self.objectSpawnSpeed - self.objectSpawnSpeed/100
                            self.objectTimer.interval = self.objectSpawnSpeed
                            
                            -- Speed up object fall speed
                            self.maxSpeed = self.maxSpeed + self.maxSpeed/150
                            
                            -- Lengthen object life
                            self.objectLife = self.objectLife + self.objectLife/100
                        end)

    self.glowMesh = mesh()
    self.glowMesh.shader = shader(radialGradient())
    self.glowMesh.shader.col1 = vec4(1,1,1,1)
    self.glowMesh.shader.col2 = vec4(1,1,1,0)
    self.glowMesh.shader.pos = vec2(.5,.5)
    self.glowMesh.shader.size = vec2(.5,.5)
    self.glowMesh.shader.angle = 0
    self.glowMesh:addRect(0,0,10,10)

    self.glueDisplayMesh = mesh()
    self.glueDisplayMesh.shader = shader(alphaThreshold())
    self.glueDisplayMesh.shader.smoothness = 0
    self.glueDisplayMesh.shader.threshold = 0
    self.glueDisplayMesh.shader.unpremultiply = 1
    self.glueDisplayMesh.shader.maxAlpha = .2
    self.glueDisplayMesh.texture = image(WIDTH,HEIGHT)
    self.glueDisplayMesh:addRect(WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)

    self.timerColor = vec4(255,255,255,1)

    self.oP = {
        friction = .5,
        gravityScale = 0,
        restitution = 0
    }
end

function ObjectManager:addObject(oPreset)
    ---------------------------
    --  OBJECT DEFINITION    --
    ---------------------------
    
    local o = ObjectFunctions:getObject(oPreset or "randObj",self.oSize,(scene.score or 1))

    if seenObjects[o.index] then
        seenObjects[o.index] = seenObjects[o.index] + 1
    else
        seenObjects[o.index] = 1
        -- RisingText:addText("Object sighted: "..o.name,nil, nil)
        Notification:add("Object sighted: "..tostring(o.name))
    end
    saveLocalData("seenObjects",tToS("seenObjects",seenObjects))

    if self.rotateLevel <= (scene.score or 0) and math.random() <= self.rotateChance then
        o.body.angularVelocity = math.random(-self.maxRotateSpeed,self.maxRotateSpeed)
    end

    if self.waveLevel <= (scene.score or 0) and math.random() <= self.waveChance then
        o.waveSpeed = (math.random()-.5)*self.maxWaveSpeed*2
        o.waveAmnt = (math.random()-.5)*self.maxWaveAmnt*2
        o.waveTime = 0
    end
    
    o.sM = self.oSize

    presetBody(o.body,o.size,self.maxSpeed,self.fixedRotation)
    
    o.tM = mesh()
    o.tM.vertices = triangulate({vec2(-self.timerSize,-self.timerSize),
                        vec2(-self.timerSize,self.timerSize),
                        vec2(self.timerSize,self.timerSize),
                        vec2(self.timerSize,-self.timerSize)})
    o.tM.shader = shader(timerShader())
    o.tM.shader.a1 = math.pi
    o.tM.shader.size = .4
    o.tM.shader.color = self.timerColor
    o.tM.texCoords = triangulate({vec2(0,0),vec2(0,1),vec2(1,1),vec2(1,0)})
    
    o.phase = 0
    o.life = Timer(self.objectLife, function()
                                        sound(sounds.oReady)
                                        o.phase = 2
                                        FadingImage:addImg(imgs.check,o.body.x,o.body.y,color(0,255,0))
                                        RisingText:addText("+"..o.worth,scene.sMPos.x,scene.sMPos.y,o.color)
                                    end)
    
    o.worth = o.worth or 1
    o.scored = false
    
    
    ---------------------------
    --  POWERUP DEFINITION   --
    ---------------------------
    local randPUpNum = math.random()
    if randPUpNum <= self.chanceOfPUp then
        local maxPUp = 0
            for i,v in pairs(self.powerups) do
                if (scene.score or 0) >= (v.level * 1000) then
                    v.ready = true
                end
                if v.ready then
                maxPUp = maxPUp + v.chance
            end
        end
        -- Define selection
        local selection = math.random() * maxPUp
    
        -- Find object
        local countPUp = 0
        for i,v in pairs(self.powerups) do
            if v.ready then
                countPUp = countPUp + v.chance
                if selection <= countPUp and o.PUp == nil then
                    o.PUp = cleanTable(v)

                    if showTips then
                        local notificationColor = color(0)
                        if o.PUp.bad then
                            if o.PUp.mightBeGood then
                                notificationColor = color(255,255,0)
                            else
                                notificationColor = color(255,0,0)
                            end
                        else
                            notificationColor = color(0,255,0)
                        end
                        Notification:add("Power up: "..o.PUp.name,notificationColor)
                    end
                end
            end
        end
        
    end
    
    table.insert(self.oList, o)
end

function ObjectManager:draw()
    if update then
        self.objectTimer:update()
        self.speedUpT:update()
    end

    setContext(self.glueDisplayMesh.texture)
    background(0,0)
    for i,v in ipairs(self.oList) do
        if v.body.active and #v.body.joints > 0 then
            local sizeAddition = 0*gScale
            local sizeMultiplier = 4
            self.glowMesh:setRect(1,v.body.x,v.body.y,v.size.x*sizeMultiplier+sizeAddition,v.size.y*sizeMultiplier+sizeAddition,math.rad(v.body.angle))
            self.glowMesh:draw()
        end
    end
    if captureScreen == 2 then
        setContext(capturedScreen)
    else
        setContext()
    end

    for i = #self.oJointList, 1, -1 do
        j = self.oJointList[i]
        if not j.bodyA.active or not j.bodyB.active then
            j:destroy()
            table.remove(self.oJointList,i)
        end
    end

    self.glueDisplayMesh.shader.threshold = .3 + math.sin(ElapsedTime/3) / 20
    self.glueDisplayMesh:draw()
    
    for i = #self.oList, 1, -1 do
        o = self.oList[i]
        -- Do tests        
        -- Test if touched
        if o.body then
            for j,w in ipairs(touches:get()) do
                if w.state == BEGAN and self:testBodyTouched(o.body,w) and o.phase == 2 and scene.paused == false and scene.gameover == false and scene.sharePhoto == false then
                    emitters[o.colorName.."Emitter"]:emit(o.body.position,30)
                    self:destroyObject(o)
                end
            end
        end
            
        -- Test if out of bounds
        if o.body then
            --if o.body.x < -o.sM or o.body.x > WIDTH+o.sM or o.body.y < -o.sM or o.body.y > HEIGHT+o.sM then
            if (o.body.y < -o.sM or o.body.x < -150 or o.body.x > WIDTH+150) and not (o.body.y < scene.paddle.dY + 50 and o.body.y > scene.paddle.dY - 50) then
                if o.PUp and o.phase <= 1 then
                    if o.PUp.bad == false then -- Else do nothing
                        FadingImage:addImg(imgs.x,o.body.x,30,color(255,0,0))
                        scene:subtractLife()
                        sound(sounds.looseObject)
                    end
                else
                    FadingImage:addImg(imgs.x,o.body.x,30,color(255,0,0))
                    scene:subtractLife()
                    sound(sounds.looseObject)
                end
                self:destroyObject(o)
            end
        end
    end
    for i = #self.oList, 1, -1 do
        o = self.oList[i]
        if o.body then
            pushStyle()
            pushMatrix()
            resetStyle()
            translate(o.body.x,o.body.y)
            rotate(o.body.angle)
            -- Draw object
            ObjectFunctions:renderMesh(o.m)
            popMatrix()
            popStyle()
        end
    end
    for i = #self.oList, 1, -1 do
        if self.oList[i] then
            
            
        o = self.oList[i]
        if o.body then
            pushStyle()
            pushMatrix()
            resetStyle()
            translate(o.body.x,o.body.y)
            rotate(o.body.angle)
            
            font(globalFont)
            if o.phase == 1 then
                pushMatrix()
                rotate(-o.body.angle)
                rotate(-90)

                fill(0,0,0,40)
                ellipse(0,0,self.timerSize*2)

                o.tM.shader.a2 = -(o.life:getTime()/o.life.interval)*(math.pi*2)+math.pi
                pushMatrix()
                translate(3*gScale,0)
                -- o.tM.shader.color = vec4(255,255,255,1)
                -- o.tM:draw()
                o.tM.shader.color = self.timerColor
                popMatrix()
                o.tM:draw()
                popMatrix()
                if update then
                    o.life:resume()
                    o.life:update()
                end
            elseif o.phase == 2 then
                if o.scored == false then
                    scene.stackPoints = scene.stackPoints + math.ceil(o.worth/2)
                    scene.sM = scene.sM + o.worth
                    o.scored = true
                    if scene.sM > mostScoreAddition then
                        mostScoreAddition = scene.sM
                        saveLocalData("mostScoreAddition",scene.sM)
                        reportScore(scene.sM,"highestaddition")
                        -- RisingText:addText("Most score addition: "..scene.sM,nil, nil)
                        if scene.sM % achievementMultiplier == 0 and achievementMultiplier ~= 0 then
                            Notification:add("Most score increment: "..tostring(scene.sM))
                        end
                    end
                    if tallestTower+2 < (o.body.y - scene.paddle.paddles[1].body.y-10)/self.oSize then
                        tallestTower = (o.body.y - scene.paddle.paddles[1].body.y-10)/self.oSize
                        saveLocalData("tallestTower",tallestTower)
                        reportScore(tallestTower,"tallesttower")
                        -- RisingText:addText("Tallest tower: "..tallestTower.." units",nil, nil)
                        if math.floor(tallestTower) % achievementMultiplier == 0 and achievementMultiplier ~= 0 then
                            Notification:add("Tallest tower: "..tostring(math.floor(tallestTower)))
                        end
                    end
                    local oC = 0
                    for i,v in pairs(self.oList) do
                        if v.phase >=1 then
                            oC = oC + 1
                        end
                    end
                    if oC > mostObjects then
                        mostObjects = oC
                        saveLocalData("mostObjects",mostObjects)
                        reportScore(mostObjects,"mostobj")
                        -- RisingText:addText("Most objects on paddle: "..#self.oList,nil, nil)
                        if mostObjects % achievementMultiplier == 0 and achievementMultiplier ~= 0 then
                            Notification:add("Most objects on paddle: "..tostring(mostObjects))
                        end
                    end
                end
            elseif o.phase == 0 then
                if o.waveTime and o.waveSpeed and o.waveAmnt then
                    o.waveTime = o.waveTime + DeltaTime * o.waveSpeed
                    o.body.linearVelocity = vec2(math.sin(o.waveTime)*o.waveAmnt*gScale,o.body.linearVelocity.y)
                end
            end
            
            -- Powerup stuff
            
            if o.PUp ~= nil and o.phase <= 1 then
                pushMatrix()
                rotate(-o.body.angle)
                scale(gScale)
                tint(o.PUp.col)
                sSprite(o.PUp.img,0,0)
                popMatrix()
            end
            if o.PUp then
                if not o.PUp.added then
                    if 
                        (o.PUp.lastTime and o.PUp.onImpact == true and o.phase == 1) or 
                        (o.PUp.lastTime and not o.PUp.onImpact and o.phase == 2) then
                        scene.pupManager:addT(o.PUp)
                        o.PUp.added = true
                    end
                    if o.PUp.touchFunc and o.phase == 1 then
                        o.PUp:touchFunc(o)
                        o.PUp.added = true
                    elseif o.PUp.catchFunc and o.phase == 2 then
                        o.PUp:catchFunc(o)
                        o.PUp.added = true
                    end
                end
                
                end
            end
            popStyle()
            popMatrix()
        end
    end
end

function ObjectManager:testBodyTouched(b,t)
    local touched = false
    if b:testPoint(vec2(t.x,t.y)) then
        touched = true
    elseif b:testPoint(vec2(t.x+touchRange,t.y+touchRange)) then
        touched = true
    elseif b:testPoint(vec2(t.x+touchRange,t.y-touchRange)) then
        touched = true
    elseif b:testPoint(vec2(t.x-touchRange,t.y+touchRange)) then
        touched = true
    elseif b:testPoint(vec2(t.x-touchRange,t.y-touchRange)) then
        touched = true
    end

    return touched
end

function ObjectManager:destroyObject(b,dontNotify)
    if b.scored == true then
        scene.sM = scene.sM - b.worth
        if not dontNotify then
            RisingText:addText("-"..b.worth,scene.sMPos.x,scene.sMPos.y,b.color)
        end
    end
    ObjectFunctions:destroyBody(b,self.oList)
end

function ObjectManager:contact(bA,bB,pos)
    for i,v in ipairs(self.oList) do
        if bA == v.body or bB == v.body then
            v.body.gravityScale = 1
            if v.phase == 0 then
                v.phase = 1
                emitters.collide:emit(pos,30)
                sound(sounds.hit)

                -- Stick to side powerup
                local makeJoint = true
                if (purchases.stickyPaddleSides or 0) < 1 then
                    makeJoint = false
                end
                local threshold = 20
                if makeJoint and v.body.y < scene.paddle.dY + threshold and v.body.y > scene.paddle.dY - threshold then
                    ObjectFunctions:jointObject(v)
                end
            end
        end
    end
end

function ObjectManager:destroyAll(justDead, getMoney)
    --for i,v in pairs(self.oList) do
    for i = #self.oList, 1, -1 do
        v = self.oList[i]

        if not justDead or (justDead == true and v.scored == true) then
            if getMoney then
                scene.stackPoints = scene.stackPoints + v.worth
            end
            self:destroyObject(v,true)
        end
    end
end

function ObjectManager:setPProperties(prop,amnt)
    --scene.paddle.body[prop] = amnt
    for i,v in ipairs(self.oList) do
        v.body[prop] = amnt
    end
    self.oP[prop] = amnt
end