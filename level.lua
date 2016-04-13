--------------------------------------------------------------------
-- 
-- Level Scene
--
--------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local physics = require("physics");

local GAME;
local UI;

local userMenuButton;
local userSkipButton;
local createGame;
local createBlock;
local calculatePositions;
local spawnBall;
local onBallCollision;
local updateScore;
local checkEndConditions;
local userDragsRacket;

function scene:create( event )

   
end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Hide the status bar
      display.setStatusBar( display.HiddenStatusBar );

      local sceneGroup = self.view;

      -- Create the game object that stores game information
      GAME = {};
      GAME.ongoing = true;
      GAME.level = event.params.levelNumber;
      GAME.score = 100;
      GAME.entities = {};
      GAME.params = {
         missScoreChange = -20,
         hitRedChange = 5
      };
      GAME.blockSequence = {-- Blue, Gray, Red, Yellow
         { name="red", start=3, count=1 },
         { name="blue", start=1, count=1 },
         { name="gray", start=2, count=1 },
         { name="yellow", start=4, count=1 },
      };
      GAME.blockSheetData = {
         width=100, height=100, numFrames=4, sheetContentWidth = 400, sheetContentHeight = 100
      };
      GAME.blockSheet = graphics.newImageSheet( "resources/blocks.png", GAME.blockSheetData);

      -- Set up the user interface
      UI = {};
      UI.group = sceneGroup;

      -- Set up the background image
      UI.background = display.newImageRect( "resources/scene_game.png", 750, 1334);
      UI.background.x = display.contentCenterX;
      UI.background.y = display.contentCenterY;
      sceneGroup:insert( UI.background )

      -- Set up the menu button that returns to the menu
      UI.menuButton = display.newRect(621, 1276, 209, 86);
      UI.menuButton:addEventListener( "tap", userMenuButton );
      UI.menuButton.alpha = 0.01;
      sceneGroup:insert( UI.menuButton );

      -- Set up the skip button that moves to the next level
      UI.skipButton = display.newRect(334, 1276, 302, 86);
      UI.skipButton:addEventListener( "tap", userSkipButton );
      UI.skipButton.alpha = 0.01;
      sceneGroup:insert( UI.skipButton );

      -- Set up the level display text
      UI.levelText = display.newText(GAME.level, 625, 45, "Arial", 56);
      sceneGroup:insert( UI.levelText );

      -- Set up the score display text
      UI.scoreText = display.newText(GAME.score, 225, 45, "Arial", 56);
      UI.scoreText.anchorX = 0;
      sceneGroup:insert( UI.scoreText );

      -- Set up the walls
      UI.walls = {};

      -- Set up the left wall
      UI.walls.left = display.newRect(0, 0, 1, display.contentHeight);
      UI.walls.left.alpha = 0.01;
      UI.walls.left.anchorX = 0;
      UI.walls.left.anchorY = 0;
      sceneGroup:insert(UI.walls.left);

      -- Set up the right wall
      UI.walls.right = display.newRect(display.contentWidth-1, 0, 1, display.contentHeight);
      UI.walls.right.alpha = 0.01;
      UI.walls.right.anchorX = 0;
      UI.walls.right.anchorY = 0;
      sceneGroup:insert(UI.walls.right);

      -- Set up the bottom wall
      UI.walls.bottom = display.newRect(0, display.contentHeight-115, display.contentWidth, 1);
      UI.walls.bottom.alpha = 0.01;
      UI.walls.bottom.anchorX = 0;
      UI.walls.bottom.anchorY = 0;
      UI.walls.bottom.isFloor = true;
      sceneGroup:insert(UI.walls.bottom);

      -- Set up the top wall
      UI.walls.top = display.newRect(0, 0, display.contentWidth, 1);
      UI.walls.top.alpha = 0.01;
      UI.walls.top.anchorX = 0;
      UI.walls.top.anchorY = 0;
      sceneGroup:insert(UI.walls.top);

      -- Set up the racket
      UI.racket = display.newRect(375, 1081, 200, 35 )
      UI.racket:setFillColor( 196/255, 34/255, 34/255 )
      sceneGroup:insert(UI.racket);

      -- Calculate box positions
      if (GAME.level == 2) then
         calculateLevel2Positions();
      else
         calculatePositions();
      end

      -- Create the game objects
      createGame();
   elseif ( phase == "did" ) then
      -- Start the physics engine
      physics.start()

      -- Configure physics engine
      physics.setGravity (0 , 0)

      -- Create the wall physics bodies
      physics.addBody(UI.walls.left, "static");
      physics.addBody(UI.walls.right, "static");
      physics.addBody(UI.walls.bottom, "static");
      physics.addBody(UI.walls.top, "static");
      physics.addBody(UI.racket, "kinematic");

      -- Set up all entity physics bodies
      for x = 1,24 do
         physics.addBody(GAME.entities[x], "static");
      end

      Runtime:addEventListener( "touch", userDragsRacket );
      spawnBall();
   end
