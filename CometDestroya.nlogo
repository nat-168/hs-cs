;Team *insert crying laughing cat emoji here*
;Anisa Palevic
;River Strumwasser
;IntroCS pd5
;Spring 2020

globals
[
  time
  score
  level
  lives
  life-gain-score
  life-gain-num
  lifelossneed
  gameover
]



turtles-own
[
  tipo
  ;tipo 1 = ship
  ;tipo 2 = lazer
  ;tipo 3 = large asteroid
  ;tipo 4 = medium asteroid
  ;tipo 5 = small asteroid
  ;tipo 6 = UFOs
  ;tipo 7 = UFO bullets

  bullet_distance
  asteroid_speed
  life_wait

  ltur
  rtur
  thrust
  thrust_dec

  ufo_ltr
]



to setup
  ca
  set time 0
  set score 0
  set lives 3
  ask patch 14 14 [set plabel "Time:"]
  ask patch 14 10 [set plabel "Score:"]
  ask patch -11 14 [set plabel "Level:"]
  ask patch -11 10 [set plabel "Lives:"]
  ask patches with [abs pxcor = 16 or abs pycor = 16] [set pcolor 13]
  labeltime
  labelscore
  labellives
  setup-ship
  cr_asteroids
  labellevel
end



to go
  if gameover != 1
  [
    ;TIMER
    every 1
    [
      set time time + 1

      labeltime

      if count turtles with [tipo >= 3 or 6 <= tipo] = 0
      [
        cr_asteroids
      ]
    ]
    ;SCORE
    every .02 [labelscore]

    ;ASTERIOD MOVEMENT
    every 0.02
    [
      ask turtles with [tipo >= 3 and tipo <= 5] [fd .07 + (.003 * level) + 0.01 * asteroid_speed]
    ]

    ;BULLET MOVEMENT
    every 0.01
    [
      ask turtles
      [
        if tipo = 2 or tipo = 7
        [
          ifelse bullet_distance > 0
          [
            fd .13 + .003 * level
            set bullet_distance bullet_distance - (.12 + .003 * level)
          ]
          [
            die
          ]
        ]
      ]
    ]

    ;COLLISIONS
    collide_if

    ;GAINING LIVES
    every 1
    [
      set life-gain-score score - (10000 * life-gain-num)
      lifegain
    ]

    ;SHIP DEATH
    every .01
    [
      ;shipdeath
      if lifelossneed = 1 [lifeloss_pro]
      set lifelossneed 0
    ]


    ;RESPAWN
    every .4 [
      if lives != 0 [
        ask turtle 0 [
          ifelse life_wait > 0
          [
            set life_wait life_wait - .4
          ]
          [
            if life_wait < 0
            [
              set color white
              set life_wait 0
            ]
          ]
        ]
      ]
    ]

    ;SMOOTH ROTATION
    every .004
    [

      ask turtles with [tipo = 1]
      [
        if ltur > 0 and life_wait = 0
        [
          lt 1
          set ltur ltur - 1
        ]
        if rtur > 0 and life_wait = 0
        [
          rt 1
          set rtur rtur - 1
        ]
      ]
    ]

    ;SMOOTH THRUST
    every .03
    [
      ask turtles with [tipo = 1]
      [
        if life_wait = 0
        [
          ifelse thrust > 0.004
          [
            fd thrust_dec + 0.01 * thrust
            set thrust thrust - thrust_dec
            set thrust_dec thrust_dec * (0.95 + thrust / 5000)
          ]
          [
            set thrust 0
            set thrust_dec .5
          ]
          if thrust_dec < .0001
          [
          set thrust 0
          set thrust_dec .5
          ]

          ;HYPERSPACE
          if thrust > 70
          [
            ask turtle 0
            [
              setxy random 33 random 33
              set heading random 360
            ]
            ask turtle 1
            [
              setxy [xcor] of turtle 0 [ycor] of turtle 0
              set heading [heading] of turtle 0
            ]
            set thrust 0
            set thrust_dec .5
          ]
        ]
      ]
    ]

    ;CREATE UFOS
    every 10
    [
      if random 3 = 0 and count turtles with [tipo = 6] = 0
      [
        crt_ufo
      ]
    ]

    ;UFOS SHOOT
    every 1
    [
      ask turtles with [tipo = 6]
      [
        ufo_shoot
      ]
    ]

    ;UFOS MOVE
    ufo_move

    ;UFOS KILL
    every .01
    [
      ufo_bullet
    ]

    ;UFOS ASTEROID COLLISION
    every .01
    [
      ufo_ast_collide
    ]
  ]
