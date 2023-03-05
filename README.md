## EventBridge ECS Logger

This EventBridge sample showcases the capabilities of the eventbridge, in this sample the eventbridge will listen for an s3 event and trigger 3 targets 

1.  log the event to cloudwatch logs
2.  call a lambda passing the event to the lamdba, the lambda logs the the event to cloudwatch logs
3.  calls an ecs task with custom parameters:  S3\_BUCKET, S3\_KEY, and S3\_REASON

When an s3 event is sent to EventBridge, CloudWatch log and Lambdas functions pass events natively to the components. However, when EventBridges calls an ECS task, the parameters need to become environment variables so the parameters can be passed into the docker container.  For the docker to act on the S3\_BUCKET, S3\_KEY, and S3\_REASON an InputTransformer is required to pass environment variabls. The InputTransformer is a critical component in passing parameters to an ECS task through EventBridge, as it allows the incoming event to be properly converted into parameters that can be passed to the Docker container environment variabls. In the sample below the input transformer is converting the s3 event , bucket and key into parameters for the eventbridge-ecs task. 

For more information on InputTransformers:  
    [https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-input-transformer-tutorial.html](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-input-transformer-tutorial.html)  
    [https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html)

```plaintext
"InputTransformer": {
    "InputPathsMap": {
        "bucketname": "$.detail.bucket.name",
        "eventname": "$.detail.reason",
        "keyname": "$.detail.object.key"
    },
    "InputTemplate": "{\"containerOverrides\": [{\"name\":\"eventbridge-ecs\",\"environment\":[{\"name\":\"S3_REASON\",\"value\":<eventname>},
        { \"name\":\"S3_BUCKET_NAME\",\"value\":<bucketname> },{ \"name\":\"S3_KEY\",\"value\":<keyname> }]}]}"
},
```

Prerequisites

*   AWS CLI installed and configured with AWS credentials
*   Docker installed
*   An Amazon Elastic Container Registry (ECR) repository in your AWS account

### Configuration

#### Create .env file:

Create a .env file in the root directory of the repository, and add the following variables with their corresponding values:

```plaintext
AWS_ACCOUNT_ID=  
```

#### Makefile

The following commands are available in the Makefile:

*   `docker-build`: Builds a Docker image of the logging service.
*   `ecr-login`: Logs in to your ECR repository to push the Docker image.
*   `ecr-tag`: Tags the Docker image with the ECR repository URI.
*   `ecr-push`: Pushes the Docker image to your ECR repository.
*   `log-groups action=create|delete`: Creates or deletes CloudWatch log groups used by the application.
*   `task-def-register:` Registers the ECS task definition in your AWS account.
*   `create-cluster`: Creates an ECS cluster with the specified name
*   `create-eventbridge`: Creates an EventBridge rule that triggers the Lambda function.
*   `create-stack`: Creates a CloudFormation stack with the specified name and the specified template file.

To build and deploy the application, run the following command:

`make build-push make log-groups action=create task-def-register create-cluster create-eventbridge`