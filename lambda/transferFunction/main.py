import boto3
from bson.json_util import dumps, loads
import hashlib
import os
import pymongo
import urllib.parse

MONGO_URL = os.environ.get('MONGO_URL')
MONGO_USER = os.environ.get('MONGO_USER')
MONGO_PASSWORD = os.environ.get('MONGO_PASSWORD')
MONGO_DB = os.environ.get('MONGO_DB')
MONGO_COLL = os.environ.get('MONGO_COLL')

hashing = hashlib.sha256()

s3 = boto3.client('s3')
client = pymongo.MongoClient(MONGO_URL, username=MONGO_USER, password=MONGO_PASSWORD)
db = client[MONGO_DB]
coll = db[MONGO_COLL]

def handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'],
                                    encoding='utf-8')

    try:
        response = s3.get_object(Bucket=bucket, Key=key)

        body = response['Body'].read()

        if key.endswith('.json'):
            docs = loads(body)
            coll.insert_many(docs)
        else:
            hashing.update(body)
            doc = {
                'title': key,
                'url': 'https://%s.s3.amazonaws.com/%s' % (bucket, key),
                'meta': response['Metadata'],
                'body': body.decode('utf-8'),
                'lastModified': response['LastModified'],
                'hash': hashing.hexdigest()
            }

            res = coll.replace_one({'title': key}, doc, upsert=True)

        print("Inserted " + key)
        return "Success"
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e
