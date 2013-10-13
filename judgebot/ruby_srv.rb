require 'socket'
require 'thread'
require 'httparty'
require 'json'
require "net/http"
require "uri"

class SConsumer
  include HTTParty
  format :json
  basic_auth 'user', 'password'
end

class SJudge

  def initialize(ip,port,time)
    @base_uri = 'http://' + ip + ':'+port
    @folder = 'files'
    @time = time.to_i
    puts @base_uri
  end
  
  def write_to_file(fname,str)
    file = File.open("#{fname}","w")
    file.write(str)
    file.close
  end
  
  def judge
    base_name = "runs" + @submission["id"].to_s
    base_path = @folder + "/" + base_name
    srcname = @submission["srcfile_file_name"]

    %x{#{"rm -rf #{base_path}"}}
    %x{#{"mkdir #{base_path}"}}
    %x{#{"chmod 777 -R #{base_path}"}}

    write_to_file(base_path + "/" + srcname,@src_code)

    sub_id = @submission["id"]
    tc_id = @submission["testcase_id"]
    
#    if !(@testcases.has_key? tc_id)
      @testcases[tc_id] = tc = SConsumer.get("#{@base_uri}/submissions/#{sub_id}/bot_testcase.json")
      write_to_file "#{base_path}/#{tc_id}.in",tc[0]
      write_to_file "#{base_path}/#{tc_id}.out",tc[1]
#    else
#      tc = @testcases[tc_id]
#     puts tc
#    end    
    
    type = @language["ltype"]
    comp = @language["compilation"]
    exec = @language["execution"]
    timl = @ex_pr["time_limit"]
    progl = @ex_pr["prog_limit"]
    meml = @ex_pr["mem_lim"]
    comp = comp.gsub("SOURCE","Main")
    exec = exec.gsub("SOURCE","Main").gsub("-tTL","-t"+timl.to_s).gsub("ML",meml.to_s).gsub("INFILE","Main.in").gsub("SRUN","safeexec")
    command = "./sjudge.sh '#{srcname}' '#{tc_id}.in' '#{tc_id}.out' #{type} '#{comp}' '#{exec}' #{timl} #{meml} #{progl} #{sub_id}"

    s = %x{#{command}}.split(',')
    ans = sub_id.to_s + "," + s[0].to_s + "," + s[1].to_s
    return ans
    
#   ur = "#{@base_uri}/submissions/#{sub_id}/update_veredict.json"
#   response = SConsumer.get(ur,:query => { :veredict => s, :time => time })
  end

  def process_subm(subm_id)
    s = "#{@base_uri}/submissions/#{subm_id}/judgebot.json"
    response = SConsumer.get(s)
    @submission = response[0]
    @src_code = response[1]
    @language = response[2]
    @ex_pr = response[3]
    judge  
  end

  def run_server()
      @testcases = {}
      puts @time
      loop {
        s = "#{@base_uri}/submissions/pending.json"

        begin
          subms = SConsumer.get(s)
          
          for s in subms
            %x{echo "Judging submission id=#{s}" >> judgebot.log}
            v = process_subm(s.to_i)
            fifo = open("test_fifo", "w+")
            fifo.puts v
            fifo.flush
          end

          sleep @time

        rescue Exception => e
          %x{echo "`date` \n\t (#{$0}) - #{e.message}\n" >> judgebot.log}
          sleep @time
          false
        end        
      }
  end

end

# Get from arguments ip and port
ip   = "#{ARGV[0]}"
port = "#{ARGV[1]}"
time = "#{ARGV[2]}"

#The actual server launch
server = SJudge.new(ip,port,time)
server.run_server
