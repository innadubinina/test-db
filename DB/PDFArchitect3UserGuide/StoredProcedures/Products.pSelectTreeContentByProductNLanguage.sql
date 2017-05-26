SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Products].[Product](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_Product_CreateDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Settings].[Language](
	[ID] [int] NOT NULL,
	[Name] [varchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
 CONSTRAINT [PK_Language] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Products].[Tree](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[ParentID] [int] NULL,
	[OrderNo] [int] NULL DEFAULT ((1)),
 CONSTRAINT [PK_ProductTree] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Products].[TreeContent](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductTreeID] [int] NOT NULL,
	[LanguageID] [int] NOT NULL CONSTRAINT [DF_ProductContent_LanguageID]  DEFAULT ((1)),
	[Title] [nvarchar](300) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[Text] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NOT NULL,
 CONSTRAINT [PK_ProductContent] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW Products.vTreeContent
AS
SELECT        tr.ID AS ProductTreeID, tr.ProductID, tr.ParentID, tr.OrderNo, trcon.ID AS TreeContentID, trcon.LanguageID, trcon.Title, trcon.Text
FROM            Products.Tree AS tr INNER JOIN
                         Products.TreeContent AS trcon ON trcon.ProductTreeID = tr.ID
GO
ALTER TABLE [Products].[Tree]  WITH CHECK ADD  CONSTRAINT [FK_Tree_Product] FOREIGN KEY([ProductID])
REFERENCES [Products].[Product] ([ID])
GO
ALTER TABLE [Products].[Tree] CHECK CONSTRAINT [FK_Tree_Product]
GO
ALTER TABLE [Products].[TreeContent]  WITH CHECK ADD  CONSTRAINT [FK_ProductContent_Language] FOREIGN KEY([LanguageID])
REFERENCES [Settings].[Language] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Products].[TreeContent] CHECK CONSTRAINT [FK_ProductContent_Language]
GO
ALTER TABLE [Products].[TreeContent]  WITH CHECK ADD  CONSTRAINT [FK_TreeContent_Tree] FOREIGN KEY([ProductTreeID])
REFERENCES [Products].[Tree] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Products].[TreeContent] CHECK CONSTRAINT [FK_TreeContent_Tree]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Products].[pSelectTreeContentByProductNLanguage]
      @productID  int
    , @languageID int
as
select
      ProductTreeID
    , ProductID
    , ParentID
    , OrderNo
    
    , TreeContentID
    , LanguageID
    , Title
    , Text
from Products.vTreeContent where productID = @productID and languageID = @languageID
    
/*  TEST ZONE
    --  select * from Products.vTreeContent where productID = 1 and languageID = 1
    
    exec Products.pSelectTreeContentByProductNLanguage 1, 1
*/

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                     
-- =============================================
-- Author:		Eugen K
-- Create date: 20090526
-- Description:	Check Delete logic for [Products].[Tree] table
-- =============================================
CREATE trigger [Products].[trTree_Del] 
on [Products].[Tree]
after delete
as 
BEGIN
set nocount on;

    -- Delete statements for trigger here

	delete from [Products].[Tree]
	where ParentID in (select ID from deleted) and ParentID is not null

END
GO
