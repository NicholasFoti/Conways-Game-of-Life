local composer = require( "composer" )
local scene = composer.newScene()

--Initialise all variables to be used
local buttonAudio = audio.loadSound("button.mp3")
local mathRandom = math.random
local gridSize = composer.getVariable("gridSize")
local yOffset
if gridSize == 200 then
    cellSize = 2
    yOffset = 30 
elseif gridSize == 25 then
    cellSize = 15
    yOffset = 10  
end
local grid = {}
local isPaused = true
local savedStates = composer.getVariable("savedStates") or {}
local iterationSpeed = 500
local updateTimer

--Funciton to clear the grid when reset is pressed
local function clearGrid()
    isPaused = true
    
    for i = 1, gridSize do
        for j = 1, gridSize do
            if grid[i] and grid[i][j] then
                display.remove(grid[i][j])
                grid[i][j] = nil
            end
        end
        if grid[i] then
            grid[i] = nil
        end
    end
end


--Create button to Save the current grid and return to the main menu
local function createSaveMenuButton(sceneGroup)
    local btnWidth = 180
    local btnHeight = 50
    
    local saveMenuButton = display.newRect(display.contentCenterX, 500, btnWidth, btnHeight)
    saveMenuButton:setFillColor(0.2)
    saveMenuButton.strokeWidth = 3
    saveMenuButton:setStrokeColor(0.4)
    sceneGroup:insert(saveMenuButton)

    local saveMenuText = display.newText("Save Game and Go Back", display.contentCenterX, 500, native.systemFont, 15)
    saveMenuButton:addEventListener("tap", function()
        audio.play(buttonAudio)

        --Save the current grid to SavedState
        local savedState = savedStates["randomGrid_" .. gridSize] or {}
        for i = 1, #grid do
            savedState[i] = {}
            for j = 1, #grid[i] do
                savedState[i][j] = grid[i][j].state
            end
        end
        savedStates["randomGrid_"..gridSize] = savedState

        --Set the variables to be used when loading the grid
        composer.setVariable("savedStates", savedStates)
        composer.setVariable("pausedGridSize", gridSize)
        composer.setVariable("pausedUserChoice", userChoice)
        isPaused = true
        print("Game Saved")

        --Return to the main menu
        composer.gotoScene("mainMenu")
        composer.removeScene("randomGrid")
    end)
    sceneGroup:insert(saveMenuText)
end

--Create button to delete the current grid and return to the main menu
local function createDeleteMenuButton(sceneGroup)
    local btnWidth = 180
    local btnHeight = 50

    local deleteMenuButton = display.newRect(display.contentCenterX, 560, btnWidth, btnHeight)
    deleteMenuButton:setFillColor(0.2) 
    deleteMenuButton.strokeWidth = 3
    deleteMenuButton:setStrokeColor(0.4)
    sceneGroup:insert(deleteMenuButton)

    local deleteMenuText = display.newText("Delete and Go Back", display.contentCenterX, 560, native.systemFont, 16)
    deleteMenuButton:addEventListener("tap", function()
        audio.play(buttonAudio)
        isPaused = true

        --Set savedStates to nil to ensure a fresh grid when returning
        savedStates["randomGrid_" .. gridSize] = nil
        composer.setVariable("savedStates", savedStates)
        print("Deleted Game")
        composer.gotoScene("mainMenu")
        composer.removeScene("randomGrid")
    end)
    sceneGroup:insert(deleteMenuText)
end

--Create function to randomly set the grid
local function onRandomTap(sceneGroup)
    random = true

    --Create the grid
    for i = 1, gridSize do
        grid[i] = {}
        for j = 1, gridSize do
            local cell = display.newRect(i * cellSize, j * cellSize, cellSize, cellSize)
            cell.state = (mathRandom(1, 1000) <= 125) and "alive" or "dead"  -- With this, roughly 12.5% of the cells will be "alive"
            cell:setFillColor(cell.state == "alive" and 0 or 1)
            cell.x, cell.y = i * cellSize, j * cellSize - yOffset
            sceneGroup:insert(cell)
            grid[i][j] = cell
        end
    end
    print("Grid randomised")
end

--Function to count how many alive neighbours a cell has
local function countAliveNeighbors(x, y)
    local count = 0
    for i = -1, 1 do
        for j = -1, 1 do
            if not (i == 0 and j == 0) then
                local newX, newY = (x + i - 1) % gridSize + 1, (y + j - 1) % gridSize + 1
                if grid[newX][newY].state == "alive" then
                    count = count + 1
                end
            end
        end
    end
    return count
end

--Function to update cells depending on its alive neighbours
local function update()
    if isPaused then return end

    local newStates = {}
    for i = 1, gridSize do
        newStates[i] = {}
        for j = 1, gridSize do
            local aliveNeighbors = countAliveNeighbors(i, j)
            if grid[i][j].state == "alive" then
                newStates[i][j] = (aliveNeighbors == 2 or aliveNeighbors == 3) and "alive" or "dead"
            else
                newStates[i][j] = (aliveNeighbors == 3) and "alive" or "dead"
            end
        end
    end
    for i = 1, gridSize do
        for j = 1, gridSize do
            grid[i][j].state = newStates[i][j]
            grid[i][j]:setFillColor(grid[i][j].state == "alive" and 0 or 1)
        end
    end
end

--Text to display the current iteration speed
local speedText = display.newText("Speed: "..iterationSpeed.."ms", display.contentCenterX, display.contentHeight - 85, native.systemFont, 16)

