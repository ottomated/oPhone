local surface = dofile('surface')

local width, height = 26, 20
term.setPaletteColor(colors.purple, 0x9047f9)

local apps = {}
for _, appFile in ipairs(fs.list("apps")) do
	local app = dofile(fs.combine("apps", appFile))
	table.insert(apps, app)
end

local currentApp
function switchApp(index)
	currentApp = apps[index]
end

local homePage = 0
local home = {
	name="Home",
	icon="",
	update = function (screen, eventData)
		local offset = homePage * 4 + 1
		for i=homePage * 4 + 1, math.min((homePage + 1) * 4, #apps) do
			local app = apps[i]
			local icon = surface.load(app.icon, true)
			local x, y = 2 + ((i - offset) % 2) * 13, 1 + math.floor((i - offset) / 2) * 9
			local width = icon.width
			if icon.width > 12 then
				screen:drawSurfaceSmall(icon, x, y)
				width = icon.width / 2
			else
				screen:drawSurface(icon, x, y)
			end
			screen:drawString(app.name, math.ceil(x + (width - #app.name) / 2), y + 7)
		end
		if eventData[1] == "mouse_click" then
			local button, x, y = eventData[2], eventData[3], eventData[4]
			if button == 1 then
				local appClicked
				if x < width / 2 and y < height / 2 then
					appClicked = offset
				elseif x > width / 2 and y < height / 2 then
					appClicked = offset + 1
				elseif x < width / 2 and y > height / 2 then
					appClicked = offset + 2
				else
					appClicked = offset + 3
				end
				switchApp(appClicked)
			end
		elseif eventData[1] == "mouse_scroll" then
			homePage = math.min(math.floor(#apps / 4), math.max(0, homePage + eventData[2]))
		end
	end
}


function osEvents()
	local titleBar = surface.create(width, 1)
	titleBar:clear(colors.gray, colors.white)
	titleBar:drawString(textutils.formatTime(os.time("ingame")), 0, 0)
	titleBar:output()
end

currentApp = home
local timer = os.startTimer(.5)
local shouldRedraw = true
local redrawTimer = nil
while true do
	if shouldRedraw then
		if redrawTimer then
			os.cancelTimer(redrawTimer)
		end
		redrawTimer = os.startTimer(0.05)
		shouldRedraw = false
	end
	local eventData = {os.pullEvent()}
	-- print(textutils.serialize(eventData))
	if eventData[1] == "timer" and eventData[2] == timer then
		timer = os.startTimer(.5)
	elseif eventData[1] == "key" and eventData[2] == keys.tab then
		currentApp = home
	else
		print("REDRAW")
		local screen = surface.create(width, height)
		shouldRedraw = currentApp.update(screen, eventData)
		screen:output(term, 0, 1)
	end
	osEvents()
end