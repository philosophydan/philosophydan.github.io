patches-own [
  significance ;; "True" landscape.  What the epistemic value of a patch is.
  visited ;; A boolean for whether an agent has been on the patch before. false for no, true for yes
  ]
globals [
  highest_significance
  lowest_significance
  random_number
  gaussian_list
]
breed [followers follower] ; Agents that like to take known paths
breed [mavericks maverick] ; Agents that like to make new paths
breed [controls control] ; Agents that don't pay attention to paths at all (control group)

turtles-own [
  previous_significance

]

to setup
  clear-all
  set random_number random 2147483647
  random-seed random_number
  set gaussian_list [[25 25 .75 .02 .01 .02] [-5 -5 .7 .01 .01 .01]]
  setup-patches
  setup-turtles
  reset-ticks
end

to setup-patches
  generate-gaussians gaussian_list
  ask patches [
     set visited false
   ]
   set highest_significance max [significance] of patches
   set lowest_significance min [significance] of patches
   ask patches [set pcolor scale-color green significance 0 1000]
   ask patches [
     ifelse (significance > (highest_significance - 10)) [
        set pcolor white
     ]
     [
       if (significance < (lowest_significance + 1)) [
          set pcolor black
        ]
     ]
   ]

end

to reset
   ask patches [set pcolor scale-color green significance 0 1000]
   ask patches [
     ifelse (significance > (highest_significance - 10)) [
        set pcolor white
     ]
     [
       if (significance < (lowest_significance + 1)) [
          set pcolor black
        ]
     ]]
end

to show-unvisited
    reset
    ask patches with [(visited = false) and (significance > 0) ] [set pcolor 85]
end

to setup-turtles
  let lowpatches count patches with [significance < (lowest_significance + 10)]
  let iter 0

   while [iter < number_of_control] [
     ask patch random-pxcor random-pycor [
       if significance < (lowest_significance + 10) [
         sprout-controls 1 [
           set color blue
           set heading random 360
           set previous_significance 0
          ]
         set iter (iter + 1)
       ]
     ]
  ]
  set iter 0
  while [iter < number_of_followers] [
     ask patch random-pxcor random-pycor [
       if significance < (lowest_significance + 10) [
         sprout-followers 1 [
           set color yellow
           set heading random 360
           set previous_significance 0
          ]
         set iter (iter + 1)
       ]
     ]
  ]
  set iter 0
  while [iter < number_of_mavericks] [
     ask patch random-pxcor random-pycor [
       if significance < (lowest_significance + 10) [
         sprout-mavericks 1 [
           set color red
           set heading random 360
           set previous_significance 0
          ]
         set iter (iter + 1)
       ]
     ]
 ]
 ask turtles [pen-down]
end

to go
  ask turtles [
    ask patch-here [ set visited true ] ]
  ask controls [move-control]
  ifelse fixed-model [ask followers [ new-move-follower ]] [ask followers [move-follower]]
  ask turtles with [breed = mavericks] [ move-maverick ]
  plot count patches with [(visited = false) and (significance > 0) ]
  tick
end

to move-control
 ;print "hello"
 ifelse ([significance] of patch-here) >= previous_significance [
      ifelse ([significance] of patch-here) = previous_significance [
        if random 50 = 1 [
          set previous_significance ([significance] of patch-here)
          set heading random 360
          fd 1
        ]
        fd 0
      ]
      [
        set previous_significance ([significance] of patch-here)
        fd 1
      ]
    ]
    [
      back 1
      set heading random 360
    ]
end

to move-follower
  let newpatch max-one-of (neighbors with [visited = true]) [significance]
  ifelse (newpatch = nobody)
  [
    ifelse (any? (neighbors with [visited = false]))
    [
      set heading towards one-of (neighbors with [visited = false])
      set previous_significance ([significance] of patch-here)
      fd 1
    ]
    [
      fd 0
    ]
  ]
  [
    ifelse ([significance] of newpatch >= [significance] of patch-here) ;; issue with >= and > is here
    [
       set heading towards newpatch
       set previous_significance ([significance] of patch-here)
       fd 1
    ]
    [
      ifelse (any? (neighbors with [visited = false]) )
      [
        set heading towards one-of (neighbors with [visited = false])
        set previous_significance ([significance] of patch-here)
        fd 1
      ]
      [
        fd 0
      ]
    ]
  ]
