CREATE TABLE [clients].[session]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[UID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_clientsSession_UID] DEFAULT (newid()),
[IPAddress] [varchar] (64) COLLATE Cyrillic_General_CI_AS NULL,
[createDate] [datetime] NULL CONSTRAINT [DF_clientsSession_createDate] DEFAULT (getdate()),
[keyID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [clients].[session] ADD CONSTRAINT [PK_clientsSessions] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_clientSession_CreateDate] ON [clients].[session] ([createDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licenseslicense_groupID] ON [clients].[session] ([UID]) ON [PRIMARY]
GO
ALTER TABLE [clients].[session] ADD CONSTRAINT [UNIQ_clientsSession_UID] UNIQUE NONCLUSTERED  ([UID]) ON [PRIMARY]
GO
