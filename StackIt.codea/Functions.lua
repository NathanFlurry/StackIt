function changeScene(s)
    if scene ~= nil then
        scene:exit()
    end
    if s == "start" then
        sID = s
        scene = Start()
    elseif s == "htmlNewsView" then
        sID = s
        scene = HTMLNewsView()
    elseif s == "stats" then
        sID = s
        scene = Stats()
    elseif s == "store" then
        sID = s
        scene = Store()
    elseif s == "seenobj" then
        sID = s
        scene = SeenObj()
    elseif s == "howtoplay" then
        sID = s
        scene = HowToPlay()
    elseif s == "about" then
        sID = s
        scene = About()
    elseif s == "game" then
        sID = s
        scene = Game()
    elseif s == "settings" then
        sID = s
        scene = Settings()
    elseif s == "feedback" then
        sID = s
        scene = Feedback()
    else
        print("Invalid scene name")
    end
end

function explodeTablexx(torig)
    local t = torig
    if type(t) ~= "table" or #t == 0 then
        return nil
    elseif #t == 1 then
        return t[1]
    else
        local v = table.remove(t, 1)
        return v, explodeTable(t)
    end
end

-- Mangage touches
function testTouchRegion(x,y,w,h,debug,excuseTouchReady)
    if debug then
        pushMatrix()
        resetMatrix()
        pushStyle()
        rectMode(CENTER)
        noStroke()
        fill(255,0,0,50)
        rect(x,y,w,h)
        popMatrix()
        popStyle()
    end

    tx = currentT.x
    ty = currentT.y
    if tx < x + w/2 and tx > x - w/2 and
        ty < y + h/2 and ty > y - h/2
        and (touchReady() or excuseTouchReady) then
        touchUsed()
        return true
    else
        return false
    end
end

function touchReady()
    if currentT.id ~= tUsedId then
        return true
    else
        return false
    end
end

function touchUsed()
    tUsedId = currentT.id
end

-- Explode table
function _values(t)
    local i = 0
    return function() i = i + 1; return t[i] end
end

function _explodeNext(iter, t)
    local v = iter(t)
    if v ~= nil then
        return v, _explodeNext(iter, t)
    else
        return
    end 
end

function explodeTable(t)
    local iter = _values(t)
    return _explodeNext(iter, t)
end

-- Unreference table
function cleanTable(t)
    local nt = {}
    for i,v in pairs(t) do
        if type(v) == "table" then
            nt[i] = cleanTable(v)
        else
            nt[i] = v
        end
    end
    return nt
end

-- Set ShackPoitns
function addStackPoints(amnt)
    _setStackPoints(stackPoints+amnt,amnt)
end

function _setStackPoints(amnt,change)
    stackPoints = amnt
    saveLocalData("stackPoints",stackPoints)
    if change and change > 0 then
        totalEarned = totalEarned + change
        saveLocalData("totalEarned",totalEarned)
    elseif change then
        totalSpent = totalSpent - change
        saveLocalData("totalSpent",totalSpent)
    end
end

-- Anglify
function anglify (p1,p2,curAngle)
    local angle1 = _anglify(vec2(p1.x,p1.y),vec2(p2.x,p2.y))
    local angle2 = angle1+180
    local getDiff = function(a)
            local diff = a - curAngle
            diff = (diff + 180)%360-180
            return math.abs(diff)
        end
    if getDiff(angle1) < getDiff(angle2) then
        return angle1
    else
        return angle2
    end
end

function _anglify (p1,p2)
    deltaY = p2.y - p1.y
    deltaX = p2.x - p1.x
    if deltaX < 0 then
        deltaY = -deltaY
        deltaX = -deltaX
    end
    angle = math.atan2(deltaY,deltaX) * 180 / math.pi
    return angle
end

-- Rounding
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Angle of point (for GStroke)

mp = (180/math.pi)
function angleOfPoint( pt )
   local ang = math.atan2(pt.y,pt.x)*(180/math.pi)
    if ang < 0 then ang = 360+ang elseif ang > 360 then ang = 0+(ang-360) end
    return ang 
end


-- Mesh masking

function meshBounds( m )
    local verts = m.vertices
 
    local ll = vec3( math.huge, math.huge, math.huge )
    local ur = -ll
    local v
 
    for i = 1,#verts do
        v = verts[i]
 
        if v.x < ll.x then ll.x = v.x end
        if v.y < ll.y then ll.y = v.y end
        if v.z < ll.z then ll.z = v.z end
        if v.x > ur.x then ur.x = v.x end
        if v.y > ur.y then ur.y = v.y end
        if v.z > ur.z then ur.z = v.z end
    end
 
    return ll, ur
