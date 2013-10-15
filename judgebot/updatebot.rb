require 'socket'
require 'httparty'
require 'json'

class SConsumer
  include HTTParty
  format :json
  
  def initialize(user, pass)
    @auth = {:username => user, :password => pass}
  end

  def get(ur,d)
    options = { :query => d, :basic_auth => @auth }
    self.class.get(ur,options)
  end

end


class RVeredict

  def initialize(ip,port,user,pass)
    @base_uri = 'http://' + ip + ':' + port
    @data = open("test_fifo", "r+")
    @user = user
    @pass = pass
    @log = "judgebot.log"
    %x{echo "#{@base_uri}\n" >> #{@log}}
  end

  def run_rv()

      loop do
          v = @data.gets
          ver = v.split(",")
          %x{ echo "Receiving veredict=#{v}" >> #{@log}}
          ur = "#{@base_uri}/submissions/#{ver[0]}/update_veredict.json"
          begin
            d = { :veredict => ver[1], :time => ver[2] }
            response = SConsumer.new(@user,@pass).get(ur,d)
          rescue Exception => e
            %x{echo "`date` \n\t  (#{$0}) - #{e.message}\n" >> #{@log}}
            false
          end
      end
  end
end

ip =   "#{ARGV[0]}"
port = "#{ARGV[1]}"
user = "#{ARGV[2]}"
pass = "#{ARGV[3]}"

rv = RVeredict.new(ip,port,user,pass)
rv.run_rv
