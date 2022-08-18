turtles-own
  [ sick-exposed?                ;; if true, the turtle is infectious
  sick-infected?
    exposed-time            ;; how long, in weeks, the turtle has been infectious

    masked?              ;; if masked, reduce the chance get infected
  in-which-zone
  exposed-duration;
    age ]                ;; how many weeks old the turtle is

globals
  [ %infected            ;; what % of the population is infectious
  %infected-masked
  %cumulative-infected
    classroom1
    classroom2
  classroom3
  classroom4
  classroom5
  classroom6
  number-classrooms
   infectiousness-with-mask
  holding-time
    in-class?
    classrooms
  size-classroom
  public-area
  cxcor
  cycor ]

;; The setup is divided into four procedures
to setup
  clear-all
  setup-classroom
  setup-turtles
  update-global-variables
  update-display
  reset-ticks
  set infectiousness-with-mask 0.1
end

to setup-classroom

  set number-classrooms 6
  set classrooms 0
  set size-classroom 50
  set public-area 60
  set cxcor 0
  set cycor 0
  ask patches with [(pycor > 200 - public-area)] [set pcolor brown]
  while [classrooms < number-classrooms]
  [
  ask patches with [ (pxcor >= cxcor + 10) and (pxcor <= cxcor + size-classroom + 10) and (pycor >= cycor + 10) and (pycor <= cycor + size-classroom + 10) ] [set pcolor white]
  set classrooms classrooms + 1
    create-turtles ceiling (number-students / number-classrooms)
    [ setxy 10 + cxcor + random size-classroom 10 + cycor + random size-classroom
      set in-class? False
      set holding-time 0
      set exposed-time 0
      set exposed-duration random-normal 3360 3360
      set masked? False
      set size 1.5  ;; easier to see
      set in-which-zone classrooms
      get-healthy ]
  ifelse cxcor + 2 * size-classroom + 10 < 200
    [set cxcor cxcor + 10 + size-classroom]
    [set cxcor 0
    set cycor cycor + size-classroom + 10]
  ]
end

;; We create a variable number of turtles of which 10 are infectious,
;; and distribute them randomly
to setup-turtles

  ask n-of 10 turtles
    [ get-sick ]
  ask n-of round (number-students * rate-wearing-mask) turtles
    [set masked? True ]
end

to get-sick ;; turtle procedure
  set sick-exposed? true
end

to get-healthy ;; turtle procedure
  set sick-exposed? false
  set sick-infected? false
  set exposed-time 0
end

;; This sets up basic constants of the model.

to go
  ask turtles [
    get-older
    ;;if not in-class? [move]
    move
    if sick-exposed? [ isolate ]
    if sick-exposed? [ infect ]
  ]
  update-global-variables
  update-display
  if holding-time < 14480 [tick]
end

to update-global-variables
  if count turtles > 0
    [ set %infected (count turtles with [ sick-exposed? ] / count turtles) * 100
      set %infected-masked ifelse-value (count turtles with[masked?]) = 0 [0][(count turtles with [ (sick-exposed? and masked?)] / count turtles with [masked?]) * 100]
      set %cumulative-infected ((number-students - count turtles with [not sick-exposed?]) / number-students) * 100
      set classroom1 (count turtles with [ in-which-zone = 1 ])
      set classroom2 (count turtles with [ in-which-zone = 2 ])
      set classroom3 (count turtles with [ in-which-zone = 3 ])
      set classroom4 (count turtles with [ in-which-zone = 4 ])
      set classroom5 (count turtles with [ in-which-zone = 5 ])
      set classroom6 (count turtles with [ in-which-zone = 6 ])
  ]
  set holding-time holding-time + 1
  ifelse holding-time mod 60 > class-duration [set in-class? False][set in-class? True]
end

to update-display
  if visualize-social-distance
  [set classrooms 0
  set cxcor 0
  set cycor 0
  ask patches [set pcolor black]
  ask patches with [(pycor > 200 - public-area)] [set pcolor brown]
  while [classrooms < number-classrooms]
  [
  ask patches with [ (pxcor >= cxcor + 10) and (pxcor <= cxcor + size-classroom + 10) and (pycor >= cycor + 10) and (pycor <= cycor + size-classroom + 10) ] [set pcolor white]
  set classrooms classrooms + 1
      ifelse cxcor + 2 * size-classroom + 10 < 200
    [set cxcor cxcor + 10 + size-classroom]
    [set cxcor 0
    set cycor cycor + size-classroom + 10]
  ]
  ]
  ask turtles
    [ if shape != turtle-shape [ set shape turtle-shape ]
      set color ifelse-value sick-exposed? [ ifelse-value sick-infected? [pink][red] ] [green]
      if masked? [set color ifelse-value sick-exposed? [gray][blue]]
      if visualize-social-distance [ask patches in-radius social-distance [set pcolor yellow]]
  ]