end

to new-move-follower
  let newpatch max-one-of (neighbors with [visited = true]) [significance]
  ifelse (newpatch = nobody)
  [
    ifelse (any? (neighbors with [visited = false]))
    [
      set heading towards one-of (neighbors with [visited = false])
      set previous_significance ([significance] of patch-here)
      fd 1
    ]
    [
      fd 0
    ]
  ]
  [
    ifelse ([significance] of newpatch > [significance] of patch-here) ;; issue with >= and > is here
    [
       set heading towards newpatch
       set previous_significance ([significance] of patch-here)
       fd 1
    ]
    [
      ifelse (any? (neighbors with [visited = false]) )
      [
        set heading towards one-of (neighbors with [visited = false])
        set previous_significance ([significance] of patch-here)
        fd 1
      ]
      [
        fd 0
      ]
    ]
  ]
end

to move-maverick
  let current_significance [significance] of patch-here

  ifelse  (([significance] of patch-here) >= previous_significance)
  [
    ifelse (any? (neighbors with [visited = false]))
    [
       ifelse [visited] of (patch-at-heading-and-distance heading 1) = false
       [
          set previous_significance ([significance] of patch-here)
          fd 1
       ]
       [
         set heading towards one-of (neighbors with [visited = false])
         set previous_significance ([significance] of patch-here)
         fd 1
       ]
    ]
    [
       ifelse (any? (neighbors with [significance >= current_significance]))
       [
         set heading towards max-one-of (neighbors with [visited = true]) [significance]
         set previous_significance ([significance] of patch-here)
         fd 1
       ]
       [
         fd 0
       ]
     ]
   ]
   [
     back 1
     set heading random 360
   ]

end

to generate-gaussians [glist]
;; Implementing a two-dimensional Gaussian distribution
;; make a list of lists
     let center_x 0
     let center_y 0
     let amplitude 0
     let a 0
     let b 0
     let c 0

   foreach glist [ ?1 ->
     set center_x item 0 ?1
     set center_y item 1 ?1
     set amplitude item 2 ?1
     set a item 3 ?1
     set b item 4 ?1
     set c item 5 ?1
     ask patches [
       set significance significance + (amplitude * exp ( -1 * (( a * ( pxcor - center_x) ^ 2 ) + b * ( pxcor - center_x ) * (pycor - center_y) + (c * (pycor - center_y) ^ 2))))
     ]
     ]
   ask patches [
     set significance (int (1000 * significance))
   ]
end

to show-paths
  ask patches with [visited = true] [set pcolor grey]
end
@#$#@#$#@
GRAPHICS-WINDOW
303
10
917
625
-1
-1
6.0
1
10
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
5
10
84
43
setup
setup
NIL
1
T
OBSERVER
NIL
I
NIL
NIL
1

BUTTON
5
48
84
81
NIL
go
T
1
T
OBSERVER
NIL
R
NIL
NIL
1

SLIDER
94
10
292
43
number_of_control
number_of_control
0
1000
0.0
1
1
NIL
HORIZONTAL

BUTTON
5
85
84
118
go-once
go
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
94
44
292
77
number_of_mavericks
number_of_mavericks
0
1000
10.0
1
1
NIL
HORIZONTAL

SLIDER
94
81
292
114
number_of_followers
number_of_followers
0
1000
400.0
1
1
NIL
HORIZONTAL

MONITOR
154
582
224
627
unvisited
count patches with [visited = false]
3
1
11

MONITOR
12
581
150
626
unvisited significant
count patches with [(visited = false) and (significance > 0) ]
3
1
11

PLOT
13
410
284
560
Unvisited Significant Patches
rounds
patches
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

MONITOR
91
636
148
681
quality
count patches with [visited = false and (significance > 0)] / count patches with [visited = false]
3
1
11

MONITOR
153
638
286
683
Epistemic Progress
count patches with [visited = true and (significance > 0)] / count patches with [(significance > 0)]
3
1
11

