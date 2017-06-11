SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [clients].[pPreClientWaitForLicense_MarkAsReadyToSend]
    @productName nvarchar(128)   
as
--  ==================================================================
--  create: 20130129 Mykhaylo Tytarenko
--  modify:
--  description: mark all nonMarked nonDeleted records by given product as readyToSend
--  ==================================================================
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  //

begin try

    if (@trancount > 0) SAVE TRANSACTION pPreClient_MarkAsReadyToSend
    else BEGIN TRAN

    if exists (
        select * from [clients].[preClientWaitForLicense]
        where productName = @productName and deleted = 0 and readyToSend = 0
        )
    begin
        update [clients].[preClientWaitForLicense]
        set readyToSend = 1
        where productName = @productName and deleted = 0 and readyToSend = 0
    
        print @@rowcount;
    end
    else
        print 'no preclient to mark as readyToSend'


    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION pPreClient_MarkAsReadyToSend


    select @errNum = error_number(), @errMsg = error_message();
    if xact_state() <> -1 exec [log].[pError] @number = @errNum, @message = @errMsg, @spid = @@spid
    print @errMsg;

    -- output error result
    set @intResult = case 
        when @errNum > 0 then (-1)*@errNum
        when @errNum = 0 then -1
        else @errNum
        end

end catch;

/*  TEST ZONE
--  select * from [clients].[preClientWaitForLicense]; select * from products.product
--  select top 10 * from log.error


--  EXECUTE
    declare @intResult int;
    -- set xact_abort on
    begin tran
    exec @intResult = [clients].[pPreClientWaitForLicense_MarkAsReadyToSend] @productName = 'pdf architect create'
    select @intResult as intResult
    exec [clients].[pPreClientWaitForLicense]
    rollback

*/

return @intResult;
END
GO
