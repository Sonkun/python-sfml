from sfml import sf
from struct import pack
from random import randint

# python 2.* compatability
try: input = raw_input
except NameError: pass

AUDIO_DATA, END_OF_STREAM = list(range(1, 3))

class NetworkRecorder(sf.SoundRecorder):
    def __init__(self, host, port):
        sf.SoundRecorder.__init__(self)

        self.host = host # address of the remote host
        self.port = port # remote port
        self.socket = sf.TcpSocket() # socket used to communicate with the server

    def on_start(self):
        try: self.socket.connect(self.host, self.port)
        except sf.SocketException as error: return False

        return True

    def on_process_samples(self, chunk):
        # pack the audio samples
        data = pack("B", AUDIO_DATA)
        data += pack("I", len(chunk.data))
        data += chunk.data

        # send the audio packet
        try: self.socket.send(data)
        except sf.SocketException: return False

        return True

    def on_stop(self):
        # send a "end-of-stream" signal
        self.socket.send(bytes(END_OF_STREAM))

        # close the socket
        self.socket.disconnect()

def do_client(port):
    # check that the device can capture audio
    if not sf.SoundRecorder.is_available():
        print("Sorry, audio capture is not supported by your system")
        return

    # ask for server address
    server = input("Type address or name of the server to connect to: ")
    server = sf.IpAddress.from_string(server)

    # create an instance of our custom recorder
    recorder = NetworkRecorder(server, port)

    # wait for the user input...
    input("Press enter to start recording audio")

    # start capturing audio data
    recorder.start(44100)
    input("Recording... press enter to stop")
    recorder.stop()
