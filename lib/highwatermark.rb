require "highwatermark/version"

module Highwatermark
    class HighWaterMark
    	def initialize(path,state_type,tag)
    		# path: is th file path for store state or the redis configure
    		# state_type: could be <redis/file/memory>
    		# tag: is the tag that will be used in state file or redis 


    		require 'yaml'
        require 'pp'
    		@path = path
    		@state_type = state_type
			  @tag = tag

    		@data = {}
    		if @state_type =='file'
    			if File.exists?(path)
  					@data = YAML.load_file(path)
  					if @data == false || @data == []
  						# this happens if an users created an empty file accidentally
  						@data = {}
  					elsif !@data.is_a?(Hash)
  						raise "state_file on #{@path.inspect} is invalid"
  					end
  				else
  					@data = {}
  				end
  			elsif @state_type =='memory'
  				@data = {}
  			elsif @state_type =='redis'
  				require 'redis'
  				$redis = if File.exists?(path)
  					redis_config = YAML.load_file(path)
  					# Connect to Redis using the redis_config host and port
  					if path
  					    begin
                  pp "In redis #{path} Host #{redis_config['host']} port #{redis_config['port']}"
  				  			$redis = Redis.new(host: redis_config['host'], port: redis_config['port'])
    						rescue Exception => e
    							pp e.message
  		            pp e.backtrace.inspect
  					    end
  					end
  				else
  			  		Redis.new
  				end
      		@data = {}
      	end # end of checking @state_type
        @data['last_records'] = {}
      end # end of intitialize

	    def last_records()
        if @state_type == 'file'
          # return @data[@tag]
          return @data['last_records'][@tag]
        elsif @state_type =='memory'
          return @data['last_records'][@tag]
        elsif @state_type =='redis'
          begin
            alertStart=$redis.get(@tag)
            return alertStart
          rescue Exception => e
            pp e.message
            pp e.backtrace.inspect
          end
      	end
      end

  		def update_records(time)
        if @state_type == 'file'
          # @data[@tag] = time
    			@data['last_records'][@tag] = time
    			# $log.info  @data
    			File.open(@path, 'w') {|f|
    			  f.write YAML.dump(@data)
    			}
        elsif @state_type =='memory'
          @data['last_records'][@tag] = time
          
        elsif @state_type =='redis'
          begin
            alertStart=$redis.set(@tag,time)
          rescue Exception => e
            pp e.message
            pp e.backtrace.inspect
          end
        end

  		end

  	end # end of class Highwatermark



    		

    


end
