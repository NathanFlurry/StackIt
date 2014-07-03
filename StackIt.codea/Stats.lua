Stats = class()

function Stats:init()
    self.transX = WIDTH
    self.transitioning = false
    tween(.2,self,{transX = 0},tween.easing.sinOut)

    self.scrollView = ScrollView(vec2(0,0),function() self:drawContent() end,6*gScale)
    
    self.stats = {
        {"Times played: ","timesPlayed",""},
        {"Highscore: ","highscore"," points"},
        {"Average score: ","avgScore"," points"},
        {"Total score: ","totalScore"," points"},
        {"Total StackPoints earned: ","totalEarned"," StackPoints"},
        {"Total StackPoints spent: ","totalSpent"," StackPoints"},
        {"Most objects on the paddle at one time: ","mostObjects",""},
        {"Highest score addition: ","mostScoreAddition"," points"},
        {"Tallest tower: ","tallestTower"," units"},
        {"Longest play: ","longestPlay"," seconds"},
        {"Total play time: ","totalPlayTime"," seconds"}
    }

    local avgScore = 0
    if #scoreHistory > 0 then
        for i,v in ipairs(scoreHistory) do
            avgScore = avgScore + v
        end
        avgScore = avgScore / #scoreHistory
    end
    
    local totalScore = 0
    for i,v in ipairs(scoreHistory) do
        totalScore = totalScore + v
    end

    --[[self.timesPlayed = 0
    self.highscore = 0
    self.avgScore = 0
    self.totalScore = 0
    self.totalEarned = 0
    self.totalSpent = 0
    self.mostObjects =  0
    self.mostScoreAddition = 0
    self.tallestTower = 0
    self.longestPlay = 0
    self.totalPlayTime = 0]]

    --[[tween (1,self,{
            timesPlayed = #scoreHistory,
            highscore = highscore,
            avgScore = avgScore,
            totalScore = totalScore,
            totalEarned = totalEarned,
            totalSpent = totalSpent,
            mostObjects = mostObjects,
            mostScoreAddition = mostScoreAddition,
            tallestTower = tallestTower*gScale,
            longestPlay = longestPlay,
            totalPlayTime = totalPlayTime
        })]]

    self.timesPlayed = #scoreHistory
    self.highscore = highscore
    self.avgScore = avgScore
    self.totalScore = totalScore
    self.totalEarned = totalEarned
    self.totalSpent = totalSpent
    self.mostObjects = mostObjects
    self.mostScoreAddition = mostScoreAddition
    self.tallestTower = tallestTower*gScale
    self.longestPlay = longestPlay
    self.totalPlayTime = totalPlayTime

    --local str = "Times played: "..math.floor(self.scoreHistory).."\nHighscore: "..math.floor(self.highscore).."\nAverage score: "..math.floor(self.avgScore).."\nTotal score: "..string.gsub(string.format("%"..string.len(math.floor(self.totalScore))..".0f",math.floor(self.totalScore)),"%s+","").."\nTotal StackPoints earned: "..totalEarned.."\nTotal StackPoints spent: "..totalSpent.."\nMost objects on a paddle at one time: "..math.floor(self.mostObjects).."\nHighest score addition: "..math.floor(self.mostScoreAddition).."\nTallest tower: "..math.floor(self.tallestTower).." units\nLongest play: "..math.floor(self.longestPlay).." seconds\nTotal play time: "..math.floor(self.totalPlayTime).." seconds"
end

function Stats:draw()
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

    popStyle()
    popMatrix()
end

function Stats:drawContent()
    titleText("Stats",HEIGHT/5*4)

    pushStyle()
    stroke(255)
    strokeWidth(2)
    fontSize(35)
    local spacing = 20
    local yPos = HEIGHT/5*3
    for i,v in ipairs(self.stats) do
        local str = v[1]
        if v[2] == "totalScore" then
            str = str..string.gsub(string.format("%"..string.len(math.floor(self[v[2]]))..".0f",math.floor(self[v[2]])),"%s+","")
        else 
            str = str..math.floor(self[v[2]])
        end
        str = str..v[3]
        local _, sY = textSize(str)
        if i > 1 then
            --line(WIDTH/3,yPos+spacing/2,WIDTH/3*2,yPos+spacing/2)
        end
        sText(str,WIDTH/2,yPos-sY/2)
        yPos = yPos - sY - spacing
    end
    if self.scrollView.contentSize.y == 0 then
        self.scrollView.contentSize.y = math.abs(yPos)+HEIGHT+60
    end
    popStyle()
end

function Stats:touched(t)
    self.scrollView:touched(t)
end

function Stats:leaveTrans()
    self.transitioning = true
    mainReverTrans = true
    tween(.2,self,{transX = WIDTH},tween.easing.sinOut,function() changeScene("start") end)
end

function Stats:exit()
end