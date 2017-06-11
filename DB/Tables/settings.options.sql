CREATE TABLE [settings].[options]
(
[id] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[name] [nvarchar] (128) COLLATE Cyrillic_General_CI_AS NOT NULL,
[value] [nvarchar] (256) COLLATE Cyrillic_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [settings].[options] ADD CONSTRAINT [PK_SettingsOptions] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [settings].[options] ADD CONSTRAINT [UNIQ_SettingsOptions_Name] UNIQUE NONCLUSTERED  ([name]) ON [PRIMARY]
GO
