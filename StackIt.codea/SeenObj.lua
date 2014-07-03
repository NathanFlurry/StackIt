SeenObj = class()

function SeenObj:init()
    self.transX = WIDTH
    self.transitioning = false
    tween(.2,self,{transX = 0},tween.easing.sinOut)

    self.scrollView = ScrollView(vec2(0,0),function() self:drawContent() end,6*gScale)

    local totalObjSeen = 0
    local totalObj = 0

    self.oList = {}
    self.oSize = 150
    local count = 0
    for i,v in pairs(seenObjects) do
        totalObjSeen = totalObjSeen +  1
        local o = ObjectFunctions:getObject(i,self.oSize*gScale,0,false,true)
        
        o.count = v
        
        table.insert(self.oList,o)
    end

    for i,v in pairs(ObjectFunctions.objects) do
        totalObj = totalObj + 1
    end

    self.objLeft = totalObj - totalObjSeen
end

function SeenObj:draw()
    pushStyle()
    pushMatrix()
    resetStyle()
    translate(self.transX,0)

    font(globalFont)
    textAlign(CENTER)
    fill(textColor)
    fontSize(25)

    sText("Back",40,HEIGHT-20)
    if testTouchRegion(40,HEIGHT-20,80,40) and not self.transitioning then
        self:leaveTrans()
    end

    titleText("Object Gallery",HEIGHT/5*4)

    local rows = 2
    local xSpace = 200
    local ySpace = 300
    local xMargin = 100
    local yMargin = 200
    
    pushStyle()
    fill(255,150)
    for i = 1,rows do
        pushMatrix()
        translate(0,(ySpace*((i%rows)) + 37)*gScaleHeight)
        rect(0,0,WIDTH,40*gScaleHeight)
        popMatrix()
    end
    popStyle()  

    self.scrollView:draw()

    popStyle()
    popMatrix()
end

function SeenObj:drawContent()
    fontSize(25*gScale)

    local rows = 2
    local xSpace = 200
    local ySpace = 300
    local xMargin = 100
    local yMargin = 200
    
    for i,v in ipairs(self.oList) do
        pushMatrix()
        translate(
            ((math.floor((i-1)/rows))*xSpace+xMargin)*gScaleHeight,
            (ySpace*((i%rows))+yMargin)*gScaleHeight
        )
        pushMatrix()
        scale(v.scaleDown*.8)
        ObjectFunctions:renderMesh(v.m,0,0,0)
        popMatrix()
        pushStyle()
        fill(0)
        fontSize(20*gScale)
        local objStr = v.count.." "..v.name
        if v.count > 1 then
            objStr = objStr.."s"
        end
        text(objStr,0,(-self.oSize/2-yMargin/3)*gScaleHeight)
        popStyle()
        popMatrix()
    end
    
    local screenWidth = xMargin + (xSpace * #self.oList)/rows
    
    local objString
    if self.objLeft == 0 then
        objString = "Great job! You've seen all the objects!"
    else
        objString = "Total objects left to see: "..self.objLeft
    end
    
    local textMargin = 50*gScale
    fontSize(30*gScale)
    textWrapWidth(200*gScale)
    fill(255)
    sText(objString,(screenWidth + textSize(objString)/2)*gScaleHeight,HEIGHT/2)
    
    screenWidth = (screenWidth + textSize(objString) + textMargin)*gScaleHeight+20

    if screenWidth < WIDTH then
        self.scrollView.contentSize.x = 0
    else
        self.scrollView.contentSize.x = screenWidth
    end
end

function SeenObj:touched(t)
    self.scrollView:touched(t)
end

function SeenObj:leaveTrans()
    self.transitioning = true
    mainReverTrans = true
    tween(.2,self,{transX = WIDTH},tween.easing.sinOut,function() changeScene("start") end)
end

function SeenObj:exit()
    --collectgarbage()
end