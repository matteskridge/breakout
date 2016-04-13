--------------------------------------------------------------------
-- 
-- Begin Scene :: Show the main menu
--
--------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local startButtonPressed

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )

   -- Hide the status bar
   display.setStatusBar( display.HiddenStatusBar );

   local sceneGroup = self.view

   -- Set up the background image
   local background = display.newImageRect( "resources/scene_title.png", 750, 1334);
   background.x = display.contentCenterX;
   background.y = display.contentCenterY;
   sceneGroup:insert( background )

   -- Define the click box for the start button
   local start = display.newRect(375, 1240, 596, 130);
   start:addEventListener( "tap", startButtonPressed );
   start.alpha = 0.01;
   sceneGroup:insert( start );
end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
   end
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

--------------------------------------------------------------------
-- 
-- User Interactions
--
--------------------------------------------------------------------

--------------------------------------------------------------------
-- startButtonPressed(event) 
-- Starts the game
--------------------------------------------------------------------
function startButtonPressed(event) 
   -- Destroys the level scene
   composer.removeScene( "level" )

   -- Switches to the level scene
   composer.gotoScene( "level", {
      effect = "fade",
      time = 400,
      params = {
         levelNumber = 1
      }
   })
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene