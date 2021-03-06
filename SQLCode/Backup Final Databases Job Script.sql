/***************************************************************************
Info498 Final Project
Dev: Byungsu Jung
--Date: 08/15/2018
Desc: This file create backup for three database namely Patients, DoctorsSchedule and DWClinicReportData.
-- Change Log: When,Who,What
-- 2018-08-17,ByungsuJung,Created File..
*****************************************************************************/
USE tempdb
GO

If Exists(Select * from Sys.objects where Name = 'pBackupDatabase')
   Drop Proc pBackupDatabase;
go
If Exists(Select * from Sys.objects where Name = 'pRestoreBackup')
   Drop Proc pRestoreBackup;
go

Create Procedure pBackupDatabase
/* Author: <ByungSu Jung>
** Desc: Backup database procedure
** Change Log: When,Who,What
** 2018-08-17,<ByungSu Jung>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
  BACKUP DATABASE [DoctorsSchedules]
	TO DISK = N'C:\_BISolutions\DoctorsSchedule.bak' 
	WITH INIT;

	BACKUP DATABASE [DWClinicReportData]
	TO DISK = N'C:\_BISolutions\DWClinicReportData.bak' 
	WITH INIT;

	BACKUP DATABASE [Patients]
	TO DISK = N'C:\_BISolutions\Patients.bak' 
	WITH INIT;
	   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Print 'Error in excuting pBackupDatabase. Common error: incorrect databas name'
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pRestoreBackup
/* Author: <ByungSu Jung>
** Desc: restore database procedure.
** Change Log: When,Who,What
** 2018-08-17,<ByungSu Jung>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
	RESTORE DATABASE [DoctorsSchedule] 
	FROM DISK = N'C:\_BISolutions\DoctorsSchedule.bak' 
	WITH FILE = 1
  , MOVE N'DoctorsSchedule' TO N'C:\_BISolutions\DoctorsSchedule-Reports.mdf'
  , MOVE N'DoctorsSchedule_log' TO N'C:\_BISolutions\DoctorsSchedule-Reports.ldf'
  , REPLACE;

	RESTORE DATABASE [Patients] 
	FROM DISK = N'C:\_BISolutions\Patients.bak' 
	WITH FILE = 1
  , MOVE N'Patients' TO N'C:\_BISolutions\Patients-Reports.mdf'
  , MOVE N'Patients_log' TO N'C:\_BISolutions\Patients-Reports.ldf'
  , REPLACE;
  	RESTORE DATABASE [DWClinicReportData] 
	FROM DISK = N'C:\_BISolutions\DWClinicReportData.bak' 
	WITH FILE = 1
  , MOVE N'DWClinicReportData' TO N'C:\_BISolutions\DWClinicReportData-Reports.mdf'
  , MOVE N'DWClinicReportData_log' TO N'C:\_BISolutions\DWClinicReportData-Reports.ldf'
  , REPLACE;
	   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Print 'Error in excuting pBackupDatabase. Common error: incorrect databas name'
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
-------------------------------------------- Job script ------------------------------------
USE [msdb]
GO

/****** Object:  Job [BackupFinalDatabase]    Script Date: 8/18/2018 3:50:12 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 8/18/2018 3:50:12 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BackupFinalDatabase', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job performs three database backup.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Three Backups]    Script Date: 8/18/2018 3:50:12 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Three Backups', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Execute pBackupDatabase;', 
		@database_name=N'tempdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DailyBackup', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180817, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'980939f7-d6ec-40c4-a6f8-09302233d9d8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'localhost\jbs'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

