globals [
  randomgroup
  expertgroup
  allheurs
  terrain

  ;;;av comp numbers
  relay-randoms
  tourn-randoms
  relay-experts
  tourn-experts
]
turtles-own [ heuristic tempcomp ]

to setup
  clear-all
  ;; set tempspotsunchecked []  ;;removed because it sets all tests to spots for random groups
  setup-terrain
  setup-allheurs ;; sets up a list of all possible heurs.  Used by setup-expert-agents and setup-random-agents
  setup-expert-agents ;; sets expertgroup to shuffled top groupsize of all possible turtles
  setup-random-agents  ;; sets random group to groupsize random turtles
  reset-ticks
end


to setup-terrain
  set terrain (list random 100)
  let thissmooth (random (SmoothingFactor * 2))
  while [(length terrain) + thissmooth < RingLength] [
    ;; if adding that spot on to the terrain would push over over the length goal for the terrain, stop
    ;; if not, choose a random height for that new spot
    let endpoint random 100

    let diff (endpoint - last terrain)
    repeat thissmooth [
      set terrain lput ((last terrain) + (diff / (thissmooth + 1))) terrain ]
    set terrain lput endpoint terrain

    set thissmooth (random (SmoothingFactor * 2))
  ]

  ;; now we have a ring that has a last random spot but we can't suppliment it with thissmooth more points without going over.  So the next bit of code smooths from the last point we have to the first point to form the loop
  let diff (first terrain - last terrain)
  let spotstoadd RingLength - length terrain
  repeat spotstoadd [
    set terrain lput ((last terrain) + (diff / (spotstoadd + 1))) terrain ]
  set terrain map round terrain ;; rounds the points in terrain to the nearist integer

  visualize-terrain
end

to visualize-terrain

 ;  visuals: this code sets the patches to look like the terrain
  let numberlist n-values RingLength [ ?1 -> ?1 ]
  foreach numberlist [ ?1 ->
    ask patch ?1 item ?1 terrain [ set pcolor white ]
  ]
end


to setup-allheurs ;; sets allhuers to a list of all possible heuristics
  set allheurs []
  foreach n-values max-heur-number [ ?1 -> ?1 + 1 ] [ ?1 ->
    let fst ?1
    foreach n-values max-heur-number [ ??1 -> ??1 + 1 ] [ ??1 ->
      let sec ??1
      if sec != fst [
        foreach n-values max-heur-number [ ???1 -> ???1 + 1 ] [ ???1 ->
          let thi ???1
          if thi != sec and thi != fst [
            set allheurs lput (list fst sec thi) allheurs
          ]
        ]
      ]
    ]
  ]
end

to setup-expert-agents
  if quick-setup-experts [set allheurs n-of min (list 500 length allheurs) allheurs]
  set expertgroup top-n
end

to setup-random-agents
  let randomheurs n-of groupsize allheurs ;; choose groupsize random heurs without repeats
  set randomgroup []
  foreach randomheurs [ ?1 -> ;; add turtles with those random heurs to randomgroup (and compute their avcompetence)
    crt 1 [
      set heuristic ?1
      set randomgroup lput self randomgroup
      set tempcomp AvCompetence self
    ]
  ]
  set randomgroup shuffle randomgroup
end

to go

  set relay-randoms AvCompetence-for-chained-Group (randomgroup)

  set tourn-randoms AvCompetenceforCheckEveryoneGroup (randomgroup)

  set relay-experts AvCompetence-for-chained-Group (expertgroup)

  set tourn-experts AvCompetenceforCheckEveryoneGroup (expertgroup)

  stop
end


to-report top-n ;; calculates expert group
  let listofposturts []
  foreach allheurs [ ?1 ->
    crt 1 [
      set heuristic ?1
      set listofposturts lput self listofposturts
      set tempcomp AvCompetence self
    ]
  ]
  report shuffle sublist (sort-by [ [?1 ?2] -> [tempcomp] of ?1 > [tempcomp] of ?2 ] listofposturts) 0 groupsize
end

