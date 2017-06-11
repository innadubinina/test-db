CREATE TABLE [clients].[clientLicense]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[clientID] [int] NOT NULL,
[licenseID] [int] NOT NULL,
[optIn] [bit] NULL,
[createDate] [datetime] NOT NULL CONSTRAINT [DF_clientLicense_createDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [clients].[clientLicense] ADD CONSTRAINT [PK_clientLicense] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LicenseID] ON [clients].[clientLicense] ([licenseID]) ON [PRIMARY]
GO
ALTER TABLE [clients].[clientLicense] ADD CONSTRAINT [FK_clientLicense_clientID] FOREIGN KEY ([clientID]) REFERENCES [clients].[client] ([id])
GO
ALTER TABLE [clients].[clientLicense] ADD CONSTRAINT [FK_clientLicense_licenseID] FOREIGN KEY ([licenseID]) REFERENCES [licenses].[license] ([id])
GO
