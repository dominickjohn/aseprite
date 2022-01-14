-- Color Shading v2.0
-- Aseprite Script that opens a dynamic palette picker window with relevant color shading options
-- Written by Dominick John, twitter @dominickjohn
-- Contributed to by David Capello
-- https://github.com/dominickjohn/aseprite/

-- Instructions:
--    Place this file into the Aseprite scripts folder (File -> Scripts -> Open Scripts Folder)
--    Run the "Color Shading" script (File -> Scripts -> Color Shading) to open the palette window.

-- Commands:
--    Base: Clicking on either base color will switch the shading palette to that saved color base.
--    "Get" Button: Updates base colors using the current foreground and background color and regenerates shading.
--    Left click: Set clicked color as foreground color.
--    Right click: Set clicked color as background color.
--    Middle click: Set clicked color as foreground color and regenerate all shades based on this new color.

function lerp(first, second, by)
  return first * (1 - by) + second * by
end

function lerpRGBInt(color1, color2, amount)
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
  newColor.hslHue = (newColor.hslHue + hueShift * 360) % 360

  -- SHIFT SATURATION
  if (satShift > 0) then
    newColor.saturation = lerp(newColor.saturation, 1, satShift)
  elseif (satShift < 0) then
    newColor.saturation = lerp(newColor.saturation, 0, -satShift)
  end

  -- SHIFT LIGHTNESS
  if (lightShift > 0) then
    newColor.lightness = lerp(newColor.lightness, 1, lightShift)
  elseif (lightShift < 0) then
    newColor.lightness = lerp(newColor.lightness, 0, -lightShift)
  end

  -- SHIFT SHADING
  local newShade = Color {red = newColor.red, green = newColor.green, blue = newColor.blue}
  local shadeInt = 0
  if (shadeShift >= 0) then
    newShade.hue = 50
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), shadeShift)
  elseif (shadeShift < 0) then
    newShade.hue = 215
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), -shadeShift)
  end
  newColor.red = shadeInt >> 16
  newColor.green = shadeInt >> 8 & 255
  newColor.blue = shadeInt & 255

  return newColor
end

function showColors(shadingColor, fg, bg, windowBounds)
  local dlg
  dlg =
    Dialog {
    title = "Color Shading"
  }

  -- CACHING
  local FGcache = app.fgColor
  if(fg ~= nil) then
    FGcache = fg
  end

  local BGcache = app.bgColor
  if(bg ~= nil) then
    BGcache = bg
  end

  -- CURRENT CORE COLOR TO GENERATE SHADING
  local C = app.fgColor
  if(shadingColor ~= nil) then
    C = shadingColor
  end

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
  dlg:
  shades {
     -- SAVED COLOR BASES
    id = "base",
    label = "Base",
    colors = {FGcache, BGcache},
    onclick = function(ev)
      showColors(ev.color, FGcache, BGcache, dlg.bounds)
      dlg:close()
    end
  }:button {
    -- GET BUTTON
    id = "get",
    text = "Get",
    onclick = function()
      showColors(app.fgColor, app.fgColor, app.bgColor, dlg.bounds)
      dlg:close()
    end
  }:shades {
     -- SHADING
    id = "sha",
    label = "Shade",
    colors = {S1, S2, S3, C, S5, S6, S7},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- LIGHTNESS
    id = "lit",
    label = "Light",
    colors = {L1, L2, L3, C, L5, L6, L7},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- SATURATION
    id = "sat",
    label = "Sat",
    colors = {C1, C2, C3, C, C5, C6, C7},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- HUE
    id = "hue",
    label = "Hue",
    colors = {H1, H2, H3, C, H5, H6, H7},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
        --showColors(SCcache, FGcache, BGcache, dlg.bounds)
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
        --showColors(SCcache, FGcache, BGcache, dlg.bounds)
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }
  
  dlg:show {wait = false, bounds = windowBounds}
end

-- Run the script
do
  showColors(app.fgColor)
end
