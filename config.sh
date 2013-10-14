#!/bin/bash
# 
# This script configure everything necessary to judging
# 

# Check if running as root
if [ "`id -u`" != "0" ]; then
  echo "Must be run as root"
  exit;
fi

COMMNAME=safeexec
basename=_utpjudge
PATH_BOT=judgebot

# To delete a previous installation, if exists
rm -rf /usr/bin/$COMMNAME &> /dev/null
deluser $basename &> /dev/null
delgroup g$basename &> /dev/null

echo "Creating commmand: '$COMMNAME' ...";
# To compile and create command $COMMNAME if does not exists
if [ ! -x /usr/bin/$COMMNAME ]; then
  if [ -f $COMMNAME.c ]; then
    gcc -Wall -o $COMMNAME $COMMNAME.c &> /dev/null;
    if [ $? == 0 ]; then
      mv $COMMNAME /usr/bin/
      chmod 4555 /usr/bin/$COMMNAME
      echo "Successful command is /usr/bin/$COMMNAME";
    else
      echo "Compilation error -> $COMMNAME.c";
      echo -e "\tFail installation. :S!"
      exit;
    fi
  else
    echo "File not found -> $COMMNAME.c";
    echo -e "\tFail installation. :S!"
    exit;
  fi
fi

# To create dir 'files' with writting permissions and pipe.
echo "Creating dir: $PATH_BOT/files";
mkdir $PATH_BOT/files
chmod 777 $PATH_BOT/files
echo "Creating fifo: $PATH_BOT/test_fifo";
mkfifo $PATH_BOT/test_fifo 
chmod 700 $PATH_BOT/test_fifo

echo "Creating user and group to runs: $basename, g$basename ...";
# To create user and group to runs
id -u $basename &>/dev/null;
if [ $? != 0 ]; then
  groupadd g$basename;
  useradd -M -s /bin/bash -g g$basename $basename;
  if [ $? != 0 ]; then
    echo "Failed to create user $basename";
    echo -e "\tFail installation. :S!"
    exit;
  fi
fi

echo -e "\tSuccessful installation :P!";
