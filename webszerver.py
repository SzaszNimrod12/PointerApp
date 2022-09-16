#!/usr/bin/env python

import asyncio
import websockets
import os

async def echo(websocket, path):
    async for message in websocket:
        print ("Received and echoing message: "+message, flush=True)
        await websocket.send(message)


async def main():
    async with websockets.serve(echo, "192.168.0.154", os.environ.get('PORT') or 8080):
        print('Server Started!')
        await asyncio.Future()  # run forever

asyncio.run(main())