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
CREATE PROCEDURE [Products].[pTree_Move]
@ID INT, @productID INT, @parentID INT, @predecessorNodeID INT, @orderNo INT=null OUTPUT
AS
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errNumb int, @errMsg varchar(max)

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //
declare @oldProductID int, @oldParentID int;
declare @tblReorderedLeaf  table (id int, orderNo int identity(1, 1))
declare @tblReorderedLeaf2 table (id int, orderNo int identity(1, 1))

begin try
    if (@trancount = 0) BEGIN TRAN

    if ((select productID from Products.Tree where ID = @ID) != @productID)
    begin
        set @errMsg = 'SP parameter @productID is not valid: you try to move product to another product'
        raiserror (@errMsg , 16, 1)
    end


    if (@parentID is not null) 
        and not exists (select ID from Products.Tree where productID = @productID and id = @parentID)
    begin
        set @errMsg = 'SP parameter @parentID has not valid node ID'
        raiserror (@errMsg , 16, 1)
    end

    set @oldParentID = (select parentID from Products.Tree where ID = @id);

    -- first node by given parent: @orderNo = 1; @predecessorNodeID = null
    if (@predecessorNodeID is null)
    begin
        set @orderNo = 1;

        --  fill new orderNo for all leaf of parent node
        insert @tblReorderedLeaf (id)
        select @ID;

        insert @tblReorderedLeaf (id)
        select ID from Products.Tree
        where productID = @productID and parentID = @parentID
			and id != @ID
        order by orderNo;

    end
    else
    if (@predecessorNodeID is not null)
    begin
        --  predecessor node has another parent
        if ((select parentID from Products.Tree where id = @predecessorNodeID) != @parentID)
        begin
            set @errMsg = 'Predecessor node has another parent than @parentID parameter'
            raiserror (@errMsg , 16, 1)
        end

        --  predecessor orderNo + 1                
        set @orderNo = ( (select orderNo from Products.Tree where ID = @predecessorNodeID) + 1 );


        --  fill new orderNo for all leaf of parent node
        insert @tblReorderedLeaf (id)
        select ID from Products.Tree
        where productID = @productID and parentID = @parentID
            and orderNo < @orderNo
        order by orderNo;

        insert @tblReorderedLeaf (id)
        select @ID;

        insert @tblReorderedLeaf (id)
        select ID from Products.Tree
        where productID = @productID and parentID = @parentID
            and orderNo >= @orderNo
            and id != @ID
        order by orderNo;
    end

    -- update current node
    update Products.Tree
    set parentID = @parentID, orderNo = @orderNo
    where id = @id;

    -- update leaf of new parent
    update tbl
    set tbl.orderNo = tmp.orderNo
    from Products.Tree tbl
        join @tblReorderedLeaf tmp on tmp.id = tbl.id;


    -- update leaf of old parent
    if @parentID != @oldParentID
    begin
        insert @tblReorderedLeaf2
        select ID from Products.Tree
        where productID = @productID and parentID = @oldParentID
        order by orderNo;

        update tbl
        set tbl.orderNo = tmp.orderNo
        from Products.Tree tbl
            join @tblReorderedLeaf2 tmp on tmp.id = tbl.id;
    end


    if @trancount = 0 and @@trancount > 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 and @@trancount > 0 ROLLBACK TRANSACTION

    --/========================LOG ERR=============================\
    select @errNumb = error_number(), @errMsg = error_message()
    -- exec [Log].[pError] @action = 1, @number = @errNumb, @message = @errMsg
    print @errMsg;
    set @intResult = case 
        when @errNumb > 0 then (-1)*@errNumb 
        when @errNumb = 0 then -1 
        else @errNumb 
        end
    -- raiserror (@errMsg , 16, 1);
    --\============================================================/
          
end catch

return @intResult;


/*  TEST ZONE
    --  select * from Products.Tree order by productID, parentID, orderNo
    --  exec log.pError

    -- no changes
    declare @intResult int, @intOrderNo int;
    exec @intResult = [Products].[pTree_Move] @ID = 54, @productID = 1, @parentID = null, @predecessorNodeID = null, @orderNo = @intOrderNo out
    select @intResult, @intOrderNo;


    -- move record in same parent group
    declare @intResult int, @intOrderNo int;
    exec @intResult = [Products].[pTree_Move] @ID = 9, @productID = 1, @parentID = 6, @predecessorNodeID = 7, @orderNo = @intOrderNo out
    select @intResult, @intOrderNo;


    -- move record to another parent group
    declare @intResult int, @intOrderNo int;
    exec @intResult = [Products].[pTree_Move] @ID = 49, @productID = 1, @parentID = 50, @predecessorNodeID = null, @orderNo = @intOrderNo out
    select @intResult, @intOrderNo;

*/
END

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
