require "highwatermark/version"

module Highwatermark
    class HighWaterMark

      def initialize(parameters)

        require 'yaml'
       
        @state_type = parameters["state_type"] # require
        @state_tag = parameters["state_tag"] # require
        @path = parameters["state_file"] # optional,  need state_type set to 'file'
        @redis_host = parameters["redis_host"]  # optional, need state_type set to 'redis'
        @redis_port = parameters["redis_port"]  # optional, need state_type set to 'redis'

        # check the parameter configurartion
        if @state_type == nil 
          raise "The parameter 'state_type' is required, please provide state_type (file, redis or memory)"
        end

        if @state_tag == nil
          raise "The paramerter 'state_tag' is required, please provide state_tag for labelling high watermark info"
        end

        if @path != nil && @state_type != 'file'
          raise "To use 'state_file' parameter, 'state_type' need to be set to 'file'"
        end

        if ((@redis_host != nil || @redis_port != nil ) && @state_type != 'redis')
          raise "To use 'redis_host' or 'redis_port' parameters, 'state_type' need to be set to 'redis'"
        end



        @data = {}
        if @state_type == 'file'

            if File.directory? (@path)
              # create a new state file in the provided directory
              # when recover from failure will also try to read from this file
              @path = @path+"/"+@state_tag+".yaml"
              puts "provided path is a valid derectory, created a new file on #{@path.inspect}"
              @data = {}
            else # not a directory, then check if it's a valid file
              if File.exist?(@path)
                @data = YAML.load_file(@path)
                if @data == false || @data == []
                  # this happens if an users created an empty file accidentally, or the file is just initialized
                  puts "state file on #{@path.inspect} is empty "
                  @data = {}
                elsif !@data.is_a?(Hash)
                  # if the file contains invalid data, that is not a hash
                  raise "state file on #{@path.inspect} contains invalid data, please use other file"
                end
              else
                raise "#{@path.inspect} is not a valid directory or file, please provide valid state file path"
              end
              
            end



        elsif @state_type =='memory'
          @data = {}


        elsif @state_type =='redis'
          require 'redis'
          if (@redis_host == nil || @redis_port == nil)
            puts "No Redis host and port specified, use default local setting"
            @redis = Redis.new
          else # if has the redis host and port configure
            begin
              puts "Redis Host #{@redis_host} port #{@redis_port}"
              @redis = Redis.new(host: @redis_host, port: @redis_port)
            rescue Exception => e
              puts e.message
              puts e.backtrace.inspect
            end
          end
          @data = {}
        end # end of checking @state_type

        if @data['last_records']==nil
          @data['last_records'] = {}
        end
        
      end # end of intitialize

      def last_records(tag=@state_tag)
        if @state_type == 'file'
          return @data['last_records'][tag]

        elsif @state_type =='memory'
          return @data['last_records'][tag]
        elsif @state_type =='redis'
          begin
            alertStart=@redis.get(tag)
            return alertStart
          rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
          end
        end
      end

      def update_records(time, tag=@state_tag)
        if @state_type == 'file'
          @data['last_records'][tag] = time
          File.open(@path, 'w') {|f|
            f.write YAML.dump(@data)
          }
        elsif @state_type =='memory'
          @data['last_records'][tag] = time
          
        elsif @state_type =='redis'
          begin
            alertStart=@redis.set(tag,time)
          rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
          end
        end

      end

    end # end of class Highwatermark



        

    


end
