#/bin/bash
#proxystatcheck.sh by Eliezer Croitoru
#you can use a ramfs/shm fs to lower the disk R\W access
while read url
do
if [ -a /tmp/proxy1.err ]
then
 echo ERR
else
 echo OK
fi
done 
