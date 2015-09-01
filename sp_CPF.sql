USE [Seu Banco de Dados]
GO
/****** Object:  StoredProcedure [dbo].[sp_CPF]    Script Date: 01/09/2015  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_CPF]
@CPF varchar(11),
@DataNascimento varchar(10),
@Documento varchar(11) OUTPUT,
@Nome varchar(100) OUTPUT,
@DataInscricao varchar(30) OUTPUT,
@AnoObito varchar(4) OUTPUT,
@SituacaoRFB varchar(20) OUTPUT,
@DataConsultaRFB varchar(30) OUTPUT,
@ProtocoloRFB varchar(50) OUTPUT,
@DigitoVerificador varchar(2) OUTPUT,
@Status bit OUTPUT,
@CodigoStatus varchar(8) OUTPUT,
@CodigoStatusDescricao varchar(max) OUTPUT
AS
BEGIN

	-- Credenciais de Acesso
	-- É necessario a abertura de conta no portal: http://www.soawebservices.com.br
	declare @Usuario varchar(100) = 'seu email'
	declare @Senha varchar(20) = 'sua senha'


	-- Ambiente
	-- Set 0 para Ambiente de Test-Drive
	-- Set 1 para Ambiente de Producao
	declare @Ambiente int = 0 
	declare @URI varchar(max)
	
	IF @Ambiente = 0 
	BEGIN
		SET @URI = 'http://www.soawebservices.com.br/webservices/test-drive/cdc/cdc.asmx'
	END
	ELSE
	BEGIN
		SET @URI = 'http://www.soawebservices.com.br/webservices/producao/cdc/cdc.asmx'
	END
	declare @ResultadoXML xml
	declare @Resultado nvarchar(max)
	Declare @RequestText as nvarchar(max)


	-- Payload de requisicao
	set @RequestText=
	'<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:soaw="SOAWebServices">
   <soap:Header/>
   <soap:Body>
      <soaw:PessoaFisicaNFe>
         <!--Optional:-->
         <soaw:Credenciais>
            <!--Optional:-->
            <soaw:Email>' + @Usuario + '</soaw:Email>
            <!--Optional:-->
            <soaw:Senha>' + @Senha + '</soaw:Senha>
         </soaw:Credenciais>
         <!--Optional:-->
         <soaw:Documento>' + @CPF + '</soaw:Documento>
		 <soaw:DataNascimento>' + @DataNascimento + '</soaw:DataNascimento>
      </soaw:PessoaFisicaNFe>
   </soap:Body>
</soap:Envelope>'


	-- Chamada do WebService
	exec sp_WebService	@URI, 'POST', @RequestText, 'SOAWebServices/PessoaFisicaNFe','', '', @Resultado out

	-- Converter UTF-8 para UTF-16
	-- Esta conversao é necessaria para o SQL Server poder receber XML com acentuacao
	SET @Resultado = REPLACE(@Resultado,'encoding="UTF-8"','encoding="UTF-16"')

	SET @ResultadoXML			= @Resultado
	SET	@Documento				= @ResultadoXML.value('(//*[local-name()="Documento"])[1]' , 'varchar(14)')
	SET	@Nome					= @ResultadoXML.value('(//*[local-name()="Nome"])[1]', 'varchar(100)')
	SET	@DataNascimento			= @ResultadoXML.value('(//*[local-name()="DataNascimento"])[1]', 'varchar(20)')
	SET	@DataInscricao			= @ResultadoXML.value('(//*[local-name()="DataInscricao"])[1]', 'varchar(30)')
	SET	@AnoObito				= @ResultadoXML.value('(//*[local-name()="AnoObito"])[1]', 'varchar(4)')
	SET	@SituacaoRFB			= @ResultadoXML.value('(//*[local-name()="SituacaoRFB"])[1]', 'varchar(30)')
	SET	@DataConsultaRFB		= @ResultadoXML.value('(//*[local-name()="DataConsultaRFB"])[1]', 'varchar(30)')
	SET	@ProtocoloRFB			= @ResultadoXML.value('(//*[local-name()="ProtocoloRFB"])[1]', 'varchar(50)')
	SET	@DigitoVerificador		= @ResultadoXML.value('(//*[local-name()="DigitoVerificador"])[1]', 'varchar(2)')

	
	---- Relacao completa dos Codigos de Status disponivel em: http://www.soawebservices.com.br/integracao/manuais/mensagens.aspx
	SET	@Status					= @ResultadoXML.value('(//*[local-name()="Status"])[2]', 'bit') -- Utilizando Status da TAG <Transacao>
	SET	@CodigoStatus			= @ResultadoXML.value('(//*[local-name()="CodigoStatus"])[1]', 'varchar(8)') -- Utilizando Status da TAG <Transacao>
	SET	@CodigoStatusDescricao	= @ResultadoXML.value('(//*[local-name()="CodigoStatusDescricao"])[1]', 'varchar(max)') -- Utilizando Status da TAG <Transacao>
	
	SELECT 	@Documento as Documento
	,@Nome as Nome
	,@DataNascimento as DataNascimento 
	,@DataInscricao as DataInscricao
	,@AnoObito as AnoObito
	,@SituacaoRFB as SituacaoRFB
	,@DataConsultaRFB as DataConsultaRFB
	,@ProtocoloRFB as ProtocoloRFB
	,@DigitoVerificador as DigitoVerificador
	,@Status as Status
	,@CodigoStatus as CodigoStatus
	,@CodigoStatusDescricao as CodigoStatusDescricao
END
	
