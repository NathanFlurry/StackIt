Background = class()

function Background:init()
    self.bgGradient = getGradient(vec2(WIDTH,HEIGHT),color(0,90,255),color(50,190,255))

    -- Get location
    location.enable()
    local hasLocation = location.available() and tostring(location) ~= "Location not available"
    if hasLocation then
        locationError = false
    else
        locationError = true
    end
    weatherError = false

    self.checkLocationReadyTimer = Timer(5,
                                        function()
                                            if location.available() == true and locationError == true and tostring(location) ~= "Location not available" then
                                                NSLog("Updated weather and BG")
                                                locationError = false
                                                Background:init()
                                            elseif locationError == false then
                                                self.checkLocationReadyTimer:pause()
                                                NSLog("Paused weather timer")
                                            end
                                        end)

    -- Set BG
    self.time = 0
    self.dayColor = nil
    self.gradContrast = 50
    local function getSunrise()
        local time
        if not locationError then
            time = weatherlib.calc_sunrise(os.date("*t"),location.latitude,location.longitude,-date():getbias()/60)
            time = getDecimalTime(time)
        end
        if not time then
            time = .25
        end
        return {
                    value = color(50,60,100),
                    time = time
                },
                {
                    value = color(109, 136, 181, 255),
                    time = time+.02
                }
    end
    local function getSunset()
        local time
        if not locationError then
            time = weatherlib.calc_sunset(os.date("*t"),location.latitude,location.longitude,-date():getbias()/60)
            time = getDecimalTime(time)
        end
        if not time then
            time = .79
        end
        return {
                    value = color(0, 47, 255, 255),
                    time = time
                },
                {
                    value = color(40,50,80),
                    time = time+.01
                }
    end
    self.track = {
        {
            value = color(40),
            time = 0
        },
        getSunrise(),
        {
            value = color(50,190,255),
            time = .5
        },
        getSunset(),
        {
            value = color(40),
            time = 1
        }
    }
    
    self:setDay()
    self.updateDay = Timer(5, function() self:setDay() end)


    self.moonMesh = mesh()
    self.moonMesh:setColors(255,255,255)

    local dir
    local t = getPercentOfMonth()
    if t <= .5 then
        t = t * 2
        dir = -1
    else
        t = (t - .5) * 2
        dir = 1
    end

    self.moonMesh.vertices = generateMoonPoints(weatherlib.calc_moon(os.date("!*t")),100) --os.date("*t",os.time({year=2014,month=2,day=1,hour=7,min=57}))),100) --BLACK SCREEN FREEZE

    self.moonSize = 50

    self.raySize = self.moonSize
    self.raySpawnSpeed = .5
    self.rayLife = 20
    self.rays = {}

    for i = 1,50 do
        local r = {}
        r.a = math.random() * 255
        r.angle = math.random()*360
        r.d1 = self.moonSize + math.random() * self.raySize
        r.d2 = self.moonSize + math.random() * self.raySize
        r.size = math.random(1,5)
        
        table.insert(self.rays,r)
    end

    self.setGlowMColor = function(_,m,col)
                            m.shader.col1 = vec4(col.r/255,col.g/255,col.g/255,col.a/255)
                            m.shader.col2 = vec4(col.r/255,col.g/255,col.g/255,0)
                        end

    self.moonGlowM = mesh()
    self.moonGlowM.shader = shader(radialGradient())
    self.moonGlowM.shader.pos = vec2(.5,.5)
    self.moonGlowM.shader.size = vec2(.5,.5)
    self.moonGlowM.shader.angle = 0
    self.moonGlowM:addRect(0,0,400,400)

    self:setGlowMColor(self.moonGlowM,color(255,30))
    
    self.sunGlowM = mesh()
    self.sunGlowM.shader = shader(radialGradient())
    self.sunGlowM.shader.pos = vec2(.5,.5)
    self.sunGlowM.shader.size = vec2(.5,.5)
    self.sunGlowM.shader.angle = 0
    self.sunGlowM:addRect(0,0,300,300)

    self:setGlowMColor(self.sunGlowM,color(255,255,0,120))

    self:makeStars()

    self.weather = {
    	raininess = 0,
		snowiness = 0,
		windiness = 0,
		storminess = 0,
		cloudiness = 0
	}

    self.currentConditions = {}

    -- Clouds
    self.clouds = {}
    for i = 1,self.weather.cloudiness*20 do
    	table.insert(self.clouds,self:createCloud())
    end
    self.cloudSpawner = Timer(0,function()
    								if self.weather.cloudiness > 0 and self.weather.windiness ~= 0 then
										table.insert(self.clouds,self:createCloud())
										self.cloudSpawner.interval = math.random() * ((1.1 - self.weather.cloudiness)) * ((1.1 - math.abs(self.weather.windiness))) * 5
									end
    							end)
    self.lightningFlash = Timer(.5,function()
    									pushStyle()
    									noSmooth()
    									fill(255)
    									rect(0,0,WIDTH,HEIGHT)
    									popStyle()
    									self.lightningFlash.interval = 3 + ((1 - self.weather.storminess) * 10) --math.random()*(1.1-self.weather.storminess)*35
    								end)

    -- Rain
    self.precipitation = {}

    self:setWeather()

    -- Holiday backgrounds
    self.holidayImageList = {
        -- Valentine's day
        {
            date = {month = 2, day = 13},
            img = "Holiday:Heart",
            bonuses = {
                life = 2
            }
        },
        -- Pi day
        {
            date = {month = 3, day = 14},
            img = "Holiday:Pi",
            bonuses = {
                score = 31415
            }
        },
        -- Easter
        {
            date = {month = 4, day = 20},
            img = "Holiday:Egg",
            bonuses = {
                life = 1
            }
        },
        -- Geek day
        {
            date = {month = 5, day = 25},
            img = "Holiday:1",
            bonuses = {
                score = 10101
            }
        },
        {
            date = {month = 5, day = 25},
            img = "Holiday:0"
        },
        -- July 4
        {
            date = {month = 7, day = 4},
            img = "Holiday:Star",
            bonuses = {
                score = 10000
            }
        },
        -- Halloween
        {
            date = {month = 10, day = 31},
            img = "Holiday:Pumpkin",
            bonuses = {
                life = 1
            }
        },
        -- Thanksgiving day
        {
            date = {month = 11, day = 28},
            img = "Holiday:Fork",
            bonuses = {
                life = 1,
                score = 5000
            }
        },
        {
            date = {month = 11, day = 28},
            img = "Holiday:Knife"
        },
        -- Christmas
        {
            date = {month = 12, day = 25},
            img = "Holiday:Present",
            bonuses = {
                life = 1,
                score = 15000
            }
        },
        {
            date = {month = 12, day = 25},
            img = "Holiday:Tree"
        },
        -- Boxing day
        {
            date = {month = 12, day = 26},
            img = "Holiday:Box",
            bonuses = {
                score = 2500
            }
        },
    }
    self.holidayImgs = {}

    local d = os.date("*t")
    for i,v in ipairs(self.holidayImageList) do
        if v.date.month == d.month and v.date.day == d.day then
            v.img = readImage(v.img)
            table.insert(self.holidayImgs,v)

            if v.bonuses then
                bonuses.score = bonuses.score + (v.bonuses.score or 0)
                bonuses.life = bonuses.life + (v.bonuses.life or 0)
            end
        end
    end

    self.holidayItems = {}
    self.holidayItemspawner = Timer(5*(1+(1-gScale)), function()
                                            if #self.holidayImgs > 0 then
                                                local selection = self.holidayImgs[math.random(#self.holidayImgs)]
                                                self:createHolidayImage(selection,math.random()*WIDTH,HEIGHT+50)
                                            end
                                        end)
end

function Background:draw()
    self.updateDay:update()
    
	self.cloudSpawner:update()

    pushMatrix()
    translate(WIDTH/2,HEIGHT/2)
    self.bgGradient:draw()
    popMatrix()

    self:drawStars()

    self:drawSunandMoon()

    -- Darkness
    if self.weather.storminess > 0 then
	    pushStyle()
	    noStroke()
	    noSmooth()
	    fill(0,225*self.weather.storminess)
	    rect(0,0,WIDTH,HEIGHT)
	    popStyle()
	end

    -- Holiday Items
    self.holidayItemspawner:update()
    for i = #self.holidayItems,1,-1 do
        self.holidayItems[i]:draw()
    end

	-- Precipitation
    for i = #self.precipitation,1,-1 do
	    self.precipitation[i]:draw()
	end

    -- Clouds
    for i = #self.clouds,1,-1 do
	    self.clouds[i]:draw()
	end

	-- Lightning
	if self.weather.storminess > .7 then
		self.lightningFlash:update()
	end

    if debugMode then
        pushStyle()
        local dS = "Debug Info:\n"
        if locationError then
            dS = dS.."No location\n"
        else
            dS = dS.."Current location: "..location.latitude..", "..location.longitude.."\n"
        end

        dS = dS.."\nCurrent conditions:\n"
        if self.currentConditions then
            for i,v in pairs(self.currentConditions) do
                dS = dS..i.."  :  "..v.."\n"
            end
        end

        dS = dS.."\nDisplayed conditions:\n"
        if self.currentConditions then
            for i,v in pairs(self.weather) do
                dS = dS..i.."  :  "..v.."\n"
            end
        end

        dS = dS.."\n\nCurrent moon angle: "..weatherlib.calc_moon(os.date("!*t"))

        -- dS = dS.."\n\nFPS: "..1/DeltaTime

        fontSize(10)
        font("HelveticaNeue")
        fill(255)
        text(dS,currentT.x,currentT.y)
        text("FPS: "..1/DeltaTime,currentT.x-150,currentT.y)
        popStyle()
    end

    self.checkLocationReadyTimer:update()
end

function Background:setDay()
    if not debugMode then
        self.time = getDecimalTime(os.date("*t"))--os.date("*t",os.time({year=2014,month=1,day=17,hour=7,min=57})))
    end
    local v1, v2
    for i,v in ipairs(self.track) do
        if self.track[i+1] ~= nil and self.time >= v.time and self.time <= self.track[i+1].time then
            v1 = v
            v2 = self.track[(i % #self.track)+1]
        end
    end
    local col = color()
    col.r = v1.value.r+(v2.value.r - v1.value.r)*((self.time-v1.time)/(v2.time-v1.time))
    col.g = v1.value.g+(v2.value.g - v1.value.g)*((self.time-v1.time)/(v2.time-v1.time))
    col.b = v1.value.b+(v2.value.b - v1.value.b)*((self.time-v1.time)/(v2.time-v1.time))
    self.dayColor = col
    self.bgGradient.setGradient(color(col.r-self.gradContrast,col.g-self.gradContrast,col.b-self.gradContrast),col)
end

function Background:setWeather()
    local function weatherFail(errorCode)
        self.weather.windiness = .5
        self.weather.cloudiness = .5
        weatherError = true
    end
    if locationError then
        NSLog("Weather fail: Location non-existent")
        weatherFail("Invalid longitude and latitude")
    elseif not showWeather then
        --weatherFail("Weather turned off")
        self.weather.windiness = .5
        self.weather.cloudiness = .5
    else
        http.request("https://api.forecast.io/forecast/d350a6eb4cafba444a0cc6f833b6cef9/"..location.latitude..","..location.longitude,
                                                                                function(data)
                                                                                    local w = json.decode(data).currently

                                                                                    self.currentConditions = w

                                                                                    -- Set cloudiness
                                                                                    self.weather.cloudiness = w.cloudCover

                                                                                    -- Reset weather conditions
                                                                                    self.weather.raininess = 0
                                                                                    self.weather.snowiness = 0

                                                                                    -- Set precipitation
                                                                                    local precipMult = 5
                                                                                    if w.precipIntensity then
                                                                                        if w.precipType == "snow" then
                                                                                            self.weather.snowiness = w.precipIntensity*precipMult
                                                                                            if self.weather.snowiness > 1 then
                                                                                                self.weather.snowiness = 1
                                                                                            end
                                                                                        else -- rain, sleet, and hail
                                                                                            self.weather.raininess = w.precipIntensity*precipMult
                                                                                            if self.weather.raininess > 1 then
                                                                                                self.weather.raininess = 1
                                                                                            end
                                                                                        end
                                                                                    end

                                                                                    -- Set storminess
                                                                                    self.weather.storminess = w.precipIntensity*10
                                                                                    if self.weather.storminess > 1 then
                                                                                        self.weather.storminess = 1
                                                                                    end

                                                                                    -- Set wind
                                                                                    self.weather.windiness = w.windSpeed/30
                                                                                    if w.windBearing and w.windBearing > 180 then
                                                                                        self.weather.windiness = self.weather.windiness * -1
                                                                                        if self.weather.windiness < -1 then
                                                                                            self.weather.windiness = -1
                                                                                        elseif self.weather.windiness > 1 then
                                                                                            self.weather.windiness = 1
                                                                                        end
                                                                                    end

                                                                                    weatherError = false
                                                                                end,
                                                                                function(errorCode)
                                                                                    NSLog("Error fetching weather: "..errorCode)
                                                                                    weatherFail(errorCode)
                                                                                end)
    end
end

function Background:drawSunandMoon()
    local tRad = (self.time*math.pi*2)-math.pi/2
    local distX = WIDTH*.5
    local distY = HEIGHT/10*9

    -- self.rayAdder:update()

    pushMatrix()
    pushStyle()
    translate(WIDTH/2,0)

    pushMatrix()
    translate(math.cos(tRad)*distX,math.sin(tRad)*distY)

    self.sunGlowM:draw()

    if math.sin(tRad)*distY > -HEIGHT/3 then
        for i,r in ipairs(self.rays) do
            pushStyle()
            pushMatrix()
            rotate(r.angle)
            strokeWidth(r.size)
            stroke(255,200,0,r.a)
            lineCapMode(SQUARE)
            line(r.d1,0,r.d2,0)
            popStyle()
            popMatrix()
        end
    end

    fill(255,200,0,255)
    ellipse(0,0,self.moonSize*2)
    popMatrix()


    pushMatrix()
    translate(-math.cos(tRad)*distX,-math.sin(tRad)*distY)

    self.moonGlowM:draw()

    fill(0,100)
    ellipse(0,0,self.moonSize*2)

    fill(220,255)
    scale(self.moonSize)
    rotate(120)
    self.moonMesh:draw()

    popMatrix()

    popMatrix()
    popStyle()
end

function Background:createCloud()
	local cloud = {}
	local cloudSelection = math.random(1,3)
	cloud.img = imgs["cloud"..cloudSelection]
	cloud.imgPlain = imgs["cloud"..cloudSelection.."Plain"]
	cloud.y = HEIGHT-(math.random()*HEIGHT/5)


	local endPos
	if self.weather.windiness > 0 then
		cloud.x = -200
		endPos = WIDTH+200
	elseif self.weather.windiness < 0 then
		cloud.x = WIDTH+200
		endPos = -200
	else
		cloud.x = math.random()*WIDTH
	end
	if self.weather.windiness ~= 0 then
		cloud.tween = tween((math.random()*20+10)*(1.1-math.abs(self.weather.windiness)), cloud, { x = endPos }, tween.easing.linear, function()
																								for i,v in ipairs(self.clouds) do
																			    					if v == cloud then
																			    						table.remove(self.clouds,i)
																			    					end
																			    				end
																							end)
	end


	cloud.rainSpawner = Timer(.05, function()
										if self.weather.raininess > 0 then
											table.insert(self.precipitation,self:createDrop(cloud.x+(math.random()-.5)*(125*gScale),cloud.y-(75*gScale)))
											cloud.rainSpawner.interval = math.random()*(1.1-self.weather.raininess)*2*(1+(1-gScale))
										end
									end)
	cloud.snowSpawner = Timer(.05, function()
										if self.weather.snowiness > 0 then
											table.insert(self.precipitation,self:createSnow(cloud.x+(math.random()-.5)*(125*gScale),cloud.y-(75*gScale)))
											cloud.snowSpawner.interval = math.random()*(1.1-self.weather.snowiness)*5*(1+(1-gScale))
										end
									end)
	cloud.draw = function()
                    if self.weather.raininess > .1 or self.weather.snowiness > .1 then
    					cloud.rainSpawner:update()
    					cloud.snowSpawner:update()
                    end
					pushStyle()
					pushMatrix()
					tint(175)
					blendMode(ADDITIVE)
					translate(cloud.x,cloud.y)
					scale(gScale)
	    			sprite(cloud.img,0,0)
	    			blendMode(NORMAL)
	    			tint(50,225*self.weather.storminess)
	    			sprite(cloud.imgPlain,0,0)
	    			popStyle()
	    			popMatrix()
				end
	return cloud
end

function Background:createDrop(x,y)
	local drop = {}
	drop.img = imgs.raindrop
	drop.x = x
	drop.y = y
	drop.tween = tween(4, drop, { y = -100 }, tween.easing.linear, function()
								for i,v in ipairs(self.precipitation) do
			    					if v == drop then
			    						table.remove(self.precipitation,i)
			    					end
			    				end
							end)
	drop.draw = function()
					pushStyle()
					pushMatrix()
					translate(drop.x,drop.y)
					scale(gScale)
					blendMode(ADDITIVE)
					tint(0,100,255)
	    			sprite(drop.img,0,0)
	    			popStyle()
	    			popMatrix()
				end
	return drop
end

function Background:createSnow(x,y)
	local flake = {}
	flake.img = imgs.snowflake
	flake.x = x
	flake.y = y
	flake.angle = math.random()*360
	flake.rotateRate = (math.random()-.5)*2
	flake.tween = tween(10, flake, { y = -100 }, tween.easing.linear, function()
								for i,v in ipairs(self.precipitation) do
			    					if v == flake then
			    						table.remove(self.precipitation,i)
			    					end
			    				end
							end)
	flake.draw = function()
					flake.angle = flake.angle + flake.rotateRate
					pushStyle()
					pushMatrix()
					translate(flake.x,flake.y)
					rotate(flake.angle)
					scale(gScale)
					blendMode(ADDITIVE)
					tint(255,100)
	    			sprite(flake.img,0,0,10)
	    			popStyle()
	    			popMatrix()
				end
	return flake
end

function Background:createHolidayImage(holidayItem,x,y)
    local img = {}
    img.img = holidayItem.img
    img.x = x
    img.y = y
    img.angle = math.random()*360
    img.rotateRate = (math.random()-.5)*50
    img.tween = tween(50, img, { y = -100 }, tween.easing.linear, function()
                                for i,v in ipairs(self.holidayItems) do
                                    if v == img then
                                        table.remove(self.holidayItems,i)
                                    end
                                end
                            end)
    img.draw = function()
                    img.angle = img.angle + img.rotateRate * DeltaTime
                    pushStyle()
                    pushMatrix()
                    translate(img.x,img.y)
                    rotate(img.angle)
                    tint(255,150)
                    sprite(img.img,0,0)
                    popStyle()
                    popMatrix()
                end
    table.insert(self.holidayItems,img)
end

function Background:makeStars()
    self.stars = {}
    for i = 1,50 do
        local s = {}
        s.pos = vec2(math.random()*WIDTH,math.random()*HEIGHT)
        s.size = math.random(3,10)
        s.a = s.pos.y/HEIGHT*255
        s.angle = math.random()*360
        table.insert(self.stars,s)
    end
end

function Background:drawStars()
    pushStyle()
    local starA;
    if self.time < .5 then
        starA = (.3-self.time)*3.33
    else
        starA = (self.time-.7)*3.33
    end
    for i,s in ipairs(self.stars) do
        pushMatrix()
        translate(s.pos.x,s.pos.y)
        rotate(s.angle)
        text()
        tint(255,s.a*starA)
        sprite(imgs.star,0,0,s.size)
        popMatrix()
    end
    popStyle()
end