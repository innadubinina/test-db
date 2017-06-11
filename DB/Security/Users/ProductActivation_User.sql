IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ProductActivation_User')
CREATE LOGIN [ProductActivation_User] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [ProductActivation_User] FOR LOGIN [ProductActivation_User]
GO
