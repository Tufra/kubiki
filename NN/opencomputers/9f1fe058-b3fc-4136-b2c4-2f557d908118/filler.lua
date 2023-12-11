local robot = require("robot")
local computer = require("computer")
local comp = require("component")
local os = require("os")
local nav = comp.navigation

local slot = 1

-- Define the starting and ending waypoints (x, y, z coordinates)
local function findPosition()
	local waypoints = nav.findWaypoints(64)
    local endWaypoint = nil

    for i, val in ipairs(waypoints) do
        if val.label == 'end' then
            print("found waypoint "..val.label)
            endWaypoint = {
                ['x'] = val['position'][1],
                ['y'] = val['position'][2],
                ['z'] = val['position'][3]
            }
        end
    end

	return endWaypoint
end

local position = {
    ['x'] = 0,
    ['y'] = 0,
	['z'] = 0,
    ['direction'] = 0
}

local function getBlocks(start)
    print("return to get blocks")
    print("now at "..position['x']..' '..position['y']..' '..position['z'])
	local memory = {
		['x'] = position['x'],
    	['y'] = position['y'],
    	['z'] = position['z'],
	}
    if start == false then
        while position['z'] > 0 do
            robot.up()
            position['z'] = position['z'] - 1
        end
        if position['direction'] == 0 then
            robot.turnLeft()
        else
            robot.turnRight()
        end
        while position['x'] > 0 do
            robot.forward()
            position['x'] = position['x'] - 1
        end
        robot.turnLeft()
        while position['y'] > 0 do
            robot.forward()
            position['y'] = position['y'] - 1
        end

        robot.turnAround()
    end
	
	slot = 1

    robot.turnLeft()
	for i = slot, 16 do
    	robot.select(i)
		robot.suck()
	end
    robot.turnRight()
    
    while computer.energy() < 0.95 * computer.maxEnergy() do
    	os.sleep(5)
    end
    
    if start == false then
    	while position['y'] < memory['y'] do
            robot.forward()
            position['y'] = position['y'] + 1
        end

        robot.turnRight()

        while position['x'] < memory['x'] do
            robot.forward()
            position['x'] = position['x'] + 1
        end

        while position['z'] < memory['z'] do
            robot.down()
            position['z'] = position['z'] + 1
        end

        if position['direction'] == 0 then
            robot.turnLeft()
        else
            robot.turnRight()
        end
    end

        robot.select(1)
        slot = 1
end

-- Function to fill one column
local function fillColumn()
    print("filling column at "..position['x']..' '..position['y']..' '..position['z'])
    local dis = findPosition()
    print("distance "..dis['x']..' '..dis['y']..' '..dis['z'])
    while not robot.detectDown() do
        robot.down()
    	position['z'] = position['z'] + 1
    end
    while position['z'] > 0 do
        robot.up()
        position['z'] = position['z'] - 1
    	robot.placeDown()
    	if robot.count() == 0 then
            if slot == 16 then
            	getBlocks(false)
            else
        		slot = slot + 1
            	robot.select(slot)
            end
    	end
    end
    
    if computer.energy() < 0.25 * computer.maxEnergy() then
    	getBlocks(false)
    end
end

-- Main function
function main()
	getBlocks(true)
    print("moving direction 0")
    -- Move to the starting waypoint
	while findPosition()['x'] ~= 0 or findPosition()['y'] ~= 0 or findPosition()['z'] ~= 0 do
        
        while findPosition()['z'] ~= 0 do
            robot.forward()
			position['y'] = position['y'] + 1
            fillColumn()
        end
		robot.turnRight()
		robot.forward()
        robot.turnRight()
        position['direction'] = 1
        print("moving direction 1")
		position['x'] = position['x'] + 1
		fillColumn()
		
		while position['y'] > 1 do
            robot.forward()
    		position['y'] = position['y'] - 1
            fillColumn()
        end
		robot.turnLeft()
		robot.forward()
        robot.turnLeft()
        position['direction'] = 0
        position['x'] = position['x'] + 1
        print("moving direction 0")
		fillColumn()
	end
end

-- Call the main function
main()
