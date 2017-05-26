SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [log].[pBaseRoutineCreator]
      @action    int         = 0xdf     --  action mask:
                                        --  0x08 = SELECT (default), 0x04= EDIT, 0x02 = DELETE, 0x01 = INSERT;  0x0f = all 4 operations will be enabled in new routine body
                                        --  0x10 = SP with transaction open and close (commit, rollback) operations
                                        --  0x20 = SP will have transaction point as input parameter
                                        --  0x40 = SP with error logging
                                        --  0x80 = SP creation prefix block, with check procedure existence and empty-body-SP creation
    , @tableName sysname     = null
    , @rowcount int          = null out        
as
--  ==================================================================
--  create:  Mykhaylo Tytarenko (20090727, 28, 20100412)
--  modify: 
--  description: Create the base procedure that provide basic SELECT, EDIT, DELETE and INSERT operations
--   under specified table 
--  ==================================================================
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  // 
declare @sqlText nvarchar(max);


-- <constant zone>  --------------------------------------------------
----------------------------------------------------------------------
declare @constCreationPrefixBlock int, @constErrorLogging  int, @constTransactionPoint int, @constTransactionOperations int
    ,   @constSelectOperation     int, @constEditOperation int, @constDeleteOperation  int, @constInsertOperation       int;

set @constCreationPrefixBlock   = 0x80;
set @constErrorLogging          = 0x40;
--  set @constTransactionPoint      = 0x20; obsolete
set @constTransactionOperations = 0x10;

set @constSelectOperation       = 0x08;
set @constEditOperation         = 0x04;
set @constDeleteOperation       = 0x02;
set @constInsertOperation       = 0x01;


declare @constProcNamePrefix    sysname;    set @constProcNamePrefix = 'p';
declare @constTABsize               int;    set @constTABsize = 4;



declare @sqlRoutineCheckExistenceBody nvarchar(max);
    set @sqlRoutineCheckExistenceBody = '
if (object_id(''%ROUTINE_SCHEMA%.%ROUTINE_NAME%'', ''P'')) is null
    exec (''create procedure %ROUTINE_SCHEMA%.%ROUTINE_NAME% as return -1'')
';

declare @sqlRoutineHeaderCommentBody nvarchar(max);
    set @sqlRoutineHeaderCommentBody =
'--  ==================================================================
--  creator:  %SYSUSER%(%SYSDATE%)
--  modifier: 
--  description: provide basic SELECT, EDIT, DELETE and INSERT operations
--   for ''%TABLE_SCHEMA%.%TABLE_NAME%'' table 
--  ==================================================================';

declare @sqlUnsupportedOperationBlock nvarchar(max);
    set @sqlUnsupportedOperationBlock =
'--  %OPERATION_NAME% operation unsupported for this table
raiserror (''%OPERATION_NAME% operation unsupported for this table'', 16, 1);';


declare @sqlDeleteOperationBlock nvarchar(max);
    set @sqlDeleteOperationBlock =
'begin
    delete %TABLE_SCHEMA%.%TABLE_NAME% where %ROW_IDENTIFY_CLAUSE%
    set @rowcount = @@rowcount;
    if @rowcount = 0
    begin
        set @errMsg = ''non-existent row %OPERATION_NAME% operation found.'' %ROW_IDENTIFY_VALUES%
        raiserror (@errMsg , 16, 1)
    end
end';


declare @sqlInsertOperationBlock nvarchar(max);
    set @sqlInsertOperationBlock =
'begin
    --  base table insert
    insert %TABLE_SCHEMA%.%TABLE_NAME% (%COLUMN_NAMES_COMMA_GROUP%)
    values (%COLUMN_PARAMS_COMMA_GROUP%)

    set @rowcount = @@rowcount;
    %IDENTITY_PARAM_INIT%
end';


