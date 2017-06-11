SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [products].[pProduct]
      @action                int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID                    int = null  out    , @rowcount              int = null  out    , @name         varchar(128) = null    , @title        varchar(128) = null    , @description nvarchar(256) = null
	, @groupid               int = null
	, @disabled              bit = null
	, @hasLifetime           bit = null
	, @externalID            int = null
	, @isFree                bit = null

    , @createDate       datetime = null        -- for select action only
as
--  ==================================================================
--  creator:  tatiana.didenko (20120723)
--  modifier: 20130920 mykhaylo tytarenko. New field 'isFree' was added
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations for '[products].[pProduct]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION Products_pProduct
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [products].[product] where id = @ID
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
        insert [products].[product] ([name], [title], [description], [groupID], [disabled], [hasLifetime], [externalID], [isFree])
        values (@name, @title, @description, @groupid, @disabled, @hasLifetime, @externalID, @isFree)

        set @rowcount = @@rowcount;
        select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin

        -- <base table update> -----------------------------
        update [products].[product]
        set   [name] = @name, [title] = @title, [description] = @description, [groupID] = @groupid, [disabled] = @disabled, [hasLifetime] = @hasLifetime, [externalID] = @externalID, [isFree] = @isFree
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
            case when @id          is null then '' else 'and ([id] = @id)'                   + char (0x0d) end +    
            case when @name        is null then '' else 'and ([name] = @name)'               + char (0x0d) end +
            case when @title       is null then '' else 'and ([title] = @title)'             + char (0x0d) end +
            case when @description is null then '' else 'and ([description] = @description)' + char (0x0d) end +
            case when @groupid     is null then '' else 'and ([groupID] = @groupid)'         + char (0x0d) end +
            case when @disabled    is null then '' else 'and ([disabled] = @disabled)'       + char (0x0d) end +
            case when @hasLifetime is null then '' else 'and ([hasLifetime] = @hasLifetime)' + char (0x0d) end +     
            case when @externalID  is null then '' else 'and ([externalID] = @externalID)'   + char (0x0d) end +
            case when @isFree      is null then '' else 'and ([isFree] = @isFree)'           + char (0x0d) end +
            case when @createDate  is null then '' else 'and ([createDate] = @createDate)'   + char (0x0d) end ;


        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  [id]          as [Product.ID]
                , [name]        as [Product.Name]
                , [title]		 as [Product.Title]
                , [description] as [Product.Description]
                , [groupID]     as [Product.GroupID]
				, [groupid]     as [Product.Groupid]
                , [disabled]    as [Product.Disabled]
                , [hasLifetime] as [Product.HasLifetime]
                , [externalID]  as [Product.ExternalID]
                , [isFree]      as [Product.IsFree]
                , [createDate]  as [Product.CreateDate]
            from [products].[product]'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id             int
            , @rowcount       int  out    

            , @name             varchar(128)			, @title            varchar(128)			, @description      nvarchar(256)
			, @groupid			int
			, @disabled         bit
			, @hasLifetime      bit
			, @externalID       int
			, @isFree           bit

            , @createDate     datetime
              
            ';
        -- print @sqlParmDefinition;        


        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id, @name = @name, @title = @title
            , @description = @description, @groupid	= @groupid, @disabled = @disabled, @hasLifetime = @hasLifetime, @externalID = @externalID, @createDate = @createDate, @isFree = @isFree
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Products_pProduct

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
--  select * from [products].[product]; 
--  select top 10 * from log.error


--  SELECT
    exec [products].[pProduct]
    exec [products].[pProduct] @rowcount = 10


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [products].[pProduct] @action = 1, @name = 'TEST', @title = 'TestTitle', @description = 'DescrTitle', @groupid =1, @disabled = 1, @hasLifetime = 1
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [products].[pProduct]
    rollback


--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [products].[pProduct] @action = 4, @id =2, @name = 'TEST', @title = 'TestTitle', @description = 'DescrTitleTEST', @groupid =3, @disabled = 1, @hasLifetime = 1, @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [products].[pProduct]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [products].[pProduct] @action = 2, @id = 2
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [products].[pProduct]
    rollback

*/

return @intResult;
END
GO