end

;;Turtle counting variables are advanced.
to get-older ;; turtle procedure
  if sick-exposed? [ set exposed-time exposed-time + 1 ]
end

;; Turtles move about at random.
to move ;; turtle procedure
  set classrooms ifelse-value in-class? [random (number-classrooms + 1)][number-classrooms + 1]
    let change-zone false
    let new-location-xcor 0
  let move? true
  let new-location-ycor 0
  ifelse not (classrooms = 1 + number-classrooms)
  [set new-location-xcor (random size-classroom) + (10 + size-classroom) * ((classrooms - 1) mod (floor (200 / (10 + size-classroom)))) + 10
    set new-location-ycor (random size-classroom) + floor((classrooms - 1) / (floor (200 / (10 + size-classroom)))) * (10 + size-classroom) + 10
  ]

  [set new-location-xcor random 200
    set new-location-ycor 200 - public-area + random public-area
  ]
  ifelse (not in-class?) [


  rt random 100
  lt random 100

  set cxcor (10 + size-classroom) * ((in-which-zone - 1) mod (floor (200 / (10 + size-classroom)))) + 10
  set cycor floor((in-which-zone - 1) / (floor (200 / (10 + size-classroom)))) * (10 + size-classroom) + 10
  ifelse not (in-which-zone = 1 + number-classrooms)
  [  ifelse allow-student-stayinclassroom-during-break
      [if xcor + agent-speed > cxcor + size-classroom and heading > 0 and heading < 180 [set change-zone true]
  if xcor - agent-speed < cxcor and heading > 180 and heading < 360 [set change-zone true]
  if ycor + agent-speed > size-classroom + cycor and (heading > 270  or heading < 90) [set change-zone true]
    if ycor - agent-speed < cycor and heading > 90 and heading < 270 [set change-zone true]
    ]
      [set change-zone true
        set classrooms number-classrooms + 1
      ]
    ]
  [ if ycor + agent-speed > 200 and (heading > 270  or heading < 90) [ifelse in-class? [set heading 180 - heading][set change-zone true]]
    if ycor - agent-speed < 200 - public-area  and heading > 90  and heading < 270 [ifelse in-class? [set heading heading - 180][set change-zone true]]
  ]
    ask patch-ahead agent-speed [if (count turtles in-radius social-distance > 1 ) [set move? false]]
    if move? [fd agent-speed]
  if change-zone [setxy new-location-xcor new-location-ycor
    set in-which-zone classrooms]
    ]
  [
    ask turtles with [in-which-zone = number-classrooms + 1] [
      if random 100 < 80 [set change-zone true
        set classrooms 1 + random number-classrooms
      set new-location-xcor (random size-classroom) + (10 + size-classroom) * ((classrooms - 1) mod (floor (200 / (10 + size-classroom)))) + 10
    set new-location-ycor (random size-classroom) + floor((classrooms - 1) / (floor (200 / (10 + size-classroom)))) * (10 + size-classroom) + 10
      ]
        if change-zone [setxy new-location-xcor new-location-ycor
    set in-which-zone classrooms]
    ]
  ]
end


;; If a turtle is sick, it infects other turtles on the same patch.
to infect ;; turtle procedure
  if (not masked? or (masked? and (random-float 100 < infectiousness-with-mask))) [
  ask other turtles in-cone infection-distance 360 with [ not sick-exposed?  ]
    [ifelse masked?
      [ if random-float 100 < infectiousness-with-mask [get-sick]]
      [ if random-float 100 < infectiousness [ get-sick ] ]
  ]
  ]
end

;; Once the turtle has been sick long enough, it
to isolate ;; turtle procedure
  if exposed-time > exposed-duration                        ;; If the turtle has survived past the virus' duration, then
      [ die ]
end


to startup

end


; Copyright 1998 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
280
10
1092
823
-1
-1
4.0
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
200
0
200
1
1
1
ticks
30.0

SLIDER
40
87
234
120
infectiousness
infectiousness
0.0
99.0
1.0
1.0
1
%
HORIZONTAL

BUTTON
62
48
132
83
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
138
48
209
84
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
0

