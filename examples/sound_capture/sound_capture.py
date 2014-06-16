from sfml import sf

# python 2.* compatability
try: input = raw_input
except NameError: pass

def main():
    # check that the device can capture audio
    if not sf.SoundRecorder.is_available():
        print("Sorry, audio capture is not supported by your system")
        return

    # choose the sample rate
    sample_rate = int(input("Please choose the sample rate for sound capture (44100 is CD quality): "))

    # wait for user input...
    input("Press enter to start recording audio")

    # here we'll use an integrated custom recorder, which saves the captured data into a sf.SoundBuffer
    recorder = sf.SoundBufferRecorder()

    # audio capture is done in a separate thread, so we can block the main thread while it is capturing
    recorder.start(sample_rate)
    input("Recording... press enter to stop")
    recorder.stop()

    # get the buffer containing the captured data
    buffer = recorder.buffer

    # display captured sound informations
    print("Sound information:")
    print("{0} seconds".format(buffer.duration))
    print("{0} samples / seconds".format(buffer.sample_rate))
    print("{0} channels".format(buffer.channel_count))

    # choose what to do with the recorded sound data
    choice = input("What do you want to do with captured sound (p = play, s = save) ? ")

    if choice == 's':
        # choose the filename
        filename = input("Choose the file to create: ")

        # save the buffer
        buffer.to_file(filename);
    else:
        # create a sound instance and play it
        sound = sf.Sound(buffer)
        sound.play();

        # wait until finished
        while sound.status == sf.Sound.PLAYING:
            # leave some CPU time for other threads
            sf.sleep(sf.milliseconds(100))

    # finished !
    print("Done !")

    # wait until the user presses 'enter' key
    input("Press enter to exit...")

if __name__ == "__main__":
    main()
