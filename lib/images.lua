local image_list = require("res.imageList")

ENUM_DIR = {
    UP = 1,             --上
    DOWN = 2,           --下
    LEFT = 4,           --左
    RIGHT = 8,          --右
}

local Frame = {
    img = 0,
    of_x = 0,
    of_y = 0,
    width = 0,
    height = 0,
    atk = {-100,0,0,0},
    hit = {-100,0,0,0},
}

local ImgsPack = {
    frames = {},
    index = 1,
    max_frame = 0,
    paused = true,
    rate = 0.5,
    timer = 0,
    set = nil,
}

Image = {}

local imgs = {nil}
local ORIGIN_X = 0
local ORIGIN_Y = 0
local touchedImage = nil
local touched = false
local draged = false
local img_off_x = 0
local img_off_y = 0

local WIDTH
local HEIGHT
local DIST = 30
local GRIDS_X = {nil}
local GRIDS_Y = {nil}
local LN = 0
local CERTS_FORMAT = false

function Image.init()
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()
    local nx = math.floor(WIDTH / DIST)
    -- 写入竖线
    for i = 1, nx do
        local x = DIST * i
        local idx1 = 2 * i - 1
        local idx2 = 2 * i
        GRIDS_X[idx1] = x
        GRIDS_X[idx2] = x
        GRIDS_Y[idx1] = 0
        GRIDS_Y[idx2] = HEIGHT
 
    end

    -- 写入横线
    local d = DIST
    local ny = math.floor(HEIGHT / DIST)
    for i = nx + 1,  nx + ny, 1 do
        local idx1 = 2 * i - 1
        local idx2 = 2 * i

        GRIDS_X[idx1] = 0
        GRIDS_X[idx2] = WIDTH
        GRIDS_Y[idx1] = d
        GRIDS_Y[idx2] = d
        d = d + DIST
    end
    ORIGIN_X = nx * DIST / 2
    ORIGIN_Y = ny * DIST / 2
    LN = (nx + ny)

end

function Image.loadImages(idx)
    local set = image_list[idx]
    ImgsPack.max_frame = set.max_frame
    ImgsPack.set = set
    for i = 1,set.max_frame,1 do
        local _frame = Public.deepCopy(Frame)
        _frame.img = love.graphics.newImage(set.path..(i - 1)..".png")
        _frame.width = _frame.img:getWidth()
        _frame.height = _frame.img:getHeight()
        ImgsPack.frames[i] =_frame
    end
    Image.loadBoxData("atk",set.path.."AtkBox.txt")
    Image.loadBoxData("hit",set.path.."HitBox.txt")
    Image.loadPosData(set.path.."pos.txt")
end

function Image.loadPosData(filename)
    local _read_file = io.open(filename, "r")
    if _read_file then
        for i = 1,ImgsPack.max_frame do
            ImgsPack.frames[i].of_x = _read_file:read("*n")
            ImgsPack.frames[i].of_y = _read_file:read("*n")
        end
        io.close(_read_file)
    else
        print("文件读取失败:", filename)
        return nil
    end
end

function Image.loadBoxData(box,filename)
    local _read_file = io.open(filename, "r")
    if _read_file then
        for i = 1,ImgsPack.max_frame do
            local data = ImgsPack.frames[i][box]
            data[1] = _read_file:read("*n") + ORIGIN_X
            data[2] = _read_file:read("*n") + ORIGIN_Y
            data[3] = _read_file:read("*n")
            data[4] = _read_file:read("*n")
            if(CERTS_FORMAT)then
                data[1] = data[1] -  data[3]
                data[2] = data[2] -  data[4]
                data[3] = data[3]* 2
                data[4] = data[4]* 2
            end

        end
        io.close(_read_file)
    else
        print("文件读取失败:", filename)
        return nil
    end

end

function Image.SaveData()
    Image.SaveBoxData("atk",ImgsPack.set.path.."AtkBox.txt")
    Image.SaveBoxData("hit",ImgsPack.set.path.."HitBox.txt")

    local _write_file = io.open(ImgsPack.set.path.."pos.txt", "w")
    if _write_file then
        for i = 1,ImgsPack.max_frame do
            _write_file:write(table.concat({ImgsPack.frames[i].of_x," ",ImgsPack.frames[i].of_y,"\n"}))
        end
        io.close(_write_file)
    else
        print("文件读取失败:", "pos.txt")
        return nil
    end

end


function Image.SaveBoxData(box,filename)
    --write Box
   local _write_file = io.open(filename, "w")
   local x
   local y
   local w
   local h  
   for index = 1,ImgsPack.max_frame do
        local t_data = ImgsPack.frames[index][box]
        x = t_data[1] - ORIGIN_X
        y = t_data[2] - ORIGIN_Y
        w = t_data[3]
        h = t_data[4]
        _write_file:write(table.concat({x," ",y," ",w," ",h,"\n"}))
   end
   io.close(_write_file)
end

function SaveRectData(data,path)
    local _write_file = io.open(path, "w")
    for i = 1, 4, 1 do
        _write_file:write(data[i])
        _write_file:write(" ")
    end
end

