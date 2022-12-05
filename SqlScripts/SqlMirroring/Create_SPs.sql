USE [MIRROR_LN107]
GO

/****** Object:  StoredProcedure [config].[WriteMirrorCopyLog]    Script Date: 12/5/2022 4:42:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [config].[WriteMirrorCopyLog] (@ExecutionID uniqueidentifier, @Table nvarchar(100) = NULL, @Status nvarchar(20), @Detail nvarchar(400) = NULL ) AS 

INSERT INTO [config].[MirrorCopyLog] (
	 [ExecutionID]
	,[Table]
	,[Status]
	,[Detail]
) VALUES (
	 @ExecutionID
	,@Table
	,@Status
	,@Detail
)
GO

USE [MIRROR_LN107]
GO


/****** Object:  StoredProcedure [config].[CopyTable]    Script Date: 12/5/2022 4:42:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Giovanni Luisotto
-- Create date: 2018-03-06
-- Description:	Create a copy of the table
-- =============================================
CREATE PROCEDURE [config].[CopyTable]
	 @Source_Server nvarchar(50) = @@servername
	,@Source_DataBase nvarchar(50)
	,@Source_Schema nvarchar(50)
	,@Source_TableName nvarchar(50)
	,@Destination_Server nvarchar(50) = @@servername
	,@Destination_DataBase nvarchar(50)
	,@Destination_Schema nvarchar(50)
	,@Destination_TableName nvarchar(50)

AS
BEGIN

	--============ Check if table Exist ============================================
	--Param needed by sp_executesql
	DECLARE @SQLString nvarchar(500)
	DECLARE @ParmDefinition nvarchar(500)
	--Source Params
	DECLARE @Source_Srv_Db nvarchar(100)
	SET @Source_Srv_Db = QUOTENAME(@Source_Server)+'.'+QUOTENAME(@Source_DataBase)
	--Output variable
	DECLARE @Out_TableName varchar(50)

	--Parametrize query to execute
	SET @SQLString = '
		SET @pOutput = (
			SELECT TABLE_NAME
			FROM '+@Source_Srv_Db+'.INFORMATION_SCHEMA.TABLES
			WHERE TABLE_NAME = '''+@Source_TableName+'''
		)'
	;
	--PRINT @SQLString;	--DEBUG ONLY

	--Declare parameters used inside @SQLString
	SET @ParmDefinition = N'@pOutput nvarchar(50) OUTPUT';

	--Execute, assigning values to the parameters
	EXECUTE sp_executesql @SQLString, @ParmDefinition, @pOutput = @Out_TableName OUTPUT;
	Print @Out_TableName

	--Throw error if the given Table does not exist
	IF @Out_TableName IS NULL 
		THROW 50000, 'The specified table does not exist', 1;

	--==================================================================================

	DECLARE @Source nvarchar(200)
	SET @Source = QUOTENAME(@Source_Server)+'.'+QUOTENAME(@Source_DataBase)+'.'+QUOTENAME(@Source_Schema)+'.'+QUOTENAME(@Source_TableName)

	DECLARE @Destination nvarchar(200)
	IF @Destination_Server != @@servername	--if different specify linked server
		SET @Destination = QUOTENAME(@Destination_Server)+'.'+QUOTENAME(@Destination_DataBase)+'.'+QUOTENAME(@Destination_Schema)+'.'+QUOTENAME(@Destination_TableName)
	ELSE	--if same (local) server omit server (can't DROP or use INTO with ServerName)
		SET @Destination = QUOTENAME(@Destination_DataBase)+'.'+QUOTENAME(@Destination_Schema)+'.'+QUOTENAME(@Destination_TableName)

	--Create the sql statement
	DECLARE @Sql AS NVARCHAR(512);
	SET @Sql  = '
	DROP TABLE IF EXISTS '+ @Destination +'
	SELECT *
	INTO '+ @Destination +'
	FROM '+ @Source +'
	WITH (NOLOCK)
	'

	EXECUTE (@Sql)

END

GO

USE [MIRROR_LN107]
GO

/****** Object:  StoredProcedure [config].[ExecuteMirrorCopy]    Script Date: 12/5/2022 4:43:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [config].[ExecuteMirrorCopy] AS

BEGIN TRY
	--Param for logging
	DECLARE @Log_ExececutionID uniqueidentifier = NEWID()
	DECLARE @Log_FullSourceTableName	AS NVARCHAR(100)
	DECLARE @Log_Error					AS NVARCHAR(400)

	--param for table mirroring
	DECLARE @Par_Source_Server			AS NVARCHAR(50)
	DECLARE @Par_Source_DataBase		AS NVARCHAR(50)
	DECLARE @Par_Source_Schema			AS NVARCHAR(50)
	DECLARE @Par_Source_TableName		AS NVARCHAR(50)
	DECLARE @Par_Destination_Server		AS NVARCHAR(50)
	DECLARE @Par_Destination_DataBase	AS NVARCHAR(50)
	DECLARE @Par_Destination_Schema		AS NVARCHAR(50)
	DECLARE @Par_Destination_TableName	AS NVARCHAR(50)

	EXEC [config].[WriteMirrorCopyLog] 
	 @ExecutionID = @Log_ExececutionID 
	,@Table = 'Procedure'
	,@Status = 'Started'
	;

	DECLARE TableListCursor CURSOR LOCAL STATIC FOR
	SELECT
		 [Source_Server]
		,[Source_DataBase]
		,[Source_Schema]
		,[Source_TableName]
		,[Destination_Server]
		,[Destination_DataBase]
		,[Destination_Schema]
		,[Destination_TableName]
	FROM [MIRROR_LN107].[config].[MirrorCopy]
	WHERE [Enabled] = 1

	OPEN TableListCursor
	WHILE 1 = 1 BEGIN	--Loop break condition is specified below
	
		FETCH NEXT FROM TableListCursor
		INTO 
			 @Par_Source_Server			
			,@Par_Source_DataBase		
			,@Par_Source_Schema			
			,@Par_Source_TableName		
			,@Par_Destination_Server		
			,@Par_Destination_DataBase
			,@Par_Destination_Schema		
			,@Par_Destination_TableName
		;

		if @@FETCH_STATUS <> 0 BREAK;	--break loop, the check must be done after FETCH NEXT (otherwise the last row run twice)

		SET @Log_FullSourceTableName = CONCAT_WS('.', QUOTENAME(@Par_Source_Server), QUOTENAME(@Par_Source_DataBase), QUOTENAME(@Par_Source_Schema) ,QUOTENAME(@Par_Source_TableName))

		EXEC [config].[WriteMirrorCopyLog] 
		 @ExecutionID = @Log_ExececutionID 
		,@Table = @Log_FullSourceTableName
		,@Status = 'Started'
		;
	
		EXECUTE [MIRROR_LN107].[config].[CopyTable] 
			 @Source_Server = @Par_Source_Server
			,@Source_DataBase = @Par_Source_DataBase
			,@Source_Schema = @Par_Source_Schema
			,@Source_TableName = @Par_Source_TableName
			,@Destination_Server = @Par_Destination_Server
			,@Destination_DataBase = @Par_Destination_DataBase
			,@Destination_Schema = @Par_Destination_Schema
			,@Destination_TableName = @Par_Destination_TableName
		;

		EXEC [config].[WriteMirrorCopyLog] 
		 @ExecutionID = @Log_ExececutionID 
		,@Table = @Log_FullSourceTableName
		,@Status = 'Completed'
		;
	END

	CLOSE TableListCursor
	DEALLOCATE TableListCursor

	EXEC [config].[WriteMirrorCopyLog] 
	 @ExecutionID = @Log_ExececutionID 
	,@Table = 'Procedure'
	,@Status = 'Completed'
	;
END TRY
BEGIN CATCH
	--Log Exception and throw exception
	SELECT @Log_Error = CONCAT_WS(' - ', ERROR_NUMBER(), ERROR_MESSAGE())
	EXEC [config].[WriteMirrorCopyLog] 
		 @ExecutionID = @Log_ExececutionID 
		,@Status = 'Error'
		,@Detail = @Log_Error
	;
	THROW
END CATCH

GO



