require 'socket'
require 'httparty'
require 'json'

class SConsumer
  include HTTParty
  format :json
  basic_auth 'user', 'password'
end


class RVeredict

  def initialize(ip,port)
    @base_uri = 'http://' + ip + ':' + port
    puts @base_uri
    @data = open("test_fifo", "r+")
  end

  def run_rv()

      loop do
          v = @data.gets
          ver = v.split(",")
          %x{ echo "Receiving veredict=#{v}" >> judgebot.log}
          ur = "#{@base_uri}/submissions/#{ver[0]}/update_veredict.json"
          response = SConsumer.get(ur,:query => { :veredict => ver[1], :time => ver[2] })

      end
  end
end

ip = "#{ARGV[0]}"
port = "#{ARGV[1]}"

rv = RVeredict.new(ip,port)
rv.run_rv
