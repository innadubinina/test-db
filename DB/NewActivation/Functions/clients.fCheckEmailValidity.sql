SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function clients.fCheckEmailValidity (@email nvarchar(128))
returns bit 
as
BEGIN
    return case when @email like '%_@_%.__%' then 1 else 0 end  
END
/*  TEST ZONE
    select clients.fCheckEmailValidity ('dddss')
    select clients.fCheckEmailValidity ('1@c.qu')

*/
GO
