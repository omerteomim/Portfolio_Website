import json
import boto3

sns = boto3.client('sns')

def lambda_handler(event, context):
    cors_headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "POST,OPTIONS"
    }

    if event['httpMethod'] == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': cors_headers,
            'body': json.dumps({'message': 'CORS preflight'})
        }

    try:
        body = json.loads(event['body'])
        name = body.get('name')
        email = body.get('email')
        message = body.get('message')

        sns.publish(
            TopicArn='arn:aws:sns:us-east-1:463470967866:ContactFormSubmissions',
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
