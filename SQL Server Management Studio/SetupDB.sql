/* DATABASE PREPARATION */

-- CREATE DATABASE WITH DEFAULT SETTINGS
USE [master];

CREATE DATABASE [Sim4Sec];

USE [Sim4Sec];

SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER ON;

-- CREATE CRIME HISTORY TABLE
CREATE TABLE [crime_hist] (
    [Território] nvarchar(255),
    [Distrito] nvarchar(255),
    [Município] nvarchar(255),
    [Ano] float,
    [Eventos] float,
	[Índice] nvarchar(255)
)

-- CREATE CRIME METADATA TABLE
CREATE TABLE [crime_meta] (
    [Classe] nvarchar(255),
    [Subclasse] nvarchar(255),
    [Crime] nvarchar(255),
    [Descrição] nvarchar(255),
	[Índice] nvarchar(255)
)

-- CREATE SOCECON DATA TABLE
CREATE TABLE [socecon_data2011] (
	[Município] nvarchar(255),
	[DICO] nvarchar(4),
	[Índice] nvarchar(255),
	[Valor] float
)

-- CREATE SOCECON METADATA TABLE
CREATE TABLE [socecon_meta] (
	[Índice] nvarchar(255),
	[Descrição] nvarchar(255)
)

-- CREATE POPULATION SUMMARY TABLE
CREATE TABLE [pop_summary] (
    [DICOFRE] nvarchar(6),
    [Nome] nvarchar(255),
    [Pop_2011] float,
    [Pop_2030] float,
    [Pop_2040] float
)

-- CREATE POPULATION FULL TABLE
CREATE TABLE [pop_full] (
    [DICOFRE] nvarchar(6),
    [Nome] nvarchar(255),
    [Ano] int,
	[ValorPop] int
)

-- CREATE FREG AREA TABLE
CREATE TABLE [area_freg] (
    [DICOFRE] nvarchar(255),
    [ÁreaFreg] float
)

-- CREATE DICOFRE TABLE
CREATE TABLE [geo_full] (
	[DI] nvarchar(2),
	[Distrito] nvarchar(255),
	[DICO] nvarchar(4),
	[Município] nvarchar(255),
	[DICOFRE] nvarchar(6),
	[Freguesia] nvarchar(255),
	[ÁreaFreg] float
)

-- CREATE POLICE TABLE
CREATE TABLE [efectivos] (
	[DICOFRE] nvarchar(6),
	[Actuação] nvarchar(6),
	[Comando] nvarchar(255),
	[Destacamento] nvarchar(255),
	[Posto] nvarchar(255),
	[PostoID] nvarchar(11),
	[Efectivo] nvarchar(255)
)

-- CREATE LAND USAGE TABLE
CREATE TABLE [uso_solo] (
    [DICOFRE] nvarchar(255),
    [Classe] nvarchar(255),
    [Area_Km2] float,
    [Area_ha] float,
    [Ano] float
)
