local LibDeflate = require 'LibDeflate'
local monitor = peripheral.find("monitor")
local surface = dofile("surface")
monitor.setTextScale(0.5)
local w, h = monitor.getSize()
local screen = surface.create(w, h)
local s
-- local window = window.create(monitor, 0, 0, w, h)

local VIDEO = 'vid.covid'

local file = fs.open(VIDEO, 'rb')

while true do
	local low = file.read()
	if low == nil then
		file.seek("set", 0)
		low = file.read()
	end
	local bufferLength = low + file.read() * 256
	local buffer = LibDeflate:DecompressDeflate(file.read(bufferLength))
	s = surface.load(buffer:sub(49), true)
	screen:drawSurface(s, 0, 0)
	for i = 0, 15 do
		monitor.setPaletteColor(2^i, buffer:byte(i*3+1, i*3+1) / 255, buffer:byte(i*3+2, i*3+2) / 255, buffer:byte(i*3+3, i*3+3) / 255)
	end
	-- window.create(monit)
	screen:output(monitor)
	os.sleep(0.1)
end
