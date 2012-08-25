
import graphics from love
import push, pop, scale, translate from graphics

require "lovekit.image"

export *

-- holds a collection of Animators assigned to a state
class StateAnim
  new: (initial, @states) =>
    @current_name = nil
    @set_state initial
    @paused = false

  set_state: (name) =>
    @current = @states[name]
    @current\reset if name != @current_name
    @current_name = name

  update: (dt) =>
    @current\update dt if not @paused

  draw: (x,y) =>
    @current\draw x, y


-- animating a series of cells from a Spriter
class Animator
  get_width: => @sprite.cell_w
  get_height: => @sprite.cell_h

  -- @sequence array of cell ids to animate
  -- @rate time between each frame in seconds
  -- @flip flip all frames horizontally if true
  new: (@sprite, @sequence, @rate=0, @flip_x=false, @flip_y=false) =>
    @reset!

  reset: =>
    @time = 0
    @i = 1

  update: (dt) =>
    if @rate > 0
      @time += dt
      if @time > @rate
        @time -= @rate
        @i = @i + 1
        @i = 1 if @i > #@sequence

  draw: (x, y) =>
    @sprite\draw_cell @sequence[@i], x, y, @flip_x, @flip_y

  -- draw frame based on time form 0 to 1
  drawt: (t, x, y) =>
    k = math.max 1, math.ceil t * #@sequence
    @sprite\draw_cell @sequence[k], x, y, @flip_x, @flip_y

-- used for blitting
class Spriter
  new: (@img, @cell_w, @cell_h=cell_w, @width=0) =>
    @img = imgfy @img

    @iw, @ih = @img\width!, @img\height!

    @ox = 0
    @oy = 0

    @quads = {}

  seq: (...) => Animator self, ...

  quad_for: (i) =>
    if not @quads[i]
      @quads[i] = if type(i) == "string" -- "x,y,w,h"
        x, y, w, h = i\match "(%d+),(%d+),(%d+),(%d+)"
        graphics.newQuad x, y, w, h, @iw, @ih
      else
        sx, sy = if @width == 0
          @ox + i * @cell_w, @oy
        else
          @ox + (i % @width) * @cell_w, @oy + math.floor(i / @width) * @cell_h

        graphics.newQuad sx, sy, @cell_w, @cell_h, @iw, @ih

    @quads[i]

  draw_sized: (i, x,y, w,h) =>
    q = @quad_for i

    sx = w / @cell_w
    sy = h / @cell_h
    @img\drawq q, x, y, 0, sx, sy

    nil

  draw_cell: (i, x, y, flip_x=false, flip_y=false) =>
    q = @quad_for i

    if flip_x or flip_y
      q\flip flip_x, flip_y
      @img\drawq q, x, y
      q\flip flip_x, flip_y
    else
      @img\drawq q, x, y
    nil


