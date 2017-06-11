CREATE TABLE [log].[error]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[text] [nvarchar] (4000) COLLATE Cyrillic_General_CI_AS NULL,
[spid] [int] NULL CONSTRAINT [DF_logError_spid] DEFAULT (@@spid),
[user] [sys].[sysname] NULL CONSTRAINT [DF_logError_user] DEFAULT (suser_sname()),
[number] [int] NULL,
[message] [nvarchar] (max) COLLATE Cyrillic_General_CI_AS NULL,
[createDate] [datetime] NULL CONSTRAINT [DF_logError_createDate] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [log].[error] ADD CONSTRAINT [PK_logError] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
