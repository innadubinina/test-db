CREATE TABLE [clients].[preClientWaitForLicense]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[productName] [nvarchar] (128) COLLATE Cyrillic_General_CI_AS NOT NULL,
[email] [nvarchar] (128) COLLATE Cyrillic_General_CI_AS NOT NULL,
[firstName] [nvarchar] (100) COLLATE Cyrillic_General_CI_AS NULL,
[lastName] [nvarchar] (100) COLLATE Cyrillic_General_CI_AS NULL,
[isValidEmail] [bit] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_isValidEmail] DEFAULT ((1)),
[createDate] [datetime] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_createDate] DEFAULT (getdate()),
[ipAddress] [varchar] (330) COLLATE Cyrillic_General_CI_AS NULL,
[languageISO2] [char] (2) COLLATE Cyrillic_General_CI_AS NULL,
[deleted] [bit] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_deleted] DEFAULT ((0)),
[readyToSend] [bit] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_readyToSend] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [clients].[preClientWaitForLicense] ADD CONSTRAINT [PK_PreClientWaitForLicense] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
ALTER TABLE [clients].[preClientWaitForLicense] ADD CONSTRAINT [UNIQ_clients_PreClientWaitForLicense] UNIQUE NONCLUSTERED  ([productName], [email]) ON [PRIMARY]
GO
