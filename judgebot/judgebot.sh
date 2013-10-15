#! /bin/bash

# Check if running as root
if [ "`id -u`" != "0" ]; then
  echo "Must be run as root"
  exit;
fi

PATH_PIDS=pids
PATH_DATA=data
SCRIPT1=judgebot.rb
SCRIPT2=updatebot.rb

kill_process(){
  if [ -s $PATH_PIDS ]; then
    while read pid; do
      kill -9 $pid 2>> /dev/null
    done < $PATH_PIDS
    echo -e "Killing process...\n\tdone!"
    echo "" > $PATH_PIDS
  fi
}

start_process(){
  if [ -s $PATH_DATA ]; then
    i=0
    while read line; do
      data[$i]=$line
      ((i++))
    done < $PATH_DATA

    echo "Rising $SCRIPT1 ... "
    ruby $SCRIPT1 ${data[0]} ${data[1]} ${data[2]} ${data[3]} ${data[4]} &
    disown
    PID1=$!
    echo "Rising $SCRIPT2 ... "
    ruby $SCRIPT2 ${data[0]} ${data[1]} ${data[3]} ${data[4]} &
    disown
    PID2=$!
    echo -e "$PID1\n$PID2" > $PATH_PIDS
    echo -e "\tRunning :P";
  else
    echo -e "Error. File $PATH_DATA does no exist or is empty\n"
    echo -e "\nPopulate with:"
    echo -e "[ip]\n[port]\n[time]\n[username]\n[password]\n"
    echo -e "\tNo running :S."
  fi
}

status_process(){
  if [ -s $PATH_DATA ]; then
    f=0
    while read pid; do
      echo -n "$pid "
      ((f++))
    done < $PATH_PIDS

    if [ $f = 2 ]; then
      echo -e "\n\tRunning..."
    else
      echo -e "\tNo running."
    fi
  fi
}

case $1 in
  start)
    kill_process;
    start_process;
  ;;

  stop)
    kill_process;
  ;;
  
  status)
    status_process;
  ;;

  *)
    echo "Usage: $0 (start|stop|status)"
  ;;
esac
