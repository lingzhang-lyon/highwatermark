require "highwatermark/version"

module Highwatermark
    # Your code goes here...
    class StateStore
      def initialize(path)
        require 'yaml'
        @path = path
        if File.exists?(@path)
          @data = YAML.load_file(@path)
          if @data == false || @data == []
            @data = {}
          elsif !@data.is_a?(Hash)
            raise "Spectrum :: ConfigError state_file on #{@path.inspect} is invalid"
          end
        else
          @data = {}
        end
      end

      def last_records
        @data['last_records'] ||= {}
      end

      def update!
        File.open(@path, 'w') {|f|
          f.write YAML.dump(@data)
        }
      end
    end

    class MemoryStateStore
      def initialize
        @data = {}
      end
      
      def last_records
        @data['last_records'] ||= {}
      end
      
      def update!
      end
    end

    # from appdynamics
    # Class statestore
    class StateStore
      def initialize(path,tag)
        require 'yaml'
        @path = path
        if File.exists?(@path)
          @data = YAML.load_file(@path)
          if @data == false || @data == []
            # this happens if an users created an empty file accidentally
            @data = {}
          elsif !@data.is_a?(Hash)
            raise "state_file on #{@path.inspect} is invalid"
          end
        else
          @data = {}
        end
      end

      def last_records(tag=nil)
        return @data[tag]
        #@data['last_records'] ||= {}
      end

      def update_records(time, tag=nil)
		@data[tag]=time
		pp  @data
        File.open(@path, 'w') {|f|
          f.write YAML.dump(@data)
        }
      end
    end

    # Class store in memory
    class MemoryStateStore
      def initialize
        @data = {}
      end
      
      def last_records(tag=nil)
        @data['last_records'] ||= {}
      end
      
      def update_records(time,tag=nil)
      end
    end

    # Class store in redis
    class RedisStateStore
      state_key = ""
      def initialize(path,tag)
        state_key=tag
		#redis_server = $appsettings['redis_server']
		#redis_port = $appsettings['redis_port']
		#redis_spectrum_key = $appsettings['redis_spectrum_key']
		#####
      	require 'redis'
		$redis = if File.exists?(path)
			redis_config = YAML.load_file(path)
			# Connect to Redis using the redis_config host and port
			if path
			    begin
			        pp "In redis #{path} Host #{redis_config['host']} port #{redis_config['port']}"
		  			$redis = Redis.new(host: redis_config['host'], port: redis_config['port'])
				    rescue Exception => e
						$log.info e.message
	                	$log.info e.backtrace.inspect
			    end
			end
		else
  		Redis.new
	  end
        @data = {}
      end
      
      def last_records(tag=nil)
        begin
  	   alertStart=$redis.get(tag)
           return alertStart
        rescue Exception => e
	   $log.info e.message
	   $log.info e.backtrace.inspect
        end
      end
      
      def update_records(time, tag=nil)
        begin
  	   		alertStart=$redis.set(tag,time)
        rescue Exception => e
		   $log.info e.message
		   $log.info e.backtrace.inspect
        end
      end
    end


end
