SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clients].[keyType](
	[id] [tinyint] IDENTITY(0,1) NOT NULL,
	[name] [sysname] COLLATE Cyrillic_General_CI_AS NOT NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_ClientsKeyType_CreateDate]  DEFAULT (getdate()),
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
CREATE TABLE [log].[error](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[text] [nvarchar](4000) COLLATE Cyrillic_General_CI_AS NULL,
	[spid] [int] NULL CONSTRAINT [DF_logError_spid]  DEFAULT (@@spid),
	[user] [sysname] COLLATE Cyrillic_General_CI_AS NULL CONSTRAINT [DF_logError_user]  DEFAULT (suser_sname()),
	[number] [int] NULL,
	[message] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_logError_createDate]  DEFAULT (getdate()),
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
CREATE procedure [clients].[pKey]
      @action             int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID                 int = null  out    , @rowcount           int = null  out    , @private varbinary(639) = null  
    , @public  varbinary(164) = null
    , @createDate    datetime = null        -- for select action only
    
    , @typeID         tinyint = null        -- for select action only
as
--  ==================================================================
--  create: 20120829 Mykhaylo Tytarenko
--  modify: 20130222 Mykhaylo Tytarenko. Private (596->635) and Public (148->162) keys expanded. New column TypeID was added
--          20130320 Mykhaylo Tytarenko. Change length of private (from 635 to 639) and public (from 162 to 164) keys and type from binary to varbinary
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations for '[clients].[key]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION Clients_pKey
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [Clients].[Key] where id = @ID
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
		insert [Clients].[Key] ([private], [public], [typeID])
		values (@private, @public, @typeID)
		
		set @rowcount = @@rowcount;
		select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin
        set @errMsg = 'the update operation is not applicable for this table' 
            +  char(0x0d) + char(0x0a) + char(0x09) + '@ID=' + isnull(ltrim(rtrim(cast(@ID as varchar(48)))), 'null')
        raiserror (@errMsg , 16, 1)
    end
    ---------------------------------------------- </update operation> 



    -- <select operation>  -------------------------------------------
    ------------------------------------------------------------------
    if @action & 0x08 != 0
    begin
        declare @sqlText nvarchar(max), @sqlParmDefinition nvarchar(max), @sqlFilter nvarchar(max);
       -- declare @intTotalRecords int;
        
        set @sqlFilter = N'' +
            case when @id         is null then '' else 'and (base.[id] = @id)'                 + char (0x0d) end +    
            case when @private    is null then '' else 'and (base.[private] = @private)'       + char (0x0d) end + 
            case when @public     is null then '' else 'and (base.[public] = @public)'         + char (0x0d) end + 
            case when @typeID     is null then '' else 'and (base.[typeID] = @typeID)'         + char (0x0d) end +             
            case when @createDate is null then '' else 'and (base.[createDate] = @createDate)' + char (0x0d) end ;

        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  base.[id]         as [Key.ID]
                , base.[private]    as [Key.Private]
                , base.[public]     as [Key.Public]
                , base.[typeID]     as [Key.TypeID]
                , base.[createDate] as [Key.CreateDate]
            from [Clients].[Key] base'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by base.id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id               int
            , @rowcount         int  out

            , @private varbinary(639)
            , @public  varbinary(164)
            , @typeID         tinyint
            , @createDate    datetime
            ';
        -- print @sqlParmDefinition;        

        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @private = @private, @public = @public
            , @typeID = @typeID, @createDate = @createDate
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Clients_pKey

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
--  select * from [Clients].[Key]; 
--  select top 10 * from log.error


