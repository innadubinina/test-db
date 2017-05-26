SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[error](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[text] [nvarchar](4000) COLLATE Cyrillic_General_CI_AS NULL,
	[spid] [int] NULL CONSTRAINT [DF_logError_spid]  DEFAULT (@@spid),
	[user] [sysname] COLLATE Cyrillic_General_CI_AS NULL CONSTRAINT [DF_logError_user]  DEFAULT (suser_sname()),
	[number] [int] NULL,
	[message] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_logError_createDate]  DEFAULT (getdate()),
	[test] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
 CONSTRAINT [PK_logError] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[activationService](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[paramList] [xml] NOT NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_logActivationService_createDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_logActivationService] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clients].[keyType](
	[id] [tinyint] IDENTITY(0,1) NOT NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_ClientsKeyType_CreateDate]  DEFAULT (getdate()),
	[name] [sysname] COLLATE Cyrillic_General_CI_AS NOT NULL,
 CONSTRAINT [PK_ClientsKeyType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_ClientsKeyType_Name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clients].[session](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_clientsSession_UID]  DEFAULT (newid()),
	[IPAddress] [varchar](64) COLLATE Cyrillic_General_CI_AS NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_clientsSession_createDate]  DEFAULT (getdate()),
	[keyID] [int] NULL,
 CONSTRAINT [PK_clientsSessions] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_clientsSession_UID] UNIQUE NONCLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clients].[key](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[private] [varbinary](639) NOT NULL,
	[public] [varbinary](164) NOT NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_clientsKey_GetDate]  DEFAULT (getdate()),
	[typeID] [tinyint] NOT NULL CONSTRAINT [DF_clientsKey_TypeID]  DEFAULT ((1)),
 CONSTRAINT [PK_clientsKey] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_clientsKey_Private] UNIQUE NONCLUSTERED 
(
	[private] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_clientsKey_Public] UNIQUE NONCLUSTERED 
