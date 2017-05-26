SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clients].[client](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_client_UID]  DEFAULT (newid()),
	[email] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[firstName] [nvarchar](100) COLLATE Cyrillic_General_CI_AS NULL,
	[lastName] [nvarchar](100) COLLATE Cyrillic_General_CI_AS NULL,
	[isValidEmail] [bit] NOT NULL CONSTRAINT [DF_client_isValidEmail]  DEFAULT ((1)),
	[optIn] [bit] NOT NULL CONSTRAINT [DF_client_optIn]  DEFAULT ((1)),
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_client_createDate]  DEFAULT (getdate()),
	[history] [xml] NULL,
	[ipAddress] [varchar](330) COLLATE Cyrillic_General_CI_AS NULL,
	[languageISO2] [char](2) COLLATE Cyrillic_General_CI_AS NULL,
 CONSTRAINT [PK_client] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_client_email] UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [licenses].[license](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[groupID] [int] NOT NULL,
	[key] [varchar](64) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[readyForActivation] [bit] NOT NULL CONSTRAINT [DF_licensesLicense_readyForActivation]  DEFAULT ((0)),
	[deactivated] [bit] NOT NULL CONSTRAINT [DF_licensesLicense_deactivated]  DEFAULT ((0)),
	[allowedActivationCount] [int] NULL,
	[lifeTimeDays] [int] NULL,
	[serverActivationCount] [int] NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesLicense_createDate]  DEFAULT (getdate()),
	[modifyDate] [datetime] NULL,
	[history] [xml] NULL,
 CONSTRAINT [PK_licenses] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_licensesLicense_license] UNIQUE NONCLUSTERED 
(
	[key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clients].[clientLicense](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[clientID] [int] NOT NULL,
	[licenseID] [int] NOT NULL,
	[optIn] [bit] NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_clientLicense_createDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_clientLicense] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view clients.vClientLicense 
as
select base.id
     , base.clientID
     , base.licenseID
     , coalesce(base.optIn, cl.optIn) [optIn]
     , base.createDate
from clients.clientLicense base
	join clients.client cl on cl.id = base.clientID
GO
CREATE NONCLUSTERED INDEX [IX_licenseslicense_groupID] ON [licenses].[license]
(
	[groupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LicenseID] ON [clients].[clientLicense]
(
	[licenseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [clients].[clientLicense]  WITH CHECK ADD  CONSTRAINT [FK_clientLicense_clientID] FOREIGN KEY([clientID])
REFERENCES [clients].[client] ([id])
GO
ALTER TABLE [clients].[clientLicense] CHECK CONSTRAINT [FK_clientLicense_clientID]
GO
ALTER TABLE [clients].[clientLicense]  WITH CHECK ADD  CONSTRAINT [FK_clientLicense_licenseID] FOREIGN KEY([licenseID])
REFERENCES [licenses].[license] ([id])
GO
ALTER TABLE [clients].[clientLicense] CHECK CONSTRAINT [FK_clientLicense_licenseID]
GO
