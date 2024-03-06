local composer = require( "composer" )
local scene = composer.newScene()

--Set Audio Sounds
local buttonAudio = audio.loadSound("button.mp3")
local ambientSound = audio.loadStream("ambient.mp3")

--Set Button Dimensions
local btnWidth = 250
local btnHeight = 50



function scene:create(event)
    local sceneGroup = self.view

    --Set Grid Size
    composer.setVariable("gridSize", nil)

    --Use for testing
    print("User choice set to:", userChoice)

    --Create Title
    local title = display.newText("Conway's Game of Life", display.contentCenterX, 10, native.systemFontBold, 28)
    sceneGroup:insert(title)

    --Create Random Start Button
    local randomButton = display.newRect(display.contentCenterX, display.contentCenterY - 50, btnWidth, btnHeight)
    randomButton:setFillColor(0.2) 
    randomButton.strokeWidth = 3
    randomButton:setStrokeColor(0.4)
    sceneGroup:insert(randomButton)
    local randomTxt = display.newText("Random Start", display.contentCenterX, display.contentCenterY - 50, native.systemFontBold, 23)
    randomButton:addEventListener("tap", function()
        audio.play(buttonAudio)
        userChoice = "random"
        composer.gotoScene("gridSizeSelection")
    end)
    sceneGroup:insert(randomTxt)

    --Create User Input Start Button
    local userButton = display.newRect(display.contentCenterX, display.contentCenterY + 50, btnWidth, btnHeight)
    userButton:setFillColor(0.2) 
    userButton.strokeWidth = 3
    userButton:setStrokeColor(0.4)
    sceneGroup:insert(userButton)
    local userInputTxt = display.newText("User Input Start", display.contentCenterX, display.contentCenterY + 50, native.systemFontBold, 23)
    userButton:addEventListener("tap", function()
        audio.play(buttonAudio)
        userChoice = "userInput"
        composer.gotoScene("gridSizeSelection")
    end)
    sceneGroup:insert(userInputTxt)

    --Create Developer Text
    local developer = display.newText("Developed By: Nicholas Foti", display.contentCenterX, 400, native.systemFontBold, 15)
    sceneGroup:insert(developer)
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    --Add Ambient Music
    if phase == "did" then
        audio.play(ambientSound, {loops = -1})
        audio.setVolume(0.3)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene