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
Initialisation
--]]--

local Fire = Class
{
  type = GameObject.newType("Fire"),

  init = function(self, x, y, starting_fuel)
    GameObject.init(self, x, y)
    self.fuel = starting_fuel
    self.t = math.random()
    self.spin = math.random()
  end,
}
Fire:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Fire:onPurge()
end


--[[------------------------------------------------------------
Game loop
--]]--

function Fire:update(dt)
  -- exponential decline
  self.fuel = self.fuel - 0.1*self.fuel*dt

  -- die
  if self.fuel <= 0.1 then
    self.purge = true
  end

  -- particles
  self.t = self.t + dt*15
  if self.t > 1 then

    if math.random()*1.5 > self.fuel then
      local angle = math.random()*math.pi*2
      local speed = 18 + math.random()*8
      local dx, dy = math.cos(angle)*self.fuel, math.sin(angle)*self.fuel
      Particle.Smoke(self.x + dx, self.y + dy, 
        dx*speed, 
        dy*speed, 
        30 + math.random()*10,
        0.5*self.fuel)
    else
      local angle = math.random()*math.pi*2
      local speed = 18 + math.random()*8
      local dx, dy = math.cos(angle)*self.fuel, math.sin(angle)*self.fuel
      Particle.Fire(self.x + dx, self.y + dy, 
        dx*speed, 
        dy*speed, 
        30 + math.random()*10,
        0.5)
    end

    self.t = self.t - 1
  end
end

function Fire:draw(x, y)
  light(x, y, 0, self.fuel)


  useful.bindBlack()
    local s = self.spin
    if s < 0.5 then
      -- left
      love.graphics.rectangle("fill", self.x - 12, self.y - 1, 12, 2)
    else
      -- right
      love.graphics.rectangle("fill", self.x, self.y - 1, 12, 2)
    end
  love.graphics.setColor(255, 100, 55, 255*self.fuel)
    love.graphics.rectangle("fill", self.x - 1, self.y - 1, 2, 2)
  useful.bindWhite()
end

function Fire:antiShadow()
  useful.pushCanvas(SHADOW_CANVAS)
    love.graphics.setBlendMode("subtractive")
      useful.oval("fill", self.x, self.y, self.fuel*8, self.fuel*8*VIEW_OBLIQUE)
    love.graphics.setBlendMode("alpha")
  useful.popCanvas()
end

--[[------------------------------------------------------------
Collisions
--]]--


--[[------------------------------------------------------------
Export
--]]--

return Fire