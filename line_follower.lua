function sysCall_init()
    sim = require('sim')
    simUI = require('simUI')
        startTime = -1
    bubbleRobBase = sim.getObject('.')
    leftMotor = sim.getObject("./leftMotor")
    rightMotor = sim.getObject("./rightMotor")
    fork = sim.getObject("./Fork")
    noseSensor = sim.getObject("./sensingNose")
    noseSensor3 = sim.getObject("./sensingNose3")
    noseSensor4 = sim.getObject("./sensingNose4")
    minMaxSpeed = {50 * math.pi / 180,300 * math.pi / 180}
    backUntilTime = -1 -- Tells whether bubbleRob is in forward or backward mode
    floorSensorHandles = {-1, -1, -1}
    floorSensorHandles[1] = sim.getObject("./rightSensor")
    floorSensorHandles[2] = sim.getObject("./middleSensor")
    floorSensorHandles[3] = sim.getObject("./leftSensor")
    robotTrace = sim.addDrawingObject(sim.drawing_linestrip + sim.drawing_cyclic, 2, 0, -1, 200, {1, 1, 0}, nil, nil, {1, 1, 0})
    -- Create the custom UI:
    xml = '<ui title="'..sim.getObjectAlias(bubbleRobBase,1)..' speed" closeable="false" resizeable="false" activate="false">'..[[
                <hslider minimum="0" maximum="100" on-change="speedChange_callback" id="1"/>
            <label text="" style="* {margin-left: 300px;}"/>
        </ui>
        ]]
    ui = simUI.create(xml)
    speed = (minMaxSpeed[1] + minMaxSpeed[2]) * 0.5
    simUI.setSliderValue(ui, 1, 100 * (speed - minMaxSpeed[1]) / (minMaxSpeed[2] - minMaxSpeed[1]))
end

function sysCall_sensing()
    local p = sim.getObjectPosition(bubbleRobBase)
    sim.addDrawingObjectItem(robotTrace, p)
end 

function speedChange_callback(ui, id, newVal)
    speed = minMaxSpeed[1] + (minMaxSpeed[2] - minMaxSpeed[1]) * newVal / 100
end

local prevProximityReading = 0

function sysCall_actuation() 
    local result = sim.readProximitySensor(noseSensor)
    local result3 = sim.readProximitySensor(noseSensor3)
    local result4 = sim.readProximitySensor(noseSensor4)
    -- If both sensors detect something, stop the motors:
     if result > 0 or result3 > 0 or result4 > 0 then
        sim.setJointTargetVelocity(leftMotor, 0)
        sim.setJointTargetVelocity(rightMotor, 0)
        return
    end
    
    -- Read the line detection sensors:
    local sensorReading = {false, false, false} -- Initialize sensorReading
    for i = 1, 3, 1 do
        local result, data = sim.readVisionSensor(floorSensorHandles[i])
        if result >= 0 then
            sensorReading[i] = (data[11] < 0.5) -- data[11] is the average of intensity of the image
        end
    end
    
    -- Check if all three sensors detect a black object (presumably the robot):
    local allSensorsSeeRobot = sensorReading[1] and sensorReading[2] and sensorReading[3]
    
    -- If all sensors see the black robot, stop the robot:
    if allSensorsSeeRobot then
        -- Check if it's time to move backward
        if backUntilTime < sim.getSimulationTime() then
            -- Set the sensor handles for reverse mode
            -- Set the joint velocities for reverse mode
            
            sim.setJointTargetPosition(fork, 0.0)
            sim.setJointTargetVelocity(leftMotor, 21)
            sim.setJointTargetVelocity(rightMotor, 21)
            
            -- Set backUntilTime for a backward movement:
            backUntilTime = sim.getSimulationTime() + 2
        end
    else
        -- Compute left and right velocities to follow the detected line:
        local rightV = speed
        local leftV = speed
        
        if sensorReading[1] then
            leftV = 0.03 * speed
        end
        if sensorReading[3] then
            rightV = -0.03 * speed
        end
        if sensorReading[1] and sensorReading[3] then
            backUntilTime = sim.getSimulationTime() + 2
        end
        
        if backUntilTime < sim.getSimulationTime() then
            -- When in forward mode, move forward at the desired speed
            sim.setJointTargetVelocity(leftMotor, leftV)
            sim.setJointTargetVelocity(rightMotor, -rightV)
        end 
       
        
 end
end
function sysCall_cleanup() 
    simUI.destroy(ui)
end
