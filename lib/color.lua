
local bit32 = require("bit32")
local computer = require("computer")
local color = {}

-----------------------------------------------------------------------------------------------------------------------

-- Yoba-fix for PIDORS
if computer.getArchitecture and computer.getArchitecture() == "Lua 5.3" then
	color.RGBToHEX = function(r, g, b)
		return (r // 1 << 16) | (g // 1 << 8) | b // 1
	end
else
	color.RGBToHEX = function(r, g, b)
		return bit32.lshift(r, 16) + bit32.lshift(g, 8) + b
	end
end

function color.HEXToRGB(HEXColor)
	return bit32.rshift(HEXColor, 16), bit32.band(bit32.rshift(HEXColor, 8), 0xFF), bit32.band(HEXColor, 0xFF)
end

function color.RGBToHSB(rr, gg, bb)
	local max = math.max(rr, math.max(gg, bb))
	local min = math.min(rr, math.min(gg, bb))
	local delta = max - min

	local h = 0
	if ( max == rr and gg >= bb) then h = 60 * (gg - bb) / delta end
	if ( max == rr and gg <= bb ) then h = 60 * (gg - bb) / delta + 360 end
	if ( max == gg ) then h = 60 * (bb - rr) / delta + 120 end
	if ( max == bb ) then h = 60 * (rr - gg) / delta + 240 end

	local s = 0
	if ( max ~= 0 ) then s = 1 - (min / max) end

	local b = max * 100 / 255

	if delta == 0 then h = 0 end

	return h, s * 100, b
end

function color.HSBToRGB(h, s, v)
	if h > 359 then h = 0 end
	local rr, gg, bb = 0, 0, 0
	local const = 255

	s = s / 100
	v = v / 100
	
	local i = math.floor(h / 60)
	local f = h / 60 - i
	
	local p = v * (1 - s)
	local q = v * (1 - s * f)
	local t = v * (1 - (1 - f) * s)

	if ( i == 0 ) then rr, gg, bb = v, t, p end
	if ( i == 1 ) then rr, gg, bb = q, v, p end
	if ( i == 2 ) then rr, gg, bb = p, v, t end
	if ( i == 3 ) then rr, gg, bb = p, q, v end
	if ( i == 4 ) then rr, gg, bb = t, p, v end
	if ( i == 5 ) then rr, gg, bb = v, p, q end

	return math.floor(rr * const), math.floor(gg * const), math.floor(bb * const)
end

function color.HEXToHSB(HEXColor)
	local rr, gg, bb = color.HEXToRGB(HEXColor)
	local h, s, b = color.RGBToHSB( rr, gg, bb )
	
	return h, s, b
end

function color.HSBToHEX(h, s, b)
	local rr, gg, bb = color.HSBToRGB(h, s, b)
	local color = color.RGBToHEX(rr, gg, bb)

	return color
end

function color.average(colors)
	local sColors, averageRed, averageGreen, averageBlue, r, g, b = #colors, 0, 0, 0

	for i = 1, sColors do
		r, g, b = color.HEXToRGB(colors[i])
		averageRed, averageGreen, averageBlue = averageRed + r, averageGreen + g, averageBlue + b
	end

	return color.RGBToHEX(math.floor(averageRed / sColors), math.floor(averageGreen / sColors), math.floor(averageBlue / sColors))
end

function color.blend(firstColor, secondColor, secondColorTransparency)
	local invertedTransparency, firstColorR, firstColorG, firstColorB = 1 - secondColorTransparency, color.HEXToRGB(firstColor)
	local secondColorR, secondColorG, secondColorB = color.HEXToRGB(secondColor)

	return color.RGBToHEX(
		secondColorR * invertedTransparency + firstColorR * secondColorTransparency,
		secondColorG * invertedTransparency + firstColorG * secondColorTransparency,
		secondColorB * invertedTransparency + firstColorB * secondColorTransparency
	)
end

-----------------------------------------------------------------------------------------------------------------------

function color.difference(r1, g1, b1, r2, g2, b2)
	return r2 - r1, g2 - g1, b2 - b1
end

function color.sum(r1, g1, b1, r2, g2, b2)
	return r2 + r1, g2 + g1, b2 + b1
end

function color.multiply(r, g, b, multiplyer)
	r, g, b = r * multiplyer, g * multiplyer, b * multiplyer
	if r > 255 then r = 255 end
	if g > 255 then g = 255 end
	if b > 255 then b = 255 end

	return r, g, b
end

-----------------------------------------------------------------------------------------------------------------------

local openComputersPalette = { 0x000000, 0x000040, 0x000080, 0x0000BF, 0x0000FF, 0x002400, 0x002440, 0x002480, 0x0024BF, 0x0024FF, 0x004900, 0x004940, 0x004980, 0x0049BF, 0x0049FF, 0x006D00, 0x006D40, 0x006D80, 0x006DBF, 0x006DFF, 0x009200, 0x009240, 0x009280, 0x0092BF, 0x0092FF, 0x00B600, 0x00B640, 0x00B680, 0x00B6BF, 0x00B6FF, 0x00DB00, 0x00DB40, 0x00DB80, 0x00DBBF, 0x00DBFF, 0x00FF00, 0x00FF40, 0x00FF80, 0x00FFBF, 0x00FFFF, 0x0F0F0F, 0x1E1E1E, 0x2D2D2D, 0x330000, 0x330040, 0x330080, 0x3300BF, 0x3300FF, 0x332400, 0x332440, 0x332480, 0x3324BF, 0x3324FF, 0x334900, 0x334940, 0x334980, 0x3349BF, 0x3349FF, 0x336D00, 0x336D40, 0x336D80, 0x336DBF, 0x336DFF, 0x339200, 0x339240, 0x339280, 0x3392BF, 0x3392FF, 0x33B600, 0x33B640, 0x33B680, 0x33B6BF, 0x33B6FF, 0x33DB00, 0x33DB40, 0x33DB80, 0x33DBBF, 0x33DBFF, 0x33FF00, 0x33FF40, 0x33FF80, 0x33FFBF, 0x33FFFF, 0x3C3C3C, 0x4B4B4B, 0x5A5A5A, 0x660000, 0x660040, 0x660080, 0x6600BF, 0x6600FF, 0x662400, 0x662440, 0x662480, 0x6624BF, 0x6624FF, 0x664900, 0x664940, 0x664980, 0x6649BF, 0x6649FF, 0x666D00, 0x666D40, 0x666D80, 0x666DBF, 0x666DFF, 0x669200, 0x669240, 0x669280, 0x6692BF, 0x6692FF, 0x66B600, 0x66B640, 0x66B680, 0x66B6BF, 0x66B6FF, 0x66DB00, 0x66DB40, 0x66DB80, 0x66DBBF, 0x66DBFF, 0x66FF00, 0x66FF40, 0x66FF80, 0x66FFBF, 0x66FFFF, 0x696969, 0x787878, 0x878787, 0x969696, 0x990000, 0x990040, 0x990080, 0x9900BF, 0x9900FF, 0x992400, 0x992440, 0x992480, 0x9924BF, 0x9924FF, 0x994900, 0x994940, 0x994980, 0x9949BF, 0x9949FF, 0x996D00, 0x996D40, 0x996D80, 0x996DBF, 0x996DFF, 0x999200, 0x999240, 0x999280, 0x9992BF, 0x9992FF, 0x99B600, 0x99B640, 0x99B680, 0x99B6BF, 0x99B6FF, 0x99DB00, 0x99DB40, 0x99DB80, 0x99DBBF, 0x99DBFF, 0x99FF00, 0x99FF40, 0x99FF80, 0x99FFBF, 0x99FFFF, 0xA5A5A5, 0xB4B4B4, 0xC3C3C3, 0xCC0000, 0xCC0040, 0xCC0080, 0xCC00BF, 0xCC00FF, 0xCC2400, 0xCC2440, 0xCC2480, 0xCC24BF, 0xCC24FF, 0xCC4900, 0xCC4940, 0xCC4980, 0xCC49BF, 0xCC49FF, 0xCC6D00, 0xCC6D40, 0xCC6D80, 0xCC6DBF, 0xCC6DFF, 0xCC9200, 0xCC9240, 0xCC9280, 0xCC92BF, 0xCC92FF, 0xCCB600, 0xCCB640, 0xCCB680, 0xCCB6BF, 0xCCB6FF, 0xCCDB00, 0xCCDB40, 0xCCDB80, 0xCCDBBF, 0xCCDBFF, 0xCCFF00, 0xCCFF40, 0xCCFF80, 0xCCFFBF, 0xCCFFFF, 0xD2D2D2, 0xE1E1E1, 0xF0F0F0, 0xFF0000, 0xFF0040, 0xFF0080, 0xFF00BF, 0xFF00FF, 0xFF2400, 0xFF2440, 0xFF2480, 0xFF24BF, 0xFF24FF, 0xFF4900, 0xFF4940, 0xFF4980, 0xFF49BF, 0xFF49FF, 0xFF6D00, 0xFF6D40, 0xFF6D80, 0xFF6DBF, 0xFF6DFF, 0xFF9200, 0xFF9240, 0xFF9280, 0xFF92BF, 0xFF92FF, 0xFFB600, 0xFFB640, 0xFFB680, 0xFFB6BF, 0xFFB6FF, 0xFFDB00, 0xFFDB40, 0xFFDB80, 0xFFDBBF, 0xFFDBFF, 0xFFFF00, 0xFFFF40, 0xFFFF80, 0xFFFFBF, 0xFFFFFF }

function color.to8Bit(color24Bit)
	local closestDelta, r, g, b, closestIndex, delta, openComputersPaletteR, openComputersPaletteG, openComputersPaletteB = math.huge, color.HEXToRGB(color24Bit)

	for index = 1, #openComputersPalette do
		if color24Bit == openComputersPalette[index] then
			return index - 1
		else
			openComputersPaletteR, openComputersPaletteG, openComputersPaletteB = color.HEXToRGB(openComputersPalette[index])
			delta = (openComputersPaletteR - r) ^ 2 + (openComputersPaletteG - g) ^ 2 + (openComputersPaletteB - b) ^ 2
			
			if delta < closestDelta then
				closestDelta, closestIndex = delta, index
			end
		end
	end

	return closestIndex - 1
end

function color.to24Bit(color8Bit)
	return openComputersPalette[color8Bit + 1]
end

function color.optimize(color24Bit)
	return color.to24Bit(color.to8Bit(color24Bit))
end

-----------------------------------------------------------------------------------------------------------------------

return color