function Image.draw()
    love.graphics.setColor(0.4,0.4,0.4,0.4)
    for k = 1, LN do
        local i1 = 2*k - 1
        local i2 = 2*k
        love.graphics.line(GRIDS_X[i1], GRIDS_Y[i1], GRIDS_X[i2], GRIDS_Y[i2])
    end

    local frame = ImgsPack.frames[ImgsPack.index]
    love.graphics.setColor(1,1,0.1,0.1)
    love.graphics.rectangle("fill",8,36,124,86)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print('frame index',10,40)
    love.graphics.print(ImgsPack.index,100,40)
    love.graphics.print('offset x',10,60)
    love.graphics.print(frame.of_x,100,60)
    love.graphics.print('offset y',10,80)
    love.graphics.print(frame.of_y,100,80)
    love.graphics.print('is_play',10,100)
    if(ImgsPack.paused)then
        love.graphics.print("false",100,100)
    else
        love.graphics.print("true",100,100)
    end

    love.graphics.circle("fill",ORIGIN_X,ORIGIN_Y,5)

    if(ImgsPack.index > 1)then
        local pre_frame = ImgsPack.frames[ImgsPack.index - 1]
        love.graphics.setColor(0.1,0.8,0.1,0.6)
        love.graphics.draw(pre_frame.img,ORIGIN_X,ORIGIN_Y,
                             0,1,1,pre_frame.of_x,pre_frame.of_y)
        love.graphics.setColor(1,1,1,1)
    end

    love.graphics.draw(frame.img,ORIGIN_X,ORIGIN_Y,
                        0,1,1,frame.of_x,frame.of_y)
    if(touched)then
        love.graphics.setColor(1,1,1,0.6)
        love.graphics.rectangle("line",ORIGIN_X - frame.of_x,ORIGIN_Y - frame.of_y,frame.width,frame.height)
        love.graphics.setColor(1,1,0.1,1)
    end


    -- ######################################
    -- ###############绘制矩形框##############
    -- ######################################
    local atk = frame.atk
    local hit = frame.hit
    love.graphics.setColor(1,1,0,1)
    love.graphics.rectangle('line',atk[1],atk[2],atk[3],atk[4])
    love.graphics.print('atk',atk[1],atk[2])
    love.graphics.setColor(0,0,1,1)
    love.graphics.rectangle('line',hit[1],hit[2],hit[3],hit[4])
    love.graphics.print('hit',hit[1],hit[2])
    love.graphics.setColor(1,1,1,1)
end

function Image.update(dt)
    local frame = ImgsPack.frames[ImgsPack.index]
    local mou_x = love.mouse.getX() + frame.of_x
    local mou_y = love.mouse.getY() + frame.of_y

    if(mou_x > ORIGIN_X  and  mou_x < ORIGIN_X + frame.width
        and mou_y > ORIGIN_Y and mou_y < ORIGIN_Y + frame.height)then
        touchedImage = ImgsPack
        touched = true
    else
        touched = false
    end
    if(ImgsPack.paused)then return end
    Image.play(dt)
end

function Image.applyPreFrameOffset()
    if(ImgsPack.index > 1)then
        local pre_frame = ImgsPack.frames[ImgsPack.index - 1]
        local frame = ImgsPack.frames[ImgsPack.index]
        frame.of_x = pre_frame.of_x
        frame.of_y = pre_frame.of_y
    end
end

function Image.applyCurFrameForAll()
    if(ImgsPack.index == ImgsPack.max_frame)then return end
    local frame = ImgsPack.frames[ImgsPack.index]
    for i = ImgsPack.index, ImgsPack.max_frame, 1 do
        local next_frame = ImgsPack.frames[i]
        next_frame.of_x = frame.of_x
        next_frame.of_y = frame.of_y
    end
end

function Image.setDrag(ms_state,st_x,st_y)
    if(not touched or ms_state ~= MS_STATE.PRESSED)then
        return
    end
    draged = true
    img_off_x = st_x
    img_off_y = st_y
end

function Image.drag(ms_state,st_x,st_y)
    if(not draged)then return end
    local frame = touchedImage.frames[touchedImage.index]
    local dist_x =  img_off_x - st_x
    local dist_y =  img_off_y - st_y
    frame.of_x = frame.of_x  + dist_x
    frame.of_y = frame.of_y + dist_y
    frame.atk[1] = frame.atk[1] - dist_x
    frame.atk[2] = frame.atk[2] - dist_y
    frame.hit[1] = frame.hit[1] - dist_x
    frame.hit[2] = frame.hit[2] - dist_y
    img_off_x = st_x
    img_off_y = st_y
end

function Image.play(dt)
    ImgsPack.timer = ImgsPack.timer + dt
    if(ImgsPack.timer > ImgsPack.rate)then
        Image.nextFrame()
        ImgsPack.timer = 0
    end
end

function Image.setPlayed()
    ImgsPack.paused = not ImgsPack.paused
end

function Image.nextFrame()
    ImgsPack.index = ImgsPack.index + 1
    if(ImgsPack.index > ImgsPack.max_frame)then
        ImgsPack.index = 1
    end
end

function Image.preFrame()
    ImgsPack.index = ImgsPack.index - 1
    if(ImgsPack.index < 1)then
        ImgsPack.index = ImgsPack.max_frame
    end
end

function Image.moveUp(distance)
    local frame = ImgsPack.frames[ImgsPack.index]
    frame.of_y = frame.of_y + distance
end

function Image.moveDown(distance)
    local frame = ImgsPack.frames[ImgsPack.index]
    frame.of_y = frame.of_y - distance
end

function Image.moveLeft(distance)
    local frame = ImgsPack.frames[ImgsPack.index]
    frame.of_x = frame.of_x + distance
end

function Image.moveRight(distance)
    local frame = ImgsPack.frames[ImgsPack.index]
    frame.of_x = frame.of_x - distance
end

function Image.setBox()
    local frame = ImgsPack.frames[ImgsPack.index]
    local _state = Mouse.getState()
    local box
    if(_state == MS_STATE.DRAW_ATK_RECT)then
        box = frame.atk
    elseif(_state == MS_STATE.DRAW_HIT_RECT)then
        box = frame.hit
    else
        return
    end
    local data = Mouse.getDrawArea()
    for i = 1, 4, 1 do
        box[i] = data[i]
    end
    -- Public.dumpTable(box,_state)
end

return Image