end

--------------------------------------------------------------------
-- spawnBall()
-- Create a new ball, after the original hits the floor, or at the
-- start of the game
--------------------------------------------------------------------
function spawnBall()
   -- Create the ball
   local ball = display.newCircle(display.contentCenterX, 800, 20);
   ball:setFillColor(0.7, 0.7, 0.7);

   -- Setup physics
   physics.addBody(ball, "dynamic", {
      bounce = 1
   });
   ball.isFixedRotation = true
   ball:setLinearVelocity(200, 250);
   UI.group:insert(ball);

   -- Setup event listeners
   ball.collision = onBallCollision
   ball:addEventListener( "collision", ball );
   GAME.ball = ball;
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

      --UI.background:removeSelf();
      --UI.menuButton:removeSelf();
      --UI.skipButton:removeSelf();
      --UI.scoreText:removeSelf();
      --UI.levelText:removeSelf();
      --UI.walls.bottom:removeSelf();
      --UI.walls.left:removeSelf();
      --UI.walls.right:removeSelf();
      --UI.walls.top:removeSelf();
      --UI.racket:removeSelf();
      --UI.ball:removeSelf();

      --for i = 1,24 do
         --if (not GAME.entities[i].dead) then
            --GAME.entities[i].dead = true;
            --GAME.entities[i]:removeSelf();
         --end
      --end
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
-- userSkipButton()
-- This is called when the user clicks the skip button
--------------------------------------------------------------------
function userSkipButton(event) 
   -- Destroys the level scene
   composer.removeScene( "level" )

   -- Switches to the level scene
   composer.gotoScene( "level", {
      effect = "fade",
      time = 400,
      params = {
         levelNumber = GAME.level + 1
      }
   })
end

--------------------------------------------------------------------
-- userMenuButton()
-- This is called when the user clicks the go to menu button
--------------------------------------------------------------------
function userMenuButton(event) 
   -- Destroys the level scene
   composer.removeScene( "menu" )

   -- Switches to the level scene
   composer.gotoScene( "menu", {
      effect = "fade",
      time = 400
   })
end

--------------------------------------------------------------------
-- userDragsRacket()
-- This is called when the user drags the racket
--------------------------------------------------------------------
function userDragsRacket( event )
    if event.phase == "began" then
        UI.racket.markX = UI.racket.x    -- store x location of object
        UI.racket.markY = UI.racket.y    -- store y location of object
    elseif event.phase == "moved" then

      if (UI.racket == nil or UI.racket.markX == nil) then
         return
      end

      local x = (event.x - event.xStart) + UI.racket.markX
      --local y = (event.y - event.yStart) + UI.racket.markY
      UI.racket.x = x;   -- move object based on calculations above
    end
    return true
end

--------------------------------------------------------------------
-- onBallCollision()
-- This is called when the ball collides
--------------------------------------------------------------------
function onBallCollision( self, event )
   if ( event.phase == "began" ) then

   elseif ( event.phase == "ended" ) then
      if (GAME.ongoing and event.other == UI.walls.bottom) then
         physics.removeBody(GAME.ball);
         GAME.ball:removeSelf();
         GAME.ball = nil;
         timer.performWithDelay(100, spawnBall);
         GAME.score = GAME.score + GAME.params.missScoreChange;
         updateScore();
         checkEndConditions();
      elseif (event.other.type ~= nil) then
         if (event.other.type == "red") then
            GAME.score = GAME.score + GAME.params.hitRedChange;
            updateScore();
            event.other:removeSelf();
            event.other.dead = true;

            checkEndConditions();
         elseif (event.other.type == "blue") then
            event.other.type = "red";
            event.other:setSequence("red");
         elseif (event.other.type == "yellow") then
            for i = 1,24 do
               if (not GAME.entities[i].dead and GAME.entities[i].type == "red") then
                  GAME.entities[i].type = "blue";
                  GAME.entities[i]:setSequence("blue");
               elseif (not GAME.entities[i].dead and GAME.entities[i].type == "blue") then
                  GAME.entities[i].type = "red";
                  GAME.entities[i]:setSequence("red");
               end
            end
         end
      end
   end
