# Calculation code
##################
class Vector
  constructor: (@x, @y) ->

  minus: (other) -> new Vector @x - other.x, @y - other.y
  plus: (other) -> new Vector @x + other.x, @y + other.y

  times: (scalar) -> new Vector @x * scalar, @y * scalar

  magnitude: -> Math.sqrt @x ** 2 + @y ** 2

  distance: (other) -> @minus(other).magnitude()

  unit: -> @times 1 / @magnitude()

class Dipole
  constructor: (@q, @s) ->
    @pos = new Vector -@s / 2, 0
    @neg = new Vector @s / 2, 0

  field: (r, theta) ->
    location = new Vector r * Math.cos(theta), r * Math.sin(theta)

    posMag = Dipole.COULOMB_CONSTANT * @q / location.distance(@pos) ** 2
    negMag = Dipole.COULOMB_CONSTANT * -@q / location.distance(@neg) ** 2

    posUnit = location.minus(@pos).unit()
    negUnit = location.minus(@neg).unit()

    posVector = posUnit.times posMag
    negVector = negUnit.times negMag

    sum = posVector.plus negVector

    return {
      m: sum.magnitude()
      angle: Math.atan2 sum.y, sum.x
    }

k = Dipole.COULOMB_CONSTANT = 8.987e9

# Code for LIVE GRAPHING
########################

canvas = document.querySelector 'canvas'
ctx = canvas.getContext '2d'

canvas.width = canvas.height = 500

ymin = ymax = null

render = (q, s, rmin, rmax, theta) ->
  console.log 'JUST RENDERED', q, s, rmin, rmax, theta
  dipole = new Dipole q, s

  x_array = []
  y_array = []
  second_y_array = []

  if thetaRangeElement.checked
    for t in [-Math.PI...Math.PI] by 2 * Math.PI / canvas.width
      x_array.push t
      if ANGLE
        y_array.push dipole.field(rmax, t).angle
      else
        y_array.push dipole.field(rmax, t).m

      if functionElement.value.length > 0
        second_y_array.push eval(functionElement.value)
  else
    for r in [rmin...rmax] by (rmax - rmin) / canvas.width
      x_array.push r
      if ANGLE
        y_array.push dipole.field(r, theta).angle
      else
        y_array.push dipole.field(r, theta).m

      if functionElement.value.length > 0
        second_y_array.push eval(functionElement.value)

  ymin = 0 #Math.min.apply @, y_array
  ymax = Math.max.apply @, y_array

  ctx.clearRect 0, 0, canvas.width, canvas.height

  if ANGLE
    ymin = -Math.PI
    ymax = Math.PI

    ctx.font = '20px Arial'
    ctx.fillText '\u03C0', 0, 20
    ctx.fillText '-\u03C0', 0, canvas.height - 40
  else
    ctx.font = '20px Arial'
    ctx.fillText ymax.toPrecision(3) + 'N/C', 0, 20
    ctx.fillText ymin.toPrecision(3) + 'N/C', 0, canvas.height - 40
  if thetaRangeElement.checked
    ctx.fillText '-\u03C0', 20, canvas.height - 20
    ctx.fillText '\u03C0', canvas.width - ctx.measureText('-\u03C0').width, canvas.height - 40
  else
    ctx.fillText RMIN.toPrecision(3) + 'm', 20, canvas.height - 20
    ctx.fillText RMAX.toPrecision(3) + 'm', canvas.width - ctx.measureText(RMAX.toPrecision(3) + 'm').width, canvas.height - 20

  ctx.beginPath()
  ctx.moveTo 0, canvas.height * (1 - (y_array[0] - ymin) / (ymax - ymin))
  for el, i in y_array
    ctx.lineTo i, canvas.height * (1 - (el - ymin) / (ymax - ymin))
  ctx.strokeStyle = '#000'
  ctx.stroke()
  if second_y_array.length > 0
    ctx.beginPath()
    ctx.moveTo 0, canvas.height * (1 - (second_y_array[0] - ymin) / (ymax - ymin))
    for el, i in second_y_array
      ctx.lineTo i, canvas.height * (1 - (el - ymin) / (ymax - ymin))
    ctx.strokeStyle = '#F00'
    ctx.stroke()