to-report peakloc [startloc turt] ; reports the highest location turt gets to starting at startloc (e.g. "peakloc 765 turtle 4")
  let currloc startloc
  ;; set tempspotsunchecked remove currloc tempspotsunchecked ;; used for counting spots touched
  let try 0
  let currheurspot 0
  while [try < 3] [
    ifelse (item ((currloc + item currheurspot [heuristic] of turt) mod RingLength) terrain) > (item currloc terrain)
      [
        set currloc (currloc + item currheurspot [heuristic] of turt) mod RingLength     ;;I had to add the MOD to make this work right.  PG
        set currheurspot (currheurspot + 1) mod 3
        ;set tempspotsunchecked remove currloc tempspotsunchecked ;; used for counting spots touched
        set try 0
      ]
      [
        set currheurspot (currheurspot + 1) mod 3
        ;set tempspotsunchecked remove ((currloc + item currheurspot [heuristic] of turt) mod RingLength) tempspotsunchecked ;; used for counting spots touched
        set try try + 1
      ]
  ]
  report currloc
end

to-report AvCompetence [turt] ; reports the average ending height from any ring location for a turtle (e.g. "AvCompetence turtle 6")
  let ccounter 0
  let total 0
  while [ccounter < Ringlength] [
    set total total + item peakloc ccounter turt terrain
    set ccounter ccounter + 1
  ]
  report total / Ringlength
end


to-report peakloc-for-chained-group [startloc listofturts] ;reports the location for the highest peak a group of turtles starting at startloc gets to by cycling through (e.g. "peakloc-for-chained-group 754 (list turtle 6 turtle 9 turtle 5)")
  let currloc startloc
  let try 0
  let currgroupspot 0
  while [try < length listofturts] [
    let currturt item currgroupspot listofturts
    ifelse (item (peakloc currloc currturt) terrain) > (item currloc terrain)
      [
        set currloc peakloc currloc currturt
        set currgroupspot (currgroupspot + 1) mod length listofturts
        set try 0
      ]
      [
        set currgroupspot (currgroupspot + 1) mod length listofturts
        set try try + 1
      ]
  ]
  report currloc
end


to-report AvCompetence-for-chained-Group [group]; reports the average ending height from any ring location for a group (e.g. "AvCompetence-for-chained-Group (list turtle 6 turtle 9 turtle 5)")
  let ccounter 0
  let total 0
  ;let spotstouched 0
  while [ccounter < Ringlength] [
    ;set tempspotsunchecked n-values RingLength [?] ;; used for counting spots touched
    set total total + item peakloc-for-chained-group ccounter group terrain
    set ccounter ccounter + 1
    ;set spotstouched spotstouched + (Ringlength - length tempspotsunchecked)
  ]
  ;print (word "In everyone relay, we looked at on average " (spotstouched / Ringlength) " spots in each run.")
  ;set relay-spots ( spotstouched / Ringlength )
  report total / Ringlength
end



to-report peakloc-for-chained-group-of-chained-groups [ startloc listoflistsofturts ] ;; reports the peakloc of chaining peakloc-for-chained-groups for each of the groups in the list
  let currloc startloc
  let try 0
  let currlistspot 0
  while [try < length listoflistsofturts ] [
    let currgroup item currlistspot listoflistsofturts
    ifelse (item (peakloc-for-chained-group currloc currgroup) terrain) > (item currloc terrain)
      [
        set currloc peakloc-for-chained-group currloc currgroup
        set try 0
      ]
      [
        set currlistspot (currlistspot + 1) mod length listoflistsofturts
        set try try + 1
      ]
  ]
  report currloc
end


to-report AvCompetence-for-chained-group-of-chained-groups [ listoflistsofturts ] ;; average over all points for chained group acting on chained groups
  let ccounter 0
  let total 0
  ;let spotstouched 0
  while [ccounter < Ringlength] [
    ;set tempspotsunchecked n-values RingLength [?] ;; used for counting spots touched
    set total total + item peakloc-for-chained-group-of-chained-groups ccounter listoflistsofturts terrain
    set ccounter ccounter + 1
    ;set spotstouched spotstouched + (Ringlength - length tempspotsunchecked)
  ]
  ;print (word "In representative relay, we looked at on average " (spotstouched / Ringlength) " spots in each run.")
  ;set relay-rep-spots (spotstouched / Ringlength)
  report total / Ringlength
end





