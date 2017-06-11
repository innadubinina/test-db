SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [activationService].[pClientSession_Set]
      @UID     uniqueidentifier
    , @ipAddress     varchar(64) = null

    , @keyTypeID         tinyint = null        --  domain of keyTypes [0=old key; 1=new key]    -- select * from clients.keyType
    , @privateKey varbinary(639) = null OUT
    , @publicKey  varbinary(164) = null OUT
as
--  ==================================================================
--  create: 20120723 Mykhaylo Tytarenko
--  modify: 20120829 Mykhaylo Tytarenko. Encryption keys are returns now from this routine
--  modify: 20130222 Mykhaylo Tytarenko. Private (596->635) and Public (148->162) keys expanded.
--          New column TypeID was added
--  description: 
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @DEBUG     bit;     -- set @DEBUG     = 1;
declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //
declare @sessionID int;
declare @messageActivLog xml, @intRowCount int, @id int;
declare @keyPosition int, @keyID int, @keyPoolSize int;

declare @newKeyStartID int; set @newKeyStartID = 1E5+1;   --    select @newKeyStartID;
--  select * from clients.[key]
--  old keys Private binary(596) and Public binary(148) placed on ID from 1 to 

begin try

-- test1
    if (@trancount > 0) SAVE TRANSACTION aS_pClientSession_Set
    else BEGIN TRAN

    set @keyTypeID = ISNULL(@keyTypeID, 1);

    --  get encription keys
    --  select rand(checksum(newid())) * 9999
    set @keyPoolSize = (select COUNT(*) from clients.[key] where [typeID] = @keyTypeID);
    if @keyPoolSize = 0
    begin
        set @errMsg = 'encription key pool has no key to use'
        raiserror (@errMsg , 16, 1)    
    end

    set @keyPosition = rand(checksum(newid())) * (@keyPoolSize) + 1/* default size of key pool = 9999 */

	print 'test1'
	
    
    set @keyID = (
        select ID from (
            select  row_number() over (order by ID asc) as rowID, [ID] as id
            from clients.[key]
            where [typeID] = @keyTypeID
            ) A
        where rowID = @keyPosition);
    print @keyPosition;
    print @keyID;

    --  DEBUG
    if @DEBUG = 1 select @keyID as keyID;
    --  \DEBUG
    
    select @privateKey = [private], @publicKey = [public] from clients.[key] where ID = @keyID;

    --  DEBUG
    if @DEBUG = 1 select @privateKey as privateKey;
    --  \DEBUG

    if @privateKey is not null
    begin
        exec @intResult = [clients].[pSession] @action = 1, @privateKey = @privateKey, @IPAddress = @ipAddress, @UID = @UID OUT
            , @id = @sessionID out

        if @intResult != 0
        begin
            set @errMsg = 'Internal error calling [clients].[pSession] routine. Param list: ' +
                CHAR(0x0d) + CHAR(0x09) + '- @action = 1,' +
                CHAR(0x0d) + CHAR(0x09) + '- @privateKey = ' + isnull(convert(varchar(1282),@privateKey, 1), 'null') + ',' +
                CHAR(0x0d) + CHAR(0x09) + '- @IPAddress = ' + isnull(cast(@ipAddress as nvarchar(64)), 'null')
            raiserror (@errMsg , 16, 1);                
        end
        else
        begin
            set @messageActivLog = (
                select 'New client session inserted' as [Message]
                    , isnull(cast(@UID as nvarchar(48)), 'null')        as [UID]
                    , isnull(convert(varchar(1282),@privateKey, 1), 'null') as [privateKey]
                    , isnull(convert(varchar(330),@publicKey, 1), 'null')  as [publicKey]
                    , isnull(cast(@ipAddress as nvarchar(64)), 'null')  as [ipAddress]
                for xml raw('ActivationLog')
                );


            exec @intResult = [log].[pActivationService] @action = 1, @paramList = @messageActivLog
                , @rowCount = @intRowCount out, @id = @id out
        end            
        
    end
    else
    begin
        set @errMsg = 'encription key is empty'
        raiserror (@errMsg , 16, 1)    
    end        


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION aS_pClientSession_Set

    set @privateKey = null;
    set @publicKey  = null;

    select @errNum = error_number(), @errMsg = error_message();
    if xact_state() <> -1 exec [log].[pError] @number = @errNum, @message = @errMsg, @spid = @@spid
    print @errMsg;
    --print @sqlText;
             
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


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    declare @privateKey binary(635), @publicKey  binary(162);
    declare @ipAddress varchar(64);  --set @ipAddress = '121.168.1.1'; 
    declare @UID uniqueidentifier;   set @UID = newID();
    
    
    set xact_abort on
    begin tran
    exec @intResult = [activationService].[pClientSession_Set] 
          @UID = @UID, @ipAddress = @ipAddress
        , @keyTypeID = 1
        , @privateKey = @privateKey OUT, @publicKey = @publicKey OUT
    select @intResult as intResult, @privateKey as privateKey, @publicKey as publicKey;
    -- exec clients.pSession  @rowCount = 10;
    -- select top 10 * from log.activationService
    
    exec [activationService].[pClientSession_Get] @UID = @UID, @privateKey = @privateKey OUT
    rollback
    
    
*/
--http://www.devtoolshed.com/using-stored-procedures-entity-framework-scalar-return-values
-- я не рак, Entity Framework не даёт возможности получить значение с return;
select @intResult;
--
return @intResult;
END
GO
