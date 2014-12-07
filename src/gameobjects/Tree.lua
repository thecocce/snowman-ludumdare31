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
    GameObject.init(self, x, y, 8)

    self.h = 50

    for i = 1, 2 do 
      local angle = math.random()*math.pi*2
      local dist = 8 + math.random()*4
      TorchFallen(
        x + math.cos(angle)*dist, 
        y + math.sin(angle)*dist, 1, 0)
    end

    self.branches = {}
    local n_branches = 3 + math.random(3)
    for i = 1, n_branches do
      local progress = i/n_branches
      table.insert(self.branches, {
        z = (0.2 + 0.6*progress) * self.h ,
        side = 2*(i%2) - 1,
        length = 3 + (8 + math.random()*4)*(1 - progress)
      })
    end

    self.branchSpawn = math.random() - 1
  end,
}
Tree:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Tree:onPurge()
end

--[[------------------------------------------------------------
Fire
--]]--

function Tree:ignite()
  self.bonfire = Bonfire(self.x, self.y - 1)
  self.bonfire.tree = self
end


function Tree:isOnFire()
  return (self.bonfire ~= nil)
end

--[[------------------------------------------------------------
Game loop
--]]--

function Tree:update(dt)
  if self.bonfire and self.bonfire.purge then
    self.bonfire = nil
  else
    self.branchSpawn = self.branchSpawn + dt/90
    if self.branchSpawn > 1 then
      self.branchSpawn = self.branchSpawn - 1


      local a = math.random()*math.pi*2
      local d = 12 + math.random()*6
      local x, y = self.x + math.cos(a)*d, self.y + math.sin(a)*d
      local t = Torch(self.x, self.y, x, y, 1, 0)
      t.startz = 0.5*(1 + math.random())*self.h
      t.alreadyHit[self] = true
    end

  end
end

function Tree:draw(x, y)
  -- tree body
  love.graphics.setColor(24, 32, 48)
    love.graphics.rectangle("fill", self.x - 2, self.y - self.h, 4, self.h)
    for _, b in ipairs(self.branches) do
      love.graphics.rectangle("fill", self.x, self.y - b.z, b.length*b.side, 2)
    end
  useful.bindWhite()

  -- shadow
  useful.pushCanvas(SHADOW_CANVAS)
    useful.oval("fill", self.x, self.y, 15, 15*VIEW_OBLIQUE)
  useful.popCanvas()

  -- debug overlay
  if DEBUG then
    useful.pushCanvas(UI_CANVAS)
      love.graphics.circle("line", self.x, self.y, self.r)
    useful.popCanvas()
  end
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