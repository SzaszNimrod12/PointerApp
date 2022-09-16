import asyncio
import websockets

async def hello():
    async with websockets.connect("ws://192.168.0.154:8080") as websocket:
        await websocket.send("Hello world!")
        await websocket.recv()

asyncio.run(hello())
