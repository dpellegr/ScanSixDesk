#!/bin/sh

source ./scan_definitions.sh

#################

for mask in $mask_list
do
  echo
  echo "####################################################"
  echo "###   RUNNING SIXTRACK FOR STUDY: $mask"
  echo "####################################################"
  echo 
  
  $sixdesk_path/run_six.sh -d $mask -a
done
