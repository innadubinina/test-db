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
CREATE TABLE [clients].[system](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_clientsSystem_UID]  DEFAULT (newid()),
	[machineKey] [uniqueidentifier] NOT NULL,
	[motherboardKey] [varchar](128) COLLATE Cyrillic_General_CI_AS NULL,
	[physicalMAC] [varchar](128) COLLATE Cyrillic_General_CI_AS NULL,
	[clientID] [int] NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesActivation_createDate]  DEFAULT (getdate()),
	[isAutogeneratedMachineKey] [bit] NOT NULL DEFAULT ((0)),
 CONSTRAINT [PK_clientsSystem] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [licenses].[activation](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[licenseID] [int] NOT NULL,
	[systemID] [int] NOT NULL,
	[parentID] [int] NULL,
	[count] [int] NOT NULL CONSTRAINT [DF_licensesActivation_count]  DEFAULT ((0)),
	[endDate] [datetime] NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_licensesActivation_createDate]  DEFAULT (getdate()),
	[modifyDate] [datetime] NULL,
	[history] [xml] NULL,
 CONSTRAINT [PK_licensesActivation] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION licenses.fActivationTie (@activationID int)
RETURNS TABLE
AS RETURN
(
 with cteChildTie (ID, parentID, level) as (
    select ID, parentID, 0 as level
    from licenses.activation
    where ID  = @activationID
    
    union all
    select act.ID, act.parentID, child.level + 1 as level
    from licenses.activation act
        join cteChildTie child on child.parentID = act.ID
    ),
  cteParentTie (ID, parentID, level) as (
    select ID, parentID, 0 as level
    from licenses.activation
    where ID  = @activationID
    
    union all
    select act.ID, act.parentID, parent.level - 1 as level
    from licenses.activation act
        join cteParentTie parent on parent.ID = act.parentID
    )
select ID, parentID, level from cteChildTie
union
select ID, parentID, level from cteParentTie
)

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [licenses].[vLicense] with schemabinding
as
--  ==================================================================
--  create: 20120725 Mykhaylo Tytarenko 
--  modify:
--  description: provide access to license attributes, stored in 'licenses.group' table.
--  '[licenses].[license]' table
--  ==================================================================
select
      base.id
    , base.groupID
    , base.[key]
    , base.readyForActivation
    , base.deactivated

    , coalesce(base.allowedActivationCount, gr.allowedActivationCount) [allowedActivationCount]
    , coalesce(base.lifeTimeDays, gr.lifeTimeDays)                     [lifeTimeDays]
    , coalesce(base.serverActivationCount, gr.serverActivationCount)   [serverActivationCount]
	, 'test' as test
    , base.createDate
    , base.modifyDate
    , base.history
from  licenses.license base
    join licenses.[group] gr on gr.id = base.groupID

