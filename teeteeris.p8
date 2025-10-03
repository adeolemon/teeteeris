pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
i=1 o=2 t=3 l=4 s=5 j=6 z=7

function _init()
 names = { i,o,t,l,s,j,z }
 stats = { 0,0,0,0,0,0,0 }
 lines = 0
 score = 0
 level = 0

 shapes  = init_shapes()
 sprites = init_sprites()
 droplag = init_droplag()

 bag = {}           -- pieces
 nxt = rnd(names)   -- next
 ▒  = init_board() -- board(b)
 …  = spawn()      -- piece(q)

 poke(0x5f5d, 4)  -- "das"
 pal({ [0] = 129 }, 1)

 tick = 0
 game = 'going'
end

function spawn()
 stats[nxt] += 1
 local name = nxt

 if #bag == 0 then -- bag empty
  bag = pack(unpack(names))

  -- shuffle the 7 pieces
  srand(time())
  for i = #bag,1,-1 do
   p=flr(rnd(i))+1

   bag[i], bag[p] =
    bag[p], bag[i]
  end

  -- add a few extra random
  for _ = 1,3 do
   add(bag, rnd(names))
  end
 end

 nxt = deli(bag)

 local x = 4
 local y = 1
 local spin = 0

 for █ in all(shapes[name][spin]) do
  if ▒[y + █.y][x + █.x] then
   game = 'over'
  end
 end

 return {
  x = x,
  y = y,
  name = name,
  spin = spin
 }
end

function move(_)
 local x = ….x + (_.yaw   or 0)
 local y = ….y + (_.pitch or 0)
 local spin = ….spin + (_.roll or 0)

 if (spin < 0) spin = 9
 if (spin > 9) spin = 0

 for █ in all(
  shapes[….name][spin]) do

  if █.x+x < 1  or
     █.x+x > 10 or
     ▒[█.y+y][█.x+x] then

   return
  elseif █.y+y == #▒ or
   ▒[█.y+y+1][█.x+x] then

   return lock(spin, x, y)
  end
 end

 if (….spin != spin) sfx(0)
 if (….x    != x   ) sfx(3)

 ….spin = spin
 ….x = x
 ….y = y

 return true
end

function lock(spin, x, y)
 for █ in all(
  shapes[….name][spin]) do

  ▒[█.y+y][█.x+x] = ….name
 end

 local full = {}
 for y = #▒, 1, -1 do
  if 0 == count(▒[y], false) then
   add(full, y)
  end
 end

 for y in all(full) do
  deli(▒, y)
 end

 if #full > 0 then
  sfx(2)
 else
  sfx(1)
 end

 for _ = 1, #full do
  add(▒, init_line(), 1)
  lines += 1

  if lines > 0 and
   0 == (lines % 10) then

   uplevel()
  end
 end

 … = spawn()
end

function uplevel()
 level  += 1
 droplag = init_droplag()
 sprites = init_sprites()
end

function init_droplag()
 if (0 == level) return 48
 if (1 == level) return 43
 if (2 == level) return 38
 if (3 == level) return 33
 if (4 == level) return 28
 if (5 == level) return 23
 if (6 == level) return 18
 if (7 == level) return 13
 if (8 == level) return 8
 if (9 == level) return 6

 if level >= 10 and
    level <= 12 then
  return 5
 end

 if level >= 13 and
    level <= 15 then
  return 4
 end

 if level >= 16 and
    level <= 18 then
  return 3
 end

 if level >= 19 and
    level <= 28 then
  return 2
 end

 return 1
end

function init_sprites()
 local black  = 0
 local blue   = 1
 local purple = 2
 local green  = 3
 local brown  = 4
 local puke   = 5
 local gray   = 6
 local white  = 7
 local red    = 8
 local orange = 9
 local yellow = 10
 local lime   = 11
 local sky    = 12
 local mauve  = 13
 local pink   = 14
 local tan    = 15

 local colors = {
  [0] = { [puke]   = 131,
          [mauve]  = 140, },

  [1] = { [purple] = 130,
          [green]  = 131,
          [yellow] = 134,
          [lime]   = 136,
          [sky]    = 137, },

  [2] = { [green]  = 139,
          [brown]  = 135,
          [lime]   = 138,
          [mauve]  = 140, },

  [3] = { [purple] = 132,
          [puke]   = 134,
          [red]    = 136,
          [orange] = 139,
          [yellow] = 131,
          [mauve]  = 140, },

  [4] = { [purple] = 130,
          [brown]  = 131,
          [orange] = 139,
          [sky]    = 138,
          [tan]    = 135, },

  [5] = { [purple] = 132,
          [green]  = 137,
          [puke]   = 134,
          [pink]   = 135, },

  [6] = { [puke]   = 134,
          [orange] = 136,
          [yellow] = 130,
          [lime]   = 140 },

  [7] = { [purple] = 130,
          [green]  = 134,
          [sky]    = 135,
          [pink]   = 132, },

  [8] = { [orange] = 130,
          [yellow] = 135,
          [lime]   = 136, }
 }

 pal()
 pal({[0] = 129}, 1)

 local palette = level % 9
 local offset  = (palette * 4)

 pal(colors[palette], 1)

 return {
  [i] = 1 + offset,
  [o] = 2 + offset,
  [t] = 2 + offset,
  [l] = 3 + offset,
  [s] = 3 + offset,
  [j] = 4 + offset,
  [z] = 4 + offset
 }
