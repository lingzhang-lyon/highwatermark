require 'minitest_helper'
# require 'highwatermark'
# require 'minitest/autorun'

class TestHighwatermark < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Highwatermark::VERSION
  end


######## test for file ###########
  def test_file_could_work
    parameters ={
      "state_tag" => "testTagForFile",     
      "state_type" =>"file",
      "state_file" => "test/test_state_file.yaml"     
    }

    hwm = ::Highwatermark::HighWaterMark.new(parameters)
    time = 'testTime'
    tag = parameters["state_tag"]
    hwm.update_records(time, tag)
    
    assert_equal time,
      hwm.last_records(tag)
  end

  def test_read_from_file_then_update
    parameters ={
      "state_tag" => "testTagForFile",     
      "state_type" =>"file",
      "state_file" => "test/test_state_file.yaml"      
    }

    hwm = ::Highwatermark::HighWaterMark.new(parameters)
    tag = parameters["state_tag"]
    refute_nil hwm.last_records(tag)    
    newTestTime = "new_" + hwm.last_records(tag)
    tag = parameters["state_tag"]
    hwm.update_records(newTestTime, tag)
    refute_nil hwm.last_records(tag)
  end


  def test_if_state_file_not_exist
    parameters ={
      "state_tag" => "testTagForFile",     
      "state_type" =>"file",
      "state_file" => "test/test_state_file_not_exist.yaml"      
    }

    hwm = ::Highwatermark::HighWaterMark.new(parameters)
    tag = parameters["state_tag"]
    assert_nil hwm.last_records(tag)
    
    newTestTime = "time_from_test_if_state_file_not_exist"
    hwm.update_records(newTestTime, tag)
    refute_nil hwm.last_records(tag)

    path = parameters["state_file"]
    File.delete(path)
  end

  def test_if_state_file_contain_invalid_data
    parameters ={
      "state_tag" => "testTagForFile",     
      "state_type" =>"file",
      "state_file" => "test/test_state_file_invalid_data.yaml"      
    }

    hwm = ::Highwatermark::HighWaterMark.new(parameters)
    tag = parameters["state_tag"]
    assert_nil hwm.last_records(tag)
    
    newTestTime = "time_from_test_if_state_file_contain_invalid_data"
    hwm.update_records(newTestTime, tag)
    assert_equal newTestTime, hwm.last_records(tag)


    # after test restore the invalid file back
    path = parameters["state_file"]
    File.open(path, "w"){ |f|
      f.write("hello world, this is an invalid data file")
    }
  end


  def test_read_from_state_file_with_wrong_tag
    parameters ={
      "state_tag" => "wrongTag",     
      "state_type" =>"file",
      "state_file" => "test/test_state_file.yaml"      
    }

    hwm = ::Highwatermark::HighWaterMark.new(parameters)
    tag = parameters["state_tag"]
    assert_nil hwm.last_records(tag)
  end 

######## test for redis ###########
  def test_redis_could_work
    parameters = {
      "state_tag" => "testTagForRedis",
      "state_type" =>"redis",      
      "redis_host" => "127.0.0.1",
      "redis_port" => "6379"
    }

    hwm = ::Highwatermark::HighWaterMark.new(parameters)
    time = 'testTime'
    tag = parameters["state_tag"]
    hwm.update_records(time, tag)
    
    assert_equal time,
      hwm.last_records(tag)
  end


  def test_read_from_redis
    parameters = {
      "state_tag" => "testTagForRedis",
      "state_type" =>"redis",      
      "redis_host" => "127.0.0.1",
      "redis_port" => "6379"
    }

    hwm = ::Highwatermark::HighWaterMark.new(parameters)
    tag = parameters["state_tag"]
    refute_empty hwm.last_records(tag) 
  end

######## test for memory ###########
  def test_memory_could_work
    parameters = {
      "state_tag" => "testTagForMemory",
      "state_type" =>"memory"
    }

    hwm = ::Highwatermark::HighWaterMark.new(parameters)
    time = 'testTime'
    tag = parameters["state_tag"]
    hwm.update_records(time, tag)
    
    assert_equal time,
      hwm.last_records(tag)
  end




end
