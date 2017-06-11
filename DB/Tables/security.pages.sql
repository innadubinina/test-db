CREATE TABLE [security].[pages]
(
[Id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[Name] [nvarchar] (50) COLLATE Cyrillic_General_CI_AS NOT NULL,
[NavigateUrl] [nvarchar] (max) COLLATE Cyrillic_General_CI_AS NOT NULL,
[Order] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [security].[pages] ADD CONSTRAINT [PK_Pages] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_Name_Pages] ON [security].[pages] ([Name]) ON [PRIMARY]
GO
