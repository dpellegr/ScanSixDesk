#!/bin/sh

# Creates the names of the masks expanding all the passed list of parameters
make_mask_names() {
  local _outvar=$1
  local _result="${mask_prefix}"

  local _arg
  local _x
  local _r
  local _new

  for _arg in "${@:2}" # skip the first two args (func_name ret_var)
  do
    if [[ ! -z "${_arg// }" ]] # test if the argument is not whites only
    then
      _new=""
      for _r in $_result # take all the old strings...
      do
        for _x in $_arg
        do
          _new="$_new ${_r}_${_x}" # ...and append the new parameter
        done
      done
      _result=${_new:1} # strip the leading space
    fi
  done
  eval $_outvar='$_result'
}
# EXAMPLE 
# make_mask_names mask_list "$SCAN_X" "$SCAN_Y"

# Get back the array of parameters extracting them from the mask name
get_pars_from_mask_name() {
  local _outvar=$1
  local _mask="$2" #mask name

  _mask=${_mask#$mask_prefix}
  IFS='_' read -ra ARRAY <<< "$_mask"
  eval $_outvar='( ${ARRAY[@]} )'
}
# EXAMPLE
# get_pars_from_mask_name PARS xbi_1_2_3
# for i in "${PARS[@]}"; do
#   echo $i
# done