end
 
-- This function normalizes the texture coordinates
--  of all the vertices within a mesh bassed on their
--  spatial position
function mapMeshCoords( m )
    local ll, ur = meshBounds( m )
 
    local bounds = vec2( ur.x - ll.x, ur.y - ll.y )
    
    local v, tx, ty
    for i = 1,m.size do
        v = m:vertex(i)
 
        tx = (v.x - ll.x) / bounds.x
        ty = (v.y - ll.y) / bounds.y
 
        m:texCoord( i, tx, ty )
    end
end

-- Coin display
function drawStackPoints(pos,offset,drawMultiplier)
    local offset = offset or 0
    drawCustomStackPoints(pos,stackPoints+offset,drawMultiplier)
end

function drawCustomStackPoints(pos,amnt,drawMultiplier)
    local xOffset = fontSize()/2
    local str = tostring(amnt)
    if (purchases.stackPointMultiplier or 0) > 1 and drawMultiplier then
        str = str.."x"..tostring(purchases.stackPointMultiplier)
    end
    sText(str,pos.x+xOffset,pos.y)
    pushStyle()
    tint(fill())
    sSprite(imgs.coin,pos.x-textSize(str)/2-fontSize()+xOffset,pos.y,3,fontSize())
    popStyle()
end

-- Shadowed text
function sText(txt,x,y,depth,txtColor,shadowColor)
    if type(txt) ~= "string" and type(txt) ~= "number" then
        print(debug.traceback())
    end
    local oldFill = color()
    oldFill.r, oldFill.g, oldFill.b,oldFill.a = fill()
    pushStyle()
    pushMatrix()
    translate(x+shadowOffset.x*(depth or 3),y+shadowOffset.y*(depth or 3))
    if shadowColor then
        fill(shadowColor)
    else
        fill(0, 0, 0, 50)
    end
    text(txt,0,0)
    popMatrix()
    if txtColor then
        fill(txtColor)
    else
        fill(oldFill)
    end
    text(txt,x,y)
    popStyle()
end

-- Shadowed sprite
function sSprite(img,x,y,depth,scaleSize)
    pushStyle()
    r,g,b,a = tint()

    smooth()

    pushMatrix()
    translate(x+shadowOffset.x*(depth or 3),y+shadowOffset.y*(depth or 3))
    if scaleSize then
        scale(gScale)
    end
    tint(0,0,0,50*(a/255))
    if scaleSize then
        sprite(img,0,0,scaleSize)
    else
        sprite(img,0,0)
    end
    popMatrix()

    pushMatrix()
    translate(x,y)
    tint(r,g,b,a)
    if scaleSize then
        sprite(img,0,0,scaleSize)
    else
        sprite(img,0,0)
    end
    popMatrix()

    popStyle()
end

-- Title text
function titleText(txt,y)
    pushStyle()
    resetStyle()
    fill(223, 223, 223, 194)
    rectMode(CENTER)
    --rect(WIDTH/2,y,WIDTH,50)
    fontSize(140*gScale)
    textWrapWidth(WIDTH-50)
    fill(textColor)
    font(globalFont)
    sText(txt,WIDTH/2,y,4)
    popStyle()
end

-- Table to string saving

function tToS (name, value, saved)
    local function basicSerialize (o)
        if type(o) == "number" then
            return tostring(o)
        elseif type(o) == "boolean" then
            return tostring(o)
        else -- assume it is a string
            return string.format("%q", o)
        end
    end
    saved = saved or {}
    local returnStr = name.." = " 
    if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
        returnStr = returnStr..basicSerialize(value).."\n"
    elseif type(value) == "table" then
        if saved[value] then
            returnStr = returnStr..saved[value].."\n"
        else
            saved[value] = name
            returnStr = returnStr.."{}\n"
            for k,v in pairs(value) do 
                local fieldname = string.format("%s[%s]", name, basicSerialize(k))
                returnStr = returnStr..tToS(fieldname, v, saved)
            end
        end
    else
        error("Cannot save a " .. type(value))
    end
    return returnStr
end

-- String to URI
function sToURI(s)
    return string.gsub(string.gsub(s, " ", "%%20"), "\n","%%0A")
end

-- listToString
function listToString(...)
    local str = ""
    for i,v in ipairs{...} do
        if i == 1 then
            str = str..tostring(v)
        else
            str = str..", "..tostring(v)
        end
    end
    return str
end

function findIndex(o,list)
    local index = nil
    for i,v in pairs(list) do
        if v == o then
            index = i
        end
    end
    if index == nil then
        -- alert("Couldn't find object to destroy")
    else
        return index
    end
