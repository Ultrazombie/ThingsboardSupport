#!/bin/bash
count=0;
total=0; 
sudo cat thingsboardOrigin.log | grep TbRuleEngineConsumerStats | grep -o 'totalMsgs = [^ ,]\+' > totalMsgstb.txt; 
for i in $( awk -F'[][]' '{print $2}' totalMsgstb.txt )
   do 
     total=$(echo $total+$i | bc )
     ((count++))
   done
echo "totalMsgs average in minute is"
echo "scale=2; $total / $count" | bc 
​
count=0;
total=0; 
sudo cat thingsboardOrigin.log | grep TbRuleEngineConsumerStats | grep -o 'successfulMsgs = [^ ,]\+' > successfulMsgstb.txt; 
for i in $( awk -F'[][]' '{print $2}' successfulMsgstb.txt )
   do 
     total=$(echo $total+$i | bc )
     ((count++))
   done
echo "successfulMsgs average in minute is"
echo "scale=2; $total / $count" | bc 
​
count=0;
total=0; 
sudo cat thingsboardOrigin.log | grep TbRuleEngineConsumerStats | grep -o 'failedMsgs = [^ ,]\+' > failedMsgstb.txt; 
if [ -s failedMsgstb.txt ]; then 
for i in $( awk -F'[][]' '{print $2}' failedMsgstb.txt )
   do 
     total=$(echo $total+$i | bc )
     ((count++))
   done
echo "failedMsgs average in minute is"
echo "scale=2; $total / $count" | bc 
else
  echo "no failed msgs found"
fi
​
count=0;
total=0; 
sudo cat thingsboardOrigin.log | grep 'JS Invoke Stats' | grep -o 'requests [^ ,]\+' > JSrequeststb.txt; 
for i in $( awk -F'[][]' '{print $2}' JSrequeststb.txt )
   do 
     total=$(echo $total+$i | bc )
     ((count++))
   done
echo "JSrequests average in minute is"
echo "scale=2; (($total / $count))*6" | bc 
​
count=0;
total=0;
sudo cat thingsboardOrigin.log | grep -q 'JS Invoke Stats' | grep -o 'failures [^ ,]\+' > JSfailurestb.txt; 
if [ -s JSfailurestb.txt ]; then 
​
    for i in $( awk -F'[][]' '{print $2}' JSfailurestb.txt )
    do 
        total=$(echo $total+$i | bc )
        ((count++))
    done
    echo "JSfailures average in minute is"
    echo "scale=2; (($total / $count))*6" | bc 
else    
    echo "no JS failures found"
fi
​
count=0;
total=0;
sudo cat thingsboardOrigin.log | grep 'CassandraBufferedRateExecutor' | grep -o 'totalAdded = [^ ,]\+' > CassandraTotalAddedtb.txt; 
if [ -s CassandraTotalAddedtb.txt ]; then
for i in $( awk -F'[][]' '{print $2}' CassandraTotalAddedtb.txt )
   do 
     total=$(echo $total+$i | bc )
     ((count++))
   done
echo "CassandraTotalAdded average in minute is"
echo "scale=2; (($total / $count))*6" | bc 
else 
echo "Cassandra not installed"
fi
​
count=0;
total=0;
sudo cat thingsboardOrigin.log | grep 'TbSqlBlockingQueue' | grep -o 'totalAdded [^ ,]\+' > TbSqltotalAddedAttributestb.txt; 
for i in $( awk -F'[][]' '{print $2}' TbSqltotalAddedAttributestb.txt )
   do 
     total=$(echo $total+$i | bc )
     ((count++))
   done
echo "TbSqltotalAddedAttributes average in minute is"
echo "scale=2; (($total / $count))*2" | bc 
​
sudo rm -r *tb.txt
