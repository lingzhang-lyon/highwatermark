require "highwatermark/version"

module Highwatermark
    class HighWaterMark
      # def initialize(path,state_type, state_tag)
      def initialize(parameters)


        # path: is th file path for store state or the redis configure
        # state_type: could be <redis/file/memory>


        require 'yaml'
       
        @state_type = parameters["state_type"]
        @state_tag = parameters["state_tag"]
        @path = parameters["state_file"]
        @redis_host = parameters["redis_host"]
        @redis_port = parameters["redis_port"]

        @default_state_file_path = "  default_state_file_"+@state_tag+".yaml"

        @data = {}
        if @state_type =='file'

            if File.directory? (@path)
              # create a new state file in the provided directory
              # when recover from failure will also try to read from this file
              @path = @path+"/"+@state_tag+".yaml"
              puts "provided path is valid derectory, created a new file on #{@path.inspect}"
              @data = {}
            else # not a directory, then check if it's a valid file
              if File.exist?(@path)
                @data = YAML.load_file(@path)
                if @data == false || @data == []
                  # this happens if an users created an empty file accidentally
                  puts "state file on #{@path.inspect} is empty "
                  @data = {}
                elsif !@data.is_a?(Hash)
                  # if the file contains invalid data, that is not a hash
                  raise "state file on #{@path.inspect} contains invalid data, please use other file"
                end
              else
                raise "#{@path.inspect} is not a valid directory or the file not exists, please provide valid state file path"
              end
              
            end



        elsif @state_type =='memory'
          @data = {}


        elsif @state_type =='redis'
          require 'redis'
          if (@redis_host == nil || @redis_port == nil)
            puts "No Redis host and port specified, use default local setting"
            $redis = Redis.new
          else # if has the redis host and port configure
            begin
              puts "Redis Host #{@redis_host} port #{@redis_port}"
              $redis = Redis.new(host: @redis_host, port: @redis_port)
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

      def last_records(tag=nil)
        if @state_type == 'file'
          return @data['last_records'][tag]

        elsif @state_type =='memory'
          return @data['last_records'][tag]
        elsif @state_type =='redis'
          begin
            alertStart=$redis.get(tag)
            return alertStart
          rescue Exception => e
            # pp e.message
            # pp e.backtrace.inspect
          end
        end
      end

      def update_records(time, tag=nil)
        if @state_type == 'file'
          @data['last_records'][tag] = time
          File.open(@path, 'w') {|f|
            f.write YAML.dump(@data)
          }
        elsif @state_type =='memory'
          @data['last_records'][tag] = time
          
        elsif @state_type =='redis'
          begin
            alertStart=$redis.set(tag,time)
          rescue Exception => e
            # pp e.message
            # pp e.backtrace.inspect
          end
        end

      end

    end # end of class Highwatermark



        

    


end
