require 'sinatra'
require 'net/http'
require 'json'
require "active_support/all"

get '/sleepy/' do
  @threads = []
  @results = { data: [], total: 0.0, sum: 0.0}

  ['http://www.fakeresponse.com/api/?sleep=1', 
   'http://www.fakeresponse.com/api/?sleep=2',
   'http://www.fakeresponse.com/api/?sleep=3',
   'http://www.fakeresponse.com/api/?sleep=4',
   'http://www.fakeresponse.com/api/?sleep=5'].each do |url|
    new_request{ url }
  end

  @threads.each { |thr| thr.join }

  @results.to_json
end

private

def new_request
  begin_time = Time.now
  @threads << Thread.new do
    u = JSON.parse( Net::HTTP.get( URI.parse( yield )))
    if u['error']
      @results[:errors] = [] unless @results[:errors]
      @results[:errors] << u
    else
      @results[:data] << u
    end
    @results[:sum] += u['slept'] if u['slept']
    @results[:total] += Time.now - begin_time
  end
end