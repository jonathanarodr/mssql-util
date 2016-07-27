USE [msdb]
GO

/****** Object:  Job [job_Kill_HeadBlocker]    Script Date: 07/27/2016 12:30:11 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 07/27/2016 12:30:11 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'job_Kill_HeadBlocker', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Finaliza head blocker ao atingir 5 minutos de bloqueio.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Executar Script]    Script Date: 07/27/2016 12:30:11 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Executar Script', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @cSQL               varchar(50)
       ,@nCdIDProcesso      int
       ,@cNmComputador      varchar(100)
       ,@cNmLogin           varchar(100)
       ,@cHostName          varchar(100)
       ,@dDtLogin           datetime
       ,@dDtInicioExec      datetime
       ,@cStatusExec        varchar(50)
       ,@cFlgTransacaoAtiva int
       ,@cComandoSQL        varchar(max)

SET @nCdIDProcesso = 0

SELECT @nCdIDProcesso      = sysprocblock.spid
      ,@cNmLogin           = sysprocblock.loginame
      ,@dDtLogin           = sysprocblock.login_time
      ,@cNmComputador      = sysprocblock.hostname
      ,@dDtInicioExec      = sysprocblock.last_batch
      ,@cStatusExec        = UPPER(sysprocblock.status)
      ,@cFlgTransacaoAtiva = open_tran
      ,@cComandoSQL        = dmsqltext.text
  FROM master.dbo.sysprocesses sysprocblock
       CROSS APPLY sys.dm_exec_sql_text(sysprocblock.sql_handle) as dmsqltext
 WHERE DB_Name(sysprocblock.dbid) = DB_NAME()
   AND sysprocblock.loginame     <> ''sa''
   AND sysprocblock.blocked       = 0
   AND EXISTS (SELECT 1 
                 FROM master.dbo.sysprocesses sysproc
                WHERE sysproc.blocked = sysprocblock.spid)

--
-- se localizou ''head blocker'' e o mesmo ultrapassou o limite de 5 min de bloqueio, finaliza processo
--                  
IF (@nCdIDProcesso <> 0) AND (DATEDIFF(MINUTE, @dDtInicioExec, GETDATE()) > 5)
BEGIN

    SET @cSQL = ''KILL '' + CAST(@nCdIDProcesso as varchar)
    EXEC(@cSQL)
    
    INSERT INTO TempProcessoSQL
         VALUES(@nCdIDProcesso
               ,DB_NAME()
               ,LTRIM(RTRIM(@cNmLogin))
               ,@dDtLogin
               ,@cNmComputador
               ,@dDtInicioExec
               ,@cStatusExec
               ,@cFlgTransacaoAtiva
               ,GETDATE()
               ,@cComandoSQL)

END', 
		@database_name=N'$NomeDatabase', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Executar Job', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160617, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0b3dea06-8422-42da-b8a1-a2253bb601aa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


