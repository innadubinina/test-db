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
CREATE NONCLUSTERED INDEX [IX_licenseslicense_groupID] ON [licenses].[license]
(
	[groupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
