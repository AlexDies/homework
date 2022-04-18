#! /usr/bin/env python3

import hvac
import time

while True:

 client = hvac.Client(
    url='http://vault:8200',
    token='aiphohTaa0eeHei'
 )
 client.is_authenticated()

 client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Netology'),
 )

 echo=client.secrets.kv.v2.read_secret_version(
    path='hvac',
 )['data']['data']['netology']

 print(echo)
 time.sleep(3)