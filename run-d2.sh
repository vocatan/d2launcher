#!/bin/bash
#
# (re)Launcher script to repeatedly try to launch DiabloII, until it loads.
# Sometimes it takes upwards of 10 launches, but this script *does* work (for me)
#
# IMPORTANT: Put the location of the Diablo II.app on the next line, in quotes
#            because the spaces will cause havoc.  I installed DiabloII onto
#            a second partition that I formatted as HFS after reading all the
#            horror stories at https://us.battle.net/forums/en/bnet/topic/20758758996
#
# Installation instructions:
# 1) save all this to a file like 'run-d2.sh' in your home directory
#
# 2) update the line below that says D2=...etc... with location of where you
#    have installed DiabloII on your Mac.  (HINT: it better be a HFS location!)
#
# 3) make that file executable (chmod +x ~/run-d2.sh)
#
# 4) execute that file from a Terminal window to watch the fun
#
# NO SUPPORT PROVIDED FOR THIS SCRIPT, Use at your own risk, yada yada yada...
# released to public domain

D2="/Volumes/HFS/Games/Diablo II/Diablo II.app"

# For this next variable, put the # of seconds you want to wait for Diablo2 to
# launch.  On the computer I'm testing this on, it usually takes about 4
# seconds to know if it worked, or if it failed..
WAITLOOPS=6

echo "Diablo II (re)Launcher - thanks Blizzard for all the happy memories....."
TRY=1
while true; do
  echo "Attempting to launch Diablo II, try # $TRY"
  "$D2/Contents/MacOS/Diablo II" >/tmp/d2.log 2>&1 &
  PID=$!
  RC=$?
  echo "Started as PID $PID   RC:$RC"

  # loop and wait to see if this pid sticks around
  # adjust this to how long it usually takes to start..
  LOOPS=$WAITLOOPS
  while [ $LOOPS -gt 0 ]; do
    echo "   Waiting $LOOPS more seconds.."
    DEAD=`ps |grep $PID | awk '{print $1}'`
    if [ "$DEAD" = "" ]; then
      echo "Yup, it died. break out of loop"
      LOOPS=0
    else
      LOOPS=$((LOOPS-1))
      sleep 1
    fi
  done

  COMPRESS=`grep "unsupported compressor" /tmp/d2.log`
  if [ "$COMPRESS" != "" ]; then
     echo "   (Yup, crashed due to that 'unsupported compressor' error...)"
  fi
  
  sleep 1
  ERR=`ps aux |grep "Blizzard Error" |grep -v grep |awk '{print $2}'`
  if [ "$ERR" != "" ]; then
    echo "looks like it crashed. killing error reporter and restarting"
    kill $ERR
    sleep 2
    sync
    TRY=$((TRY+1))

  else
    echo "Well, what do you know, it might have worked..."
    echo "(and after only $TRY tries...)"
    exit
  fi
done
