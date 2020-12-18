local surface = dofile('surface')

local clockScreen = "timer"

local numbers = {
	surface.load("f88f\n8ff8\n8ff8\n8ff8\n8ff8\n8ff8\nf88f\nffff\nffff\n", true),
	surface.load("f8ff\n88ff\nf8ff\nf8ff\nf8ff\nf8ff\n888f\nffff\nffff\n", true),
	surface.load("f88f\n8ff8\nfff8\nff8f\nf8ff\n8fff\n8888\nffff\nffff\n", true),
	surface.load("f88f\n8ff8\nfff8\nf88f\nfff8\n8ff8\nf88f\nffff\nffff\n", true),
	surface.load("ff88\nf8f8\n8ff8\n8888\nfff8\nfff8\nfff8\nffff\nffff\n", true),
	surface.load("8888\n8fff\n888f\nfff8\nfff8\nfff8\n888f\nffff\nffff\n", true),
	surface.load("ff8f\nf8ff\n8fff\n888f\n8ff8\n8ff8\nf88f\nffff\nffff\n", true),
	surface.load("8888\nfff8\nfff8\nff8f\nf8ff\nf8ff\nf8ff\nffff\nffff\n", true),
	surface.load("f88f\n8ff8\n8ff8\nf88f\n8ff8\n8ff8\nf88f\nffff\nffff\n", true),
	surface.load("f88f\n8ff8\n8ff8\nf888\nfff8\nff8f\nf8ff\nffff\nffff\n", true)
};
local period = surface.load("ff\nff\nff\nff\nff\nff\n8f\nff\nff", true)
local colon = surface.load("ff\nff\n8f\nff\nff\n8f\nff\nff\nff", true)
local stopwatchStartedAt
local pausedAt
local timeWhenPaused

local buttons = {
	["start"] = {
		x= 9, 
		y= 9,
		img= surface.load("ffff888888ffff\nfff8ffffff8fff\nff8ffffffff8ff\nf8ffffffffff8f\n8fffff8ffffff8\n8fffff88fffff8\n8fffff888ffff8\n8fffff8888fff8\n8fffff888ffff8\n8fffff88fffff8\n8fffff8ffffff8\nf8ffffffffff8f\nff8ffffffff8ff\nfff8ffffff8fff\nffff888888ffff\n", true)
	},
	["pause"] = {
		x= 9,
		y= 9,
		img= surface.load("ffff888888ffff\nfff8ffffff8fff\nff8ffffffff8ff\nf8ffffffffff8f\n8fff88ff88fff8\n8fff88ff88fff8\n8fff88ff88fff8\n8fff88ff88fff8\n8fff88ff88fff8\n8fff88ff88fff8\n8fff88ff88fff8\nf8ffffffffff8f\nff8ffffffff8ff\nfff8ffffff8fff\nffff888888ffff\n", true)
	},
	["reset"] = {
		x=6,
		y=15,
		img= surface.load("fff888888888888888888888ff\nff8fffffffffffffffffffff8f\nf8ff888f888f888f888f888ff8\nf8ff8f8f88ff8fff88fff8fff8\nf8ff88ff8ffff88f8ffff8fff8\nf8ff8f8f888f888f888ff8fff8\nff8fffffffffffffffffffff8f\nfff888888888888888888888ff\nffffffffffffffffffffffffff\n", true)
	}
}

function drawButton(screen, button)
	if button.img then
		screen:drawSurfaceSmall(button.img, button.x, button.y)
	elseif button.text then
		screen:drawString(button.text, button.x, button.y)
	end
end
function checkButton(event, button)
	local x, y = event[3], event[4]
	return x >= button.x and x <= button.x + button.img.width / 2 and
	y >= button.y and y <= button.y + button.img.height / 3
end

function drawTimeRaw(screen, x, y, raw)
	screen:drawSurfaceSmall(numbers[raw[1] + 1], x, y)
	screen:drawSurfaceSmall(numbers[raw[2] + 1], x+3, y)
	screen:drawSurfaceSmall(colon, x+6, y)
	screen:drawSurfaceSmall(numbers[raw[3] + 1], x+7, y)
	screen:drawSurfaceSmall(numbers[raw[4] + 1], x+10, y)
	screen:drawSurfaceSmall(period, x+13, y)
	screen:drawSurfaceSmall(numbers[raw[5] + 1], x+14, y)
	screen:drawSurfaceSmall(numbers[raw[6] + 1], x+17, y)
end

