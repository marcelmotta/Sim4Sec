/* DATABASE PREPARATION */

-- CREATE DATABASE WITH DEFAULT SETTINGS
USE [master];

CREATE DATABASE [Sim4Sec_DW];

USE [Sim4Sec_DW];

SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER ON;

-- CREATE FREGUESIA DIMENSION
CREATE TABLE [Dim_Freg] (
	SK_FregID int PRIMARY KEY,
	FK_MunID int,
	codDICOFRE nvarchar(6),
	codFreguesia nvarchar(255),
	codUsoSolo nvarchar(255),
	codÁreaFreg float
)

-- CREATE MUNICIPIO DIMENSION
CREATE TABLE [Dim_Mun] (
	SK_MunID int PRIMARY KEY,
	codDICO int,
	codDistrito nvarchar(255),
	codMunicípio nvarchar(255),
	codÁreaMun float
)

-- CREATE POSTOSGNR DIMENSION
CREATE TABLE [Dim_Postos] (
	SK_PostoID int PRIMARY KEY,
	FK_FregID int,
	posPostoID int,
	posActuação nvarchar(255),
	posComando nvarchar(255),
	posDestacamento nvarchar(255),
	posPosto nvarchar(255),
	posEfectivo int
)

-- CREATE CRIMES DIMENSION
CREATE TABLE [Dim_Crime] (
	SK_CrimeID int PRIMARY KEY,
	criClasse nvarchar(255),
	criSubclasse nvarchar(255),
	criDescrição nvarchar(255)
)

-- CREATE SOCIOECONOMICO DIMENSION
CREATE TABLE [Dim_SocEcon] (
	SK_SocEconID int PRIMARY KEY,
	socÍndice nvarchar(255),
	socDescrição nvarchar(255)
)

-- CREATE ANO TABLE
CREATE TABLE [Dim_Ano] (
	SK_AnoID int PRIMARY KEY,
	anoAno int
)

-- CREATE SEGURANÇA FACT
CREATE TABLE [Fact_Segurança] (
	FK_FregID int,
	FK_PostoID int,
	FK_AnoID int,
	PopulaçãoFreg int,
	DensDemográfica float,
	PolporHabitante float

	CONSTRAINT [PK_Measure_Seg] PRIMARY KEY CLUSTERED (
	[FK_FregID] ASC,
	[FK_PostoID] ASC,
	[FK_AnoID] ASC
)
)
ON [PRIMARY]
;

-- CREATE CRIMES FACT
CREATE TABLE [Fact_Crime] (
	FK_CrimeID int,
	FK_MunID int,
	FK_PostoID int,
	FK_AnoID int,
	Eventos int

	CONSTRAINT [PK_Measure_Cri] PRIMARY KEY CLUSTERED (
	[FK_CrimeID] ASC,
	[FK_MunID] ASC,
	[FK_PostoID] ASC,
	[FK_AnoID] ASC
)
)
ON [PRIMARY]
;

-- CREATE DEMOGRAFIA FACT
CREATE TABLE [Fact_Demografia] (
	FK_SocEconID int,
	FK_MunID int,
	FK_AnoID int,
	ValorÍndice float

	CONSTRAINT [PK_Measure_Dem] PRIMARY KEY CLUSTERED (
	[FK_SocEconID] ASC,
	[FK_MunID] ASC,
	[FK_AnoID] ASC
)
)
ON [PRIMARY]
;

