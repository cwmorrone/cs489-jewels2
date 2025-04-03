local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"

local spriGem = love.graphics.newImage(
    "graphics/sprites/coin_gem_spritesheet.png")
local gridGem = Anim8.newGrid(16,16,spriGem:getWidth(),spriGem:getHeight())
local GemColors = {
    [4] = {1, 0, 0},    -- Yellow
    [5] = {0, 1, 0},    -- Blue
    [6] = {0, 0, 1},    -- Grey
    [7] = {1, 1, 0},    -- Red
    [8] = {1, 0, 1}     -- Green
}
local Gem = Class{}
Gem.SIZE = 16
Gem.SCALE = 2.5
function Gem:init(x,y,type)
    self.x = x
    self.y = y
    self.type = type 
    
    if self.type == nil then self.type = 4 end
    self.color = GemColors[self.type] or {1, 1, 1} -- Default white if type is invalid


    self.animation = Anim8.newAnimation(gridGem('1-4',self.type),0.25)
end

function Gem:setType(type)
    self.type = type
    self.color = GemColors[self.type] or {1, 1, 1}

    self.animation = Anim8.newAnimation(gridGem('1-4',self.type),0.25)
end

function Gem:nextType()
    local newtype = self.type+1
    if newtype > 8 then newtype = 4 end
    self:setType(newtype)
end

function Gem:update(dt)
    self.animation:update(dt)
end

function Gem:draw()
    self.animation:draw(spriGem, self.x, self.y, 0, Gem.SCALE, Gem.SCALE)
end

return Gem
