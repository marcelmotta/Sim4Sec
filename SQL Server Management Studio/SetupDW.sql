/* DATABASE PREPARATION */

-- CREATE DATABASE WITH DEFAULT SETTINGS
USE [master];

CREATE DATABASE [Sim4Sec_DW];

USE [Sim4Sec_DW];

SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER ON;

-- CREATE FREGUESIA DIMENSION
CREATE TABLE [Dim_Freg] (
	SK_FregID int identity PRIMARY KEY,
	FK_MunID int,
	codDICOFRE nvarchar(6),
	codFreguesia nvarchar(255),
	codUsoSolo nvarchar(255),
	codÁreaFreg float
)

-- CREATE MUNICIPIO DIMENSION
CREATE TABLE [Dim_Mun] (
	SK_MunID int identity PRIMARY KEY,
	codDICO nvarchar(4),
	codDistrito nvarchar(255),
	codMunicípio nvarchar(255),
	codÁreaMun float
)

-- CREATE POSTOSGNR DIMENSION
CREATE TABLE [Dim_Postos] (
	SK_PostoID int identity PRIMARY KEY,
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
	SK_CrimeID int identity PRIMARY KEY,
	criClasse nvarchar(255),
	criSubclasse nvarchar(255),
	criDescrição nvarchar(255)
)

-- CREATE SOCIOECONOMICO DIMENSION
CREATE TABLE [Dim_SocEcon] (
	SK_SocEconID int identity PRIMARY KEY,
	socÍndice nvarchar(255),
	socDescrição nvarchar(255)
)

-- CREATE ANO TABLE
CREATE TABLE [Dim_Ano] (
	SK_AnoID int identity PRIMARY KEY,
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

--ADD FOREIGN KEYS CONTRAINTS FOR FACT_SEGURANÇA
ALTER TABLE [dbo].[Fact_Segurança]  WITH CHECK ADD  CONSTRAINT [Measure_Seg-Dim_Freg] FOREIGN KEY([FK_FregID])
REFERENCES [dbo].[Dim_Freg] ([SK_FregID])

ALTER TABLE [dbo].[Fact_Segurança]  WITH CHECK ADD  CONSTRAINT [Measure_Seg-Dim_Postos] FOREIGN KEY([FK_PostoID])
REFERENCES [dbo].[Dim_Postos] ([SK_PostoID])

ALTER TABLE [dbo].[Fact_Segurança]  WITH CHECK ADD  CONSTRAINT [Measure_Seg-Dim_Ano] FOREIGN KEY([FK_AnoID])
REFERENCES [dbo].[Dim_Ano] ([SK_AnoID])

--ADD FOREIGN KEYS CONTRAINTS FOR FACT_CRIME
ALTER TABLE [dbo].[Fact_Crime]  WITH CHECK ADD  CONSTRAINT [Measure_Cri-Dim_Crime] FOREIGN KEY([FK_CrimeID])
REFERENCES [dbo].[Dim_Crime] ([SK_CrimeID])

ALTER TABLE [dbo].[Fact_Crime]  WITH CHECK ADD  CONSTRAINT [Measure_Cri-Dim_Postos] FOREIGN KEY([FK_PostoID])
REFERENCES [dbo].[Dim_Postos] ([SK_PostoID])

ALTER TABLE [dbo].[Fact_Crime]  WITH CHECK ADD  CONSTRAINT [Measure_Cri-Dim_Ano] FOREIGN KEY([FK_AnoID])
REFERENCES [dbo].[Dim_Ano] ([SK_AnoID])

--ADD FOREIGN KEYS CONTRAINTS FOR FACT_DEMOGRAFIA
ALTER TABLE [dbo].[Fact_Demografia]  WITH CHECK ADD  CONSTRAINT [Measure_Dem-Dim_SocEcon] FOREIGN KEY([FK_SocEconID])
REFERENCES [dbo].[Dim_SocEcon] ([SK_SocEconID])

ALTER TABLE [dbo].[Fact_Demografia]  WITH CHECK ADD  CONSTRAINT [Measure_Dem-Dim_Mun] FOREIGN KEY([FK_MunID])
REFERENCES [dbo].[Dim_Mun] ([SK_MunID])

ALTER TABLE [dbo].[Fact_Demografia]  WITH CHECK ADD  CONSTRAINT [Measure_Dem-Dim_Ano] FOREIGN KEY([FK_AnoID])
REFERENCES [dbo].[Dim_Ano] ([SK_AnoID])

-- ADD FOREING KEY CONSTAINT FOR DIM_FREG
ALTER TABLE [dbo].[Dim_Freg]  WITH CHECK ADD  CONSTRAINT [FK_Freg_Mun] FOREIGN KEY([FK_MunID])
REFERENCES [dbo].[Dim_Mun] ([SK_MunID])


/*
-- WIPE DATA FROM DW
TRUNCATE TABLE [Fact_Segurança]
TRUNCATE TABLE [Fact_Crime]
TRUNCATE TABLE [Fact_Demografia]

DELETE FROM [Dim_Ano]
DELETE FROM [Dim_Crime]
DELETE FROM [Dim_Freg]
DELETE FROM [Dim_Mun]
DELETE FROM [Dim_Postos]
DELETE FROM [Dim_SocEcon]

--RESET IDENTITY COUNT
DBCC CHECKIDENT ('[Dim_Ano]', RESEED, 0);
DBCC CHECKIDENT ('[Dim_Crime]', RESEED, 0);
DBCC CHECKIDENT ('[Dim_Freg]', RESEED, 0);
DBCC CHECKIDENT ('[Dim_Mun]', RESEED, 0);
DBCC CHECKIDENT ('[Dim_Postos]', RESEED, 0);
DBCC CHECKIDENT ('[Dim_SocEcon]', RESEED, 0);

-- DROP DW IN USE
USE master;
ALTER DATABASE [Sim4Sec_DW] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [Sim4Sec_DW] ;