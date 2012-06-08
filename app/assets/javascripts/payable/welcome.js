

processaPagtoCredito = function() {
       var settings = {
           "Forma": "CartaoCredito",
           "Instituicao": "Visa",
           "Parcelas": "1",
           "Recebimento": "AVista",
           "CartaoCredito": {
               "Numero": "4073020000000002",
               "Expiracao": "12/15",
               "CodigoSeguranca": "123",
               "Portador": {
                   "Nome": "Nome Sobrenome",
                   "DataNascimento": "30/12/1987",
                   "Telefone": "(11)3165-4020",
                   "Identidade": "222.222.222-22"
               }
           }
       }
       MoipWidget(settings);
   }