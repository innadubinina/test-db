SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [clients].[vClientLicense] 
as
select base.id
     , base.clientID
     , base.licenseID
     , coalesce(base.optIn, cl.optIn) [optIn]
     , base.createDate
from clients.clientLicense base
	join clients.client cl on cl.id = base.clientID
GO
