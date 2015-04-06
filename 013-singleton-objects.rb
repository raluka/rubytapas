
# #+TITLE: Singleton Objects
# #+SETUPFILE: ../defaults.org

# While I was at Ruby DCamp a few weeks ago Sandi Metz asked me to write
# a version of Conway's Game of Life in a semi-functional, stateless
# style. I decided to represent the concept of a "live cell" and a "dead
# cell" as two different kinds of object. The game grid would then be
# represented by a simple array of arrays, populated by live cells and
# dead cells.

# I was all set to write a class for each...

class LiveCell
  # ...
end

class DeadCell
  # ...
end

# ...when it occurred to me: since this is a stateless implementation,
# there was no real need to have individual =LiveCell= objects for every
# live cell on the board. And the same goes for dead cells. Without any
# state, every instance would be exactly the same. And since the objects
# didn't have any need for initialization, why even bother with classes?

# Instead, I created the objects as singleton instances of the =Object=
# class. I assigned the instances to constants, so they would be
# available anywhere in the program. Then I used Ruby's singleton class
# syntax to add methods to each one. Each object needed two methods: a
# =#to_s= method to represent the cell on an ASCII grid, and a method to
# determine what the next generation of its grid square would contain:
# either a live cell or a dead cell.

LIVE_CELL = Object.new
class << LIVE_CELL
  def to_s() 'o' end

  def next_generation(x, y, board)
    case board.neighbors(x,y).count(LIVE_CELL)
    when 2..3 then self
    else DEAD_CELL
    end
  end
end

DEAD_CELL = Object.new
class << DEAD_CELL
  def to_s() '.' end

  def next_generation(x, y, board)
    case board.neighbors(x,y).count(LIVE_CELL)
    when 3 then LIVE_CELL
    else self
    end
  end
end

# Then I could just populate my grid with the same LIVE_CELL and
# DEAD_CELL objects, over and over again.

[
 [DEAD_CELL, LIVE_CELL, LIVE_CELL, DEAD_CELL],
 # ...
]

# This worked quite well, but I didn't like the fact that the singleton
# objects had to be created in two steps. So I decided to see if I could
# create the object, assign it to a constant, and define methods on it,
# all in a single statement.

# To accomplish this feat, I took advantage of the fact that Ruby allows
# variables and constants to be assigned inside parenthesized
# sub-expressions of a statement.

class << (LIVE_CELL = Object.new)
  def to_s() 'o' end

  def next_generation(x, y, board)
    case board.neighbors(x,y).count(LIVE_CELL)
    when 2..3 then self
    else DEAD_CELL
    end
  end
end

class << (DEAD_CELL = Object.new)
  def to_s() '.' end

  def next_generation(x, y, board)
    case board.neighbors(x,y).count(LIVE_CELL)
    when 3 then LIVE_CELL
    else self
    end
  end
end

# The resulting syntax was a bit obscure, but it accomplished my purpose
# succinctly.

# A class plays two roles in an OO program:

# 1. It provides a container for behavior that's shared by many objects.
# 2. It acts as an /object factory/, manufacturing new instances and
#    ensuring they are initialized correctly.

# When we have an object which does not need to share behavior with any
# others objects, and which requires no initialization, that renders
# both roles of a class superfluous. In cases like this, it can make
# more sense to just use a one-off singleton object.

# Another way to accomplish this is to use a module as our singleton
# object, and only define class-level methods on the module. Let's
# update the example to use this approach instead.

module LiveCell
  def self.to_s() 'o' end

  def self.next_generation(x, y, board)
    case board.neighbors(x,y).count(LiveCell)
    when 2..3 then self
    else DeadCell
    end
  end
end

module DeadCell
  def self.to_s() '.' end

  def self.next_generation(x, y, board)
    case board.neighbors(x,y).count(LiveCell)
    when 3 then LiveCell
    else self
    end
  end
end

[
 [DeadCell, LiveCell, LiveCell, DeadCell],
 # ...
]
