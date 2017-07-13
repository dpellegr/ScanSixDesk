#!/bin/sh

source ./scan_definitions.sh

#################

for mask in $mask_list
do
  echo
  echo "##########################################################"
  echo "### SETTING ENV AND RUNNING MAD FOR MASK: $mask"
  echo "##########################################################"
  echo
 
  get_pars_from_mask_name PARS $mask
  x=${PARS[0]}
  y=${PARS[1]}
 
  cp mask/$template_mask mask/$mask.mask
  sed -i 's#%QX#'$x'#g' mask/$mask.mask
  sed -i 's#%QY#'$y'#g' mask/$mask.mask
 
  sed -i 's/export LHCDescrip=.*/export LHCDescrip='$mask'/' sixdeskenv
 
  $sixdesk_path/set_env.sh -s #create study
  $sixdesk_path/mad6t.sh -c > /dev/null #check
  if [ "$?" -ne "0" ]
  then
    rm -rf sixtrack_input/*
    $sixdesk_path/mad6t.sh -s #submit
  fi
done

