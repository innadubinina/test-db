SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [clients].[fGetSessionByUID] (@UID uniqueidentifier)
returns table with schemabinding
as return
(
    select top 1
          base.[id]
        , [key].[private] as privateKey
        , [key].[typeID]  as keyTypeID
                    
        , base.[IPAddress]
        , base.[createDate]
    from clients.[session] base
        join clients.[key] [key] on [key].[id] = base.keyID
    where base.[uid] = @uid

/*  TEST ZONE
    -- select top 100 * from clients.session
    select * from [clients].[fGetSessionByUID] ('65A4AC3D-A045-434D-AA68-DAAFB0373586')
*/
)
GO
