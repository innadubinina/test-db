SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [products].[pGroup]
      @action                int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID                    int = null  out    , @rowcount              int = null  out    , @name          varchar(50) = null    , @externalID            int = null    , @description nvarchar(256) = null

    , @createDate       datetime = null        -- for select action only
as
--  ==================================================================
--  creator:  tatiana.didenko (20120723)
--  modifier: 
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[products].[pGroup]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION Products_pGroup
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [products].[group] where id = @ID
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
        insert [products].[group] ([name], [description], [externalID])
        values (@name, @description, @externalID)

        set @rowcount = @@rowcount;
        select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin

        -- <base table update> -----------------------------
        update [products].[group]
        set   [name] = @name, [description] = @description, [externalID] = @externalID
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
       -- declare @intTotalRecords int;
        
        set @sqlFilter = N'' +
            case when @id          is null then '' else 'and (prim.[id] = @id)'                   + char (0x0d) end +    
            case when @name        is null then '' else 'and (prim.[name] = @name)'               + char (0x0d) end +
            case when @description is null then '' else 'and (prim.[description] = @description)' + char (0x0d) end +
            case when @externalID  is null then '' else 'and (prim.[externalID] = @externalID)'   + char (0x0d) end +
            case when @createDate  is null then '' else 'and (prim.[createDate] = @createDate)'   + char (0x0d) end ;


        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  prim.[id]          as [Group.ID]
                , prim.[name]        as [Group.Name]
                , prim.[description] as [Group.Description]
                , prim.[externalID]  as [Group.ExternalID]
                , prim.[createDate]  as [Group.CreateDate]
            from [products].[group] prim'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by prim.id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id             int
            , @rowcount       int  out    

            , @name           varchar(50)            , @externalID     int
            , @description    nvarchar(256)

            , @createDate     datetime
              
            ';
        -- print @sqlParmDefinition;        


        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id, @name = @name
            , @description = @description, @externalID = @externalID, @createDate = @createDate
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Products_pGroup

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
--  select * from [products].[group]; 
--  select top 10 * from log.error


--  SELECT
    exec [products].[pGroup] @id=13
    exec [products].[pGroup] @rowcount = 10


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [products].[pGroup] @action = 1, @name = 'TEST', @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [products].[pGroup]
    rollback


--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [products].[pGroup] @action = 4, @id = 263, @name = 'TEST', @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [products].[pGroup]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [products].[pGroup] @action = 2, @id = 263
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [products].[pGroup]
    rollback

*/

return @intResult;
END
GO
