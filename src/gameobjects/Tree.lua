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

local Tree = Class
{
  type = GameObject.newType("Tree"),

  init = function(self, x, y)
    GameObject.init(self, x, y, 4)
    self.fuel = 1
    self.heat = 0
    self.particle_t = math.random()
    self.h = 64
  end,
}
Tree:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Tree:onPurge()
end


--[[------------------------------------------------------------
Game loop
--]]--

function Tree:update(dt)

  -- burn
  if self.heat > 0 then
    -- exponential decline of heat
    self.heat = math.max(0, self.heat - 0.1*self.heat*dt)

    -- linear decline of fuel
    if self.heat > 0.2 then
      self.fuel = self.fuel - 0.0001*self.heat*dt
    else
      self.heat = 0
    end

    -- die
    if self.fuel <= 0.1 then
      self.purge = true
    end

    -- particles
    self.particle_t = self.particle_t + dt*30
    if self.particle_t > 1 then

      if math.random()*1.5 > self.heat then
        local angle = math.random()*math.pi*2
        local speed = (18 + math.random()*8)*(0.5 + 0.5*self.heat)
        local dx, dy = math.cos(angle), math.sin(angle)
        Particle.Smoke(self.x + dx*4*self.heat, self.y + dy*4*self.heat, 
          dx*speed, 
          dy*speed, 
          (60 + math.random()*20)*(0.5 + 0.5*self.heat))
      else
        local angle = math.random()*math.pi*2
        local speed = 18 + math.random()*8
        local dx, dy = math.cos(angle)*self.heat, math.sin(angle)*self.heat
        Particle.Fire(self.x + dx*4, self.y + dy*4, 
          dx*speed, 
          dy*speed, 
          (60 + math.random()*20)*self.heat)
      end

      self.particle_t = self.particle_t - 1
    end
  end
end

function Tree:draw(x, y)
  light(x, y, 0, 10*self.heat)


  useful.bindBlack()

    love.graphics.rectangle(self.x - self.r*0.5, self.y - self.h, self.r, self.h)

  useful.bindWhite()

end



--[[------------------------------------------------------------
Collisions
--]]--

function Tree:eventCollision(other, dt)
  if other:isType("Tree") then
    other:shoveAwayFrom(self, 100*dt)
  end
end

--[[------------------------------------------------------------
Export
--]]--

return Tree