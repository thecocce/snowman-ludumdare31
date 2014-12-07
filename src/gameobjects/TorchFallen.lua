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

local TorchFallen = Class
{
  type = GameObject.newType("TorchFallen"),

  init = function(self, x, y, starting_fuel, starting_heat)
    GameObject.init(self, x, y)
    self.fuel = starting_fuel
    self.heat = starting_heat
    self.t = math.random()
    self.spin = math.random()
  end,
}
TorchFallen:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function TorchFallen:onPurge()
end


--[[------------------------------------------------------------
Game loop
--]]--

function TorchFallen:update(dt)
  -- exponential decline of heat
  self.heat = self.heat - 0.1*self.heat*dt

  -- linear decline of fuel
  if self.heat > 0.2 then
    self.fuel = self.fuel - 0.001*self.heat*dt
  else
    self.heat = 0
  end

  -- die
  if self.fuel <= 0.1 then
    self.purge = true
  end

  -- particles
  if self.heat > 0 then
    self.t = self.t + dt*15
    if self.t > 1 then

      if math.random()*1.5 > self.heat then
        local angle = math.random()*math.pi*2
        local speed = 18 + math.random()*8
        local dx, dy = math.cos(angle)*self.heat, math.sin(angle)*self.heat
        Particle.Smoke(self.x + dx, self.y + dy, 
          dx*speed, 
          dy*speed, 
          30 + math.random()*10,
          0.5)
      else
        local angle = math.random()*math.pi*2
        local speed = 18 + math.random()*8
        local dx, dy = math.cos(angle)*self.heat, math.sin(angle)*self.heat
        Particle.Fire(self.x + dx, self.y + dy, 
          dx*speed, 
          dy*speed, 
          30 + math.random()*10,
          0.5*self.heat)
      end

      self.t = self.t - 1
    end
  end
end

function TorchFallen:draw(x, y)
  light(x, y, 0, self.heat)


  useful.bindBlack()
    local len = 12*self.fuel
    local s = self.spin
    if s < 0.5 then
      -- left
      love.graphics.rectangle("fill", self.x - len, self.y - 1, len, 2)
    else
      -- right
      love.graphics.rectangle("fill", self.x, self.y - 1, len, 2)
    end
  love.graphics.setColor(255, 100, 55, 255*self.heat)
    love.graphics.rectangle("fill", self.x - 1, self.y - 1, 2, 2)
  useful.bindWhite()
end

function TorchFallen:antiShadow()
  useful.pushCanvas(SHADOW_CANVAS)
    love.graphics.setBlendMode("subtractive")
      useful.oval("fill", self.x, self.y, self.heat*8, self.heat*8*VIEW_OBLIQUE)
    love.graphics.setBlendMode("alpha")
  useful.popCanvas()
end

--[[------------------------------------------------------------
Collisions
--]]--


--[[------------------------------------------------------------
Export
--]]--

return TorchFallen