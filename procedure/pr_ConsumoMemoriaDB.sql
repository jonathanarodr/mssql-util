/*
Autor : Danilo Santos
*/

IF (OBJECT_ID('pr_ConsumoMemoriaDB','P') IS NOT NULL)
    DROP PROCEDURE pr_ConsumoMemoriaDB
GO    

CREATE PROCEDURE pr_ConsumoMemoriaDB

AS

BEGIN

    SET TRAN ISOLATION LEVEL READ UNCOMMITTED

    SELECT ISNULL(DB_NAME(database_id), 'ResourceDb') as DatabaseName
          ,CAST(COUNT(row_count) * 8.0 / (1024.0) as decimal (28,2)) as [Size (MB)]
      FROM sys.dm_os_buffer_descriptors
     GROUP BY database_id
     ORDER BY 2 desc
 
END