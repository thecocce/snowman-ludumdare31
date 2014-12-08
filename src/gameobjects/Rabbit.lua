--[[
(C) Copyright 2014 William Dyce

All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
--]]

--[[------------------------------------------------------------
CONSTANTS
--]]--

local SPEED = 24
local SPEED_FLEE = 96

--[[------------------------------------------------------------
Initialisation
--]]--

local Rabbit = Class
{
  FRICTION = 100,

  type = GameObject.newType("Rabbit"),

  init = function(self, x, y)
    GameObject.init(self, x, y, 3)
    self.heart = math.random()
    self.visibility = 1
    self.burrowed = true
  end,
}
Rabbit:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Rabbit:onPurge()
end

function Rabbit:kill()
  self.dying = 0
end

--[[------------------------------------------------------------
States
--]]--

function Rabbit:isAfraid()
  return isDaytime() or (self.visibility >= 1)
end


--[[------------------------------------------------------------
Game loop
--]]--

function Rabbit:update(dt)

  -- die
  if self.dying then
    self.dying = self.dying + dt
    if self.dying > 1 then
      self.purge = true
    end
    return
  end

  GameObject.update(self, dt)

  -- disappear like darkness!
  self.visibility = math.max(0, self.visibility - dt)
  if self.burrowed and (self.visibility <= 0) then
    self.burrowed = false
  end

  -- invisible
  if self.burrowed then
    if isDaytime() then
      self.purge = true
    end
    return
  end

  -- bouncy
  self.z = (1 + math.sin(self.heart*math.pi*2))*4

  -- heartbeat
  self.heart = self.heart + dt*2

  if self:isAfraid() then
    -- run away!
    local dx, dy, dist = Vector.normalize(self.x - WORLD_W*0.5, self.y - WORLD_H*0.5)
    self.dx, self.dy = dx*SPEED_FLEE, dy*SPEED_FLEE
    if dist > WORLD_W then
      self.purge = true
    end
  else

    -- if not self.chaser or self.heart > 1 then
    --   self.chaser = GameObject.getNearestOfType("Human", self.x, self.y)
    -- else
    --   local c = self.chaser
    --   -- run from chaser
    --   local dx, dy = Vector.normalize(self.x - c.x, self.y - c.y)
    --   self.dx, self.dy = dx*SPEED, dy*SPEED
    -- end
  end

  -- loop heart beat
  if self.heart > 1 then
    self.heart = self.heart - 1
  end
end

function Rabbit:draw(x, y)
  -- debug
  if DEBUG then
    useful.pushCanvas(UI_CANVAS)
      love.graphics.circle("line", self.x, self.y, self.r)
    useful.popCanvas()
  end

  if self.dying then
    -- die animation
    local w, h = 4*(1 + self.dying), 6*(1 - self.dying)
    love.graphics.setColor(178, 122, 173, 255*(1 - self.dying))  
      love.graphics.rectangle("fill", self.x - w, self.y - h, 2*w, h)
    useful.bindWhite()
    -- shadow
    useful.pushCanvas(SHADOW_CANVAS)
      useful.oval("fill", self.x, self.y, 6*(1 + self.dying), 6*VIEW_OBLIQUE*(1 - self.dying))
    useful.popCanvas()
    return
  end

  -- invisible
  if self.burrowed then
    return
  end

  -- breathe air
  local breath = math.sin(((self:isAfraid() and 4) or 1)*self.heart*math.pi)

  -- body
  local w, h = (4 + breath), (6 - breath)
  love.graphics.setColor(178, 122, 173)
    love.graphics.rectangle("fill", self.x - w, self.y - h - self.z, 2*w, h)
  useful.bindWhite()
  
  -- shadow
  useful.pushCanvas(SHADOW_CANVAS)
    useful.oval("fill", self.x, self.y, 6, 6*VIEW_OBLIQUE)
  useful.popCanvas()

end


--[[------------------------------------------------------------
Collisions
--]]--

function Rabbit:eventCollision(other, dt)
  if other:isType("Light") then
    self:shoveAwayFrom(other, 300*dt)
    self.visibility = math.min(1, self.visibility + 2*dt)
  end
end


--[[------------------------------------------------------------
Export
--]]--

return Rabbit