(
	[public] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [clients].[fGetSessionByUID] (@UID uniqueidentifier)
returns table with schemabinding
as return
(
    select top 1
          base.[id]
        , [key].[private] as privateKey
        , [key].[typeID]  as keyTypeID
                    
        , base.[IPAddress]
        , base.[createDate]
    from clients.[session] base
        join clients.[key] [key] on [key].[id] = base.keyID
    where base.[uid] = @uid

/*  TEST ZONE
    -- select top 100 * from clients.session
    select * from [clients].[fGetSessionByUID] ('65A4AC3D-A045-434D-AA68-DAAFB0373586')
*/
)

GO
CREATE NONCLUSTERED INDEX [IX_clientSession_CreateDate] ON [clients].[session]
(
	[createDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licenseslicense_groupID] ON [clients].[session]
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [clients].[key]  WITH CHECK ADD  CONSTRAINT [FK_clientsKey_TypeID] FOREIGN KEY([typeID])
REFERENCES [clients].[keyType] ([id])
GO
ALTER TABLE [clients].[key] CHECK CONSTRAINT [FK_clientsKey_TypeID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [log].[pError]
      @action            int = 0x01      -- action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT
    , @id                int = null  out
    , @rowcount          int = 10    out
    
    , @number            int = null      -- error number  (select error_number())
    , @message nvarchar(max) = null      -- error message (select error_message())
    , @spid              int = null      -- only for SELECT filtration (select @@spid)
    , @user          sysname = null      -- only for SELECT filtration (select system_user)
as
--  ==================================================================
--  create: 20120717 Mykhaylo Tytarenko
--  modify: 20120723 Tatiana Didenko. Changed @action=0x08 to @action=0x01
--  NewActivation Project
--  The base routine for the DB error log table '[log].[error]'
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max);

-- declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount 
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  // 
declare @sqlText nvarchar(max);

    begin try

        -- <delete operation>  ---------------------------------------
        if @action & 0x02 != 0
        begin
            set @errMsg = 'delete operation is not supported by the [log].[pError] stored procedure';
            raiserror (@errMsg , 16, 1)
        end
        ------------------------------------------ </delete operation>



        -- <insert operation>  ---------------------------------------
        if @action & 0x01 != 0
        begin
            declare @eventText nvarchar(4000);
            declare @tblTemp table (
                  EventType  nvarchar(30)
                , Parameters int
                , EventInfo  nvarchar(4000)
                );


            if @spid is null
                set @spid = (select @@spid);
            set @sqlText = N'dbcc inputbuffer(' + cast (@spid as varchar(32)) + ') with NO_INFOMSGS';

            insert into @tblTemp exec (@sqlText);
            set @eventText = (select top 1 eventInfo from @tblTemp);

            insert into [log].error ([text], [number], [message])
            values (@eventText, @number, @message);

            set @rowcount = @@rowcount;  
            set @id = scope_identity();

            -- delete @tblTemp; 
        end
        ------------------------------------------ </insert operation>



        -- <update operation>  ---------------------------------------
        if @action & 0x04 != 0
        begin
            set @errMsg = 'update operation is not supported by the [log].[pError] stored procedure';
            raiserror (@errMsg , 16, 1)
        end
        ------------------------------------------ </update operation> 



        -- <select operation>  ---------------------------------------
        if @action & 0x08 != 0
        begin

            declare @sqlParmDefinition nvarchar(max), @sqlFilter nvarchar(max);
            declare @intTotalRecords int;

            set @sqlFilter = N'' +
                case when @id           is null then '' else 'and ([ID] = @id)'           + char (0x0d) end +    
                case when @number       is null then '' else 'and ([Number] = @number)'   + char (0x0d) end +    
                case when @message      is null then '' else 'and ([Message] = @message)' + char (0x0d) end +  
                case when @spid         is null then '' else 'and ([spid] = @spid)'       + char (0x0d) end + 
                case when @user         is null then '' else 'and ([user] = @user)'       + char (0x0d) end;

            if left(@sqlFilter, 3) = N'and'
                set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
            -- print @sqlFilter;

            set @sqlText = N'
                select '

                + case
                    when @rowcount is null then ''
                    else ' top (' + cast (@rowcount as nvarchar(32)) + ')'
                    end
                + ' 
                      [id]
                    , [user]
                    , [number]
                    , [message]
                    , [text]
                    , [spid]
                    , [createDate]
                from [log].[error] '
                + case
                    when @sqlFilter = N'' then ''
                    else '
                where ' + char (0x0d) + @sqlFilter
                    end
                + ' 
                            
                set @rowcount = @@rowcount;
                ';
            -- print @sqlText;


            set @sqlParmDefinition = N'
                  @id                int out
                , @rowcount          int out

                , @number            int
                , @message nvarchar(max)
                , @spid              int
                , @user          sysname
                ';
            -- print @sqlParmDefinition; 

            exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
                , @id = @id
                , @number = @number, @message = @message, @spid = @spid, @user = @user
                , @rowcount = @rowcount out

        end
        ------------------------------------------ </select operation>                


        set @intResult = 0  --  routine success status

    end try



    begin catch
        --  SUPPRESS ERROR MESSAGES FOR ROLLBACK OF OUTER TRANSACTIONS FROM CLIENT WHAT CAUSED TO ERROR:
        --  The current transaction cannot be committed and cannot support operations that write to the log file. Roll back the transaction.
        set @errMsg = 'An error found in error logging routine: ' + error_message();
        --  raiserror (@errMsg , 16, 1)
        print @errMsg;
        set @id = null;
    end catch;


/*  TEST ZONE
  --  select * from [log].[error]

  --  DELETE
  exec [log].[pError] @action = 2, @id = 7

  --  INSERT
  declare @intOutputID int, @intResult int, @number int, @message nvarchar(max)
  select @number  = 235
    , @message = 'Cannot convert a char value to money. The char value has incorrect syntax.'     -- select * from sys.messages where message_id = 235

  exec @intResult = [Log].[pError] @action = 1, @id = @intOutputID out, @number = @number, @message = @message
  select 'Inserted record ID: ' + isnull(ltrim(rtrim(str(@intOutputID))), 'null'), 'Proc execution result: ' + isnull(ltrim(rtrim(str(@intResult))), 'null')  
  
  
 declare @errMsg varchar(max), @errNum int;
 set @errMsg='test'
 set @errNum=10
 
  set xact_abort on
  begin tran
  exec [log].[pError] @number = @errNum, @message = @errMsg
  exec [log].[pError] @action=8
  rollback
  

  --  UPDATE
  exec [Log].[pError] @action = 4, @id = 738

  --  SELECT
  exec [Log].[pError]
  exec [Log].[pError] @spid = @@spid

  --    exec [Log].[pError] @action = 1, @number =  8169, @message = 'Conversion failed when converting from a character string to uniqueidentifier'
*/
return @intResult;
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
