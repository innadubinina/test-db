SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[log](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[stackTrace] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
	[message] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
	[source] [nvarchar](max) COLLATE Cyrillic_General_CI_AS NULL,
	[createDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [log].[log] ADD  CONSTRAINT [DF_Log_CreateDate]  DEFAULT (getdate()) FOR [createDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [log].[pLog]
      @action            int = 0x01      -- action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT
    , @id                int = null  out
    , @rowcount          int = 10    out
    
    , @stackTrace        nvarchar(max) = null      
    , @message           nvarchar(max) = null      
    , @source            nvarchar(max) = null      
    , @createDate        datetime = null       -- only for SELECT filtration
as
--  ==================================================================
--  create: 20120806 Tatiana Didenko.
--  modify: 
--  The base routine for the DB error log table '[log].[log]'
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
            set @errMsg = 'delete operation is not supported by the [log].[pLog] stored procedure';
            raiserror (@errMsg , 16, 1)
        end
        ------------------------------------------ </delete operation>


        -- <insert operation>  ---------------------------------------
        if @action & 0x01 != 0
        begin
          
            insert into [log].[log] ([stackTrace], [message], [source])
            values (@stackTrace, @message, @source);

            set @rowcount = @@rowcount;  
            set @id = scope_identity();

            -- delete @tblTemp; 
        end
        ------------------------------------------ </insert operation>



        -- <update operation>  ---------------------------------------
        if @action & 0x04 != 0
        begin
            set @errMsg = 'update operation is not supported by the [log].[pLog] stored procedure';
            raiserror (@errMsg , 16, 1)
        end
        ------------------------------------------ </update operation> 



        -- <select operation>  ---------------------------------------
        if @action & 0x08 != 0
        begin

            declare @sqlParmDefinition nvarchar(max), @sqlFilter nvarchar(max);
            declare @intTotalRecords int;

            set @sqlFilter = N'' +
                case when @id          is null then '' else 'and ([id] = @id)'                  + char (0x0d) end +    
                case when @stackTrace  is null then '' else 'and ([stackTrace] = @stackTrace)'  + char (0x0d) end +    
                case when @message     is null then '' else 'and ([message] = @message)'        + char (0x0d) end +  
                case when @source      is null then '' else 'and ([source] = @source)'          + char (0x0d) end + 
                case when @createDate  is null then '' else 'and ([createDate] = @createDate)'  + char (0x0d) end;

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
                    , [stackTrace]
                    , [message]
                    , [source]
                    , [createDate]
                from [log].[log] '
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

                , @stackTrace        nvarchar(max)    
				, @message           nvarchar(max)      
				, @source            nvarchar(max)    
				, @createDate        datetime
                ';
            -- print @sqlParmDefinition; 

            exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
                , @id = @id
                , @stackTrace = @stackTrace
				, @message = @message
				, @source = @source   
				, @createDate = @createDate
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
  --  select * from [log].[log]

  --  INSERT
  declare @intOutputID int, @intResult int, @id int;
  
    set xact_abort on
    begin tran
		  exec @intResult = [Log].[pLog] @action = 1, @id = @intOutputID out, @stackTrace = 'Test stack Trace', @message = 'test message error', @source = 'internet'
		  select @intOutputID as id  
		  exec [log].[pLog] @action = 8
    rollback
    
  --  SELECT
  exec [Log].[pLog] @action = 8, @rowcount = 10
  
  --  UPDATE
  
  exec [Log].[pLog] @action = 4, @id = 4
  
 --  DELETE
  exec [log].[pLog] @action = 2, @id = 7


*/
return @intResult;
END


GO
