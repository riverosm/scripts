# 2012 - riverosm@ar.ibm.com

cp /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD_M.utl /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD_D.utl
#/usr/sap/PRD/HDB00/exe/hdbsql -t -U TSM "backup data for SYSTEMDB using backint ('mensual_weekday_$(date +'%Y%m%d_%H%M%S')')"
/usr/sap/PRD/HDB00/exe/hdbsql -t -U TSM "backup data using backint ('mensual_$(date +'%Y%m%d_%H%M%S')')"
cp /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD_D.utl.ori /hana/shared/PRD/global/hdb/opt/hdbconfig/initPRD_D.utl