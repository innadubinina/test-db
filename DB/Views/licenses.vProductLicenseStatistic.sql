SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [licenses].[vProductLicenseStatistic]
with schemabinding
as
select pr.name as ProductName, count(ln.id) as Reserved, count(cls.id) as Used
from products.product                pr
    join licenses.[group]            gr on pr.id = gr.productID
    join licenses.license            ln on gr.id = ln.groupID
    left join clients.clientLicense cls on ln.id = cls.licenseID
group by pr.name
/*  TEST ZONE
    select * from [licenses].[vProductLicenseStatistic]
*/
GO
