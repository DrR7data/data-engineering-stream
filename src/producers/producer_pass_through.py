import pandas as pd
import json
from kafka import KafkaProducer
from models import Ride, ride_from_row, ride_serializer
import dataclasses
import time

url = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-11.parquet"
columns = ['PULocationID', 'DOLocationID', 'trip_distance', 'total_amount', 'tpep_pickup_datetime']
df = pd.read_parquet(url, columns=columns).head(1000)
print(df.head())

#import json
#from kafka import KafkaProducer

def json_serializer(data):
    return json.dumps(data).encode('utf-8')

server = 'localhost:9092'

producer = KafkaProducer(
    bootstrap_servers=[server],
    value_serializer=json_serializer
)

producer = KafkaProducer(
    bootstrap_servers=[server],
    value_serializer=ride_serializer
)

ride = ride_from_row(df.iloc[0])
ride

#import dataclasses
topic_name = 'rides'

#import time

t0 = time.time()

for _, row in df.iterrows():
    ride = ride_from_row(row)
    producer.send(topic_name, value=ride)
    print(f"Sent: {ride}")
    time.sleep(0.01)

producer.flush()

t1 = time.time()
print(f'took {(t1 - t0):.2f} seconds')