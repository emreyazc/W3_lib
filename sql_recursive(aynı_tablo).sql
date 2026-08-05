

	/* yukarýdan aþaðý */
	
	WITH CTE AS 
	(
		SELECT
			ASSETCAT_ID, 
			ASSETCAT
		FROM
			workcube_test.workcube_test.ASSET_CAT
		WHERE 
			ASSETCAT_MAIN_ID = 1945
	UNION ALL
		SELECT
			t.ASSETCAT_ID,
			t.ASSETCAT
		FROM 
			workcube_test.workcube_test.ASSET_CAT t
			INNER JOIN CTE ON t.ASSETCAT_MAIN_ID = CTE.ASSETCAT_ID
	)
	SELECT
		ASSETCAT_ID,
		ASSETCAT
	FROM CTE;

	/* aþaðýdan yukarý*/

	DECLARE @ID INT = 1948
	;WITH AssetTree AS
	(
		SELECT 
			C.ASSETCAT_ID, 
			C.ASSETCAT, 
			C.ASSETCAT_MAIN_ID,
			C.ASSETCAT_PATH,
			0 AS [Level]
			FROM workcube_test.workcube_test.ASSET_CAT C
			WHERE C.ASSETCAT_ID=@ID OR (@ID IS NULL AND C.ASSETCAT_MAIN_ID IS NULL)
		UNION ALL
			SELECT 
				S.ASSETCAT_ID, S.ASSETCAT, S.ASSETCAT_MAIN_ID, S.ASSETCAT_PATH,T.[Level]+1
			FROM 
				AssetTree T
				INNER JOIN workcube_test.workcube_test.ASSET_CAT S ON s.ASSETCAT_ID=t.ASSETCAT_MAIN_ID
	)
	SELECT *
	FROM AssetTree
	ORDER BY [Level] ASC;