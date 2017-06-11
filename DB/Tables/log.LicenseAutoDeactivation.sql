CREATE TABLE [log].[LicenseAutoDeactivation]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[GlobalOrderID] [varchar] (21) COLLATE Cyrillic_General_CI_AS NOT NULL,
[TransactionType] [varchar] (20) COLLATE Cyrillic_General_CI_AS NOT NULL,
[TransactionDate] [datetime] NOT NULL,
[LicenseKey] [nvarchar] (200) COLLATE Cyrillic_General_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_LicenseAutoDeactivation_CreateDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [log].[LicenseAutoDeactivation] ADD CONSTRAINT [PK_logLicenseAutoDeactivation] PRIMARY KEY CLUSTERED  ([ID] DESC) ON [PRIMARY]
GO
