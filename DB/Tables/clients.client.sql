CREATE TABLE [clients].[client]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[UID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_client_UID] DEFAULT (newid()),
[email] [nvarchar] (128) COLLATE Cyrillic_General_CI_AS NOT NULL,
[firstName] [nvarchar] (100) COLLATE Cyrillic_General_CI_AS NULL,
[lastName] [nvarchar] (100) COLLATE Cyrillic_General_CI_AS NULL,
[isValidEmail] [bit] NOT NULL CONSTRAINT [DF_client_isValidEmail] DEFAULT ((1)),
[optIn] [bit] NOT NULL CONSTRAINT [DF_client_optIn] DEFAULT ((1)),
[createDate] [datetime] NOT NULL CONSTRAINT [DF_client_createDate] DEFAULT (getdate()),
[history] [xml] NULL,
[ipAddress] [varchar] (330) COLLATE Cyrillic_General_CI_AS NULL,
[languageISO2] [char] (2) COLLATE Cyrillic_General_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [clients].[client] ADD CONSTRAINT [PK_client] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
ALTER TABLE [clients].[client] ADD CONSTRAINT [UNIQ_client_email] UNIQUE NONCLUSTERED  ([email]) ON [PRIMARY]
GO