declare @sqlRowIdentifyValuesBlock nvarchar(max);
    set @sqlRowIdentifyValuesBlock = '''%IDENTIFY_ROW_NAME%='' + isnull(ltrim(rtrim(cast(%IDENTIFY_ROW_NAME% as varchar(48)))), ''null'')';


declare @sqlRoutineMainBody nvarchar(max);
    set @sqlRoutineMainBody = '
alter procedure %ROUTINE_SCHEMA%.%ROUTINE_NAME%
%PARAM_BLOCK%
as
%HEADER_COMMENT_BLOCK%
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  // 
declare @sqlText nvarchar(max);

begin try


%OPEN_TRANSACTION_OPERATION%


    -- <delete operation>  -------------------------------------------
    if @action & 0x02 != 0
%DELETE_OPERATION_BLOCK%
    ---------------------------------------------- </delete operation>


    -- <insert operation>  -------------------------------------------
    if @action & 0x01 != 0
%INSERT_OPERATION_BLOCK%
    ---------------------------------------------- </insert operation>


    -- <update operation>  -------------------------------------------
    if @action & 0x04 != 0
%UPDATE_OPERATION_BLOCK%
    ---------------------------------------------- </update operation>


    -- <select operation>  -------------------------------------------
    if @action & 0x08 != 0
%SELECT_OPERATION_BLOCK%
    ---------------------------------------------- </select operation>


%COMMIT_TRANSACTION_OPERATION%
    set @intResult = 0  --  routine success status

end try

begin catch

%ROLLBACK_TRANSACTION_OPERATION%
    -- set @id = null;

    select @errNum = error_number(), @errMsg = error_message();
    %CALL_ERROR_LOG_SP%
    %RAISING_ERROR%

    -- output error result
    set @intResult = case 
        when @errNum > 0 then (-1)*@errNum 
        when @errNum = 0 then -1 
        else @errNum 
        end

end catch;

/*  TEST ZONE
%TEST_ZONE_BODY%
*/

return @intResult;
END
';

declare @sqlTestZoneBody nvarchar(max);
    set @sqlTestZoneBody = '
  --  select * from %TABLE_SCHEMA%.%TABLE_NAME%
  --  select top 20 * from %LOG_SCHEMA%.%LOG_TABLE% where spname = ''%ROUTINE_SCHEMA%.%ROUTINE_NAME%''

  --  DELETE
  exec %ROUTINE_SCHEMA%.%ROUTINE_NAME% @action = 2, @id = 65535

  --  INSERT
  declare @intOutputID int, @intResult int
  exec @intResult = %ROUTINE_SCHEMA%.%ROUTINE_NAME% @action = 1, @id = @intOutputID out
%TEST_ZONE_PARAMS%
  select ''Inserted record ID: ''    + isnull(ltrim(rtrim(str(@intOutputID))), ''null'')
  select ''Proc execution result: '' + isnull(ltrim(rtrim(str(@intResult)))  , ''null'')  
  
  --  UPDATE
  declare @intResult int
  exec @intResult = %ROUTINE_SCHEMA%.%ROUTINE_NAME% @action = 4, @id = 65535
%TEST_ZONE_PARAMS%
  select ''Proc execution result: '' + isnull(ltrim(rtrim(str(@intResult)))  , ''null'')  

  --  SELECT
  exec %ROUTINE_SCHEMA%.%ROUTINE_NAME% @id = 65535
';  


declare @tblContextDBColumns table (id tinyint identity(1, 1), name sysname);
    insert @tblContextDBColumns (name)
    select 'ID'    union all
    select 'UID'   union all
    select 'URL'   union all
    select 'UID'   union all
    select 'SKUID'
    ;

/*
declare @tblTransactionCommand table (id tinyint identity(1, 1), name sysname, value nvarchar(max));
    insert @tblTransactionCommand (name, value)
    select 'Open',   'if (@@trancount = 0) BEGIN TRAN'                           union all
    select 'Close',  'if @trancount = 0 and @@trancount > 0 COMMIT TRANSACTION'  union all
    select 'Cancel', 'if @trancount = 0 and @@trancount > 0 COMMIT TRANSACTION'  union all
*/

----------------------------------------------------- </constant zone>
----------------------------------------------------------------------



declare @dbname sysname;
declare @objectID       int,     @schemaID      int;
declare @objectName     sysname, @schemaName    sysname;
declare @routineName    sysname, @routineSchema sysname;

declare @tblColumns table (
      id            int
    , name          sysname
    , systemTypeID  tinyint
    , userTypeID    tinyint
    , maxLength     smallint
    , precision     tinyint
    , scale         tinyint
    , collationName varchar(255)
    , isNullable    bit
    , isAnsiPadded  bit
    , isRowguidcol  bit
    , isIdentity    bit
    , isPrimaryKey  bit
    , isComputed    bit
    , isFilestream  bit
    , isReplicated  bit
    );

declare @tblParams table (
      rowID         int           identity(1, 1)
    , id            int    
    , name          sysname
    , type          sysname
    , length        varchar(128)
    , precision     int
    , scale         int
    , collation     varchar(255)
    , isIdentity    bit           default(0)
    , isPrimaryKey  bit           default(0)
    , fullName      nvarchar(512)
    );



begin try

   
	-- make sure the @tableName is local to the current database
	set @dbname = (select parsename(@tableName,3));
	if (@dbname is null)
		set @dbname = (select db_name());
	else
    if (@dbname <> db_name())
	    raiserror(15250,-1,-1);                         -- select * from sys.messages where message_id = 15250


    -- get table name and schema
	select
          @objectID   = object_id
        , @schemaID   = schema_id
        , @objectName = name
        , @schemaName = schema_name(schema_id)
    from sys.tables where object_id = object_id(@tableName);
    
    if @@rowcount = 0
        raiserror(15009,-1,-1, @tableName, @dbname);    -- select * from sys.messages where message_id = 15009

    -- print quotename(@schemaName) + '.' + quotename(@objectName);

    set @routineSchema = @schemaName;
    set @routineName = @constProcNamePrefix + @objectName;
    
    -- print quotename(@routineSchema) + '.' + quotename(@routineName);

    

    insert @tblColumns (
          id
        , name, systemTypeID, userTypeID, maxLength, precision, scale, collationName
        , isNullable, isAnsiPadded, isRowguidcol, isIdentity
        , isPrimaryKey
        , isComputed, isFilestream, isReplicated
        )
    select 
          column_id
        , col.name, system_type_id, user_type_id, max_length, precision, scale, collation_name 
        , is_nullable, is_ansi_padded, is_rowguidcol, is_identity
        , case when A.name is not null then 1 else 0 end as is_primaryKey
        , is_computed, is_filestream, is_replicated

    from sys.all_columns col
        
        left join (
            --  primary key columns selection
            select tcol.name
            from sys.indexes idx
                join sys.index_columns col on idx.object_id = col.object_id and idx.index_id = col.index_id
                join sys.columns tcol on col.object_id = tcol.object_id and col.column_id = tcol.column_id 
            where idx.object_id = @objectID
                and idx.type = 1    -- type_desc = CLUSTERED 
            ) A on A.name = col.name

    where object_id = @objectID

    -- select * from @tblColumns;



    -- <@tblParams fill>  --------------------------------------------
    ------------------------------------------------------------------

    --  insert first param, @action
    insert @tblParams (name, type, fullName)
    select 'action', 'int', '= 8     --  action mask: 0x08 = SELECT (by default), 0x04 = EDIT, 0x02 = DELETE, 0x01 = INSERT';

    
    --  insert primary key params
    insert @tblParams (id, name, type, length, collation, isIdentity, isPrimaryKey, fullName)
    select
          tbl.id
        , tbl.name, type_name(tbl.userTypeID)
        , case
            when type_name(tbl.userTypeID) in ('char', 'nchar') then '(' + ltrim(cast(tbl.maxlength as varchar(48)) ) + ')'
            when type_name(tbl.userTypeID) in ('varchar', 'nvarchar') then
            case
                when tbl.maxlength = -1 then '(max)' 
                else '(' + ltrim(cast(tbl.maxlength as varchar(48)) ) + ')'
                end
            when type_name(tbl.userTypeID) in ('numeric', 'decimal')                   then '(' + ltrim(cast(tbl.precision as varchar(48)) ) + ', ' + ltrim(cast(tbl.scale as varchar(48)) ) + ')'
            when type_name(tbl.userTypeID) in ('float')                                then '(' + ltrim(cast(tbl.precision as varchar(48)) ) + ')'
            end as length
        , tbl.collationName
        , tbl.isIdentity
        , tbl.isPrimaryKey
        , '= null  out'
    from @tblColumns tbl
    where tbl.isPrimaryKey = 1 or tbl.isIdentity = 1
    order by tbl.id


    --  insert third param, @rowcount
    insert @tblParams (name, type, fullName)
    select 'rowcount', 'int', '= null  out';

    --  insert empty line
    insert @tblParams (name, type, fullName)
    select '', '', ''    



    --  insert all other params
    insert @tblParams (
          id
        , name, type
        , length
        , collation
        , isIdentity
        , isPrimaryKey
        , fullName
        )
    select
          tbl.id
        , tbl.name, type_name(tbl.userTypeID)
        , case
            when type_name(tbl.userTypeID) in ('char', 'nchar') then '(' + ltrim(cast(tbl.maxlength as varchar(48)) ) + ')'
            when type_name(tbl.userTypeID) in ('varchar', 'nvarchar') then
            case
                when tbl.maxlength = -1 then '(max)' 
                else case when type_name(tbl.userTypeID) = 'nvarchar' then '(' + ltrim(cast(tbl.maxlength/2 as varchar(48)) ) + ')'
                     else '(' + ltrim(cast(tbl.maxlength as varchar(48)) ) + ')'
                    end 
                end
            when type_name(tbl.userTypeID) in ('numeric', 'decimal')                   then '(' + ltrim(cast(tbl.precision as varchar(48)) ) + ', ' + ltrim(cast(tbl.scale as varchar(48)) ) + ')'
            when type_name(tbl.userTypeID) in ('float')                                then '(' + ltrim(cast(tbl.precision as varchar(48)) ) + ')'
            end as length
        , tbl.collationName
        , tbl.isIdentity
        , tbl.isPrimaryKey
        , '= null'
    from @tblColumns tbl
    where tbl.isPrimaryKey = 0 and tbl.isIdentity = 0
    order by tbl.id
--        join sys.types types on types.user_type_id = tbl.userTypeID

    -- select * from  INFORMATION_SCHEMA.COLUMNS where table_name = 'user' and table_schema = 'users'

    update @tblParams
    set name = lower(left(name, 1)) + right(name, len(name)-1)
    from @tblParams
    where name not in ( select name from @tblContextDBColumns ) and len(name) > 0;
    
    
--  align param length
declare @intParamBlockRowLength int;
    set @intParamBlockRowLength = (
        select max(len([name] + ' ' + [type] + isnull(length, '')))
        from @tblParams
        );


    update @tblParams
    set fullName = '@' + [name] + space(@intParamBlockRowLength - len([name] + [type] + isnull([length], ''))) + [type] + isnull([length], '') + isnull(' ' + fullName, '')
    from @tblParams
    where len(name) > 0


    --  select * from @tblParams
 
    ----------------------------------------------  </@tblParams fill>
    ------------------------------------------------------------------


    --  %PARAM_BLOCK% replacement
declare @sqlParamBlock nvarchar(max);
    set @sqlParamBlock = N'';

    select @sqlParamBlock = @sqlParamBlock + space(@constTABsize) + ', ' + isnull(fullName, '') + char(0x0d)
    from @tblParams;

    if (left (@sqlParamBlock, len(space(@constTABsize) + ', ')) = space(@constTABsize) + ', ')
        set @sqlParamBlock = space(@constTABsize) + ' ' + right (@sqlParamBlock, len(@sqlParamBlock) - len(space(@constTABsize) + ', '));
    if right(@sqlParamBlock, 1) = char(0x0d)
        set @sqlParamBlock = left(@sqlParamBlock, len(@sqlParamBlock) - 1);

    set @sqlParamBlock = replace (@sqlParamBlock, space(@constTABsize) + ', ' + char(0x0d), char(0x0d));

    set @sqlRoutineMainBody = replace(@sqlRoutineMainBody, '%PARAM_BLOCK%', @sqlParamBlock);



    --  %ROW_IDENTIFY_CLAUSE% building
declare @sqlRowIdentifyClause nvarchar(max);
    set @sqlRowIdentifyClause = N'';

    select @sqlRowIdentifyClause = @sqlRowIdentifyClause + ' and ' + isnull(Name, '') +  ' = ' + isnull(left(fullName, charindex(' ', fullName)), '')
    from @tblParams
    where isPrimaryKey = 1 or isIdentity = 1
        

    if left (@sqlRowIdentifyClause, 5) = N' and '
        set @sqlRowIdentifyClause = right(@sqlRowIdentifyClause, len(@sqlRowIdentifyClause) - 4);
    
    set @sqlRowIdentifyClause = ltrim(rtrim(@sqlRowIdentifyClause));
    if @sqlRowIdentifyClause = ''
        set @sqlRowIdentifyClause = '<ERROR: THE PRIMARY KEY ROWS WERE NOT FOUND FOR GIVEN TABLE>'

    -- print @sqlRowIdentifyClause;



    --  %ROW_IDENTIFY_VALUES% building
declare @sqlRowIdentifyValues nvarchar(max);
    set @sqlRowIdentifyValues = N'';

    select @sqlRowIdentifyValues = @sqlRowIdentifyValues +
        +  char(0x0d) + char(0x0a) + space(4 * @constTABsize) + '+  char(0x0d) + char(0x0a) + char(0x09) + ' + replace (@sqlRowIdentifyValuesBlock, '%IDENTIFY_ROW_NAME%', isnull(left(fullName, charindex(' ', fullName)-1), ''))
    from @tblParams
    where isPrimaryKey = 1 or isIdentity = 1

    if left (@sqlRowIdentifyValues, 2) = N'; '
        set @sqlRowIdentifyValues = right(@sqlRowIdentifyValues, len(@sqlRowIdentifyValues) - 1);


    -- print @sqlRowIdentifyValues;

    -- <operation blocks replacement>  -------------------------------
    ------------------------------------------------------------------

    -- %DELETE_OPERATION_BLOCK% replacement
    if (@action & @constDeleteOperation = 0)
    begin
        set @sqlRoutineMainBody = replace (
            @sqlRoutineMainBody, '%DELETE_OPERATION_BLOCK%', space(2 * @constTABsize) + replace (
                replace(@sqlUnsupportedOperationBlock, '%OPERATION_NAME%', 'delete'),
                char(0x0d) + char(0x0a), char(0x0d) + char(0x0a) + space(2 * @constTABsize)
                )
            );
    end
    else
    begin
        set @sqlRoutineMainBody = replace (
            @sqlRoutineMainBody, '%DELETE_OPERATION_BLOCK%', space(@constTABsize) + replace (
                replace(
                    replace (@sqlDeleteOperationBlock, '%ROW_IDENTIFY_CLAUSE%', @sqlRowIdentifyClause)
                    , '%OPERATION_NAME%', 'delete'
                    ),
                char(0x0d) + char(0x0a), char(0x0d) + char(0x0a) + space(@constTABsize)
                )
            );
    end


    -- %INSERT_OPERATION_BLOCK% replacement
    if (@action & @constDeleteOperation = 0)
    begin
        set @sqlRoutineMainBody = replace (
            @sqlRoutineMainBody, '%INSERT_OPERATION_BLOCK%', space(2 * @constTABsize) + replace (
                replace(@sqlUnsupportedOperationBlock, '%OPERATION_NAME%', 'insert'),
                char(0x0d) + char(0x0a), char(0x0d) + char(0x0a) + space(2 * @constTABsize)
                )
            );
    end
    else
    begin

        declare @columnNamesCommaGroup nvarchar(max);
        set @columnNamesCommaGroup = (select name + ',' 'data()' from @tblColumns where isIdentity !=1 and isComputed != 1 order by ID for xml path (''));
        set @columnNamesCommaGroup = left (@columnNamesCommaGroup, len (@columnNamesCommaGroup)-1);
        

        declare @columnParamsCommaGroup nvarchar(max);
        set @columnParamsCommaGroup = (select '@'+ name + ',' 'data()' from @tblParams where id is not null and isIdentity !=1 order by ID for xml path (''));
        set @columnParamsCommaGroup = left (@columnParamsCommaGroup, len (@columnParamsCommaGroup)-1);

--        select '@columnNamesCommaGroup',  @columnNamesCommaGroup;
--        select '@columnParamsCommaGroup', @columnParamsCommaGroup;

        set @sqlRoutineMainBody = replace (
            @sqlRoutineMainBody, '%INSERT_OPERATION_BLOCK%', space(@constTABsize) + replace (
                replace(
                    replace (@sqlInsertOperationBlock, '%COLUMN_NAMES_COMMA_GROUP%', @columnNamesCommaGroup)
                    , '%COLUMN_PARAMS_COMMA_GROUP%', @columnParamsCommaGroup
                    ),
                char(0x0d) + char(0x0a), char(0x0d) + char(0x0a) + space(@constTABsize)
                )
            );

        if not exists (select * from @tblColumns where isIdentity = 1)
            set @sqlRoutineMainBody = replace (@sqlRoutineMainBody, '%IDENTITY_PARAM_INIT%', '')
        else
        begin
            declare @identityParamInit nvarchar(max);
            set @identityParamInit = (select 'select @' + isnull(name, '%IDENTITY_PARAM_NAME%') + ' = scope_identity();' from @tblParams where id is not null and isIdentity = 1);
            set @sqlRoutineMainBody = replace (@sqlRoutineMainBody, '%IDENTITY_PARAM_INIT%', @identityParamInit);
        end
    end



--declare @sqlInsertOperationBlock nvarchar(max);
--    set @sqlInsertOperationBlock =
--'begin
--    --  base table insert
--    insert %TABLE_SCHEMA%.%TABLE_NAME% (%COLUMN_NAMES_COMMA_GROUP%)
--    values (%COLUMN_PARAMS_COMMA_GROUP%)
--
--    set @rowcount = @@rowcount;
--    %IDENTITY_PARAM_INIT%
--
--end';

    --------------------------------- </ operation blocks replacement>
    ------------------------------------------------------------------


-- select charindex ('bc', 'abcde')
/*
    select tcol.name
    from sys.indexes idx
        join sys.index_columns col on idx.object_id = col.object_id and idx.index_id = col.index_id
        join sys.columns tcol on col.object_id = tcol.object_id and col.column_id = tcol.column_id 
    where idx.object_id = object_id('products.product')
        and idx.type = 1    -- type_desc = CLUSTERED 

    select col.*, object_name(col.object_id), tcol.name


    from sys.index_columns col
        join sys.columns tcol on col.object_id = tcol.object_id and col.column_id = tcol.column_id 
    where col.object_id = object_id('products.product')

    'sp_help'
    'sys.sp_helpconstraint'
    'object_id'
*/
    

/*

	-- DISPLAY COLUMN IF TABLE / VIEW
	if exists (select * from sys.all_columns where object_id = @objid)
	begin

		-- SET UP NUMERIC TYPES: THESE WILL HAVE NON-BLANK PREC/SCALE
		declare @numtypes nvarchar(80)
		select @numtypes = N'tinyint,smallint,decimal,int,real,money,float,numeric,smallmoney'

		-- INFO FOR EACH COLUMN
		print ' '
		select
			'Column_name'			= name,
			'Type'					= type_name(user_type_id),
			'Computed'				= case when ColumnProperty(object_id, name, 'IsComputed') = 0 then @no else @yes end,
			'Length'					= convert(int, max_length),
			'Prec'					= case when charindex(type_name(system_type_id), @numtypes) > 0
										then convert(char(5),ColumnProperty(object_id, name, 'precision'))
										else '     ' end,
			'Scale'					= case when charindex(type_name(system_type_id), @numtypes) > 0
										then convert(char(5),OdbcScale(system_type_id,scale))
										else '     ' end,
			'Nullable'				= case when is_nullable = 0 then @no else @yes end,
			'TrimTrailingBlanks'	= case ColumnProperty(object_id, name, 'UsesAnsiTrim')
										when 1 then @no
										when 0 then @yes
										else '(n/a)' end,
			'FixedLenNullInSource'	= case
						when type_name(system_type_id) not in ('varbinary','varchar','binary','char')
							then '(n/a)'
						when is_nullable = 0 then @no else @yes end,
			'Collation'		= collation_name
		from sys.all_columns where object_id = @objid

*/

    


    --  action 0x80 = SP creation prefix block, with check procedure existence and empty-body-SP creation        
    if @action & @constCreationPrefixBlock != 0
        set @sqlRoutineMainBody = 
            @sqlRoutineCheckExistenceBody + 'go' + @sqlRoutineMainBody;


    -- %SYSUSER% and %SYSDATE% replacement
    set @sqlRoutineHeaderCommentBody = replace (
        replace(@sqlRoutineHeaderCommentBody, '%SYSUSER%', isnull(system_user, '')),
            '%SYSDATE%', convert(varchar(8), getdate(), 112)
        );

    --  %HEADER_COMMENT_BLOCK% replacement
    set @sqlRoutineMainBody = replace (@sqlRoutineMainBody, '%HEADER_COMMENT_BLOCK%', @sqlRoutineHeaderCommentBody);


    --  %ROUTINE_SCHEMA% and %ROUTINE_NAME% replacement
    set @sqlRoutineMainBody = replace(
        replace(@sqlRoutineMainBody, '%ROUTINE_SCHEMA%', quotename(@routineSchema)), 
            '%ROUTINE_NAME%', quotename(@routineName)
        );

    --  %TABLE_SCHEMA% and %TABLE_NAME% replacement
    set @sqlRoutineMainBody = replace(
        replace(@sqlRoutineMainBody, '%TABLE_SCHEMA%', quotename(@schemaName)), 
            '%TABLE_NAME%', quotename(@objectName)
        );


    --  %ROW_IDENTIFY_VALUES% replacement
    set @sqlRoutineMainBody = replace (@sqlRoutineMainBody, '%ROW_IDENTIFY_VALUES%', @sqlRowIdentifyValues);


    select @sqlRoutineMainBody;



    if @trancount = 0 and @@trancount > 0 COMMIT TRANSACTION
    
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 and @@trancount > 0 ROLLBACK TRANSACTION
    -- set @id = null;

    --/========================LOG ERR=============================\
    select @errNum = error_number(), @errMsg = error_message();
    --  exec [log].[WriteToLogErr] @errNum, @errMsg, @@SPID    

    raiserror (@errMsg, 16, 1);
    set @intResult = case
        when @errNum > 0 then (-1)*@errNum 
        when @errNum = 0 then -1 
        else @errNum
        end
    --\============================================================/

end catch;

/*  TEST ZONE
  --  select * FROM [log].[Application]

    exec [log].[pBaseRoutineCreator] @tableName = 'Support.Agent'


    exec [log].[pBaseRoutineCreator] @tableName = '[Products].Product', @action = 0xdd
    exec [log].[pBaseRoutineCreator] @tableName = 'Products.[Product]'
    exec [log].[pBaseRoutineCreator] @tableName = '[Products].[Product]'
    exec [log].[pBaseRoutineCreator] @tableName = '[Products.Product]'

    sys.sp_helpconstraint 'Products.Product','nomsg'
*/

  return @intResult;
GO
