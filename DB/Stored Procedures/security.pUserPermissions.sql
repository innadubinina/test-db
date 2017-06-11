SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [security].[pUserPermissions]
      @action           int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID               int = null  out    , @rowcount         int = null  out    , @userID           int = null    , @pageID           int = null
as
--  ==================================================================
--  creator:  tatiana.didenko (20120723)
--  modifier: 
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[security].[userPermissions]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION Security_pUserPermissions
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [security].[userPermissions] where id = @ID
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
        insert [security].[userPermissions] (UserID, PageID)
        values (@userID, @pageID)

        set @rowcount = @@rowcount;
        select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin

        -- <base table update> -----------------------------
        update [security].[userPermissions]
        set   UserID = @userID, PageID = @pageID
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
            case when @id       is null then '' else 'and (perm.[ID] = @id)'          + char (0x0d) end +    
            case when @userID   is null then '' else 'and (perm.[UserID] = @userID)'  + char (0x0d) end +
            case when @pageID   is null then '' else 'and (perm.[PageID] = @pageID)'  + char (0x0d) end ;


        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  perm.[ID]       as [UserPermissions.ID]
                , perm.[UserID]   as [UserPermissions.UserID]
                , perm.[PageID]	  as [UserPermissions.PageID]
            from [security].[userPermissions] perm'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by perm.id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id             int
            , @rowcount       int  out    

            , @userID         int            , @pageID         int
              
            ';
        -- print @sqlParmDefinition;        


        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @userID = @userID, @pageID  = @pageID
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Security_pUserPermissions

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
--  select * from [security].[userPermissions]; 
--  select top 10 * from log.error


--  SELECT
    exec [security].[pUserPermissions] @id=841
    exec [security].[pUserPermissions] @rowcount = 10


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [security].[pUserPermissions] @action = 1, @userID = 18, @pageID  = 6  
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [security].[pUserPermissions]
    rollback


--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [security].[pUserPermissions] @action = 4, @id = 841, @userID = 19, @pageID  = 6 
			, @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [security].[pUserPermissions]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [security].[pUserPermissions] @action = 2, @id = 841
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [security].[pUserPermissions]
    rollback

*/

return @intResult;
END
GO
