require("lib.publicFunc")
require("lib.keyEvent")
require("lib.mouse")
require("lib.images")

-- ######################################
-- ################INIT##################
-- ######################################
function love.load()
    local idx = 1
    Image.init()
    Image.loadImages(idx)

    Mouse.callBack(MS_EVENT.LEFT_RELEASED,Image.setBox)
    Mouse.callBack(MS_EVENT.LEFT_PRESSED,Image.setDrag)
    Mouse.callBack(MS_EVENT.LEFT_PRESSING,Image.drag)
    Mouse.callBack(MS_EVENT.LEFT_RELEASED,Image.cancelDrag)
    KeyEvent.addEvent("space", Image.setPlayed)
    KeyEvent.addEvent("g", Mouse.setState,MS_STATE.DRAW_ATK_RECT)
    KeyEvent.addEvent("h", Mouse.setState,MS_STATE.DRAW_HIT_RECT)
    KeyEvent.addEvent("r", Image.applyPreFrameOffset)
    KeyEvent.addEvent("f", Image.applyCurFrameForAll)
    KeyEvent.addEvent("up", Image.moveUp,1)
    KeyEvent.addEvent("down", Image.moveDown,1)
    KeyEvent.addEvent("left", Image.moveLeft,1)
    KeyEvent.addEvent("right", Image.moveRight,1)
    KeyEvent.addEvent("s", Image.SaveData)
    KeyEvent.addEvent("q", Image.preFrame)
    KeyEvent.addEvent("e", Image.nextFrame)
    -- ############ DEBUG
    -- Mouse.callBack(MS_EVENT.LEFT_PRESSED,function ()
    --     local drawArea = Mouse.getDrawArea()
    -- end)
end

function love.keypressed(key)
    KeyEvent.trigger(key)
end

function love.update(dt)
    Mouse.update(dt)
    Image.update(dt)
end

function love.draw()
    Image.draw()
    Mouse.draw()
end