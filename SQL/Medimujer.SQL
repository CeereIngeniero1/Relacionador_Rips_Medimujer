CREATE TABLE 
RipsCodigoDX
(
[id RipsCodigoDX] int identity (1,1),
[Diagnostico Rips] [nvarchar](50) Not null,
[Documento Usuario] [nvarchar] (50) NOT NULL, 
[Id Acto Quirúrgico] [int] Not NULL,
	[Codigo Rips] [nvarchar](50) NULL,
	[Codigo Rips2] [nvarchar](50) NULL, 
	[Diagnostico Rips2] [nvarchar](50) NULL,
	[Id Tipo de Rips] [int] NULL,
	[Documento Tipo Rips] [nvarchar](50) NULL,
	[Id Finalidad Consulta] [int] NULL,
	[Id Causa Externa] [int] NULL,
	[Id Tipo de Diagnóstico Principal] [int] NULL,
	[Id Modalidad Atencion] [int] NULL,
	[Id Grupo Servicios] [int] NULL,
	[Id Servicios] [int] NULL,
	[Id Via Ingreso Usuario] [int] NULL,

)

--Para las listas AC

ALTER VIEW [dbo].[Cnsta VB Todos - Finalidad Consulta - Orden Alfabético]
AS
SELECT       Codigo AS [Id Finalidad Consulta], Codigo AS [Finalidad Consulta], [Nombre RIPS Finalidad Consulta Version2] AS [Descripción Finalidad Consulta]
FROM            dbo.[RIPS Finalidad Consulta Version2]
WHERE        (AC = N'Si')
GO

ALTER VIEW [dbo].[Cnsta VB Todos - Causa Externa - Orden Alfabético]
AS
SELECT        Codigo AS [Id Causa Externa], Codigo [Causa Externa], [Nombre RIPS Causa Externa Version2] AS [Descripción Causa Externa]
FROM            dbo.[RIPS Causa Externa Version2]
WHERE        ([Id Estado] = 7)
GO

ALTER VIEW [dbo].[Cnsta VB Todos - Tipo de Diagnóstico Ppal - Orden Alfabético]
AS
SELECT        [Tipo de Diagnóstico Principal] AS [Id Tipo de Diagnóstico Principal], [Tipo de Diagnóstico Principal], [Descripción Tipo de Diagnóstico Principal]
FROM            dbo.[Tipo de Diagnóstico Principal]
WHERE        ([Id Tipo de Diagnóstico Principal] <> 1)

--Para las Listas AP
ALTER VIEW [dbo].[Cnsta VB Todos - Finalidad del Procedimiento - Orden Alfabético]
AS
SELECT        Codigo AS [Id Finalidad del Procedimiento], Codigo AS [Finalidad del Procedimiento], [Nombre RIPS Finalidad Consulta Version2] AS [Descripción Finalidad del Procedimiento]
FROM            dbo.[RIPS Finalidad Consulta Version2]
WHERE        (AP = N'Si')
GO

ALTER VIEW [dbo].[Cnsta VB Todos - Ambito - Orden Alfabético]
AS
SELECT        [Id Via Ingreso Usuario] AS [Id Ambito de Realización del Procedimiento], Codigo AS [Ambito de Realización del Procedimiento], [Nombre Via Ingreso Usuario] AS [Descripción Ambito de Realización del Procedimiento]
FROM            dbo.[RIPS Via Ingreso Usuario]
WHERE        ([Id Estado] = 7)
GO

ALTER VIEW [dbo].[Cnsta VB Todos - Persona que Atiende - Orden Alfabético]
AS
SELECT        Codigo AS [Id Persona que Atiende], Codigo AS [Persona que Atiende], [Nombre Modalidad Atencion] AS [Descripción Persona que Atiende]
FROM            dbo.[RIPS Modalidad Atención]
GO

ALTER VIEW [dbo].[Cnsta VB Todos - Acto Quirúrgico - Orden Alfabético]
AS
SELECT        TOP (1) 3 AS [Id Acto Quirúrgico], 3 AS [Acto Quirúrgico], 'AP' AS [Descripción Acto Quirúrgico]
FROM            dbo.[Acto Quirúrgico]
GO

--Esta columna es para identificar cuales fueron automaticos 
ALTER TABLE [Evaluación Entidad Rips]
ADD Automatico nvarchar (20) NULL default 'NO'
--Este triger es para que los datos ingresados por ap  de complemente de forma correcta donde deben ir 
CREATE TRIGGER [dbo].[RIPS AUTOMATICOS MEDIMUJER 2275]
ON [dbo].[Evaluación Entidad Rips]
AFTER  insert
--NOT FOR REPLICATION
AS
begin


declare @IdEvaluacionRips  int;
--Ambito <--> Finalidad
Declare @IdFinalidad int;
--Finalidad <--> Via ingreso
Declare @IdCausaExterna int;
--TipodxPrincipal <--> Modalidad
Declare @IdTipodxPrincipal int;
--Acto quir = 3 cuando viene de sio
Declare @Acto int;




select  @IdCausaExterna = inserted.[Id Causa Externa] ,
@IdFinalidad = inserted.[Id Finalidad Consulta] ,
@IdTipodxPrincipal = inserted.[Id Tipo de Diagnóstico Principal]  ,
@IdEvaluacionRips = inserted.[Id Evaluación Entidad Rips],
@Acto = inserted.[Id Acto Quirúrgico]
from Inserted  

	IF @Acto = 3 
		BEGIN
		UPDATE [Evaluación Entidad Rips] 
		SET 
			[Id Finalidad Consulta] = @IdCausaExterna,
			[Id Via Ingreso Usuario] = @IdFinalidad,
			[Id Modalidad Atencion] = @IdTipodxPrincipal,
			[Id Acto Quirúrgico] = 2,
			[Id Causa Externa] = 0,
			[Id Tipo de Diagnóstico Principal] = 0
			
		END;
 
END;