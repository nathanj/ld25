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

state = STATE_RECRUIT
day = 1

class Army
  constructor: () ->
    @orcs = 0
    @werewolves = 0
    @skeletons = 0

get_event_xy = (e) ->
  x = e.pageX - canvas.offsetLeft - canvas.clientLeft
  y = e.pageY - canvas.offsetTop - canvas.clientTop
  [x, y]

on_mouse = (e) ->
  [x, y] = get_event_xy(e)
  console.log("x=%d, y=%d", x, y)
  if 400 < x <= 600 && 40 < y <= 80
    console.log("state change to recruit")
    state = STATE_RECRUIT
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
  ctx.fillText("Day:   1", 420, 450)

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

draw = () ->
  ctx.clearRect(0, 0, WIDTH, HEIGHT)
  switch state
    when STATE_OVERWORLD then draw_overworld()
    when STATE_RECRUIT then draw_recruit()
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
