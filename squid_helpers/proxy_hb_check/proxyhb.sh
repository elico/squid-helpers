#/bin/bash
#proxyhb.sh
#heart beat state script by Eliezer Croitoru
#customize the locations and files names
#change the proxy address and test url
#the alive.html contains: <html><body><h1>It works!</h1></body></html>
#you can use a ramfs/shm fs to lower the disk R\W access

timestamp="$(date +%Y-%m-%d_%a_%H_%M)"
LOGFILE="/var/log/proxystat.log"
MARKER="/tmp/proxy1.err"
PROXYADD="http://127.0.0.1:3128/"
WORKSTAR="http://www1.ngtech.co.il/alive.html"
STATE="0"
echo "$timestamp starting proxy 127.0.0.1:3128 heartbeat">>$LOGFILE
if [ -a $MARKER ] ; then
   rm $MARKER
fi
while true;do

curl -s -x $PROXYADD $WORKSTAR|grep "works\!" >/dev/null 2>&1
TESTRES=$?
timestamp="$(date +%Y-%m-%d_%a_%H_%M)"
if [ $TESTRES == 0 ] && [ $STATE == 0 ]
then
      echo "$timestamp proxy still up" >>$LOGFILE

fi

if [ "$TESTRES" == 0 ] && [ "$STATE" == 1 ]
then
        rm $MARKER
        STATE="0"
        echo "$timestamp proxy got up" >>$LOGFILE

fi

if [ "$TESTRES" == 1 ] && [ "$STATE" == 0 ]
then
        touch $MARKER
        STATE="1"
        echo "$timestamp proxy got down">>$LOGFILE

fi

if [ "$TESTRES" == 1 ] && [ "$STATE" == 1 ]
then
        echo "$timestamp proxy down again">>$LOGFILE

fi

# debug options to see the last log and end progress of loop on stdout
#tail -1 $LOGFILE
#echo "$timestamp sleeping"

sleep 30
done 