end



to setup-ship
  crt 1 [set size 3 set color white]
  crt 1 [set size 2.3 set color black]
  ask turtles with [tipo = 0]
  [
    set heading 0
    set tipo 1
    set thrust_dec .5
  ]
end



to cr_asteroids
  crt random 3 + 2 [

    if tipo = 0
    [
      set tipo 3
      set size 3
      set color 35
      set shape "circle"
      setxy ([xcor] of turtle 0 + 5 + random 23) ([ycor] of turtle 0 + 5 + random 23)
      set asteroid_speed random 3 + 1
    ]
  ]
  set level level + 1
  labellevel
end



to labeltime
  ask patch 14 12
  [
    set plabel time
  ]
end



to labelscore
  ask patch 14 8
  [
    set plabel score
  ]
end



to labellevel
  ask patches with [pycor = 12 and (pxcor >= -14 and pxcor <= 0)]
  [
    set plabel ""
  ]

  ask patch (-14 + 0.87 * (log level 10 - remainder (log level 10) 1)) 12
  [
    set plabel level
  ]
end



to labellives
  ask patches with [pycor = 8 and (pxcor >= -14 and pxcor <= 0)]
  [
    set plabel ""
  ]

  ask patch (-14 + 0.87 * (log lives 10 - remainder (log lives 10) 1)) 8
  [
    set plabel lives
  ]
end



to move
  if gameover = 0
  [
    if [life_wait] of turtle 0 = 0
    [
      ask turtles with [tipo = 1]
      [
        set thrust thrust + 5
        set thrust_dec .5
      ]
    ]
  ]
end



to leftmv
  if gameover = 0
  [
    if [life_wait] of turtle 0 = 0
    [
      ask turtles with [tipo = 1]
      [
        set ltur 20
      ]
    ]
  ]
end



to rightmv
  if gameover = 0
  [
    if [life_wait] of turtle 0 = 0
    [
      ask turtles with [tipo = 1]
      [
        set rtur 20
      ]
    ]
  ]
end



to shoot
  if gameover = 0
  [
    if [life_wait] of turtle 0 = 0
    [
      crt 1
      [
        set color white
        set shape "bullet"
        setxy [xcor] of turtle 0 [ycor] of turtle 0
        set heading [heading] of turtle 0
        set tipo 2
        set bullet_distance 25
      ]
    ]
  ]
end



to collide_if
  ask turtles with [tipo >= 3 and tipo <= 6]
  [
    if count turtles in-radius (size / 2) with [tipo = 2] > 0
    [
      collide_score_death
    ]
    if count turtles in-radius (size / 2) with [tipo = 7] > 0 and tipo != 6
    [
      collide_score_death
    ]
    if count turtles in-radius (size / 2 + 0.5) with [tipo = 1] > 0
    and [life_wait] of turtle 0 = 0
    [
      collide_score_death
    ]
  ]
end



to collide_score_death
  ;SCORING

  if count turtles in-radius (size / 2) with [tipo = 2] > 0
  [
    if tipo = 3
    [
      set score score + 20
    ]

    if tipo = 4
    [
      set score score + 50
    ]

    if tipo = 5
    [
      set score score + 100
    ]

    if tipo = 6 and size = 3
    [
      set score score + 500
    ]

    if tipo = 6 and size = 2
    [
      set score score + 1000
    ]
  ]

  ;DEATH

  ask turtles in-radius (size / 2) with [tipo = 2 or tipo = 7]
  [
    die
  ]

  ask turtles in-radius (size / 2 + 0.5) with [tipo = 1]
  [
    set lifelossneed 1
  ]

  if tipo = 5
  [
    die
  ]

  if tipo = 4
  [
    set size 1
    set tipo 5
    hatch 1 [random_ast_reset]
  ]

  if tipo = 3
  [
    set size 2
    set tipo 4
    hatch 1 [random_ast_reset]
  ]

  if tipo = 6
  [
    die
  ]
