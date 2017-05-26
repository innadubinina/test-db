SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clients].[preClientWaitForLicense](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[productName] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[email] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[firstName] [nvarchar](100) COLLATE Cyrillic_General_CI_AS NULL,
	[lastName] [nvarchar](100) COLLATE Cyrillic_General_CI_AS NULL,
	[isValidEmail] [bit] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_isValidEmail]  DEFAULT ((1)),
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_createDate]  DEFAULT (getdate()),
	[ipAddress] [varchar](330) COLLATE Cyrillic_General_CI_AS NULL,
	[languageISO2] [char](2) COLLATE Cyrillic_General_CI_AS NULL,
	[deleted] [bit] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_deleted]  DEFAULT ((0)),
	[readyToSend] [bit] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_readyToSend]  DEFAULT ((0)),
 CONSTRAINT [PK_PreClientWaitForLicense] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_clients_PreClientWaitForLicense] UNIQUE NONCLUSTERED 
(
	[productName] ASC,
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [clients].[vPreClientWaitForLicenseStatistic]
with schemabinding
as
    select productName
        , sum (case when [readyToSend] = 0 then 1 else 0 end) as nonMarkedValue
        , sum (case when [readyToSend] = 1 then 1 else 0 end) as markedValue
    from [clients].[preClientWaitForLicense] where [deleted] = 0
    group by productName

--select
--      (select COUNT(*) as nonMarkedValue from [clients].[preClientWaitForLicense] where [deleted] = 0 and [readyToSend] = 0) as nonMarkedValue
--    , (select COUNT(*) from [clients].[preClientWaitForLicense] where [deleted] = 0 and [readyToSend] = 1) as markedValue

/*  TEST ZONE
    select * from [clients].[vPreClientWaitForLicenseStatistic]
*/

GO
