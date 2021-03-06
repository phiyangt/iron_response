require "test_helper"

class GemDependencyTest < Test::Unit::TestCase
  def test_synopsis_with_iron_cache

    config = Configuration.keys
    batch = IronResponse::Batch.new(iron_io: config[:iron_io])
    
    code = IronWorkerNG::Code::Ruby.new
    code.exec "test/workers/fcc_filings_counter.rb"
    code.runtime = "ruby"
    code.merge_gem("nokogiri", "< 1.6.0") # keeps the build times low
    code.merge_gem("ecfs")
    code.full_remote_build(true)

    batch.code = code
    params = [
              "12-375", "12-268",
              "12-238", "12-353", 
              "13-150", "13-5", 
              "10-71"
              ].map { |i| {docket_number: i} } 
    batch.params_array = params
    batch.create_code!

    results = batch.run!

    #binding.pry

    assert_equal batch.params_array.length, results.length
    results.select! {|r| !r.is_a?(IronResponse::Log)}
    total = results.map {|r| r["length"]}.inject(:+)
    p "There are #{total} total filings in these dockets."
    assert_equal Array, results.class
  end

  def test_synopsis_with_aws_s3

    config = Configuration.keys
    batch = IronResponse::Batch.new(config)

    code = IronWorkerNG::Code::Ruby.new
    code.exec "test/workers/fcc_filings_counter.rb"
    code.runtime = "ruby"
    code.merge_gem("nokogiri", "< 1.6.0") # keeps the build times low
    code.merge_gem("ecfs")
    code.full_remote_build(true)

    batch.code = code

    params = [
              "12-375", "12-268",
              "12-238", "12-353", 
              "13-150", "13-5", 
              "10-71"
              ].map { |i| {docket_number: i} } 
    batch.params_array = params      
    
    batch.create_code!
    results = batch.run!
    assert_equal batch.params_array.length, results.length
    #binding.pry
    results.select! {|r| !r.is_a?(IronResponse::Log)}
    total = results.map {|r| r["length"]}.inject(:+)
    p "There are #{total} total filings in these dockets."
    assert_equal Array, results.class
  end

end