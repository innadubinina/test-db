SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
