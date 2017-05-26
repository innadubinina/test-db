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
