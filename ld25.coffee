WIDTH = 640
HEIGHT = 480
BS = 8

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

level = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]

deep_array_copy = (a) ->
  ret = new Array
  for i in a
    ret.push(i[..])
  ret

make_damage_array = (a) ->
  ret = new Array
  for i in a
    ret.push((j*500 for j in i))
  ret

class City
  constructor: (level) ->
    @level = deep_array_copy(level)
    @damage = make_damage_array(level)
    console.log(@damage)

  draw: () ->
    ctx.fillStyle = "black"
    for row, y in @level
      for col, x in row
        if col == 1
          ctx.fillRect(x * BS, y * BS, BS, BS)

  take_damage: (x, y, amount) ->
    @damage[y][x] -= amount
    if @damage[y][x] < 0
      @level[y][x] = 0

city = new City(level)

class Unit
  constructor: (@color, @x, @y) ->
    @health = @max_health = 50
    @target = null
    @velocity = 15
    @dir = {x: 0, y: 0}
    @attack_range = 0
    @strength = 10

  draw: () ->
    ctx.fillStyle = @color
    ctx.fillRect(@x, @y, 4, 4)

  _find_target: (city) ->
    min = 999999
    target_x = -1
    target_y = -1
    for row, y in city.level
      for col, x in row
        if col == 1
          tmp_x = x * BS
          tmp_y = y * BS
          distance = Math.pow(@x - tmp_x, 2) + Math.pow(@y - tmp_y, 2)
          if distance < min
            target_x = x
            target_y = y
            min = distance
    @target = {
      x: target_x * BS + BS,
      y: target_y * BS + BS,
      rx: target_x,
      ry: target_y
    }
    rem_x = @target.x - @x
    rem_y = @target.y - @y
    mag = Math.sqrt(rem_x * rem_x + rem_y * rem_y)
    @dir = {x: rem_x / mag, y: rem_y / mag}

  _can_attack_target: () ->
    rem_x = @target.x - @x
    rem_y = @target.y - @y
    dist_squared = rem_x * rem_x + rem_y * rem_y
    return dist_squared < @attack_range

  _attack: (city) ->
    city.take_damage(@target.rx, @target.ry, @strength)

  move: (city) ->
    if @target is null or city.level[@target.ry][@target.rx] == 0
      @_find_target(city)
    if @_can_attack_target()
      @dir.x = @dir.y = 0
      @_attack(city)
    if within(@x, @target.x, @dir.x * @velocity)
      @x = @target.x
      @dir.x = 0
    else
      @x += @dir.x * @velocity
    if within(@y, @target.y, @dir.y * @velocity)
      @y = @target.y
      @dir.y = 0
    else
      @y += @dir.y * @velocity

within = (pos, target_pos, velocity) ->
  return (Math.abs(target_pos - pos) < Math.abs(velocity))

class Orc extends Unit
  constructor: (x, y) ->
    super('#6b6', x, y)

class Werewolf extends Unit
  constructor: (x, y) ->
    super('#66b', x, y)

class Skeleton extends Unit
  constructor: (x, y) ->
    super('#bbb', x, y)
    @attack_range = 1000

rand = (a, b) ->
  Math.floor(Math.random() * (b - a) + a)

class Army
  constructor: () ->
    @orcs = 0
    @werewolves = 0
    @skeletons = 0

  prepare_for_battle: () ->
    [x, y, w, h] = [500, 100, 50, 50]
    @units = new Array
    for i in [0..@orcs]
      @units.push(new Orc(rand(x, x + w), rand(y, y + h)))
    for i in [0..@werewolves]
      @units.push(new Werewolf(rand(x, x + w), rand(y, y + h)))
    for i in [0..@skeletons]
      @units.push(new Skeleton(rand(x, x + w), rand(y, y + h)))

  draw: () ->
    u.draw() for u in @units

  move: (city) ->
    u.move(city) for u in @units

army = new Army
army.orcs = 5
army.werewolves = 5
army.skeletons = 5
army.prepare_for_battle()

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
  ctx.fillStyle = "#bfb"
  ctx.fillRect(0, 0, WIDTH, HEIGHT)
  city.draw()
  army.draw()
  ctx.font = "bold 25px sans-serif"
  ctx.fillStyle = "black"
  ctx.fillText("Day: " + day, 420, 450)

draw = () ->
  ctx.clearRect(0, 0, WIDTH, HEIGHT)
  switch state
    when STATE_OVERWORLD then draw_overworld()
    when STATE_RECRUIT then draw_recruit()
    when STATE_BATTLE then draw_battle()
    else console.log("unknown state=%d", state)

update_battle = () ->
  army.move(city)

update = () ->
  switch state
    when STATE_BATTLE then update_battle()
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
