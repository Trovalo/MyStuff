EXEC sp_MSforeachdb '
USE [?]

select DB_NAME() [database], name as [user_name], type_desc,default_schema_name,create_date,modify_date 
INTO #orphans
from sys.database_principals 
where type in (''G'',''S'',''U'') 
and authentication_type<>2 -- Use this filter only if you are running on SQL Server 2012 and major versions and you have "contained databases"
and [sid] not in ( select [sid] from sys.server_principals where type in (''G'',''S'',''U'') ) 
and name not in (''dbo'',''guest'',''INFORMATION_SCHEMA'',''sys'',''MS_DataCollectorInternalUser'')

--SELECT * FROM #orphans
IF (SELECT COUNT(*) FROM #orphans) > 0 BEGIN
SELECT ''------------------------''
UNION ALL
SELECT ''USE [''+DB_NAME()+'']''
UNION ALL
SELECT
   ''DROP USER '' + QUOTENAME(user_name)
FROM #orphans
UNION ALL
SELECT ''------------------------''
END

DROP TABLE #orphans
'