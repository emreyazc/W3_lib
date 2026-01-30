
	CREATE TABLE workcube_test.workcube_test.DASHBOARD_USER_LAYOUT (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    EMPLOYEE_ID INT NOT NULL, -- Kullanýcýyý temsil eder (örn: session.ep.userid)
    DASHBOARD_KEY VARCHAR(100) NOT NULL, -- Hangi dashboard (örn: 'HolisticLiveDashboard')
    GRAPH_FUSEACTION VARCHAR(150) NOT NULL, -- Örn: 'report.orders_graph'
    CUSTOM_TITLE NVARCHAR(200), -- Kullanýcýnýn kutucuða verdiði baþlýk (opsiyonel)
    POSITION_X INT NOT NULL, -- Grid X pozisyonu
    POSITION_Y INT NOT NULL, -- Grid Y pozisyonu
    WIDTH INT NOT NULL, -- Grid geniþlik (w)
    HEIGHT INT NOT NULL, -- Grid yükseklik (h)
    SORT_ORDER INT NULL, -- Sýraya göre dizim (isteðe baðlý)
    IS_ACTIVE BIT DEFAULT 1, -- Kullanýcý bu kutucuðu görünür mü yaptý?
    CREATED_AT DATETIME DEFAULT GETDATE() -- Oluþturulma tarihi
);