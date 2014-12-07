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

local SPEED = 32
local SPEED_FLEE = 96

--[[------------------------------------------------------------
Initialisation
--]]--

local Monster = Class
{
  FRICTION = 100,

  type = GameObject.newType("Monster"),

  init = function(self, x, y)
    GameObject.init(self, x, y, 6)
    self.fire_t = math.random()
  end,
}
Monster:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Monster:onPurge()
end

--[[------------------------------------------------------------
States
--]]--

function Monster:setState(newStateClass, ...)
  
  if self.state.class == newStateClass then
    return
  end
  local newState = newState(self, ...)
  newState.class = newStateClass

  local oldState = self.state
  if oldState.exitTo then
    oldState.exitTo(newState)
  end
  if newState.enterFrom then
    newState.enterFrom(oldState)
  end
  self.state = newState
end


--[[------------------------------------------------------------
Game loop
--]]--

function Monster:update(dt)

  if self.fire or (day_night > 0) then
    -- run away!
    local dx, dy, dist = Vector.normalize(self.x - WORLD_W*0.5, self.y - WORLD_H*0.5)
    self.dx, self.dy = dx*SPEED_FLEE, dy*SPEED_FLEE
    if dist > WORLD_W then
      self.purge = true
    end
  else

    if not self.target then
      self.target = GameObject.getNearestOfType("Human", self.x, self.y)
    else
      local t = self.target
      
      if self:isNear(t) then
        -- attack target
        t.purge = true
        self.target = nil
      else
        -- move to target
        local dx, dy = Vector.normalize(t.x - self.x, t.y - self.y)
        self.dx, self.dy = dx*SPEED, dy*SPEED
      end

    end
  end

  if self.fire then
    self.fire_t = self.fire_t + 20*dt
    -- burn, howl in pain!
    if self.fire_t > 1 then

      if math.random() > 0.5 then
        local angle = math.random()*math.pi*2
        local speed = 18 + math.random()*8
        local dx, dy = math.cos(angle), math.sin(angle)
        Particle.Smoke(self.x + dx*4, self.y + dy*4, 
          dx*speed, 
          dy*speed, 
          60 + math.random()*20)
      else
        local angle = math.random()*math.pi*2
        local speed = 18 + math.random()*8
        local dx, dy = math.cos(angle), math.sin(angle)
        Particle.Fire(self.x + dx*4, self.y + dy*4, 
          dx*speed, 
          dy*speed, 
          60 + math.random()*20)
      end

      self.fire_t = self.fire_t - 1
    end
  end

  GameObject.update(self, dt)
end

function Monster:draw(x, y)

  if self.fire then
    light(self.x, self.y, 32, 3)
  end

  love.graphics.setColor(122, 152, 178)
    love.graphics.rectangle("fill", self.x - 7, self.y - 32, 14, 32)
  useful.bindWhite()
  
  -- shadow
  useful.pushCanvas(SHADOW_CANVAS)
    useful.oval("fill", self.x, self.y, 14, 14*VIEW_OBLIQUE)
  useful.popCanvas()

  -- debug
  if DEBUG and self.target then
    useful.bindBlack()
      love.graphics.line(x, y, self.target.x, self.target.y)
    useful.bindWhite()
  end

end

--[[------------------------------------------------------------
Combat
--]]--

function Monster:ignite()
  self.fire = true
end

function Monster:isOnFire()
  return self.fire
end


--[[------------------------------------------------------------
Collisions
--]]--

function Monster:eventCollision(other, dt)
  if other:isType("Monster") then
    other:shoveAwayFrom(self, 100*dt)
  elseif other:isType("Human") then
    other:shoveAwayFrom(self, 300*dt)
  end
end


--[[------------------------------------------------------------
Export
--]]--

return Monster