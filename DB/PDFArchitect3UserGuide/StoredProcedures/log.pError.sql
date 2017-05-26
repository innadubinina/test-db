SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[error](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[text] [nvarchar](4000) COLLATE Cyrillic_General_CI_AS NULL,
	[spid] [int] NOT NULL,
	[user] [sysname] COLLATE Cyrillic_General_CI_AS NOT NULL,
	[createDate] [datetime] NOT NULL,
	[number] [int] NULL,
	[message] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
 CONSTRAINT [PK_logError] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [log].[error] ADD  CONSTRAINT [DF_logError_spid]  DEFAULT (@@spid) FOR [spid]
GO
ALTER TABLE [log].[error] ADD  CONSTRAINT [DF_logError_user]  DEFAULT (suser_sname()) FOR [user]
GO
ALTER TABLE [log].[error] ADD  CONSTRAINT [DF_logError_createDate]  DEFAULT (getdate()) FOR [createDate]
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
--  create: 20120806 Tatiana Didenko
--  modify: 
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
 begin tran
  declare @intOutputID int, @intResult int, @number int, @message nvarchar(max)
  select @number  = 235
    , @message = 'Cannot convert a char value to money. The char value has incorrect syntax.'     -- select * from sys.messages where message_id = 235

  exec @intResult = [Log].[pError] @action = 1, @id = @intOutputID out, @number = @number, @message = @message
  select 'Inserted record ID: ' + isnull(ltrim(rtrim(str(@intOutputID))), 'null'), 'Proc execution result: ' + isnull(ltrim(rtrim(str(@intResult))), 'null')  
  select * from [log].[error]
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
