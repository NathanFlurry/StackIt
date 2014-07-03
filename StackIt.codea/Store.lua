Store = class()

function Store:init()
    self.transX = WIDTH
    self.transitioning = false
    tween(.2,self,{transX = 0},tween.easing.sinOut)

    self.scrollView = ScrollView(vec2(0,0),function() self:drawContent() end,6*gScale)

    self.items = {
        {
            name = "Extra Life",
            type = "upgrade",
            img = imgs.heart,
            col = color(255,0,0),
            cost = 300,
            max = 3,
            value = "extraLives"
        },
        {
            name = "Extra Score",
            type = "upgrade",
            img = imgs.star,
            col = color(255, 200, 0, 255),
            cost = 175,
            max = 10,
            value = "extraScore"
        },
        {
            name = "Paddle Size",
            type = "upgrade",
            img = imgs.expandPaddle,
            col = color(255,255,255),
            cost = 225,
            max = 4,
            value = "paddleSize"
        },
        {
            name = "Exta Paddle",
            type = "upgrade",
            img = imgs.extraPaddle,
            col = color(255,255,255),
            cost = 1250,
            max = 1,
            value = "extraPaddles"
        },
        {
            name = "Sticky Paddle Sides",
            type = "upgrade",
            img = imgs.stickyPaddleSides,
            col = color(255,255,255),
            cost = 2000,
            max = 1,
            value = "stickyPaddleSides"
        },
        {
            name = "Add Life",
            type = "disposable",
            img = imgs.heart,
            col = color(255,0,0),
            cost = 10,
            value = "addLife"
        },
        {
            name = "Nuke",
            type = "disposable",
            img = imgs.nuke,
            col = color(255, 197, 0, 255),
            cost = 35,
            value = "nuke"
        },
        {
            name = "Glue",
            type = "disposable",
            img = imgs.glue,
            col = color(255,255,255),
            cost = 45,
            value = "glue"
        },
        {
            name = "Null Gravity",
            type = "disposable",
            img = imgs.nullGravity,
            col = color(50, 160, 255, 255),
            cost = 3,
            value = "nullGravity"
        },
        {
            name = "Coin Doubler",
            type = "iap",
            img = imgs.stackPointDoubler,
            col = color(255, 255),
            id = "stackPointDoubler",
            value = "coinDoubler"
        },
        {
            name = "Coin Tripler",
            type = "iap",
            img = imgs.stackPointTripler,
            col = color(255, 255),
            id = "stackPointTripler",
            value = "coinTripler"
        }
    }
    for i,v in ipairs(self.items) do
        if v.type == "upgrade" then
            v.level = (purchases[v.value] or 0)
        elseif v.type == "disposable" then
            v.num = (purchases[v.value] or 0)
        end
        v.timingOffset = math.random()*.5+.75
    end

    self:configureIAP()

    self.margin = WIDTH/12

    self.movingTouch = nil
end

function Store:draw()
    pushStyle()
    pushMatrix()
    resetStyle()
    translate(self.transX,0)

    fontSize(30)
    font(globalFont)
    textAlign(CENTER)
    fill(textColor)
    fontSize(25)

    sText("Back",40,HEIGHT-20)
    if testTouchRegion(40,HEIGHT-20,80,40) and not self.transitioning then
        self:leaveTrans()
    end

    self.scrollView:draw()

    popStyle()
    popMatrix()
end

