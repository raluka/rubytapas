
# #+TITLE: #fetch for Defaults
# #+SETUPFILE: ../defaults.org

# In a previous episode, we looked at how the =#fetch= method on =Hash=
# can be used to assert that a given hash key is present.

auth = {
  'uid'  => 12345,
  'info' => {
  }
}

# ...

email_address = auth['info'].fetch('email')
# ~> -:11:in `fetch': key not found: "email" (KeyError)
# ~>    from -:11:in `<main>'

# But what if the =KeyError= that Hash raises doesn't provide enough
# context for a useful error message?

# Along with the key to fetch, the =#fetch= method can also receive an
# optional block. This block is evaluated if, and only if, the key is
# /not/ found.

# Knowing this, we can pass a block to =#fetch= which raises a custom
# exception:

auth['uid'] # => 12345
auth['info'].fetch('email') do 
  raise "Invalid auth data (missing email)."\
        "See https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema"
end
email_address = auth['info'].fetch('email')
# ~> -:10:in `block in <main>': Invalid auth data (missing email).See https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema (RuntimeError)
# ~>    from -:8:in `fetch'
# ~>    from -:8:in `<main>'

# Now when this code encounters an unexpectedly missing key, the raised
# exception will explain both the problem, and where to find more
# information.

# The block argument to =#fetch= isn't just for raising errors,
# however. If it doesn't raise an exception, =#fetch= will return the
# result value of the block to the caller, meaning that =#fetch= is also
# very useful for providing default values. So, for instance, we can
# provide a default email address when none is specified.

email_address = auth['info'].fetch('email'){ 'anonymous@example.org' }
email_address # => "anonymous@example.org"

# Now, you may be wondering: what's the difference between using
# =#fetch= for defaults, and using the =||= operator for default values?
# While these may seem equivalent at first, they actually behave in
# subtly, but importantly different ways. Let's explore the differences.

# Here's an example of using the =||= operator for a default. This code
# receives an options hash, and uses the =:logger= key to find a logger
# object. If the key isn't specified, it creates a default logger to
# =$stdout=. If the key is =nil= or =false=, it disables logging by
# substituting a =NullLogger= object.

# This works fine when we give it an empty =Hash=.

require 'logger'

class NullLogger
  def method_missing(*); end
end

options = {}
logger = options[:logger] || Logger.new($stdout) 
unless logger
  logger = NullLogger.new
end
logger
# => #<Logger:0x000000030545a8
#     @default_formatter=
#      #<Logger::Formatter:0x00000003054580 @datetime_format=nil>,
#     @formatter=nil,
#     @level=0,
#     @logdev=
#      #<Logger::LogDevice:0x00000003054530
#       @dev=#<IO:<STDOUT>>,
#       @filename=nil,
#       @mutex=
#        #<Logger::LogDevice::LogDeviceMutex:0x00000003054508
#         @mon_count=0,
#         @mon_mutex=#<Mutex:0x000000030544b8>,
#         @mon_owner=nil>,
#       @shift_age=nil,
#       @shift_size=nil>,
#     @progname=nil>

# But when we pass =false= as the value of =:logger=, we get a surprise:

options = {logger: false}
logger = options[:logger] || Logger.new($stdout) 
unless logger
  logger = NullLogger.new
end
logger
# => #<Logger:0x000000040bb608
#     @default_formatter=
#      #<Logger::Formatter:0x000000040bb5e0 @datetime_format=nil>,
#     @formatter=nil,
#     @level=0,
#     @logdev=
#      #<Logger::LogDevice:0x000000040bb590
#       @dev=#<IO:<STDOUT>>,
#       @filename=nil,
#       @mutex=
#        #<Logger::LogDevice::LogDeviceMutex:0x000000040bb568
#         @mon_count=0,
#         @mon_mutex=#<Mutex:0x000000040bb518>,
#         @mon_owner=nil>,
#       @shift_age=nil,
#       @shift_size=nil>,
#     @progname=nil>

# That was supposed to be a =NullLogger=, not the default logger!

# So what happened here? The problem with using =||= with a =Hash= for
# default values is that it can't differentiate between a /missing/ key,
# versus a key whose value is =nil= or =false=. Here's some code to
# demonstrate:

{}[:foo] || :default             # => :default
{foo: nil}[:foo] || :default     # => :default
{foo: false}[:foo] || :default   # => :default

# In contrast, =#fetch= only resorts to the default when the given key
# is actually missing:

{}.fetch(:foo){:default}             # => :default
{foo: nil}.fetch(:foo){:default}     # => nil
{foo: false}.fetch(:foo){:default}   # => false

# When we switch to using =#fetch= in our logger-defaulting code, it
# works as intended.

options = {logger: false}
logger = options.fetch(:logger){Logger.new($stdout)}
unless logger
  logger = NullLogger.new
end
logger
# => #<NullLogger:0x00000003b73858>
