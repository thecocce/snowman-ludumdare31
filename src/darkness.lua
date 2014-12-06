DARKNESS_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)

function light(x, y, z, intensity)

	x = x + useful.signedRand(8*intensity)
	y = y + useful.signedRand(8*intensity)
	z = z + math.max(0.1, useful.signedRand(8*intensity))

	-- Wolfram: "equation of parabola passing through A(0, 0.5) B(64, 1) C(128, 0)"
	-- 0.5 + 0.00976563x -0.0000457764x^2
	log:write(math.floor(z), math.floor((64 -0.5*z)*z + 0.5))
	intensity = intensity*math.max(0, (0.00976563 -0.0000457764*z)*z + 0.5)

	local r = math.max(0, intensity*64 - z/128)
	local half_r = r*0.5

  -- erase darkness with torch
  useful.pushCanvas(DARKNESS_CANVAS)
    love.graphics.setBlendMode("subtractive")
      useful.bindWhite(128)
        love.graphics.rectangle("fill", x - half_r, y - half_r, r, r*VIEW_OBLIQUE)
    love.graphics.setBlendMode("alpha")
  useful.popCanvas()
end