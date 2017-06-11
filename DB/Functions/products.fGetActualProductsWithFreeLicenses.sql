SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [products].[fGetActualProductsWithFreeLicenses] ()
returns table with schemabinding
as return
(
    --  logic before 20130920
    --  ---------------------
    --  select [id], [name], [title], [description], [groupID], [disabled], [hasLifetime], [externalID], [createDate]
    --  from products.product
    --  where name='soda pdf 3d reader mac'

    --  // logic before 20130920
    select [id], [name], [title], [description], [groupID], [disabled], [hasLifetime], [externalID], [isFree], [createDate]
    from products.product
    where [isFree] = 1
    

/*  TEST ZONE
    select * from [products].[fGetActualProductsWithFreeLicenses] ()
*/
)
GO