end

--------------------------------------------------------------------
-- createGame()
-- Set up the game
--------------------------------------------------------------------
function createGame()
   local x;
   local y;

   for x=1,6 do
      for y=1,4 do
         createBlock(x,y);
      end
   end

end

--------------------------------------------------------------------
-- calculatePositions()
-- Calculate the positions for levels other than level 2
--------------------------------------------------------------------
function calculatePositions()
   GAME.types = {};
   local grays = {};

   -- Randomly assign each block as either red or blue, randomly. 50/50 odds
   for x=1,6 do
      GAME.types[x] = {};
      for y=1,4 do
         if math.random(1,2) == 1 then
            GAME.types[x][y] = "red"; -- Red
         else
            GAME.types[x][y] = "blue"; -- Blue
         end
      end
   end

   -- Place 5 gray blocks within acceptable rows randomly.
   for i=1,5 do
      local candidateX = 0;
      local candidateY = 0;

      while candidateX == 0 or GAME.types[candidateX][candidateY] == "gray" do
         candidateX = math.random(1,6);
         candidateY = (math.random(0,1) * 2) + 2;
      end

      GAME.types[candidateX][candidateY] = "gray";
      grays[i] = {candidateX, candidateY};
   end

   -- Place the sixth gray block on the same column as a random other gray block. This prevents a case in
   -- which the gray blocks form an unbreakable wall.
   local lastGrayY = 2;
   local grayBeside = 0;
   local found

   -- Find a column that does not already have two blocks on it
   while (grayBeside == 0 or found) do 
      found = false;
      grayBeside = math.random(1,5);

      for i=1,5 do
         if (i ~= grayBeside and grays[grayBeside][1] == grays[i][1]) then
            found = true;
         end
      end
   end

   -- Retreive the object that the sixth block should be beside
   grayBeside = grays[grayBeside];

   -- Set the correct Y value, so that the sixth gray block cannot overrite another gray block.
   if (grayBeside[2] == 2) then lastGrayY = 4 end;

   -- Set the sixth block as gray.
   GAME.types[grayBeside[1]][lastGrayY] = "gray";

   -- Generate the yellow blocks. These must be on the same column as a gray, to ensure that an unbreakable wall is not formed.
   for i=1,2 do
      local candidateX = 0;
      local candidateY = 0;

      while candidateX == 0 or GAME.types[candidateX][candidateY] == "gray" or GAME.types[candidateX][candidateY] == "yellow" do
         candidateX = grays[math.random(1,5)][1]
         candidateY = math.random(1,4);
      end

      GAME.types[candidateX][candidateY] = "yellow";
   end
end

--------------------------------------------------------------------
-- calculateLevel2Positions()
-- Build level 2
--------------------------------------------------------------------
function calculateLevel2Positions()
   GAME.types = {
      {"gray", "yellow", "gray", "gray"},
      {"red", "blue", "blue", "blue"},
      {"yellow", "blue", "yellow", "blue"},
      {"yellow", "blue", "yellow", "blue"},
      {"red", "blue", "blue", "blue"},
      {"gray", "yellow", "gray", "gray"},
   };
end

--------------------------------------------------------------------
-- createBlock()
-- Create a block at the provided position
--------------------------------------------------------------------
function createBlock(x, y)
   local posX = 77 + ((x - 1) * 118);
   local posY = 311 + ((y - 1) * 118);
   local type = GAME.types[x][y];

   local block = display.newSprite(GAME.blockSheet, GAME.blockSequence);
   block.x = posX;
   block.y = posY;
   block.type = type;
   block:setSequence(type);
   block.dead = false;
   table.insert(GAME.entities, block);
   UI.group:insert(block);
end

--------------------------------------------------------------------
-- updateScore()
-- Update the score text as shown
--------------------------------------------------------------------
function updateScore()
   UI.scoreText.text = GAME.score;
end

--------------------------------------------------------------------
-- checkEndConditions()
-- Ends the game if victory has been achieved.
--------------------------------------------------------------------
function checkEndConditions() 
   if (GAME.score <= 0) then
      GAME.ongoing = false;
      userMenuButton();
   else
      local found = false;

      for i=1,24 do
         if (not GAME.entities[i].dead and GAME.entities[i].type ~= "gray" and GAME.entities[i].type ~= "yellow") then
            found = true;
         end
      end

      if (not found) then
         userSkipButton();
      end
   end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene