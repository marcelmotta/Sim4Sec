-- -- FIX LEADING ZEROES IN DICOFRE FIELD AND ROUND VALUES FOR POPULATION FORECASTS

IF OBJECT_ID('tempdb.dbo.##tempPop') IS NOT NULL
DROP TABLE [##tempPop]
CREATE TABLE [##tempPop] (
    [DICOFRE] nvarchar(6),
    [Nome] nvarchar(255),
    [Pop_2011] float,
    [Pop_2030] float,
    [Pop_2040] float
)
INSERT INTO ##tempPop
SELECT 
	CASE 
		WHEN LEN([pop_summary].DICOFRE) IN (3,5) THEN '0' + [pop_summary].DICOFRE
		ELSE [pop_summary].DICOFRE
	END AS DICOFRE
      ,[Nome]
      ,[Pop_2011]
      ,ROUND([Pop_2030],0) AS Pop_2030
      ,ROUND([Pop_2040],0) AS Pop_2040
  FROM [pop_summary]

TRUNCATE TABLE [pop_summary]

INSERT INTO [pop_summary]
SELECT * FROM ##tempPop

-- FIND DISTRICT CODES
INSERT INTO [cod_freg]
SELECT DISTINCT 
	LEFT([socecon_data2011].DICO,2) AS DI, 
	[crime_hist].Distrito, [socecon_data2011].DICO, 
	[socecon_data2011].Município,
	[pop_summary].DICOFRE, 
	[pop_summary].Nome AS Freguesia
FROM [socecon_data2011]

LEFT JOIN [crime_hist]
ON [crime_hist].Município = [socecon_data2011].Município
LEFT JOIN [pop_summary]
ON [socecon_data2011].DICO =
	CASE
		WHEN LEN([pop_summary].DICOFRE) > 4 THEN LEFT([pop_summary].DICOFRE,4)
		ELSE NULL
	END
COLLATE Latin1_general_CI_AI
ORDER by DICO ASC