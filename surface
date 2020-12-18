local surface = { } do
--[[
Surface 2

The MIT License (MIT)
Copyright (c) 2017 CrazedProgrammer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local surf = { }
surface.surf = surf

local table_concat, math_floor, math_atan2 = table.concat, math.floor, math.atan2

local _cc_color_to_hex, _cc_hex_to_color = { }, { }
for i = 0, 15 do
	_cc_color_to_hex[2 ^ i] = string.format("%01x", i)
	_cc_hex_to_color[string.format("%01x", i)] = 2 ^ i
end

local _chars = { }
for i = 0, 255 do
	_chars[i] = string.char(i)
end
local _numstr = { }
for i = 0, 1023 do
	_numstr[i] = tostring(i)
end

local _eprc, _esin, _ecos = 20, { }, { }
for i = 0, _eprc - 1 do
	_esin[i + 1] = (1 - math.sin(i / _eprc * math.pi * 2)) / 2
	_ecos[i + 1] = (1 + math.cos(i / _eprc * math.pi * 2)) / 2
end

local _steps, _palette, _rgbpal, _palr, _palg, _palb = 16

local function calcStack(stack, width, height)
	local ox, oy, cx, cy, cwidth, cheight = 0, 0, 0, 0, width, height
	for i = 1, #stack do
		ox = ox + stack[i].ox
		oy = oy + stack[i].oy
		cx = cx + stack[i].x
		cy = cy + stack[i].y
		cwidth = stack[i].width
		cheight = stack[i].height
	end
	return ox, oy, cx, cy, cwidth, cheight
end

local function clipRect(x, y, width, height, cx, cy, cwidth, cheight)
	if x < cx then
		width = width + x - cx
		x = cx
	end
	if y < cy then
		height = height + y - cy
		y = cy
	end
	if x + width > cx + cwidth then
		width = cwidth + cx - x
	end
	if y + height > cy + cheight then
		height = cheight + cy - y
	end
	return x, y, width, height
end



function surface.create(width, height, b, t, c)
	local surface = setmetatable({ }, {__index = surface.surf})
	surface.width = width
	surface.height = height
	surface.buffer = { }
	surface.overwrite = false
	surface.stack = { }
	surface.ox, surface.oy, surface.cx, surface.cy, surface.cwidth, surface.cheight = calcStack(surface.stack, width, height)
	-- force array indeces instead of hashed indices

	local buffer = surface.buffer
	for i = 1, width * height * 3, 3 do
		buffer[i] = b or false
		buffer[i + 1] = t or false
		buffer[i + 2] = c or false
	end
	buffer[width * height * 3 + 1] = false
	if not b then
		for i = 1, width * height * 3, 3 do
			buffer[i] = b
		end
	end
	if not t then
		for i = 2, width * height * 3, 3 do
			buffer[i] = t
		end
	end
	if not c then
		for i = 3, width * height * 3, 3 do
			buffer[i] = c
		end
	end

	return surface
end

function surface.getPlatformOutput(output)
	output = output or (term or gpu or (love and love.graphics) or io)

	if output.blit and output.setCursorPos then
		return "cc", output, output.getSize()
	elseif output.write and output.setCursorPos and output.setTextColor and output.setBackgroundColor then
		return "cc-old", output, output.getSize()
	elseif output.blitPixels then
		return "riko-4", output, 320, 200
	elseif output.points and output.setColor then
		return "love2d", output, output.getWidth(), output.getHeight()
	elseif output.drawPixel then
		return "redirection", output, 64, 64
	elseif output.setForeground and output.setBackground and output.set then
		return "oc", output, output.getResolution()
	elseif output.write then
		return "ansi", output, (os.getenv and (os.getenv("COLUMNS"))) or 80, (os.getenv and (os.getenv("LINES"))) or 43
	else
		error("unsupported platform/output object")
	end
end

function surf:output(output, x, y, sx, sy, swidth, sheight)
	local platform, output, owidth, oheight = surface.getPlatformOutput(output)

	x = x or 0
	y = y or 0
	sx = sx or 0
	sy = sy or 0
	swidth = swidth or self.width
	sheight = sheight or self.height
	sx, sy, swidth, sheight = clipRect(sx, sy, swidth, sheight, 0, 0, self.width, self.height)

	local buffer = self.buffer
	local bwidth = self.width
	local xoffset, yoffset, idx

	if platform == "cc" then
		-- CC
		local str, text, back = { }, { }, { }
		for j = 0, sheight - 1 do
			yoffset = (j + sy) * bwidth + sx
			for i = 0, swidth - 1 do
				xoffset = (yoffset + i) * 3
				idx = i + 1
				str[idx] = buffer[xoffset + 3] or " "
				text[idx] = _cc_color_to_hex[buffer[xoffset + 2] or 1]
				back[idx] = _cc_color_to_hex[buffer[xoffset + 1] or 32768]
			end
			output.setCursorPos(x + 1, y + j + 1)
			output.blit(table_concat(str), table_concat(text), table_concat(back))
		end

	elseif platform == "cc-old" then
		-- CC pre-1.76
		local str, b, t, pb, pt = { }
		for j = 0, sheight - 1 do
			output.setCursorPos(x + 1, y + j + 1)
			yoffset = (j + sy) * bwidth + sx
			for i = 0, swidth - 1 do
				xoffset = (yoffset + i) * 3
				pb = buffer[xoffset + 1] or 32768
				pt = buffer[xoffset + 2] or 1
				if pb ~= b then
					if #str ~= 0 then
						output.write(table_concat(str))
						str = { }
					end
					b = pb
					output.setBackgroundColor(b)
				end
				if pt ~= t then
					if #str ~= 0 then
						output.write(table_concat(str))
						str = { }
					end
					t = pt
					output.setTextColor(t)
				end
				str[#str + 1] = buffer[xoffset + 3] or " "
			end
			output.write(table_concat(str))
			str = { }
		end

	elseif platform == "riko-4" then
		-- Riko 4
		local pixels = { }
		for j = 0, sheight - 1 do
			yoffset = (j + sy) * bwidth + sx
			for i = 0, swidth - 1 do
				pixels[j * swidth + i + 1] = buffer[(yoffset + i) * 3 + 1] or 0
			end
		end
		output.blitPixels(x, y, swidth, sheight, pixels)

	elseif platform == "love2d" then
		-- Love2D
		local pos, r, g, b, pr, pg, pb = { }
		for j = 0, sheight - 1 do
			yoffset = (j + sy) * bwidth + sx
			for i = 0, swidth - 1 do
				xoffset = (yoffset + i) * 3
				pr = buffer[xoffset + 1]
				pg = buffer[xoffset + 2]
				pb = buffer[xoffset + 3]
				if pr ~= r or pg ~= g or pb ~= b then
					if #pos ~= 0 then
						output.setColor((r or 0) * 255, (g or 0) * 255, (b or 0) * 255, (r or g or b) and 255 or 0)
						output.points(pos)
					end
					r, g, b = pr, pg, pb
					pos = { }
				end
				pos[#pos + 1] = i + x + 1
				pos[#pos + 1] = j + y + 1
			end
		end
		output.setColor((r or 0) * 255, (g or 0) * 255, (b or 0) * 255, (r or g or b) and 255 or 0)
		output.points(pos)

	elseif platform == "redirection" then
		-- Redirection arcade (gpu)
		-- todo: add image:write support for extra performance
		local px = output.drawPixel
		for j = 0, sheight - 1 do
			for i = 0, swidth - 1 do
				px(x + i, y + j, buffer[((j + sy) * bwidth + (i + sx)) * 3 + 1] or 0)
			end
		end

	elseif platform == "oc" then
		-- OpenComputers
		local str, lx, b, t, pb, pt = { }
		for j = 0, sheight - 1 do
			lx = x
			yoffset = (j + sy) * bwidth + sx
			for i = 0, swidth - 1 do
				xoffset = (yoffset + i) * 3
				pb = buffer[xoffset + 1] or 0x000000
				pt = buffer[xoffset + 2] or 0xFFFFFF
				if pb ~= b then
					if #str ~= 0 then
						output.set(lx + 1, j + y + 1, table_concat(str))
						lx = i + x
						str = { }
					end
					b = pb
					output.setBackground(b)
				end
				if pt ~= t then
					if #str ~= 0 then
						output.set(lx + 1, j + y + 1, table_concat(str))
						lx = i + x
						str = { }
					end
					t = pt
					output.setForeground(t)
				end
				str[#str + 1] = buffer[xoffset + 3] or " "
			end
			output.set(lx + 1, j + y + 1, table_concat(str))
			str = { }
		end

	elseif platform == "ansi" then
		-- ANSI terminal
		local str, b, t, pb, pt = { }
		for j = 0, sheight - 1 do
			str[#str + 1] = "\x1b[".._numstr[y + j + 1]..";".._numstr[x + 1].."H"
			yoffset = (j + sy) * bwidth + sx
			for i = 0, swidth - 1 do
				xoffset = (yoffset + i) * 3
				pb = buffer[xoffset + 1] or 0
				pt = buffer[xoffset + 2] or 7
				if pb ~= b then
					b = pb
					if b < 8 then
						str[#str + 1] = "\x1b[".._numstr[40 + b].."m"
					elseif b < 16 then
						str[#str + 1] = "\x1b[".._numstr[92 + b].."m"
					elseif b < 232 then
						str[#str + 1] = "\x1b[48;2;".._numstr[math_floor((b - 16) / 36 * 85 / 2)]..";".._numstr[math_floor((b - 16) / 6 % 6 * 85 / 2)]..";".._numstr[math_floor((b - 16) % 6 * 85 / 2)].."m"
					else
						local gr = _numstr[b * 10 - 2312]
						str[#str + 1] = "\x1b[48;2;"..gr..";"..gr..";"..gr.."m"
					end
				end
				if pt ~= t then
					t = pt
					if t < 8 then
						str[#str + 1] = "\x1b[".._numstr[30 + t].."m"
					elseif t < 16 then
						str[#str + 1] = "\x1b[".._numstr[82 + t].."m"
					elseif t < 232 then
						str[#str + 1] = "\x1b[38;2;".._numstr[math_floor((t - 16) / 36 * 85 / 2)]..";".._numstr[math_floor((t - 16) / 6 % 6 * 85 / 2)]..";".._numstr[math_floor((t - 16) % 6 * 85 / 2)].."m"
					else
						local gr = _numstr[t * 10 - 2312]
						str[#str + 1] = "\x1b[38;2;"..gr..";"..gr..";"..gr.."m"
					end
				end
				str[#str + 1] = buffer[xoffset + 3] or " "
			end
		end
		output.write(table_concat(str))
	end
end

function surf:push(x, y, width, height, nooffset)
	x, y = x + self.ox, y + self.oy

	local ox, oy = nooffset and self.ox or x, nooffset and self.oy or y
	x, y, width, height = clipRect(x, y, width, height, self.cx, self.cy, self.cwidth, self.cheight)
	self.stack[#self.stack + 1] = {ox = ox - self.ox, oy = oy - self.oy, x = x - self.cx, y = y - self.cy, width = width, height = height}

	self.ox, self.oy, self.cx, self.cy, self.cwidth, self.cheight = calcStack(self.stack, self.width, self.height)
end

function surf:pop()
	if #self.stack == 0 then
		error("no stencil to pop")
	end
	self.stack[#self.stack] = nil
	self.ox, self.oy, self.cx, self.cy, self.cwidth, self.cheight = calcStack(self.stack, self.width, self.height)
end

function surf:copy()
	local surface = setmetatable({ }, {__index = surface.surf})

	for k, v in pairs(self) do
		surface[k] = v
	end

	surface.buffer = { }
	for i = 1, self.width * self.height * 3 + 1 do
		surface.buffer[i] = false
	end
	for i = 1, self.width * self.height * 3 do
		surface.buffer[i] = self.buffer[i]
	end

	surface.stack = { }
	for i = 1, #self.stack do
		surface.stack[i] = self.stack[i]
	end

	return surface
end

function surf:clear(b, t, c)
	local xoffset, yoffset

	for j = 0, self.cheight - 1 do
		yoffset = (j + self.cy) * self.width + self.cx
		for i = 0, self.cwidth - 1 do
			xoffset = (yoffset + i) * 3
			self.buffer[xoffset + 1] = b
			self.buffer[xoffset + 2] = t
			self.buffer[xoffset + 3] = c
		end
	end
end

function surf:drawPixel(x, y, b, t, c)
	x, y = x + self.ox, y + self.oy

	local idx
	if x >= self.cx and x < self.cx + self.cwidth and y >= self.cy and y < self.cy + self.cheight then
		idx = (y * self.width + x) * 3
		if b or self.overwrite then
			self.buffer[idx + 1] = b
		end
		if t or self.overwrite then
			self.buffer[idx + 2] = t
		end
		if c or self.overwrite then
			self.buffer[idx + 3] = c
		end
	end
end

function surf:drawString(str, x, y, b, t)
	x, y = x + self.ox, y + self.oy

	local sx = x
	local insidey = y >= self.cy and y < self.cy + self.cheight
	local idx
	local lowerxlim = self.cx
	local upperxlim = self.cx + self.cwidth
	local writeb = b or self.overwrite
	local writet = t or self.overwrite

	for i = 1, #str do
		local c = str:sub(i, i)
		if c == "\n" then
			x = sx
			y = y + 1
			if insidey then
				if y >= self.cy + self.cheight then
					return
				end
			else
				insidey = y >= self.cy
			end
		else
			idx = (y * self.width + x) * 3
			if x >= lowerxlim and x < upperxlim and insidey then
				if writeb then
					self.buffer[idx + 1] = b
				end
				if writet then
					self.buffer[idx + 2] = t
				end
				self.buffer[idx + 3] = c
			end
			x = x + 1
		end
	end
end

-- You can remove any of these components
function surface.load(strpath, isstr)
	local data = strpath
	if not isstr then
		local handle = io.open(strpath, "rb")
		if not handle then return end
		local chars = { }
		local byte = handle:read(1)
		if type(byte) == "number" then -- cc doesn't conform to standards
			while byte do
				chars[#chars + 1] = _chars[byte]
				byte = handle:read(1)
			end
		else
			while byte do
				chars[#chars + 1] = byte
				byte = handle:read(1)
			end
		end
		handle:close()
		data = table_concat(chars)
	end
	
	if data:sub(1, 3) == "RIF" then
		-- Riko 4 image format
		local width, height = data:byte(4) * 256 + data:byte(5), data:byte(6) * 256 + data:byte(7)
		local surf = surface.create(width, height)
		local buffer = surf.buffer
		local upper, byte = 8, false
		local byte = data:byte(index)

		for j = 0, height - 1 do
			for i = 0, height - 1 do
				if not upper then
					buffer[(j * width + i) * 3 + 1] = math_floor(byte / 16)
				else
					buffer[(j * width + i) * 3 + 1] = byte % 16
					index = index + 1
					data = data:byte(index)
				end
				upper = not upper
			end
		end
		return surf

	elseif data:sub(1, 2) == "BM" then
		-- BMP format
		local width = data:byte(0x13) + data:byte(0x14) * 256
		local height = data:byte(0x17) + data:byte(0x18) * 256
		if data:byte(0xF) ~= 0x28 or data:byte(0x1B) ~= 1 or data:byte(0x1D) ~= 0x18 then
			error("unsupported bmp format, only uncompressed 24-bit rgb is supported.")
		end
		local offset, linesize = 0x36, math.ceil((width * 3) / 4) * 4
		
		local surf = surface.create(width, height)
		local buffer = surf.buffer
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				buffer[(j * width + i) * 3 + 1] = data:byte((height - j - 1) * linesize + i * 3 + offset + 3) / 255
				buffer[(j * width + i) * 3 + 2] = data:byte((height - j - 1) * linesize + i * 3 + offset + 2) / 255
				buffer[(j * width + i) * 3 + 3] = data:byte((height - j - 1) * linesize + i * 3 + offset + 1) / 255
			end
		end
		return surf

	elseif data:find("\30") then
		-- NFT format
		local width, height, lwidth = 0, 1, 0
		for i = 1, #data do
			if data:byte(i) == 10 then -- newline
				height = height + 1
				if lwidth > width then
					width = lwidth
				end
				lwidth = 0
			elseif data:byte(i) == 30 or data:byte(i) == 31 then -- color control
				lwidth = lwidth - 1
			elseif data:byte(i) ~= 13 then -- not carriage return
				lwidth = lwidth + 1
			end
		end
		if data:byte(#data) == 10 then
			height = height - 1
		end

		local surf = surface.create(width, height)
		local buffer = surf.buffer
		local index, x, y, b, t = 1, 0, 0

		while index <= #data do
			if data:byte(index) == 10 then
				x, y = 0, y + 1
			elseif data:byte(index) == 30 then
				index = index + 1
				b = _cc_hex_to_color[data:sub(index, index)]
			elseif data:byte(index) == 31 then
				index = index + 1
				t = _cc_hex_to_color[data:sub(index, index)]
			elseif data:byte(index) ~= 13 then
				buffer[(y * width + x) * 3 + 1] = b
				buffer[(y * width + x) * 3 + 2] = t
				if b or t then
					buffer[(y * width + x) * 3 + 3] = data:sub(index, index)
				elseif data:sub(index, index) ~= " " then
					buffer[(y * width + x) * 3 + 3] = data:sub(index, index)
				end
				x = x + 1
			end
			index = index + 1
		end

		return surf
	else
		-- NFP format
		local width, height, lwidth = 0, 1, 0
		for i = 1, #data do
			if data:byte(i) == 10 then -- newline
				height = height + 1
				if lwidth > width then
					width = lwidth
				end
				lwidth = 0
			elseif data:byte(i) ~= 13 then -- not carriage return
				lwidth = lwidth + 1
			end
		end
		if data:byte(#data) == 10 then
			height = height - 1
		end

		local surf = surface.create(width, height)
		local buffer = surf.buffer
		local x, y = 0, 0
		for i = 1, #data do
			if data:byte(i) == 10 then
				x, y = 0, y + 1
			elseif data:byte(i) ~= 13 then
				buffer[(y * width + x) * 3 + 1] = _cc_hex_to_color[data:sub(i, i)]
				x = x + 1
			end
		end

		return surf
	end
end

function surf:save(file, format)
	format = format or "nfp"
	local data = { }
	if format == "nfp" then
		for j = 0, self.height - 1 do
			for i = 0, self.width - 1 do
				data[#data + 1] = _cc_color_to_hex[self.buffer[(j * self.width + i) * 3 + 1]] or " "
			end
			data[#data + 1] = "\n"
		end

	elseif format == "nft" then
		for j = 0, self.height - 1 do
			local b, t, pb, pt
			for i = 0, self.width - 1 do
				pb = self.buffer[(j * self.width + i) * 3 + 1]
				pt = self.buffer[(j * self.width + i) * 3 + 2]
				if pb ~= b then
					data[#data + 1] = "\30"..(_cc_color_to_hex[pb] or " ")
					b = pb
				end
				if pt ~= t then
					data[#data + 1] = "\31"..(_cc_color_to_hex[pt] or " ")
					t = pt
				end
				data[#data + 1] = self.buffer[(j * self.width + i) * 3 + 3] or " "
			end
			data[#data + 1] = "\n"
		end

	elseif format == "rif" then
		data[1] = "RIF"
		data[2] = string.char(math_floor(self.width / 256), self.width % 256)
		data[3] = string.char(math_floor(self.height / 256), self.height % 256)
		local byte, upper, c = 0, false
		for j = 0, self.width - 1 do
			for i = 0, self.height - 1 do
				c = self.buffer[(j * self.width + i) * 3 + 1] or 0
				if not upper then
					byte = c * 16
				else
					byte = byte + c
					data[#data + 1] = string.char(byte)
				end
				upper = not upper
			end
		end
		if upper then
			data[#data + 1] = string.char(byte)
		end

	elseif format == "bmp" then
		data[1] = "BM"
		data[2] = string.char(0, 0, 0, 0) -- file size, change later
		data[3] = string.char(0, 0, 0, 0, 0x36, 0, 0, 0, 0x28, 0, 0, 0) 
		data[4] = string.char(self.width % 256, math_floor(self.width / 256), 0, 0)
		data[5] = string.char(self.height % 256, math_floor(self.height / 256), 0, 0)
		data[6] = string.char(1, 0, 0x18, 0, 0, 0, 0, 0)
		data[7] = string.char(0, 0, 0, 0) -- pixel data size, change later
		data[8] = string.char(0x13, 0x0B, 0, 0, 0x13, 0x0B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

		local padchars = math.ceil((self.width * 3) / 4) * 4 - self.width * 3
		for j = self.height - 1, 0, -1 do
			for i = 0, self.width - 1 do
				data[#data + 1] = string.char((self.buffer[(j * self.width + i) * 3 + 1] or 0) * 255)
				data[#data + 1] = string.char((self.buffer[(j * self.width + i) * 3 + 2] or 0) * 255)
				data[#data + 1] = string.char((self.buffer[(j * self.width + i) * 3 + 3] or 0) * 255)
			end
			data[#data + 1] = ("\0"):rep(padchars)
		end
		local size = #table_concat(data)
		data[2] = string.char(size % 256, math_floor(size / 256) % 256, math_floor(size / 65536), 0)
		size = size - 54
		data[7] = string.char(size % 256, math_floor(size / 256) % 256, math_floor(size / 65536), 0)
		 
	else
		error("format not supported")
	end

	data = table_concat(data)
	if file then
		local handle = io.open(file, "wb")
		for i = 1, #data do
			handle:write(data:byte(i))
		end
		handle:close()
	end
	return data
end
function surf:drawLine(x1, y1, x2, y2, b, t, c)
	if x1 == x2 then
		x1, y1, x2, y2 = x1 + self.ox, y1 + self.oy, x2 + self.ox, y2 + self.oy
		if x1 < self.cx or x1 >= self.cx + self.cwidth then return end
		if y2 < y1 then
			local temp = y1
			y1 = y2
			y2 = temp
		end
		if y1 < self.cy then y1 = self.cy end
		if y2 >= self.cy + self.cheight then y2 = self.cy + self.cheight - 1 end
		if b or self.overwrite then
			for j = y1, y2 do
				self.buffer[(j * self.width + x1) * 3 + 1] = b
			end
		end
		if t or self.overwrite then
			for j = y1, y2 do
				self.buffer[(j * self.width + x1) * 3 + 2] = t
			end
		end
		if c or self.overwrite then
			for j = y1, y2 do
				self.buffer[(j * self.width + x1) * 3 + 3] = c
			end
		end
	elseif y1 == y2 then
		x1, y1, x2, y2 = x1 + self.ox, y1 + self.oy, x2 + self.ox, y2 + self.oy
		if y1 < self.cy or y1 >= self.cy + self.cheight then return end
		if x2 < x1 then
			local temp = x1
			x1 = x2
			x2 = temp
		end
		if x1 < self.cx then x1 = self.cx end
		if x2 >= self.cx + self.cwidth then x2 = self.cx + self.cwidth - 1 end
		if b or self.overwrite then
			for i = x1, x2 do
				self.buffer[(y1 * self.width + i) * 3 + 1] = b
			end
		end
		if t or self.overwrite then
			for i = x1, x2 do
				self.buffer[(y1 * self.width + i) * 3 + 2] = t
			end
		end
		if c or self.overwrite then
			for i = x1, x2 do
				self.buffer[(y1 * self.width + i) * 3 + 3] = c
			end
		end
	else
		local delta_x = x2 - x1
		local ix = delta_x > 0 and 1 or -1
		delta_x = 2 * math.abs(delta_x)
		local delta_y = y2 - y1
		local iy = delta_y > 0 and 1 or -1
		delta_y = 2 * math.abs(delta_y)
		self:drawPixel(x1, y1, b, t, c)
		if delta_x >= delta_y then
			local error = delta_y - delta_x / 2
			while x1 ~= x2 do
				if (error >= 0) and ((error ~= 0) or (ix > 0)) then
					error = error - delta_x
					y1 = y1 + iy
				end
				error = error + delta_y
				x1 = x1 + ix
				self:drawPixel(x1, y1, b, t, c)
			end
		else
			local error = delta_x - delta_y / 2
			while y1 ~= y2 do
				if (error >= 0) and ((error ~= 0) or (iy > 0)) then
					error = error - delta_y
					x1 = x1 + ix
				end
				error = error + delta_x
				y1 = y1 + iy
				self:drawPixel(x1, y1, b, t, c)
			end
		end
	end
end

function surf:drawRect(x, y, width, height, b, t, c)
	self:drawLine(x, y, x + width - 1, y, b, t, c)
	self:drawLine(x, y, x, y + height - 1, b, t, c)
	self:drawLine(x + width - 1, y, x + width - 1, y + height - 1, b, t, c)
	self:drawLine(x, y + height - 1, x + width - 1, y + height - 1, b, t, c)
end

function surf:fillRect(x, y, width, height, b, t, c)
	x, y, width, height = clipRect(x + self.ox, y + self.oy, width, height, self.cx, self.cy, self.cwidth, self.cheight)

	if b or self.overwrite then
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				self.buffer[((j + y) * self.width + i + x) * 3 + 1] = b
			end
		end
	end
	if t or self.overwrite then
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				self.buffer[((j + y) * self.width + i + x) * 3 + 2] = t
			end
		end
	end
	if c or self.overwrite then
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				self.buffer[((j + y) * self.width + i + x) * 3 + 3] = c
			end
		end
	end
end

function surf:drawTriangle(x1, y1, x2, y2, x3, y3, b, t, c)
	self:drawLine(x1, y1, x2, y2, b, t, c)
	self:drawLine(x2, y2, x3, y3, b, t, c)
	self:drawLine(x3, y3, x1, y1, b, t, c)
end

function surf:fillTriangle(x1, y1, x2, y2, x3, y3, b, t, c)
	if y1 > y2 then
		local tempx, tempy = x1, y1
		x1, y1 = x2, y2
		x2, y2 = tempx, tempy
	end
	if y1 > y3 then
		local tempx, tempy = x1, y1
		x1, y1 = x3, y3
		x3, y3 = tempx, tempy
	end
	if y2 > y3 then
		local tempx, tempy = x2, y2
		x2, y2 = x3, y3
		x3, y3 = tempx, tempy
	end
	if y1 == y2 and x1 > x2 then
		local temp = x1
		x1 = x2
		x2 = temp
	end
	if y2 == y3 and x2 > x3 then
		local temp = x2
		x2 = x3
		x3 = temp
	end

	local x4, y4
	if x1 <= x2 then
		x4 = x1 + (y2 - y1) / (y3 - y1) * (x3 - x1)
		y4 = y2
		local tempx, tempy = x2, y2
		x2, y2 = x4, y4
		x4, y4 = tempx, tempy
	else
		x4 = x1 + (y2 - y1) / (y3 - y1) * (x3 - x1)
		y4 = y2
	end

	local finvslope1 = (x2 - x1) / (y2 - y1)
	local finvslope2 = (x4 - x1) / (y4 - y1)
	local linvslope1 = (x3 - x2) / (y3 - y2)
	local linvslope2 = (x3 - x4) / (y3 - y4)

	local xstart, xend, dxstart, dxend
	for y = math.ceil(y1 + 0.5) - 0.5, math.floor(y3 - 0.5) + 0.5, 1 do
		if y <= y2 then -- first half
			xstart = x1 + finvslope1 * (y - y1)
			xend = x1 + finvslope2 * (y - y1)
		else -- second half
			xstart = x3 - linvslope1 * (y3 - y)
			xend = x3 - linvslope2 * (y3 - y)
		end

		dxstart, dxend = math.ceil(xstart - 0.5), math.floor(xend - 0.5)
		if dxstart <= dxend then
			self:drawLine(dxstart, y - 0.5, dxend, y - 0.5, b, t, c)
		end
	end
end

function surf:drawEllipse(x, y, width, height, b, t, c)
	for i = 0, _eprc - 1 do
		self:drawLine(math_floor(x + _ecos[i + 1] * (width - 1) + 0.5), math_floor(y + _esin[i + 1] * (height - 1) + 0.5), math_floor(x + _ecos[(i + 1) % _eprc + 1] * (width - 1) + 0.5), math_floor(y + _esin[(i + 1) % _eprc + 1] * (height - 1) + 0.5), b, t, c)
	end
end

function surf:fillEllipse(x, y, width, height, b, t, c)
	x, y = x + self.ox, y + self.oy

	local sx, sy
	for j = 0, height - 1 do
		for i = 0, width - 1 do
			sx, sy = i + x, j + y
			if ((i + 0.5) / width * 2 - 1) ^ 2 + ((j + 0.5) / height * 2 - 1) ^ 2 <= 1 and sx >= self.cx and sx < self.cx + self.cwidth and sy >= self.cy and sy < self.cy + self.cheight then
				if b or self.overwrite then 
					self.buffer[(sy * self.width + sx) * 3 + 1] = b
				end
				if t or self.overwrite then
					self.buffer[(sy * self.width + sx) * 3 + 2] = t
				end
				if c or self.overwrite then 
					self.buffer[(sy * self.width + sx) * 3 + 3] = c
				end
			end
		end
	end
end

function surf:drawArc(x, y, width, height, fromangle, toangle, b, t, c)
	if fromangle > toangle then
		local temp = fromangle
		fromangle = toangle
		temp = toangle
	end
	fromangle = math_floor(fromangle / math.pi / 2 * _eprc + 0.5)
	toangle = math_floor(toangle / math.pi / 2 * _eprc + 0.5) - 1
	
	for j = fromangle, toangle do
		local i = j % _eprc
		self:drawLine(math_floor(x + _ecos[i + 1] * (width - 1) + 0.5), math_floor(y + _esin[i + 1] * (height - 1) + 0.5), math_floor(x + _ecos[(i + 1) % _eprc + 1] * (width - 1) + 0.5), math_floor(y + _esin[(i + 1) % _eprc + 1] * (height - 1) + 0.5), b, t, c)
	end
end

function surf:fillArc(x, y, width, height, fromangle, toangle, b, t, c)
	x, y = x + self.ox, y + self.oy

	if fromangle > toangle then
		local temp = fromangle
		fromangle = toangle
		temp = toangle
	end
	local diff = toangle - fromangle
	fromangle = fromangle % (math.pi * 2)

	local fx, fy, sx, sy, dir
	for j = 0, height - 1 do
		for i = 0, width - 1 do
			fx, fy = (i + 0.5) / width * 2 - 1, (j + 0.5) / height * 2 - 1
			sx, sy = i + x, j + y
			dir = math_atan2(-fy, fx) % (math.pi * 2)
			if fx ^ 2 + fy ^ 2 <= 1 and ((dir >= fromangle and dir - fromangle <= diff) or (dir <= (fromangle + diff) % (math.pi * 2))) and sx >= self.cx and sx < self.cx + self.cwidth and sy >= self.cy and sy < self.cy + self.cheight then
				if b or self.overwrite then 
					self.buffer[(sy * self.width + sx) * 3 + 1] = b
				end
				if t or self.overwrite then
					self.buffer[(sy * self.width + sx) * 3 + 2] = t
				end
				if c or self.overwrite then 
					self.buffer[(sy * self.width + sx) * 3 + 3] = c
				end
			end
		end
	end
end
function surf:drawSurface(surf2, x, y, width, height, sx, sy, swidth, sheight)
	x, y, width, height, sx, sy, swidth, sheight = x + self.ox, y + self.oy, width or surf2.width, height or surf2.height, sx or 0, sy or 0, swidth or surf2.width, sheight or surf2.height

	if width == swidth and height == sheight then
		local nx, ny
		nx, ny, width, height = clipRect(x, y, width, height, self.cx, self.cy, self.cwidth, self.cheight)
		swidth, sheight = width, height
		if nx > x then
			sx = sx + nx - x
			x = nx
		end
		if ny > y then
			sy = sy + ny - y
			y = ny
		end
		nx, ny, swidth, sheight = clipRect(sx, sy, swidth, sheight, 0, 0, surf2.width, surf2.height)
		width, height = swidth, sheight
		if nx > sx then
			x = x + nx - sx
			sx = nx
		end
		if ny > sy then
			y = y + ny - sy
			sy = ny
		end

		local b, t, c
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				b = surf2.buffer[((j + sy) * surf2.width + i + sx) * 3 + 1]
				t = surf2.buffer[((j + sy) * surf2.width + i + sx) * 3 + 2]
				c = surf2.buffer[((j + sy) * surf2.width + i + sx) * 3 + 3]
				if b or self.overwrite then
					self.buffer[((j + y) * self.width + i + x) * 3 + 1] = b
				end
				if t or self.overwrite then
					self.buffer[((j + y) * self.width + i + x) * 3 + 2] = t
				end
				if c or self.overwrite then
					self.buffer[((j + y) * self.width + i + x) * 3 + 3] = c
				end
			end
		end
	else
		local hmirror, vmirror = false, false
		if width < 0 then
			hmirror = true
			x = x + width
		end
		if height < 0 then
			vmirror = true
			y = y + height
		end
		if swidth < 0 then
			hmirror = not hmirror
			sx = sx + swidth
		end
		if sheight < 0 then
			vmirror = not vmirror
			sy = sy + sheight
		end
		width, height, swidth, sheight = math.abs(width), math.abs(height), math.abs(swidth), math.abs(sheight)
		
		local xscale, yscale, px, py, ssx, ssy, b, t, c = swidth / width, sheight / height
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				px, py = math_floor((i + 0.5) * xscale), math_floor((j + 0.5) * yscale) 
				if hmirror then
					ssx = x + width - i - 1
				else
					ssx = i + x
				end
				if vmirror then
					ssy = y + height - j - 1
				else
					ssy = j + y
				end

				if ssx >= self.cx and ssx < self.cx + self.cwidth and ssy >= self.cy and ssy < self.cy + self.cheight and px >= 0 and px < surf2.width and py >= 0 and py < surf2.height then
					b = surf2.buffer[(py * surf2.width + px) * 3 + 1]
					t = surf2.buffer[(py * surf2.width + px) * 3 + 2]
					c = surf2.buffer[(py * surf2.width + px) * 3 + 3]
					if b or self.overwrite then
						self.buffer[(ssy * self.width + ssx) * 3 + 1] = b
					end
					if t or self.overwrite then
						self.buffer[(ssy * self.width + ssx) * 3 + 2] = t
					end
					if c or self.overwrite then
						self.buffer[(ssy * self.width + ssx) * 3 + 3] = c
					end
				end
			end
		end
	end
end

function surf:drawSurfaceRotated(surf2, x, y, ox, oy, angle)
	local sin, cos, sx, sy, px, py = math.sin(angle), math.cos(angle)
	for j = math.floor(-surf2.height * 0.75), math.ceil(surf2.height * 0.75) do
		for i = math.floor(-surf2.width * 0.75), math.ceil(surf2.width * 0.75) do
			sx, sy, px, py = x + i, y + j, math_floor(cos * (i + 0.5) - sin * (j + 0.5) + ox), math_floor(sin * (i + 0.5) + cos * (j + 0.5) + oy)
			if sx >= self.cx and sx < self.cx + self.cwidth and sy >= self.cy and sy < self.cy + self.cheight and px >= 0 and px < surf2.width and py >= 0 and py < surf2.height then
				b = surf2.buffer[(py * surf2.width + px) * 3 + 1]
				t = surf2.buffer[(py * surf2.width + px) * 3 + 2]
				c = surf2.buffer[(py * surf2.width + px) * 3 + 3]
				if b or self.overwrite then
					self.buffer[(sy * self.width + sx) * 3 + 1] = b
				end
				if t or self.overwrite then
					self.buffer[(sy * self.width + sx) * 3 + 2] = t
				end
				if c or self.overwrite then
					self.buffer[(sy * self.width + sx) * 3 + 3] = c
				end
			end
		end
	end
end

function surf:drawSurfacesInterlaced(surfs, x, y, step)
	x, y, step = x + self.ox, y + self.oy, step or 0
	local width, height = surfs[1].width, surfs[1].height
	for i = 2, #surfs do
		if surfs[i].width ~= width or surfs[i].height ~= height then
			error("surfaces should be the same size")
		end
	end
	
	local sx, sy, swidth, sheight, index, b, t, c = clipRect(x, y, width, height, self.cx, self.cy, self.cwidth, self.cheight)
	for j = sy, sy + sheight - 1 do
		for i = sx, sx + swidth - 1 do
			index = (i + j + step) % #surfs + 1
			b = surfs[index].buffer[((j - sy) * surfs[index].width + i - sx) * 3 + 1]
			t = surfs[index].buffer[((j - sy) * surfs[index].width + i - sx) * 3 + 2]
			c = surfs[index].buffer[((j - sy) * surfs[index].width + i - sx) * 3 + 3]
			if b or self.overwrite then
				self.buffer[(j * self.width + i) * 3 + 1] = b
			end
			if t or self.overwrite then
				self.buffer[(j * self.width + i) * 3 + 2] = t
			end
			if c or self.overwrite then
				self.buffer[(j * self.width + i) * 3 + 3] = c
			end
		end
	end
end

function surf:drawSurfaceSmall(surf2, x, y)
	x, y = x + self.ox, y + self.oy
	if surf2.width % 2 ~= 0 or surf2.height % 3 ~= 0 then
		error("surface width must be a multiple of 2 and surface height a multiple of 3")
	end

	local sub, char, c1, c2, c3, c4, c5, c6 = 32768
	for j = 0, surf2.height / 3 - 1 do
		for i = 0, surf2.width / 2 - 1 do
			if i + x >= self.cx and i + x < self.cx + self.cwidth and j + y >= self.cy and j + y < self.cy + self.cheight then
				char, c1, c2, c3, c4, c5, c6 = 0,
				surf2.buffer[((j * 3) * surf2.width + i * 2) * 3 + 1],
				surf2.buffer[((j * 3) * surf2.width + i * 2 + 1) * 3 + 1],
				surf2.buffer[((j * 3 + 1) * surf2.width + i * 2) * 3 + 1],
				surf2.buffer[((j * 3 + 1) * surf2.width + i * 2 + 1) * 3 + 1],
				surf2.buffer[((j * 3 + 2) * surf2.width + i * 2) * 3 + 1],
				surf2.buffer[((j * 3 + 2) * surf2.width + i * 2 + 1) * 3 + 1]
				if c1 ~= c6 then
	                sub = c1
	                char = 1
	            end
	            if c2 ~= c6 then
	                sub = c2
	                char = char + 2
	            end
	            if c3 ~= c6 then
	                sub = c3
	                char = char + 4
	            end
	            if c4 ~= c6 then
	                sub = c4
	                char = char + 8
	            end
	            if c5 ~= c6 then
	                sub = c5
	                char = char + 16
	            end
	            self.buffer[((j + y) * self.width + i + x) * 3 + 1] = c6
	            self.buffer[((j + y) * self.width + i + x) * 3 + 2] = sub
	            self.buffer[((j + y) * self.width + i + x) * 3 + 3] = _chars[128 + char]
			end
		end
	end
end
function surf:flip(horizontal, vertical)
	local ox, oy, nx, ny, tb, tt, tc
	if horizontal then
		for i = 0, math.ceil(self.cwidth / 2) - 1 do
			for j = 0, self.cheight - 1 do
				ox, oy, nx, ny = i + self.cx, j + self.cy, self.cx + self.cwidth - i - 1, j + self.cy
				tb = self.buffer[(oy * self.width + ox) * 3 + 1]
				tt = self.buffer[(oy * self.width + ox) * 3 + 2]
				tc = self.buffer[(oy * self.width + ox) * 3 + 3]
				self.buffer[(oy * self.width + ox) * 3 + 1] = self.buffer[(ny * self.width + nx) * 3 + 1]
				self.buffer[(oy * self.width + ox) * 3 + 2] = self.buffer[(ny * self.width + nx) * 3 + 2]
				self.buffer[(oy * self.width + ox) * 3 + 3] = self.buffer[(ny * self.width + nx) * 3 + 3]
				self.buffer[(ny * self.width + nx) * 3 + 1] = tb
				self.buffer[(ny * self.width + nx) * 3 + 2] = tt
				self.buffer[(ny * self.width + nx) * 3 + 3] = tc
			end
		end
	end
	if vertical then
		for j = 0, math.ceil(self.cheight / 2) - 1 do
			for i = 0, self.cwidth - 1 do
				ox, oy, nx, ny = i + self.cx, j + self.cy, i + self.cx, self.cy + self.cheight - j - 1
				tb = self.buffer[(oy * self.width + ox) * 3 + 1]
				tt = self.buffer[(oy * self.width + ox) * 3 + 2]
				tc = self.buffer[(oy * self.width + ox) * 3 + 3]
				self.buffer[(oy * self.width + ox) * 3 + 1] = self.buffer[(ny * self.width + nx) * 3 + 1]
				self.buffer[(oy * self.width + ox) * 3 + 2] = self.buffer[(ny * self.width + nx) * 3 + 2]
				self.buffer[(oy * self.width + ox) * 3 + 3] = self.buffer[(ny * self.width + nx) * 3 + 3]
				self.buffer[(ny * self.width + nx) * 3 + 1] = tb
				self.buffer[(ny * self.width + nx) * 3 + 2] = tt
				self.buffer[(ny * self.width + nx) * 3 + 3] = tc
			end
		end
	end
end

function surf:shift(x, y, b, t, c)
	local hdir, vdir = x < 0, y < 0
	local xstart, xend = self.cx, self.cx + self.cwidth - 1
	local ystart, yend = self.cy, self.cy + self.cheight - 1
	local nx, ny
	for j = vdir and ystart or yend, vdir and yend or ystart, vdir and 1 or -1 do
		for i = hdir and xstart or xend, hdir and xend or xstart, hdir and 1 or -1 do
			nx, ny = i - x, j - y
			if nx >= 0 and nx < self.width and ny >= 0 and ny < self.height then
				self.buffer[(j * self.width + i) * 3 + 1] = self.buffer[(ny * self.width + nx) * 3 + 1]
				self.buffer[(j * self.width + i) * 3 + 2] = self.buffer[(ny * self.width + nx) * 3 + 2]
				self.buffer[(j * self.width + i) * 3 + 3] = self.buffer[(ny * self.width + nx) * 3 + 3] 
			else
				self.buffer[(j * self.width + i) * 3 + 1] = b
				self.buffer[(j * self.width + i) * 3 + 2] = t
				self.buffer[(j * self.width + i) * 3 + 3] = c
			end
		end
	end
end

function surf:map(colors)
	local c
	for j = self.cy, self.cy + self.cheight - 1 do
		for i = self.cx, self.cx + self.cwidth - 1 do
			c = colors[self.buffer[(j * self.width + i) * 3 + 1]]
			if c or self.overwrite then
				self.buffer[(j * self.width + i) * 3 + 1] = c
			end
		end
	end
end
surface.palette = { }
surface.palette.cc = {[1]="F0F0F0",[2]="F2B233",[4]="E57FD8",[8]="99B2F2",[16]="DEDE6C",[32]="7FCC19",[64]="F2B2CC",[128]="4C4C4C",[256]="999999",[512]="4C99B2",[1024]="B266E5",[2048]="3366CC",[4096]="7F664C",[8192]="57A64E",[16384]="CC4C4C",[32768]="191919"}
surface.palette.riko4 = {"181818","1D2B52","7E2553","008651","AB5136","5F564F","7D7F82","FF004C","FFA300","FFF023","00E755","29ADFF","82769C","FF77A9","FECCA9","ECECEC"}
surface.palette.redirection = {[0]="040404",[1]="FFFFFF"}

local function setPalette(palette)
	if palette == _palette then return end
	_palette = palette
	_rgbpal, _palr, _palg, _palb = { }, { }, { }, { }

	local indices = { }
	for k, v in pairs(_palette) do
		if type(v) == "string" then
			_palr[k] = tonumber(v:sub(1, 2), 16) / 255
			_palg[k] = tonumber(v:sub(3, 4), 16) / 255
			_palb[k] = tonumber(v:sub(5, 6), 16) / 255
		elseif type(v) == "number" then
			_palr[k] = math.floor(v / 65536) / 255
			_palg[k] = (math.floor(v / 256) % 256) / 255
			_palb[k] = (v % 256) / 255
		end
		indices[#indices + 1] = k
	end

	local pr, pg, pb, dist, d, id
	for i = 0, _steps - 1 do
		for j = 0, _steps - 1 do
			for k = 0, _steps - 1 do
				pr = (i + 0.5) / _steps
				pg = (j + 0.5) / _steps
				pb = (k + 0.5) / _steps

				dist = 1e10
				for l = 1, #indices do
					d = (pr - _palr[indices[l]]) ^ 2 + (pg - _palg[indices[l]]) ^ 2 + (pb - _palb[indices[l]]) ^ 2
					if d < dist then
						dist = d
						id = l
					end
				end
				_rgbpal[i * _steps * _steps + j * _steps + k + 1] = indices[id]
			end
		end
	end
end



function surf:toRGB(palette)
	setPalette(palette)
	local c
	for j = 0, self.height - 1 do
		for i = 0, self.width - 1 do
			c = self.buffer[(j * self.width + i) * 3 + 1] 
			self.buffer[(j * self.width + i) * 3 + 1] = _palr[c]
			self.buffer[(j * self.width + i) * 3 + 2] = _palg[c]
			self.buffer[(j * self.width + i) * 3 + 3] = _palb[c]
		end
	end
end

function surf:toPalette(palette, dither)
	setPalette(palette)
	local scale, r, g, b, nr, ng, nb, c, dr, dg, db = _steps - 1
	for j = 0, self.height - 1 do
		for i = 0, self.width - 1 do
			r = self.buffer[(j * self.width + i) * 3 + 1]
			g = self.buffer[(j * self.width + i) * 3 + 2]
			b = self.buffer[(j * self.width + i) * 3 + 3]
			r = (r > 1) and 1 or r
			r = (r < 0) and 0 or r
			g = (g > 1) and 1 or g
			g = (g < 0) and 0 or g
			b = (b > 1) and 1 or b
			b = (b < 0) and 0 or b
			
			nr = (r == 1) and scale or math_floor(r * _steps)
			ng = (g == 1) and scale or math_floor(g * _steps)
			nb = (b == 1) and scale or math_floor(b * _steps)
			c = _rgbpal[nr * _steps * _steps + ng * _steps + nb + 1]
			if dither then
				dr = (r - _palr[c]) / 16
				dg = (g - _palg[c]) / 16
				db = (b - _palb[c]) / 16

				if i < self.width - 1 then
					self.buffer[(j * self.width + i + 1) * 3 + 1] = self.buffer[(j * self.width + i + 1) * 3 + 1] + dr * 7
					self.buffer[(j * self.width + i + 1) * 3 + 2] = self.buffer[(j * self.width + i + 1) * 3 + 2] + dg * 7
					self.buffer[(j * self.width + i + 1) * 3 + 3] = self.buffer[(j * self.width + i + 1) * 3 + 3] + db * 7
				end
				if j < self.height - 1 then
					if i > 0 then
						self.buffer[((j + 1) * self.width + i - 1) * 3 + 1] = self.buffer[((j + 1) * self.width + i - 1) * 3 + 1] + dr * 3
						self.buffer[((j + 1) * self.width + i - 1) * 3 + 2] = self.buffer[((j + 1) * self.width + i - 1) * 3 + 2] + dg * 3
						self.buffer[((j + 1) * self.width + i - 1) * 3 + 3] = self.buffer[((j + 1) * self.width + i - 1) * 3 + 3] + db * 3
					end
					self.buffer[((j + 1) * self.width + i) * 3 + 1] = self.buffer[((j + 1) * self.width + i) * 3 + 1] + dr * 5
					self.buffer[((j + 1) * self.width + i) * 3 + 2] = self.buffer[((j + 1) * self.width + i) * 3 + 2] + dg * 5
					self.buffer[((j + 1) * self.width + i) * 3 + 3] = self.buffer[((j + 1) * self.width + i) * 3 + 3] + db * 5
					if i < self.width - 1 then
						self.buffer[((j + 1) * self.width + i + 1) * 3 + 1] = self.buffer[((j + 1) * self.width + i + 1) * 3 + 1] + dr * 1
						self.buffer[((j + 1) * self.width + i + 1) * 3 + 2] = self.buffer[((j + 1) * self.width + i + 1) * 3 + 2] + dg * 1
						self.buffer[((j + 1) * self.width + i + 1) * 3 + 3] = self.buffer[((j + 1) * self.width + i + 1) * 3 + 3] + db * 1
					end
				end
			end
			self.buffer[(j * self.width + i) * 3 + 1] = c
			self.buffer[(j * self.width + i) * 3 + 2] = nil
			self.buffer[(j * self.width + i) * 3 + 3] = nil
		end
	end
end
function surface.loadFont(surf)
	local font = {width = surf.width, height = surf.height - 1}
	font.buffer =  { }
	font.indices = {0}
	font.widths = { }

	local startc, hitc, curc = surf.buffer[((surf.height - 1) * surf.width) * 3 + 1]
	for i = 0, surf.width - 1 do
		curc = surf.buffer[((surf.height - 1) * surf.width + i) * 3 + 1]
		if curc ~= startc then
			hitc = curc
			break
		end
	end

	for j = 0, surf.height - 2 do
		for i = 0, surf.width - 1 do
			font.buffer[j * font.width + i + 1] = surf.buffer[(j * surf.width + i) * 3 + 1] == hitc
		end
	end

	local curchar = 1
	for i = 0, surf.width - 1 do
		if surf.buffer[((surf.height - 1) * surf.width + i) * 3 + 1] == hitc then 
			font.widths[curchar] = i - font.indices[curchar]
			curchar = curchar + 1
			font.indices[curchar] = i + 1
		end
	end
	font.widths[curchar] = font.width - font.indices[curchar]

	return font
end

function surface.getTextSize(str, font)
	local cx, cy, maxx = 0, 0, 0
	local ox, char = cx

	for i = 1, #str do
		char = str:byte(i) - 31

		if char + 31 == 10 then -- newline
			cx = ox
			cy = cy + font.height + 1
		elseif font.indices[char] then
			cx = cx + font.widths[char] + 1
		else
			cx = cx + font.widths[1]
		end
		if cx > maxx then
			maxx = cx
		end
	end

	return maxx - 1, cy + font.height
end

function surf:drawText(str, font, x, y, b, t, c)
	local cx, cy = x + self.ox, y + self.oy
	local ox, char, idx = cx

	for i = 1, #str do
		char = str:byte(i) - 31

		if char + 31 == 10 then -- newline
			cx = ox
			cy = cy + font.height + 1
		elseif font.indices[char] then
			for i = 0, font.widths[char] - 1 do
				for j = 0, font.height - 1 do
					x, y = cx + i, cy + j
					if font.buffer[j * font.width + i + font.indices[char] + 1] then
						if x >= self.cx and x < self.cx + self.cwidth and y >= self.cy and y < self.cy + self.cheight then
							idx = (y * self.width + x) * 3
							if b or self.overwrite then
								self.buffer[idx + 1] = b
							end
							if t or self.overwrite then
								self.buffer[idx + 2] = t
							end
							if c or self.overwrite then
								self.buffer[idx + 3] = c
							end
						end
					end
				end
			end
			cx = cx + font.widths[char] + 1
		else
			cx = cx + font.widths[1]
		end
	end
end
local smap = { }
surface.smap = smap 

function surface.loadSpriteMap(surf, spwidth, spheight, sprites)
	if surf.width % spwidth ~= 0 or surf.height % spheight ~= 0 then
		error("sprite width/height does not match smap width/height")
	end

	local smap = setmetatable({ }, {__index = surface.smap})
	smap.surf = surf
	smap.spwidth = spwidth
	smap.spheight = spheight
	smap.sprites = sprites or ((surf.width / spwidth) * (surf.height / spheight))
	smap.perline = surf.width / spwidth

	return smap
end

function smap:pos(index, scale)
	if index < 0 or index >= self.sprites then
		error("sprite index out of bounds")
	end

	return (index % self.perline) * self.spwidth, math.floor(index / self.perline) * self.spheight
end

function smap:sprite(index, x, y, width, height)
	local sx, sy = self:pos(index)
	return self.surf, x, y, width or self.spwidth, height or self.spheight, sx, sy, self.spwidth, self.spheight
end
end return surface