CREATE TABLE [licenses].[license]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[groupID] [int] NOT NULL,
[key] [varchar] (64) COLLATE Cyrillic_General_CI_AS NOT NULL,
[readyForActivation] [bit] NOT NULL CONSTRAINT [DF_licensesLicense_readyForActivation] DEFAULT ((0)),
[deactivated] [bit] NOT NULL CONSTRAINT [DF_licensesLicense_deactivated] DEFAULT ((0)),
[allowedActivationCount] [int] NULL,
[lifeTimeDays] [int] NULL,
[serverActivationCount] [int] NULL,
[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesLicense_createDate] DEFAULT (getdate()),
[modifyDate] [datetime] NULL,
[history] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [licenses].[license] ADD CONSTRAINT [PK_licenses] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licenseslicense_groupID] ON [licenses].[license] ([groupID]) ON [PRIMARY]
GO
ALTER TABLE [licenses].[license] ADD CONSTRAINT [UNIQ_licensesLicense_license] UNIQUE NONCLUSTERED  ([key]) ON [PRIMARY]
GO
