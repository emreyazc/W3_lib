
CREATE TABLE workcube_test.workcube_test.DASHBOARD_WIDGETS (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    TITLE NVARCHAR(255) NULL,
    FILE_PATH NVARCHAR(255) NULL, -- Örnek: 'charts/chart_order_by_city.cfm'
    MODULE_ID INT NULL,           -- CRM = 1, ERP = 2 vs.
    IS_ACTIVE BIT NULL DEFAULT 1
)
