import logging
import os
import sys

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
 
if __name__ == '__main__':
    print("python version " + sys.version)
    
    logger.debug(os.environ)
    
    message='environment variable was not received, please check the "containerOverrides" were configured'
    logger.info("S3_BUCKET_NAME=" +os.getenv('S3_BUCKET_NAME', message))
    logger.info("S3_KEY" +os.getenv('S3_KEY', message))
    logger.info("S3_REASON" +os.getenv('S3_REASON', message))

