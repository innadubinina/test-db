SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [licenses].[pActivation]
      @action                 int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID                     int = null  out    , @rowcount               int = null  out    , @licenseID              int = null    , @systemID               int = null    , @parentID               int = null    , @count                  int = null    
    , @endDate                datetime = null
    , @createDate             datetime = null        -- for select action only
	, @modifyDate             datetime = null
as
--  ==================================================================
--  creator:  tatiana.didenko (20120724)
--  modifier: 
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[licenses].[activation]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //
declare @history xml;

begin try

    if (@trancount > 0) SAVE TRANSACTION Licenses_pActivation
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [licenses].[activation] where id = @ID
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
        set @createDate = getdate()
        set @history = (select isnull(ltrim(rtrim(convert(nvarchar(30), @createDate, 121))), 'null') as [createDate]
                             , isnull(ltrim(rtrim(cast(@licenseID as varchar(48)))), 'null')       as [licenseID]
                             , isnull(ltrim(rtrim(cast(@systemID as varchar(48)))), 'null')        as [systemID]
                             , isnull(ltrim(rtrim(cast(@parentID as varchar(48)))), 'null')        as [parentID]
                             , isnull(ltrim(rtrim(cast(@count as varchar(48)))), 'null')           as [count]
                             , isnull(ltrim(rtrim(convert(nvarchar(30), @endDate, 121))), 'null')    as [endDate]
                        for xml raw('insert'), root('history')
                       )
  
        insert [licenses].[activation] ([licenseID],[systemID],[parentID],[count],[endDate],[createDate],[history])
        values (@licenseID, @systemID, @parentID, @count, @endDate, @createDate, @history)

        set @rowcount = @@rowcount;
        select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin

        -- <base table update> -----------------------------
        set @modifyDate = getdate()
        set @history = (select isnull(ltrim(rtrim(convert(nvarchar(30), @modifyDate, 121))), 'null') as [modifyDate]
                             , isnull(ltrim(rtrim(cast(@licenseID as varchar(48)))), 'null')       as [licenseID]
                             , isnull(ltrim(rtrim(cast(@systemID as varchar(48)))), 'null')        as [systemID]
                             , isnull(ltrim(rtrim(cast(@parentID as varchar(48)))), 'null')        as [parentID]
                             , isnull(ltrim(rtrim(cast(@count as varchar(48)))), 'null')           as [count]
                             , isnull(ltrim(rtrim(convert(nvarchar(30), @endDate, 121))), 'null')    as [endDate]
                        for xml raw('update')
                       )
        
        update [licenses].[activation]
        set  [licenseID] = @licenseID, [systemID] = @systemID, [parentID] = @parentID, [count] = @count, [endDate] = @endDate, [modifyDate] = @modifyDate
            , [history]= cast(substring(cast([history] as nvarchar(max)), 0, len(cast([history] as nvarchar(max)))-len('</history>')+1)+cast(@history as nvarchar(max))+'</history>' as xml) 
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
            case when @id          is null then '' else 'and (act.[id] = @id)'                  + char (0x0d) end +    
            case when @licenseID   is null then '' else 'and (act.[licenseID] = @licenseID)'    + char (0x0d) end + 
            case when @systemID    is null then '' else 'and (act.[systemID] = @systemID)'      + char (0x0d) end + 
            case when @parentID    is null then '' else 'and (act.[parentID] = @parentID)'      + char (0x0d) end + 
            case when @count       is null then '' else 'and (act.[count] = @count)'            + char (0x0d) end + 
            case when @endDate     is null then '' else 'and (act.[endDate] = @endDate)'        + char (0x0d) end +  
            case when @createDate  is null then '' else 'and (act.[createDate] = @createDate)'  + char (0x0d) end +
            case when @modifyDate  is null then '' else 'and (act.[modifyDate] = @modifyDate)'  + char (0x0d) end ;

        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  act.[id]          as [Activation.ID]
                , act.[licenseID]   as [Activation.LicenseID]
                , act.[systemID]    as [Activation.SystemID]
                , act.[parentID]    as [Activation.ParentID]
                , act.[count]       as [Activation.Count]
                , act.[endDate]     as [Activation.EndDate]
                , act.[createDate]  as [Activation.CreateDate]
                , act.[modifyDate]  as [Activation.ModifyDate]
                , act.[history]     as [Activation.History]
            from [licenses].[activation] act'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by act.id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id                     int
            , @rowcount               int  out

            , @licenseID              int			, @systemID               int			, @parentID               int			, @count                  int		    
			, @endDate                datetime
			, @createDate             datetime
			, @modifyDate             datetime
            ';
        -- print @sqlParmDefinition;        

        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @licenseID = @licenseID, @systemID = @systemID, @parentID = @parentID, @count = @count, @endDate = @endDate
			, @createDate = @createDate, @modifyDate = @modifyDate
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Licenses_pActivation

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
--  select * from [licenses].[activation]; 
--  select top 10 * from log.error


--  SELECT
    exec [licenses].[pActivation] @id=4
    exec [licenses].[pActivation] @rowcount = 10


--  INSERT
declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [licenses].[pGroup] @action = 1, @userID = 1, @productID = 0, @licenseCount = 2, @lifeTimeDays = 5
		, @serverActivationCount = 1, @resellerName = 'TEST', @readyForActivation = 0
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pGroup]
    rollback
    
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [licenses].[pLicense] @action = 1, @groupID = 13, @key = 'ttttttt', @readyForActivation = 1, @deactivated = 0
		, @allowedActivationCount = 7, @lifeTimeDays = 10, @serverActivationCount = 4 
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pLicense]
    rollback
    
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [clients].[pSystem] @action = 1, @UID = '595F8DB8-DE97-4E14-A2FF-66481859EAEA', @machineKey='595F8DB2-DE97-4E04-A2FF-66483259EAEA' 
                    , @motherboardKey ='TEST', @physicalMAC ='TEST2' 
        , @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pSystem]
    rollback


 declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [licenses].[pActivation] @action = 1, @licenseID = 5, @systemID = 5, @count = 10, @endDate = '20120901'
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pActivation]
    rollback
    

--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [licenses].[pActivation] @action = 4, @id = 1, @licenseID = 5, @systemID = 5, @count = 15, @endDate ='20121005'
		, @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pActivation]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [licenses].[pActivation] @action = 2, @id = 1
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pActivation]
    rollback

*/

return @intResult;
END
GO
