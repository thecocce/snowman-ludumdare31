DARKNESS_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)

function light(x, y, z, intensity, r, g, b)

	x = x + useful.signedRand(8 + 0.2*intensity)
	y = y + useful.signedRand(8 + 0.2*intensity)
	z = z + math.max(0.1, useful.signedRand(8 + 0.2*intensity))

	-- Wolfram: "equation of parabola passing through A(0, 0.5) B(64, 1) C(128, 0)"
	-- 0.5 + 0.00976563x -0.0000457764x^2
	intensity = intensity*math.max(0, (0.00976563 -0.0000457764*z)*z + 0.5)

  -- erase darkness with torch
  useful.pushCanvas(DARKNESS_CANVAS)
    for i = intensity, 0, -1 do
      local size = math.max(0, i*64 - z/128)
      local half_size = size*0.5
      love.graphics.setBlendMode("subtractive")
        useful.bindWhite((0.5 + 0.5*(intensity - i))*255)
        love.graphics.rectangle("fill", x - half_size, y - half_size, size, size*VIEW_OBLIQUE)
    end
    love.graphics.setBlendMode("alpha")
    useful.bindWhite()
  useful.popCanvas()
end

function lit_rectangle(x, y, w, h)
  love.graphics.rectangle("fill", x, y, w, h)
  useful.pushCanvas(DARKNESS_CANVAS)
    love.graphics.setBlendMode("subtractive")
      love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setBlendMode("alpha")
  useful.popCanvas()
end