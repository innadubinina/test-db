CREATE TABLE [log].[activationService]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[paramList] [xml] NOT NULL,
[createDate] [datetime] NOT NULL CONSTRAINT [DF_logActivationService_createDate] DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [log].[activationService] ADD CONSTRAINT [PK_logActivationService] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