end


to lifegain
  if life-gain-score >= 10000
  [
    set life-gain-score score mod 10000
    set lives lives + 1
    set life-gain-num life-gain-num + 1
    labellives
  ]
end



to random_ast_reset
  set heading random 360
  set asteroid_speed (random 3 + 1)
end



to lifeloss_pro
  set lives (lives - 1)
  ifelse lives = 0
  [
    gameover_c
  ]
  [
    labellives
    ask turtles with [tipo = 1]
      [
        setxy 0 0
        set heading 0
        set thrust 0
        set thrust_dec 0.5
        set ltur 0
        set rtur 0
      ]
    ask turtle 0
    [
      set color 4
      set life_wait 1.5
    ]
  ]
end



to gameover_c
  set gameover 1
  ask turtles [die]
  ask patches [set pcolor black]
  ask patches [set plabel-color black]
  ask patch 4 14 [
    set plabel-color white
    set plabel "Game Over"
  ]
  ask patch 14 10 [
    set plabel-color white
    set plabel (word "Time Survived: " time)
  ]
  ask patch 14 6 [
    set plabel-color white
    set plabel (word "Final Score: " score)
  ]
  ask patch 14 2 [
    set plabel-color white
    set plabel (word "Final Level: " level)
  ]
end



to crt_ufo
  crt 1
  [
    set tipo 6
    set size 2 + random 2
    set color 105
    set shape "ufo"
    set xcor 14.5
    set heading 270
    if random 2 = 0
    [
      set xcor 0 - xcor
      set ufo_ltr 1
      rt 180
    ]
    set ycor 10 - random 21
  ]
end



to ufo_shoot
  if [life_wait] of turtle 0 = 0
  [
    hatch 1
    [
      set shape "bullet"
      set tipo 7
      set color 106
      set bullet_distance 20

      ifelse size = 2
      [
        set heading towards turtle 0 + 25 - random 51
      ]
      [
        set heading towards turtle 0 + 100 - random 201
      ]

      set size 1
    ]
  ]
end



to ufo_move
  every 0.01
  [
    ask turtles with [tipo = 6]
    [
      ifelse ufo_ltr = 0 and xcor < -14.5
      [
        die
      ]
      [
        ifelse ufo_ltr = 1 and xcor > 14.5
        [
          die
        ]
        [
          fd .07 + .003 * level
        ]
      ]
    ]
  ]
  every 1.5
    [
      ask turtles with [tipo = 6]
      [
        set heading -45 - 45 * random 3 + ufo_ltr * 180
      ]
  ]
end



to ufo_bullet
  ask turtles with [tipo = 7]
  [
    if count turtles in-radius 1.2 with [tipo = 1] > 0 and [life_wait] of turtle 0 = 0
    [
      set lifelossneed 1
      die
    ]
  ]
end



