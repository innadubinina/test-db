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
ALTER TABLE [Products].[Tree]  WITH CHECK ADD  CONSTRAINT [FK_Tree_Product] FOREIGN KEY([ProductID])
REFERENCES [Products].[Product] ([ID])
GO
ALTER TABLE [Products].[Tree] CHECK CONSTRAINT [FK_Tree_Product]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Products].[pTree]
@Action INT=8, @ID INT=null OUTPUT, @ProductID INT=null, @ParentID INT=null, @OrderNo INT=null
AS
begin

SET NOCOUNT ON;


declare @intResult int;     set @intResult = -1;            --  routine fail status;

begin try

     --  DELETE
     if @action = 2
	 begin
		delete from  [Products].[Tree]
		where [ID] = @id
	 end

    --  UPDATE
    if @action = 4
    begin 
		UPDATE [Products].[Tree]
		   SET [ParentID]			= isnull(@ParentID,[ParentID])
		       ,[ProductID]			= isnull(@ProductID,[ProductID])
			   ,[OrderNo]			= isnull(@OrderNo,[OrderNo])
		 WHERE [ID] = @id
	
		if @@rowcount = 0 
		begin
			set @intResult = -1
			raiserror ('Update [Products].[Tree] error', 16, 1);
		end
    end
     --  INSERT
    if @action = 1 
	begin
		 DECLARE @MaxOrder int;
		 SELECT @MaxOrder = MAX(T.OrderNo)
		 FROM [Products].[Tree] T
		 WHERE (T.[ProductID] = @ProductID) AND
		       (T.[ParentID]  = @ParentID)

		SET @MaxOrder = @MaxOrder + 1;

		 INSERT INTO [Products].[Tree]
			   ([ParentID],
				[ProductID],
				[OrderNo])
		 VALUES
			   (@ParentID,
				@ProductID,
				@MaxOrder)

		select @ID = scope_identity()

		if @ID is null  
		begin
			set @intResult = -1
			raiserror ('Insert [Products].[Tree] error', 16, 1);
		end
	end

    --  SELECT
    if @action = 8
	begin
		SELECT [ID]
		  ,[ParentID]
          ,[ProductID]
		  ,[OrderNo]
		FROM [Products].[Tree]
		where 
		([ID]				= @ID				or @ID       is null) and
		([ParentID]			= @ParentID			or @ParentID is null) and
		([ProductID]		= @ProductID		or @ProductID is null)and
		([OrderNo]			= @OrderNo			or @OrderNo   is null)
	end

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
