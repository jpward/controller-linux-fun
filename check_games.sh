#!/bin/bash

set -e

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

HYPERKIN_MOUSE_CLICK_TMP=/tmp/hyperkin_mouse_click.txt
HYPERKIN_MOUSE_PID=""

JOYSTICK_TOGGLE_PREV=1
GAMES="Spyro.exe CrashBandicootNSaneTrilogy.exe retroarch D2R.exe game.exe"
RUN=true
NUM_CNTRLRS=$(xinput --list | wc -l)
while $RUN; do
  JOYSTICK_TOGGLE=1
  FORCE_TOGGLE=false
  NEW_NUM_CNTRLRS=$(xinput --list | wc -l)
  if ! [ ${NEW_NUM_CNTRLRS} -eq ${NUM_CNTRLRS} ]; then
    NUM_CNTRLRS=${NEW_NUM_CNTRLRS}
    FORCE_TOGGLE=true
  fi
  for g in $GAMES; do
    if ( pgrep -f $g ); then
      JOYSTICK_TOGGLE=0
      break;
    fi
  done
  if ! [ $JOYSTICK_TOGGLE -eq $JOYSTICK_TOGGLE_PREV ] || ${FORCE_TOGGLE} ; then
    JOYSTICK_TOGGLE_PREV=$JOYSTICK_TOGGLE
    ${HERE}/toggle_joystick.sh $JOYSTICK_TOGGLE

    echo "${JOYSTICK_TOGGLE}" > ${HYPERKIN_MOUSE_CLICK_TMP}
    if [ -z "${HYPERKIN_MOUSE_PID}" ] || ! ( kill -0 ${HYPERKIN_MOUSE_PID} ); then
      ${HERE}/hyperkin_mouse_click.sh &
      HYPERKIN_MOUSE_PID=$!
    fi
  fi
  sleep 3
done
