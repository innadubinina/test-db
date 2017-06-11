CREATE TABLE [licenses].[activation]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[licenseID] [int] NOT NULL,
[systemID] [int] NOT NULL,
[parentID] [int] NULL,
[count] [int] NOT NULL CONSTRAINT [DF_licensesActivation_count] DEFAULT ((0)),
[endDate] [datetime] NULL,
[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesActivation_createDate] DEFAULT (getdate()),
[modifyDate] [datetime] NULL,
[history] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [licenses].[activation] ADD CONSTRAINT [PK_licensesActivation] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_createDate] ON [licenses].[activation] ([createDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_licenseID] ON [licenses].[activation] ([licenseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_modifyDate] ON [licenses].[activation] ([modifyDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_parentID] ON [licenses].[activation] ([parentID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_systemID] ON [licenses].[activation] ([systemID]) ON [PRIMARY]
GO
ALTER TABLE [licenses].[activation] ADD CONSTRAINT [FK_licensesActivation_licenseID] FOREIGN KEY ([licenseID]) REFERENCES [licenses].[license] ([id])
GO
ALTER TABLE [licenses].[activation] ADD CONSTRAINT [FK_licensesActivation_parentID] FOREIGN KEY ([parentID]) REFERENCES [licenses].[activation] ([id])
GO
ALTER TABLE [licenses].[activation] ADD CONSTRAINT [FK_licensesActivation_systemID] FOREIGN KEY ([systemID]) REFERENCES [clients].[system] ([id])
GO
