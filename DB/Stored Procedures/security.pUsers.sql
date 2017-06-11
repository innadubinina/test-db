SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [security].[pUsers]
      @action           int = 8           --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT    , @ID               int = null  out    , @rowcount         int = null  out    , @name             nvarchar(50) = null    , @password         nvarchar(50) = null    , @isActive         bigint = null
	, @isAdmin          bit = null

    , @createDate       datetime = null        -- for select action only
as
--  ==================================================================
--  creator:  tatiana.didenko (20120723)
--  modifier: 
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for '[security].[users]' table
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION Security_pUsers
    else BEGIN TRAN

    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
    begin

        -- <base table delete> -----------------------------
        delete [security].[users] where id = @ID
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
        insert [security].[users] ([Name], [Password], [IsActive], [IsAdmin])
        values (@name, @password, @isActive, @isAdmin)

        set @rowcount = @@rowcount;
        select @ID = scope_identity();
        ------------------------------- </base table insert>

    end
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
    begin

        -- <base table update> -----------------------------
        update [security].[users]
        set   [Name] = @name, [Password] = @password, [IsActive] = @isActive, [IsAdmin] = @isAdmin
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
        
        set @sqlFilter = N'' +
            case when @id          is null then '' else 'and (usr.[Id] = @id)'                   + char (0x0d) end +    
            case when @name        is null then '' else 'and (usr.[Name] = @name)'               + char (0x0d) end +
            case when @password    is null then '' else 'and (usr.[Password] = @password)'       + char (0x0d) end +
            case when @isActive    is null then '' else 'and (usr.[IsActive] = @isActive)'       + char (0x0d) end +
            case when @isAdmin     is null then '' else 'and (usr.[IsAdmin] = @isAdmin)'         + char (0x0d) end +
            case when @createDate  is null then '' else 'and (usr.[CreateDate] = @createDate)'   + char (0x0d) end ;


        if left(@sqlFilter, 3) = N'and'
            set @sqlFilter = right (@sqlFilter, len (@sqlFilter)-3)
        -- print @sqlFilter;

        set @sqlText = N'
            select ' + case when @rowcount is not null then 'top (' + ltrim(rtrim(cast(@rowcount as varchar(48)))) + ')' else '' end + '
                  usr.[id]          as [Users.ID]
                , usr.[Name]        as [Users.Name]
                , usr.[Password]	as [Users.Password]
                , usr.[CreateDate]  as [Users.CreateDate]
                , usr.[IsActive]    as [Users.IsActive]
                , usr.[IsAdmin]     as [Users.IsAdmin]
            from [security].[users] usr'
            + case
                when @sqlFilter = N'' then ''
                else '
            where ' + char (0x0d) + @sqlFilter
                end               
            + ' 
            order by usr.id desc' 
            + ' 
                        
            set @rowcount = @@rowcount;
            ';
        print @sqlText;

        set @sqlParmDefinition = N'
              @id             int
            , @rowcount       int  out    

            , @name           nvarchar(50)			, @password       nvarchar(50)			, @isActive       bigint
			, @isAdmin        bit
			, @createDate     datetime
              
            ';
        -- print @sqlParmDefinition;        


        --  output recordset
        exec @intResult = sp_executesql @sqlText, @sqlParmDefinition
            , @id = @id
            , @name = @name, @password = @password, @isActive = @isActive, @isAdmin = @isAdmin, @createDate = @createDate
            , @rowcount = @rowcount out

    end
    ------------------------------------------------------------------
    ---------------------------------------------- </select operation> 


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION Security_pUsers

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
--  select * from [security].[users]; 
--  select top 10 * from log.error


--  SELECT
    exec [security].[pUsers] @id=13
    exec [security].[pUsers] @rowcount = 10


--  INSERT
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [security].[pUsers] @action = 1, @name = 'TestUser', @password = 'TT@@US', @isActive = 1, @isAdmin = 1 
		, @rowCount = @intRowCount out, @id = @id out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [security].[pUsers]
    rollback


--  UPDATE
    declare @intResult int, @intRowCount int, @id int;
    
    set xact_abort on
    begin tran
    exec @intResult = [security].[pUsers] @action = 4, @id = 19, @name = 'TEST', @password = '12345', @isActive = 0, @isAdmin = 1, @rowCount = @intRowCount out 
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [security].[pUsers]
    rollback


--  DELETE
    declare @intResult int, @intRowCount int, @id int;
    -- set xact_abort on
    begin tran
    exec @intResult = [security].[pUsers] @action = 2, @id = 19
        , @rowCount = @intRowCount out
    select @intResult as intResult, @intRowCount as [rowCount], @id as id
    exec [security].[pUsers]
    rollback

*/

return @intResult;
END
GO
