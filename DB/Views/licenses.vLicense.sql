SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [licenses].[vLicense] with schemabinding
as
--  ==================================================================
--  create: 20120725 Mykhaylo Tytarenko 
--  modify:
--  description: provide access to license attributes, stored in 'licenses.group' table.
--  '[licenses].[license]' table
--  ==================================================================
select
      base.id
    , base.groupID
    , base.[key]
    , base.readyForActivation
    , base.deactivated

    , coalesce(base.allowedActivationCount, gr.allowedActivationCount) [allowedActivationCount]
    , coalesce(base.lifeTimeDays, gr.lifeTimeDays)                     [lifeTimeDays]
    , coalesce(base.serverActivationCount, gr.serverActivationCount)   [serverActivationCount]
	, 'test' as test
    , base.createDate
    , base.modifyDate
    , base.history
from  licenses.license base
    join licenses.[group] gr on gr.id = base.groupID

/*  TEST ZONE
--  select * from licenses.license
--  select * from licenses.vLicense
*/


GO
