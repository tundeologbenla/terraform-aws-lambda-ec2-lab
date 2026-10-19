
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("Lambda function triggered")
    logger.info("Received event: %s", json.dumps(event))

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Terraform Lambda lab executed successfully"
        })
    }
