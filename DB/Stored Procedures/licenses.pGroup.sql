SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [licenses].[pGroup]
      @action                int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID                    int = null  out    , @rowcount              int = null  out    , @resellerName          nvarchar(128) = null    , @userID                int = null    , @productID             int = null        , @licenseCount          int = null    , @lifeTimeDays          int = null    , @serverActivationCount int = null    , @readyForActivation    bit = null    
    , @createDate            datetime = null        -- for select action only
as
--  ==================================================================
--  creator:  tatiana.didenko (20120723)
--  modifier: 
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[licenses].[group]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION Licenses_pGroup
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [licenses].[group] where id = @ID
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
        insert [licenses].[group] (userID, productID, licenseCount, lifeTimeDays, serverActivationCount, resellerName, readyForActivation)
        values (@userID, @productID, @licenseCount, @lifeTimeDays, @serverActivationCount, @resellerName, @readyForActivation)

        set @rowcount = @@rowcount;
        select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin

        -- <base table update> -----------------------------
        update [licenses].[group]
        set   userID = @userID, productID = @productID, licenseCount = @licenseCount, lifeTimeDays = @lifeTimeDays
			, serverActivationCount = @serverActivationCount, resellerName = @resellerName, readyForActivation = @readyForActivation
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
            case when @id                     is null then '' else 'and (lgr.[id] = @id)'                                        + char (0x0d) end +    
            case when @userID                 is null then '' else 'and (lgr.[userID] = @userID)'                                + char (0x0d) end + 
            case when @productID              is null then '' else 'and (lgr.[productID] = @productID)'                          + char (0x0d) end + 
            case when @licenseCount           is null then '' else 'and (lgr.[licenseCount] = @licenseCount)'                    + char (0x0d) end + 
            case when @lifeTimeDays           is null then '' else 'and (lgr.[lifeTimeDays] = @lifeTimeDays)'                    + char (0x0d) end + 
            case when @serverActivationCount  is null then '' else 'and (lgr.[serverActivationCount] = @serverActivationCount)'  + char (0x0d) end +  
            case when @resellerName           is null then '' else 'and (lgr.[resellerName] = @resellerName)'                    + char (0x0d) end +
            case when @readyForActivation     is null then '' else 'and (lgr.[readyForActivation] = @readyForActivation)'        + char (0x0d) end + 
            case when @createDate             is null then '' else 'and (lgr.[createDate] = @createDate)'                        + char (0x0d) end ;

        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  lgr.[id]                    as [Group.ID]
                , lgr.[userID]                as [Group.UserID]
                , lgr.[productID]             as [Group.ProductID]
                , lgr.[licenseCount]          as [Group.LicenseCount]
                , lgr.[lifeTimeDays]          as [Group.LifeTimeDays]
                , lgr.[serverActivationCount] as [Group.ServerActivationCount]
                , lgr.[resellerName]          as [Group.ResellerName]
                , lgr.[readyForActivation]    as [Group.ReadyForActivation]
                , lgr.[createDate]            as [Group.CreateDate]
            from [licenses].[group] lgr'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by lgr.id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id                    int
            , @rowcount              int  out    

            , @resellerName          nvarchar(128)			, @userID                int			, @productID             int			, @licenseCount          int			, @lifeTimeDays          int			, @serverActivationCount int			, @readyForActivation    bit
            , @createDate            datetime
              
            ';
        -- print @sqlParmDefinition;        


        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @resellerName = @resellerName, @userID = @userID, @productID = @productID, @licenseCount = @licenseCount, @lifeTimeDays = @lifeTimeDays
            , @serverActivationCount = @serverActivationCount, @readyForActivation = @readyForActivation, @createDate = @createDate
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Licenses_pGroup

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
--  select * from [licenses].[group]; 
--  select top 10 * from log.error


--  SELECT
    exec [licenses].[pGroup] @id=13
    exec [licenses].[pGroup] @rowcount = 10


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


--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [licenses].[pGroup] @action = 4, @id = 5, @userID = 1, @productID = 0, @licenseCount = 4, @lifeTimeDays = 10
		, @serverActivationCount = 3, @resellerName = 'TEST', @readyForActivation = 1
		, @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pGroup]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [licenses].[pGroup] @action = 2, @id = 5
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pGroup]
    rollback

*/

return @intResult;
END
GO
