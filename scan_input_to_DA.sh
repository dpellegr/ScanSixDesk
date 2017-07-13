
# pass 1 to skip madx, 2 to skip sixtrack, 3 to skip check

source ./sixdeskenv.sh

entry_point=0
if [ "$#" -ge "1" ]
then
  entry_point="$1"
fi

if [ $entry_point -lt 1 ]; then
  ./scan_make_input.sh
  $sixdesk_path/condor_wait.sh -n "mad/$workspace/" -i 150
fi

if [ $entry_point -lt 2 ]; then
  ./scan_run_six.sh
  $sixdesk_path/condor_wait.sh -n "run_six/$workspace/" -i 600
fi

if [ $entry_point -lt 3]; then
  while [ cnt=$(./scan_run_check); cnt -gt 0 ] do
    echo "Rerunning $cnt studies"
    $sixdesk_path/condor_wait.sh -n "run_six/$workspace/" -i 600
  done
fi

python2 scan_plot_sixdb.py
