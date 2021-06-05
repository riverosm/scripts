# 2012 - riverosm@ar.ibm.com

cp /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD_D.utl.ori /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD_D.utl
/usr/sap/PRD/HDB00/exe/hdbsql -t -u system -p XXXXXXXX -n hanaprd:30013 "backup data differential for SYSTEMDB using backint ('dif_inc_weekday_$(date +'%Y%m%d_%H%M%S')')"
/usr/sap/PRD/HDB00/exe/hdbsql -t -u system -p XXXXXXXX -n hanaprd:30013 "backup data differential for PRD using backint ('dif_weekday_$(date +'%Y%m%d_%H%M%S')')"
# VIEJOS
#/usr/sap/PRD/HDB00/exe/hdbsql -t -U TSM "backup data differential using backint ('diario_$(date +'%Y%m%d_%H%M%S')')"
#/usr/sap/PRD/HDB00/exe/hdbsql -t -U TSM "backup data differential for SYSTEMDB using backint ('full_weekday_$(date +'%Y%m%d_%H%M%S')')"
#/usr/sap/PRD/HDB00/exe/hdbsql -t -U TSM "backup data differential for PRD using backint ('full_weekday_$(date +'%Y%m%d_%H%M%S')')"