function drawTime(ms, screen, y)
	local milliseconds = {
		math.floor((ms % 100)  / 10),
		ms % 10
	}
	local sec = math.floor(ms / 100)
	local min = math.floor(sec / 60)
	if min > 99 then
		local overflowText = "Wtf are you timing";
		screen:drawString(overflowText, math.floor((screen.width - #overflowText) / 2), y)
	else
		sec = sec - min * 60
		local seconds = {
			math.floor(sec / 10),
			sec % 10
		}
		local minutes = {
			math.floor(min / 10),
			min % 10
		}
		local x = math.floor((screen.width - 20) / 2)
		-- screen:drawString(tostring(milliseconds[2]), 0, 0)
		
		drawTimeRaw(screen, x, y, {
			minutes[1], minutes[2],
			seconds[1], seconds[2],
			milliseconds[1], milliseconds[2]
		})
	end
end

function doStopwatch(screen, eventData)
	local redraw = false
	local y = 5
	local ms
	if stopwatchStartedAt == nil then
		print(buttons.start.y)
		drawButton(screen, buttons.start)
		ms = 0
	elseif pausedAt then
		drawButton(screen, buttons.reset)
		drawButton(screen, buttons.start)
		ms = timeWhenPaused
	else
		drawButton(screen, buttons.pause)
		ms = math.floor((os.epoch("utc") - stopwatchStartedAt) / 10)
	end
	drawTime(ms, screen, y)
	redraw = true
	if eventData[1] == "mouse_click" then
		if checkButton(eventData, buttons.start) then
			if not stopwatchStartedAt then
				stopwatchStartedAt = os.epoch("utc")
			elseif pausedAt then -- Resume from pause
				stopwatchStartedAt = stopwatchStartedAt + (os.epoch("utc") - pausedAt)
				pausedAt = nil
			else -- Pause
				pausedAt = os.epoch("utc")
				timeWhenPaused = math.floor((os.epoch("utc") - stopwatchStartedAt) / 10)
			end
		elseif checkButton(eventData, buttons.reset) then
			stopwatchStartedAt = nil
			pausedAt = nil
		end
	end
	return redraw
end

local timerLength = 0
local timerStartedAt = nil
local timerSetValue = ''

function numberToDigits(number)
	local str = tostring(number)
	local digits = {}
	for i=1,#str do
		table.insert(digits, tonumber(str:sub(i, 1)))
	end
	while #digits < 6 do
		table.insert(digits, 0)
	end
	return digits
end

function doTimer(screen, eventData)
	if timerStartedAt then
		local timeLeft
		if pausedAt then
			drawButton(screen, buttons.reset)
			if timeWhenPaused ~= 0 then
				drawButton(screen, buttons.start)
			end
			timeLeft = timeWhenPaused
		else
			drawButton(screen, buttons.pause)
			timeLeft = timerLength - (os.epoch("utc") - timerStartedAt)
		end
		if timeLeft < 0 then
			pausedAt = os.epoch("utc")
			timeWhenPaused = 0
			timeLeft = 0
		end
		drawTime(math.floor(timeLeft / 10), screen, 3)
	else
		local x = math.floor((screen.width - 20) / 2)
		local digits = {}
		for i=1, 4-#timerSetValue do
			table.insert(digits, 0)
		end
		for i=1, #timerSetValue do
			-- print(i, tonumber(timerSetValue:sub(i, 1)))
			table.insert(digits, tonumber(timerSetValue:sub(i, i)))
		end
		table.insert(digits, 0)
		table.insert(digits, 0)
		if #timerSetValue == 0 then
			screen:drawString("Type to set timer", 4, 3)
		end
 		drawTimeRaw(screen, x, 5, digits)
		-- drawTime(timerLength * 100, screen, 3)
		if timerSetValue ~= '' then
			drawButton(screen, buttons.start)
		end
	end
	if eventData[1] == "mouse_click" then
		if checkButton(eventData, buttons.start) then
			if not timerStartedAt then
				local tSv = timerSetValue
				while #tSv < 4 do
					tSv = '0'..tSv
				end
				timerLength = (tonumber(tSv:sub(1, 2)) * 60 + tonumber(tSv:sub(3, 4))) * 1000
				if timerLength > 0 then
					timerStartedAt = os.epoch("utc")
				end
				-- timerLength = 10 * 1000
			elseif pausedAt then
				timerStartedAt = timerStartedAt + (os.epoch("utc") - pausedAt)
				pausedAt = nil
			else -- Pause
				pausedAt = os.epoch("utc")
				timeWhenPaused = timerLength - (os.epoch("utc") - timerStartedAt)
			end
		elseif checkButton(eventData, buttons.reset) then
			timerStartedAt = nil
			pausedAt = nil
		end
	elseif eventData[1] == "key" then
		local numberEntered
		local k = eventData[2]
		if k == keys.one then
			numberEntered = 1
		elseif k == keys.two then
			numberEntered = 2
		elseif k == keys.three then
			numberEntered = 3
		elseif k == keys.four then
			numberEntered = 4
		elseif k == keys.five then
			numberEntered = 5
		elseif k == keys.six then
			numberEntered = 6
		elseif k == keys.seven then
			numberEntered = 7
		elseif k == keys.eight then
			numberEntered = 8
		elseif k == keys.nine then
			numberEntered = 9
		elseif k == keys.zero then
			numberEntered = 0
		elseif k == keys.backspace then
			timerSetValue = timerSetValue:sub(1, #timerSetValue - 1)
		end
		if numberEntered ~= nil and not (timerSetValue == '' and numberEntered == 0) then
			if #timerSetValue < 4 then
				timerSetValue = timerSetValue..tostring(numberEntered)
			end
		end
	end
	return true
end

return {
	name="Clock",
	icon="ffffff777777ffffff\nffff7777887777ffff\nfff777777777777fff\nff77777777777777ff\nf7777777777777777f\nf7777077777777707f\n777777077777700777\n777777707770077777\n787777770007777787\n787777777077777787\n777777777777777777\n777777777777777777\nf7777777777777777f\nf7777777777777777f\nff77777777777777ff\nfff777777777777fff\nffff7777887777ffff\nffffff777777ffffff\n",
	update=function(screen, eventData)
		if clockScreen == "stopwatch" then
			doStopwatch(screen, eventData)
		elseif clockScreen == "timer" then
			doTimer(screen, eventData)
		end
		return true
	end
}