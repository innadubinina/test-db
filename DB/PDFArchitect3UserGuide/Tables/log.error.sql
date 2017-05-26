SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[error](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[text] [nvarchar](4000) COLLATE Cyrillic_General_CI_AS NULL,
	[spid] [int] NOT NULL,
	[user] [sysname] COLLATE Cyrillic_General_CI_AS NOT NULL,
	[createDate] [datetime] NOT NULL,
	[number] [int] NULL,
	[message] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
 CONSTRAINT [PK_logError] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [log].[error] ADD  CONSTRAINT [DF_logError_spid]  DEFAULT (@@spid) FOR [spid]
GO
ALTER TABLE [log].[error] ADD  CONSTRAINT [DF_logError_user]  DEFAULT (suser_sname()) FOR [user]
GO
ALTER TABLE [log].[error] ADD  CONSTRAINT [DF_logError_createDate]  DEFAULT (getdate()) FOR [createDate]
GO
