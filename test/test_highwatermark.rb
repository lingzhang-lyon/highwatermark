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
    tag = 'testTagForFile'

    hwm = ::Highwatermark::HighWaterMark.new(path, state_type,tag)
    time = 'testTime'
    hwm.update_records(time, tag)
    
    assert_equal time,
      hwm.last_records(tag)
  end

  def test_redis_could_work
    path = 'test/test_redis.conf'
    state_type = 'redis'
    tag = 'testTagForRedis'

    hwm = ::Highwatermark::HighWaterMark.new(path, state_type,tag)
    time = 'testTime'
    hwm.update_records(time, tag)
    
    assert_equal time,
      hwm.last_records(tag)
  end

  def test_memory_could_work
    path = 'test/test_redis.conf'
    state_type = 'memory'
    tag = 'testTagForMemory'

    hwm = ::Highwatermark::HighWaterMark.new(path, state_type,tag)
    time = 'testTime'
    hwm.update_records(time, tag)
    
    assert_equal time,
      hwm.last_records(tag)
  end

  def test_read_from_file_then_update
    path = 'test/test_state_file.conf'
    state_type = 'file'
    tag = 'testTagForFile'

    hwm = ::Highwatermark::HighWaterMark.new(path, state_type,tag)
    refute_nil hwm.last_records(tag)
    
    newTestTime = "new_" + hwm.last_records(tag)
    hwm.update_records(newTestTime, tag)
    refute_nil hwm.last_records(tag)


  end

  def test_read_from_redis
    path = 'test/test_redis.conf'
    state_type = 'redis'
    tag = 'testTagForRedis'

    hwm = ::Highwatermark::HighWaterMark.new(path, state_type,tag)
    refute_empty hwm.last_records(tag) 
  end


  def test_if_state_file_not_exist
    path = 'test/test_state_file_new.conf'
    state_type = 'file'
    tag = 'testTagForFile'

    hwm = ::Highwatermark::HighWaterMark.new(path, state_type,tag)
    assert_nil hwm.last_records(tag)
    
    newTestTime = "time_from_test_if_state_file_not_exist"
    hwm.update_records(newTestTime, tag)
    refute_nil hwm.last_records(tag)

    File.delete(path)
  end

  def test_if_state_file_contain_invalid_data
    path = 'test/test_state_file_invalid_data.conf'
    state_type = 'file'
    tag = 'testTagForFile'

    hwm = ::Highwatermark::HighWaterMark.new(path, state_type,tag)
    assert_nil hwm.last_records(tag)
    
    newTestTime = "time_from_test_if_state_file_contain_invalid_data"
    hwm.update_records(newTestTime, tag)
    assert_equal newTestTime, hwm.last_records(tag)


    # after test restore the invalid file back
    File.open(path, "w"){ |f|
      f.write("hello world, this is an invalid data file")
    }

  end


  def test_read_from_state_file_with_wrong_tag
    path = 'test/test_state_file.conf'
    state_type = 'file'
    tag = 'wrongTag'

    hwm = ::Highwatermark::HighWaterMark.new(path, state_type,tag)
    assert_nil hwm.last_records(tag)

  end 


end
