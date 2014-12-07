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

local Bonfire = Class
{
  type = GameObject.newType("Bonfire"),

  init = function(self, x, y)
    GameObject.init(self, x, y, 12)
    self.fuel = 1
    self.heat = 1
    self.t = math.random()
  end,
}
Bonfire:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Bonfire:onPurge()
end


--[[------------------------------------------------------------
Game loop
--]]--

function Bonfire:update(dt)
	

  -- exponential decline of heat
  self.heat = math.max(0, self.heat - 0.002*self.heat*dt)

  -- linear decline of fuel
  if self.heat > 0.2 then
    self.fuel = self.fuel - 0.001*self.heat*dt
  else
    self.heat = 0
  end

  -- extinguish if no fuel is left
  if self.fuel <= 0.1 then
  	self.heat = useful.lerp(self.heat, 0, dt)
  end

  -- particles
  self.t = self.t + dt*30
  if self.t > 1 then
		  
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

		self.t = self.t - 1
	end
end

function Bonfire:draw(x, y)
	if self.heat > 0 then
  	light(x, y, 0, 8*self.heat)
  end
  love.graphics.setColor(32, 32, 32)
  	useful.oval("fill", self.x, self.x, 12, 12*VIEW_OBLIQUE)
  love.graphics.setColor(255, 100, 55, 255*self.heat)
  	useful.oval("fill", self.x, self.x, 5, 5*VIEW_OBLIQUE)
  useful.bindWhite()
end

function Bonfire:antiShadow()
	useful.pushCanvas(SHADOW_CANVAS)
	  love.graphics.setBlendMode("subtractive")
	    useful.oval("fill", self.x, self.y, self.heat*18, self.heat*18*VIEW_OBLIQUE)
	  love.graphics.setBlendMode("alpha")
	useful.popCanvas()
end

--[[------------------------------------------------------------
Collisions
--]]--


--[[------------------------------------------------------------
Export
--]]--

return Bonfire