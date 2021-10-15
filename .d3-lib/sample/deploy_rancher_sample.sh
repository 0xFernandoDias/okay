#!/bin/bash

echo "D3 SITE DEPLOY FLOW!"
#AVISO: essas duas variaveis estão declaradas na pipeline,
#são necessarias para o funcionamento desse script
#  1 --> ${RANCHER_ACCESS_KEY}
#  2 --> ${RANCHER_SECRET_KEY}

#-------IMPORT-BASH-MODULE--------------------
# . ../ssh-login.sh
. .d3-lib/clone_module.sh
. .d3-lib/checkout_module.sh
. .d3-lib/aws_module.sh
. .d3-lib/rancher_module.sh
#---------------------------------------------

#faz a clonagem dos repositórios de acordo com .config
configRead
# #utiliza a função configRead para entrar em todos os repos e executar o checkout nos diretórios
configRead "checkoutHashAndAmazon";
# #Por fim , executa a função para enviar as imagens para a amazon e fazer o deploy no rancher
pushImagesEcr "$ECR_REPOSITORY"
