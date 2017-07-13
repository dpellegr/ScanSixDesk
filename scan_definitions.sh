#!/bin/sh

source ./scan_utils.sh

#################
## Definitions ##
#################

export template_mask=template_ats2017_tune.mask
export mask_prefix=ats2017

# When changing the number of scanning parameters adapt also the line "make_mask_names mask_list ..." below
export SCAN_X="$(seq -w 62.300 0.002 62.324)" # Qx
export SCAN_Y="$(seq -w 62.300 0.002 62.324)" # Qy
make_mask_names mask_list "$SCAN_X" "$SCAN_Y"

export sixdesk_path=/afs/cern.ch/user/d/dpellegr/public/SixDesk/utilities/bash/
export sixdb_path=/afs/cern.ch/project/sixtrack/SixDeskDB/

