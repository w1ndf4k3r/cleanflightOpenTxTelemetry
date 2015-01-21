local lastBlink = 0
local blinkShowState = true
local function blinkShow()
  local time = getTime() % 128
  local blink = (time - time % 64) / 64
  if blink ~= lastBlink then
    lastBlink = blink
	blinkShowState = not blinkShowState    
  end
    return blinkShowState  
end

-- will draw a white popup with border on the center of the screen
-- width: width of the popup
-- height: height of the popup
local function popup(width,height)
	--lcd.drawFilledRectangle(106-(width/2), 10, width, height,INVERS)
	lcd.drawFilledRectangle(106-(width/2), 32-(height/2), width, height,ERASE)
	
	lcd.drawRectangle(106-(width/2), 32-(height/2), width, height)
end

return {popup=popup,blinkShow=blinkShow}