SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function clients.fCheckEmailValidity (@email nvarchar(128))
returns bit 
as
BEGIN
    return case when @email like '%_@_%.__%' then 1 else 0 end  
END
/*  TEST ZONE
    select clients.fCheckEmailValidity ('dddss')
    select clients.fCheckEmailValidity ('1@c.qu')

*/
GO
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
CREATE TABLE [clients].[client](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_client_UID]  DEFAULT (newid()),
	[email] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[firstName] [nvarchar](100) COLLATE Cyrillic_General_CI_AS NULL,
	[lastName] [nvarchar](100) COLLATE Cyrillic_General_CI_AS NULL,
	[isValidEmail] [bit] NOT NULL CONSTRAINT [DF_client_isValidEmail]  DEFAULT ((1)),
	[optIn] [bit] NOT NULL CONSTRAINT [DF_client_optIn]  DEFAULT ((1)),
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_client_createDate]  DEFAULT (getdate()),
	[history] [xml] NULL,
	[ipAddress] [varchar](330) COLLATE Cyrillic_General_CI_AS NULL,
	[languageISO2] [char](2) COLLATE Cyrillic_General_CI_AS NULL,
 CONSTRAINT [PK_client] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_client_email] UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

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
CREATE procedure [clients].[pClient]
      @action              int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT
    , @ID                  int = null  out
    , @rowcount            int = null  out

    , @UID    uniqueidentifier = null  
    , @email     nvarchar(128) = null
    , @firstName nvarchar(100) = null
    , @lastName  nvarchar(100) = null
    , @isValidEmail        bit = null        -- for select action only
    , @optIn               bit = null
    , @createDate     datetime = null        -- for select action only

    , @ipAddress  varchar(330) = null
    , @languageISO2    char(2) = null

as
--  ==================================================================
--  create: 20120725 Tatiana Didenko
--  modify: 20120801 Tatiana Didenko 1) delete parameters: '@userNameLC', '@domain'.
--                                   2) added using clients.fCheckEmailValidity function for set @isValidEmail
--          20130129 Mykhaylo Tytarenko. New fields ipAddress and languageISO2 in the base entity
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations for '[clients].[client]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION Clients_pClient
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [clients].[client] where id = @ID
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
        set @isValidEmail = (select clients.fCheckEmailValidity(@email))

        -- <base table insert> -----------------------------
        if @UID is not null
        begin
            insert [clients].[client] ([UID],[email],[firstName],[lastName],[isValidEmail],[optIn], [ipAddress], [languageISO2])
            values (@UID, @email, @firstName, @lastName, @isValidEmail, @optIn, @ipAddress, @languageISO2)
        end
        else
        begin
            -- UID is generated by default
            insert [clients].[client] ([email],[firstName],[lastName],[isValidEmail],[optIn], [ipAddress], [languageISO2])
            values (@email, @firstName, @lastName, @isValidEmail, @optIn, @ipAddress, @languageISO2)
        end 
        
            set @rowcount = @@rowcount;
            select @ID = scope_identity();
        ------------------------------- </base table insert>

    
    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin
        
        set @isValidEmail = (select clients.fCheckEmailValidity(@email))

        -- <base table update> -----------------------------
        update [clients].[client]
        set [email] = @email, [firstName] = @firstName, [lastName] = @lastName
            , [isValidEmail] = @isValidEmail, [optIn] = @optIn, [ipAddress] = @ipAddress, [languageISO2] = @languageISO2
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
            case when @id           is null then '' else 'and ([id] = @id)'                     + char (0x0d) end +
            case when @UID          is null then '' else 'and ([UID] = @UID)'                   + char (0x0d) end +
            case when @email        is null then '' else 'and ([email] = @email)'               + char (0x0d) end +
            case when @firstName    is null then '' else 'and ([firstName] = @firstName)'       + char (0x0d) end +
            case when @lastName     is null then '' else 'and ([lastName] = @lastName)'         + char (0x0d) end +
            case when @isValidEmail is null then '' else 'and ([isValidEmail] = @isValidEmail)' + char (0x0d) end +
            case when @optIn        is null then '' else 'and ([optIn] = @optIn)'               + char (0x0d) end +
            case when @createDate   is null then '' else 'and ([createDate] = @createDate)'     + char (0x0d) end +
            case when @ipAddress    is null then '' else 'and ([ipAddress] = @ipAddress)'       + char (0x0d) end +
            case when @languageISO2 is null then '' else 'and ([languageISO2] = @languageISO2)' + char (0x0d) end;

        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  [id]           as [Client.ID]
                , [UID]          as [Client.UID]
                , [email]        as [Client.Email]
                , [firstName]    as [Client.FirstName]
                , [lastName]     as [Client.LastName]
                , [isValidEmail] as [Client.IsValidEmail]
                , [optIn]        as [Client.OptIn]
                , [createDate]   as [Client.CreateDate]
                , [ipAddress]    as [Client.IPAddress]
                , [languageISO2] as [Client.LanguageISO2]

            from [clients].[client]'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id                  int
            , @rowcount            int  out

            , @UID    uniqueidentifier
            , @email     nvarchar(128)
            , @firstName nvarchar(100)
            , @lastName  nvarchar(100)
            , @isValidEmail        bit
            , @optIn               bit
            , @createDate     datetime

            , @ipAddress  varchar(330)
            , @languageISO2    char(2)
            
            ';
        -- print @sqlParmDefinition;        

        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @UID = @UID, @email = @email, @firstName = @firstName, @lastName = @lastName, @isValidEmail = @isValidEmail
            , @optIn = @optIn, @createDate = @createDate, @ipAddress = @ipAddress, @languageISO2 = @languageISO2
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Clients_pClient

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
--  select * from [clients].[client]; 
--  select top 10 * from log.error


--  SELECT
    exec [clients].[pClient] @id=4
    exec [clients].[pClient] @rowcount = 10


--  INSERT
declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [clients].[pClient] @action = 1, @UID = 'DBC21343-EE89-400B-9226-F20A4AE9AA86', @email = 'test@y', @firstName = 'TEST1', @lastName = 'TEST2'
        , @isValidEmail = 1, @optIn = 1
        , @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pClient]
    rollback

--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [clients].[pClient] @action = 4, @id = 9, @UID = 'DBC21343-EE89-400B-9226-F20A4AE9AA86', @email = 'test222@ya.ru', @firstName = 'TESTFirst', @lastName = 'TESTLast'
        , @isValidEmail = 1, @optIn = 0
        , @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pClient]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [clients].[pClient] @action = 2, @id = 9
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pClient]
    rollback

*/

return @intResult;
END

GO
