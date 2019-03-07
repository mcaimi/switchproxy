#!/usr/bin/env ruby

=begin
    Directory Walk Class
=end

require 'color_string'
require 'generator'

# exceptions
class MissingCodeBlockException < Exception; end
class DirectoryDoesNotExistException < Exception; end

# Dorectory walker class
class Walker
  # constructor
  def initialize(dirpath)
      raise DirectoryDoesNotExistException, "Directory does not exist" if !File.exists? dirpath
      @working_directory = dirpath
      @dir_accessor = Dir[@working_directory + "/*.yaml"]
  end
    
  # config file iterator
  def each_profile
    if block_given?
      @dir_accessor.each do |profile_file|
        yield profile_file
      end
    else
      raise MissingCodeBlockException, "Walker::each_rule() requires a code block!".eerror()
    end
  end
  
  # search for a specific rule
  def search(profile_name)
    self.each_profile do |profile|
      # compare every 'name' field contained in each yaml rule specification fiel
      temp_spec = ProxyProfile.new(profile)
      return temp_spec if (temp_spec.name == profile_name)
    end
    
    # no rule found
    return nil
  end
  
  # print a list of all defined rules
  def list()
    "Profiles Currently Configured In The Configuration Directory:".yellow
    self.each_profile {|profile| puts "Proxy Spec: ".einfo() + ProxyProfile.new(profile).name }
    puts ""
  end
end
