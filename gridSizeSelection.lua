local composer = require( "composer" )
local scene = composer.newScene()

--Set button dimensions
local btnWidth = 100
local btnHeight = 40

function scene:create(event)
    local sceneGroup = self.view

    --Use for testing
    print("User choice set to:", userChoice)

    --Add Background
    local background = display.newImageRect("background.jpg", display.actualContentWidth, display.actualContentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)

    --Create Page Title (direct user what to do)
    local title = display.newText("Choose Grid Size", display.contentCenterX, display.contentCenterY - 100, native.systemFont, 24)
    title:setFillColor(1)
    sceneGroup:insert(title)

    --Create 200x200 Grid button
    local bigGridBtn = display.newRect(display.contentCenterX, display.contentCenterY, btnWidth, btnHeight)
    bigGridBtn:setFillColor(0.2) 
    bigGridBtn.strokeWidth = 3
    bigGridBtn:setStrokeColor(0.4)
    sceneGroup:insert(bigGridBtn)
    local bigGridTxt = display.newText("200x200", display.contentCenterX, display.contentCenterY, native.systemFont, 24)
    bigGridTxt:setFillColor(1)

    --Set the gridSize variable to 200 for the next scene
    bigGridBtn:addEventListener("tap", function()
        composer.setVariable("gridSize", 200)

        --Send the user to the corresponding Start State according to their main menu choice
        if userChoice == "random" then
            composer.removeScene("randomGrid")
            composer.gotoScene("randomGrid")
        elseif userChoice == "userInput" then
            composer.removeScene("userInputGrid")
            composer.gotoScene("userInputGrid")
        end
    end)
    sceneGroup:insert(bigGridTxt)

    --Create 25x25 Grid button
    local smallGridBtn = display.newRect(display.contentCenterX, display.contentCenterY + 50, btnWidth, btnHeight)
    smallGridBtn:setFillColor(0.2) 
    smallGridBtn.strokeWidth = 3
    smallGridBtn:setStrokeColor(0.4)
    sceneGroup:insert(smallGridBtn)
    local smallGridTxt = display.newText("25x25", display.contentCenterX, display.contentCenterY + 50, native.systemFont, 24)
    smallGridTxt:setFillColor(1)

    --Set the gridSize variable to 25 for the next scene
    smallGridTxt:addEventListener("tap", function()
        composer.setVariable("gridSize", 25)

        --Send the user to the corresponding Start State according to their main menu choicethe 
        if userChoice == "random" then
            composer.gotoScene("randomGrid")
        elseif userChoice == "userInput" then
            composer.gotoScene("userInputGrid")
        end
    end)
    sceneGroup:insert(smallGridTxt)
end

scene:addEventListener("create", scene)

return scene