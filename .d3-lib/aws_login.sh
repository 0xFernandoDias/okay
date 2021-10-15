#!/bin/bash
aws configure set aws_access_key_id $AWS_KEY
aws configure set aws_secret_access_key $AWS_SEC
aws configure set region us-east-1
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPOSITORY