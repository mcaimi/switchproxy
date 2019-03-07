#!/usr/bin/env ruby

=begin
    Dynamic Profile Generator Class
    Code by Caimi Marco <marco.caimi@risolve.com>
=end

# program requires
require 'yaml'
require 'date'

# Generator class
class Generator
     attr_reader :config_filename
     
     # class constructor
     def initialize(filename, rootkey)
         @config_filename = filename
         @root_key = rootkey
         raise GlobalConfigFileNotFoundException, "Configuration file #{@config_filename} not found!" if !File.exists? @config_filename
         
         # load the global configuration file
         begin
             @config = YAML.load_file(@config_filename)
         rescue ArgumentError => e
             raise YAMLSyntaxError, "Syntax Error in #{@config_filename}: #{e.to_s}"
         end
         
         # check for semantic errors:
         # the file must have a "parameters" root key
         raise YAMLSyntaxError, "SYNTAX ERROR IN CONFIG FILE: No parameters section found in #{@config_filename}" if !@config.has_key? @root_key
         
         # populate class attributes
         @config[@root_key].each_key { |key_name| self.attr_init(key_name) }
     end
        
     # build class attibutes from configuration file
     # by using reflection and metaprogramming
     def create_method(name, &block)
         # define method wrapper
         self.class.send(:define_method, name, &block)
     end
       
     def attr_init(attribute)
         # instantiate attributes via eval() calls
         instance_variable_set("@#{attribute}", @config[@root_key][attribute])
         self.create_method(attribute) { return instance_variable_get("@#{attribute}") }
     end
end
    
# global params class
class ProxyProfile < Generator
   
   # constructor
   def initialize(filename)
      # call parent constructor
      super(filename, "proxyspec")
      # profile properties
      @profile_properties = { :http_proxy => "http_proxy", 
                              :https_proxy => "https_proxy", 
                              :ftp_proxy => "ftp_proxy"} 
   end
   
   # profile activation method
   def apply
        #check if we are already logged in a switchproxy task
        #set profile name
        if ENV.has_key? "PROXYPROFILE"
            puts "You are alredy inside a switchproxy thread.".eerr()
            exit(-1)
        else
            ENV['PROXYPROFILE'] = self.name
        end

        # apply environment variables if defined in the yaml spec
        @profile_properties.each_key do |key|
            if self.respond_to? "#{@profile_properties[key]}"
                puts "Now setting the #{@profile_properties[key]} env variable...".einfo()
                eval("ENV['#{@profile_properties[key]}'] = self.#{@profile_properties[key]}") 
            end
        end

        puts "Spawning shell...".einfo()
        p1 = Thread.new do
            system(ENV['SHELL']) 
        end
        p1.join()
        
        if self.respond_to? "#{@profile_properties[:auth_helper]}"    
          puts "Now stopping authentication helper #{self.auth_helper}".einfo()
                system("#{self.auth_helper} stop")
        end
              
        puts "Switchproxy task terminated.".einfo()
   end
end