to-report AvTopCompetence [ listofturts ]
  let ccounter 0
  let total 0
  while [ccounter < Ringlength] [
    let maxvalueshere []
    foreach listofturts [ ?1 ->
        set maxvalueshere lput (item peakloc
        ccounter ?1 terrain) maxvalueshere
      ]
      set total total + max maxvalueshere
      set ccounter ccounter + 1
    ]
    report total / Ringlength
  end



;;; The following few methods report the maximum locations
;;; for asking for the best performance for the groups (or group of groups)
;;; rather than by chaining

to-report CheckEveryonePeakLoc [startloc group] ;; reports the peakloc by finding the peakloc for ANYONE in the group then going there (and repeating until stuck)
  ;; Code ex: CheckEveryonePeakLoc 13 (list turtle 2 turtle 3 turtle 4 turtle 5 turtle 6 turtle 7)
  let currloc startloc
  ;; find best turtle
  let bestturt first group
  let bestturtheight item peakloc currloc bestturt terrain
  foreach butfirst group [ ?1 ->
    if item peakloc currloc ?1 terrain > bestturtheight [
      set bestturt ?1
      set bestturtheight item peakloc currloc bestturt terrain
    ]
  ]
  ;; set currloc to peakloc bestturt
  set currloc peakloc currloc bestturt
  ;; if we're stuck, report that location
  ;; if not, report this method of new location
  ifelse currloc = startloc
    [ report currloc ]
    [ report CheckEveryonePeakLoc currloc group ]
end


to-report AvCompetenceforCheckEveryoneGroup [group]; reports the average ending height from any ring location for a group using Everyone Checking (e.g. "AvCompetenceforCheckEveryoneGroup (list turtle 6 turtle 9 turtle 5)")
  let ccounter 0
  let total 0
  ;let spotstouched 0
  while [ccounter < Ringlength] [
    ;set tempspotsunchecked n-values RingLength [?] ;; used for counting spots touched
    set total total + item CheckEveryonePeakLoc ccounter group terrain
    set ccounter ccounter + 1
    ;set spotstouched spotstouched + (Ringlength - length tempspotsunchecked)
  ]
  ;print (word "In everyone tournament, we looked at on average " (spotstouched / Ringlength) " spots in each run.")
  ;set tourn-spots ( spotstouched / Ringlength )
  report total / Ringlength
end


to-report CheckEveryoneinGroupsPeakLoc [startloc groupofgroups] ;; code ex: CheckEveryoneinGroupsPeakLoc 15 (list (list turtle 2 turtle 4) (list turtle 7 turtle 55))
  let currloc startloc
  ;; find best turtle
  let bestgroup first groupofgroups
  let bestgroupheight item CheckEveryonePeakLoc currloc bestgroup terrain
  foreach butfirst groupofgroups [ ?1 ->
    if item CheckEveryonePeakLoc currloc ?1 terrain > bestgroupheight [
      set bestgroup ?1
      set bestgroupheight item CheckEveryonePeakLoc currloc bestgroup terrain
    ]
  ]
  ;; set currloc to peakloc bestturt
  set currloc CheckEveryonePeakLoc currloc bestgroup
  ;; if we're stuck, report that location
  ;; if not, report this method of new location
  ifelse currloc = startloc
    [ report currloc ]
    [ report CheckEveryoneinGroupsPeakLoc currloc groupofgroups ]
end

to-report AvCompetenceforCheckEveryoneGroupofGroups [ listoflistsofturts ]
  let ccounter 0
  let total 0
  ;let spotstouched 0
  while [ccounter < Ringlength] [
    ;set tempspotsunchecked n-values RingLength [?] ;; used for counting spots touched
    set total total + item CheckEveryoneinGroupsPeakLoc ccounter listoflistsofturts terrain
    set ccounter ccounter + 1
    ;set spotstouched spotstouched + (Ringlength - length tempspotsunchecked)
  ]
 ; print (word "In representative tournament, we looked at on average " (spotstouched / Ringlength) " spots in each run.")
  ;set tourn-rep-spots (spotstouched / Ringlength)
  report total / Ringlength
end
@#$#@#$#@
GRAPHICS-WINDOW
4
5
1310
145
-1
-1
1.298
1
10
1
1
1
0
1
1
1
0
999
0
100
1
1
0
ticks
30.0

