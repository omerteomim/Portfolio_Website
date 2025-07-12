import json
import boto3
import os

sns = boto3.client('sns')
topic_arn = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    cors_headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "POST,OPTIONS"
    }

    method = event.get("requestContext", {}).get("http", {}).get("method", "")

    if method == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': cors_headers,
            'body': json.dumps({'message': 'CORS preflight'})
        }

    try:
        body = json.loads(event.get('body', '{}'))

        name = body.get('name', 'N/A')
        email = body.get('email', 'N/A')
        message = body.get('message', '')

        sns.publish(
            TopicArn=topic_arn,
            Subject=f"New contact from {name}",
            Message=f"Name: {name}\nEmail: {email}\nMessage:\n{message}"
        )

        return {
            'statusCode': 200,
            'headers': cors_headers,
            'body': json.dumps({'success': True, 'message': 'Message sent'})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': cors_headers,
            'body': json.dumps({'error': str(e)})
        }
