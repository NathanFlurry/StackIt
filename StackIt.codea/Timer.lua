Timer = class()

function Timer:init(interval,callback)
    self.interval = interval
    self.callback = callback
    self.time = 0
    self.occurances = 0
    self.paused = false
end

function Timer:update()
    if self.paused ~= true then
        self.time = self.time + DeltaTime
        if self.time >= self.interval then
            self.occurances = self.occurances + 1
            self.time = 0
            if type(self.callback) == "function" then
                self.callback(self.occurances)
            end
            return true
        else
            return false
        end
    end
end

function Timer:reset()
    self.time = 0
    self.occurances = 0
end

function Timer:pause()
    self.paused = true
end

function Timer:resume()
    self.paused = false
end

function Timer:isPaused()
    return self.paused
end

function Timer:getTime()
    return self.time
end

function Timer:getCount()
    return self.occurances
end