SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [clients].[vPreClientWaitForLicenseStatistic]
with schemabinding
as
    select productName
        , sum (case when [readyToSend] = 0 then 1 else 0 end) as nonMarkedValue
        , sum (case when [readyToSend] = 1 then 1 else 0 end) as markedValue
    from [clients].[preClientWaitForLicense] where [deleted] = 0
    group by productName

--select
--      (select COUNT(*) as nonMarkedValue from [clients].[preClientWaitForLicense] where [deleted] = 0 and [readyToSend] = 0) as nonMarkedValue
--    , (select COUNT(*) from [clients].[preClientWaitForLicense] where [deleted] = 0 and [readyToSend] = 1) as markedValue

/*  TEST ZONE
    select * from [clients].[vPreClientWaitForLicenseStatistic]
*/
GO
