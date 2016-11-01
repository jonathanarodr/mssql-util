IF (OBJECT_ID('pr_ReorganizaIndices','P') IS NOT NULL)
    DROP PROCEDURE pr_ReorganizaIndices
GO

CREATE PROCEDURE pr_ReorganizaIndices

AS

BEGIN

	DECLARE @cSQL     varchar(400)
		   ,@cSchema  varchar(20)
		   ,@cNmTable varchar(150)

	DECLARE curInReorganize CURSOR
		FOR SELECT TABLE_SCHEMA
				  ,TABLE_NAME
			  FROM information_schema.tables 
			 WHERE TABLE_TYPE = 'BASE TABLE'
			 ORDER BY TABLE_NAME

	OPEN curInReorganize

	FETCH NEXT 
	 FROM curInReorganize
	 INTO @cSchema
		 ,@cNmTable

	WHILE (@@FETCH_STATUS = 0)
	BEGIN

		PRINT 'Reorganizando índices do objeto ' + @cNmTable + '...'

		SET @cSQL = 'ALTER INDEX ALL ON [' + DB_NAME() + '].' + @cSchema + '.' + @cNmTable + ' REORGANIZE'
		EXEC(@cSQL)

		FETCH NEXT 
		 FROM curInReorganize
		 INTO @cSchema
			 ,@cNmTable

	END

	CLOSE curInReorganize
	DEALLOCATE curInReorganize

END
