
CREATE TABLE DASHBOARD_DEFS (
    DASHBOARD_ID INT IDENTITY(1,1) PRIMARY KEY,
    DASHBOARD_NAME NVARCHAR(100) NULL,  -- Boþ olabilir
    MODULE_NAME NVARCHAR(50) NULL,      -- Boþ olabilir
    IS_PUBLIC BIT NULL,                 -- NULL -> varsayýlan private
    CREATED_BY INT NULL,                -- NULL -> sistem veya bilinmiyor
    CREATED_AT DATETIME NULL,           -- NULL -> sistem tarihini kullanýrsýn istersen
    UPDATED_AT DATETIME NULL
);