end

-- Gradient
function getGradient(size,color1,color2)
    local m = mesh()

    m.setSize = function(size)
        m.vertices = {
            vec2(-size.x/2,-size.y/2),
            vec2(-size.x/2,size.y/2),
            vec2(size.x/2,-size.y/2),

            vec2(size.x/2,size.y/2),
            vec2(-size.x/2,size.y/2),
            vec2(size.x/2,-size.y/2)
        }
    end

    m.setGradient = function(color1,color2)
        m.colors = {
            color2,
            color1,
            color2,

            color1,
            color1,
            color2

        }
    end

    m.setSize(size)
    m.setGradient(color1,color2)

    return m
end

function getLineCount()
    local str = ""
    local totalLines = 0
    for i,v in ipairs(listProjectTabs()) do
        local tab = readProjectTab( v )
        local count = 0
        for i,v in tab:gmatch("\n") do
            count = count + 1
        end
        str = str.."Tab '"..v.."' has "..count.." lines.\n"
        totalLines = totalLines + count
    end
    alert(str.."\nYou have "..totalLines.." lines total.")
end

-- Get time values
function getDecimalTime(time)
    time = time or os.date("*t")
    seconds = time.sec+(time.min*60)+(time.hour*3600)
    decimal = seconds/86400
    return decimal
end

function getPercentOfMonth(d)
    local d = os.date("*t")
    return d.day/getMonthLength()
end

function getMonthLength()
    local d = os.date("*t")
    local monthLengths = {}
    for i = 1,12 do
        if i % 2 == 0 then
            table.insert(monthLengths,31)
        else
            table.insert(monthLengths,31)
        end
    end
    if d.year % 4 == 0 and (d.year % 100 ~= 0 or d.year % 400 == 0) then
        monthLengths[2] = 28
    end
    return monthLengths[d.month]
end

-- Hours since epoch
function hoursSinceEpoch()
    return os.time()/3600--/60/60
end

-- Make moon points

function generateMoonPoints(a,res)
    local dir

    if a >= 180 then
        dir = -1
    else
        dir = -1
    end
    a = (90-math.abs(a-180))/90

    local p = {}
    for i = 0, res/2 do
        local l = i/res*math.pi*2
        table.insert(p,vec2(
                        math.cos(l),
                        math.sin(l)*dir
                    ))
    end
    for i = res/2, 0,-1 do
        local l = i/res*math.pi*2
        table.insert(p,vec2(
                        math.cos(l),
                        math.sin(l)*a
                    ))
    end
    return triangulate(p)
end

-- Debug stuff

function debugDraw(val)
    val = val or _G
    for i,v in pairs(val) do
        if type(v) == "userdata" and v.type and v.shapeType then
            debugDrawBody(v)
        end
        if type(v) == "table" then
            debugDraw(v)
        end
    end
end