end

function _draw()
 -- pixel sizes:
 local █_size   = 6
 local ▒_top    = 2
 local ▒_left   = 32
 local ▒_width  = #▒[1] * █_size
 local ▒_height = #▒    * █_size

 cls()

 rectfill(
  ▒_left, ▒_top,
  ▒_left + ▒_width,
  ▒_top  + ▒_height,
  0
 )

 cursor(2, 2, 7)
 ? "lines\n\n" .. lines

 cursor(100, 2, 7)
 ? "next"

 for █ in all(shapes[nxt][0]) do
  spr(
   sprites[nxt],
    100 + (█.x * █_size),
     10 + (█.y * █_size)
  )
 end

 cursor(100, 30, 7)
 ? "level\n"
 ? level

 cursor(2, 30, 7)
 ? "stats\n"
 for n in all(names) do
  local pre = '00'
  local num = stats[n]

  if (num > 009) pre = '0'
  if (num > 090) pre = ''

  ? n .. ' ' .. pre .. num
 end

 for y = 1,#▒ do
  for x = 1,#▒[y] do
   spr(
    48,
    ▒_left + 1 + ((x-1) * █_size),
    ▒_top  + 1 + ((y-1) * █_size)
   )

   if ▒[y][x] then
    spr(
     sprites[▒[y][x]],
     ▒_left + 1 + ((x-1) * 6),
     ▒_top  + 1 + ((y-1) * 6)
    )
   end
  end
 end

 for █ in all(
  shapes[….name][….spin]) do

  spr(
   sprites[….name],
   ▒_left + 1 + ((….x + █.x - 1)*6),
   ▒_top  + 1 + ((….y + █.y - 1)*6)
  )
 end

 rect(
  ▒_left, ▒_top,
  ▒_left + ▒_width,
  ▒_top  + ▒_height,
  6
 )

 if game == 'over' then
  rrectfill(
   40, 36, 45, 15, 2, 7)
  rrect(
   42, 38, 41, 11, 2, 6)

  cursor(45-1, 41, 0)
  ?"game over"

  cursor(45+1, 41, 0)
  ?"game over"

  cursor(45, 41-1, 0)
  ?"game over"

  cursor(45, 41+1, 0)
  ?"game over"

  cursor(45, 41, 7)
  ?"game over"
 end
end

function _update60()
 if (game == 'over') return

 if     btnp(❎) then cw()
 elseif btnp(🅾️) then ccw()
 end

 if     btnp(⬅️) then left()
 elseif btnp(➡️) then right()
 end

 if btn(⬇️) then
  if (0 == tick % 4) down()
 elseif tick >= droplag then
  tick = 0

  down()
 end

 tick += 1
end

function left()
 move({ yaw = -1 })
end

function right()
 move({ yaw = 1 })
end

function down()
 move({ pitch = 1 })
end

function cw()
 move({ roll = 3 })
end

function ccw()
 move({ roll = -3 })
end

function init_board()
 local board = {}

 for col = 1,20 do
  board[col] = init_line()
 end

 return board
end

function init_line()
 local lin = {}
 for col = 1, 10 do
  lin[col] = false
 end

 return lin
end

