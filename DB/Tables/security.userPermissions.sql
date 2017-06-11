CREATE TABLE [security].[userPermissions]
(
[ID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[UserID] [int] NOT NULL,
[PageID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [security].[userPermissions] ADD CONSTRAINT [PK_UserPermissions] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_UserID_PageID_UserPermissions] ON [security].[userPermissions] ([UserID], [PageID]) ON [PRIMARY]
GO
ALTER TABLE [security].[userPermissions] ADD CONSTRAINT [FK_UserPermissions_Pages] FOREIGN KEY ([PageID]) REFERENCES [security].[pages] ([Id])
GO
ALTER TABLE [security].[userPermissions] ADD CONSTRAINT [FK_UserPermissions_Users] FOREIGN KEY ([UserID]) REFERENCES [security].[users] ([Id])
GO
