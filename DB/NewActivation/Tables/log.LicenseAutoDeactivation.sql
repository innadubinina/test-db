SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[LicenseAutoDeactivation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GlobalOrderID] [varchar](21) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[TransactionType] [varchar](20) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[TransactionDate] [datetime] NOT NULL,
	[LicenseKey] [nvarchar](200) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_logLicenseAutoDeactivation] PRIMARY KEY CLUSTERED 
(
	[ID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [log].[LicenseAutoDeactivation] ADD  CONSTRAINT [DF_LicenseAutoDeactivation_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