PLOT
1125
215
1690
675
Populations
minutes
students
0.0
52.0
0.0
100.0
true
true
"" ""
PENS
"sick(all)" 1.0 0 -2064490 true "" "plot %infected"
"sick(masked)" 1.0 0 -4539718 true "" "plot %infected-masked"
"cumulative-infected" 1.0 0 -2674135 true "" "plot %cumulative-infected"

SLIDER
40
10
234
43
number-students
number-students
10
300
100.0
10
1
NIL
HORIZONTAL

MONITOR
28
568
103
613
NIL
%infected
1
1
11

MONITOR
105
568
227
613
NIL
%infected-masked
1
1
11

CHOOSER
40
195
185
240
turtle-shape
turtle-shape
"person" "circle"
1

SLIDER
40
280
252
313
infection-distance
infection-distance
0
5
3.0
1
1
meter
HORIZONTAL

SLIDER
40
325
217
358
rate-wearing-mask
rate-wearing-mask
0.01
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
40
365
242
398
class-duration
class-duration
10
60
40.0
10
1
minutes
HORIZONTAL

SLIDER
40
420
212
453
agent-speed
agent-speed
1
size-classroom / 2
20.0
1
1
NIL
HORIZONTAL

MONITOR
1120
15
1207
60
NIL
classroom1
17
1
11

MONITOR
1220
15
1302
60
NIL
classroom2
17
1
11

MONITOR
1315
15
1397
60
NIL
classroom3
17
1
11

MONITOR
1415
15
1497
60
NIL
classroom4
17
1
11

MONITOR
1505
15
1587
60
NIL
classroom5
17
1
11

MONITOR
1595
15
1677
60
NIL
classroom6
17
1
11

TEXTBOX
1120
95
1270
113
NIL
12
0.0
1

SLIDER
40
145
212
178
social-distance
social-distance
0
5
1.0
1
1
NIL
HORIZONTAL

SWITCH
1130
80
1357
113
visualize-social-distance
visualize-social-distance
1
1
-1000

TEXTBOX
1135
120
1285
170
this buttom will slow down the simulation speed.
12
0.0
1

SWITCH
1135
170
1482
203
allow-student-stayinclassroom-during-break
allow-student-stayinclassroom-during-break
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

This model simulates the transmission and perpetuation of a virus in a human population.

Ecological biologists have suggested a number of factors which may influence the survival of a directly transmitted virus within a population. (Yorke, et al. "Seasonality and the requirements for perpetuation and eradication of viruses in populations." Journal of Epidemiology, volume 109, pages 103-123)

## HOW IT WORKS

The model is initialized with 150 people, of which 10 are infected.  People move randomly about the world in one of three states: healthy but susceptible to infection (green), sick and infectious (red), and healthy and immune (gray). People may die of infection or old age.  When the population dips below the environment's "carrying capacity" (set at 300 in this model) healthy people may produce healthy (but susceptible) offspring.

Some of these factors are summarized below with an explanation of how each one is treated in this model.

### The density of the population

Population density affects how often infected, immune and susceptible individuals come into contact with each other. You can change the size of the initial population through the NUMBER-PEOPLE slider.

### Population turnover

As individuals die, some who die will be infected, some will be susceptible and some will be immune.  All the new individuals who are born, replacing those who die, will be susceptible.  People may die from the virus, the chances of which are determined by the slider CHANCE-RECOVER, or they may die of old age.

In this model, people die of old age at the age of 50 years.  Reproduction rate is constant in this model.  Each turn, if the carrying capacity hasn't been reached, every healthy individual has a 1% chance to reproduce.

### Degree of immunity

If a person has been infected and recovered, how immune are they to the virus?  We often assume that immunity lasts a lifetime and is assured, but in some cases immunity wears off in time and immunity might not be absolutely secure.  In this model, immunity is secure, but it only lasts for a year.

### Infectiousness (or transmissibility)

How easily does the virus spread?  Some viruses with which we are familiar spread very easily.  Some viruses spread from the smallest contact every time.  Others (the HIV virus, which is responsible for AIDS, for example) require significant contact, perhaps many times, before the virus is transmitted.  In this model, infectiousness is determined by the INFECTIOUSNESS slider.

### Duration of infectiousness

How long is a person infected before they either recover or die?  This length of time is essentially the virus's window of opportunity for transmission to new hosts. In this model, duration of infectiousness is determined by the DURATION slider.

### Hard-coded parameters

