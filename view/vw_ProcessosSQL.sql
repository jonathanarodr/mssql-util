IF (OBJECT_ID('vw_ProcessosSQL','V') IS NOT NULL)
    DROP VIEW vw_ProcessosSQL
GO

CREATE VIEW vw_ProcessosSQL

AS

SELECT sysprocblock.spid          as nCdIDProcesso
      ,sysprocblock.loginame      as cNmLogin
      ,sysprocblock.login_time    as dDtLogin
      ,sysprocblock.hostname      as cHostName
      ,sysprocblock.last_batch    as dDtInicioExec
      ,UPPER(sysprocblock.status) as cStatusExec
      ,open_tran                  as iTransacoes
      ,sysprocblock.blocked       as nCdBlockID
      ,CASE WHEN EXISTS (SELECT 1 
	                       FROM master.dbo.sysprocesses sysproc
	                      WHERE sysproc.blocked = sysprocblock.spid)
	        THEN 1
	        ELSE 0
	   END cFlgHeadBlocker
	  ,dmsqltext.text             as cComandoSQL
  FROM master.dbo.sysprocesses sysprocblock
       CROSS APPLY sys.dm_exec_sql_text(sysprocblock.sql_handle) as dmsqltext
 WHERE DB_Name(sysprocblock.dbid) = DB_NAME()