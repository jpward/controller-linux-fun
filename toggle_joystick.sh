#!/bin/bash

if [ $# -eq 1 ]; then
  ENABLE=$1
else
  echo "Needs argument of 0 or 1, to enable/disable joystick"
fi

#id=$(xinput --list --id-only 'Xbox Wireless Controller')
ids=$(xinput --list | grep 'Hyperkin Pad\|Xbox Wireless Controller' | grep -v '(keys)' | grep -o 'id=[0-9]*' | cut -d'=' -f2)
for id in ${ids}; do
  source <(xinput list-props $id | perl -ne'
    if(m/Generate Mouse Events \(([0-9]+)\)/){print"props_mouse=$1;";}
    if(m/Generate Key Events \(([0-9]+)\)/){print"props_teclado=$1;";}
  ')

  xinput set-prop $id $props_mouse $1
  xinput set-prop $id $props_teclado $1
done
