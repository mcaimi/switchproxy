#!/usr/bin/env ruby

=begin
    Main
=end

$: << File.expand_path(File.dirname(__FILE__)) + "/lib"

# global requires
require 'color_string'
require 'generator'
require 'directory'
require 'optparse'

# commandline parser class
cfg = Hash.new
oParser = OptionParser.new do |o|
    o.banner = "SwitchProxy v0.1"

    # help switch
    o.on("-h", "--help", "Shows this help screen") do
        puts o
        exit(0)
    end
    
    # status switch
    cfg[:showstatus] = false
    o.on("-s", "--status", "Shows proxy status in the current shell environment") do
        cfg[:showstatus] = true
    end
    
    # proxy selection switch
    cfg[:proxyspec] = nil
    o.on("-u", "--use PROXYSPEC", "Use the specified proxy configuration") do |spec|
        cfg[:proxyspec] = spec
    end
    
    # proxy spec list
    cfg[:listspecs] = false
    o.on("-l", "--list", "lists all defined proxy specs") do
        cfg[:listspecs] = true
    end
end

# global path array
$config_path = {
                :main_path => "/home/marco/Work/Sources/switchproxy/specs/",
                :secondary_path => "/usr/local/etc/switchproxy",
                :tertiary_path => "/etc/switchproxy"
              }

# main class
class Main
    # constructor
    def initialize
        begin
            @main_repo = Walker.new($config_path[:main_path])
        rescue DirectoryDoesNotExistException => e
            puts "Error: #{e.message}"
            exit(-1)
        end
    end
    
    # show current status
    def showstatus
        # check current proxy configuration
        # read from shell environment
        puts "Currently Configured Proxy is:".green
        if (ENV.has_key? "PROXYPROFILE")
            puts "PROXY PROFILE: #{ENV['PROXYPROFILE']}"
            puts "HTTP_PROXY: #{ENV['http_proxy']}" if ENV.has_key? "http_proxy"
            puts "HTTPS_PROXY: #{ENV['https_proxy']}" if ENV.has_key? "https_proxy"
            puts "FTP_PROXY: #{ENV['ftp_proxy']}" if ENV.has_key? "ftp_proxy"
        else
            puts "No proxy address is currently configured.".red
        end
    end
    
    # search profile
    def p_search(p_name)
        return @main_repo.search(p_name)
    end
    
    # list available profiles
    def list_profiles
        @main_repo.list if !@main_repo.nil?
        @secondary_repo.list if !@secondary_repo.nil?
    end
    
    # reset config
    def reset
        puts ""
    end
end

## MAIN ##

# check command line
if ARGV.empty?
    puts oParser
    exit(0)
end

# begin command line parsing
begin
    oParser.parse!
rescue OptionParser::MissingArgument => e
    puts e.message.eerr()
    exit(-1)
rescue OptionParser::InvalidOption => e
    puts e.message.eerr()
    exit(-1)
end

# instantiate main class
m = Main.new
if (cfg[:showstatus] == true)
    m.showstatus()
    exit(0)
end

# list profiles if specified by the appropriate command line option
m.list_profiles if (cfg[:listspecs] and cfg[:proxyspec] == nil)

# search and apply profile
if (cfg[:listspecs] == false and cfg[:proxyspec] != nil)
    profile = m.p_search(cfg[:proxyspec])
    if profile != nil
        profile.apply()
        exit(0)
    else
        puts "No such profile found.".einfo()
        exit(-1)
    end
end

## END ##