--Function to change the iteration speed on users request
local function changeIterationSpeed(delta)
    -- Stop the current timer
    timer.cancel(updateTimer)
    
    -- Adjust the iterationSpeed
    iterationSpeed = iterationSpeed + delta
    if iterationSpeed < 100 then
        iterationSpeed = 100
    end
    if iterationSpeed < 500 then
        speedText:setFillColor(0, 1, 0) 
    elseif iterationSpeed > 500 then
        speedText:setFillColor(1, 0, 0)  
    else
        speedText:setFillColor(1, 1, 1) 
    end
    speedText.text = "Speed: "..iterationSpeed.."ms"

    -- Restart the timer with the new speed
    updateTimer = timer.performWithDelay(iterationSpeed, update, -1)
end

function scene:create(event)
    local sceneGroup = self.view

    local savedState = savedStates["randomGrid_" .. gridSize]

    --Create Background
    local background = display.newImageRect("background.jpg", display.actualContentWidth, display.actualContentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)

    --Insert the Menu buttons
    createSaveMenuButton(sceneGroup)
    createDeleteMenuButton(sceneGroup)

    --Check if there was a previously savedState to load, otherwise randomly generate a fresh grid
    if savedState then
        -- Load the grid based on savedState
        for i = 1, gridSize do
            grid[i] = {}
            for j = 1, gridSize do
                local cell = display.newRect(i * cellSize, j * cellSize, cellSize, cellSize)
                cell.state = savedState[i][j]
                cell:setFillColor(cell.state == "alive" and 0 or 1)
                cell.x, cell.y = i * cellSize, j * cellSize - yOffset
                sceneGroup:insert(cell)
                grid[i][j] = cell
            end
        end
        print("Game Loaded")
    else
        onRandomTap(sceneGroup)
    end

    --Insert the control buttons
    local startButton = display.newText("Start", display.contentCenterX - 60, display.contentHeight - 35, native.systemFontBold, 16)
    sceneGroup:insert(startButton)

    local pauseButton = display.newText("Pause", display.contentCenterX, display.contentHeight - 35, native.systemFontBold, 16)
    sceneGroup:insert(pauseButton)

    local resetButton = display.newText("Reset", display.contentCenterX + 60, display.contentHeight - 35, native.systemFontBold, 16)
    sceneGroup:insert(resetButton)

    --Define the functions of the control buttons
    startButton:addEventListener("tap", function()
        isPaused = false
        startButton:setFillColor(0, 1, 0)  
        pauseButton:setFillColor(1, 1, 1)  
        resetButton:setFillColor(1, 1, 1)
    end)
    
    pauseButton:addEventListener("tap", function()
        isPaused = true
        startButton:setFillColor(1, 1, 1)  
        pauseButton:setFillColor(1, 0.5, 0) 
        resetButton:setFillColor(1, 1, 1)   
    end)
    
    resetButton:addEventListener("tap", function()
        clearGrid()
        isPaused = true
        onRandomTap(sceneGroup)
    
        startButton:setFillColor(1, 1, 1)  
        pauseButton:setFillColor(1, 1, 1)  
    
        -- Flash reset button red
        resetButton:setFillColor(1, 0, 0)   
        timer.performWithDelay(500, function()  
            resetButton:setFillColor(1, 1, 1)
        end)
    end)

    --Create arrows images to allow users to control iteration speeds
    local fasterButton = display.newImage("downarrow.png")
    fasterButton.x = display.contentCenterX - 75
    fasterButton.y = display.contentHeight - 73
    fasterButton.xScale = 0.013
    fasterButton.yScale = 0.013
    fasterButton:addEventListener("tap", function()
        changeIterationSpeed(-100)  -- decrease delay by 100ms
    end)
    sceneGroup:insert(fasterButton)
    
    local slowerButton = display.newImage("uparrow.png")
    slowerButton.x = display.contentCenterX + 75
    slowerButton.y = display.contentHeight - 72
    slowerButton.xScale = 0.1
    slowerButton.yScale = 0.1
    slowerButton:addEventListener("tap", function()
        changeIterationSpeed(100)  -- increase delay by 100ms
    end)
    sceneGroup:insert(slowerButton)
    
    --Insert button to allow users to reset the iteration speed
    local resetSpeedButton = display.newText("Reset Speed", display.contentCenterX, display.contentHeight - 65, native.systemFontBold, 16)
    resetSpeedButton:setFillColor(1)
    resetSpeedButton:addEventListener("tap", function()
        iterationSpeed = 500  -- reset to default
        changeIterationSpeed(0)
        resetSpeedButton:setFillColor(1, 0, 0)   
        timer.performWithDelay(500, function()  
            resetSpeedButton:setFillColor(1, 1, 1)
        end)
    end)
    sceneGroup:insert(resetSpeedButton)
    sceneGroup:insert(speedText)

    --Create animations to control buttons to signify to user that they can be pressed
    transition.to(pauseButton, { time=1000, xScale=1.05, yScale=1.05, iterations=-1, transition=easing.continuousLoop, reverse=true })
    transition.to(startButton, { time=1000, xScale=1.05, yScale=1.05, iterations=-1, transition=easing.continuousLoop, reverse=true })
    transition.to(resetButton, { time=1000, xScale=1.05, yScale=1.05, iterations=-1, transition=easing.continuousLoop, reverse=true })

end

scene:addEventListener("create", scene)
updateTimer = timer.performWithDelay(iterationSpeed, update, -1)

return scene
