import ctypes
import PySimpleGUI as sg
import asyncio
import websockets
import os
import threading

class WebSocketThread(threading.Thread):
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
        asyncio.get_event_loop().run_until_complete(websockets.serve(self.listen, "192.168.0.154", os.environ.get('PORT') or 8080))
        # keep thread running
        asyncio.get_event_loop().run_forever()

    # listener
    async def listen(self, websocket, path):
        '''listenner is called each time new client is connected
        websockets already ensures that a new thread is run for each client'''
        async for message in websocket:
            print("Received and echoing message: " + message, flush=True)
            await websocket.send(message)

    def stop(self):
        # terminate the loop
        asyncio.get_event_loop().stop()

def the_gui():

    sg.theme('Black')  # give our window a spiffy set of colors

    layout = [[sg.Text('Your output will go here', size=(40, 1))],
                      [sg.Output(size=(110, 20), font=('Helvetica 10')),
                       sg.Button('Start', button_color=(sg.BLUES[0]), bind_return_key=True),
                       sg.Button('Stop', button_color=(sg.GREENS[0]))]]

    window = sg.Window('', layout, font=('Helvetica', ' 13'), default_button_element_size=(8, 2),
                               use_default_focus=False, finalize=True)

    threadWebSocket = WebSocketThread("websocket_server")
    threadWebSocket.start()

    while True:     # The Event Loop
            event, value = window.read()
            if event in (sg.WIN_CLOSED, 'Stop'):            # quit if exit button or X
                break
            if event == 'Start':
                print("done")


    window.close()
    threadWebSocket.stop()



if __name__ == '__main__':
    the_gui()