BUTTON
4
236
83
269
unvisited
show-unvisited
NIL
1
T
OBSERVER
NIL
U
NIL
NIL
1

BUTTON
5
197
83
230
m-drop
ask patch random-pxcor random-pycor [sprout-mavericks 1]\nask mavericks [pen-down]\nask mavericks [set color red]
NIL
1
T
OBSERVER
NIL
M
NIL
NIL
1

BUTTON
5
156
84
189
find peaks
if (count patches with [pxcor = -5 and pycor = -5 and visited = true] + count patches with [pxcor = 25 and pycor = 25 and visited = true]) < 2  [go]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
12
636
82
681
unvisited
count patches with [visited = false]
3
1
11

SWITCH
81
314
202
347
fixed-model
fixed-model
1
1
-1000

TEXTBOX
91
157
241
185
Alternative \"go\" button that goes until peaks found
11
0.0
1

TEXTBOX
89
205
239
223
Adds a new maverick
11
0.0
1

TEXTBOX
89
238
239
266
Highlights unvisited spots on hills
11
0.0
1

TEXTBOX
41
354
277
438
Switch between original Weisberg and Muldoon model (off) and a fixed version (on). See J. McKenzie Alexander et al, 2015
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This is the model from Weisberg and Muldoon (2009). In this model, there are followers and mavericks (and controls, which this description will ignore) that explore the epistemic landscape in different ways.

‘Followers’ take previous investigation of the territory by others into account in order to follow successful trends.  If any previously investigated points in their immediate neighborhood have a higher significance than the point they stand on, they move to that point (randomly breaking any tie). Only if no neighboring investigated points have higher significance and uninvestigated point remain, followers move to one of those. The paths of the followers are in yellow.

‘Mavericks’ avoid previously investigated points much as followers prioritize them.  Mavericks choose unexplored points in their neighborhoods, testing significance.  If higher than their current spot, they move to that point. The paths of the mavericks are in red.

Clicking "setup" makes the landscape and drops the followers and mavericks onto parts of the landscape that aren't on the hills. Clicking "go" makes the agents follow their movement pattern.

Weisberg and Muldoon measure both the percentages of runs in which groups of agents find the highest peak and the speed at which peaks are found.  They report that the epistemic success of a population of followers is increased when mavericks are included, and that the explanation for that effect lies in the fact that mavericks can provide pathways for followers: “[m]avericks help many of the followers to get unstuck, and to explore more fruitful areas of the epistemic landscape” (for details see Weisberg & Muldoon (2009), pp. 247 ff). Against that background they argue for broad claims regarding the value for an epistemic community of combining different research strategies.  The optimal division of labor that their model suggests is “a healthy number of followers with a small number of mavericks.”  

In contrast to their description in the text the original software for the model used “>=” in place of “>” at a crucial place, with the result that followers moved to neighboring points with a higher or equal significance, resulting in their often getting stuck in a very local oscillation (Alexander, Himmelreich and Thomson 2015). By flipping the "fixed-model" switch, you can see how the model would run if it were implemented correctly. Notice the difference in movement of the followers.

## CREDITS AND REFERENCES

Weisberg, M. and R. Muldoon, 2009, “Epistemic Landscapes and the Division of Cognitive Labor.” Philosophy of Science, 76 (2): 225-252.

Alexander, J., J. Himmelreich and C. Thompson, 2015, “Epistemic Landscapes, Optimal Search, and the Division of Cognitive Labor,” Philosophy of Science, 82 (3): 424-453.  

For a different critique of this model, see 
Thoma, J., 2015, “Epistemic Division of Labor Revisited,” Philosophy of Science, 82 (3), 454-472.


