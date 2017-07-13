# ScanSixDesk
Scanning scripts for studies with sixdesk.

Manual adjustment in *scan_definitions.sh* and *scan_make_input.sh* is required according to which parameter one want to scan.

**scan_definitions.sh**
Put here paths and ranges

**scan_make_input.sh**
Performs the required substitutions, creates the studies and runs madx

**scan_run_six.sh**
Runs Sixtrack for all the studies

**scan_run_check.sh**
Checks the outcomes with sixdb and resumbit in case of issues

**scan_plot_sixdb.py**
For plotting the scans

**scan_input_to_DA.sh**
Does all of the above automatically

**scan_utils.sh**
Some support functions, no need to look in there