function init_shapes()
 local tetrominos = {
  [t] = {
   [0] = { { ∧,█    },
           { █,█,█ } },

   [3] = { { ∧,█    },
           { ∧,█,█ },
           { ∧,█    } },

   [6] = { { ∧,∧,∧ },
           { █,█,█ },
           { ∧,█    } },

   [9] = { { ∧,█ },
           { █,█ },
           { ∧,█ } }
  },

  [j] = {
   [0] = { { █       },
           { █,█,█ } },

   [3] = { { ∧,█,█ },
           { ∧,█    },
           { ∧,█    } },

   [6] = { { ∧,∧,∧ },
           { █,█,█ },
           { ∧,∧,█ } },

   [9] = { { ∧,█ },
           { ∧,█ },
           { █,█ } }
  },

  [z] = {
   [0] = { { █,█    },
           { ∧,█,█ } },

   [3] = { { ∧,∧,█ },
           { ∧,█,█ },
           { ∧,█    } }
  },

  [o] = {
   [0] = { { █,█ },
           { █,█ } }
  },

  [s] = {
   [0] = { { ∧,█,█ },
           { █,█    } },

   [3] = { { █,∧ },
           { █,█ },
           { ∧,█ } }
  },

  [l] = {
   [0] = { { ∧,∧,█ },
           { █,█,█ } },

   [3] = { { ∧,█    },
           { ∧,█    },
           { ∧,█,█ } },

   [6] = { { ∧,∧,∧ },
           { █,█,█ },
           { █       } },

   [9] = { { █,█ },
           { ∧,█ },
           { ∧,█ } }
  },

  [i] = {
   [0] = { { █,█,█,█ } },

   [3] = { { ∧,█ },
           { ∧,█ },
           { ∧,█ },
           { ∧,█ } },
  }
 }

 local shapes = {}
 for n in all(names) do
  shapes[n] = shapes[n] or {}

  local shp = tetrominos[n]
  shp[3] = shp[3] or shp[0]
  shp[6] = shp[6] or shp[0]
  shp[9] = shp[9] or shp[3]

  for spin in all({ 0,3,6,9 }) do
   local rows = shp[spin]

   shapes[n][spin] =
    shapes[n][spin] or {}

   for y, row in pairs(rows) do
    for x, char in pairs(row) do
     if char == █ then
      add(shapes[n][spin], {
       y = y-1,
       x = x-1
      })
     end
    end
   end
  end
 end

 return shapes
end

__gfx__
00000000888882009999940033333500ddddd50033333200ddddd200ccccc400bbbbb200bbbbb300cccccd00aaaaa900eeeee80044444200ddddda0033333a00
0000000087fe820097af940037ab3500d76cd50036a53200d76ad200c7f9c400b7e8b200b74ab300c7f6cd00a74fa900e74fe80047f54200d76cda0037b93a00
000000008fe882009af994003ab33500d6cdd5003a533200d6add200cf9cc400be8bb200b4abb300cf6ccd00a4faa900e4fee8004f544200d6cdda003b933a00
000000008e8882009f9994003b333500dcddd50035333200daddd200c9ccc400b8bbb200babbb300c6cccd00afaaa900efeee80045444200dcddda0039333a00
00000000888882009999940033333500ddddd50033333200ddddd200ccccc400bbbbb200bbbbb300cccccd00aaaaa900eeeee80044444200ddddda0033333a00
00000000222222004444440055555500555555002222220022222200444444002222220033333300dddddd00999999008888880022222200aaaaaa00aaaaaa00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888820044444200bbbbb30033333400ccccc900444442003333320099999400aaaaa90022222a00bbbbba00ddddda00cccccb009999940033333e0044444e00
87fe820047654200b7fcb30037b93400c7fac90047f5420037f9320097ef9400a7efa90027892a00b76cba00d765da00c7f6cb0097af940037c63e0047f34e00
8fe8820046544200bfcbb3003b933400cfacc9004f5442003f9332009ef99400aefaa90028922a00b6cbba00d65dda00cf6ccb009af994003c633e004f344e00
8e88820045444200bcbbb30039333400caccc90045444200393332009f999400afaaa90029222a00bcbbba00d5ddda00c6cccb009f99940036333e0043444e00
8888820044444200bbbbb30033333400ccccc900444442003333320099999400aaaaa90022222a00bbbbba00ddddda00cccccb009999940033333e0044444e00
222222002222220033333300444444009999990022222200222222004444440099999900aaaaaa00aaaaaa00aaaaaa00bbbbbb0044444400eeeeee00eeeeee00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555520022222900bbbbb20088888200eeeeeb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
57635200278b2900b7e8b20087fe8200e7afeb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5635520028b22900be8bb2008fe88200eafeeb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
535552002b222900b8bbb2008e888200efeeeb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555520022222900bbbbb20088888200eeeeeb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222200999999002222220022222200bbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000017500275003750047500575007750097500c7501075013750177501c7502175025750297502b7502c7502e7502c7502475021750187500c75009750097500b75011750177501c750247502b75030750
000100002975024750207501d7501c7501b7501b7501b7501b7501d7501f7502275024750247502475024750227501e7501a7501975019750197501b7501d7501d7501d7501c75019750137500f7500b75005750
0001000019750197501d750217502575029750307502c750247501c750187501575018750207502a7502f7502d7502a75026750227502275024750297502b7502b7502975026750227501e7501a7501775014750
00010000001003c150001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000100000105005050090500e05012050130501705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
