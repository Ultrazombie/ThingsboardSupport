#!/bin/bash

LOGS_PATH="./thingsboard.log"

if [ $1 ]
then
  LOGS_PATH=$1
fi

TOTAL='totalMsgs' 
SUCCESSFUL='successfulMsgs' 
FAILED='failedMsgs'
REQUESTS='requests'
FAILURES='failures'
TOTAL_ADDED='totalAdded'

function parse_log {
  LOGS_PATH=$1
  NAME=$2
  MESSAGE=$3
  MESSAGE_FILENAME="./temp/${MESSAGE}tb.txt"
  MESSAGE_REGEX="${MESSAGE}.\{1,3\}\[.\{1,6\}\]\+"
  count=0
  total=0
  max=0
  sudo cat ${LOGS_PATH} | grep "$NAME" | grep -o $MESSAGE_REGEX > $MESSAGE_FILENAME 
  for i in $( awk -F'[][]' '{print $2}' $MESSAGE_FILENAME )
    do 
      total=$(echo $total+$i | bc )
      ((count++))
      if [ $(echo "$max<=$i" | bc) -ge 1 ] 
        then 
          max=$i
        fi
    done
  if [ $total == 0 ]
    then
      echo "$NAME ${MESSAGE}: 0 messages"
    else
      echo "$NAME ${MESSAGE}: average in minute is $(echo "scale=2; $total / $count" | bc ) "
      echo "$NAME ${MESSAGE}: max in minute is $max "
  fi
}

if [ ! -f "$LOGS_PATH" ]; 
then
    echo "File $LOGS_PATH not exist"
else
mkdir -p temp
parse_log $LOGS_PATH TbRuleEngineConsumerStats $TOTAL
parse_log $LOGS_PATH TbRuleEngineConsumerStats $SUCCESSFUL
parse_log $LOGS_PATH TbRuleEngineConsumerStats $FAILED
parse_log $LOGS_PATH "JS.Invoke.Stats" $REQUESTS
parse_log $LOGS_PATH "JS.Invoke.Stats" $FAILURES
parse_log $LOGS_PATH CassandraBufferedRateExecutor $TOTAL_ADDED
parse_log $LOGS_PATH TbSqlBlockingQueue $TOTAL_ADDED

sudo rm -r ./temp
fi