function Store:drawContent()
    titleText("Store",HEIGHT/5*4)

    pushStyle()
    fontSize(50*gScale)
    drawStackPoints(vec2(WIDTH/2,HEIGHT/5*4-100*gScale))
    popStyle()

    pushStyle()
    stroke(255)
    strokeWidth(2)
    fontSize(50*gScale)
    local spacing = 50
    local yPos = HEIGHT/2
    local itemPos = 0
    for i,v in ipairs(self.items) do
        if not v.hide then
            local cost = 12345
            if v.type ~= "iap" then
                cost = v.cost * ((v.level or 0) + 1)
            end
            local canBuy = v.type == "iap" or (stackPoints - cost >= 0 and (v.type == "disposable" or (v.level or 0) < v.max))
            local side = itemPos%2
            local pos = vec2(WIDTH/2,yPos)
            if side == 0 then
                pos.x = WIDTH/3-50*gScale
            else
                pos.x = WIDTH/3*2+50*gScale
            end

            pushStyle()
            pushMatrix()
            noStroke()
            fill(255,25)
            translate(pos.x,pos.y)
            scale(1+math.sin(ElapsedTime*v.timingOffset)/15)
            ellipse(0,0,200*gScale)
            popStyle()
            popMatrix()

            pushStyle()
            tint(v.col)
            sprite(v.img,pos.x,pos.y,130*gScale)
            popStyle()

            pushStyle()
            fontSize(40*gScale)
            sText(v.name,pos.x,pos.y-125*gScale)
            popStyle()

            pushStyle()
            fontSize(20*gScale)
            if v.type == "upgrade" and (v.level or 0) >= v.max then
                sText("Fully upgraded",pos.x,pos.y-175*gScale)
            elseif v.type == "iap" then
                pushStyle()
                fontSize(30*gScale)
                local str
                if storeReady then
                    str = iapItems[v.id]["price"]
                else
                    str = "Not available"
                end
                sText(str,pos.x,pos.y-85*gScale)
                popStyle()
            else
                pushStyle()
                fontSize(30*gScale)
                drawCustomStackPoints(vec2(pos.x,pos.y-85*gScale),cost)
                popStyle()
            end
            popStyle()

            pushStyle()
            if canBuy then
                tint(255)
            else
                tint(150)
            end
            popStyle()

            if v.type == "upgrade" then
                local height = 5*gScale
                local totalWidth = 200*gScale
                local barPos = vec2(pos.x,pos.y-160*gScale)
                pushStyle()
                noStroke()
                for itemPos = 0,v.max-1 do
                    if itemPos < (v.level or 0) then
                        fill(255)
                    else
                        fill(200)
                    end
                    rect((itemPos*totalWidth/v.max)+barPos.x-totalWidth/2,barPos.y,totalWidth/v.max,height)
                end
                popStyle()
            elseif v.type == "disposable" then
                pushStyle()
                fontSize(20*gScale)
                sText(v.num.." owned",pos.x,pos.y-175*gScale)
                popStyle()
            end

            if testTouchRegion(pos.x,self.scrollView.contentPos.y+pos.y,200*gScale,200*gScale,false,true) and currentT.state == ENDED and self.movingTouch ~= currentT.id then
                if canBuy then
                    if v.type ~= "iap" then
                        addStackPoints(-cost)
                        Notification:clearAll()
                        Notification:add("Purchased")
                    end
                    if v.type == "upgrade" then
                        v.level = (v.level or 0) + 1
                        if v.level > v.max then
                            v.level = v.max
                        end
                        purchases[v.value] = v.level
                    elseif v.type == "disposable" then
                        purchases[v.value] = (purchases[v.value] or 0) + 1
                        v.num = purchases[v.value]
                    elseif v.type == "iap" then
                        local itemNum
                        if v.id == "stackPointDoubler" then
                            itemNum = 0
                        else--if v.id == "stackPointTripler" then
                            itemNum = 1
                        end
                        purchaseItem(itemNum)
                    end

                    saveLocalData("purchases",tToS("purchases",purchases))
                else
                    if v.type == "upgrade" and v.level >= v.max then
                        Notification:clearAll()
                        Notification:add("Fully upgraded")
                    else    
                        Notification:clearAll()
                        Notification:add("Insufficient funds")
                    end
                end
            end
            itemPos = itemPos + 1
        end

        if itemPos%2 == 0 or i == #self.items then
            yPos = yPos - 300 * gScale - spacing
        end
    end

    sText("Restore purchases",WIDTH/2,yPos+50*gScale)
    local sX,sY = textSize("Restore Purchases")
    if testTouchRegion(WIDTH/2,self.scrollView.contentPos.y+yPos+50*gScale,sX,sY,false,true) and currentT.state == ENDED and self.movingTouch ~= currentT.id then
        restorePurchases()
    end
    yPos = yPos - 50 * gScale

    if self.scrollView.contentSize.y == 0 then
        self.scrollView.contentSize.y = math.abs(yPos)+HEIGHT
    end
end

function Store:configureIAP()
    for i,v in ipairs(self.items) do
        if v.id == "stackPointDoubler" then
            if purchases.stackPointMultiplier >= 2 or not iapItems.stackPointDoubler then
                v.hide = true
            end
        elseif v.id == "stackPointTripler" then
            if purchases.stackPointMultiplier == 3 or not iapItems.stackPointTripler then
                v.hide = true
            elseif purchases.stackPointMultiplier == 2 then
                v.name = v.name.." + 1K SP"
            end
        end
    end
end

function Store:touched(t)
    self.scrollView:touched(t)
    if t.state == MOVING then
        self.movingTouch = t.id
    elseif (t.state == ENDED or t.state == CANCELLED) and t.id == self.movingTouch then
        --self.movingTouch = nil
    end
end

function Store:leaveTrans()
    self.transitioning = true
    mainReverTrans = true
    tween(.2,self,{transX = WIDTH},tween.easing.sinOut,function() changeScene("start") end)
end

function Store:exit()
end

function getProductInfo(id,price)
    iapItems[id] = {
        price = price
    }
end

function productBeingPurchased(id)
    purchasePending = true
end

function restoredProducts(id)
    setProductPurchased(id)
end

function noRestoredProducts()

end

function productPurchaseFailed()
    purchasePending = true
end

function productPurchaseSucceeded(id)
    purchasePending = true
    setProductPurchased(id)
end

function setProductPurchased(id)
    if id == "stackPointDoubler" then
        purchases.stackPointMultiplier = 2
    elseif id == "stackPointTripler" then
        purchases.stackPointMultiplier = 3
        if purchases.stackPointMultiplier == 2 then
            addStackPoints(1000)
            Notification:add("1000 StackPoints awared")
        end
    end
    if sID == "store" then
        scene:configureIAP()
    end
end