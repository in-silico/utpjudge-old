## Judgebot

### Files

- `data` Data to connect with rails app (ip,port,time,user,pass) ***one data per line***
- `pids` Judgebot's process ids
- `judgebot.sh` To (start|stop|status) judgebot (launches judgebot.rb and updatebot.rb)
- `judgebot.log` Log of events
- `test_fifo` Communications between judgebot.rb and updatebot.rb
- `files` Folder to runs
- `sjudge.sh` Judge

### Usage

  ./judgebot.sh (start|stop|status)
