import asyncio
import os
import threading
import json
import pyautogui as pyautogui
import PySimpleGUI as sg
import websockets
import pydirectinput
import socket
import qrcode
from PIL import Image

msgstop = False
screenWidth, screenHeight = pyautogui.size()


class MeasurementFilter:
    def __init__(self, window_size):
        self.windowSize = window_size
        self.queue = []

    def count(self):
        return len(self.queue)

    def empty(self):
        return len(self.queue) == 0

    def full(self):
        return self.windowSize == len(self.queue)

    def last(self):
        return self.queue[-1]

    def append(self, val):
        self.queue.append(val)

        if len(self.queue) > self.windowSize:
            self.queue.pop(0)

    def clear(self):
        self.queue.clear()

    def get_filtered(self):
        if not self.full():
            print('Not enough data')
            return 0, 0

        total = [sum(point) for point in zip(*self.queue)]

        return total[0] / self.count(), \
               total[1] / self.count()


def run():
    # must set a new loop for asyncio
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    # setup a server

    # Elso megoldas

    # nem mindenkinel a [3] elembe lessz a Wi-Fi ip attol fug hany network portja van lehet ez is configba hogy
    # hanyadik  network portot kell  megadni
    # ip_address = (socket.gethostbyname_ex(socket.gethostname())[2][2])
    # print(ip_address)

    # Ez talan jobb
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    # print(s.getsockname()[0])
    ip_address = s.getsockname()[0]

    port = os.environ.get('PORT') or 8080
    port = str(port)

    # generate qr code
    img = qrcode.make(ip_address + ":" + port)
    type(img)  # qrcode.image.pil.PilImage
    img.save("connect_qrcode.png")

    loop.run_until_complete(websockets.serve(listen, ip_address, port))
    # keep thread running
    loop.run_forever()


# listener
async def listen(websocket):
    async for message in websocket:
        print("Received and echoing message: " + message, flush=True)
        messageCheck(message)

        # viszakuldeni sem muszaly tesztelese erdekeben van itt
        await websocket.send(message)


def messageCheck(message):
    stopChek()
    response = json.loads(message)
    if response['type'] == 'actions':
        if response['action'] == 'calibrate':
            pyautogui.moveTo(screenWidth / 2, screenHeight / 2)  # move mouse to the center of screen

        if response['action'] == 'startLaserPointer' or response['action'] == 'stopLaserPointer':
            pyautogui.hotkey('ctrl', 'l')  # laser pointer

        if response['action'] == 'startDraw':
            pyautogui.hotkey('ctrl', 'p')  # draw with pen
            pyautogui.mouseDown(button='left')

        if response['action'] == 'stopDraw':
            pyautogui.mouseUp(button='left')
            pyautogui.hotkey('ctrl', 'p')  # draw with pen

        if response['action'] == 'pressLeft':
            pyautogui.press('left')        # press left arrow key

        if response['action'] == 'pressRight':
            pyautogui.press('right')       # press right arrow key

        elif response['action'] == 'stop':
            asyncio.get_event_loop().stop()

    if response['type'] == 'points':
        mover(response)


def mover(response):
    xkord = float('%.2f' % response['x'])
    ykord = float('%.2f' % response['y'])

    # print(xkord)
    # print(ykord)
    # zkord = float('%.2f' % response['z'])
    # move mouse right down -left -up

    if -50.0 < xkord < 50.0 and -50.0 < ykord < 50.0:
        xkordint = int(xkord * 10)
        ykordint = int(ykord * 10)

        # print(xkordint)
        # print(ykordint)

        position.append((xkordint, ykordint))
        if position.full():
            xfilter, yfilter = position.get_filtered()
            posx, posy = pyautogui.position()

            # ezel nem mukodik a rajz  de minden os kompatibilis
            # pyautogui.moveTo(posx - xfilter, posy - yfilter)

            # ez csak windows-al kompatibilis
            pydirectinput.moveTo(int(posx - xfilter), int(posy - yfilter))


def stopChek():
    if msgstop:
        asyncio.get_event_loop().stop()
    else:
        return


def the_gui():
    sg.theme('Black')  # give our window a spiffy set of colors

    layout = [[sg.Text('Output Text', size=(40, 1))],
              [sg.Output(size=(110, 20), font=('Helvetica 10')),
               sg.Button('Start', button_color=('black', 'darkslateblue'), bind_return_key=True),
               sg.Button('Stop', button_color=('black', 'firebrick'))],
              [sg.Button('Open QR Code', button_color=('black', 'azure4'))]]

    window = sg.Window("Websocket Server", layout, font=('Helvetica', ' 13'), default_button_element_size=(8, 2),
                       use_default_focus=False, finalize=True)

    threadWebSocket = threading.Thread(target=run)

    while True:  # The Event Loop
        event, value = window.read()
        if event in (sg.WIN_CLOSED, 'Stop'):  # quit if exit button or X
            global msgstop
            msgstop = True
            break

        if event == 'Start':
            threadWebSocket.start()
            print("Server started")

        if event == 'Open QR Code':
            im = Image.open("connect_qrcode.png")
            im.show()

    window.close()
    threadWebSocket.join()


if __name__ == '__main__':
    position = MeasurementFilter(window_size=5)
    the_gui()
