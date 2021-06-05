# 2012 - riverosm@ar.ibm.com

cp /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD_S.utl /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD.utl
/usr/sap/PRD/HDB00/exe/hdbsql -t -u system -p XXXXXXXX -n hanaprd:30013 "backup data for SYSTEMDB using backint ('full_weekday_$(date +'%Y%m%d_%H%M%S')')"
/usr/sap/PRD/HDB00/exe/hdbsql -t -u system -p XXXXXXXX -n hanaprd:30013 "backup data for PRD using backint ('full_weekday_$(date +'%Y%m%d_%H%M%S')')"
# Viejos
#/usr/sap/PRD/HDB00/exe/hdbsql -t -U TSM "backup data for SYSTEMDB using backint ('full_weekday_$(date +'%Y%m%d_%H%M%S')')"
#/usr/sap/PRD/HDB00/exe/hdbsql -t -U TSM "backup data for DEV using backint ('full_weekday_$(date +'%Y%m%d_%H%M%S')')"
#/usr/sap/PRD/HDB00/exe/hdbsql -t -U TSM "backup data using backint ('full_$(date +'%Y%m%d_%H%M%S')')"
cp /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD_D.utl.ori /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD_D.utl
cp /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD.utl.ori /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD.utl