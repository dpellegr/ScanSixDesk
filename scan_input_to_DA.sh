#!/bin/sh
# pass 1 to skip madx, 2 to skip sixtrack, 3 to skip check

source ./scan_definitions.sh
source ./sixdeskenv

for i in $(seq 5)
do
  ./scan_make_input.sh
  if [ $? -eq 0 ]; then break; fi
  $sixdesk_path/condor_wait.sh -n "mad/$workspace/" -i 600
done

./scan_run_six.sh | tee log.scan_run_six.sh
$sixdesk_path/condor_wait.sh -n "run_six/$workspace/" -i 600

for i in $(seq 5)
do
  ./scan_run_check.sh
  if [ $? -eq 0 ]; then break; fi
  $sixdesk_path/condor_wait.sh -n "run_six/$workspace/" -i 600
done

rm -f *.pkl *.db
python2 scan_plot_sixdb.py
