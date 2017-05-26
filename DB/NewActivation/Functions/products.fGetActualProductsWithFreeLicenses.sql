SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [products].[group](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[name] [varchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[description] [nvarchar](256) COLLATE Cyrillic_General_CI_AS NULL,
	[externalID] [int] NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_productsGroup_createDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_productsGroup] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_productsGroup_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [products].[product](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[name] [varchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[title] [varchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[description] [nvarchar](256) COLLATE Cyrillic_General_CI_AS NULL,
	[groupID] [int] NULL CONSTRAINT [DF_product_groupID]  DEFAULT ((0)),
	[disabled] [bit] NOT NULL CONSTRAINT [DF_product_disabled]  DEFAULT ((0)),
	[hasLifetime] [bit] NOT NULL CONSTRAINT [DF_product_hasLifetime]  DEFAULT ((0)),
	[externalID] [int] NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_product_createDate]  DEFAULT (getdate()),
	[isFree] [bit] NOT NULL CONSTRAINT [DF_product_isFree]  DEFAULT ((0)),
 CONSTRAINT [PK_product] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_product_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_product_title] UNIQUE NONCLUSTERED 
(
	[title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [products].[fGetActualProductsWithFreeLicenses] ()
returns table with schemabinding
as return
(
    --  logic before 20130920
    --  ---------------------
    --  select [id], [name], [title], [description], [groupID], [disabled], [hasLifetime], [externalID], [createDate]
    --  from products.product
    --  where name='soda pdf 3d reader mac'

    --  // logic before 20130920
    select [id], [name], [title], [description], [groupID], [disabled], [hasLifetime], [externalID], [isFree], [createDate]
    from products.product
    where [isFree] = 1
    

/*  TEST ZONE
    select * from [products].[fGetActualProductsWithFreeLicenses] ()
*/
)

GO
ALTER TABLE [products].[product]  WITH CHECK ADD  CONSTRAINT [FK_product_groupID] FOREIGN KEY([groupID])
REFERENCES [products].[group] ([id])
GO
ALTER TABLE [products].[product] CHECK CONSTRAINT [FK_product_groupID]
GO
