WIDTH = 640
HEIGHT = 480

canvas = null
ctx = null
interval = -1

# Game states
STATE_OVERWORLD = 1
STATE_RECRUIT = 2
STATE_TRAIN = 3
STATE_BATTLE = 4

state = STATE_BATTLE
day = 1

class City
  constructor: () ->
    @buildings = [
      [10, 10, 8, 8],
      [10, 20, 8, 8],
      [10, 30, 8, 8],
      [10, 40, 8, 8],
      [20, 10, 8, 8],
      [20, 20, 8, 8],
      [20, 30, 8, 8],
      [20, 40, 8, 8],
      [30, 10, 8, 8],
      [30, 20, 8, 8],
      [30, 30, 8, 8],
      [30, 40, 8, 8],
      [40, 10, 8, 8],
      [40, 20, 8, 8],
      [40, 30, 8, 8],
      [10, 50, 28, 8],
      [40, 40, 16, 16],
    ]

  draw: () ->
    ctx.fillStyle = "black"
    for b in @buildings
      [x, y, w, h] = b
      ctx.fillRect(x * 4, y * 4, w * 4, h * 4)

city = new City

class Army
  constructor: () ->
    @orcs = 0
    @werewolves = 0
    @skeletons = 0

army = new Army

get_event_xy = (e) ->
  x = e.pageX - canvas.offsetLeft - canvas.clientLeft
  y = e.pageY - canvas.offsetTop - canvas.clientTop
  [x, y]

handle_mouse_overworld = (x, y) ->
  if 400 < x <= 600 && 40 < y <= 80
    console.log("state change to recruit")
    state = STATE_RECRUIT
  if 400 < x <= 600 && 220 < y <= 260
    console.log("state change to battle")
    city = new City
    state = STATE_BATTLE

handle_mouse_recruit = (x, y) ->
  if 50 < x <= 200 && 50 < y <= 200
    day++
    army.orcs++
    state = STATE_OVERWORLD
  if 250 < x <= 400 && 50 < y <= 200
    day++
    army.werewolves++
    state = STATE_OVERWORLD
  if 450 < x <= 600 && 50 < y <= 200
    day++
    army.skeletons++
    state = STATE_OVERWORLD
  console.log("increased army => ", army)

on_mouse = (e) ->
  [x, y] = get_event_xy(e)
  console.log("x=%d, y=%d", x, y)
  switch state
    when STATE_OVERWORLD then handle_mouse_overworld(x, y)
    when STATE_RECRUIT then handle_mouse_recruit(x, y)
    else console.log("unknown state=%d", state)
  return

on_key = (e) ->
  return

draw_overworld = () ->
  ctx.fillStyle = "black"
  ctx.font = "bold 25px sans-serif"
  ctx.textAlign = "start"
  ctx.textBaseline = "alphabetic"
  ctx.fillRect(400, 40, 200, 40)
  ctx.fillRect(400, 100, 200, 40)
  ctx.fillRect(400, 160, 200, 40)
  ctx.fillRect(400, 220, 200, 40)
  ctx.fillStyle = "white"
  ctx.fillText("Recruit", 420, 70)
  ctx.fillText("Train", 420, 130)
  ctx.fillText("Status", 420, 190)
  ctx.fillText("Go", 420, 250)
  ctx.fillStyle = "black"
  ctx.fillText("Day: " + day, 420, 450)
  ctx.fillText("Orcs: " + army.orcs, 420, 350)
  ctx.fillText("Werewolves: " + army.werewolves, 420, 380)
  ctx.fillText("Skeletons: " + army.skeletons, 420, 410)

draw_recruit_box = (str, pos) ->
  ctx.fillStyle = "black"
  ctx.fillRect(50 + pos * 200, 50, 150, 150)
  ctx.fillStyle = "white"
  ctx.fillText("Recruit", 120 + pos * 200, 70)
  ctx.fillText(str, 120 + pos * 200, 120)

draw_recruit = () ->
  ctx.font = "bold 20px sans-serif"
  ctx.textBaseline = "top"
  ctx.textAlign = "center"
  draw_recruit_box("Orcs", 0)
  draw_recruit_box("Werewolves", 1)
  draw_recruit_box("Skeletons", 2)

draw_battle = () ->
  city.draw()
  ctx.font = "bold 25px sans-serif"
  ctx.fillText("Day: " + day, 420, 450)

draw = () ->
  ctx.clearRect(0, 0, WIDTH, HEIGHT)
  switch state
    when STATE_OVERWORLD then draw_overworld()
    when STATE_RECRUIT then draw_recruit()
    when STATE_BATTLE then draw_battle()
    else console.log("unknown state=%d", state)

update = () ->
  draw()

window.init = () ->
  canvas = document.getElementById('a')
  ctx = canvas.getContext('2d')
  canvas.addEventListener("mousedown", on_mouse, false)
  #canvas.addEventListener("mousemove", on_mouse, false)
  #canvas.addEventListener("mouseup", on_mouse, false)
  window.addEventListener('keydown', on_key, false)
  window.addEventListener('keyup', on_key, false)
  interval = setInterval(update, 50)
