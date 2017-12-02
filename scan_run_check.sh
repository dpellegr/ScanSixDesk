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
  
  #$sixdb_path/sixdb studies/${mask} load_dir
  #$sixdb_path/sixdb ${mask}.db check_results
  $sixdesk_path/set_env.sh -d $mask
  python -c "import sys; sys.path.append('/afs/cern.ch/user/d/dpellegr/public/SixDeskDB/'); import sixdeskdb;
sys.exit(sixdeskdb.SixDeskDB.from_dir('./studies/$mask/').check_results(update_work=True))"
  if [ $? -ne 1 ]
  then
    ((++cnt))
#    cp work/completed_cases  work/mycompleted_cases
#    cp work/incomplete_cases work/myincomplete_cases
    $sixdesk_path/run_six.sh -U -d $mask -i
  else
    echo " ### OK !"
  fi
done

exit $cnt
