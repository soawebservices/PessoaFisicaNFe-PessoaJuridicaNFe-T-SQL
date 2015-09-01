USE [Seu Banco de dados]
GO
/****** Object:  StoredProcedure [dbo].[sp_WebService]    Script Date: 01/09/2015  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[sp_WebService] 
      @URI varchar(2000) = '',      
      @methodName varchar(50) = '', 
      @requestBody varchar(8000) = '', 
      @SoapAction varchar(255), 
      @UserName nvarchar(100), -- Domain\UserName or UserName 
      @Password nvarchar(100), 
      @responseText varchar(8000) output
as
SET NOCOUNT ON
IF    @methodName = ''
BEGIN
      select FailPoint = 'Nome do Method é obrigatorio'
      return
END
set   @responseText = 'FALHOU'
DECLARE @objectID int
DECLARE @hResult int
DECLARE @source varchar(255), @desc varchar(255) 
EXEC @hResult = sp_OACreate 'MSXML2.ServerXMLHTTP', @objectID OUT
IF @hResult <> 0 
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT      hResult = convert(varbinary(4), @hResult), 
                  source = @source, 
                  description = @desc, 
                  FailPoint = 'Criacao Falhou', 
                  MedthodName = @methodName 
      goto destroy 
      return
END
-- Abre URI de Destino com o Method specificado
EXEC @hResult = sp_OAMethod @objectID, 'open', null, @methodName, @URI, 'false', @UserName, @Password
IF @hResult <> 0 
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT      hResult = convert(varbinary(4), @hResult), 
            source = @source, 
            description = @desc, 
            FailPoint = 'Falhou na abertura da URI', 
            MedthodName = @methodName 
      goto destroy 
      return
END
-- Set o Header do Request
EXEC @hResult = sp_OAMethod @objectID, 'setRequestHeader', null, 'Content-Type', 'text/xml;charset=UTF-8'
IF @hResult <> 0 
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT      hResult = convert(varbinary(4), @hResult), 
            source = @source, 
            description = @desc, 
            FailPoint = 'SetRequestHeader Falhou', 
            MedthodName = @methodName 
      goto destroy 
      return
END
-- Set o SOAP Action 
EXEC @hResult = sp_OAMethod @objectID, 'setRequestHeader', null, 'SOAPAction', @SoapAction 
IF @hResult <> 0 
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT      hResult = convert(varbinary(4), @hResult), 
            source = @source, 
            description = @desc, 
            FailPoint = 'SetRequestHeader Falhou', 
            MedthodName = @methodName 
      goto destroy 
      return
END
declare @len int
set @len = len(@requestBody) 
EXEC @hResult = sp_OAMethod @objectID, 'setRequestHeader', null, 'Content-Length', @len 
IF @hResult <> 0 
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT      hResult = convert(varbinary(4), @hResult), 
            source = @source, 
            description = @desc, 
            FailPoint = 'SetRequestHeader Falhou', 
            MedthodName = @methodName 
      goto destroy 
      return
END
-- Envia o Request
EXEC @hResult = sp_OAMethod @objectID, 'send', null, @requestBody 
IF    @hResult <> 0 
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT      hResult = convert(varbinary(4), @hResult), 
            source = @source, 
            description = @desc, 
            FailPoint = 'Falhou enviando', 
            MedthodName = @methodName 
      goto destroy 
      return
END
declare @statusText varchar(1000), @status varchar(1000) 
-- Get status text 
exec sp_OAGetProperty @objectID, 'StatusText', @statusText out
exec sp_OAGetProperty @objectID, 'Status', @status out
--select @status, @statusText, @methodName 
-- Get response text 
exec sp_OAGetProperty @objectID, 'responseText', @responseText out
IF @hResult <> 0 
BEGIN
      EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT
      SELECT	hResult = convert(varbinary(4), @hResult), 
				Source = @source, 
				description = @desc, 
				FailPoint = 'ResponseText Falhou', 
				MedthodName = @methodName  
      goto destroy 
      return
END
destroy: 
      exec sp_OADestroy @objectID 
SET NOCOUNT OFF
 
