# Line-Following Robot with CoppeliaSim

This project simulates a line-following robot in CoppeliaSim using Lua for the simulation logic. The robot uses three floor sensors to detect lines and three proximity sensors to avoid obstacles. The speed of the robot can be controlled via a custom UI slider.

## Files and Directories

- `line_follower_robot.ttt`: The CoppeliaSim scene file containing the robot and environment setup.
- `sysCall_init`, `sysCall_sensing`, `sysCall_actuation`, `sysCall_cleanup`: Lua script functions implementing the robot's behavior.

## Code Description

### Initialization (`sysCall_init`)
- Imports necessary modules (`sim` and `simUI`).
- Initializes variables and retrieves object handles for the robot base, motors, fork, and sensors.
- Sets the minimum and maximum speed for the robot.
- Creates a custom UI with a slider to adjust the robot's speed.
- Sets an initial speed for the robot.

```lua
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
    minMaxSpeed = {50 * math.pi / 180, 300 * math.pi / 180}
    backUntilTime = -1
    floorSensorHandles = {sim.getObject("./rightSensor"), sim.getObject("./middleSensor"), sim.getObject("./leftSensor")}
    robotTrace = sim.addDrawingObject(sim.drawing_linestrip + sim.drawing_cyclic, 2, 0, -1, 200, {1, 1, 0})
    xml = '<ui title="'..sim.getObjectAlias(bubbleRobBase, 1)..' speed" closeable="false" resizeable="false" activate="false">'..[[
                <hslider minimum="0" maximum="100" on-change="speedChange_callback" id="1"/>
            <label text="" style="* {margin-left: 300px;}"/>
        </ui>
    ]]
    ui = simUI.create(xml)
    speed = (minMaxSpeed[1] + minMaxSpeed[2]) * 0.5
    simUI.setSliderValue(ui, 1, 100 * (speed - minMaxSpeed[1]) / (minMaxSpeed[2] - minMaxSpeed[1]))
end
