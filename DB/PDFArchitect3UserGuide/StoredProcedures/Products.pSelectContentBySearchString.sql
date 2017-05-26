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
--  ==================================================================
--  Create: Eugen Kirichenko (20090526)
--  Modify: 
--  Description: Select Product tree Content By Search String
--  ==================================================================
CREATE PROCEDURE [Products].[pSelectContentBySearchString]
(
    @LanguageID		int				= null,
    @SearchText  nvarchar(300)		= null,
	@SearchTitle	nvarchar(300)   = null
)
as
begin

SET NOCOUNT ON;


declare @intResult int;     set @intResult = -1;            --  routine fail status;

begin try

	SELECT [ID]
		  ,[ProductTreeID]
		  ,[LanguageID]
		  ,[Title]
		  ,[Text]
	  FROM [Products].[TreeContent]
	where 
    ([LanguageID]	= @LanguageID				or @LanguageID		is null) and
	(([Title]	like '%' + @SearchTitle + '%'	or @SearchTitle		is null) or
	([Text]		like '%' + @SearchText + '%'	or @SearchText		is null) )
	--and [Text] is not null


    set @intResult = 0  --  routine success status


end try
begin catch

		  --/========================LOG ERR=============================\
		   declare @errNumb int, @errMsg varchar(max)
		   select @errNumb = error_number(), @errMsg = error_message()
		   --exec [log].[WriteToLogErr] @errNumb, @errMsg, @@SPID    

           set @intResult = case 
                              when @errNumb > 0 then (-1)*@errNumb 
                              when @errNumb = 0 then -1 
                              else @errNumb 
                            end
		  --\============================================================/
          
end catch


RETURN @intResult

SET NOCOUNT OFF;
end

/*
	TEST ZONE

	[Trees].[pSelectContentBySearchString]

    exec [Products].[pSelectContentBySearchString] 1,'Zooming','Zooming'

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
