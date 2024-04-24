-- Calvin Lee
-- calvinnleeee@gmail.com

-- Flappy Bird game, coding tutorial for practice
-- https://love2d.org/wiki for documentation.

-- In the window, the bird stays in the same x-position, and changes y-position to simulate
--    gravity and flying.
-- Pipes with a specific width and empty space height move from right to left.
-- Any key press makes the bird flap, changing its vertical velocity to a high number.
-- Maximum 2 pipes on the screen at any time. When it scrolls to the left, a new 'empty space' position
--    is given and its x-position is reset to the right.
-- The bird is a 3x2 rectangle (?)

record = 0

function love.load()
  scale = 2   -- scale factor for sizing, since the tutorial makes a small window
  windowWidth = 300 * scale
  windowHeight = 388 * scale
  love.window.setMode(windowWidth, windowHeight)
  love.window.setTitle('Really basic flappy bird')

  -- set bird's initial y-position (from its topleft edge), and other parameters
  birdX = 62 * scale
  birdWidth = 30 * scale
  birdHeight = 25 * scale

  -- initial pipe parameters
  pipeWidth = 54 * scale
  pipeSpaceHeight = 100 * scale

  -- function to get a random starting height for the empty space in a pipe
  function newPipeSpaceY()
    local pipeSpaceYMin = 54 * scale    -- minimum distance from the top/bottom
    local pipeSpaceY = love.math.random(pipeSpaceYMin, windowHeight - pipeSpaceHeight - pipeSpaceYMin)
    
    return pipeSpaceY
  end

  -- reset some initial parameters, also called when bird dies
  function reset()
    birdY = 200 * scale
    birdYSpeed = 0

    pipe1X = windowWidth
    pipe1SpaceY = newPipeSpaceY()

    pipe2X = windowWidth + ((windowWidth + pipeWidth) / 2)
    pipe2SpaceY = newPipeSpaceY()

    score = 0
    upcomingPipe = 1    -- the first pipe is incoming, toggles between 1 and 2 as the score increments
  end
  reset()
end

function love.update(dt)
  -- update score
  local function updateScore(thisPipe, pipeX, otherPipe)
    if upcomingPipe == thisPipe and (birdX > (pipeX + pipeWidth)) then
      score = score + 1
      upcomingPipe = otherPipe
    end
  end
  updateScore(1, pipe1X, 2)
  updateScore(2, pipe2X, 1)

  birdYSpeed = birdYSpeed + (516 * dt * scale)
  birdY = birdY + (birdYSpeed * dt)

  -- if left edge of bird is to left of right edge of pipe
  -- and right edge of bird is to right of left edge of pipe
  -- and top edge of bird is above bottom edge of top pipe segment
  -- or bottom edge of bird is below top edge of bottom pipe segment
  -- then restart the game
  function collisionCheck(pipeX, pipeSpaceY)
    return (birdX < (pipeX + pipeWidth)) and ((birdX + birdWidth) > pipeX) and 
      ((birdY < pipeSpaceY) or ((birdY + birdHeight) > (pipeSpaceY + pipeSpaceHeight)))
  end

  -- restart game if collided with one of the pipes or if bird fell out of bounds
  if collisionCheck(pipe1X, pipe1SpaceY)
  or collisionCheck(pipe2X, pipe2SpaceY) 
  or birdY > windowHeight then
    if (score > record) then
      record = score
    end
    reset()
  end

  local function movePipe(pipeX, pipeSpaceY)
    pipeX = pipeX - (60 * dt * scale)
    if (pipeX + pipeWidth) < 0 then
      pipeX = windowWidth
      pipeSpaceY = newPipeSpaceY()
    end
    return pipeX, pipeSpaceY
  end

  pipe1X, pipe1SpaceY = movePipe(pipe1X, pipe1SpaceY)
  pipe2X, pipe2SpaceY = movePipe(pipe2X, pipe2SpaceY)
end

function love.draw()
  -- Drawing the background
  love.graphics.setColor(.14, .36, .46)
  love.graphics.rectangle('fill', 0, 0, windowWidth, windowHeight)

  -- Drawing the pipes
  local function drawPipe(pipeX, pipeSpaceY)
    love.graphics.setColor(.37, .82, .28)
    love.graphics.rectangle(
      'fill', pipeX, 0, pipeWidth, pipeSpaceY)
    love.graphics.rectangle(
      'fill', 
      pipeX, 
      pipeSpaceY + pipeSpaceHeight, 
      pipeWidth, windowHeight - pipeSpaceY - pipeSpaceHeight
    )
  end
  drawPipe(pipe1X, pipe1SpaceY)
  drawPipe(pipe2X, pipe2SpaceY)

  -- Drawing the bird
  love.graphics.setColor(.87, .84, .27)
  love.graphics.rectangle('fill', birdX, birdY, birdWidth, birdHeight)

  -- Print the current session record and current score
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(
    'Current session record: '..record..'\nCurrent score: '..score, 10, 10, 0
  )
end

-- flapping, can only flap if top edge of bird is not above the playing area
function love.keypressed(key)
  if birdY > 0 then
    birdYSpeed = -165 * scale  
  end
end