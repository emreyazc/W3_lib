
	-- =====================================
--  1) BI_ENTITIES TABLOSU
-- =====================================

CREATE TABLE workcube_tenteks.workcube_tenteks.BI_ENTITIES (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    
    -- MSSQL'deki GERÇEK TABLO ADI (ör: OFFER_HEADER, SALES_ORDER)
    REAL_TABLE_NAME NVARCHAR(128) NOT NULL,
    
    -- Self-service BI'de KULLANICILARA GÖSTERÝLECEK AD (ör: "Teklif Baþlýk")
    DISPLAY_NAME NVARCHAR(256) NOT NULL,
    
    -- Tablo/Entity ile ilgili AÇIKLAMA
    [DESCRIPTION] NVARCHAR(1000) NULL,
    
    -- Aktif/Pasif kontrolü (1 = aktif, 0 = pasif)
    IS_ACTIVE BIT NOT NULL DEFAULT 1,
    
    -- Kayýt oluþturma bilgileri
    CREATED_AT DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CREATED_BY NVARCHAR(100) NULL,
    
    -- Kayýt güncelleme bilgileri
    UPDATED_AT DATETIME2 NULL,
    UPDATED_BY NVARCHAR(100) NULL
);

-- Opsiyonel: REAL_TABLE_NAME üzerinde arama yapacaksanýz indeks
CREATE INDEX IDX_BI_ENTITIES_REAL_TABLE_NAME 
    ON workcube_tenteks.workcube_tenteks.BI_ENTITIES (REAL_TABLE_NAME);

-- =====================================
--  2) BI_FIELDS TABLOSU
-- =====================================

CREATE TABLE workcube_tenteks.workcube_tenteks.BI_FIELDS (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Hangi BI_ENTITIES kaydý (tablo) ile iliþkili?
    ENTITY_ID INT NOT NULL,
    
    -- MSSQL'deki GERÇEK KOLON ADI (ör: OTHER_MONEY, ORDER_DATE)
    REAL_COLUMN_NAME NVARCHAR(128) NOT NULL,
    
    -- Kullanýcý dostu kolon adý (ör: "Döviz Tutarý")
    DISPLAY_NAME NVARCHAR(256) NOT NULL,
    
    -- Açýklama / Ýpuçlarý
    [DESCRIPTION] NVARCHAR(1000) NULL,
    
    -- Veri Tipi (ör: 'numeric', 'datetime', 'nvarchar')
    DATA_TYPE NVARCHAR(50) NULL,
    
    -- Toplama / hesaplama þekli (ör: 'SUM', 'COUNT', 'NONE')
    AGGREGATION_TYPE NVARCHAR(20) NULL,
    
    -- Ölçü (Measure) mü?  (1 = Evet, 0 = Hayýr)
    IS_MEASURE BIT NOT NULL DEFAULT 0,
    
    -- Kullanýcýya görünür mü? (1 = görünür, 0 = gizli)
    IS_VISIBLE BIT NOT NULL DEFAULT 1,
    
    -- Kayýt oluþturma bilgileri
    CREATED_AT DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CREATED_BY NVARCHAR(100) NULL,
    
    -- Kayýt güncelleme bilgileri
    UPDATED_AT DATETIME2 NULL,
    UPDATED_BY NVARCHAR(100) NULL
);

-- BI_FIELDS -> BI_ENTITIES iliþki tanýmý
ALTER TABLE workcube_tenteks.workcube_tenteks.BI_FIELDS
ADD CONSTRAINT FK_BI_FIELDS_ENTITY
    FOREIGN KEY (ENTITY_ID) REFERENCES workcube_tenteks.workcube_tenteks.BI_ENTITIES (ID)
    ON DELETE CASCADE;


-- =====================================
--  3) BI_RELATIONS TABLOSU (Opsiyonel)
-- =====================================

CREATE TABLE workcube_tenteks.workcube_tenteks.BI_RELATIONS (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    
    SOURCE_ENTITY_ID INT NOT NULL,
    TARGET_ENTITY_ID INT NOT NULL,
    
    -- Kaynak tablodaki kolon (ör: 'customer_id')
    SOURCE_COLUMN_NAME NVARCHAR(128) NOT NULL,
    
    -- Hedef tablodaki kolon (ör: 'id')
    TARGET_COLUMN_NAME NVARCHAR(128) NOT NULL,
    
    -- Ýliþki türü ("1-1", "1-n", "n-1", vb.)
    RELATION_TYPE NVARCHAR(10) NOT NULL,
    
    -- Kayýt oluþturma bilgileri
    CREATED_AT DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CREATED_BY NVARCHAR(100) NULL,
    
    -- Kayýt güncelleme bilgileri
    UPDATED_AT DATETIME2 NULL,
    UPDATED_BY NVARCHAR(100) NULL
);

-- Kaynak tarafýn (SOURCE_ENTITY_ID) iliþkisi
ALTER TABLE workcube_tenteks.workcube_tenteks.BI_RELATIONS
ADD CONSTRAINT FK_BI_RELATIONS_SOURCE_ENTITY
    FOREIGN KEY (SOURCE_ENTITY_ID) REFERENCES workcube_tenteks.workcube_tenteks.BI_ENTITIES (ID)
    ON DELETE CASCADE;

-- Hedef tarafýn (TARGET_ENTITY_ID) iliþkisi
ALTER TABLE workcube_tenteks.workcube_tenteks.BI_RELATIONS
ADD CONSTRAINT FK_BI_RELATIONS_TARGET_ENTITY
    FOREIGN KEY (TARGET_ENTITY_ID) REFERENCES workcube_tenteks.workcube_tenteks.BI_ENTITIES (ID)
    ON DELETE CASCADE;
