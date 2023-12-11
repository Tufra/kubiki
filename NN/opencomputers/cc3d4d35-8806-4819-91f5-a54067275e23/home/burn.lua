local component = require("component")
local robot = require("robot")

-- Main loop
while true do
    robot.use()
    robot.turnRight()
    robot.use()
    robot.turnRight()
    robot.use()
    robot.turnAround()
    
    os.sleep(40)

    if robot.durability() == 0 then
    	print("Tool is broken!")

                -- Drop items into the chest
        for slot = 1, robot.inventorySize() do
            robot.select(slot)
            robot.dropDown(chestSide)
        end
        robot.select(1)  -- Return to the first slot
        
        robot.suckUp()
    end
end
