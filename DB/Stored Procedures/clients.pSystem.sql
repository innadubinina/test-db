SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [clients].[pSystem]
      @action           int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID               int = null  out    , @rowcount         int = null  out    , @UID              uniqueidentifier = null  
    , @machineKey       uniqueidentifier = null
    , @motherboardKey   varchar(128) = null
    , @physicalMAC      varchar(128) = null
    , @isAutogeneratedMachineKey bit = null
    , @clientID         int = null
    
    , @createDate       datetime = null        -- for select action only
as
--  ==================================================================
--  create:  20120724 tatiana.didenko
--  modify:
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[clients].[system]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION clients_pSystem
    else BEGIN TRAN


    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [clients].[system] where ID = @ID
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
        
        --  if UID not passed from client - DB must generate it
        if @UID is null set @UID = (select newid());
        
        -- <base table insert> -----------------------------
        insert [clients].[system] ([UID],[machineKey],[motherboardKey],[physicalMAC],[clientID], [isAutogeneratedMachineKey])
        values (@UID, @machineKey, @motherboardKey, @physicalMAC, @clientID, @isAutogeneratedMachineKey)

        set @rowcount = @@rowcount;
        select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin

        -- <base table update> -----------------------------
        update [clients].[system]
        set [UID] = @UID, [machineKey] = @machineKey, [motherboardKey] = @motherboardKey, [physicalMAC] = @physicalMAC
			, [clientID] = @clientID, [isAutogeneratedMachineKey] = @isAutogeneratedMachineKey
        where ID = @ID

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
        declare @intTotalRecords int;
        
        set @sqlFilter = N'' +
            case when @id                        is null then '' else 'and (base.[ID] = @id)'                                               + char (0x0d) end +
            case when @UID                       is null then '' else 'and (base.[UID] = @UID)'                                             + char (0x0d) end +    
            case when @machineKey                is null then '' else 'and (base.[machineKey] = @machineKey)'                               + char (0x0d) end +
            case when @motherboardKey            is null then '' else 'and (base.[motherboardKey] = @motherboardKey)'                       + char (0x0d) end +
            case when @physicalMAC               is null then '' else 'and (base.[physicalMAC] = @physicalMAC)'                             + char (0x0d) end +
            case when @clientID                  is null then '' else 'and (base.[clientID] = @clientID)'                                   + char (0x0d) end +
            case when @createDate                is null then '' else 'and (base.[CreateDate] = @createDate)'                               + char (0x0d) end +
            case when @isAutogeneratedMachineKey is null then '' else 'and (base.[isAutogeneratedMachineKey] = @isAutogeneratedMachineKey)' + char (0x0d) end;

        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'

            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  base.[ID]                        as [System.ID]
                , base.[UID]                       as [System.UID]
                , base.[machineKey]                as [System.MachineKey]
                , base.[motherboardKey]            as [System.MotherboardKey]
                , base.[physicalMAC]               as [System.PhysicalMAC]
                , base.[clientID]                  as [System.ClientID]
                , base.[CreateDate]                as [System.CreateDate]
                , base.[isAutogeneratedMachineKey] as [System.isAutogeneratedMachineKey]
            from [clients].[system] base '
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
              @id                    int
            , @rowcount              int  out    

            , @UID                       uniqueidentifier
			, @machineKey                uniqueidentifier
			, @motherboardKey            varchar(128)
			, @physicalMAC               varchar(128)
			, @isAutogeneratedMachineKey bit
			, @clientID                  int
			, @createDate                datetime
            ';
        -- print @sqlParmDefinition;        


        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @UID = @UID
			, @machineKey = @machineKey
			, @motherboardKey = @motherboardKey
			, @physicalMAC = @physicalMAC
			, @clientID = @clientID
			, @createDate = @createDate
			, @isAutogeneratedMachineKey = @isAutogeneratedMachineKey
            , @rowcount = @rowcount out
        

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION clients_pSystem

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
--  select * from [clients].[system];
--  select top 10 * from log.error

--  SELECT
    exec [clients].[pSystem] 
    exec [clients].[pSystem] @rowcount = 10

select newid()

--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    insert into clients.client([UID],[email],[firstName],[lastName],[isValidEmail],[optIn],[userNameLC],[domain])
    values ('125F8DB8-DE97-4E04-A2FF-66481859EAEA','sdf@dfg.ru','fff','bbb', 1,1,'rrf','fgfg')
    select * from clients.client
    
    exec @intResult = [clients].[pSystem] @action = 1, @UID = '595F8DB8-DE97-4E04-A2FF-66481859EAEA', @machineKey='595F8DB8-DE97-4E04-A2FF-66483259EAEA' 
                    , @motherboardKey ='TEST', @physicalMAC ='TEST2', @clientID = 7 , @isAutogeneratedMachineKey = 1
        , @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pSystem]
    rollback


--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [clients].[pSystem] @action = 4, @id = 28, @UID = '595F8DB8-DE97-4E04-A2FF-66481859EAEA', @machineKey='535F8DB8-DE97-4E04-A2FF-66483259EAEA' 
                    , @motherboardKey ='TEST3', @physicalMAC ='TEST333', @clientID = 7 , @isAutogeneratedMachineKey = 0
        , @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pSystem]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [clients].[pSystem] @action = 2, @id = 28
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pSystem]
    rollback

*/

return @intResult;
END
GO