--  SELECT
    exec [Clients].[pKey] @id=4
    exec [Clients].[pKey] @rowcount = 10


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [Clients].[pKey] @action = 1
        , @private = 0x0702000000A400005253413200040000010001003DC27B0D81046AF01E7FF95084F5BBBB38EC4DB369A8EE344648577BA39B4DDEA4504119DAD6C08976BF4EA62CDE9165A37AF27D6AB3502D8143DA6B1E6680D0CB7BE9EDFE5EF6E600840F307CB9178ACDB41A47939152487554023801F66D9276E564C72944E6B20078C7B4F64FE3FC32FBA4DAA4EE623C56900EB362CC21A9295E29FCDACDCD2B19C161C1938A449FC1416E068E7B970EC6163187A95201E0EFFD69B3F659E4FE4B143E1C1D40E5B0C48B59CD58FE8068A48187D7FB0B50DEF51DAACBAA73B5A7EC41A67DD6A353473841780F18543EDA124718C6260E3315230CAA1A80F2133567CC0BA1B733A078CC72008C44D9E98D6BCC5B6080C4C2C2A94ADA6B3C25360771EFD4CC5938A49764B80AC5E7B4A23F97D90E44D4DD6B6C7AE26901B68DA7740BB7F09E18C379D909D7F81D4C1C0044AD21B6685315BF45BD63D7BFFEA13D78440AB1637DD3238EE48B2B3A513AB76F5BDF1A4681AB0FC143A08B0A90FD1CC405845D55A73731418D4C2CD033CD0A8E2C16AAFC4EE785965C90B9549D6D416CD9FD4A8268BE9C3EC50BA585566047AFD3D3BE14F5C5212F165340957CF9F0EDBADE18E8C418F4F8EB66FA10BA859279652DD595621C220C01296EC8C09A5FF20002611E909F0D057FB842DAEB76ACEFDFFBB2C47542F8DF7553F86C9478A97F08732691F306EF5B463492C3FCD260DB0173D3583FDE2C043BF9D668B897AEED0861624236644638D0FA11E4272E5AC5AE93F6A425CAC48309608080DC129D9092532BA595F9EEE04787A727B22023C2432FDE9AE9BB3522
		, @public  = 0x0702000000A400005253413200040000010001003DC27B0D81046AF01E7FF95084F5BBBB38EC4DB369A8EE344648577BA39B4DDEA4504119DAD6C08976BF4EA62CDE9165A37AF27D6AB3502D8143DA6B1E6680D0CB7BE9EDFE5EF6E600840F307CB9178ACDB41A47939152487554023801F66D9276E564C72944E6B20078C7B4F64FE3FC32FBA4DAA4EE623C56900EB362CC21A9295E29
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [Clients].[pKey]
    rollback

--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [Clients].[pKey] @action = 4
        , @id = 9
        , @private = 0x0702000000A400005253413200040000010001003DC27B0D81046AF01E7FF95084F5BBBB38EC4DB369A8EE344648577BA39B4DDEA4504119DAD6C08976BF4EA62CDE9165A37AF27D6AB3502D8143DA6B1E6680D0CB7BE9EDFE5EF6E600840F307CB9178ACDB41A47939152487554023801F66D9276E564C72944E6B20078C7B4F64FE3FC32FBA4DAA4EE623C56900EB362CC21A9295E29FCDACDCD2B19C161C1938A449FC1416E068E7B970EC6163187A95201E0EFFD69B3F659E4FE4B143E1C1D40E5B0C48B59CD58FE8068A48187D7FB0B50DEF51DAACBAA73B5A7EC41A67DD6A353473841780F18543EDA124718C6260E3315230CAA1A80F2133567CC0BA1B733A078CC72008C44D9E98D6BCC5B6080C4C2C2A94ADA6B3C25360771EFD4CC5938A49764B80AC5E7B4A23F97D90E44D4DD6B6C7AE26901B68DA7740BB7F09E18C379D909D7F81D4C1C0044AD21B6685315BF45BD63D7BFFEA13D78440AB1637DD3238EE48B2B3A513AB76F5BDF1A4681AB0FC143A08B0A90FD1CC405845D55A73731418D4C2CD033CD0A8E2C16AAFC4EE785965C90B9549D6D416CD9FD4A8268BE9C3EC50BA585566047AFD3D3BE14F5C5212F165340957CF9F0EDBADE18E8C418F4F8EB66FA10BA859279652DD595621C220C01296EC8C09A5FF20002611E909F0D057FB842DAEB76ACEFDFFBB2C47542F8DF7553F86C9478A97F08732691F306EF5B463492C3FCD260DB0173D3583FDE2C043BF9D668B897AEED0861624236644638D0FA11E4272E5AC5AE93F6A425CAC48309608080DC129D9092532BA595F9EEE04787A727B22023C2432FDE9AE9BB3522
		, @public  = 0x0702000000A400005253413200040000010001003DC27B0D81046AF01E7FF95084F5BBBB38EC4DB369A8EE344648577BA39B4DDEA4504119DAD6C08976BF4EA62CDE9165A37AF27D6AB3502D8143DA6B1E6680D0CB7BE9EDFE5EF6E600840F307CB9178ACDB41A47939152487554023801F66D9276E564C72944E6B20078C7B4F64FE3FC32FBA4DAA4EE623C56900EB362CC21A9295E29
		, @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [Clients].[pKey]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [Clients].[pKey] @action = 2, @id = 2
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [Clients].[pKey]
    rollback

*/

return @intResult;
END

GO
