import asyncio
import os
import threading

import PySimpleGUI as sg
import websockets

def run():
        # must set a new loop for asyncio
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        # setup a server
        loop.run_until_complete(websockets.serve(listen, "192.168.0.154", os.environ.get('PORT') or 8080))
        # keep thread running
        loop.run_forever()

    # listener
async def listen(websocket):
        async for message in websocket:
            print("Received and echoing message: " + message, flush=True)
            await websocket.send(message)


def the_gui():

    sg.theme('Black')  # give our window a spiffy set of colors

    layout = [[sg.Text('Output Text', size=(40, 1))],
                      [sg.Output(size=(110, 20), font=('Helvetica 10')),
                       sg.Button('Start', button_color=(sg.BLUES[0]), bind_return_key=True),
                       sg.Button('Stop', button_color=(sg.GREENS[0]))]]

    window = sg.Window("Websocket Server", layout, font=('Helvetica', ' 13'), default_button_element_size=(8, 2),
                               use_default_focus=False, finalize=True)

    threadWebSocket = threading.Thread(target=run)

    while True:     # The Event Loop
            event, value = window.read()
            if event in (sg.WIN_CLOSED, 'Stop'):            # quit if exit button or X
                break


            if event == 'Start':
                threadWebSocket.start()
                print("Server started")


    window.close()
    threadWebSocket.join()





if __name__ == '__main__':
    the_gui()