/*  TEST ZONE
--  select * from licenses.license
--  select * from licenses.vLicense
*/



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
CREATE NONCLUSTERED INDEX [clientsSystem_machineKey] ON [clients].[system]
(
	[machineKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_clientsSystem_clientID] ON [clients].[system]
(
	[clientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
CREATE UNIQUE NONCLUSTERED INDEX [UNIQ_clientsSystem_systemKeys] ON [clients].[system]
(
	[physicalMAC] ASC,
	[machineKey] ASC,
	[motherboardKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_createDate] ON [licenses].[activation]
(
	[createDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_licenseID] ON [licenses].[activation]
(
	[licenseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_modifyDate] ON [licenses].[activation]
(
	[modifyDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_parentID] ON [licenses].[activation]
(
	[parentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_licensesActivation_systemID] ON [licenses].[activation]
(
	[systemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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
ALTER TABLE [clients].[system]  WITH CHECK ADD  CONSTRAINT [FK_clientsSystem_clientID] FOREIGN KEY([clientID])
REFERENCES [clients].[client] ([id])
GO
ALTER TABLE [clients].[system] CHECK CONSTRAINT [FK_clientsSystem_clientID]
GO
ALTER TABLE [licenses].[activation]  WITH CHECK ADD  CONSTRAINT [FK_licensesActivation_licenseID] FOREIGN KEY([licenseID])
REFERENCES [licenses].[license] ([id])
GO
ALTER TABLE [licenses].[activation] CHECK CONSTRAINT [FK_licensesActivation_licenseID]
GO
ALTER TABLE [licenses].[activation]  WITH CHECK ADD  CONSTRAINT [FK_licensesActivation_parentID] FOREIGN KEY([parentID])
REFERENCES [licenses].[activation] ([id])
GO
ALTER TABLE [licenses].[activation] CHECK CONSTRAINT [FK_licensesActivation_parentID]
GO
ALTER TABLE [licenses].[activation]  WITH CHECK ADD  CONSTRAINT [FK_licensesActivation_systemID] FOREIGN KEY([systemID])
REFERENCES [clients].[system] ([id])
GO
ALTER TABLE [licenses].[activation] CHECK CONSTRAINT [FK_licensesActivation_systemID]
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [activationService].[pLicense_Activate_OLD20120910]
    --  main license to activate
      @licenseKey      varchar(64)
    
    --  client system attributes
    , @machineKey uniqueidentifier 
    , @motherboardKey varchar(128)
    , @physicalMAC    varchar(128)
    , @isAutogeneratedMachineKey bit
    
    --  previous license (old license key if need)
    , @oldLicenseKey   varchar(64) = null
    
    , @endDate            datetime = null OUT
    , @serverActivationCount   int = null OUT
as
--  ==================================================================
--  Create: 20120724,25 Mykhaylo Tytarenko 
--  Modify: 20120801 Tatiana Didenko. 1) Updated endDate for the chain of old activation licenses.
--                                    2) Added the @isAutogeneratedMachineKey parameter
--  Description: 'licenses.license', 'licenses.activation'
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  // 
declare @licenseID    int; set @licenseID    = (select ID from licenses.license where [key] = @licenseKey);
declare @oldLicenseID int; set @oldLicenseID = (select ID from licenses.license where [key] = @oldLicenseKey);


declare @dtLicenseEndDate datetime;
declare @dtNow datetime; set @dtNow = (select getdate());

declare @activationID int, @systemID int; 
declare @oldActivationID int; 

--  license attributes 
declare @allowedActivationCount int, @readyForActivation bit, @deactivated bit;
declare @activationCount int;

begin try

    if @licenseID is null
    begin
        set @errMsg = N'50001. Given license <' + ltrim(rtrim(ISNULL(@licenseKey, 'null'))) + '> is not exists in the license pool'
        raiserror (@errMsg , 16, 1)
    end    

    if @oldLicenseID is null and @oldLicenseKey is not null
    begin
        set @errMsg = N'50002. Given old license <' + ltrim(rtrim(ISNULL(@oldLicenseKey, 'null'))) + '> is not exists in the license pool'
        raiserror (@errMsg , 16, 1)
    end   

    --  get exists activation for this client
    set @systemID = (select ID from clients.system where machineKey = @machineKey and isnull(motherboardKey, '') = isnull (@motherboardKey, '') and isnull(physicalMAC, '') = isnull(@physicalMAC, ''));
    set @activationID = (select ID from licenses.activation where licenseID = @licenseID and systemID = @systemID);

    if @oldLicenseID is not null
    begin
        set @oldActivationID = (select ID from licenses.activation where licenseID = @oldLicenseID and systemID = @systemID);
    end

    --  cheat :)
    if @oldLicenseID is not null and @licenseID is not null
        and @oldActivationID is not null and @activationID is not null
    begin
        set @errMsg = N'50007. The licenses, <' + ltrim(rtrim(ISNULL(@licenseKey, 'null'))) + '> and <'  + ltrim(rtrim(ISNULL(@oldLicenseKey, 'null'))) + '> are already activated on this system (already merged)'
        raiserror (@errMsg , 16, 1)       
    end
    

    if @activationID is null
    begin

        --  system entity
        if @systemID is null
            exec @intResult = clients.pSystem @action = 1, @machineKey = @machineKey, @motherboardKey = @motherboardKey, @physicalMAC = @physicalMAC, @isAutogeneratedMachineKey = @isAutogeneratedMachineKey
                , @ID = @systemID OUT
        
        set @activationCount = (select COUNT(*) from licenses.activation where licenseID = @licenseID);
        
        --  license entity
        select @allowedActivationCount = allowedActivationCount
            , @readyForActivation      = [readyForActivation] 
            , @deactivated             = [deactivated]
            , @serverActivationCount   = [serverActivationCount]
        from licenses.vLicense
        where ID = @licenseID

        if @activationCount >= @allowedActivationCount
        begin
            set @errMsg = N'50003. The number of available activations for this license <' + ltrim(rtrim(ISNULL(@licenseKey, 'null'))) + '> is exceeded'
            raiserror (@errMsg , 16, 1)
        end

        if @readyForActivation != 1
        begin
            set @errMsg = N'50004. Given license <' + ltrim(rtrim(ISNULL(@licenseKey, 'null'))) + '> is not ready for activation'
            raiserror (@errMsg , 16, 1)
        end

        if @deactivated = 1
        begin
            set @errMsg = N'50005. Given license <' + ltrim(rtrim(ISNULL(@licenseKey, 'null'))) + '> was deactivated'
            raiserror (@errMsg , 16, 1)
        end


        --  --------------------------------------------------------------
        --  MERGE
        --  --------------------------------------------------------------
        if @oldLicenseID is not null
        begin
            --  precondidtions to merge
            --  1. old key is active
            if  not exists (select * from licenses.license where ID = @oldLicenseID and deactivated != 1)
                or
            --  2. new key is valid (is active and allowed activation count > 0)
                not exists (
                    select * from licenses.vLicense where ID = @licenseID and deactivated != 1
                        and allowedActivationCount> (select COUNT(*) from licenses.activation where LicenseID = @licenseID)
                    )
                --  or
            --  3. new key not linked to this client already
                --  alredy checked
                --  exists (select * from ActivationProcess.Activations where LicenseNumberID = @licenseNumberID and ClientId = @clientId)
            goto lblExit;

            --  key merging
            set @dtLicenseEndDate = (select endDate from licenses.activation where id = @oldActivationID);
            --  select @dtLicenseEndDate as dtLicenseEndDate;

            if @dtLicenseEndDate is null
                set @dtLicenseEndDate = (
                select dateadd(dd, (select [lifetimeDays] from licenses.vLicense where ID = @oldlicenseID), createDate)
                from licenses.activation
                where ID = @oldActivationID
                )                
            --  select @dtLicenseEndDate as dtLicenseEndDate;
                
            if (@dtLicenseEndDate < @dtNow) or (@dtLicenseEndDate is null)
                set @dtLicenseEndDate = @dtNow
            --  select @dtLicenseEndDate as dtLicenseEndDate;
            
            set @dtLicenseEndDate = dateadd(dd, (select [lifetimeDays] from licenses.vLicense where ID = @licenseID), @dtLicenseEndDate)
            --  select @dtLicenseEndDate as dtLicenseEndDate;

            if (@@trancount = 0) BEGIN TRAN trnASSetActivationStatus

            --  insert activation record for new key                
            insert licenses.activation (licenseID, parentID, systemID, createDate, endDate)
            select @licenseID, @oldActivationID, @systemID, GETDATE(), @dtLicenseEndDate
            --  // key merging
            set @activationID = SCOPE_IDENTITY();

            --  update activation record for ald key: set new EndDate for old activation
            -- if Lifetime is null, then update activation records for the chain of old keys: set new EndDate for for the chain of old activations
            if @dtLicenseEndDate is not null
            begin
				update licenses.activation
				set endDate = @dtLicenseEndDate
				where ID in (select ID from [licenses].[fActivationTie] (@activationID) where ID!=@activationID)
            end
            
        end
        --  --------------------------------------------------------------
        --  /MERGE
        --  --------------------------------------------------------------
        else    --  if @oldLicenseNumberID is null
        --  --------------------------------------------------------------
        --  ONE KEY
        --  --------------------------------------------------------------
        begin
            ----  get exists activation for this client
            ----set @activationID = (select ID from ActivationProcess.Activations where LicenseNumberID = @licenseNumberID and ClientId = @clientId);
            --if @activationID is null
            --begin
            set @dtLicenseEndDate = @dtNow;   
            set @dtLicenseEndDate = dateadd(dd, (select [lifetimeDays] from  licenses.vLicense where ID = @licenseID), @dtLicenseEndDate)

            if (@@trancount = 0) BEGIN TRAN trnASSetActivationStatus
                
            insert licenses.activation (licenseID, parentID, systemID, createDate, endDate)
            select @licenseID, @oldActivationID, @systemID, GETDATE(), @dtLicenseEndDate
            set @activationID = SCOPE_IDENTITY();
            --end
        end

    end --  of <if @activationID is null> clause
    else    
    --  if @activationID is not null - license for this system already exists
    begin
        set @dtLicenseEndDate = (select endDate from licenses.activation where ID = @activationID);
        if @dtLicenseEndDate < @dtNow
        begin
            set @errMsg = N'50006. The license <' + ltrim(rtrim(ISNULL(@licenseKey, 'null'))) + '> has expired'
            raiserror (@errMsg , 16, 1)       
        end
    end
    
    
    if @dtLicenseEndDate is null
        set @dtLicenseEndDate = (select EndDate from licenses.activation where ID = @activationID);
    if @dtLicenseEndDate is null
        set @dtLicenseEndDate = (
            select dateadd(dd, lc.lifetimeDays, act.createDate) as LicenseEndDate
            from licenses.activation act
                join licenses.vLicense lc on act.licenseID = lc.id
            where act.ID = @activationID
            );
   
    --  set @daysToLicenseEndDate = datediff(dd, @dtToday, @dtLicenseEndDate);
    set @endDate = @dtLicenseEndDate;


    ----  update activation count
    if (@@trancount = 0) BEGIN TRAN trnASSetActivationStatus;
    
    update licenses.activation
    set
          count = count + 1
        , modifyDate = GETDATE()
    where ID = @activationID
    

lblExit:
	
	
    if @trancount = 0 and @@trancount > 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 and @@trancount > 0 ROLLBACK TRANSACTION trnASSetActivationStatus
    select @errNum = error_number(), @errMsg = error_message();

    print @errMsg;
    exec [Log].[pError] @action = 1, @number = @errNum, @message = @errMsg
    set @intResult = case 
        when @errNum > 0 and isnumeric(left(@errMsg, 5)) = 1 then (-1)* cast(left(@errMsg, 5) as int)
        when @errNum = 0 then -1 
        else (-1)*@errNum 
        end

end catch;

      
                   
/*  TEST ZONE
--  select top 10 * from licenses.license where id = 650020;
--  select top 10 * from licenses.activation where endDate < getdate();
  
begin tran

--  declare @intResult int, @daysToLicenseEndDate int;
--  select newid()

declare @intResult int, @licenseEndDate datetime, @serverActivationCount int;
exec @intResult = [activationService].[pLicense_Activate]
    --  main license to activate
      @licenseKey = 'RN2S4TAS6DSMQGZ2R4M6PRN4K'
    
    --  client system attributes
    , @machineKey = '10CF59E1-853D-46E6-825C-77337014AA3E'
    , @motherboardKey = 'IST19'
    , @physicalMAC    = null
    , @isAutogeneratedMachineKey = 1
    , @oldLicenseKey = 'BXX9Q7AMB6ZY3DA9H2MT8HFUM'
    
    , @endDate = @licenseEndDate OUT
    , @serverActivationCount = @serverActivationCount OUT
  
select @intResult, @licenseEndDate as licenseEndDate, @serverActivationCount as serverActivationCount;

--  select * from licenses.activation where licenseID = 100144
--  select * from licenses.activation where licenseID = 100143
    select * from licenses.activation 

rollback tran



--  20120726 BUGFIX
begin tran

declare @intResult int, @licenseEndDate datetime;
exec @intResult = [activationService].[pLicense_Activate]
    --  main license to activate
      @licenseKey = 'JPY89W22T3A4Q2HMJ4RFUWYJ6'
    
    --  client system attributes
    , @machineKey = '56FBA942-04CB-4FFA-895F-17A984D453EF'
    , @motherboardKey = 'IST19'
    , @physicalMAC    = null
    
    , @endDate = @licenseEndDate OUT
  
select @intResult, @licenseEndDate as licenseEndDate;

--  select * from licenses.activation where licenseID = 100144
--  select * from licenses.activation where licenseID = 100143

--  select * from licenses.vLicense where [key] = 'JPY89W22T3A4Q2HMJ4RFUWYJ6'
--  select * from licenses.activation where licenseID = 20009

rollback tran


*/
--http://www.devtoolshed.com/using-stored-procedures-entity-framework-scalar-return-values
-- я не рак, Entity Framework не даёт возможности получить значение с return;
select @intResult;
--

return @intResult;
END

GO
