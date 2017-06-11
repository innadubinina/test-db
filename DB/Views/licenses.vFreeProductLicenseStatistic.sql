SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [licenses].[vFreeProductLicenseStatistic]
with schemabinding
as
select pr.name as ProductName, count(ln.id) as Reserved, count(cls.id) as Used
from products.product                pr
    left join licenses.[group]            gr on pr.id = gr.productID
    left join licenses.license            ln on gr.id = ln.groupID
    left join clients.clientLicense cls on ln.id = cls.licenseID
where pr.name in (select name from products.fGetActualProductsWithFreeLicenses())
group by pr.name
/*  TEST ZONE
    select * from [licenses].[vFreeProductLicenseStatistic]
*/

GO