Original model written by Michael Weisberg and Ryan Muldoon. Updated and simplified in 2019 by Daniel J. Singer to work on Netlogo Web as well as to incude the fixed version of the model.
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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Control Epistemic Significance Timecourse" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>let i 0
while [i &lt; 100]
[
go
set i  i + 1
]</go>
    <timeLimit steps="100"/>
    <metric>count patches with [visited = true]</metric>
    <metric>count patches with [significance &gt; 0]</metric>
    <metric>count patches with [(visited = false) and (significance &gt; 0) ]</metric>
    <enumeratedValueSet variable="number_of_mavericks">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number_of_control" first="10" step="10" last="200"/>
    <enumeratedValueSet variable="number_of_followers">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1251"/>
    <metric>count patches with [(visited = false) and (significance &gt; 0) ]</metric>
    <enumeratedValueSet variable="number_of_mavericks">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_control">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_followers">
      <value value="500"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="control timecourse" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>let i 0
while [i &lt; 50]
[
go
set i  i + 1
]</go>
    <exitCondition>(count turtles with [previous_significance = 0]) = 0</exitCondition>
    <metric>count turtles with [previous_significance &gt; 0]</metric>
    <enumeratedValueSet variable="number_of_mavericks">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_control">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_followers">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="control find max sign peaks" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50000"/>
    <exitCondition>(count patches with [pxcor = -5 and pycor = -5 and visited = true] + count patches with [pxcor = 25 and pycor = 25 and visited = true]) = 2</exitCondition>
    <metric>count patches with [pxcor = -5 and pycor = -5 and visited = true] + count patches with [pxcor = 25 and pycor = 25 and visited = true]</metric>
    <enumeratedValueSet variable="number_of_mavericks">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number_of_control" first="20" step="10" last="200"/>
    <enumeratedValueSet variable="number_of_followers">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name=" maverick find max sign peaks" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>(count patches with [pxcor = -5 and pycor = -5 and visited = true] + count patches with [pxcor = 25 and pycor = 25 and visited = true]) = 2</exitCondition>
    <metric>count patches with [pxcor = -5 and pycor = -5 and visited = true] + count patches with [pxcor = 25 and pycor = 25 and visited = true]</metric>
    <steppedValueSet variable="number_of_mavericks" first="10" step="10" last="200"/>
    <enumeratedValueSet variable="number_of_control">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_followers">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Control Epistemic Significance Summary" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>count patches with [visited = true]</metric>
    <metric>count patches with [significance &gt; 0]</metric>
    <metric>(count patches with [(visited = true) and (significance &gt; 0) ] / count patches with [significance &gt; 0])</metric>
    <enumeratedValueSet variable="number_of_mavericks">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number_of_control" first="10" step="10" last="400"/>
    <enumeratedValueSet variable="number_of_followers">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="followers find max sign peaks" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>(count patches with [pxcor = -5 and pycor = -5 and visited = true] + count patches with [pxcor = 25 and pycor = 25 and visited = true]) = 2</exitCondition>
    <metric>count patches with [pxcor = -5 and pycor = -5 and visited = true] + count patches with [pxcor = 25 and pycor = 25 and visited = true]</metric>
    <enumeratedValueSet variable="number_of_mavericks">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_control">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number_of_followers" first="10" step="10" last="200"/>
  </experiment>
  <experiment name="Follower Epistemic Significance Summary" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>count patches with [visited = true]</metric>
    <metric>count patches with [significance &gt; 0]</metric>
    <metric>(count patches with [(visited = true) and (significance &gt; 0) ] / count patches with [significance &gt; 0])</metric>
    <enumeratedValueSet variable="number_of_mavericks">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_control">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number_of_followers" first="10" step="10" last="400"/>
  </experiment>
  <experiment name="Mavericks Epistemic Significance Summary" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>count patches with [visited = true]</metric>
    <metric>count patches with [significance &gt; 0]</metric>
    <metric>(count patches with [(visited = true) and (significance &gt; 0) ] / count patches with [significance &gt; 0])</metric>
    <steppedValueSet variable="number_of_mavericks" first="10" step="10" last="400"/>
    <enumeratedValueSet variable="number_of_control">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_followers">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="1 maverick" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count patches with [visited = true]</metric>
    <metric>count patches with [visited = true and (significance &gt; 0)]</metric>
    <metric>(count patches with [(visited = true) and (significance &gt; 0)] / count patches with [significance &gt; 0])</metric>
    <enumeratedValueSet variable="number_of_control">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_mavericks">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_followers">
      <value value="401"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
