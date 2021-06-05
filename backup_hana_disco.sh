# 2012 - riverosm@ar.ibm.com

/bin/mv /hanabackup/* /BACKUPHANA/base/
PID=`/bin/ps -ef |/usr/bin/grep hdbbackint | /usr/bin/grep -v /usr/bin/grep | /usr/bin/awk '{print $2}'`
if $PID <> 0
then
   /bin/kill -9 $PID
fi