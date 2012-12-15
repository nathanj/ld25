width = 640
height = 480

ctx = null

on_mouse = (e) ->
  return

on_key = (e) ->
  return

draw = (e) ->
  ctx.font = "bold 25px sans-serif"
  ctx.fillText("It begins", 50, 50)

window.init = () ->
  a = document.getElementById('a')
  ctx = a.getContext('2d')
  a.addEventListener("mousedown", on_mouse, false)
  a.addEventListener("mousemove", on_mouse, false)
  a.addEventListener("mouseup", on_mouse, false)
  window.addEventListener('keydown', on_key, false)
  window.addEventListener('keyup', on_key, false)
  draw()
