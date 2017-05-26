SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clients].[session](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_clientsSession_UID]  DEFAULT (newid()),
	[IPAddress] [varchar](64) COLLATE Cyrillic_General_CI_AS NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_clientsSession_createDate]  DEFAULT (getdate()),
	[keyID] [int] NULL,
 CONSTRAINT [PK_clientsSessions] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_clientsSession_UID] UNIQUE NONCLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clients].[keyType](
	[id] [tinyint] IDENTITY(0,1) NOT NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_ClientsKeyType_CreateDate]  DEFAULT (getdate()),
	[name] [sysname] COLLATE Cyrillic_General_CI_AS NOT NULL,
 CONSTRAINT [PK_ClientsKeyType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_ClientsKeyType_Name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clients].[key](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[private] [varbinary](639) NOT NULL,
	[public] [varbinary](164) NOT NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_clientsKey_GetDate]  DEFAULT (getdate()),
	[typeID] [tinyint] NOT NULL CONSTRAINT [DF_clientsKey_TypeID]  DEFAULT ((1)),
 CONSTRAINT [PK_clientsKey] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_clientsKey_Private] UNIQUE NONCLUSTERED 
(
	[private] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_clientsKey_Public] UNIQUE NONCLUSTERED 
(
	[public] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [clients].[fGetSessionByUID] (@UID uniqueidentifier)
returns table with schemabinding
as return
(
    select top 1
          base.[id]
        , [key].[private] as privateKey
        , [key].[typeID]  as keyTypeID
                    
        , base.[IPAddress]
        , base.[createDate]
    from clients.[session] base
        join clients.[key] [key] on [key].[id] = base.keyID
    where base.[uid] = @uid

/*  TEST ZONE
    -- select top 100 * from clients.session
    select * from [clients].[fGetSessionByUID] ('65A4AC3D-A045-434D-AA68-DAAFB0373586')
*/
)

GO
CREATE NONCLUSTERED INDEX [IX_clientSession_CreateDate] ON [clients].[session]
(
	[createDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licenseslicense_groupID] ON [clients].[session]
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [clients].[key]  WITH CHECK ADD  CONSTRAINT [FK_clientsKey_TypeID] FOREIGN KEY([typeID])
REFERENCES [clients].[keyType] ([id])
GO
ALTER TABLE [clients].[key] CHECK CONSTRAINT [FK_clientsKey_TypeID]
GO
