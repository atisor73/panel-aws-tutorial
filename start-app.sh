#!/bin/bash

echo ".......Installing dependencies......."
# sudo apt-get update > /dev/null
# sudo apt-get install python3-pip > /dev/null
# sudo apt install awscli > /dev/null

echo ".......Retrieving IP & Port of AWS instance........"
SOCKET=$(curl http://checkip.amazonaws.com)
PORT=5006

echo
echo "socket : $SOCKET"
echo "port   : $PORT"
echo
echo

echo "........Installing requirements........"
pip install -r requirements.txt > /dev/null
echo 

echo "........Serving panel........"
python3 -m panel serve app.py --address 0.0.0.0 --port $PORT --allow-websocket-origin=$SOCKET:$PORT
