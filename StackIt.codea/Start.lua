Start = class()

function Start:init()
	if mainReverTrans then
		mainReverTrans = false
		self.transX = -WIDTH
	else
		self.transX = WIDTH
	end
	self.transitioning = false
	self.destination = nil
	tween(.2,self,{transX = 0},tween.easing.sinOut)

	if not newsTitle then
		http.request(
						"http://www.interdazzle.com/misc/dev/news.json",
						function(str)
							local data = json.decode(str)
							newsTitle = data.title
							newsData = data.url or data.html
							if data.url then
								newsDataType = "url"
							else
								newsDataType = "html"
							end
						end,
						function(error)
							NSLog("News fetch failed")
						end
					)
	end
	
	self.playA = 1

	self.menuTrans = 0
	self.menuItemSpacing = 5
	self.menuTextOffset = 10
	self.menuLinesSize = 100
	self.menuLinesSpacing = 10
	self.menuEdgeDistance = 50
	self.menuList = {
		{
			title = "Object Gallery",
			action = "seenobj"
		},
		{
			title = "Stats",
			action = "stats"
		},
		{
			title = "GameCenter",
			action = function()
				showGameCenter()
			end
		},
		{
			title = "Help",
			action = "howtoplay"
		},
		{
			title = "About",
			action = "about"
		},
		{
			title = "Settings",
			action = "settings"
		}
	}

	self.oList = {}
	self.oSize = 30*gScale
	self.oSpawner = Timer(0,function()
		self.oSpawner.interval = .2+math.random()*1
		for i = 1,1 do
			local o = ObjectFunctions:getObject("randObj",self.oSize,highscore,true)
			
			o.body.x = math.random(WIDTH/10,WIDTH/4*2)
			o.body.y = HEIGHT+100
			o.body.angle = math.random(360)
			o.body.angularVelocity = (math.random()-.5)*300
			o.body.friction = 1
			o.body.restitution = .1
			
			local create = true
			for i,v in ipairs(self.oList) do
				if o.body:testOverlap(v.body) then
					create = false
				end
			end
			if create then
				table.insert(self.oList,o)
			else
				o.body:destroy()
				o = nil
			end
		end
	end)
	
	self.rollers = {}
	local oSize = 15*gScale
	for i = 1,(WIDTH/oSize) do
		local o = physics.body(CIRCLE,oSize*2)
		o.type = KINEMATIC
		o.x = i*oSize
		o.y = 50
		o.angularVelocity = -100
		table.insert(self.rollers,o)
	end
end

