#!/bin/sh

source ./scan_utils.sh

#################
## Definitions ##
#################

export template_mask=template_ats2018.mask
export mask_prefix=ats2018

# When changing the number of scanning parameters adapt also the line "make_mask_names mask_list ..." below
export SCAN_X="$(seq -w 60 10 190)" # Xing
export SCAN_Y="$(seq -w 0.5 0.1 1.7)" # I
#export SCAN_X="60" # Xing
#export SCAN_Y="0.5" # I

make_mask_names mask_list "$SCAN_X" "$SCAN_Y"

export sixdesk_path=/afs/cern.ch/user/d/dpellegr/public/SixDesk/utilities/bash/
export sixdb_path=/afs/cern.ch/project/sixtrack/SixDesk_utilities/pro/utilities/externals/SixDeskDB/

