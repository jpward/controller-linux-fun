#!/bin/bash -x

set -e

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

HYPERKIN_MOUSE_CLICK_TMP=/tmp/hyperkin_mouse_click.txt

CLICK_A=false
CLICK_B=false
TMP_JSTEST_OUTPUT="/tmp/jstest_output.txt"
JSTEST_PID=""
RUN=true
while ${RUN}; do
  if [ $(cat ${HYPERKIN_MOUSE_CLICK_TMP}) -eq 0 ]; then
    continue
  fi
  for f in $(ls /dev/input | grep '^js'); do
    jstest --event /dev/input/$f > ${TMP_JSTEST_OUTPUT} 2>&1 &
    JSTEST_PID=$!
    sleep 1
    if [ -z "${JSTEST_PID}" ]; then
      break
    fi
    if ! ( head -2 ${TMP_JSTEST_OUTPUT} | grep -q 'Hyperkin Pad' ); then
      if ! [ -z "${JSTEST_PID}" ]; then
        kill -9 ${JSTEST_PID}
      fi
      continue
    else
      A_TIME=-999999
      B_TIME=-999999
      while ${RUN}; do
        if ( kill -0 ${JSTEST_PID} ); then
          AB_STATES="$(tail -10 ${TMP_JSTEST_OUTPUT} | grep 'number 0, value 1\|number 1, value 1' || echo "")"
	  A_TIMES="$(echo $AB_STATES | sed 's/Event/\nEvent/g' | tail +2 | grep 'number 0, value 1' | sed 's/.*time \(.*\), number.*/\1_0/g')"
	  B_TIMES="$(echo $AB_STATES | sed 's/Event/\nEvent/g' | tail +2 | grep 'number 1, value 1' | sed 's/.*time \(.*\), number.*/\1_1/g')"
	  for t in $(echo ${A_TIMES} ${B_TIMES} | sort); do
	    PRESS_TIME=$(echo ${t} | cut -d'_' -f1)
	    PRESS_TYPE=$(echo ${t} | cut -d'_' -f2)
            if [ ${PRESS_TYPE} -eq 0 ] && [ ${PRESS_TIME} -gt ${A_TIME} ]; then
              xte 'mouseclick 1'
	      A_TIME=${PRESS_TIME}
            elif [ ${PRESS_TYPE} -eq 1 ] && [ ${PRESS_TIME} -gt ${B_TIME} ]; then
              xte 'mouseclick 3'
	      B_TIME=${PRESS_TIME}
            fi
          done
        else
          JSTEST_PID=""
          break
        fi

        if [ $(cat ${HYPERKIN_MOUSE_CLICK_TMP}) -eq 0 ]; then
          break
        fi

	sleep 0.1
      done
      break
    fi
  done

  if ! [ -z "${JSTEST_PID}" ]; then
    kill -9 ${JSTEST_PID}
  fi

  sleep 3
done
