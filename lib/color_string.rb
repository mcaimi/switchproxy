#!/usr/bin/env ruby

=begin
Colored Output -- String Helper
=end

# Patch the built-in String Class to support colored text output
class String
  
  # define color codes
  $COLORS = {:reset => "\033[0m",
    :red => "\033[0;31m",
    :blue => "\033[0;34m",
    :yellow => "\033[1;33m",
    :green => "\033[0;32m",
    :purple => "\033[0;35m"
  }

  # generate color output methods
  $COLORS.keys.each do |key|
    define_method "#{key}" do
      return $COLORS[key] + self.to_s + $COLORS[:reset]
    end
  end

  # console event reporting metods
  # display event results with different colored strings
  # These methods do not print anything, they just return a string

  # => INFO LEVEL EVENT
  def einfo()
    return $COLORS[:green] + "*" + "\t" + $COLORS[:reset] + self.to_s
  end

  # => WARNING LEVEL EVENT
  def ewarn()
    return $COLORS[:yellow] + "*" + "\t" + $COLORS[:reset] + self.to_s
  end

  # => ERROR LEVEL EVENT
  def eerr()
    return $COLORS[:red] + "*" + "\t" + $COLORS[:reset] + self.to_s
  end
end
## EOF ##