function Start:draw()
	pushStyle()
	pushMatrix()
	resetStyle()
	translate(self.transX,0)

	-- Draw objects
	physics.gravity(0,-100)
	fill(textColor)
	if update then
		self.oSpawner:update()
	end
	for i = #self.oList, 1, -1 do
		local o = self.oList[i]
		ObjectFunctions:renderMesh(o.m,o.body.x,o.body.y,o.body.angle)
		if o.body.y < 0 then
			ObjectFunctions:destroyBody(o,self.oList)
		end
		for j,w in ipairs(touches:get()) do
			if w.state == BEGAN and o.body:testPoint(vec2(w.x,w.y)) then
				emitters[o.colorName.."Emitter"]:emit(o.body.position,30)
				ObjectFunctions:destroyBody(o,self.oList)
			end
		end
	end
	
	local titleY = HEIGHT/5*4
	local logoSize = 300*gScale

	pushStyle()
	pushMatrix()
	translate(WIDTH-25,35)
	blendMode(ADDITIVE)
	sprite(imgs.interDazzleSmall,0,0)
	popMatrix()
	popStyle()
	if testTouchRegion(WIDTH-25,35,125,125) and currentT.state == BEGAN and not self.transitioning then
		openURL("http://www.interdazzle.com")
	end

	pushStyle()
	pushMatrix()
	translate(25,35)
	sprite(imgs.storeSmall,0,0)
	popMatrix()
	popStyle()
	if testTouchRegion(25,35,125,125) and currentT.state == BEGAN and not self.transitioning then
		changeScene("store")
	end

	pushStyle()
	tint(255, 255, 255, 255)
	fontSize(100*gScale)
	--sprite(imgs.logo,WIDTH/2-textSize("StackIt")/2-logoSize/2,titleY+logoSize/2,logoSize)
	sprite(imgs.logo,WIDTH/2,titleY+logoSize/6,logoSize)
	--sprite(imgs.logo,logoSize/3,logoSize/3,logoSize)
	--sprite(imgs.logo,WIDTH/2,titleY+logoSize/6-10,logoSize)
	popStyle()
	
	fill(textColor)
	font(globalFont)
	titleText("StackIt",titleY)

	if self.playA ~= 0 then
		pushStyle()
		fill(255,self.playA*255)
		fontSize(17)
		sText("Highscore: "..highscore,WIDTH/2,HEIGHT/5*4-100*gScale,1)

		sText("Last score: "..lastScore,WIDTH/2,HEIGHT/5*4-100*gScale-fontSize()*1.5,1)

		drawStackPoints(vec2(WIDTH/2,HEIGHT/5*4-100*gScale-fontSize()*3))
		popStyle()
	end
	
	pushStyle()
	pushMatrix()
	tint(255,self.playA*255)
	translate(WIDTH/2,HEIGHT/2)
	scale(gScale)
	sSprite(imgs.play,0,0,3*gScale)
	popStyle()
	popMatrix()

	if self.playA == 1 then
		if testTouchRegion(WIDTH/2,HEIGHT/2,300*gScale,300*gScale) and currentT.state == 0 and not self.transitioning and update then
			touchUsed()
			changeScene("game")
		end
	end

	-- Errors
	pushStyle()
	local yPos = HEIGHT-35
	tint(255)
	if weatherError then
		sprite(imgs.weatherError,35,yPos)
		if testTouchRegion(35,yPos,50,50) and currentT.state == 0 then
			alert("This is due to either having no internet access or the incorrect location. Please contact InterDazzle if you cannot fix this.","Could not retrieve weather")
		end
	end
	if locationError then
		sprite(imgs.locationError,95,yPos)
		if testTouchRegion(95,yPos,50,50) and currentT.state == 0 then
			alert("This is due to either StackIt not having permission to access the current location or you do not have internet/GPS access. Please contact InterDazzle if you cannot fix this.","Could not retrieve location")
		end
	end
	popStyle()


	if newsTitle then
		pushStyle()
		local strW,strH = textSize(newsTitle)
		local padding = vec2(20,10)
		local pos = vec2(WIDTH/2,HEIGHT-strH/2-padding.y)--vec2(WIDTH-strW/2-padding.x,HEIGHT-strH/2-padding.y)
		fill(0,35)
		rectMode(CENTER)
		rect(pos.x,pos.y,strW+padding.x,strH + padding.y)
		fill(255)
		text(newsTitle,pos.x,pos.y)
		popStyle()
		if testTouchRegion(pos.x,pos.y,strW+padding.x*2,strH+padding.y*2) and currentT.state == BEGAN then
			if newsDataType == "url" then
				openURL(newsURL,false)
			else--if newsDataType == "html" then
				changeScene("htmlNewsView")
			end
		end
	end


	---------------
	-- Draw menu
	---------------

	pushMatrix()
	pushStyle()

	fontSize(40)
	strokeWidth(5)
	stroke(255)
	lineCapMode(ROUND)

	translate(0,self.menuTrans+fontSize()/2+self.menuItemSpacing)

	sText("Menu",WIDTH/2,self.menuTextOffset)

	local menuTextSizeX = textSize("Menu")
	local l1p1 = vec2(WIDTH/2+menuTextSizeX/2+self.menuLinesSpacing,self.menuTextOffset)
	local l1p2 = vec2(WIDTH/2+menuTextSizeX/2+self.menuLinesSpacing+self.menuLinesSize,self.menuTextOffset)
	local l2p1 = vec2(WIDTH/2-menuTextSizeX/2-self.menuLinesSpacing,self.menuTextOffset)
	local l2p2 = vec2(WIDTH/2-menuTextSizeX/2-self.menuLinesSpacing-self.menuLinesSize,self.menuTextOffset)
	if l1p2.x > WIDTH-self.menuEdgeDistance then
		l1p2.x = WIDTH-self.menuEdgeDistance
		l2p2.x = self.menuEdgeDistance
	end
	line(l1p1.x,l1p1.y,l1p2.x,l1p2.y)
	line(l2p1.x,l2p1.y,l2p2.x,l2p2.y)


	local itemPos = 0
	for i,v in ipairs(self.menuList) do
		itemPos = itemPos - fontSize() - self.menuItemSpacing
		sText(v.title,WIDTH/2,itemPos)
	end
	itemPos = itemPos - 15

	-- Test Menu Touched
	if testTouchRegion(WIDTH/2,self.menuTextOffset+fontSize()/2+self.menuTrans,WIDTH,fontSize()+self.menuItemSpacing) and currentT.state == 0 and not self.transitioning then
		local animSpeed = .5
		if self.menuTrans == 0 then
			if HEIGHT/2 - 120 * gScale < -itemPos then
				tween(animSpeed/2,self,{playA = 0},tween.easing.sinOut)
			end
			tween(animSpeed,self,{menuTrans = -itemPos},tween.easing.elasticOut)
		else
			if self.playA ~= 1 then
				tween(animSpeed/2,self,{playA = 1},tween.easing.sinOut)
			end
			tween(animSpeed,self,{menuTrans = 0},tween.easing.elasticOut)
		end
	end

	-- Test items touched
	local itemPos = 0
	for i,v in ipairs(self.menuList) do
		if testTouchRegion(WIDTH/2,itemPos+self.menuTrans-fontSize()/2,WIDTH,fontSize()+self.menuItemSpacing) and currentT.state == 0 and not self.transitioning then
			if type(v.action) == "string" then
				changeScene(v.action)
			elseif type(v.action) == "function" then
				v.action()
			end
		end
		itemPos = itemPos - fontSize() - self.menuItemSpacing
	end

	popMatrix()
	popStyle()

	
	popStyle()
	popMatrix()
end

function Start:leaveTrans()
	self.transitioning = true
	tween.sequence(tween.delay(.2),tween(.2,self,{transX = -WIDTH},tween.easing.sinOut,function() changeScene(self.destination) end))
end

function Start:exit()
	ObjectFunctions:destroyAllBodies(self.oList)
	for i,v in pairs(self.rollers) do
		v:destroy()
	end
	--collectgarbage()
end

function emailSent(result)
	alert(result)
end