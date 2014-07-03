ObjectStyles = class()

function ObjectStyles:init()
    self.objectAlpha = 230
    
    local darkColor = 350
    self.themes = {
        -- Bright
        {
            babyBlue = color(165,195,255),
            yellow = color(255,240,45),
            red = color(255,110,85),
            purple = color(185,130,210),
            green = color(160,255,165),
            orange = color(255,255,155),
            pink = color(255,170,250)
        },
        -- Neon
        {
            green = color(0,255,0),
            pink = color(255,50,150),
            blue = color(0,200,255),
            orange = color(255,100,50)
        },
        -- Black and white
        {
            nonCompliment = color(darkColor-textColor.r,darkColor-textColor.g,darkColor-textColor.b)
        }
    }

    self:setTheme()
end

function ObjectStyles:setTheme()
    self.colors = self.themes[colorScheme]
    self:setCompliment()
    
    for i,v in pairs(self.colors) do
        v.a = self.objectAlpha
    end
    
    self.colorNum = 0
    for i,v in pairs(self.colors) do
        self.colorNum = self.colorNum + 1
    end
    
    local destroyPreset = {
            tex = imgs.triangle,
            minSize = 5,
            maxSize = 10,
            minSpeed = 50,
            maxSpeed = 75,
            minLife = .5,
            maxLife = 1,
            accel = vec2(0,-300),
            rAccel = vec2(500,500),
            streak = true
        }
    for i,v in pairs(self.colors) do
        local e = cleanTable(destroyPreset)
        e.startColor = v
        e.endColor = color(v.r,v.g,v.b,0)
        emitters[i.."Emitter"] = Emitter( e )
    end
end

function ObjectStyles:setCompliment()
    local colorMult = 1
    self.colors.compliment = color(127+(textColor.r-127)*colorMult,127+(textColor.g-127)*colorMult,127+(textColor.b-127)*colorMult)
end

function ObjectStyles:getRandomColor()
    local colSelect = math.random(self.colorNum)
    local colCount = 0
    for i,v in pairs(self.colors) do
        colCount = colCount + 1
        if colSelect == colCount then
            return v,i
        end
    end
end

function ObjectStyles:getRandomColorValue(darkness)
    local colDarkness = darkness or 100
    return color(
                    math.random()*colDarkness+(255-colDarkness),
                    math.random()*colDarkness+(255-colDarkness),
                    math.random()*colDarkness+(255-colDarkness)
                )
end

function ObjectStyles:gradient(startCol, endCol)
    local img = image(200,1)
    
    local function blendColor( c1, c2, a )
        return color( c1.r * a + c2.r * (1 - a),
                      c1.g * a + c2.g * (1 - a),
                      c1.b * a + c2.b * (1 - a),
                      255 )
    end

    local a = 1
    local c = nil
    
    for y = 1,img.rawHeight do
        a = y / img.rawHeight
        for x = 1,img.rawWidth do
            c = blendColor(startCol, endCol, a)
            img:rawSet( x, y, c )
        end
    end
    
    return img
end