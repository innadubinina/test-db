CREATE TABLE [licenses].[group]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[userID] [int] NOT NULL,
[productID] [int] NOT NULL,
[licenseCount] [int] NOT NULL CONSTRAINT [DF_licensesGroup_LicenseCount] DEFAULT ((10)),
[allowedActivationCount] [int] NOT NULL,
[lifeTimeDays] [int] NULL,
[serverActivationCount] [int] NULL,
[resellerName] [nvarchar] (128) COLLATE Cyrillic_General_CI_AS NULL,
[readyForActivation] [bit] NOT NULL CONSTRAINT [DF_licensesGroup_readyForActivation] DEFAULT ((0)),
[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesGroup_createDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [licenses].[group] ADD CONSTRAINT [PK_licensesGroup] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Licensesgroup_productID] ON [licenses].[group] ([productID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Licensesgroup_userID] ON [licenses].[group] ([userID]) ON [PRIMARY]
GO
ALTER TABLE [licenses].[group] ADD CONSTRAINT [FK_licensesGroup_productID] FOREIGN KEY ([productID]) REFERENCES [products].[product] ([id])
GO
ALTER TABLE [licenses].[group] ADD CONSTRAINT [FK_licensesGroup_userID] FOREIGN KEY ([userID]) REFERENCES [security].[users] ([Id])
GO
