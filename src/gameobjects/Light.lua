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

local Light = Class
{
  type = GameObject.newType("Light"),

  init = function(self, x, y)
    GameObject.init(self, x, y, 1)
  end,
}
Light:include(GameObject)


--[[------------------------------------------------------------
Game loop
--]]--

function Light:update(dt)
end

function Light:draw()
  if DEBUG then
    useful.pushCanvas(UI_CANVAS)
      useful.oval("line", self.x, self.y, self.r, self.r*VIEW_OBLIQUE)
    useful.popCanvas()
  end
end

--[[------------------------------------------------------------
Export
--]]--

return Light