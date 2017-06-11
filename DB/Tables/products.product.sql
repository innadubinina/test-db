CREATE TABLE [products].[product]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[name] [varchar] (128) COLLATE Cyrillic_General_CI_AS NOT NULL,
[title] [varchar] (128) COLLATE Cyrillic_General_CI_AS NOT NULL,
[description] [nvarchar] (256) COLLATE Cyrillic_General_CI_AS NULL,
[groupID] [int] NULL CONSTRAINT [DF_product_groupID] DEFAULT ((0)),
[disabled] [bit] NOT NULL CONSTRAINT [DF_product_disabled] DEFAULT ((0)),
[hasLifetime] [bit] NOT NULL CONSTRAINT [DF_product_hasLifetime] DEFAULT ((0)),
[externalID] [int] NULL,
[createDate] [datetime] NULL CONSTRAINT [DF_product_createDate] DEFAULT (getdate()),
[isFree] [bit] NOT NULL CONSTRAINT [DF_product_isFree] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [products].[product] ADD CONSTRAINT [PK_product] PRIMARY KEY CLUSTERED  ([id] DESC) ON [PRIMARY]
GO
ALTER TABLE [products].[product] ADD CONSTRAINT [UNIQUE_product_name] UNIQUE NONCLUSTERED  ([name]) ON [PRIMARY]
GO
ALTER TABLE [products].[product] ADD CONSTRAINT [UNIQUE_product_title] UNIQUE NONCLUSTERED  ([title]) ON [PRIMARY]
GO
ALTER TABLE [products].[product] ADD CONSTRAINT [FK_product_groupID] FOREIGN KEY ([groupID]) REFERENCES [products].[group] ([id])
GO
