/*
Autor : Danilo Santos
*/

IF (OBJECT_ID('pr_VerificaIndiceSemUso','P') IS NOT NULL)
    DROP PROCEDURE pr_VerificaIndiceSemUso
GO    

CREATE PROCEDURE pr_VerificaIndiceSemUso (@cNmTabela varchar(100))

AS

BEGIN

    --
    -- Analisar bem caso a caso, as DMVs podem ajudar mas não confie nelas 100%
    --
	SELECT object_schema_name(indexes.object_id) + '.' + object_name(indexes.object_id) as objectName
	      ,indexes.name
	      ,case when is_unique = 1 
	            then 'UNIQUE ' 
	            else '' 
	       end + indexes.type_desc as type
	      ,ddius.user_seeks
	      ,ddius.user_scans
	      ,ddius.user_lookups
	      ,ddius.user_updates
	  FROM sys.indexes
	  LEFT OUTER JOIN sys.dm_db_index_usage_stats ddius
		ON indexes.object_id = ddius.object_id
	   AND indexes.index_id = ddius.index_id
	   AND ddius.database_id = db_id()
	 WHERE sys.indexes.object_id = Object_ID(@cNmTabela)
	ORDER BY ddius.user_seeks + ddius.user_scans + ddius.user_lookups DESC
	
END