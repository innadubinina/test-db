/****** Cannot script Unresolved Entities : Server[@Name='SCTFS']/Database[@Name='T']/UnresolvedEntity[@Name='value' and @Schema='C'] ******/
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
CREATE TABLE [licenses].[license](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[groupID] [int] NOT NULL,
	[key] [varchar](64) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[readyForActivation] [bit] NOT NULL CONSTRAINT [DF_licensesLicense_readyForActivation]  DEFAULT ((0)),
	[deactivated] [bit] NOT NULL CONSTRAINT [DF_licensesLicense_deactivated]  DEFAULT ((0)),
	[allowedActivationCount] [int] NULL,
	[lifeTimeDays] [int] NULL,
	[serverActivationCount] [int] NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesLicense_createDate]  DEFAULT (getdate()),
	[modifyDate] [datetime] NULL,
	[history] [xml] NULL,
 CONSTRAINT [PK_licenses] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_licensesLicense_license] UNIQUE NONCLUSTERED 
(
	[key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [products].[group](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[name] [varchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[description] [nvarchar](256) COLLATE Cyrillic_General_CI_AS NULL,
	[externalID] [int] NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_productsGroup_createDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_productsGroup] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_productsGroup_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [security].[users](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Name] [nvarchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[Password] [nvarchar](50) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_Users_CreateDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_Users_IsActive]  DEFAULT ((1)),
	[IsAdmin] [bit] NOT NULL CONSTRAINT [DF_Users_IsAdmin]  DEFAULT ((0)),
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [products].[product](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[name] [varchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[title] [varchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[description] [nvarchar](256) COLLATE Cyrillic_General_CI_AS NULL,
	[groupID] [int] NULL CONSTRAINT [DF_product_groupID]  DEFAULT ((0)),
	[disabled] [bit] NOT NULL CONSTRAINT [DF_product_disabled]  DEFAULT ((0)),
	[hasLifetime] [bit] NOT NULL CONSTRAINT [DF_product_hasLifetime]  DEFAULT ((0)),
	[externalID] [int] NULL,
	[createDate] [datetime] NULL CONSTRAINT [DF_product_createDate]  DEFAULT (getdate()),
	[isFree] [bit] NOT NULL CONSTRAINT [DF_product_isFree]  DEFAULT ((0)),
 CONSTRAINT [PK_product] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_product_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_product_title] UNIQUE NONCLUSTERED 
(
	[title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [licenses].[group](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[userID] [int] NOT NULL,
	[productID] [int] NOT NULL,
	[licenseCount] [int] NOT NULL CONSTRAINT [DF_licensesGroup_LicenseCount]  DEFAULT ((10)),
	[allowedActivationCount] [int] NOT NULL,
	[lifeTimeDays] [int] NULL,
	[serverActivationCount] [int] NULL,
	[resellerName] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NULL,
	[readyForActivation] [bit] NOT NULL CONSTRAINT [DF_licensesGroup_readyForActivation]  DEFAULT ((0)),
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesGroup_createDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_licensesGroup] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_licenseslicense_groupID] ON [licenses].[license]
(
	[groupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_Name_Users] ON [security].[users]
(
	[Name] ASC,
	[IsActive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Licensesgroup_productID] ON [licenses].[group]
(
	[productID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Licensesgroup_userID] ON [licenses].[group]
(
	[userID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [products].[product]  WITH CHECK ADD  CONSTRAINT [FK_product_groupID] FOREIGN KEY([groupID])
REFERENCES [products].[group] ([id])
GO
ALTER TABLE [products].[product] CHECK CONSTRAINT [FK_product_groupID]
GO
ALTER TABLE [licenses].[group]  WITH CHECK ADD  CONSTRAINT [FK_licensesGroup_productID] FOREIGN KEY([productID])
REFERENCES [products].[product] ([id])
GO
ALTER TABLE [licenses].[group] CHECK CONSTRAINT [FK_licensesGroup_productID]
GO
ALTER TABLE [licenses].[group]  WITH CHECK ADD  CONSTRAINT [FK_licensesGroup_userID] FOREIGN KEY([userID])
REFERENCES [security].[users] ([Id])
GO
ALTER TABLE [licenses].[group] CHECK CONSTRAINT [FK_licensesGroup_userID]
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
CREATE procedure [activationService].[pLicenseGroup_Set]
      @userID                  int
    , @productID               int
    , @lifeTimeDays            int
    , @resellerName  nvarchar(256)

    , @readyForActivation      bit = 1
    , @allowedActivationsCount int = 1000
    , @serverActivationCount   int = 100

    , @keyList                 xml
as
--  ==================================================================
--  Create: 20120725 Mykhaylo Tytarenko
--  Modify: 
--  Description: 'licenses.license', 'licenses.group'
--  ==================================================================BEGIN
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  // 
create table #tblList (
	  ID int identity(1,1) primary key
	, [key] nvarchar(64)
);
create nonclustered index [IX_#tblList_key] on #tblList ([key] asc)

declare @listRowcount  int;
declare @existRowcount int; declare @existRowValues nvarchar (max);

declare @licenseGroupID int;

begin try


    if @keyList is not null
    begin
        --  XML list parsing
        insert #tblList ([key])
        select nullif(ltrim(rtrim( T.C.value('./@LicenseKey', 'nvarchar(64)') )), '')  as [key]
        from @keyList.nodes('ArrayOfLicenseKey/LicenseKey') as T(C)
        
        --  select * from #tblList;

        set @listRowcount = @@rowcount;
        
        if @listRowcount = 0
        begin
            set @errMsg = N'50017. No license was passed to store'
            raiserror (@errMsg , 16, 1)
        end
    end  

    if (@@trancount = 0) BEGIN TRAN

    if @keyList is not null
    begin
        --  exists row move to error log. Error exeption not generated.
        if exists (
            select 1
            from #tblList source
                join licenses.license destin on destin.[key] = source.[key]
            )
        begin
            set @existRowValues = '';
            select @existRowValues = @existRowValues + isnull(source.[key], N'NULL') + '; '
            from #tblList source
                join licenses.license destin on destin.[key] = source.[key]

            set @existRowcount = @@rowcount;
            set @existRowValues = 'List of already exists licenceNumbers (total = ' + rtrim(ltrim(str(@existRowcount))) + '): ' + @existRowValues;

            print @existRowValues;

            insert log.error (text, number, message)
            values ('50016. Some licenceNumbers already presents in target table', 16, @existRowValues);
        end
        
        		
		--  insert licenses.[group] ([UserID], [ProductID], [Reseller], [CreateDate])
		insert licenses.[group] (userID, productID, licenseCount, allowedActivationCount, lifeTimeDays, serverActivationCount, resellerName, readyForActivation)
		select @userID, @productID, @listRowcount, @allowedActivationsCount, @lifeTimeDays, @serverActivationCount, @resellerName, @readyForActivation;
		set @licenseGroupID = scope_identity();
		
        --  insert logic: insert rows not exists in base table, exists rows not update
        insert licenses.license ([key], groupID, readyForActivation)
        select source.[key], @licenseGroupID, @readyForActivation
        from #tblList source
            left join licenses.license destin on destin.[key] = source.[key]
        where destin.[key] is null

    end            

    if @trancount = 0 and @@trancount > 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 and @@trancount > 0 ROLLBACK TRANSACTION
    select @errNum = error_number(), @errMsg = error_message();
    print @errMsg;
    
    exec [Log].[pError] @action = 1, @number = @errNum, @message = @errMsg
    set @intResult = case 
        when @errNum > 0 and isnumeric(left(@errMsg, 5)) = 1 then (-1)* cast(left(@errMsg, 5) as int)
        when @errNum = 0 then -1 
        else (-1)*@errNum 
        end

end catch;

drop table #tblList
      
                   
/*  TEST ZONE
  --  select * from licenses.license;
  --  select top 10 * from log.Error order by ID desc;
  -- select top 10 * from [Security].Users
  -- select top 10 * from products.Product
  -- select top 10 * from Report.LicenseDownloads
  
  begin tran

	  declare @intResult int;
	  exec @intResult = [activationService].[pLicenseGroup_Set]
    	  @keyList = '
        <ArrayOfLicenseNumber>
          <LicenseNumber LicenseNumber="T6EZ84BB3KA4E2G4YSGWQYEDG" /> 
          </ArrayOfLicenseNumber>
		'
        , @userID                  = 2
        , @productID               = 0
        , @lifeTimeDays            = 365
        , @resellerName            = 'Deutchland'


	  select @intResult;
	  --    select * from licenses.license where [key] = 'T6EZ84BB3KA4E2G4YSGWQYEDG'
  
  rollback tran


 int? result = pLicenseGroup_Set(group.userID, group.productID, license.lifeTimeDays, group.resellerName, group.readyForActivation, license.allowedActivationCount, license.serverActivationCount, xml).Fetch<int?>();
[16:55:14] megazverxxx:  int? result = pLicenseGroup_Set(1, 0, null, "zver", true, 3, null, xml).Fetch<int?>();
  
    
*/
--http://www.devtoolshed.com/using-stored-procedures-entity-framework-scalar-return-values
-- я не рак, Entity Framework не даёт возможности получить значение с return;
select @intResult;
--
return @intResult;
END

GO
