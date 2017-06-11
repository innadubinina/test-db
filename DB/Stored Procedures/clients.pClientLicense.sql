SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
