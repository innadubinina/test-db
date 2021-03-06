SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Tatiana Didenko
-- Create date: 20121128
-- Description:	'[licenses].[licenses]' deactivation
-- =============================================
CREATE PROCEDURE [activationService].[pLicense_DeactivatePurchaseLicenses]
      @startDate datetime = null
    , @endDate   datetime = null
AS
BEGIN
	SET NOCOUNT ON;

declare @globalOrderID varchar(21), @transactionType varchar(20), @transactionDate datetime, @licenseKey nvarchar(200), @isHistory bit;
declare @history xml;

create table #tblLicenses
(
    id int identity(1,1) not null primary key
  , GlobalOrderID    varchar(21)
  , TransactionType  varchar(20)
  , TransactionDate  datetime
  , LicenseKey       nvarchar(200)
  , isHistory        bit default(0)
)

if @startDate is null or @endDate is null
begin
    set @startDate =(select dateadd(day, 0, datediff(day, 0, getdate())));  --  today start
    set @endDate =(select dateadd(day, 1, @startDate));                     --  today end
end


insert #tblLicenses(GlobalOrderID, TransactionType, TransactionDate, LicenseKey, isHistory)
select source.GlobalOrderID, source.TransactionType, source.TransactionDate, source.LicenseKey, case when base.history is not null then 1 else 0 end as isHistory
from NewStats.Dict.fnGetPurchaseLicensesForDeactivation (@startDate, @endDate) source
    join licenses.license   base   on source.LicenseKey = base.[key] collate Cyrillic_General_CI_AS
where base.Deactivated = 0 

select * from #tblLicenses  


declare cursLicensesUpdate cursor local fast_forward for
    select GlobalOrderID, TransactionType, TransactionDate, LicenseKey, isHistory from #tblLicenses
  
    open  cursLicensesUpdate
    fetch next from cursLicensesUpdate into @globalOrderID, @transactionType, @transactionDate, @licenseKey, @isHistory
    
    while @@FETCH_STATUS = 0
    begin
        set @history = (select convert(nvarchar(30), getdate(), 121)         as [createDate]
                              , cast(@globalOrderID as nvarchar(25))         as GlobalOrderID
                              , cast(@transactionType as nvarchar(25))       as TransactionType
                              , convert(nvarchar(30), @transactionDate, 121) as TransactionDate
                        for xml raw('automatedDeactivate')
                        ) 
                       
        if @isHistory = 0
        begin
            update licenses.license
            set deactivated = 1, history = ('<history>' + cast(@history as nvarchar(max)) + '</history>')
            where [key] = @licenseKey   
        end
        else
        begin
            update licenses.license
            set deactivated = 1, history = cast(substring(cast([history] as nvarchar(max)), 0, len(cast([history] as nvarchar(max)))-len('</history>')+1)+cast(@history as nvarchar(max))+'</history>' as xml)
            where [key] = @licenseKey  
        end
    
        print @licenseKey
        
        insert log.LicenseAutoDeactivation(GlobalOrderID, TransactionType, TransactionDate, LicenseKey)
        values(@globalOrderID, @transactionType, @transactionDate, @licenseKey)
      
        fetch next from cursLicensesUpdate into @globalOrderID, @transactionType, @transactionDate, @licenseKey, @isHistory
    end
      
close cursLicensesUpdate
deallocate cursLicensesUpdate


drop table #tblLicenses
  
END

/*
TEST ZONE
select * from log.LicenseAutoDeactivation;
select top 1000 * from ActivationProcess.LicenseNumbers where LicenseNumber in (select LicenseKey from log.LicenseAutoDeactivation);

declare @startDate datetime, @endDate datetime
set @startDate = '20121130'
set @endDate = '20121201'

begin tran
    exec  [activationService].[pLicense_DeactivatePurchaseLicenses] @startDate, @endDate

    select * from log.LicenseAutoDeactivation
    select * from licenses.license where [key] in (select LicenseKey from log.LicenseAutoDeactivation)
rollback



declare @startDate datetime, @endDate datetime
set @startDate = '20121127'
set @endDate = '20121128'
select base.*
from NewStats.Dict.fnGetPurchaseLicensesForDeactivation (@startDate, @endDate) source
    join ActivationProcess.LicenseNumbers base   on source.LicenseKey = base.LicenseNumber collate Cyrillic_General_CI_AS
where base.Deactivated = 0 

*/
GO