function debugDrawBody(b)
    pushStyle()
    pushMatrix()
    translate(b.x,b.y)
    rotate(b.angle)

    if b.type == STATIC then
        stroke(255,255,255,255)
    elseif b.type == DYNAMIC then
        stroke(150,255,150,255)
    elseif b.type == KINEMATIC then
        stroke(150,150,255,255)
    end

    if b.shapeType == POLYGON then
        strokeWidth(3)
        local points = b.points
        for j = 1,#points do
            local a = points[j]
            local b = points[(j % #points)+1]
            line(a.x,a.y,b.x,b.y)
        end
    elseif b.shapeType == CHAIN or b.shapeType == EDGE then
        strokeWidth(3)
        local points = b.points
        for j = 1,#points-1 do
            local a = points[j]
            local b = points[j+1]
            line(a.x,a.y,b.x,b.y)
        end
    elseif b.shapeType == CIRCLE then
        strokeWidth(3)
        line(0,0,b.radius-3,0)
        ellipse(0,0,b.radius*2)
    end

    popStyle()
    popMatrix()
end

function trace(event, line)
    local s = debug.getinfo(2).short_src
    NSLog(s..":"..line)
end

function setTraceOn(b)
    if b then
        debug.sethook(trace, "l")
    else
        debug.sethook()
    end
end

__OldErrorFunc = error

function myError(msg, level)
    NSLog(debug.traceback())
    __OldErrorFunc(msg, level)
end

function setMyErrorOn(b)
    if b then
        error = myError
    else
        error = __OldErrorFunc
    end
end

-- Draw score
function drawScore(rank,score,spacing,y,isScore)
    pushMatrix()
    pushStyle()
    translate(0,y)
    if isScore then
        --scale(1.8)
        fontSize(fontSize()+20)
    end

    pushStyle()
    textAlign(RIGHT)
    text("#"..rank,-spacing-textSize("#"..rank)/2,0)
    popStyle()

    pushStyle()
    textAlign(LEFT)
    if score == 0 then
        score = "None"
    end
    text(score,spacing+textSize(score)/2,0)
    popStyle()
    popMatrix()
    popStyle()
end

-- Rounded rect
function roundRect(x, y, w, h, cr)
    pushStyle()
    insetPos = vec2(x+cr,y+cr)
    insetSize = vec2(w-2*cr,h-2*cr)

    rectMode(CORNER)
    rect(insetPos.x,insetPos.y,insetSize.x,insetSize.y)

    r,g,b,a = fill()
    stroke(r,g,b,a)

    if r > 0 then
        smooth()
        lineCapMode(ROUND)
        strokeWidth(cr*2)

        line(insetPos.x, insetPos.y, 
             insetPos.x + insetSize.x, insetPos.y)
        line(insetPos.x, insetPos.y,
            insetPos.x, insetPos.y + insetSize.y)
        line(insetPos.x, insetPos.y + insetSize.y,
             insetPos.x + insetSize.x, insetPos.y + insetSize.y)
        line(insetPos.x + insetSize.x, insetPos.y,
            insetPos.x + insetSize.x, insetPos.y + insetSize.y)           
    end
    popStyle()
end

-- Leave feedback
function leaveFeedback()
    advancedAlert("How do you feel about StackIt?","","Cancel",{"Content","Flustered","Disappointed","Other"},
        function(index,title)
            feedbackCallback = index
            --[[if index == 1 then
                advancedAlert("What would you like to do?","","Cancel",{"Write a review","Contact InterDazzle","Tweet about StackIt","Post on FaceBook about StackIt"},function() print("hello") end)
                    function(index,title)
                        print("hello")
                        if index == 1 then
                            print(rateApp,showAppPreview)
                            --rateApp("741575975")
                        elseif index == 2 then
                            sendEmail("support@interdazzle.com","I love StackIt",getSupportMessage())
                        elseif index == 3 then
                            -- WRITE OBJ-C FUNC
                        elseif index == 4 then
                            -- WRITE OBJ-C FUNC
                        end
                    end)
            elseif index == 2 then
                advancedAlert("What would you like to do?","","Cancel",{"Got to help screen","Contact InterDazzle"},
                    function(index,title)
                        if index == 1 then
                            changeScene("Help")
                        elseif index == 2 then
                            sendEmail("support@interdazzle.com","I'm confused about StackIt",getSupportMessage())
                        end
                        end)
            elseif index == 3 then
                sendEmail("support@interdazzle.com","I'm disappointed with Stackit",getSupportMessage())
            elseif index == 4 then
                sendEmail("support@interdazzle.com","I'd like to talk to you'",getSupportMessage())
            end]]--
        end)
end

function getSupportMessage()

    local message = [[
    <style>
    html,body {
        padding: 0;
        margin: 0;
    }

    #content {
        font-size: 25px;
        background-color: #ffffff;
        width: 100%;
    }

    .formItem {
        border-radius: 4px;
        width: 100%;
        height: 35px;
        border: none;
        -webkit-appearance: none;
        appearance: none;
        -webkit-transition: .5s ease-out;
        -moz-transition: .5s ease-out;
        -o-transition: .5s ease-out;
        -ms-trsansition: .5s ease-out;
        background-color: rgb(238, 238, 238);
        display: block;
        padding: 10px;
    }

    .formItem:focus {
        outline: none;
        background-color: #cbcbcb;
    }

    .multiline {
        min-height: 300px;
    }

    .hidden {
        color: white;
        font-size: 1px;
    }
    </style>

    <div id="content">
    Thank you for contacting InterDazzle. Please fill out the following form:<br /><br />
    Name:<br />
    <div class="formItem" contenteditable=""></div><br />
    Reason for contact: <br />
    <div class="formItem" contenteditable=""></div><br />
    Message: <br />
    <div class="formItem multiline" contenteditable></div><br />
    <br />
    Thank you!
    <br />
    <div class="hidden"><br />Please don't delete this:<br />deviceinfohere</div>
    </div>
    ]]

    message = string.gsub(message,"deviceinfohere","Memory: "..tostring(MemoryInfo()).."<br />Disk space size: "..tostring(DiskSpaceSize()).."<br />Version: "..tostring(MyAppVersion()).."<br />OS version: "..tostring(OSVersion()).."<br />Device model: "..tostring(DeviceModel()))

    return message
end