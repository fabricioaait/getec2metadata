import boto3
import json
import os

def lambda_handler(event, context):
    instance_id = os.environ['INSTANCE_ID']  # Fetch the instance ID from an environment variable
    bucket_name = os.environ['S3_BUCKET_NAME']  # Fetch the S3 bucket name from an environment variable

    ec2 = boto3.client('ec2')
    response = ec2.describe_instances(InstanceIds=[instance_id])
    instance_metadata = response['Reservations'][0]['Instances'][0]

    s3 = boto3.client('s3')
    s3.put_object(Bucket=bucket_name, Key=f"{instance_id}.json", Body=json.dumps(instance_metadata))

    return {
        "statusCode": 200,
        "body": "Lambda function executed successfully!"
    }
