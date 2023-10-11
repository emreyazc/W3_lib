
	WITH TOP_5_SALES_EMPLOYEES 
	AS 
	(
		SELECT TOP 5
			ASSETCAT_ID, 
			ASSETCAT
		FROM 
			workcube_test.workcube_test.ASSET_CAT
		WHERE 
			ASSETCAT_ID = 1945
	)
		SELECT
			P.ASSETCAT_ID,
			P.ASSETCAT,
			E.ASSETCAT_ID,
			E.ASSETCAT
		FROM 
			TOP_5_SALES_EMPLOYEES E
			JOIN workcube_test.workcube_test.ASSET_CAT P ON P.ASSETCAT_MAIN_ID = E.ASSETCAT_ID;



	WITH recursive_cte AS 
	(
		SELECT
			ASSETCAT_ID, 
			ASSETCAT
		FROM
			workcube_test.workcube_test.ASSET_CAT
		WHERE 
			ASSETCAT_ID = 1945
	UNION ALL
		SELECT
			t.ASSETCAT_ID,
			t.ASSETCAT
		FROM 
			workcube_test.workcube_test.ASSET_CAT t
			INNER JOIN recursive_cte rc ON t.ASSETCAT_MAIN_ID = rc.ASSETCAT_ID
	)
	SELECT
	ASSETCAT_ID,
	ASSETCAT
	FROM recursive_cte;