BUTTON
13
156
79
189
Setup
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
86
156
149
189
Go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
177
156
349
189
RingLength
RingLength
100
5000
1000.0
100
1
NIL
HORIZONTAL

MONITOR
412
250
653
303
NIL
relay-experts
17
1
13

MONITOR
31
251
272
304
NIL
relay-randoms
17
1
13

MONITOR
31
311
272
364
NIL
tourn-randoms
17
1
13

SLIDER
363
157
535
190
max-heur-number
max-heur-number
5
20
12.0
1
1
NIL
HORIZONTAL

MONITOR
412
310
652
363
NIL
tourn-experts
17
1
13

TEXTBOX
33
204
183
242
Scores of Group of Random People
15
0.0
1

TEXTBOX
414
205
564
243
Scores of Group of Highest-Performing
15
0.0
1

SLIDER
735
157
907
190
SmoothingFactor
SmoothingFactor
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
550
157
722
190
groupsize
groupsize
1
15
9.0
1
1
NIL
HORIZONTAL

SWITCH
733
255
919
288
quick-setup-experts
quick-setup-experts
0
1
-1000

TEXTBOX
734
297
917
367
Improves setup time by chosing top performers from 500 random heuristics (rather than all possible heuristics)
11
0.0
1

MONITOR
31
463
731
508
Heuristics in Highest-Performaing Group
map [i -> [heuristic] of i] expertgroup
17
1
11

MONITOR
31
411
731
456
Heuristics in Random Group
map [i -> [heuristic] of i] randomgroup
17
1
11

TEXTBOX
744
415
894
499
Note: List of heuristics may not print correctly on Web version. The first three numbers are the first heuristic. The second three are the second. Etc.
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This is an implementation of the "Diversity Trumps Ability" model originally presented by Lu Hong and Scott Page in "Groups of diverse problem solvers can outperform groups of high-ability problem solvers" (*PNAS*, 2004). 

In this model, groups of agents try to find the highest location on a lanscape of *RingLength* points (that wraps around like a circle). Each point is assigned a random score between 1 and 100. 

Individual agents explore that landscape using heuristics composed of three ordered numbers between, say, 1 and 12 (set by *max-heur-number*).  An example helps.  Consider an individual with heuristic <2, 4, 7> at point 112 on the landscape.  He first uses his heuristic 2 to see if a point two to  the right—at 114—has a higher value than his current position.  If so, he moves to that point.  If not, he stays put.  From that point, whichever it is, he uses his heuristic 4 in order to see if a point 4 steps to the right has a higher peak, and so forth.  An agent circles through his heuristic numbers repeatedly until he reaches a point from which none within reach of his heuristic offers a higher value.  An individual's score is the average height they can reach starting from every point in the landscape. Groups (in relay, as Hong and Page discuss) act similarly in that a single individual takes the group to the highest point they can, then turn over the group to the next individual, and then proceeding around the group until no one can take the group any higher. The group's score is the average score they can reach from any point.

This model also implements a tournement dynamic whereby on each step of group movement, everyone in the group finds the highest spot they can get to and the whole group moves to the highest spot that anyone in the group can reach.

This model also includes a smoothing function, which smooths out the landscape, making it not random like it was in Hong and Page's original work.

When *setup* is run, this model creates the landscape and two groups. One group is the random group, which is composed of random individuals. The other is the "expert" group (this is a bad name choice -- See Grim, et al (2019)). The expert group is the top performing individuals.

For more on the extensions of the Hong and Page model that this model includes, see Grim, et al (2019).

## CREDITS AND REFERENCES

This model was produced by Daniel J. Singer (based on the work by Lu Hong and Scott Page) with assistance from the Computational Social Philosophy Lab

For more information about this model, see

Lu Hong, Scott E. Page. (2004) "Groups of diverse problem solvers can outperform groups of high-ability problem solvers" *Proceedings of the National Academy of Sciences* 101 (46) 16385-16389; DOI: 10.1073/pnas.0403723101

