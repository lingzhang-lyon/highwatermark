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
      "state_file" => "test/state_files/test_state_file.yaml"     
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
      "state_file" => "test/state_files/test_state_file.yaml"      
    }

    hwm = ::Highwatermark::HighWaterMark.new(parameters)
    tag = parameters["state_tag"]
    refute_nil hwm.last_records(tag)    
    newTestTime = "new_" + hwm.last_records(tag)
    tag = parameters["state_tag"]
    hwm.update_records(newTestTime, tag)
    refute_nil hwm.last_records(tag)
  end


  def test_if_state_file_is_valid_directory_not_a_file
    absolute_path = File.absolute_path("test/state_files")

    parameters ={
      "state_tag" => "testTagForFile",     
      "state_type" =>"file",
      "state_file" => absolute_path     
    }


    hwm = ::Highwatermark::HighWaterMark.new(parameters)
    tag = parameters["state_tag"]
    assert_nil hwm.last_records(tag)
    
    newTestTime = "time_from_test_if_state_file_not_exist"
    hwm.update_records(newTestTime, tag)
    refute_nil hwm.last_records(tag)

    
    file_path = parameters["state_file"]+"/"+tag+".yaml"
    File.delete(file_path)
  end

  def test_if_state_file_is_neither_valid_directory_nor_valid_file
    absolute_path = File.absolute_path("test/blah")
    parameters ={
      "state_tag" => "testTagForFile",     
      "state_type" =>"file",
      "state_file" => absolute_path      
    }

    begin
      hwm = ::Highwatermark::HighWaterMark.new(parameters)

    rescue Exception => e
      puts e.message
      path = parameters["state_file"]
      assert_equal e.message, "#{path.inspect} is not a valid directory or the file not exists, please provide valid state file path"
    end
  end

  def test_if_state_file_contain_invalid_data
    parameters ={
      "state_tag" => "testTagForFile",     
      "state_type" =>"file",
      "state_file" => "test/state_files/test_state_file_invalid_data.yaml"      
    }
    begin
      hwm = ::Highwatermark::HighWaterMark.new(parameters)
    rescue Exception => e
      puts e.message
      path = parameters["state_file"]
      assert_equal e.message, "state file on #{path.inspect} contains invalid data, please use other file"
    end
  end


  def test_read_from_state_file_with_wrong_tag
    parameters ={
      "state_tag" => "wrongTag",     
      "state_type" =>"file",
      "state_file" => "test/state_files/test_state_file.yaml"      
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
