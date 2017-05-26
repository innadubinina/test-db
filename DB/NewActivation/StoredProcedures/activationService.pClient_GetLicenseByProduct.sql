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
CREATE TABLE [clients].[preClientWaitForLicense](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[productName] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[email] [nvarchar](128) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[firstName] [nvarchar](100) COLLATE Cyrillic_General_CI_AS NULL,
	[lastName] [nvarchar](100) COLLATE Cyrillic_General_CI_AS NULL,
	[isValidEmail] [bit] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_isValidEmail]  DEFAULT ((1)),
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_createDate]  DEFAULT (getdate()),
	[ipAddress] [varchar](330) COLLATE Cyrillic_General_CI_AS NULL,
	[languageISO2] [char](2) COLLATE Cyrillic_General_CI_AS NULL,
	[deleted] [bit] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_deleted]  DEFAULT ((0)),
	[readyToSend] [bit] NOT NULL CONSTRAINT [DF_preClientWaitForLicense_readyToSend]  DEFAULT ((0)),
 CONSTRAINT [PK_PreClientWaitForLicense] PRIMARY KEY CLUSTERED 
(
	[id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQ_clients_PreClientWaitForLicense] UNIQUE NONCLUSTERED 
(
	[productName] ASC,
	[email] ASC
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
CREATE TABLE [clients].[clientLicense](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[clientID] [int] NOT NULL,
	[licenseID] [int] NOT NULL,
	[optIn] [bit] NULL,
	[createDate] [datetime] NOT NULL CONSTRAINT [DF_clientLicense_createDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_clientLicense] PRIMARY KEY CLUSTERED 
(
	[id] DESC
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [licenses].[vClientProductLicenses]
as
select cl.id as 'clientID'
     , cl.email
     , cl.firstName
     , cl.lastName
     , cl.Optin
     , cl.isValidEmail
     , cl.createDate as clientCreateDate
     , lnsCl.createDate as clientLicenseCreateDate
     , lns.id as 'licenseID'
     , lns.[key]
     , gr.id as 'groupID'
     , gr.productID
     , cl.ipAddress  
     , cl.languageISO2
from clients.client               cl 
	join clients.clientLicense lnsCl on cl.id = lnsCl.clientID
	join licenses.license        lns on lnsCl.licenseID = lns.id
	join licenses.[group]         gr on lns.groupID = gr.id

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
CREATE NONCLUSTERED INDEX [IX_LicenseID] ON [clients].[clientLicense]
(
	[licenseID] ASC
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
ALTER TABLE [clients].[clientLicense]  WITH CHECK ADD  CONSTRAINT [FK_clientLicense_clientID] FOREIGN KEY([clientID])
REFERENCES [clients].[client] ([id])
GO
ALTER TABLE [clients].[clientLicense] CHECK CONSTRAINT [FK_clientLicense_clientID]
GO
ALTER TABLE [clients].[clientLicense]  WITH CHECK ADD  CONSTRAINT [FK_clientLicense_licenseID] FOREIGN KEY([licenseID])
REFERENCES [licenses].[license] ([id])
GO
ALTER TABLE [clients].[clientLicense] CHECK CONSTRAINT [FK_clientLicense_licenseID]
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
CREATE procedure [clients].[pClientLicense]
      @action        int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID            int = null  out    , @rowcount      int = null  out    , @clientID      int = null  
    , @licenseID     int = null
    , @optIn         bit = null
    , @createDate    datetime = null        -- for select action only

as
--  ==================================================================
--  creator:  tatiana.didenko (20120802)
--  modifier:
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[clients].[clientLicense]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION Clients_pClientLicense
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [clients].[clientLicense] where id = @ID
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
		insert [clients].[clientLicense] ([clientID], [licenseID], [optIn])
		values (@clientID, @licenseID, @optIn)
		
		set @rowcount = @@rowcount;
		select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin
		
        -- <base table update> -----------------------------
        update [clients].[clientLicense]
        set [clientID] = @clientID, [licenseID] = @licenseID, [optIn] = @optIn
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
            case when @id         is null then '' else 'and (cl.[id] = @id)'                  + char (0x0d) end +    
            case when @clientID   is null then '' else 'and (cl.[clientID] = @clientID)'      + char (0x0d) end + 
            case when @licenseID  is null then '' else 'and (cl.[licenseID] = @licenseID)'    + char (0x0d) end + 
            case when @optIn      is null then '' else 'and (cl.[optIn] = @optIn)'            + char (0x0d) end + 
            case when @createDate is null then '' else 'and (cl.[createDate] = @createDate)'  + char (0x0d) end ;

        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  cl.[id]           as [ClientLicense.ID]
                , cl.[clientID]     as [ClientLicense.ClientID]
                , cl.[licenseID]    as [ClientLicense.LicenseID]
                , cl.[optIn]        as [ClientLicense.OptIn]
                , cl.[createDate]   as [ClientLicense.CreateDate]
            from [clients].[vClientLicense] cl'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by cl.id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id            int
            , @rowcount      int  out

            , @clientID      int
			, @licenseID     int
			, @optIn         bit
			, @createDate    datetime
            ';
        -- print @sqlParmDefinition;        

        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @clientID = @clientID, @licenseID = @licenseID, @optIn = @optIn, @createDate = @createDate
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Clients_pClientLicense

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
--  select top 10 * from [licenses].[license];   --650068
--  select top 10 * from log.error


--  SELECT
    exec [clients].[pClientLicense] @id=4
    exec [clients].[pClientLicense] @rowcount = 10


--  INSERT
declare @intResult int, @intRowCount int, @id int;
    set xact_abort on
    begin tran
		insert into clients.client([email],[firstName],[lastName],[optIn])
		values ('sdf@dfg.ru','fff','bbb', 1)
		select * from clients.client
    rollback 
    
declare @intResult int, @intRowCount int, @id int;    
    set xact_abort on
    begin tran
		exec @intResult = [clients].[pClientLicense] @action = 1, @clientID = 12, @licenseID = 650068, @optIn = 1
			, @rowCount = @intRowCount out, @id = @id out
		select @intResult as intResult, @intRowCount as [rowCount], @id as id
		exec [clients].[pClientLicense]
    rollback

--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
		exec @intResult = [clients].[pClientLicense] @action = 4, @id = 1,  @clientID = 12, @licenseID = 650068, @optIn = 0
			, @rowCount = @intRowCount out 
		select @intResult as intResult, @intRowCount as [rowCount], @id as id
		exec [clients].[pClientLicense]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
		exec @intResult = [clients].[pClientLicense] @action = 2, @id = 1
			, @rowCount = @intRowCount out
		select @intResult as intResult, @intRowCount as [rowCount], @id as id
		exec [clients].[pClientLicense]
    rollback

*/

return @intResult;
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [clients].[pPreClientWaitForLicense]
      @action                int = 8     --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @id                    int = null  out    , @rowcount              int = null  out    , @productName nvarchar(128) = null    , @email       nvarchar(128) = null    , @firstName   nvarchar(100) = null    , @lastName    nvarchar(100) = null    , @isValidEmail          bit = null  --  for SELECT operation only (as filter)    , @createDate       datetime = null  --  for SELECT operation only (as filter)
    
    , @ipAddress    varchar(330) = null
    , @languageISO2      char(2) = null
    , @deleted               bit = null  --  for SELECT operation only (as filter)
    , @readyToSend           bit = null  --  for SELECT operation only (as filter)
    
as
--  ==================================================================
--  create: 20130122 Mykhaylo Tytarenko
--  modify: 20130129 Mykhaylo Tytarenko. New fields ipAddress, languageISO2, deleted and readyToSend in the base entity
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[clients].[preClientWaitForLicense]' table 
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION Clients_pPreClientWaitForLicense
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [clients].[preClientWaitForLicense] where id = @ID
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
	    set @isValidEmail = (select clients.fCheckEmailValidity(@email))

		insert [clients].[preClientWaitForLicense] ([productName], [email],[firstName],[lastName],[isValidEmail],[ipAddress],[languageISO2])
		values (@productName, @email, @firstName, @lastName, @isValidEmail,@ipAddress,@languageISO2)

		set @rowcount = @@rowcount;
		select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin
		
        set @errMsg = 'update operation is not applicable for this table.' 
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
            case when @id           is null then '' else 'and (base.[id] = @id)'                      + char (0x0d) end +    
            case when @productName  is null then '' else 'and (base.[productName] = @productName)'    + char (0x0d) end + 
            case when @email        is null then '' else 'and (base.[email] = @email)'                + char (0x0d) end + 
            case when @firstName    is null then '' else 'and (base.[firstName] = @firstName)'        + char (0x0d) end + 
            case when @lastName     is null then '' else 'and (base.[lastName] = @lastName)'          + char (0x0d) end + 
            case when @isValidEmail is null then '' else 'and (base.[isValidEmail] = @isValidEmail)'  + char (0x0d) end +  
            case when @createDate   is null then '' else 'and (base.[createDate] = @createDate)'      + char (0x0d) end +
            case when @ipAddress    is null then '' else 'and (base.[ipAddress] = @ipAddress)'        + char (0x0d) end +
            case when @languageISO2 is null then '' else 'and (base.[languageISO2] = @languageISO2)'  + char (0x0d) end +
            case when @deleted      is null then '' else 'and (base.[deleted] = @deleted)'            + char (0x0d) end +
            case when @readyToSend  is null then '' else 'and (base.[readyToSend] = @readyToSend)'    + char (0x0d) end;


        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  base.[id]           as [preClientWaitForLicense.ID]
                , base.[productName]  as [preClientWaitForLicense.ProductName]
                , base.[email]        as [preClientWaitForLicense.Email]
                , base.[firstName]    as [preClientWaitForLicense.FirstName]
                , base.[lastName]     as [preClientWaitForLicense.LastName]
                , base.[isValidEmail] as [preClientWaitForLicense.IsValidEmail]
                , base.[createDate]   as [preClientWaitForLicense.CreateDate]
                , base.[ipAddress]    as [preClientWaitForLicense.IPAddress]
                , base.[languageISO2] as [preClientWaitForLicense.LanguageISO2]
                , base.[deleted]      as [preClientWaitForLicense.Deleted]
                , base.[readyToSend]  as [preClientWaitForLicense.ReadyToSend]
                                                
            from [clients].[preClientWaitForLicense] base'
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
        -- print @sqlText;

        set @sqlParmDefinition = N'
              @id                    int
            , @rowcount              int  out

            , @productName nvarchar(128)            , @email       nvarchar(128)            , @firstName   nvarchar(100)            , @lastName    nvarchar(100)            , @isValidEmail          bit            , @createDate       datetime
            
            , @ipAddress    varchar(330)
            , @languageISO2      char(2)
            , @deleted               bit
            , @readyToSend           bit
            ';
        -- print @sqlParmDefinition;        

        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @productName = @productName, @email = @email, @firstName = @firstName, @lastName = @lastName, @isValidEmail = @isValidEmail
			, @createDate = @createDate, @ipAddress = @ipAddress, @languageISO2 = @languageISO2, @deleted = @deleted, @readyToSend = @readyToSend
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Clients_pPreClientWaitForLicense

    set @ID = null;

    select @errNum = error_number(), @errMsg = error_message();
    if xact_state() <> -1 exec [log].[pError] @number=@errNum, @message=@errMsg, @spid=@@spid
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
--  select * from [clients].[preClientWaitForLicense]; select * from products.product
--  select top 10 * from log.error


--  SELECT
    exec [clients].[pPreClientWaitForLicense] @id=4
    exec [clients].[pPreClientWaitForLicense] @rowcount = 10


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [clients].[pPreClientWaitForLicense] @action = 1
        , @productName = 'PDF Architect Create'
        , @email = 'test@y', @firstName = 'TEST1', @lastName = 'TEST2'
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pPreClientWaitForLicense]
    rollback

--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [clients].[pPreClientWaitForLicense] @action = 4, @id = 9
        , @productName = 'PDF Architect Create'
        , @email = 'test@y', @firstName = 'TEST1', @lastName = 'TEST2'
		, @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pPreClientWaitForLicense]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [clients].[pPreClientWaitForLicense] @action = 2, @id = 9
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pPreClientWaitForLicense]
    rollback

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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--  ==================================================================
--  Create: 20120801,02 Tatiana Didenko
--  Modify: 20120830 Mykhaylo Tytarenko. Add transaction scope.
--          20130129 Mykhaylo Tytarenko. New fields ipAddress and languageISO2 in the Client entity
--  Description:    returns a free license key for client
--  ==================================================================
CREATE procedure [activationService].[pClient_GetLicenseByProduct]
      @sessionUID uniqueidentifier = null  --   special for get IP Address from current session

    , @productName    varchar(128)

    , @email         nvarchar(128)
    , @firstName     nvarchar(128) = null
    , @lastName      nvarchar(128) = null
    , @optIn                   bit = null
    , @languageISO2        char(2) = null

    , @licenseKey      varchar(64) = null out
AS
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  // 
declare @licenseKeyID int, @productID int, @clientID int;

declare @ipAddress varchar(330);

begin try

    if (@trancount > 0) SAVE TRANSACTION pClientGetLicenseByProduct
    else BEGIN TRAN

    set @productID = (select id from products.product where name = @productName);   --  select * from ActivationProcess.Products

    if @productID is null
    begin
        set @errMsg = N'50032. The product <' + ltrim(rtrim(ISNULL(@productName, 'null'))) + '> was not found'
        raiserror (@errMsg , 16, 1)
    end

    set @ipAddress = (select [IPAddress] from [clients].[session] where [UID] = @sessionUID);
    
    set @clientID = (select ID from clients.client where email = @email);
    if @clientID is null
    begin               
        exec @intResult = clients.pClient @action = 1, @email = @email, @firstName = @firstName, @lastName = @lastName, @optIn = @optIn
                , @ipAddress = @ipAddress, @languageISO2 = @languageISO2        
                , @ID = @clientID OUT
    end
    
    --  check license exists
    set @licenseKey = (select top 1 [key] from [licenses].[vClientProductLicenses] where productID = @productID and clientID = @clientID);
    --  select * from [licenses].[vClientProductLicenses]

 
    --  new license
    if @licenseKey is null
    begin

        set @licenseKeyID = (
            select top 1 source.id
            from licenses.license source WITH(UPDLOCK, READPAST)
                join licenses.[group] gr on gr.ID = source.groupID
                join products.product pr on pr.id = gr.productID and pr.ID = @productID
                --  join @tblFreeLicenses fl on fl.id = source.id
            where source.id not in (select licenseID from clients.clientLicense)
            );

    
        if @licenseKeyID is null
        begin
            set @errMsg = N'50033. No available license found'
            raiserror (@errMsg , 16, 1)
        end
        
        exec @intResult = clients.pClientLicense @action = 1, @clientID = @clientID, @licenseID = @licenseKeyID, @optIn = @optIn
                    , @ID = @clientID OUT
    
         --  output param
        set @licenseKey = (select [key] from licenses.license where ID = @licenseKeyID);

    end

    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION pClientGetLicenseByProduct
    print @errMsg;
    
    select @errNum = error_number(), @errMsg = error_message();
    if xact_state() <> -1 exec [Log].[pError] @action = 1, @number = @errNum, @message = @errMsg
    
    set @intResult = case 
        when @errNum > 0 and isnumeric(left(@errMsg, 5)) = 1 then (-1)* cast(left(@errMsg, 5) as int)
        when @errNum = 0 then -1 
        else (-1)*@errNum 
        end

    --  log preClients
    if @errMsg = N'50033. No available license found'
    begin
        declare @preClientID int;
        exec [clients].[pPreClientWaitForLicense] @action = 1
            , @productName = @productName
            , @email = @email, @firstName = @firstName, @lastName = @lastName
            , @ipAddress = @ipAddress, @languageISO2 = @languageISO2
            , @id = @preClientID out
        print @preClientID;
    end
    
end catch;
   
--http://www.devtoolshed.com/using-stored-procedures-entity-framework-scalar-return-values
select @intResult;
--
return @intResult;
END

/*
TEST ZONE

--  select * from [clients].[client]; 
--  select * from [licenses].[license];
--  select * from [products].[product];
--  select * from [clients].[clientLicense];
--  select top 10 * from log.error
--  [log].[pError] 8
--  select * from licenses.license nolock where [key] = 'ZBTAUT6DA7ERUZC2YRDV4FRD6' --  is not exists in the license pool
--  select * from licenses.license nolock where [key] = 'H22JAU7NB7YRU8CTBR7674QPN' --  is not exists in the license pool
--  select * from licenses.license nolock where [key] = 'EP4RH7JJ7UP9FZC2G59S8FK5K' --  is not exists in the license pool
--  50001. Given license <EP4RH7JJ7UP9FZC2G59S8FK5K> is not exists in the license pool
--  select  db_name(5)
kill 55

--  INSERT
declare @intResult int, @licenseKey varchar(64); 

set xact_abort on
begin tran
    exec @intResult = [activationService].[pClient_GetLicenseByProduct] @email = 'test@ya.rueeeee', @firstName = 'TestFirstName', @lastName = 'TestLastName'
        , @optIn = 1, @productName = 'pdf architect create'
        , @licenseKey = @licenseKey out
    select @intResult as intResult,  @licenseKey as licenseKey

     --select * from [clients].[clientLicense];
     --select * from [licenses].[license] where [key]=@licenseKey;
     --select * from [clients].[client]; 
rollback
    
*/
GO
