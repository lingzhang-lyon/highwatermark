# Highwatermark

This gem is for storing your high watermark in state file or redis cache.

If not set up state file or redis, it will just use memory 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'highwatermark'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install highwatermark

## Usage

In your ruby code:
```ruby
# To initilize high watermark
require 'highwatermark'

highwatermark_parameters={
	"state_tag" => "your tag",  # required, is the tag that will be used in state file or redis     
	"state_type" => "file",  # required: could be <redis/file/memory>
	"state_file" => "/path/to/state/file/or/redis/conf", # optional, the file path for store state, need state_type set to 'file'
	"redis_host" => '127.0.0.1', #optional, to set remote redis, need state_type set to 'redis'
	"redis_port" => '6379'  #optional, to set remote redis, need state_type set to 'redis'   
}

hwm = Highwatermark::HighWaterMark.new(highwatermark_parameters)

# To store time in high watermark
time = "what your want to store in high watermark"
hwm.update_records(time) #use tag in the configure 'state_tag'

tag = "some other specified tag"
hwm.update_records(time, tag) # use some other specified tag


# To get the high watermark
hwm.last_records() #get high watermark with tag in the configure 'state_tag'

tag = "some other specified tag"
hwm.last_records(tag) #get high watermark with some other specified tag



```


Output in the state file:

```
---
last_records:
  your tag: 1429572200

```


## Test

Install rake and minitest,then use rake run the test

```
gem install minitest
gem install rake
rake test --trace

```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/highwatermark/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
