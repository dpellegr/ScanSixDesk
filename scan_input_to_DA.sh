#!/bin/sh
# pass 1 to skip madx, 2 to skip sixtrack, 3 to skip check

source ./scan_definitions.sh
source ./sixdeskenv

entry_point=0
if [ "$#" -ge "1" ]
then
  entry_point="$1"
fi

logfile="scan_input_to_DA.log"
logmsg() {
  echo "$(date) $1" >> $logfile
}

if [ $entry_point -lt 1 ]; then
  echo "$(date) LOG FOR $workspace" > $logfile
  logmsg "Make input - submitting madx"
  ./scan_make_input.sh
  sleep 10
  condor_release --all
  logmsg "Waiting for Condor jobs"
  $sixdesk_path/condor_wait.sh -n "mad/$workspace/" -i 150
  logmsg "Madx Done"
fi

if [ $entry_point -lt 2 ]; then
  logmsg "Submitting Sixtrack"
  ./scan_run_six.sh
  sleep 10
  condor_release --all
  logmsg "Waiting for Condor jobs"
  $sixdesk_path/condor_wait.sh -n "run_six/$workspace/" -i 600
  logmsg "run_six Done" >> scan_input_to_DA.log
fi

if [ $entry_point -lt 3 ]; then
  while 
    logmsg "run_check"
    ./scan_run_check.sh
    cnt=$?
    sleep 10
    condor_release --all
    [ $cnt -gt 0 ]
  do
    logmsg "Rerunning $cnt studies"
    $sixdesk_path/condor_wait.sh -n "run_six/$workspace/" -i 600
    logmsg "Waiting for Condor jobs"
  done
fi

logmsg "Plotting"
rm -f *pkl
python2 scan_plot_sixdb.py
logmsg "Finished"
