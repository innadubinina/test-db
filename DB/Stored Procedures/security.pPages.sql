SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [security].[pPages]
      @action           int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID               int = null  out    , @rowcount         int = null  out    , @name             nvarchar(50) = null    , @navigateUrl      nvarchar(max) = null    --, @navigate         bit = null
	--, @role             bit = null
	, @order            int = null
    , @createDate       datetime = null        -- for select action only
as
--  ==================================================================
--  creator:  tatiana.didenko (20120723)
--  modifier: tatiana.didenko (20120724) added field "Order"
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[security].[pages]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION Security_pPages
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [security].[pages] where id = @ID
        set @rowcount = @@rowcount;
        if @rowcount = 0
        begin
            set @errMsg = 'non-existent row delete operation found.' 
                +  char(0x0d) + char(0x0a) + char(0x09) + '@ID=' + isnull(ltrim(rtrim(cast(@ID as varchar(48)))), 'null')
            raiserror (@errMsg , 16, 1)
        end
        ------------------------------- </base table delete>

    end
    ---------------------------------------------- </delete operation>


    -- <insert operation>  -------------------------------------------
    if @action & 0x01 != 0
    begin

        -- <base table insert> -----------------------------
        insert [security].[pages] ([Name], [NavigateUrl], /*[Navigate], [Role],*/ [Order])
        values (@name, @navigateUrl, /*@navigate, @role,*/ @order)

        set @rowcount = @@rowcount;
        select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin

        -- <base table update> -----------------------------
        update [security].[pages]
        set   [Name] = @name, [NavigateUrl] = @navigateUrl, /*[Navigate] = @navigate, [Role] = @role,*/ [Order] = @order
        where id = @ID

        set @rowcount = @@rowcount;
        if @rowcount = 0
        begin
            set @errMsg = 'non-existent row update operation found.' 
                +  char(0x0d) + char(0x0a) + char(0x09) + '@ID=' + isnull(ltrim(rtrim(cast(@ID as varchar(48)))), 'null')
            raiserror (@errMsg , 16, 1)
        end
        ------------------------------- </base table update>

    end
    ---------------------------------------------- </update operation> 



    -- <select operation>  -------------------------------------------
    ------------------------------------------------------------------
    if @action & 0x08 != 0
    begin
        declare @sqlText nvarchar(max), @sqlParmDefinition nvarchar(max), @sqlFilter nvarchar(max);
        
        set @sqlFilter = N'' +
            case when @id          is null then '' else 'and (pg.[Id] = @id)'                   + char (0x0d) end +    
            case when @name        is null then '' else 'and (pg.[Name] = @name)'               + char (0x0d) end +
            case when @navigateUrl is null then '' else 'and (pg.[NavigateUrl] = @navigateUrl)' + char (0x0d) end +
            --case when @navigate    is null then '' else 'and (pg.[Navigate] = @navigate)'       + char (0x0d) end +
            --case when @role        is null then '' else 'and (pg.[Role] = @role)'               + char (0x0d) end +
            case when @order       is null then '' else 'and (pg.[Order] = @order)'             + char (0x0d) end +
            case when @createDate  is null then '' else 'and (pg.[CreateDate] = @createDate)'   + char (0x0d) end ;


        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  pg.[id]          as [Pages.ID]
                , pg.[Name]        as [Pages.Name]
                , pg.[NavigateUrl] as [Pages.NavigateUrl]
                , pg.[CreateDate]  as [Pages.CreateDate]
              --  , pg.[Navigate]    as [Pages.Navigate]
              --  , pg.[Role]        as [Pages.Role]
                , pg.[Order]       as [Pages.Order]
            from [security].[pages] pg'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by pg.id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id             int
            , @rowcount       int  out    

            , @name             nvarchar(50)			, @navigateUrl      nvarchar(max)		--	, @navigate         bit
		--	, @role             bit
			, @order            int
			, @createDate       datetime
              
            ';
        -- print @sqlParmDefinition;        


        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @name = @name, @navigateUrl = @navigateUrl, /*@navigate = @navigate, @role = @role,*/ @order = @order, @createDate = @createDate
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Security_pPages

    set @ID = null;

    select @errNum = error_number(), @errMsg = error_message();
    if xact_state() <> -1 exec [log].[pError] @number = @errNum, @message = @errMsg, @spid = @@spid
    print @errMsg;
    print @sqlText

    -- output error result
    set @intResult = case 
        when @errNum > 0 then (-1)*@errNum
        when @errNum = 0 then -1
        else @errNum
        end

end catch;

/*  TEST ZONE
--  select * from [security].[pages]; 
--  select top 10 * from log.error


--  SELECT
    exec [security].[pPages] @id=10
    exec [security].[pPages] @rowcount = 10


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [security].[pPages] @action = 1, @name = 'Test', @navigateUrl = 'TEST.aspx', @navigate = 1, @role = 1
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [security].[pPages]
    rollback


--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [security].[pPages] @action = 4, @id = 10, @name = 'TEST', @navigateUrl = 'TEST 2.aspx', @navigate = 0, @role = 0, @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [security].[pPages]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [security].[pPages] @action = 2, @id = 10
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [security].[pPages]
    rollback

*/

return @intResult;
END
GO
