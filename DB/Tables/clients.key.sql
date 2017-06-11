CREATE TABLE [clients].[key]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[private] [varbinary] (639) NOT NULL,
[public] [varbinary] (164) NOT NULL,
[createDate] [datetime] NOT NULL CONSTRAINT [DF_clientsKey_GetDate] DEFAULT (getdate()),
[typeID] [tinyint] NOT NULL CONSTRAINT [DF_clientsKey_TypeID] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [clients].[key] ADD CONSTRAINT [PK_clientsKey] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [clients].[key] ADD CONSTRAINT [UNIQ_clientsKey_Private] UNIQUE NONCLUSTERED  ([private]) ON [PRIMARY]
GO
ALTER TABLE [clients].[key] ADD CONSTRAINT [UNIQ_clientsKey_Public] UNIQUE NONCLUSTERED  ([public]) ON [PRIMARY]
GO
ALTER TABLE [clients].[key] ADD CONSTRAINT [FK_clientsKey_TypeID] FOREIGN KEY ([typeID]) REFERENCES [clients].[keyType] ([id])
GO
