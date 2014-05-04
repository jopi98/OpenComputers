local robot = require("robot")
local os = require("os")

local tArgs = {...}

local forward = 1
local up = 2
local down = 3

local currentslot = 1

function fail(reason)
  print(reason)
  os.exit(false)
end

function safeMove(dir)
  if dir == forward then
    -- forward
    local m, r = robot.detect()
    if m then
      robot.swing()
    end
    m, r = robot.forward()
    if not m then
      fail("Failed to move: "..r)
    end
  elseif dir == up then
    -- up
    local m, r = robot.detectUp()
    if m then
      robot.swingUp()
    end
    m, r = robot.up()
    if not m then
      fail("Failed to move: "..r)
    end
  elseif dir == down then
    -- down
    local m, r = robot.detectDown()
    if m then
      robot.swingDown()
    end
    m, r = robot.down()
    if not m then
      fail("Failed to move: "..r)
    end
  end
end

function safePlace(dir)
  while robot.count(currentslot) == 0 do
    currentslot = currentslot + 1
    if currentslot > 16 then
      fail("Out of blocks.")
    end
  end
  robot.select(currentslot)
  
  if dir == forward then
    -- forward
    local m, r = robot.detect()
    if m then
      robot.swing()
    end
    if not clear then
      m = robot.place()
      if not m then
        fail("Failed to place block, probably due to "..r)
      end
    end
  elseif dir == up then
    -- up
    local m, r = robot.detectUp()
    if m then
      robot.swingUp()
    end
    if not clear then
      m = robot.placeUp()
      if not m then
        fail("Failed to place block, probably due to "..r)
      end
    end
  elseif dir == down then
    -- down
    local m, r = robot.detectDown()
    if m then
      robot.swingDown()
    end
    if not clear then
      m = robot.placeDown()
      if not m then
        fail("Failed to place block, probably due to "..r)
      end
    end
  end
end

if #tArgs > 4 or #tArgs < 2 then
  print("wrong number of arguments")
  print("square.lua depth width [depth_offset] [width_offset]")
  return
end

local depth = tonumber(tArgs[1])
local width = tonumber(tArgs[2])
local depth_offset = 0
local width_offset = 0

if #tArgs > 2 then
  depth_offset = tonumber(tArgs[3])
  if #tArgs > 3 then
    width_offset = tonumber(tArgs[4])
  end
end


-- check inventory
local haveBlock = 0
for i = 1,16 do
  haveBlock = haveBlock + robot.count(i)
end

if haveBlock < (depth*width) then
  print("Error: Not enough blocks in inventory")
  return
end

safeMove(forward)
if width_offset > 0 then
  robot.turnRight()
  for i = 1,width_offset do
    safeMove(forward)
  end
  robot.turnLeft()
elseif width_offset < 0 then
  robot.turnLeft()
  for i = 1,abs(width_offset) do
    safeMove(forward)
  end
  robot.turnRight()
end

-- build
local odd = true

function nextRow()
  if odd then
    robot.turnRight()
    safeMove(forward)
    robot.turnRight()
  else
    robot.turnLeft()
    safeMove(forward)
    robot.turnLeft()
  end
  odd = not odd
end

for x = 1,width do
  for i = 1, (depth-1) do
    safePlace(down)
    safeMove(forward)
  end
  safePlace(down)
  nextRow()
end

