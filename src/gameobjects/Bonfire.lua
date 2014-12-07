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
    GameObject.init(self, x, y)
    self.fuel = 1
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
	self.t = self.t + dt*30

	if self.t > 1 then

		if math.random()*1.5 > self.fuel then
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

		self.t = self.t - 1
	end



end

function Bonfire:draw(x, y)
  light(x, y, 0, 8)
  love.graphics.setColor(32, 32, 32)
  	useful.oval("fill", self.x, self.x, 12, 12*VIEW_OBLIQUE)
  love.graphics.setColor(255, 100, 55)
  	useful.oval("fill", self.x, self.x, 5, 5*VIEW_OBLIQUE)
  useful.bindWhite()
end

--[[------------------------------------------------------------
Collisions
--]]--


--[[------------------------------------------------------------
Export
--]]--

return Bonfire