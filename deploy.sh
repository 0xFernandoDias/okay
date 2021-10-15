#!/bin/bash

# Modify this file to match your environment variables
create_env(){
cat << EOF > .env
AWS_KEY=${AWS_KEY}
AWS_SEC=${AWS_SEC}
ECR_REPOSITORY=${ECR_REPOSITORY}
RANCHER_SECRET_KEY=${RANCHER_SECRET_KEY}
RANCHER_ACCESS_KEY=${RANCHER_ACCESS_KEY}
RANCHER_URL_API=${RANCHER_URL_API}
BOT_KEY=${BOT_KEY}
EOF
}

# Checking if deploy is being called inside the pipeline container
if [[ "$1" != "INSIDE_CONTAINER" ]]; then
    # Using local .env or building one in the pipeline
    if [[ -f ./.env ]]; then
        . ./.env
    else
        create_env
    fi
    # Building and Running Pipeline Container
    docker build --tag ${PWD##*/} -f ./d3-lib/dockerfiles/Pipeline-Dockerfile .
    docker run -v /var/run/docker.sock:/var/run/docker.sock --rm ${PWD##*/}
else
    # Exporting environment variables to be accessible in other scripts
    . ./.env
    export AWS_KEY AWS_SEC ECR_REPOSITORY RANCHER_SECRET_KEY RANCHER_ACCESS_KEY RANCHER_URL_API BOT_KEY

    # Creating SSH agent and logging in
    mkdir ~/.ssh
    eval "$(ssh-agent)"
    bash .d3-lib/ssh_login.sh "pipeline"

    # Logging into AWS CLI
    bash .d3-lib/aws_login.sh

    # Deploying to Rancher (Sample)
    bash .d3-lib/sample/deploy_rancher_sample.sh
fi