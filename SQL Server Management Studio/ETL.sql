/** ETL - Data Extraction and Transformation *//

USE [Sim4Sec];

-- FIX LEADING ZEROES IN DICOFRE FIELD AND ROUND VALUES FOR POPULATION FORECASTS
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

-- JOIN CRIME MEASURES AND METADATA
IF OBJECT_ID('tempdb.dbo.##tempCrime') IS NOT NULL
DROP TABLE [##tempCrime]
CREATE TABLE [##tempCrime] (
    [Território] nvarchar(255),
    [Distrito] nvarchar(255),
    [Município] nvarchar(255),
    [Ano] float,
    [Eventos] float,
	[Índice] nvarchar(255)
)

INSERT INTO [##tempCrime]
SELECT
	[crime_hist].Território,
	[crime_hist].Distrito,
	[crime_hist].Município,
	[crime_hist].Ano,
	[crime_hist].Eventos,
	[crime_meta].Descrição AS Índice
FROM [crime_hist]

LEFT JOIN [crime_meta]
ON [crime_hist].Índice = [crime_meta].Índice

TRUNCATE TABLE [crime_hist]

INSERT INTO [crime_hist]
SELECT * FROM ##tempCrime
ORDER BY [##tempCrime].Território, [##tempCrime].Distrito, [##tempCrime].Município ASC

-- FIND DISTRICT CODES
INSERT INTO [geo_full]
SELECT DISTINCT 
	LEFT([socecon_data2011].DICO,2) AS DI, 
	[crime_hist].Distrito, [socecon_data2011].DICO, 
	[socecon_data2011].Município,
	[pop_summary].DICOFRE, 
	[pop_summary].Nome AS Freguesia,
	CAST(ROUND([area_freg].ÁreaFreg,2) AS DECIMAL(10,2)) AS ÁreaFreg
FROM [socecon_data2011]

LEFT JOIN [crime_hist]
ON [crime_hist].Município = [socecon_data2011].Município
LEFT JOIN [pop_summary]
ON [socecon_data2011].DICO =
	CASE
		WHEN LEN([pop_summary].DICOFRE) > 4 THEN LEFT([pop_summary].DICOFRE,4)
		ELSE NULL
	END
LEFT JOIN [area_freg]
ON [area_freg].DICOFRE = [pop_summary].DICOFRE

COLLATE Latin1_general_CI_AI
WHERE [socecon_data2011].Índice = 'Area'
ORDER by DI, DICO, DICOFRE ASC

/** ETL - Data Load *//

USE [Sim4Sec_DW];

-- LOAD DIM_ANO
INSERT INTO [Sim4Sec_DW].[dbo].[Dim_Ano] (
	anoAno
)
SELECT DISTINCT
	[crime_hist].Ano
FROM [Sim4Sec].[dbo].[crime_hist]
UNION
SELECT '2030'
UNION
SELECT '2040'

-- LOAD DIM_CRIME
INSERT INTO [Sim4Sec_DW].[dbo].[Dim_Crime] (
	criClasse,
	criSubclasse,
	criDescrição
)
SELECT
	[crime_meta].Classe,
	[crime_meta].Subclasse,
	[crime_meta].Descrição
FROM [Sim4Sec].[dbo].[crime_meta]

-- LOAD DIM_SOCECON
INSERT INTO [Sim4Sec_DW].[dbo].[Dim_SocEcon] (
	socÍndice,
	socDescrição
)
SELECT
	[socecon_meta].Índice,
	[socecon_meta].Descrição
FROM [Sim4Sec].[dbo].[socecon_meta]

-- LOAD DIM_MUN
INSERT INTO [Sim4Sec_DW].[dbo].[Dim_Mun] (
	munDICO,
	munDistrito,
	munMunicípio,
	munÁreaMun
)
SELECT
	[geo_full].DICO,
	[geo_full].Distrito,
	[geo_full].Município,
	SUM([geo_full].ÁreaFreg) AS ÁreaMun
FROM [Sim4Sec].[dbo].[geo_full]
GROUP BY [geo_full].DICO, [geo_full].Distrito,[geo_full].Município

-- LOAD DIM_FREG
INSERT INTO [Sim4Sec_DW].[dbo].[Dim_Freg] (
	FK_MunID,
	freDICOFRE,
	freFreguesia,
	freÁreaFreg
)
SELECT
	[Dim_Mun].SK_MunID,
	[geo_full].DICOFRE,
	[geo_full].Freguesia,
	[geo_full].ÁreaFreg
FROM [Sim4Sec].[dbo].[geo_full]

LEFT JOIN [Sim4Sec_DW].[dbo].[Dim_Mun]
ON [Dim_Mun].munDICO = [geo_full].DICO
ORDER BY [geo_full].DICOFRE ASC

-- LOAD DIM_POSTOS
INSERT INTO [Sim4Sec_DW].[dbo].[Dim_Postos]
SELECT 
	[efectivos].PostoID,
	[efectivos].Actuação,
	[efectivos].Comando,
	[efectivos].Destacamento,
	[efectivos].Posto,
	[efectivos].Efectivo
FROM [Sim4Sec].[dbo].[efectivos]

-- LOAD DIM_USOSOLO
INSERT INTO [Sim4Sec_DW].[dbo].[Dim_UsoSolo]
SELECT DISTINCT
	[uso_solo].Classe
FROM [Sim4Sec].[dbo].[uso_solo]

-- LOAD FACT_TERRITÓRIO
INSERT INTO [Sim4Sec_DW].[dbo].[Fact_Território]
SELECT
	[Dim_Freg].SK_FregID AS FK_FregID,
	[Dim_UsoSolo].SK_UsoSoloID AS FK_UsoSoloID,
	[Dim_Ano].SK_AnoID AS FK_Ano,
	[uso_solo].Area_Km2 AS ÁreaporSolo
FROM [Sim4Sec].[dbo].uso_solo

LEFT JOIN [Sim4Sec_DW].[dbo].[Dim_Freg]
ON [uso_solo].DICOFRE = [Dim_Freg].freDICOFRE
LEFT JOIN [Sim4Sec_DW].[dbo].[Dim_UsoSolo]
ON [uso_solo].Classe = [Dim_UsoSolo].usoClasse
LEFT JOIN [Sim4Sec_DW].[dbo].[Dim_Ano]
ON [uso_solo].Ano = [Dim_Ano].anoAno
	