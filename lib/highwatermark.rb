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

        @data = {}
        if @state_type =='file'

          if File.exists?(@path)
            @data = YAML.load_file(@path)
            if @data == false || @data == []
              # this happens if an users created an empty file accidentally
              puts "state_file on #{@path.inspect} is empty "
              @data = {}
            elsif !@data.is_a?(Hash)
              # if the file contains invalid data, that is not a hash
              puts "state_file data on #{@path.inspect} is invalid"
              # don't want to over write the data in original file
              # create a new file on default path when update_records  
              @path = "test/default_state_file_"+@state_tag+".yaml"
              puts "will use default state_file path #{@path.inspect}"
              @data = {}
            end
          else
            # if the file is not exist, just create an empty hash
            puts "state_file on #{@path.inspect} not exists"
            @data = {}
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
