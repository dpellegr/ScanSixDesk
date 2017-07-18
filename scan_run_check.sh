#!/bin/sh

source ./scan_definitions.sh

#################

cnt=0

for mask in $mask_list
do
  echo
  echo "####################################################"
  echo "###   CHECKING STUDY: $mask"
  echo "####################################################"
  echo 
  
  $sixdb_path/sixdb studies/${mask} load_dir
  $sixdb_path/sixdb ${mask}.db check_results
  if [ $? -ne 0 ]
  then
    ((++cnt))
    $sixdesk_path/run_six.sh -d $mask -a
  else
    echo " ### OK !"
  fi
done

exit $cnt
