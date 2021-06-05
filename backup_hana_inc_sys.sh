# 2012 - riverosm@ar.ibm.com

hdbsql -i 0 -u system -p XXXXXXXX "backup data differential for SYSTEMDB using backint ('/usr/sap/PRD/SYS/global/hdb/backint/diario_weekday_$(date +'m%d')')"