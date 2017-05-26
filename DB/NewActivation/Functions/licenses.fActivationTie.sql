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
CREATE TABLE [clients].[system](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_clientsSystem_UID]  DEFAULT (newid()),
	[machineKey] [uniqueidentifier] NOT NULL,
	[motherboardKey] [varchar](128) COLLATE Cyrillic_General_CI_AS NULL,
	[physicalMAC] [varchar](128) COLLATE Cyrillic_General_CI_AS NULL,
	[clientID] [int] NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesActivation_createDate]  DEFAULT (getdate()),
	[isAutogeneratedMachineKey] [bit] NOT NULL DEFAULT ((0)),
 CONSTRAINT [PK_clientsSystem] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [licenses].[activation](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[licenseID] [int] NOT NULL,
	[systemID] [int] NOT NULL,
	[parentID] [int] NULL,
	[count] [int] NOT NULL CONSTRAINT [DF_licensesActivation_count]  DEFAULT ((0)),
	[endDate] [datetime] NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesActivation_createDate]  DEFAULT (getdate()),
	[modifyDate] [datetime] NULL,
	[history] [xml] NULL,
 CONSTRAINT [PK_licensesActivation] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION licenses.fActivationTie (@activationID int)
RETURNS TABLE
AS RETURN
(
 with cteChildTie (ID, parentID, level) as (
    select ID, parentID, 0 as level
    from licenses.activation
    where ID  = @activationID
    
    union all
    select act.ID, act.parentID, child.level + 1 as level
    from licenses.activation act
        join cteChildTie child on child.parentID = act.ID
    ),
  cteParentTie (ID, parentID, level) as (
    select ID, parentID, 0 as level
    from licenses.activation
    where ID  = @activationID
    
    union all
    select act.ID, act.parentID, parent.level - 1 as level
    from licenses.activation act
        join cteParentTie parent on parent.ID = act.parentID
    )
select ID, parentID, level from cteChildTie
union
select ID, parentID, level from cteParentTie
)

GO
CREATE NONCLUSTERED INDEX [IX_licenseslicense_groupID] ON [licenses].[license]
(
	[groupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [clientsSystem_machineKey] ON [clients].[system]
(
	[machineKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_clientsSystem_clientID] ON [clients].[system]
(
	[clientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE UNIQUE NONCLUSTERED INDEX [UNIQ_clientsSystem_systemKeys] ON [clients].[system]
(
	[physicalMAC] ASC,
	[machineKey] ASC,
	[motherboardKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_createDate] ON [licenses].[activation]
(
	[createDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_licenseID] ON [licenses].[activation]
(
	[licenseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_modifyDate] ON [licenses].[activation]
(
	[modifyDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_parentID] ON [licenses].[activation]
(
	[parentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_systemID] ON [licenses].[activation]
(
	[systemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [clients].[system]  WITH CHECK ADD  CONSTRAINT [FK_clientsSystem_clientID] FOREIGN KEY([clientID])
REFERENCES [clients].[client] ([id])
GO
ALTER TABLE [clients].[system] CHECK CONSTRAINT [FK_clientsSystem_clientID]
GO
ALTER TABLE [licenses].[activation]  WITH CHECK ADD  CONSTRAINT [FK_licensesActivation_licenseID] FOREIGN KEY([licenseID])
REFERENCES [licenses].[license] ([id])
GO
ALTER TABLE [licenses].[activation] CHECK CONSTRAINT [FK_licensesActivation_licenseID]
GO
ALTER TABLE [licenses].[activation]  WITH CHECK ADD  CONSTRAINT [FK_licensesActivation_parentID] FOREIGN KEY([parentID])
REFERENCES [licenses].[activation] ([id])
GO
ALTER TABLE [licenses].[activation] CHECK CONSTRAINT [FK_licensesActivation_parentID]
GO
ALTER TABLE [licenses].[activation]  WITH CHECK ADD  CONSTRAINT [FK_licensesActivation_systemID] FOREIGN KEY([systemID])
REFERENCES [clients].[system] ([id])
GO
ALTER TABLE [licenses].[activation] CHECK CONSTRAINT [FK_licensesActivation_systemID]
GO
