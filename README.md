## EventBridge ECS Logger

This sample showcases the capabilities of an EventBridge Rule, in this sample the EventBridge rule will listen for any s3 event and trigger 3 targets:

1.  log the event to CloudWatch logs - (Matched Event)
2.  calls a lambda - passing the s3 event to the lamdba and logs the the event to cloudwatch logs - (Matched Event)
3.  calls an ecs task with custom parameters:  S3\_BUCKET, S3\_KEY, and S3\_REASON (InputTransformer)

As defined in this cft - [eventbridge/cw\_rule\_cft\_inputtransformer.json](eventbridge/cw_rule_cft_inputtransformer.json) all s3 events  triggered by the EventBridge Rule will call 3 different targets. CloudWatch log and Lambdas functions pass events natively to the components, so no custom code was required. These two components receive the data with what AWS refers to as a “matched pattern” as seen in the console.  However, when the EventBridge is required to send parameters from an EventBridge Rule to an ECS task by utilizing an InputTransformer as a a conduit between the two components. The InputTransformer is a critical component in passing parameters to an ECS task through EventBridge, as it allows the incoming event to be properly converted into parameters that can be passed to the Docker container environment variabls.   
 

 [eventbridge/cw\_rule\_cft\_inputtransformer.json](eventbridge/cw_rule_cft_inputtransformer.json)

```plaintext
"InputTransformer": {
    "InputPathsMap": {
        "bucketname": "$.detail.bucket.name",
        "eventname": "$.detail.reason",
        "keyname": "$.detail.object.key"
    },
    "InputTemplate": "{
    \"containerOverrides\": [
    	{\"name\":\"eventbridge-ecs\"
    	,\"environment\":[
    	{\"name\":\"S3_REASON\",\"value\":<eventname>},
        {\"name\":\"S3_BUCKET_NAME\",\"value\":<bucketname> },
        { \"name\":\"S3_KEY\",\"value\":<keyname> 
    }]}]}"
},...
```

In the sample above the InputTransformer is extracting from the s3 event, the bucket, key and reason into parameters for the eventbridge-ecs task.  A couple of key items to be careful of, the containerOverrides\[0\].name has be the match your ecs-task-definition (below), in this case 'eventbridge-ecs'. Secondly the InputTemplate json needs to be escaped. IMHO this was a bit messy and over complicates the situation but hey, once you get the escaped syntax aligned, its not too bad. 

 [logging\_ecs\_service/ecs-task-definition.json](logging_ecs_service/ecs-task-definition.json)

```plaintext
"family": "eventbridge-ecs",
"containerDefinitions": [
   {
      "name": "eventbridge-ecs",
      ....
   }]
...
```

For more information on InputTransformers:  
    [https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-input-transformer-tutorial.html](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-input-transformer-tutorial.html)  
    [https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html)

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