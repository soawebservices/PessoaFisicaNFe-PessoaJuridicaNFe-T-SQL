USE [Seu Banco de dados]
GO
/****** Object:  StoredProcedure [dbo].[sp_CNPJ]    Script Date: 01/03/2016 12:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[sp_CNPJ]
@CNPJ varchar(14),
@Usuario varchar(100),
@Senha varchar(20)
AS
BEGIN

	declare @ResultadoXML xml
	declare @Resultado varchar(max)
	Declare @RequestText as varchar(max);
	set @RequestText=
	'<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <PessoaJuridicaNFe xmlns="SOAWebServices">
      <Credenciais>
        <Email>' + @Usuario +'</Email>
        <Senha>' + @Senha +'</Senha>
      </Credenciais>
      <Documento>' + @CNPJ +  '</Documento>
    </PessoaJuridicaNFe>
  </soap:Body>
</soap:Envelope>'
	exec sp_WebService	'http://www.soawebservices.com.br/webservices/producao/cdc/cdc.asmx', 
						'POST', 
						@RequestText, 
						'SOAWebServices/PessoaJuridicaNFe',
						'', 
						'', 
						@ResultadoXML out
	SELECT	[Documento]			= @ResultadoXML.value('(//*[local-name()="Documento"])[1]' , 'varchar(14)'),
			[RazaoSocial]		= @ResultadoXML.value('(//*[local-name()="RazaoSocial"])[1]', 'varchar(100)'),
			[SituacaoRFB]		= @ResultadoXML.value('(//*[local-name()="SituacaoRFB"])[1]', 'varchar(100)'),
			[DataConsultaRFB]	= @ResultadoXML.value('(//*[local-name()="DataConsultaRFB"])[1]', 'varchar(100)'),
			[Status]			= @ResultadoXML.value('(//*[local-name()="Status"])[1]', 'bit'),
			[Mensagem]			= @ResultadoXML.value('(//*[local-name()="Mensagem"])[1]', 'varchar(max)')
END
			
