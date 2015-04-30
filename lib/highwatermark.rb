require "highwatermark/version"

module Highwatermark
    class HighWaterMark
      def initialize(path,state_type, state_tag)
        # path: is th file path for store state or the redis configure
        # state_type: could be <redis/file/memory>


        require 'yaml'
        @path = path
        @state_type = state_type
        @state_tag = state_tag

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
          $redis = if File.exists?(@path)
            redis_config = YAML.load_file(@path)
            # Connect to Redis using the redis_config host and port
            if @path
                begin
                  puts "In redis #{path} Host #{redis_config['host']} port #{redis_config['port']}"
                  $redis = Redis.new(host: redis_config['host'], port: redis_config['port'])
                rescue Exception => e
                  # pp e.message
                  # pp e.backtrace.inspect
                end
            end
          else
              Redis.new
          end
          @data = {}
        end # end of checking @state_type

        if @data['last_records']==nil
          @data['last_records'] = {}
        end
        
      end # end of intitialize

      def last_records(tag)
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

      def update_records(time, tag)
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
