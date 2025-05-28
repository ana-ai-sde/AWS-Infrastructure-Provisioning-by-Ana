import json
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    Lambda function handler that logs a message when triggered by EventBridge
    """
    logger.info('Lambda function executed successfully!')
    logger.info(f'Event received: {json.dumps(event)}')
    
    return {
        'statusCode': 200,
        'body': json.dumps('Function executed successfully!')
    }