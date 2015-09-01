# PessoaFisicaNFe-T-SQL
SOAWebServices www.soawebservices.com.br

Exemplo de como consumir o webservice PessoaFisicaNFe em T-SQL

É ncessário informar a data de nascimento para realizar esta consulta.

É necessário abrir sua conta e possuir créditos para consultas em ambiente de produção.

Acesse no site: http://www.soawebservices.com.br/clientes/


#Antes de rodar as Stored Procedures é necessário reconfigurar o SQL Server (2005 ou superior)

sp_configure 'show advanced options', 1

GO


RECONFIGURE;

GO


sp_configure 'Ole Automation Procedures', 1

GO

RECONFIGURE;

GO

sp_configure 'show advanced options', 1

GO

RECONFIGURE;


