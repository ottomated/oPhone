local surface = dofile("surface")
local monitor = peripheral.find('monitor')
local oldTerm = term.redirect(monitor)
monitor.setTextScale(0.5)
monitor.setPaletteColor(colors.cyan, 0x62729b)
monitor.setPaletteColor(colors.orange, 0xefcd8a)
monitor.setPaletteColor(colors.brown, 0xa38c5e)
local width, height = monitor.getSize()
local screen = surface.create(width, height)
math.round = function(x) return x + 0.5 - (x + 0.5) % 1 end

function fpart(x)
	return x - math.floor(x)
end
function rfpart(x)
	return 1 - fpart(x)
end

function plot(starColors, x, y, b)
	local color
	if b < 0.25 then
		color = colors.black
	elseif b < 0.5 then
		color = starColors.dark
	else
		color = starColors.light
	end
	screen:drawPixel(x, y, color)
end

function aliasLine(x0, y0, x1, y1, starColors)
	local tmp
	local steep = math.abs(y1 - y0) > math.abs(x1 - x0)
	if steep then
		tmp = x0
		x0 = y0
		y0 = tmp
		tmp = x1
		x1 = y1
		y1 = tmp
	end
	if x0 > x1 then
		tmp = x0
		x0 = x1
		x1 = tmp
		tmp = y0
		y0 = y1
		y1 = tmp
	end

	local dx, dy = x1 - x0, y1 - y0
	local gradient = dy / dx
	if dx == 0 then
		gradient = 1
	end

	xend = math.round(x0)
	yend = y0 + gradient * (xend - x0)
	xgap = rfpart(x0 + 0.5)
	xpxl1 = xend
	ypxl1 = math.floor(yend)
	if steep then
		plot(starColors, ypxl1,   xpxl1, rfpart(yend) * xgap)
		plot(starColors, ypxl1+1, xpxl1,  fpart(yend) * xgap)
	else
		plot(starColors, xpxl1, ypxl1  , rfpart(yend) * xgap)
		plot(starColors, xpxl1, ypxl1+1,  fpart(yend) * xgap)
	end
	intery = yend + gradient

	xend = math.round(x1)
	yend = y1 + gradient * (xend - x1)
	xgap = fpart(x1 + 0.5)
	xpxl2 = xend
	ypxl2 = math.floor(yend)
	if steep then
		plot(starColors, ypxl2  , xpxl2, rfpart(yend) * xgap)
		plot(starColors, ypxl2+1, xpxl2,  fpart(yend) * xgap)
	else
		plot(starColors, xpxl2, ypxl2,  rfpart(yend) * xgap)
		plot(starColors, xpxl2, ypxl2+1, fpart(yend) * xgap)
	end

	if steep then
		for x=xpxl1 + 1,xpxl2 - 1 do
			plot(starColors, math.floor(intery)  , x, rfpart(intery))
			plot(starColors, math.floor(intery)+1, x,  fpart(intery))
			intery = intery + gradient
		end
	else
		for x=xpxl1 + 1,xpxl2 - 1 do
			plot(starColors, x, math.floor(intery),  rfpart(intery))
			plot(starColors, x, math.floor(intery)+1, fpart(intery))
			intery = intery + gradient
		end
	end
end

local allStarColors = {
	{dark=colors.lightGray, light=colors.white},
	{dark=colors.purple, light=colors.pink},
	{dark=colors.brown, light=colors.orange},
}
local stars = {}
for i=1,100 do
	local x = math.random(0, width)
	local y = math.random(0, height)

	local starColors = allStarColors[math.random(1, #allStarColors)]
	
	table.insert(stars, {
		x = x,
		y = y,
		length = 1,
		angle = math.atan2(y - height / 2, x - width / 2),
		starColors = starColors
	})
end

local starGrowth = 1

function drawStars()
	screen:clear(colors.black)
	for _, star in ipairs(stars) do
		local endX, endY = math.cos(star.angle) * star.length + star.x , math.sin(star.angle) * star.length + star.y
		aliasLine(star.x, star.y, endX, endY, star.starColors)
		star.length = star.length + starGrowth
		-- starGrowth = starGrowth + 0.005
		if star.length > 4 then
			star.x = star.x + math.cos(star.angle) * starGrowth
			star.y = star.y + math.sin(star.angle) * starGrowth
			if star.x > width or star.x < 0 or star.y > height or star.y < 0 then
				star.x = math.random(0, width)
				star.y = math.random(0, height)
				star.length = 1
				star.angle = math.atan2(star.y - height / 2, star.x - width / 2)
			end
		end
	end
end

while true do
	drawStars()
	screen:output()
	os.sleep(0.05)
end