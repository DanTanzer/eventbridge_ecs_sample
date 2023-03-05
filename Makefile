# This make file expect that you are logged into AWS and that you have
# AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN configured
#
# Additional environment variables required can be added to = .env file
# create .env and add your AWS_ACCOUNT_ID
# 
# AWS_ACCOUNT_ID=<your id> 
#

include .env
export

# varaibles below can be added .env or inline here
image-name = ecs_sample_logger
cluster-name=my-cluster
bucket-name=my-bucket
task-definition-family=eventbridge-ecs
task-definition-revision=:1
task-defintion-arn=arn:aws:ecs:us-east-1:${AWS_ACCOUNT_ID}:task-definition/${task-definition-family}

docker-build:
	docker build -t ${image-name} .

ecr-login:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com

ecr-tag:
	docker tag ${image-name}:latest ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${image-name}:latest

ecr-push:
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${image-name}:latest

# make log-groups action=create|delete
log-groups:
	aws logs ${action}-log-group --log-group-name /ecs/eventbridge-ecs
	aws logs ${action}-log-group --log-group-name /aws/lambda/eventbridge-lambda
	aws logs ${action}-log-group --log-group-name /aws/events/eventbridge-log

#   envsubst is used to replace environments variables in a file and is not included by default on macOS.
#   install 'brew install gettext' envsubst is part of that package  	
task-def-register:
	envsubst < logging_ecs_service/ecs-task-definition.json > logging_ecs_service/ecs-task-definition-updated.json
	aws ecs register-task-definition --cli-input-json file://logging_ecs_service/ecs-task-definition-updated.json

# make create-cluster cluster-name=my-cluster
create-cluster:
	aws ecs create-cluster --cluster-name ${cluster-name}

#   envsubst is used to replace environments variables in a file and is not included by default on macOS.
#   install 'brew install gettext' envsubst is part of that package  	
#	$(shell uuidgen) in Make, the 'shell' function is used to invoke shell commands and capture their output as a string that can be used in Make rules and variables.
#   stack-names need to be unique 
create-eventbridge:
	envsubst < eventbridge/cw_rule_cft_inputtransformer.json > eventbridge/cw_rule_cft_inputtransformer_updated.json
	make create-stack stack-name=eb-input-transformer-$(shell uuidgen) stack-file=file://eventbridge/cw_rule_cft_inputtransformer_updated.json

# make create-stack stack-name=eb-input-transformer2 stack-file=file://eventbridge/cw_rule_cft_inputtransformer.json
create-stack: 
	aws cloudformation create-stack --stack-name ${stack-name} --template-body ${stack-file}

build-push: docker-build ecr-login ecr-tag ecr-push

