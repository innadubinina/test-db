SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Tatiana Didenko
-- Create date: 20121203
-- Description:	Check available licenses and compare with limit
-- =============================================
CREATE procedure [log].[pCheckAvailableLicenses]
    @mode int = 0   --  0 = default, check the license count
                    --  1 = push output recordset
AS
BEGIN
SET NOCOUNT ON;
set ansi_warnings off;

----  routine logging and error trapping variables  ------------------
declare @errMsg varchar(max), @errNum int;

-- declare @trancount int;     set @trancount = @@trancount    --  outlevel trancount    
declare @intResult int;     set @intResult = -1;            --  routine fail status;
------------------------------------------------------------------  // 

begin try

    declare @freeLicensesAlertLimit int;  --    set @freeLicensesAlertLimit = 10000;  -- default
    set @freeLicensesAlertLimit = (select cast(value as int) from [settings].[options] where Name = 'FreeLicensesAlertLimit');
    if @freeLicensesAlertLimit is null set @freeLicensesAlertLimit = 1000;  -- default
 
 
if @mode = 0
begin
    if not exists 
    ( 
        select ProductName, Reserved, Used, (reserved - used) as Available
        from (
            select pr.name as ProductName, count(ln.id) as Reserved, count(cls.id) as Used
            from products.product                pr
                join licenses.[group]            gr on pr.id = gr.productID
                join licenses.license            ln on gr.id = ln.groupID
                left join clients.clientLicense cls on ln.id = cls.licenseID
            where pr.name='soda pdf 3d reader mac'
            group by pr.name
            ) A
        where (reserved - used) <= @freeLicensesAlertLimit
    )
    begin
        set @intResult = 0
    end
    else
    begin
        set @intResult = 1  --  alert must be raised
    end
   print @intResult;

end
else
begin
    select cast (ProductName as nvarchar(64)) ProductName, cast (Reserved as nvarchar(10)) Reserved, cast (Used as nvarchar(10)) Used, cast ((reserved - used) as nvarchar(10)) as Available
    from (
        select pr.name as ProductName, count(ln.id) as Reserved, count(cls.id) as Used
        from products.product                pr
            join licenses.[group]            gr on pr.id = gr.productID
            join licenses.license            ln on gr.id = ln.groupID
            left join clients.clientLicense cls on ln.id = cls.licenseID
        where pr.name='soda pdf 3d reader mac'
        group by pr.name
       ) A
    where (reserved - used) <= @freeLicensesAlertLimit
  
  
   if @@ROWCOUNT = 0
        set @intResult = 0
    else 
        set @intResult = 1
end
      
end try
   
begin catch

    select @errNum = error_number(), @errMsg = error_message();
    print @errMsg;
    exec [Log].[pError] @action = 1, @number = @errNum, @message = @errMsg

    -- output error result
    set @intResult = case 
        when @errNum > 0 then (-1)*@errNum 
        when @errNum = 0 then -1 
        else @errNum 
        end
    
    -- raiserror (@errMsg , 16, 1)
    
end catch; 
    
    return @intResult;
    
END

/*  TEST ZONE
  --  select * from [Log].[Error]

  -- test1
  declare @intResult int;
  exec @intResult = [log].[pCheckAvailableLicenses];
  select '@intResult:' + cast (@intResult as nvarchar(32))
  

 /*
  -- test2
  declare @intResult int;
  -- declare @tblResult table (
  create table #tblResult (
      productName nvarchar(64)
    , reserved int
    , used int
    , available int
    );

  begin try    
    insert #tblResult
    exec @intResult = [log].[pCheckAvailableLicenses];
  end try
  begin catch

  end catch
  
  select '@intResult:' + cast (@intResult as nvarchar(32))
  if @intResult = 1
  select * from #tblResult;
  
  drop table #tblResult;
  
  
  --    test 3
  [log].[pCheckAvailableLicenses] 1
*/  
  


*/
GO
