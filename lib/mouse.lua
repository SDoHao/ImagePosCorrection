local ENUM_MOUSE_STATE = {
    NORMAL = 0,                   --
    DRAW_ATK_RECT = 1,            --绘制攻击框
                                  --...
    DRAW_HIT_RECT = 3,            --绘制受击框
    PRESSED = 4,
    END = 4,
}

local ENUM_MOUSE_BUTTON = {
    LEFT = 1,
    RIGHT = 2,
    WHEEL = 3,
}

local ENUM_MOUSE_EVENT = {
    LEFT_PRESSED = 1,             --鼠标左键按下
    LEFT_RELEASED = 2,            --鼠标左键释放
    RIGHT_PRESSED = 3,            --鼠标右键按下
    RIGHT_RELEASED = 4,           --鼠标右键释放
    WHELL_PRESSED = 5,            --鼠标滚轮按下
    WHELL_RELEASED = 6,           --鼠标滚轮释放
    LEFT_PRESSING = 7,            --鼠标左键一直按下
    RIGHT_PRESSING = 8,           --鼠标右键一直按下
    WHELL_PRESSING = 6,           --鼠标滚轮一直按下
    -- ...
}

MS_STATE = ENUM_MOUSE_STATE
MS_BUTTON = ENUM_MOUSE_BUTTON
MS_EVENT = ENUM_MOUSE_EVENT

local draw_area = {0,0,0,0}

local  mouse_events = {}

Mouse = {
    cur_x = 0,
    cur_y = 0,
    st_x = 0,
    st_y = 0,
    ed_w = 0,
    ed_h = 0,
    pressed = 0,
    get_rect = false,
    state = ENUM_MOUSE_STATE.NORMAL,
}

function Mouse.callBack(_ms_event,func)
    if(not mouse_events[_ms_event])then
        mouse_events[_ms_event] = {nil}
    end
    table.insert(mouse_events[_ms_event],func)
end

function Mouse.emit(_ms_event)
    if(not mouse_events[_ms_event])then
        return
    end
    for _, func in ipairs(mouse_events[_ms_event]) do
        func(Mouse.state,Mouse.cur_x,Mouse.cur_y)
    end
end

function Mouse.getDrawArea()
    return draw_area
end

function Mouse.setState(_state)
    if(_state <= MS_STATE.NORMAL or _state >= MS_STATE.END)then
        return
    end
    Mouse.state = _state
end

function Mouse.getState()
    return Mouse.state
end

function love.mousepressed(x,y,button)
    local ms_state = Mouse.state
    Mouse.pressed = button
    Mouse.cur_x = x
    Mouse.cur_y = y
    if(button == MS_BUTTON.LEFT)then
        if(ms_state >= ENUM_MOUSE_STATE.DRAW_ATK_RECT
        and ms_state <= ENUM_MOUSE_STATE.DRAW_HIT_RECT)then
            Mouse.get_rect,Mouse.st_x,Mouse.st_y = true,x,y
        else
            Mouse.state = MS_STATE.PRESSED
        end
        Mouse.emit(MS_EVENT.LEFT_PRESSED)
    else
        Mouse.state = MS_STATE.PRESSED
    end
end

function love.mousereleased(x,y,button)
    local ms_state = Mouse.state
    if(button == MS_BUTTON.LEFT)then
        if(ms_state >= ENUM_MOUSE_STATE.DRAW_ATK_RECT
        and ms_state <= ENUM_MOUSE_STATE.DRAW_HIT_RECT)then
            Mouse.get_rect = false
            Mouse.ed_w =  Mouse.cur_x - Mouse.st_x
            Mouse.ed_h =  Mouse.cur_y - Mouse.st_y
            local half_w = math.abs(Mouse.ed_w)
            local half_h = math.abs(Mouse.ed_h)
            draw_area[1] = Mouse.st_x
            draw_area[2] = Mouse.st_y
            draw_area[3] = half_w
            draw_area[4] = half_h
        end
        Mouse.emit(ENUM_MOUSE_EVENT.LEFT_RELEASED)
    end
    Mouse.state = ENUM_MOUSE_STATE.NORMAL
end


function Mouse.update(dt)
    if(Mouse.state == MS_STATE.PRESSED)then
        Mouse.cur_x = love.mouse.getX()
        Mouse.cur_y = love.mouse.getY()
        Mouse.emit(ENUM_MOUSE_EVENT.WHELL_RELEASED + Mouse.pressed)
    elseif(Mouse.get_rect)then
        Mouse.cur_x = love.mouse.getX()
        Mouse.cur_y = love.mouse.getY()
        Mouse.ed_w = (Mouse.cur_x - Mouse.st_x)
        Mouse.ed_h = (Mouse.cur_y - Mouse.st_y)
    end
end

function Mouse.draw()
    if Mouse.get_rect then
        love.graphics.setColor(0,0,1,0.2)
        love.graphics.rectangle('fill',Mouse.st_x,Mouse.st_y,Mouse.ed_w,Mouse.ed_h)
        love.graphics.setColor(1,1,0,1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line',Mouse.st_x,Mouse.st_y,Mouse.ed_w,Mouse.ed_h)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1,1,1,1)
    end
end

return Mouse