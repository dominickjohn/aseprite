-- Aseprite Script to open dialog with relevant color shades
-- Written by Dominick John, 2019
-- https://github.com/alpineboarder/aseprite/

function lerp(first, second, by)
  return first * (1 - by) + second * by
end

function lerpRGBInt (color1, color2, amount)
  local X1 = 1 - amount
  local X2 = color1 >> 24 & 255
  local X3 = color1 >> 16 & 255
  local X4 = color1 >> 8 & 255
  local X5 = color1 & 255
  local X6 = color2 >> 24 & 255
  local X7 = color2 >> 16 & 255
  local X8 = color2 >> 8 & 255
  local X9 = color2 & 255
  local X10 = X2 * X1 + X6 * amount
  local X11 = X3 * X1 + X7 * amount
  local X12 = X4 * X1 + X8 * amount
  local X13 = X5 * X1 + X9 * amount
  return X10 << 24 | X11 << 16 | X12 << 8 | X13
end

function colorToInt(color)
  return (color.red << 16) + (color.green << 8) + (color.blue)
end

function colorShift(color, hueShift, satShift, lightShift, shadeShift)
  local newColor = Color(color) -- Make a copy of the color so we don't modify the parameter

  -- SHIFT HUE
  newColor.hue = newColor.hue + hueShift * 359

  -- SHIFT SATURATION
  if (satShift > 0)
  then
    newColor.saturation = lerp(newColor.saturation, 1, satShift)
  elseif (satShift < 0)
  then
    newColor.saturation = lerp(newColor.saturation, 0, -satShift)
  end

  -- SHIFT LIGHTNESS
  if (lightShift > 0)
  then
    newColor.lightness = lerp(newColor.lightness, 1, lightShift)
  elseif (lightShift < 0)
  then
    newColor.lightness = lerp(newColor.lightness, 0, -lightShift)
  end

  -- SHIFT SHADING
  local newShade = Color{red = newColor.red, green = newColor.green, blue = newColor.blue}
  local shadeInt = 0
  if (shadeShift >= 0)
  then
    newShade.hue = 50
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), shadeShift)
  elseif (shadeShift < 0)
  then
    newShade.hue = 215
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), -shadeShift)
  end
  newColor.red = shadeInt >> 16
  newColor.green = shadeInt >> 8 & 255
  newColor.blue = shadeInt & 255

  return newColor
end

function showColors()
  local dlg
  dlg = Dialog{
    title="Color Shading",
    onclose=function()
      ColorShadingWindowBounds = dlg.bounds
    end
  }

  -- CURRENT FOREGROUND COLOR
  local C = app.fgColor

  -- SHADING COLORS
  local S1 = colorShift(C, 0, 0.3, -0.6, -0.6)
  local S2 = colorShift(C, 0, 0.2, -0.2, -0.3)
  local S3 = colorShift(C, 0, 0.1, -0.1, -0.1)
  local S5 = colorShift(C, 0, 0.1, 0.1, 0.1)
  local S6 = colorShift(C, 0, 0.2, 0.2, 0.2)
  local S7 = colorShift(C, 0, 0.3, 0.5, 0.4)

  -- LIGHTNESS COLORS
  local L1 = colorShift(C, 0, 0, -0.4, 0)
  local L2 = colorShift(C, 0, 0, -0.2, 0)
  local L3 = colorShift(C, 0, 0, -0.1, 0)
  local L5 = colorShift(C, 0, 0, 0.1, 0)
  local L6 = colorShift(C, 0, 0, 0.2, 0)
  local L7 = colorShift(C, 0, 0, 0.4, 0)

  -- SATURATION COLORS
  local C1 = colorShift(C, 0, -0.5, 0, 0)
  local C2 = colorShift(C, 0, -0.2, 0, 0)
  local C3 = colorShift(C, 0, -0.1, 0, 0)
  local C5 = colorShift(C, 0, 0.1, 0, 0)
  local C6 = colorShift(C, 0, 0.2, 0, 0)
  local C7 = colorShift(C, 0, 0.5, 0, 0)

  -- HUE COLORS
  local H1 = colorShift(C, -0.15, 0, 0, 0)
  local H2 = colorShift(C, -0.1, 0, 0, 0)
  local H3 = colorShift(C, -0.05, 0, 0, 0)
  local H5 = colorShift(C, 0.05, 0, 0, 0)
  local H6 = colorShift(C, 0.1, 0, 0, 0)
  local H7 = colorShift(C, 0.15, 0, 0, 0)

  -- DIALOGUE
  dlg
  :color{ label="Current Color", color=C }
  :button{ text="Get",
           onclick=function()
             dlg:close()
             showColors()
           end }

  -- SHADING
  :shades{ id='sha', label='Shading',
           colors={ S1, S2, S3, C, S5, S6, S7 },
           onclick=function(ev) app.fgColor=ev.color end }

  -- LIGHTNESS
  :shades{ id='lit', label='Lightness',
           colors={ L1, L2, L3, C, L5, L6, L7 },
           onclick=function(ev) app.fgColor=ev.color end }

  -- SATURATION
  :shades{ id='sat', label='Saturation',
           colors={ C1, C2, C3, C, C5, C6, C7 },
           onclick=function(ev) app.fgColor=ev.color end }

  -- HUE
  :shades{ id='hue', label='Hue',
           colors={ H1, H2, H3, C, H5, H6, H7 },
           onclick=function(ev) app.fgColor=ev.color end }

  dlg:show{ wait=false, bounds=ColorShadingWindowBounds }

end

-- Run the script
do
  showColors()
end
