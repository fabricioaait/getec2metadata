import boto3
import json
import os
from datetime import datetime

ec2 = boto3.client('ec2')
s3 = boto3.client('s3')

def datetime_serializer(obj):
    if isinstance(obj, datetime):
        return obj.isoformat()
    raise TypeError(f"Object of type {obj.__class__.__name__} is not JSON serializable")

def lambda_handler(event, context):
    instance_id = os.environ['INSTANCE_ID']
    bucket_name = os.environ['S3_BUCKET_NAME']

    response = ec2.describe_instances(InstanceIds=[instance_id])
    instance_metadata = response['Reservations'][0]['Instances'][0]

    # Convert datetime object to string using custom serializer
    instance_metadata['LaunchTime'] = datetime_serializer(instance_metadata['LaunchTime'])

    s3.put_object(Bucket=bucket_name, Key=f"{instance_id}.json", Body=json.dumps(instance_metadata, default=datetime_serializer))

    return {
        "statusCode": 200,
        "body": "Lambda function executed successfully!"
    }
