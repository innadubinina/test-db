SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [licenses].[fActivationTie] (@activationID int)
RETURNS TABLE
AS RETURN
(
 with cteChildTie (ID, parentID, level) as (
    select ID, parentID, 0 as level
    from licenses.activation
    where ID  = @activationID
    
    union all
    select act.ID, act.parentID, child.level + 1 as level
    from licenses.activation act
        join cteChildTie child on child.parentID = act.ID
    ),
  cteParentTie (ID, parentID, level) as (
    select ID, parentID, 0 as level
    from licenses.activation
    where ID  = @activationID
    
    union all
    select act.ID, act.parentID, parent.level - 1 as level
    from licenses.activation act
        join cteParentTie parent on parent.ID = act.parentID
    )
select ID, parentID, level from cteChildTie
union
select ID, parentID, level from cteParentTie
)
GO
