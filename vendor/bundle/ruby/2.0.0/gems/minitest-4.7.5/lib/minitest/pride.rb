require "minitest/unit"

##
# Show your testing pride!

class PrideIO

  # Start an escape sequence
  ESC = "\e["

  # End the escape sequence
  NND = "#{ESC}0m"

  # The IO we're going to pipe through.
  attr_reader :io

  def initialize io # :nodoc:
    @io = io
    # stolen from /System/Library/Perl/5.10.0/Term/ANSIColor.pm
    # also reference http://en.wikipedia.org/wiki/ANSI_escape_code
    @colors ||= (31..36).to_a
    @size   = @colors.size
    @index  = 0
    # io.sync = true
  end

  ##
  # Wrap print to colorize the output.

  def print o
    case o
    when "." then
      io.print pride o
    when "E", "F" then
      io.print "#{ESC}41m#{ESC}37m#{o}#{NND}"
    else
      io.print o
    end
  end

  def puts(*o) # :nodoc:
    o.map! { |s|
      s.to_s.sub(/Finished tests/) {
        @index = 0
        'Fabulous tests'.split(//).map { |c|
          pride(c)
        }.join
      }
    }

    super
  end

  ##
  # Color a string.

  def pride string
    string = "*" if string == "."
    c = @colors[@index % @size]
    @index += 1
    "#{ESC}#{c}m#{string}#{NND}"
  end

  def method_missing msg, *args # :nodoc:
    io.send(msg, *args)
  end
end

##
# If you thought the PrideIO was colorful...
#
# (Inspired by lolcat, but with clean math)

class PrideLOL < PrideIO
  PI_3 = Math::PI / 3 # :nodoc:

  def initialize io # :nodoc:
    # walk red, green, and blue around a circle separated by equal thirds.
    #
    # To visualize, type this into wolfram-alpha:
    #
    #   plot (3*sin(x)+3), (3*sin(x+2*pi/3)+3), (3*sin(x+4*pi/3)+3)

    # 6 has wide pretty gradients. 3 == lolcat, about half the width
    @colors = (0...(6 * 7)).map { |n|
      n *= 1.0 / 6
      r  = (3 * Math.sin(n           ) + 3).to_i
      g  = (3 * Math.sin(n + 2 * PI_3) + 3).to_i
      b  = (3 * Math.sin(n + 4 * PI_3) + 3).to_i

      # Then we take rgb and encode them in a single number using base 6.
      # For some mysterious reason, we add 16... to clear the bottom 4 bits?
      # Yes... they're ugly.

      36 * r + 6 * g + b + 16
    }

    super
  end

  ##
  # Make the string even more colorful. Damnit.

  def pride string
    c = @colors[@index % @size]
    @index += 1
    "#{ESC}38;5;#{c}m#{string}#{NND}"
  end
end

klass = ENV['TERM'] =~ /^xterm|-256color$/ ? PrideLOL : PrideIO
MiniTest::Unit.output = klass.new(MiniTest::Unit.output)
