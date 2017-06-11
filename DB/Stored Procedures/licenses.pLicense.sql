SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [licenses].[pLicense]
      @action                 int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID                     int = null  out    , @rowcount               int = null  out    , @groupID                int = null    , @key                    varchar(64) = null    , @readyForActivation     bit = null    , @deactivated            bit = null    , @allowedActivationCount int = null    , @lifeTimeDays           int = null    , @serverActivationCount  int = null
    , @createDate             datetime = null        -- for select action only
	, @modifyDate             datetime = null
as
--  ==================================================================
--  create: 20120723 Tatiana Didenko
--  modify: 20120724 Tatiana Didenko. Added xml field "history"
--  modify: 20120725 Mykhaylo Tytarenko. Rewrite select zone via view 'licenses.vLicense'
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[licenses].[license]' table
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

    if (@trancount > 0) SAVE TRANSACTION Licenses_pLicense
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [licenses].[license] where id = @ID
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
        set @history = (select convert(nvarchar(30), @createDate, 121)      as [createDate]
                             , cast(@groupID as nvarchar(10))               as [groupID]
                             , @key                                         as [key]
                             , cast(@readyForActivation as nvarchar(5))     as [readyForActivation]
                             , cast(@deactivated as nvarchar(5))            as [deactivated]
                             , cast(@allowedActivationCount as nvarchar(10))as [allowedActivationCount]
                             , cast(@lifeTimeDays as nvarchar(10))          as [lifeTimeDays]
                             , cast(@serverActivationCount as nvarchar(10)) as [serverActivationCount]
                        for xml raw('insert'), root('history')
                       )
  
        insert [licenses].[license] ([groupID], [key], [readyForActivation], [deactivated], [allowedActivationCount], [lifeTimeDays], [serverActivationCount], [createDate], [history])
        values (@groupID, @key, @readyForActivation, @deactivated, @allowedActivationCount, @lifeTimeDays, @serverActivationCount, @createDate, @history)

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
        set @history = (select convert(nvarchar(30), @modifyDate, 121)      as [modifyDate]
                             , cast(@groupID as nvarchar(10))               as [groupID]
                             , @key                                         as [key]
                             , cast(@readyForActivation as nvarchar(5))     as [readyForActivation]
                             , cast(@deactivated as nvarchar(5))            as [deactivated]
                             , cast(@allowedActivationCount as nvarchar(10))as [allowedActivationCount]
                             , cast(@lifeTimeDays as nvarchar(10))          as [lifeTimeDays]
                             , cast(@serverActivationCount as nvarchar(10)) as [serverActivationCount]
                        for xml raw('update')
                       )
        
        update [licenses].[license]
        set   [groupID] = @groupID, [key] = @key, [readyForActivation] = @readyForActivation, [deactivated] = @deactivated, [allowedActivationCount] = @allowedActivationCount
            , [lifeTimeDays] = @lifeTimeDays, [serverActivationCount] = @serverActivationCount, [modifyDate] = @modifyDate
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
            case when @id                     is null then '' else 'and (lns.[id] = @id)'                                         + char (0x0d) end +    
            case when @groupID                is null then '' else 'and (lns.[groupID] = @groupID)'                               + char (0x0d) end + 
            case when @key                    is null then '' else 'and (lns.[key] = @key)'                                       + char (0x0d) end + 
            case when @readyForActivation     is null then '' else 'and (lns.[readyForActivation] = @readyForActivation)'         + char (0x0d) end + 
            case when @deactivated            is null then '' else 'and (lns.[deactivated] = @deactivated)'                       + char (0x0d) end + 
            case when @allowedActivationCount is null then '' else 'and (lns.[allowedActivationCount] = @allowedActivationCount)' + char (0x0d) end +  
            case when @lifeTimeDays           is null then '' else 'and (lns.[lifeTimeDays] = @lifeTimeDays)'                     + char (0x0d) end +
            case when @serverActivationCount  is null then '' else 'and (lns.[serverActivationCount] = @serverActivationCount)'   + char (0x0d) end + 
            case when @createDate             is null then '' else 'and (lns.[createDate] = @createDate)'                         + char (0x0d) end +
            case when @modifyDate             is null then '' else 'and (lns.[modifyDate] = @modifyDate)'                         + char (0x0d) end ;

        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  lns.[id]                     as [ID]
                , lns.[groupID]                as [GroupID]
                , lns.[key]                    as [Key]
                , lns.[readyForActivation]     as [ReadyForActivation]
                , lns.[deactivated]            as [Deactivated]
                , lns.[allowedActivationCount] as [AllowedActivationCount]
                , lns.[lifeTimeDays]           as [LifeTimeDays]
                , lns.[serverActivationCount]  as [ServerActivationCount]
                , lns.[createDate]             as [CreateDate]
                , lns.[modifyDate]             as [ModifyDate]
                , lns.[history]                as [History]
            from licenses.vLicense lns'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by lns.id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        -- print @sqlText;

        set @sqlParmDefinition = N'
              @id                     int
            , @rowcount               int  out

            , @groupID                int			, @key                    varchar(64)			, @readyForActivation     bit			, @deactivated            bit			, @allowedActivationCount int			, @lifeTimeDays           int			, @serverActivationCount  int
			, @createDate             datetime
			, @modifyDate             datetime
            ';
        -- print @sqlParmDefinition;        

        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @groupID = @groupID, @key = @key, @readyForActivation = @readyForActivation, @deactivated = @deactivated, @allowedActivationCount = @allowedActivationCount
            , @lifeTimeDays = @lifeTimeDays, @serverActivationCount = @serverActivationCount, @createDate = @createDate, @modifyDate = @modifyDate 
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Licenses_pLicense

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
--  select * from [licenses].[license];
--  select * from [licenses].[vLicense]; 
--  select top 10 * from log.error


--  SELECT
    exec [licenses].[pLicense] @id=4
    exec [licenses].[pLicense] @rowcount = 10


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [licenses].[pGroup] @action = 1, @userID = 1, @productID = 0, @allowedActivationCount = 2, @lifeTimeDays = 5
		, @serverActivationCount = 1, @resellerName = 'TEST', @readyForActivation = 0
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pLicense]
    rollback
    
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [licenses].[pLicense] @action = 1, @groupID = 11, @key = 'ttttttt', @readyForActivation = 1, @deactivated = 0
		, @allowedActivationCount = 7, @lifeTimeDays = 10, @serverActivationCount = 4 
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pLicense]
    rollback


--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [licenses].[pLicense] @action = 4, @id = 4, @groupID = 11, @key = 'aaaa', @readyForActivation = 1, @deactivated = 0
			, @allowedActivationCount = 10, @lifeTimeDays = 15, @serverActivationCount = 6
		, @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pLicense]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [licenses].[pLicense] @action = 2, @id = 4
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [licenses].[pLicense]
    rollback

*/

return @intResult;
END
GO
