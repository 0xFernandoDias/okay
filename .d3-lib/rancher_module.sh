#!/bin/bash

#AVISO: essas duas variaveis estão declaradas na pipeline,
#são necessarias para o funcionamento desse script
#  1 --> ${RANCHER_ACCESS_KEY}
#  2 --> ${RANCHER_SECRET_KEY}


#Instala as dependências da aplicação python
git clone git@github.com:d3estudio/d3lib-rancher-action.git
cd d3lib-rancher-action
apt-get install python3-venv -y
apt install python3-pip -y
python3 -m venv venv
$(source ./venv/bin/activate)
pip install -r requirements.txt
cd ..


deployRancher(){
    export DOCKER_IMAGE=$1
    #Verifica a branch que essa imagem foi clonada
    if [ "${REPO_CONFIG[3]}" == "dev" ];
        then export SERVICE_NAME="${REPO_CONFIG[0]}-dev"
        else export SERVICE_NAME="${REPO_CONFIG[0]}"
    fi
    #Declara como variavel de ambiente
    export DOCKER_IMAGE_LATEST=''
    cd d3lib-rancher-action
    python3 deploy_to_rancher.py
    echo "TAG OK! $SERVICE_NAME $repository_ecr/${REPO_CONFIG[0]}:${REPO_CONFIG[1]}"
    cd ..
}