rminElement = document.querySelector('#rmin')
rmaxElement = document.querySelector('#rmax')
thetaElement = document.querySelector('#theta')
thetaRangeElement = document.querySelector('#thetarange')
functionElement = document.querySelector('#function')
angleElement = document.querySelector('#angle')
qElement = document.querySelector('#q')
sElement = document.querySelector('#s')
cElement = document.querySelector('#C')

ANGLE = false
RMIN = 0
RMAX = 10
THETA = Math.PI / 4
Q = 1e-9
S = 1
C = 0

rminElement.addEventListener 'input', ->
  RMIN = Number rminElement.value
  render Q, S, RMIN, RMAX, THETA

rmaxElement.addEventListener 'input', ->
  RMAX = Number rmaxElement.value
  render Q, S, RMIN, RMAX, THETA

thetaElement.addEventListener 'input', ->
  THETA = Number(thetaElement.value) * Math.PI / 180
  render Q, S, RMIN, RMAX, THETA

qElement.addEventListener 'input', ->
  Q = Number qElement.value
  render Q, S, RMIN, RMAX, THETA

sElement.addEventListener 'input', ->
  S = Number sElement.value
  render Q, S, RMIN, RMAX, THETA

functionElement.addEventListener 'input', ->
  S = Number sElement.value
  render Q, S, RMIN, RMAX, THETA

thetaRangeElement.addEventListener 'change', ->
  render Q, S, RMIN, RMAX, THETA

angleElement.addEventListener 'change', ->
  console.log 'changed...'
  if angleElement.value is 'angle'
    ANGLE = true
  else
    ANGLE = false
  render Q, S, RMIN, RMAX, THETA

render Q, S, RMIN, RMAX, THETA

canvas.addEventListener 'mousemove', (event) ->
  if thetaRangeElement.checked
    canvas.setAttribute 'title', "(#{event.offsetX * 2 * Math.PI / canvas.width - Math.PI}, #{event.offsetY * (ymax - ymin) / canvas.height + ymin})"
  else
    canvas.setAttribute 'title', "(#{event.offsetX * (RMAX - RMIN) / canvas.width + RMIN}, #{event.offsetY * (ymax - ymin) / canvas.height + ymin})"

# Code to GENERATE A SPREADSHEET (deprecated)
################################
###
generate = (q, s, rmin, rmax) ->
  dipole = new Dipole q, s

  # Along the x-axis
  rows = []
  for r in [rmin...rmax] by (rmax - rmin) / 100
    {m, angle} = dipole.field r, 0
    rows.push [r, m]
  fs.writeFileSync 'x-axis.csv', rows.map((row) -> row.join(',')).join('\n')

  # Along the x-axis
  rows = []
  for r in [rmin...rmax] by (rmax - rmin) / 100
    {m, angle} = dipole.field r, Math.PI / 2
    rows.push [r, m]
  fs.writeFileSync 'y-axis.csv', rows.map((row) -> row.join(',')).join('\n')

  # Along the line x = y
  rows = []
  for r in [rmin...rmax] by (rmax - rmin) / 100
    {m, angle} = dipole.field r, Math.PI / 2
    rows.push [r, m, angle]
  fs.writeFileSync 'xy.csv', rows.map((row) -> row.join(',')).join('\n')

  # vs theta (symmetric after pi)
  rows = []
  for t in [0...Math.PI] by Math.PI / 100
    {m, angle} = dipole.field rmax, t
    rows.push [t, m, angle]
  fs.writeFileSync 'theta.csv', rows.map((row) -> row.join(',')).join('\n')

# We examine a dipole of two protons a millimeter apart.
fs = require 'fs'
generate 1.6e-19, 0.01, 0.011, 0.2
###