Patrick Grim, Daniel J. Singer, Aaron Bramson, Bennett Holman, Sean McGeehan, and William J. Berger. (2019) “Diversity, Ability, and Expertise in Epistemic Communities” *Philosophy of Science*
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
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment2" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>randoms</metric>
    <metric>representation1</metric>
    <metric>representation2</metric>
    <enumeratedValueSet variable="RingLength">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="number">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RingLength">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-heur-number">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="expanded heuristics 36" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>experts-chained</metric>
    <metric>experts-chained-representation</metric>
    <metric>randomschained</metric>
    <metric>randoms-chained-representation</metric>
    <metric>simultaneous-chained</metric>
    <metric>simultaneous-chained-representation</metric>
    <enumeratedValueSet variable="max-heur-number">
      <value value="36"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RingLength">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-terrain">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="expanded heuristics 24" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>experts-chained</metric>
    <metric>experts-chained-representation</metric>
    <metric>randomschained</metric>
    <metric>randoms-chained-representation</metric>
    <metric>simultaneous-chained</metric>
    <metric>simultaneous-chained-representation</metric>
    <enumeratedValueSet variable="max-heur-number">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RingLength">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-terrain">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="normal terrain" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>experts-chained</metric>
    <metric>experts-chained-representation</metric>
    <metric>randomschained</metric>
    <metric>randoms-chained-representation</metric>
    <metric>simultaneous-chained</metric>
    <metric>simultaneous-chained-representation</metric>
    <enumeratedValueSet variable="max-heur-number">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RingLength">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-terrain">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="counting spots" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>relay-all-spots</metric>
    <metric>relay-rep-spots</metric>
    <metric>tourn-all-spots</metric>
    <metric>tourn-rep-spots</metric>
    <enumeratedValueSet variable="RingLength">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-heur-number">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-terrain">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="miscom tests" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>randomschained</metric>
    <metric>relay-all-spots</metric>
    <metric>simultaneous-chained</metric>
    <metric>tourn-all-spots</metric>
    <metric>miscom-randomschained</metric>
    <metric>miscom-relay-all-spots</metric>
    <enumeratedValueSet variable="RingLength">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-heur-number">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-terrain">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="miscom tests 11082018" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>randomschained</metric>
    <metric>relay-all-spots</metric>
    <metric>simultaneous-chained</metric>
    <metric>tourn-all-spots</metric>
    <metric>miscom-randomschained</metric>
    <metric>miscom-relay-all-spots</metric>
    <metric>miscom-simultaneous-chained</metric>
    <metric>miscom-tourn-all-spots</metric>
    <metric>miscom-simultaneous-chained2</metric>
    <metric>miscom-tourn-all-spots2</metric>
    <enumeratedValueSet variable="RingLength">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-heur-number">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-terrain">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="soph miscom tests 11272018" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>relay-randoms</metric>
    <metric>miscompointonly-randomrelay</metric>
    <metric>miscompointandheight-randomrelay</metric>
    <metric>tourn-randoms</metric>
    <metric>miscom-onlygoifhigher-tourn-randoms</metric>
    <metric>miscom-alwaysgo-tourn-randoms</metric>
    <metric>relay-spots</metric>
    <metric>miscompointonly-relay-spots</metric>
    <metric>miscompointandheight-relay-spots</metric>
    <metric>tourn-spots</metric>
    <metric>miscom-onlygoifhigher-tourn-spots</metric>
    <metric>miscom-alwaysgo-tourn-spots</metric>
    <enumeratedValueSet variable="RingLength">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-heur-number">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal-terrain">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="miscom with smoothed tests 12142018" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>relay-randoms</metric>
    <metric>miscompointonly-randomrelay</metric>
    <metric>miscompointandheight-randomrelay</metric>
    <metric>tourn-randoms</metric>
    <metric>miscom-onlygoifhigher-tourn-randoms</metric>
    <metric>miscom-alwaysgo-tourn-randoms</metric>
    <metric>relay-experts</metric>
    <metric>miscompointonly-expertsrelay</metric>
    <metric>miscompointandheight-expertsrelay</metric>
    <metric>tourn-experts</metric>
    <metric>miscom-onlygoifhigher-tourn-experts</metric>
    <metric>miscom-alwaysgo-tourn-experts</metric>
    <enumeratedValueSet variable="RingLength">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-heur-number">
      <value value="12"/>
    </enumeratedValueSet>
    <steppedValueSet variable="SmoothingFactor" first="0" step="1" last="15"/>
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
