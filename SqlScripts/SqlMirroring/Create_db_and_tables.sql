USE [MIRROR_LN107]
GO

/****** Object:  Table [config].[MirrorCopy]    Script Date: 12/5/2022 4:40:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[MirrorCopy]') AND type in (N'U'))
DROP TABLE [config].[MirrorCopy]
GO

/****** Object:  Table [config].[MirrorCopy]    Script Date: 12/5/2022 4:40:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [config].[MirrorCopy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Source_Server] [nvarchar](50) NOT NULL,
	[Source_DataBase] [nvarchar](50) NOT NULL,
	[Source_Schema] [nvarchar](50) NOT NULL,
	[Source_TableName] [nvarchar](50) NOT NULL,
	[Destination_Server] [nvarchar](50) NOT NULL,
	[Destination_DataBase] [nvarchar](50) NOT NULL,
	[Destination_Schema] [nvarchar](50) NOT NULL,
	[Destination_TableName] [nvarchar](50) NOT NULL,
	[Enabled] [bit] NOT NULL,
 CONSTRAINT [PK_MirrorCopy] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [MIRROR_LN107]
GO

ALTER TABLE [config].[MirrorCopyLog] DROP CONSTRAINT [Constr_Def_DateTime]
GO

/****** Object:  Table [config].[MirrorCopyLog]    Script Date: 12/5/2022 4:40:34 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[MirrorCopyLog]') AND type in (N'U'))
DROP TABLE [config].[MirrorCopyLog]
GO

/****** Object:  Table [config].[MirrorCopyLog]    Script Date: 12/5/2022 4:40:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [config].[MirrorCopyLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionID] [uniqueidentifier] NOT NULL,
	[DateTime] [datetime2](0) NOT NULL,
	[Table] [nvarchar](100) NULL,
	[Status] [nvarchar](20) NULL,
	[Detail] [nvarchar](400) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [config].[MirrorCopyLog] ADD  CONSTRAINT [Constr_Def_DateTime]  DEFAULT (CONVERT([datetime2](0),getdate())) FOR [DateTime]
GO


