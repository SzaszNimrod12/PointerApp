# this demonstrates a simple websocket server with GUI which sends messages to its clients
# vuquangtrong@gmail.com

from tkinter import *
import json
import asyncio
import websockets
import threading


class WebSocketThread(threading.Thread):
    '''WebSocketThread will make websocket run in an a new thread'''

    # overide self init
    def __init__(self, name):
        threading.Thread.__init__(self)
        self.name = name
        self.USERS = set()
        print("Start thread", self.name)

    # overide run method
    def run(self):
        # must set a new loop for asyncio
        asyncio.set_event_loop(asyncio.new_event_loop())
        # setup a server
        asyncio.get_event_loop().run_until_complete(websockets.serve(self.listen, 'localhost', 6789))
        # keep thread running
        asyncio.get_event_loop().run_forever()

    # listener
    async def listen(self, websocket, path):
        '''listenner is called each time new client is connected
        websockets already ensures that a new thread is run for each client'''

        print("listen: ", websocket)

        # register new client #
        self.USERS.add(websocket)
        await self.notify_users()

        # this loop to get massage from client #
        while True:
            try:
                msg = await websocket.recv()
                if msg is None:
                    break
                await self.handle_message(client, msg)

            except websockets.exceptions.ConnectionClosed:
                print("close: ", websocket)
                break

        self.USERS.remove(websocket)
        await self.notify_users()

    # message handler
    async def handle_message(self, client, data):
        print("handle_message: ", client, data)

    # example of an action
    # action: notify
    async def notify_users(self):
        '''notify the number of current connected clients'''
        if self.USERS:  # asyncio.wait doesn't accept an empty list
            message = json.dumps({'type': 'users', 'count': len(self.USERS)})
            await asyncio.wait([user.send(message) for user in self.USERS])

    # action: action
    async def action(self):
        '''this is an action which will be executed when user presses on button'''
        if self.USERS:  # asyncio.wait doesn't accept an empty list
            message = json.dumps({'type': 'activation', 'count': 'true'})
            await asyncio.wait([user.send(message) for user in self.USERS])

    # expose action
    def do_activate(self):
        '''this method is exposed to outside, not an async coroutine'''
        # use asyncio to run action
        # must call self.action(), not use self.action, because it must be a async coroutine
        asyncio.get_event_loop().run_until_complete(self.action())


# start WebSocketThread #
threadWebSocket = WebSocketThread("websocket_server")
threadWebSocket.start()


# helper function for window
def clicked():
    threadWebSocket.do_activate()
    lbl.configure(text="Button was clicked !!")


# tkinter application
window = Tk()

# set up GUI #
window.title("tkinter GUI")
window.geometry('200x120')

lbl = Label(window, text="Hello")
lbl.grid(column=0, row=0)

btn = Button(window, text="Click Me", command=clicked)
btn.grid(column=1, row=0)

# start GUI #
window.mainloop()