SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[log](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[stackTrace] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
	[message] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
	[source] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
	[createDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [log].[log] ADD  CONSTRAINT [DF_Log_CreateDate]  DEFAULT (getdate()) FOR [createDate]
GO