to ufo_ast_collide
  ask turtles with [tipo >= 3 and tipo <= 5]
  [
    if count turtles in-radius (size / 2 + 0.5)  with [tipo = 6] > 0
    [
      ask turtles in-radius (size / 2 + 0.5) with [tipo = 6]
      [
        die
      ]
      if tipo = 5
      [
        die
      ]

      if tipo = 4
      [
        set size 1
        set tipo 5
        hatch 1 [random_ast_reset]
      ]

      if tipo = 3
      [
        set size 2
        set tipo 4
        hatch 1 [random_ast_reset]
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
20
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
64
107
130
140
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
64
66
130
99
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
29
247
95
280
left
leftmv
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
102
247
168
280
right
rightmv
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
66
207
131
240
NIL
move
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
65
303
132
336
NIL
shoot
NIL
1
T
OBSERVER
NIL
Q
NIL
NIL
1

@#$#@#$#@
### WHO WE ARE

Team *insert crying laughing cat emoji here*
Anisa Palevic
River Strumwasser
IntroCS pd5
Spring 2020

### WHAT IS IT?

Our model is a replica of the Atari Asteroids Arcade game.

In the game, the player controls a ship that can move, turn, and shoot and destroy asteroids with bullets, which causes the asteroids to split, and the player gets points for doing such. A large asteroid earns a player 20 points, a medium-sized one earns 50, and a small one earns 100. Asteroids move at different, constant rates and directions. If the player is moving too fast, they enter hyperspace, causing their direction and position to be randomly set.

UFOs have a 1/3 chance of spawning every 10 seconds. They move across the world, and shoot bullets. There are 2 variations of UFOs. Larger ones aren't very accurate with their shots, and award 500 points when shot by the player. Smaller ones are very accurate, and earn 1,000 points.

If an asteroid or a UFO's bullet hits the ship, the player loses a life. The game ends when the player reaches 0 lives. Every time the player earns 10,000 points, the player gains a life.

There are a few features in our model that aren’t in the original Asteroids game. There's a level counter based on how many times the user has cleared the screen, and a timer showing how long the user has been playing the game for. The games speed increases with level.

The player's movement is also unlike the original game's. Thrust sets how far forward the player moves in the direction faced, rather than in the direction of the ship when thrust was applied.

### HOW IT WORKS

Our inital programming step was to set up a base user interface, visual world setup, and movement functions for the ship, and its setup. Our next steps were to add variables, and then asteroids and their movements, as well as a shooting function. We then began working on how to have turtles react to collisions, starting with those between bullets and asteroids. 

We then added a game over function, and lastly UFOs and their bullets. We spent a long time testing out the game and adding small touch-ups, like making movement smoother and stopping UFOs from shooting if the ship is dead/reviving.

We used global variables - variables that can be accessed and changed in any context - to define time, score, level, user death and game ending, and addition of lives every 10,000 points.

Distinct turtle types are categorized with the turtle variable *tipo*. This separates out ships, which are tipo = 1, from UFOs, which are tipo = 6, and so on.

The *word* command allows patch labels to join strings together, as well as convert numbers to strings, which we use on our game over screen. For example, we have a patch label that says "Time Survived: "time".

New asteroids are created with the *hatch* command, which duplicates a turtle. This is great for creating a copy of a newly set smaller asteroid, when one large one is split into two.

UFOs shoot in a range of possibly varied headings from the direction of the player's ship, which is found with the *towards* command. Large UFOs shoot + or - 100 degrees from the ship, and small ones shoot 25. 

Collisions between turtles are hard to program in NetLogo, since there's no command for turtles overlapping. Our solution to this is using the *in-radius* command. It allows for turtles to see how many others are within a radius of its center, which is perfect for circular asteroids. It's not perfect for the irregular shapes of other turtles, but essentially works, and is better than other options, like the patch of the center of the turtle.

### HOW TO USE IT

The user should follow the gameplay instructions written in the *WHAT IS IT?* tab to survive as long as possible, and get to the highest score and level possible.

**Setup** sets the game up for a new round.
**Go** starts the game.
**Move** adds thrust to the ship, moving it forward. Its hotkey is W.
**Left** turns the ship to the left. Its hotkey is A.
**Right** turns the ship to the right. Its hotkey is D.
**Shoot** shoots a bullet from the ship. Its hotkey is Q.

### CREDITS AND REFERENCES

T. Mykolyk's Intro CompSci Class

Asteroids Game (Mechanics)
https://www.echalk.co.uk/amusements/Games/asteroidsClassic/ateroids.html

Asteroids Description
https://en.wikipedia.org/wiki/Asteroids_(video_game)#Gameplay

Global Variables - Mr. Brooks's Video "Variables"
https://www.youtube.com/watch?v=1DWSDSL_z_o

Hatch Functionality for Duplicating Turtles
https://stackoverflow.com/questions/33546462/in-netlogo-what-is-the-most-efficient-way-to-copy-the-values-of-variables-in-an

Turtles-on, found by searching "Turtles on Nearby Patches NetLogo" in Google.
http://ccl.northwestern.edu/netlogo/docs/dict/turtles-on.html

Turtles-here, found by searching "Turtles-on with" in Google.
https://stackoverflow.com/questions/43613786/how-can-i-use-turtle-sets-with-turtles-on-keyword-in-netlogo

Note: Neither turtles-X command made it into the final version.

Word, found by searching "Netlogo convert to string" and "Netlogo add strings together"
https://ccl.northwestern.edu/netlogo/docs/transition.html#adding-strings-and-lists

Towards, found by searching "Netlogo make a turtle look at another" and scrolling down.
http://ccl.northwestern.edu/netlogo/docs/dict/towards.html

In-Radius, found while exploring Semoi Khan's final projects.

GasLab (Collision Mechanics)
Wilensky, U. (1997). NetLogo GasLab Single Collision model. http://ccl.northwestern.edu/netlogo/models/GasLabSingleCollision. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

NetLogo Programming Guide - https://ccl.northwestern.edu/netlogo/docs/programming.html

NetLogo Dictionary - https://ccl.northwestern.edu/netlogo/docs/dictionary.html

Stuart Strumwasser (River's Dad) reccomended the game as a model to build.

Charity, Kindness, and Support from Duckies Billiam and Gerald

### DEVELOPMENT LOG

2020-06-09: Anisa and River created the bullet shape, added setup and go buttons. We added left turn, right turn, and move forward buttons, and basic commands for them. We added display labels for Time, Level, and Score.

2020-06-10: Today, we were extremely productive, and did a lot to compensate for the lack of time left. First, we added in a shoot button, which shoots a bullet out. Then, we added in scoring, levels, time, their plabels (and shifting for justification for those on the left), and resetting their labels and changing them. 

Then, we began the long road of asteroid collision mechanics. We started by using long strings of turtles-at, but realized that although it works for some things, like asteroid death, it's extremely inefficient for other commands, and not worth all the extra coding. We experimented with turtles-on, before realizing a far better command would be turtles-here, since you can't do turtles-on + with. We managed to encode them as well as a score add-er. 

We also added a life gain command, since the user gains a life every time 10,000 points is reached. We adjusted bullet and asteroid movement, to make them go faster as level increases (every time all of the asteroids are killed), as well as asteroids having varied speeds.

2020-06-11: First we added in commands for lives being lost by the turtle, and a game over screen when lives = 0 (and lots of debugging that came with it). We added smoother movement and a hyperspace function, and as our last coded addition, we created UFOs, of 2 types, that move around and shoot bullets.

2020-06-12: We began debugging, including UFO death and speeding up with level, and no max speed without hyperspace (speed increases with thrust). 

2020-06-13: We also fixed a bug where UFOs didn't collide with ships. We also added better asteroid collisions, changing all of them from patch-based to radial. We also changed how close to the edge a UFO dies. We also sped up the asteroids and bullets.

2020-06-14: We stopped UFOs from shooting if the ship is dead, and we wrote a script for our presentation and finished up the info tabs.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

bullet
true
0
Rectangle -7500403 true true 90 15 210 285

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

ufo
false
15
Polygon -1 true true 0 150 15 180 60 210 120 225 180 225 240 210 285 180 300 150 300 135 285 120 240 105 195 105 150 105 105 105 60 105 15 120 0 135
Polygon -1 false true 105 105 60 105 15 120 0 135 0 150 15 180 60 210 120 225 180 225 240 210 285 180 300 150 300 135 285 120 240 105 210 105
Polygon -7500403 true false 60 131 90 161 135 176 165 176 210 161 240 131 225 101 195 71 150 60 105 71 75 101
Circle -16777216 false false 255 135 30
Circle -16777216 false false 180 180 30
Circle -16777216 false false 90 180 30
Circle -16777216 false false 15 135 30
Circle -7500403 true false 15 135 30
Circle -7500403 true false 90 180 30
Circle -7500403 true false 180 180 30
Circle -7500403 true false 255 135 30
Polygon -7500403 false false 150 59 105 70 75 100 60 130 90 160 135 175 165 175 210 160 240 130 225 100 195 70

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
