CREATE TABLE [clients].[keyType]
(
[id] [tinyint] NOT NULL IDENTITY(0, 1),
[createDate] [datetime] NULL CONSTRAINT [DF_ClientsKeyType_CreateDate] DEFAULT (getdate()),
[name] [sys].[sysname] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [clients].[keyType] ADD CONSTRAINT [PK_ClientsKeyType] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [clients].[keyType] ADD CONSTRAINT [UNIQ_ClientsKeyType_Name] UNIQUE NONCLUSTERED  ([name]) ON [PRIMARY]
GO
