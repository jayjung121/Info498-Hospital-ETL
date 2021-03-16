# Info498-Hospital-ETL

For better description, check out Technical Documentation_ByungsuJung document in \ByungsuJung_Info498_Final\Documents

Info498 Final project

ETL Process(Final)

Introduction  
This document is a technical support document that illustrates whole ETL process from reading flat file to extract data to backup database using job. The ETL process starts with extracting data from comma separated value file. Once the data is extracted, the staging tables are created to receive the data extracted and load data into OLTP database. Once the data loading to OLTP database is finished, the data in OLTP is also loaded into OLAP Data warehouse for reporting purposes. Once all the ETL process is completed, I have created a job in SQL management studio to process daily Backup task of all the database used in this ETL process.
The whole ETL process is very similar to normal ETL process conducted in another field. The following is outline of the process. 

*Make sure to run the program as Administrator

The following is an outline of entire ETL process of the Patient database and DWClinicReportData.

•	Extract data from flat file
•	Load the extracted data into staging table and synchronize the staging table with the Patients.dbo.Visits table.
•	Create DWClinicReportData databse
•	Pre-load process
•	DWClinicReportData ETL process
•	Post-load process
•	Create a job that performs backup task.
•	Create SSIS for whole ETL process




1.	Extract data from flat file
In order to extract data from provided flat files, staging table is created to hold the data before it is transferred into the OLTP database. 



























Figure01. Bulk Insert
Once the tables are created, the SQL Bulk Insert statement is used to read the data in flat file and load the data into the staging tables.


2.	Load the extracted data into staging table and synchronize the staging table with the Patients.dbo.Visits table.
Once the data has been loaded into staging table that is constructed for storing data before it is transferred into the OLTP database, pETLSyncVisit procedure synchronize the data in staging table and the Patients.dbo.Visits table in OLAP database by using merge technique.
















Figure02. pETLSyncVisit

3.	Create DWClinicReportData
The creation of DWClinicReportData is done by running the SQL script file called ‘Create DWClinicReportData’
  
Figure03. ‘Create DWClinicReportData’

4.	Pre-load process
The pre-load process represents the process required to be succeeded before performing actual ETL process. In this case, the pre-load process consists of truncate table process and drop foreign key constraint process. The stored procedure named pETLDropForeignKeyConstraints is created to perform foreign key constraint dropping process.




5.	



Figure03. pETLDropForeignKeyConstraints
pETLDropForeignKeyConstraints





Figure04. pETLTruncateTables

6.	DWClinicReportData ETL Process
In this process, I have created view and procedure for each tables. Following are list of the view and procedures created to load the data into OLAP report Data warehouse from OLTP database

 [dbo].[vETLDimClinics]		-		[dbo].[pETLFillDimClinics]	
NA					-		[dbo].[pETLFillDimDates]
[dbo].[vETLDimDoctors]		-		[dbo].[pETLFillDimDoctors]
[dbo].[vETLDimPatients]		-		[dbo].[pETLFillDimPatients]
[dbo].[vETLDimProcedures]		-		[dbo].[pETLFillDimProcedures]

[dbo].[vETLDimShifts]		-		[dbo].[pETLFillDimShifts]
[dbo].[vETLFactDoctorShifts]		-		[dbo].[pETLFillFactDoctorShifts

[dbo].[vETLFactVisits]		-		[dbo].[pETLFillFactVisits]

  

Figure05. Stored procedures and views

Each of the view extract the data from multiple tables in OLTP database and convert the value into the format that matches the format of OLAP Data Warehouse.
Then, each view tables are used in Stored Procedures to Insert data into the OLAP Data Warehouse. For example, the following are view and stored procedure for the table DimClinic.


7.	







Figure06. vETLDimClinics












Figure06. Stored procedures pETLFillDimClinics

8.	Post-Load process

The post load process is a finishing step of ETL process. In this process, the foreign key constraints that had been removed for ETL purposed are restored.









Figure07. pETLAddForeignKeyConstraints



9.	Create a job that performs the backup task
To create a job that performs the task that you wish to perform, there exist a section called SQL SERVER AGENT in Object Explorer where Jobs folder lies within. To create a new job, right click Jobs and select Create New Job.

In this process, the BackupFinalDatabse job is created in the SQL Sever Agent to perform a backup task for all the database used in ETL process namely [DWClinicReportData], [Patients] and [DoctorsSchedules]. 
 
Figure08. SQL Server Agent
The newly created job is assigned a task to perform in step section, and  the schedule to perform a task in schedule section. Once the job is created, test the job by right clicking the newly created job and select ‘Start Job at Step..’.
 
Figure09. Test Job



10.	Create SSIS for whole ETL process
 
Figure09. SSIS Flow chart

Creating SSIS package that performs the ETL process as same as one illustrated in this document is final task of the whole ETL process.
The process starts with creating connection to both DWClinicReportData and tempdb to call the stored procedure created previously.
  
Figure10. Connection
Once the connections are set, drag Excute SQL Task from SSIS tool box and assign them different connection and SQL commend that are required for each ETL processes.
 
Figure11. Execute SQL Task Editor

Summary
The whole ETL process in this document consist of extract data from flat file, load the extracted data into staging table and synchronize the staging table with the Patients.dbo.Visits table, create DWClinicReportData database, pre-load process, DWClinicReportData ETL process, post-load process, create a job that performs backup task and create SSIS for whole ETL process.
This document illustrates the entire ETL process from flat file process to backup. This process can be used in different ETL task by altering variable names. Each step in the document must be processed to successfully perform ETL process. Also, the order of steps should be strictly followed to avoid error message.



