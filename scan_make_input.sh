#!/bin/sh

source ./scan_definitions.sh

#################
cnt=0
for mask in $mask_list; do
  if [ -d "studies/$mask" ]
  then
    echo
    echo "##########################################################"
    echo "### SWITCHING TO STUDY: $mask"
    echo "##########################################################"
    echo

    $sixdesk_path/set_env.sh -d $mask > /dev/null #checkout study
    echo "Checking..."
    $sixdesk_path/mad6t.sh -U -c #check
    if [ $? -ne "0" ]         # not good, remove everything and prepare for resub
    then
      echo "Not good... resubmitting"
      rm -rf sixtrack_input/*
      $sixdesk_path/mad6t.sh -U -s #submit
      ((++cnt))
    else
      echo "Check is OK!"
    fi
  else
    echo
    echo "##########################################################"
    echo "### SETTING ENV AND RUNNING MAD FOR MASK: $mask"
    echo "##########################################################"
    echo
   
    get_pars_from_mask_name PARS $mask
    x=${PARS[0]} #Xing
    y=${PARS[1]} #Int
  
    cat mask/$template_mask |\
      sed -e 's#%XING#'$x'#g' > "mask/$mask.mask"
  
    cat sixdeskenv |\
      sed -e 's/export LHCDescrip=.*/export LHCDescrip='$mask'/' |\
      sed -e 's/export bunch_charge=.*/export bunch_charge='$y'e11/' > sixdeskenv.new
    mv sixdeskenv.new sixdeskenv
  
    $sixdesk_path/set_env.sh -s #create study
    $sixdesk_path/mad6t.sh -U -s #submit

    ((++cnt))
  fi
done

exit $cnt
