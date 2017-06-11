CREATE TABLE [log].[log]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[stackTrace] [nvarchar] (max) COLLATE Cyrillic_General_CI_AS NULL,
[message] [nvarchar] (max) COLLATE Cyrillic_General_CI_AS NULL,
[source] [nvarchar] (max) COLLATE Cyrillic_General_CI_AS NULL,
[createDate] [datetime] NOT NULL CONSTRAINT [DF_Log_CreateDate] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [log].[log] ADD CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
