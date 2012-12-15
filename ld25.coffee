width = 640
height = 480

ctx = null

# Game states
STATE_OVERWORLD = 1

state = STATE_OVERWORLD

on_mouse = (e) ->
  return

on_key = (e) ->
  return

draw_overworld = () ->
  ctx.fillStyle = "black"
  ctx.font = "bold 25px sans-serif"
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

draw = () ->
  switch state
    when STATE_OVERWORLD then draw_overworld()
    else console.log("unknown state=%d", state)

window.init = () ->
  a = document.getElementById('a')
  ctx = a.getContext('2d')
  a.addEventListener("mousedown", on_mouse, false)
  a.addEventListener("mousemove", on_mouse, false)
  a.addEventListener("mouseup", on_mouse, false)
  window.addEventListener('keydown', on_key, false)
  window.addEventListener('keyup', on_key, false)
  draw()
