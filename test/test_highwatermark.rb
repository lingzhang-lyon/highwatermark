require 'minitest_helper'
# require 'highwatermark'
# require 'minitest/autorun'

class TestHighwatermark < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Highwatermark::VERSION
  end

  def test_file_could_work
  	path = 'test/test_state_file.conf'
  	state_type = 'file'
  	tag = 'testTag'

  	hwm = ::Highwatermark::HighWaterMark.new(path, state_type, tag)
  	time = 'testTime'
  	hwm.update_records(time)
  	
  	assert_equal time,
      hwm.last_records()
  end

  def test_redis_could_work
    path = 'test/test_redis.conf'
    state_type = 'redis'
    tag = 'testTag'

    hwm = ::Highwatermark::HighWaterMark.new(path, state_type, tag)
    time = 'testTime'
    hwm.update_records(time)
    
    assert_equal time,
      hwm.last_records()
  end

  def test_memory_could_work
    path = 'test/test_redis.conf'
    state_type = 'memory'
    tag = 'testTag'

    hwm = ::Highwatermark::HighWaterMark.new(path, state_type, tag)
    time = 'testTime'
    hwm.update_records(time)
    
    assert_equal time,
      hwm.last_records()
  end



end
