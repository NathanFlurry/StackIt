ObjectFunctions = class()

function ObjectFunctions:init()
    self.objects = {
        -- Static: name, pGen, pArgs, chance, worth, level
        square = {
            name = "Square",
            pGen = pRect,
            pArgs = {1,1},
            chance = 4,
            worth = 1,
            level = 0
        },
        plank = {
            name = "Plank",
            pGen = pRect,
            pArgs = {5,.3},
            chance = 2,
            worth = 3,
            level = 1.5
        },
        largePlank = {
            name = "Large Plank",
            pGen = pRect,
            pArgs = {5,1},
            chance = .1,
            worth = 12,
            level = 10
        },
        triangle = {
            name = "Triangle",
            pGen = pTri,
            pArgs = {1,1},
            chance = 3,
            worth = 3,
            level = .5
        },
        corner = {
            name = "Corner",
            pGen = pCorner,
            pArgs = {1,1},
            chance = .3,
            worth = 2,
            level = 3
        },
        doubleSquare = {
            name = "Double square",
            pGen = pDoubleSquare,
            pArgs = {1,1},
            chance = .3,
            worth = 2,
            level = 5
        },
        t = {
            name = "T",
            pGen = pT,
            pArgs = {1,1},
            chance = .2,
            worth = 2,
            level = 7
        },
        circle = {
            name = "Circle",
            pGen = pPoly,
            pArgs = {40},
            chance = 1,
            worth = 6,
            level = 5
        },
        circleCatcher = {
            name = "Circle catcher",
            pGen = halfCircle,
            pArgs = {30},
            chance = .3,
            worth = 6,
            level = 7
        },
        pentagon = {
            name = "Pentagon",
            pGen = pPoly,
            pArgs = {5},
            chance = .5,
            worth = 6,
            level = 8
        },
        oval = {
            name = "Oval",
            pGen = pOval,
            pArgs = {45},
            chance = .2,
            worth = 6,
            level = 9
        },
        hexagon = {
            name = "Hexagon",
            pGen = pPoly,
            pArgs = {6},
            chance = .5,
            worth = 5,
            level = 7
        },
        septagon = {
            name = "Heptagon",
            pGen = pPoly,
            pArgs = {7},
            chance = .5,
            worth = 8,
            level = 8
        },
        octagon = {
            name = "Octagon",
            pGen = pPoly,
            pArgs = {8},
            chance = .5,
            worth = 6,
            level = 6
        },
        flatSquare = {
            name = "Rectangle",
            pGen = pRect,
            pArgs = {1,.5},
            chance = .3,
            worth = 1,
            level = 7
        },
        largeSquare = {
            name = "Large square",
            pGen = pRect,
            pArgs = {3,3},
            chance = .1,
            worth = 10,
            level = 10
        },
        random = {
            name = "Random shape",
            pGen = pRandPoly,
            pArgs = {4,50,.5,1},
            chance = .2,
            worth = 4,
            level = 10
        },
        star = {
            name = "Star",
            pGen = pStar,
            pArgs = {4,6,.5,1.2},
            chance = .7,
            worth = 8,
            level = 7
        },
        cow = {
            name = "Cow",
            pGen = pCow,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        stackit = {
            name = "StackIt Logo",
            pGen = pStackIt,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        whale = {
            name = "Whale",
            pGen = pWhale,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        rhino = {
            name = "Rhino",
            pGen = pRhino,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        rat = {
            name = "Rat",
            pGen = pRat,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        rabbit = {
            name = "Rabbit",
            pGen = pRabbit,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        pig = {
            name = "Pig",
            pGen = pPig,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        lizard = {
            name = "Lizard",
            pGen = pLizard,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        elephant = {
            name = "Elephant",
            pGen = pElephant,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        duck = {
            name = "Duck",
            pGen = pDuck,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        car = {
            name = "Car",
            pGen = pCar,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        bus = {
            name = "Bus",
            pGen = pBus,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        },
        bird = {
            name = "Bird",
            pGen = pBird,
            pResize = true,
            pArgs = {},
            chance = .075,
            worth = 20,
            level = 12
        }
    }
end

function ObjectFunctions:findIndex(o,list)
    for i,v in ipairs(list) do
        if v == o then
            return i
        end
    end
end

function ObjectFunctions:destroyBody(o,list,cG)
    o.body:destroy()
    o.body.active = false
    table.remove(list,findIndex(o,list))
    if not cG then
        --collectgarbage()
    end
end


function ObjectFunctions:destroyAllBodies(list)
    for i = #list, 1, -1 do
        v = list[i]
        self:destroyBody(v,list,true)
        --collectgarbage()
    end
end


function ObjectFunctions:getObject(name,size,level,alreadyseen,noBody)
    level = level or 100000
    if name == "randObj" then
        local count = 0
        for i,v in pairs(self.objects) do
            if level >= (v.level * 1000) then
                count = count + v.chance
            end
        end
        local randSelect = math.random()*count
        count = 0
        for i,v in pairs(self.objects) do
            if level >= (v.level * 1000) then
                count = count + v.chance
                if randSelect <= count and name == "randObj" then
                    local allowed = false
                    if alreadyseen then
                        for j,w in pairs(seenObjects) do
                            if j == i then
                                allowed = true
                            end
                        end
                    else
                        allowed = true
                    end
                    if allowed then
                        name = i
                    end
                end
            end
        end
        if name == "randObj" then
            name = "square"
        end
    end
    if self.objects[name] or type(name) == "table" then
        local o
        if type(name) == "table" then
            o = cleanTable(name)
        else
            o = cleanTable(self.objects[name])
        end

        o.index = name

        o.id = math.random()

        o.points = {scalePoints(size,o.pGen(explodeTable(o.pArgs)),o.pResize)}

        if noBody ~= true then
            o.body = physics.body(POLYGON,explodeTable(o.points))
            o.body.bullet = true
            o.body.interpolate = true
        end

        o.size = vec2(0,0)
        for i,v in ipairs(o.points) do
            if math.abs(v.x) > o.size.x then
                o.size.x = v.x*2
            end
            if math.abs(v.y) > o.size.y then
                o.size.y = v.y*2
            end
        end
        
        if o.size.x > o.size.y then
            o.scaleDown = size/o.size.x
        else
            o.scaleDown = size/o.size.y
        end

        o.color,o.colorName = ObjectStyles:getRandomColor()

        o.m = mesh()
        o.m.vertices = triangulate(o.points)
        o.m:setColors(o.color)
        
        return o
    else
        error("Invalid key: "..name)
    end
end

function ObjectFunctions:renderMesh(m,x,y,angle)
    x = x or 0
    y = y or 0
    angle = angle or 0
    pushMatrix()
    translate(x,y)
    rotate(angle)
    m:draw()
    popMatrix()
end

function ObjectFunctions:jointObject(o)
    local doJoint = true
    for i,j in ipairs(scene.objectManager.oJointList) do
        if j.uID == o.uID then
            doJoint = false
        end
    end
    if o.phase == 0 then
        doJoint = false
    end
    if doJoint then
        local j = physics.joint(WELD,
                        o.body,
                        scene.paddle.paddles[1].body,
                        vec2(
                            (o.body.x+scene.paddle.paddles[1].body.x)/2,
                            (o.body.y+scene.paddle.paddles[1].body.y)/2
                        )
                    )
        j.uID = o.id-- + o2.id
        j.frequency = 0

        table.insert(scene.objectManager.oJointList,j)
    end
end