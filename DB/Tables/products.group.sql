CREATE TABLE [products].[group]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[name] [varchar] (50) COLLATE Cyrillic_General_CI_AS NOT NULL,
[description] [nvarchar] (256) COLLATE Cyrillic_General_CI_AS NULL,
[externalID] [int] NULL,
[createDate] [datetime] NULL CONSTRAINT [DF_productsGroup_createDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [products].[group] ADD CONSTRAINT [PK_productsGroup] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
ALTER TABLE [products].[group] ADD CONSTRAINT [UNIQUE_productsGroup_name] UNIQUE NONCLUSTERED  ([name]) ON [PRIMARY]
GO
