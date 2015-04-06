
# #+TITLE: super
# #+SETUPFILE: ../defaults.org

# Let's talk about calling superclass methods.

# As you know, when class =Child= inherits from class =Parent=, and both
# define a method =#hello=, the =Child= can reference the =Parent='s
# implementation of =#hello=, using =super=.

# #+name: parent1

class Parent
  def hello(subject="World")
    puts "Hello, #{subject}"
  end
end

# #+name: child1

class Child < Parent
  def hello(subject)
    super(subject)
    puts "How are you today?"
  end
end

class Parent
  def hello(subject="World")
    puts "Hello, #{subject}"
  end
end

class Child < Parent
  def hello(subject)
    super(subject)
    puts "How are you today?"
  end
end

Child.new.hello("Bob")

# #+RESULTS:
# : Hello, Bob
# : How are you today?


# If we simply want to call the parent implementation with the same
# arguments that were passed to the child implementation, we can omit
# the arguments to =super=. This *only* works if we leave off the
# parentheses as well.

# #+name: child2

class Child < Parent
  def hello(subject)
    puts super
    puts "How are you today?"
  end
end

# This makes our code less brittle, because changes to a parent method's
# parameter list won't mean having to hunt around and update every
# =super= call that invokes it.

# Sometimes we may want to force zero arguments to be passed to the
# superclass method. In that case, it's important to remember to
# explicitly supply empty parentheses instead of leaving them off.

# Here's a version of =Child= that takes a special flag to indicate that
# it should use its default subject. When the flag is passed, it calls
# =super= with empty parentheses, forcing the superclass method to
# resort to the default value for =subject=.

# #+name: child3

class Child < Parent
  def hello(subject=:default)
    if subject == :default
      super() 
      puts "How are you today?"
    else
      super(subject)
      puts "How are you today?"
    end
  end
end

class Parent
  def hello(subject="World")
    puts "Hello, #{subject}"
  end
end

class Child < Parent
  def hello(subject=:default)
    if subject == :default
      super() 
      puts "How are you today?"
    else
      super(subject)
      puts "How are you today?"
    end
  end
end

Child.new.hello(:default)

# #+RESULTS:
# : Hello, World
# : How are you today?

# There's a catch to this, though: even with explicit empty parens,
# calling super will still automatically pass along any block given to
# the child method.

# To show what I mean, let's modify the parent class method to take a
# block, and then pass a block to the call to =#hello=.

# #+name: parent2

class Parent
  def hello(subject="World")
    puts "Hello, #{subject}"
    if block_given?
      yield
      puts "Well, nice seeing you!"
    end
  end
end

class Parent
  def hello(subject="World")
    puts "Hello, #{subject}"
    if block_given?
      yield
      puts "Well, nice seeing you!"
    end
  end
end

class Child < Parent
  def hello(subject=:default)
    if subject == :default
      super() 
      puts "How are you today?"
    else
      super(subject)
      puts "How are you today?"
    end
  end
end  

Child.new.hello(:default) do
  puts "Hi there, Child!"
end
# >> Hello, World
# >> Hi there, Child!
# >> Well, nice seeing you!
# >> How are you today?

# #+RESULTS:
# : Hello, World
# : Hi there, Child!
# : Well, nice seeing you!
# : How are you today?

# As you can see, the output is a little mixed-up due to the block being
# unexpectedly passed-through despite the empty argument list to =super=.

# In order to suppress the block being passed through, we have to use
# the special argument =&nil=:

# #+name: child4

class Child < Parent
  def hello(subject=:default)
    if subject == :default
      super(&nil) 
      puts "How are you today?"
    else
      super(subject, &nil)
      puts "How are you today?"
    end
  end
end

class Parent
  def hello(subject="World")
    puts "Hello, #{subject}"
    if block_given?
      yield
      puts "Well, nice seeing you!"
    end
  end
end

class Child < Parent
  def hello(subject=:default)
    if subject == :default
      super(&nil) 
      puts "How are you today?"
    else
      super(subject, &nil)
      puts "How are you today?"
    end
  end
end

Child.new.hello(:default) do
  puts "Hi there, Child"
end
