SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [log].[pActivationService]
      @action          int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID              int = null  out    , @rowcount        int = null  out    , @paramList       xml = null
    , @createDate datetime = null        -- for select action only
as
--  ==================================================================
--  create: 20120723 Mykhaylo Tytarenko
--  modify: 20130131 Mykhaylo Tytarenko. Autoclear logic added to insert zone.
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[log].[pActivationService]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION log_pActivationService
    else BEGIN TRAN


    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin
        set @errMsg = 'delete operation is not applicable for this table' 
        raiserror (@errMsg , 16, 1)
    end
    ---------------------------------------------- </delete operation>


    -- <insert operation>  -------------------------------------------
    if @action & 0x01 != 0
    begin
        --  autoclear obsolete records
        declare @twoDaysAgo datetime; set @twoDaysAgo = ( select cast( cast (dateadd(dd, -2, getdate()) as date) as datetime) );
        if exists (select * from [log].[activationService] where createDate < @twoDaysAgo)
            delete [log].[activationService] where createDate < @twoDaysAgo
    
        -- <base table insert> -----------------------------
        insert [log].[activationService] (paramList)
        values (@paramList)

        set @rowcount = @@rowcount;
        select @ID = scope_identity();
        ------------------------------- </base table insert>
    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin
        set @errMsg = 'update operation is not applicable for this table' 
        raiserror (@errMsg , 16, 1)

    end
    ---------------------------------------------- </update operation> 



    -- <select operation>  -------------------------------------------
    ------------------------------------------------------------------
    if @action & 0x08 != 0
    begin
        declare @sqlText nvarchar(max), @sqlParmDefinition nvarchar(max), @sqlFilter nvarchar(max);
        declare @intTotalRecords int;
        
        set @sqlFilter = N'' +
            case when @id         is null then '' else 'and (base.[ID] = @id)'                 + char (0x0d) end +
            case when @createDate is null then '' else 'and (base.[CreateDate] = @createDate)' + char (0x0d) end;

        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'

            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  base.[ID]         as [logActivationService.ID]
                , base.[paramList]  as [logActivationService.ParamList]
                , base.[CreateDate] as [logActivationService.CreateDate]
            from [log].[activationService] base '
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by base.ID desc' 
 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id              int
            , @rowcount        int  out    

            , @paramList       xml 
            , @createDate datetime
            ';
        -- print @sqlParmDefinition;        


        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @paramList = @paramList, @createDate = @createDate

            , @rowcount = @rowcount out
        

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION log_pActivationService

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
--  select * from [clients].[session];
--  select top 10 * from log.error

--  SELECT
    exec [log].[pActivationService] 
    exec [log].[pActivationService] @rowcount = 10


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [log].[pActivationService] @action = 1, @privateKey = 0x000000087, @IPAddress = '121.17.96.1'
        , @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [log].[pActivationService]
    rollback


--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [log].[pActivationService] @action = 4, @id = 6, @UID = 'AAB116A3-5CA2-418F-B2B1-10CD128CF848', @privateKey = 0x0000097, @IPAddress = '10.17.96.1'
        , @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [log].[pActivationService]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [log].[pActivationService] @action = 2, @id = 6
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [log].[pActivationService]
    rollback

*/

return @intResult;
END
GO
