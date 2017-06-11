SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  ==================================================================
--  Create: 20120801,02 Tatiana Didenko
--  Modify: 20120830 Mykhaylo Tytarenko. Add transaction scope.
--          20130129 Mykhaylo Tytarenko. New fields ipAddress and languageISO2 in the Client entity
--  Description:    returns a free license key for client
--  ==================================================================
CREATE procedure [activationService].[pClient_GetLicenseByProduct]
      @sessionUID uniqueidentifier = null  --   special for get IP Address from current session

    , @productName    varchar(128)

    , @email         nvarchar(128)
    , @firstName     nvarchar(128) = null
    , @lastName      nvarchar(128) = null
    , @optIn                   bit = null
    , @languageISO2        char(2) = null

    , @licenseKey      varchar(64) = null out
AS
BEGIN
set nocount on;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  // 
declare @licenseKeyID int, @productID int, @clientID int;

declare @ipAddress varchar(330);

begin try

    if (@trancount > 0) SAVE TRANSACTION pClientGetLicenseByProduct
    else BEGIN TRAN

    set @productID = (select id from products.product where name = @productName);   --  select * from ActivationProcess.Products

    if @productID is null
    begin
        set @errMsg = N'50032. The product <' + ltrim(rtrim(ISNULL(@productName, 'null'))) + '> was not found'
        raiserror (@errMsg , 16, 1)
    end

    set @ipAddress = (select [IPAddress] from [clients].[session] where [UID] = @sessionUID);
    
    set @clientID = (select ID from clients.client where email = @email);
    if @clientID is null
    begin               
        exec @intResult = clients.pClient @action = 1, @email = @email, @firstName = @firstName, @lastName = @lastName, @optIn = @optIn
                , @ipAddress = @ipAddress, @languageISO2 = @languageISO2        
                , @ID = @clientID OUT
    end
    
    --  check license exists
    set @licenseKey = (select top 1 [key] from [licenses].[vClientProductLicenses] where productID = @productID and clientID = @clientID);
    --  select * from [licenses].[vClientProductLicenses]

 
    --  new license
    if @licenseKey is null
    begin

        set @licenseKeyID = (
            select top 1 source.id
            from licenses.license source WITH(UPDLOCK, READPAST)
                join licenses.[group] gr on gr.ID = source.groupID
                join products.product pr on pr.id = gr.productID and pr.ID = @productID
                --  join @tblFreeLicenses fl on fl.id = source.id
            where source.id not in (select licenseID from clients.clientLicense)
            );

    
        if @licenseKeyID is null
        begin
            set @errMsg = N'50033. No available license found'
            raiserror (@errMsg , 16, 1)
        end
        
        exec @intResult = clients.pClientLicense @action = 1, @clientID = @clientID, @licenseID = @licenseKeyID, @optIn = @optIn
                    , @ID = @clientID OUT
    
         --  output param
        set @licenseKey = (select [key] from licenses.license where ID = @licenseKeyID);

    end

    if @trancount = 0 COMMIT TRANSACTION
    set @intResult = 0  --  routine success status

end try

begin catch

    if @trancount = 0 ROLLBACK TRANSACTION
    else if xact_state() <> -1 ROLLBACK TRANSACTION pClientGetLicenseByProduct
    print @errMsg;
    
    select @errNum = error_number(), @errMsg = error_message();
    if xact_state() <> -1 exec [Log].[pError] @action = 1, @number = @errNum, @message = @errMsg
    
    set @intResult = case 
        when @errNum > 0 and isnumeric(left(@errMsg, 5)) = 1 then (-1)* cast(left(@errMsg, 5) as int)
        when @errNum = 0 then -1 
        else (-1)*@errNum 
        end

    --  log preClients
    if @errMsg = N'50033. No available license found'
    begin
        declare @preClientID int;
        exec [clients].[pPreClientWaitForLicense] @action = 1
            , @productName = @productName
            , @email = @email, @firstName = @firstName, @lastName = @lastName
            , @ipAddress = @ipAddress, @languageISO2 = @languageISO2
            , @id = @preClientID out
        print @preClientID;
    end
    
end catch;
   
--http://www.devtoolshed.com/using-stored-procedures-entity-framework-scalar-return-values
select @intResult;
--
return @intResult;
END

/*
TEST ZONE

--  select * from [clients].[client]; 
--  select * from [licenses].[license];
--  select * from [products].[product];
--  select * from [clients].[clientLicense];
--  select top 10 * from log.error
--  [log].[pError] 8
--  select * from licenses.license nolock where [key] = 'ZBTAUT6DA7ERUZC2YRDV4FRD6' --  is not exists in the license pool
--  select * from licenses.license nolock where [key] = 'H22JAU7NB7YRU8CTBR7674QPN' --  is not exists in the license pool
--  select * from licenses.license nolock where [key] = 'EP4RH7JJ7UP9FZC2G59S8FK5K' --  is not exists in the license pool
--  50001. Given license <EP4RH7JJ7UP9FZC2G59S8FK5K> is not exists in the license pool
--  select  db_name(5)
kill 55

--  INSERT
declare @intResult int, @licenseKey varchar(64); 

set xact_abort on
begin tran
    exec @intResult = [activationService].[pClient_GetLicenseByProduct] @email = 'test@ya.rueeeee', @firstName = 'TestFirstName', @lastName = 'TestLastName'
        , @optIn = 1, @productName = 'pdf architect create'
        , @licenseKey = @licenseKey out
    select @intResult as intResult,  @licenseKey as licenseKey

     --select * from [clients].[clientLicense];
     --select * from [licenses].[license] where [key]=@licenseKey;
     --select * from [clients].[client]; 
rollback
    
*/
GO
