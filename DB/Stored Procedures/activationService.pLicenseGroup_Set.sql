SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
