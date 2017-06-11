CREATE TABLE [security].[users]
(
[Id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[Name] [nvarchar] (50) COLLATE Cyrillic_General_CI_AS NOT NULL,
[Password] [nvarchar] (50) COLLATE Cyrillic_General_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_Users_CreateDate] DEFAULT (getdate()),
[IsActive] [bit] NOT NULL CONSTRAINT [DF_Users_IsActive] DEFAULT ((1)),
[IsAdmin] [bit] NOT NULL CONSTRAINT [DF_Users_IsAdmin] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [security].[users] ADD CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_Name_Users] ON [security].[users] ([Name], [IsActive]) ON [PRIMARY]
GO
