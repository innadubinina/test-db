SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [products].[group](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[name] [varchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[description] [nvarchar](256) COLLATE Cyrillic_General_CI_AS NULL,
	[externalID] [int] NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_productsGroup_createDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_productsGroup] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_productsGroup_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [security].[users](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Name] [nvarchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[Password] [nvarchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_Users_CreateDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_Users_IsActive]  DEFAULT ((1)),
	[IsAdmin] [bit] NOT NULL CONSTRAINT [DF_Users_IsAdmin]  DEFAULT ((0)),
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [products].[product](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[name] [varchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[title] [varchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[description] [nvarchar](256) COLLATE Cyrillic_General_CI_AS NULL,
	[groupID] [int] NULL CONSTRAINT [DF_product_groupID]  DEFAULT ((0)),
	[disabled] [bit] NOT NULL CONSTRAINT [DF_product_disabled]  DEFAULT ((0)),
	[hasLifetime] [bit] NOT NULL CONSTRAINT [DF_product_hasLifetime]  DEFAULT ((0)),
	[externalID] [int] NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_product_createDate]  DEFAULT (getdate()),
	[isFree] [bit] NOT NULL CONSTRAINT [DF_product_isFree]  DEFAULT ((0)),
 CONSTRAINT [PK_product] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_product_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_product_title] UNIQUE NONCLUSTERED 
(
	[title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [licenses].[group](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[userID] [int] NOT NULL,
	[productID] [int] NOT NULL,
	[licenseCount] [int] NOT NULL CONSTRAINT [DF_licensesGroup_LicenseCount]  DEFAULT ((10)),
	[allowedActivationCount] [int] NOT NULL,
	[lifeTimeDays] [int] NULL,
	[serverActivationCount] [int] NULL,
	[resellerName] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NULL,
	[readyForActivation] [bit] NOT NULL CONSTRAINT [DF_licensesGroup_readyForActivation]  DEFAULT ((0)),
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesGroup_createDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_licensesGroup] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_Name_Users] ON [security].[users]
(
	[Name] ASC,
	[IsActive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Licensesgroup_productID] ON [licenses].[group]
(
	[productID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Licensesgroup_userID] ON [licenses].[group]
(
	[userID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [products].[product]  WITH CHECK ADD  CONSTRAINT [FK_product_groupID] FOREIGN KEY([groupID])
REFERENCES [products].[group] ([id])
GO
ALTER TABLE [products].[product] CHECK CONSTRAINT [FK_product_groupID]
GO
ALTER TABLE [licenses].[group]  WITH CHECK ADD  CONSTRAINT [FK_licensesGroup_productID] FOREIGN KEY([productID])
REFERENCES [products].[product] ([id])
GO
ALTER TABLE [licenses].[group] CHECK CONSTRAINT [FK_licensesGroup_productID]
GO
ALTER TABLE [licenses].[group]  WITH CHECK ADD  CONSTRAINT [FK_licensesGroup_userID] FOREIGN KEY([userID])
REFERENCES [security].[users] ([Id])
GO
ALTER TABLE [licenses].[group] CHECK CONSTRAINT [FK_licensesGroup_userID]
GO
