SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [clients].[pSession]
      @action                int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID                    int = null  out    , @rowcount              int = null  out    , @UID      uniqueidentifier = null  out
    , @privateKey varbinary(639) = null
    , @IPAddress     varchar(64) = null
    , @createDate       datetime = null        -- for select action only
as
--  ==================================================================
--  create: 20120723 Mykhaylo Tytarenko
--  modify: 20130131 Mykhaylo Tytarenko. Autoclear logic added to insert zone.
--          20130222 Mykhaylo Tytarenko. Private (596->635) and Public (148->162) keys expanded.
--          20130320 Mykhaylo Tytarenko. Change length of private (from 635 to 639) and public (from 162 to 164) keys and type from binary to varbinary
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[clients].[session]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //
declare @keyID int;

begin try

    if (@trancount > 0) SAVE TRANSACTION clients_pSession
    else BEGIN TRAN


    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [clients].[session] where ID = @ID
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
        declare @twoDaysAgo datetime; set @twoDaysAgo = ( select cast( cast (dateadd(dd, -2, getdate()) as date) as datetime) );
        if exists (select * from [clients].[session] where createDate < @twoDaysAgo)
            delete [clients].[session] where createDate < @twoDaysAgo

        
        --  if UID not passed from client - DB must generate it
        if @UID is null set @UID = (select newid());
        
        --  get privateKey ID
        set @keyID = (select top 1 id from clients.[key] where [private] = @privateKey);
        
        -- <base table insert> -----------------------------
        insert [clients].[session] (UID, keyID, IPAddress)
        values (@UID, @keyID, @IPAddress)

        set @rowcount = @@rowcount;
        select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin

        --  get privateKey ID
        set @keyID = (select top 1 id from clients.[key] where [private] = @privateKey);

        -- <base table update> -----------------------------
        update [clients].[session]
        set UID = @UID, keyID = @keyID, IPAddress = @IPAddress
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
            case when @id         is null then '' else 'and (base.[ID] = @id)'                 + char (0x0d) end +
            case when @UID        is null then '' else 'and (base.[UID] = @UID)'               + char (0x0d) end +    
            case when @privateKey is null then '' else 'and (key.[private]=@privateKey)'       + char (0x0d) end +
            case when @ipAddress  is null then '' else 'and (base.[ipAddress] = @ipAddress)'   + char (0x0d) end +
            case when @createDate is null then '' else 'and (base.[CreateDate] = @createDate)' + char (0x0d) end;

        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'

            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  base.[ID]         as [Session.ID]
                , base.[UID]        as [Session.UID]
                , [key].[private]   as [Session.PrivateKey]
                , [key].[typeID]    as [Session.KeyTypeID]
                , base.[IPAddress]  as [Session.IPAddress]
                , base.[CreateDate] as [Session.CreateDate]
            from [clients].[session] base 
                join [clients].[key] [key] on [key].id = base.keyID'
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
        -- print @sqlText;

        set @sqlParmDefinition = N'
              @id                    int
            , @rowcount              int  out    

            , @UID      uniqueidentifier  out
            , @privateKey    binary(639)
            , @IPAddress     varchar(64)
            , @createDate       datetime
            ';
        -- print @sqlParmDefinition;        


        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @UID = @UID, @privateKey = @privateKey, @IPAddress = @IPAddress
            , @createDate = @createDate

            , @rowcount = @rowcount out
        

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION clients_pSession

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
    exec [clients].[pSession] 
    exec [clients].[pSession] @rowcount = 10


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [clients].[pSession] @action = 1, @privateKey = 0x000000087, @IPAddress = '121.17.96.1'
        , @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pSession]
    rollback


--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [clients].[pSession] @action = 4, @id = 6, @UID = 'AAB116A3-5CA2-418F-B2B1-10CD128CF848', @privateKey = 0x0000097, @IPAddress = '10.17.96.1'
        , @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pSession]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [clients].[pSession] @action = 2, @id = 6
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [clients].[pSession]
    rollback

*/

return @intResult;
END
GO
