local Class = require "libs.hump.class"
local Timer = require "libs.hump.timer"
local Tween = require "libs.tween"

local statFont = love.graphics.newFont(26)
highScore =0
local Stats = Class{}
function Stats:init()
    self.y = 10 -- for tweening later
    self.level = 1 -- current level
    self.totalScore = 0 -- total score so far
    self.targetScore = 1000
    self.maxSecs = 99 -- max seconds for the level
    self.elapsedSecs = self.maxSecs -- start with full time
    self.timeOut = false -- game over flag
    self.tweenLevel = nil -- for later

    --level up effects
    self.levelUpAlpha = 0  -- Alpha for flash effect
    self.levelUpTextY = gameHeight / 2
    self.isLevelingUp = false -- Controls the effect duration
    self.levelUpTimer = 0 -- Timer to control fade in/out



    -- Timer to decrement elapsedSecs every second
    self.timer = Timer.new()
    self.timer:every(1, function()
        if not self.timeOut then
            if self.elapsedSecs > 0 then
                self.elapsedSecs = self.elapsedSecs - 1
            else
                self:gameOver()
            end
        end
    end)
end

function Stats:draw()
    if self.levelUpAlpha > 0 then
        love.graphics.setColor(1, 1, 0, self.levelUpAlpha) -- Yellowish flash
        love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
    end
    love.graphics.setColor(1, 0, 1) -- Magenta
    love.graphics.printf("Level " .. tostring(self.level), statFont, gameWidth/2-60, self.y, 100, "center")
    love.graphics.printf("Time " .. tostring(self.elapsedSecs) .. "/" .. tostring(self.maxSecs), statFont, 10, 10, 200)
    love.graphics.printf("Score " .. tostring(self.totalScore), statFont, gameWidth-210, 10, 200, "right")

    -- Level Up Text
    if self.isLevelingUp then
        love.graphics.setColor(1, 1, 0) -- Bright Yellow
        love.graphics.printf("LEVEL UP!", statFont, gameWidth / 2 - 100, self.levelUpTextY, 200, "center")
    end
    
    if self.timeOut then
        love.graphics.setColor(1, 0, 0) -- Red for game over
        love.graphics.printf("GAME OVER: press r to restart", statFont, gameWidth/2-100, gameHeight/2, 200, "center")
        gameState = "over"
    end

    love.graphics.setColor(1, 1, 1) -- White
end
function love.keypressed(key)
    if key == "r" then
        gameState = "start"
        love.load() -- Restart the game
    end
end

function Stats:update(dt)
    if self.timeOut then return end -- Stop updating if game is over
    self.timer:update(dt/2)
    if self.isLevelingUp then
        -- Handle fade in and fade out of level up text
        self.levelUpTimer = self.levelUpTimer - dt
        if self.levelUpTimer > 1 then
            -- Fade in
            self.levelUpAlpha = self.levelUpAlpha + dt
        elseif self.levelUpTimer > 0 then
            -- Fade out
            self.levelUpAlpha = self.levelUpAlpha - dt
        else
            -- Reset after fading out
            self.isLevelingUp = false
            self.levelUpAlpha = 0
        end
    end
end

function Stats:addScore(n)
    if self.timeOut then return end -- Prevent adding score after game over
    self.totalScore = self.totalScore + n
    if self.totalScore > self.targetScore then
        self:levelUp()
    end
end

function Stats:levelUp(dt)
    if self.timeOut then return end -- Prevent leveling up after game over
    self.level = self.level + 1
    self.targetScore = self.targetScore + self.level * 1000
    self.elapsedSecs = self.maxSecs -- Reset timer for the new level

    -- Trigger level-up effect
    self.isLevelingUp = true
    self.levelUpTimer = 2 -- Show for 2 seconds
    self.levelUpAlpha = 0 -- Start fading in
    
end

function Stats:gameOver()
    self.timeOut = true
    self.timer:clear() -- Stop the timer completely
    if self.totalScore > highScore then
        highScore = self.totalScore
    end
end

return Stats
