SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [licenses].[vClientProductLicenses]
as
select cl.id as 'clientID'
     , cl.email
     , cl.firstName
     , cl.lastName
     , cl.Optin
     , cl.isValidEmail
     , cl.createDate as clientCreateDate
     , lnsCl.createDate as clientLicenseCreateDate
     , lns.id as 'licenseID'
     , lns.[key]
     , gr.id as 'groupID'
     , gr.productID
     , cl.ipAddress  
     , cl.languageISO2
from clients.client               cl 
	join clients.clientLicense lnsCl on cl.id = lnsCl.clientID
	join licenses.license        lns on lnsCl.licenseID = lns.id
	join licenses.[group]         gr on lns.groupID = gr.id
GO
