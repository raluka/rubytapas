
# #+TITLE: Subclassing Array
# #+SETUPFILE: ../defaults.org

# Sooner or later you will find yourself wanting a data structure which
# is almost, but not quite, exactly like a built-in Ruby Array. For
# instance, let's say we have a list of tags. We'd like it to behave
# more or less like an array, except that strings containing spaces
# should be separated into individual tags on insertion, and converting
# the list to a string should result in a space-separated list.

tags = TagList.new
tags << "foo", "bar", "baz buz"

# The first thing that occurs to us is to make =TagList= a subclass of
# =Array=.

# #+name: taglist_array :exports none

class TagList < Array
  def <<(tag)
    tag.to_s.strip.split.each do |t|
      super(t)
    end
    self
  end
  
  def to_s
    join(" ")
  end
end

class TagList < Array
  def <<(tag)
    tag.to_s.strip.split.each do |t|
      super(t)
    end
    self
  end
  
  def to_s
    join(" ")
  end
end

tags = TagList.new
tags << "foo" << "bar" << "baz buz"
tags.to_s # =>
tags.grep(/b/) # =>

# #+RESULTS:

class TagList < Array
  def <<(tag)
    tag.to_s.strip.split.each do |t|
      super(t)
    end
    self
  end
  
  def to_s
    join(" ")
  end
end

tags = TagList.new
tags << "foo" << "bar" << "baz buz"
tags.to_s # => "foo bar baz buz"
tags.grep(/ba/) # => ["bar", "baz", "buz"]

# #+RESULTS:

# At first blush this seems like a perfect solution. Our custom
# insertion behavior works correctly, the object stringifies the way we
# want it to, and otherwise it behaves like a normal array.

# But one day we discover a fly in the ointment. We have some code that
# merges two =TagLists= together. After they are merged, they stop
# behaving like =TagLists=!

tl1 = TagList.new(%w[apple banana])
tl2 = TagList.new(%w[peach pear])
tl1.to_s # => "apple banana"
tl2.to_s # => "peach pear"
tl3 = tl1 + tl2
tl3.to_s # => "[\"apple\", \"banana\", \"peach\", \"pear\"]"

# On further investigation, we discover that the merged object isn't
# even a =TagList=---it's an ordinary =Array=!

tl3.class # => Array

# What's going on here?!

# The explanation boils down to limitations in the Ruby
# implementation. For efficiency, many core class methods are
# coded in C instead of Ruby. And in some cases, such as this =Array=
# addition operator, they are implemented in such a way that the class
# of the return value is hardcoded.

# If we subclass core classes, such as =Array=, =String=, and =Hash=, we
# will eventually run up against these limitations. The results can be
# surprising and frustrating.

# Fortunately, there's a way around this mess. Instead of subclassing,
# we can use delegation. Here's a version of the =TagList= that
# doesn't subclass =Array=, but is instead implemented /in terms of/ an
# internal =Array=.

class TagList
  def initialize(*args)
    @list = Array.new(*args)
  end

  def <<(tag)
    tag.to_s.strip.split.each do |t|
      list << t
    end
    self
  end
  
  def to_s
    list.join(" ")
  end

  protected

  attr_reader :list
end

tl1 = TagList.new(%w[apple banana])
tl2 = TagList.new(%w[peach pear])
tl1.to_s # => "apple banana"
tl2.to_s # => "peach pear"

# To make =TagList= addition work, we can add a "plus" operator that
# adds the internal arrays and then wraps the result in a =TagList=.

class TagList
  def initialize(*args)
    @list = Array.new(*args)
  end

  def <<(tag)
    tag.to_s.strip.split.each do |t|
      list << t
    end
    self
  end
  
  def to_s
    list.join(" ")
  end

  def +(other)
    self.class.new(list + other.list)
  end

  protected

  attr_reader :list
end

tl1 = TagList.new(%w[apple peach])
tl2 = TagList.new(%w[pear banana])
tl1 + tl2 # => apple peach pear banana

# But what about all those other great =Enumerable= methods, like
# =#map=, =#select=, =#grep=, or =#group_by=? Do we have to delegate
# each one individually?

# Thankfully, no. All we need to do is delegate one more method,
# =#each=, then include the =Enumerable= module. All of =Enumerable='s
# methods are implemented in terms of =#each=, so our =TagList= now has
# the full power of =Enumerable= available.

class TagList
  include Enumerable

  def initialize(*args)
    @list = Array.new(*args)
  end

  def <<(tag)
    tag.to_s.strip.split.each do |t|
      list << t
    end
    self
  end
  
  def to_s
    list.join(" ")
  end

  def +(other)
    self.class.new(list + other.list)
  end

  def each(*args, &block)
    list.each(*args, &block)
  end

  protected

  attr_reader :list
end

tl1 = TagList.new(%w[apple peach pear banana])
tl1.grep(/p/) # => ["apple", "peach", "pear"]
tl1.map(&:reverse) # => ["elppa", "hcaep", "raep", "ananab"]
tl1.group_by(&:size)
# => {5=>["apple", "peach"], 4=>["pear"], 6=>["banana"]}
