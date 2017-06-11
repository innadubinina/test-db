SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [activationService].[pClientSession_Get]
      @UID   uniqueidentifier
    
    , @privateKey varbinary(639) = NULL OUT
    , @keyTypeID         tinyint = NULL OUT
as
--  ==================================================================
--  create: 20120723 Mykhaylo Tytarenko
--  modify: 20130121 Mykhaylo Tytarenko. Add timeout logic.
--  modify: 20130222 Mykhaylo Tytarenko. Private (596->635) and Public (148->162) keys expanded.
--  description: get privateKey by sessionUID
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //
declare @sessionID int, @intRowCount int, @id int;
declare @messageActivLog xml;

--  20130121. Timeout logic
--  Now Timeout is 20 minutes.
declare @sessionCreateDate datetime;
declare @sessionCreateDateLimit datetime; set @sessionCreateDateLimit = (select dateadd(minute, -20, getdate()));
--  // 20130121. Timeout logic


begin try

    if (@trancount > 0) SAVE TRANSACTION aS_pClientSession_Get
    else BEGIN TRAN

    if @UID is not null
    begin
        -- select @privateKey = privateKey, @sessionCreateDate = createDate from [clients].[Session] where UID = @UID
        select
              @privateKey = [privateKey]
            , @keyTypeID = [keyTypeID]
            , @sessionCreateDate = [createDate]
        from [clients].[fGetSessionByUID] (@UID)
        --  select * from [clients].[fGetSessionByUID] ('65A4AC3D-A045-434D-AA68-DAAFB0373586')
        
        if @@rowCount < 1
        begin
            set @errMsg = 'session not found'
                +  char(0x0d) + char(0x0a) + char(0x09) + '@UID=' + isnull(ltrim(rtrim(cast(@UID as varchar(48)))), 'null')
            raiserror (@errMsg , 16, 1)
        end
        else
        if @sessionCreateDate < @sessionCreateDateLimit
        begin
            set @errMsg = 'session not found because of timeout'
                +  char(0x0d) + char(0x0a) + char(0x09) + '@UID=' + isnull(ltrim(rtrim(cast(@UID as varchar(48)))), 'null')
            raiserror (@errMsg , 16, 1)
        end

		print 'test'


        set @messageActivLog = (select 'For UID was found the privateKey' as [Message], isnull(cast(@UID as nvarchar(48)), 'null') as [UID], isnull(convert(varchar(1282),@privateKey, 1), 'null') as [privateKey]
                                for xml raw('ActivationLog')
                               )

        exec @intResult = [log].[pActivationService] @action = 1, @paramList = @messageActivLog
            , @rowCount = @intRowCount out, @id = @id out
    end
    


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION aS_pClientSession_Get

    --set @ID = null;

    select @errNum = error_number(), @errMsg = error_message();
    
    --  if @errMsg like 'session not found%' then @errNum 50000;
    
    if xact_state() <> -1 exec [log].[pError] @number = @errNum, @message = @errMsg
    print @errMsg;
    --print @sqlText;

	set @messageActivLog = (select @errMsg as [Message], isnull(cast(@UID as nvarchar(48)), 'null') as [UID] for xml raw('ActivationLog'))
	
	exec @intResult = [log].[pActivationService] @action = 1, @paramList = @messageActivLog
            , @rowCount = @intRowCount out, @id = @id out

    -- output error result
    set @intResult = case 
        when @errNum > 0 then (-1)*@errNum
        when @errNum = 0 then -1
        else @errNum
        end

end catch;

/*  TEST ZONE
--  select * from [clients].[session];
--  select * from log.error
--  delete log.error where spid is null

--  GET
    --  select newID()
    --  exec clients.pSession @uid = 'B45DDD52-E770-4DF7-9890-3626879E0090'
    --  exec [activationService].[pClientSession_Get] 'B45DDD52-E770-4DF7-9890-3626879E0090'
    
    declare @privateKey binary(596);
    exec [activationService].[pClientSession_Get] 'B45DDD52-E770-4DF7-9890-3626879E0090',  @privateKey OUT
    select @privateKey as privateKey;
    
begin tran    
    
    declare @privateKey binary(596);
    exec [activationService].[pClientSession_Get] '7C47C303-213A-436E-95D7-2B2B350474B7',  @privateKey OUT
    select @privateKey as privateKey;

select * from log.activationService
rollback



--  INSERT and GET
    declare @intResult int, @intRowCount int, @id int;
    declare @privateKey binary(596); set @privateKey = 0x0010; 
    declare @ipAddress varchar(64);  set @ipAddress = '192.168.1.1'; 
    declare @UID uniqueidentifier;   set @UID = newID();
    
    
    set xact_abort on
    begin tran
    
    --  set 
    exec @intResult = [activationService].[pClientSession_Set] 
        @privateKey = @privateKey, @ipAddress = @ipAddress, @UID = @UID
    select @intResult as intResult;
    --  exec clients.pSession  @rowCount = 10;

    --  reset the privateKey
    set @privateKey = null;

    --  get 
    exec @intResult = [activationService].[pClientSession_Get] @UID, @privateKey OUT
    select @intResult as intResult, @privateKey as privateKey;


    rollback
    
*/
--http://www.devtoolshed.com/using-stored-procedures-entity-framework-scalar-return-values
-- я не рак, Entity Framework не даёт возможности получить значение с return;
select @intResult;
--
return @intResult;
END
GO
