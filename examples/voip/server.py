import threading
from time import sleep
from sfml import sf
from struct import unpack

# python 2.* compatability
try: input = raw_input
except NameError: pass

AUDIO_DATA, END_OF_STREAM = list(range(1, 3))

class NetworkAudioStream(sf.SoundStream):
    def __init__(self):
        sf.SoundStream.__init__(self)

        self.offset = 0
        self.has_finished = False
        self.listener = sf.TcpListener()
        self.samples = sf.Chunk()

        # set the sound parameters
        self.initialize(1, 44100)

    def start(self, port):
        if not self.has_finished:
            try:
                # listen to the given port for incoming connections
                self.listener.listen(port)
                print("Server is listening to port {0}, waiting for connections... ".format(port))

                # wait for a connection
                self.client = self.listener.accept()
                print("Client connected: {0}".format(self.client.remote_address))

            except sf.SocketException: return

            # start playback
            self.play()

            # start receiving audio data
            self.receive_loop()

        else:
            # start playback
            self.play()

    def on_get_data(self, chunk):
        # we have reached the end of the buffer and all audio data have been played : we can stop playback
        if self.offset >= len(self.samples) and self.has_finished:
            return False

        # no new data has arrived since last update : wait until we get some
        while self.offset >= len(self.samples) and not self.has_finished:
            sf.sleep(sf.milliseconds(10))

        # don't forget to lock as we run in two separate threads
        lock = threading.Lock()
        lock.acquire()

        # fill audio data to pass to the stream
        chunk.data = self.samples.data[self.offset*2:]

        # update the playing offset
        self.offset += len(chunk)

        lock.release()

        return True

    def on_seek(self, time_offset):
        self.offset = time_offset.milliseconds * self.sample_rate * self.channel_count // 1000

    def receive_loop(self):
        lock = threading.RLock()

        while not self.has_finished:
            # get waiting audio data from the network
            data = self.client.receive(1)

            # extract the id message
            id = unpack("B", data)[0]

            if id == AUDIO_DATA:
                # extract audio samples from the packet, and append it to our samples buffer
                data = self.client.receive(4)
                sample_count = unpack("I", data)[0]

                samples = self.client.receive(sample_count)

                # don't forget the other thread can access the sample array at any time
                lock.acquire()
                self.samples.data += samples
                lock.release()

            elif id == END_OF_STREAM:
                # end of stream reached : we stop receiving audio data
                print("Audio data has been 100% received!")
                self.has_finished = True

            else:
                # something's wrong...
                print("Invalid data received...")
                self.has_finished = True

def do_server(port):
    # build an audio stream to play sound data as it is received through the network
    audio_stream = NetworkAudioStream()
    audio_stream.start(port)

    # loop until the sound playback is finished
    while audio_stream.status != sf.SoundStream.STOPPED:
        # leave some CPU time for other threads
        sf.sleep(sf.milliseconds(100))


    # wait until the user presses 'enter' key
    input("Press enter to replay the sound...")

    # replay the sound (just to make sure replaying the received data is OK)
    audio_stream.play();

    # loop until the sound playback is finished
    while audio_stream.status != sf.SoundStream.STOPPED:
        sf.sleep(sf.milliseconds(100))