Four important parameters of this model are set as constants in the code (See `setup-constants` procedure). They can be exposed as sliders if desired. The turtles’ lifespan is set to 50 years, the carrying capacity of the world is set to 300, the duration of immunity is set to 52 weeks, and the birth-rate is set to a 1 in 100 chance of reproducing per tick when the number of people is less than the carrying capacity.

## HOW TO USE IT

Each "tick" represents a week in the time scale of this model.

The INFECTIOUSNESS slider determines how great the chance is that virus transmission will occur when an infected person and susceptible person occupy the same patch.  For instance, when the slider is set to 50, the virus will spread roughly once every two chance encounters.

The DURATION slider determines the number of weeks before an infected person either dies or recovers.

The CHANCE-RECOVER slider controls the likelihood that an infection will end in recovery/immunity.  When this slider is set at zero, for instance, the infection is always deadly.

The SETUP button resets the graphics and plots and randomly distributes NUMBER-PEOPLE in the view. All but 10 of the people are set to be green susceptible people and 10 red infected people (of randomly distributed ages).  The GO button starts the simulation and the plotting function.

The TURTLE-SHAPE chooser controls whether the people are visualized as person shapes or as circles.

Three output monitors show the percent of the population that is infected, the percent that is immune, and the number of years that have passed.  The plot shows (in their respective colors) the number of susceptible, infected, and immune people.  It also shows the number of individuals in the total population in blue.

## THINGS TO NOTICE

The factors controlled by the three sliders interact to influence how likely the virus is to thrive in this population.  Notice that in all cases, these factors must create a balance in which an adequate number of potential hosts remain available to the virus and in which the virus can adequately access those hosts.

Often there will initially be an explosion of infection since no one in the population is immune.  This approximates the initial "outbreak" of a viral infection in a population, one that often has devastating consequences for the humans concerned. Soon, however, the virus becomes less common as the population dynamics change.  What ultimately happens to the virus is determined by the factors controlled by the sliders.

Notice that viruses that are too successful at first (infecting almost everyone) may not survive in the long term.  Since everyone infected generally dies or becomes immune as a result, the potential number of hosts is often limited.  The exception to the above is when the DURATION slider is set so high that population turnover (reproduction) can keep up and provide new hosts.

## THINGS TO TRY

Think about how different slider values might approximate the dynamics of real-life viruses.  The famous Ebola virus in central Africa has a very short duration, a very high infectiousness value, and an extremely low recovery rate. For all the fear this virus has raised, how successful is it?  Set the sliders appropriately and watch what happens.

The HIV virus, which causes AIDS, has an extremely long duration, an extremely low recovery rate, but an extremely low infectiousness value.  How does a virus with these slider values fare in this model?

## EXTENDING THE MODEL

Add additional sliders controlling the carrying capacity of the world (how many people can be in the world at one time), the average lifespan of the people and their birth-rate.

Build a similar model simulating viral infection of a non-human host with very different reproductive rates, lifespans, and population densities.

Add a slider controlling how long immunity lasts. You could also make immunity imperfect, so that immune turtles still have a small chance of getting infected. This chance could get higher over time.

## VISUALIZATION

The circle visualization of the model comes from guidelines presented in
Kornhauser, D., Wilensky, U., & Rand, W. (2009). http://ccl.northwestern.edu/papers/2009/Kornhauser,Wilensky&Rand_DesignGuidelinesABMViz.pdf.

At the lowest level, perceptual impediments arise when we exceed the limitations of our low-level visual system. Visual features that are difficult to distinguish can disable our pre-attentive processing capabilities. Pre-attentive processing can be hindered by other cognitive phenomena such as interference between visual features (Healey 2006).

The circle visualization in this model is supposed to make it easier to see when agents interact because overlap is easier to see between circles than between the "people" shapes. In the circle visualization, the circles merge to create new compound shapes. Thus, it is easier to perceive new compound shapes in the circle visualization.
Does the circle visualization make it easier for you to see what is happening?

## RELATED MODELS

* HIV
* Virus on a Network

## CREDITS AND REFERENCES

This model can show an alternate visualization of the Virus model using circles to represent the people. It uses visualization techniques as recommended in the paper:

Kornhauser, D., Wilensky, U., & Rand, W. (2009). Design guidelines for agent based model visualization. Journal of Artificial Societies and Social Simulation, JASSS, 12(2), 1.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1998).  NetLogo Virus model.  http://ccl.northwestern.edu/netlogo/models/Virus.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1998 2001 -->
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
1
@#$#@#$#@
