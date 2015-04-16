require 'minitest_helper'
# require 'highwatermark'
# require 'minitest/autorun'

class TestHighwatermark < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Highwatermark::VERSION
  end

  def test_it_does_something_useful
    # assert false
  end

  def test_could_work
  	path = 'test/test_state_file.conf'
  	state_type = 'file'
  	tag = 'testTag'

  	hwm = ::Highwatermark::HighWaterMark.new(path, state_type, tag)
  	# time = Engine.now
  	time = 'testTime'
  	hwm.update_records(time)
  	
  	assert_equal time,
      hwm.last_records()
  end




end
