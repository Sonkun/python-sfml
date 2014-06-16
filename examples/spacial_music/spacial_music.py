from sfml import sf

def main(song):
	window = sf.RenderWindow(sf.VideoMode(600, 600), "pySFML - Spacial Music")
	window.framerate_limit = 60

	# load one font, one song and two textures
	try:
		font = sf.Font.from_file("data/sansation.ttf")
		music = sf.Music.from_file(song)

		texture = sf.Texture.from_file("data/speaker.gif")
		speaker = sf.Sprite(texture)
		speaker.position = -texture.size // 2

		texture = sf.Texture.from_file("data/head_kid.png")
		hears = sf.Sprite(texture)
		hears.origin = texture.size // 2

	except IOError:
		exit(1)

	# create a text that display instructions
	instructions = "Up/Down        Move hears along Y axis\n"
	instructions += "Left/Right       Move hears along X axis\n"
	instructions += "Plus/Minus     Move hears along Z axis"
	instructions = sf.Text(instructions, font, 12)
	instructions.position = (70, 250)
	instructions.color = sf.Color.BLACK

	# make sure the song is monothread so it can be spacialized
	if music.channel_count != 1:
		print("Only sounds with one channel (mono sounds) can be spatialized.")
		print("This song ({0}) has {1} channels.".format(SONG, music.channels_count))
		exit(1)

	# setup the music properties
	music.relative_to_listener = False
	music.min_distance = 200
	music.attenuation = 1

	# initialize some values before entering the main loop
	position = sf.Vector3(-250, -250, 0)
	sf.Listener.set_position(position)

	x, y, _ = position
	hears.position = (x, y)

	running = True

	# move the view to make coord (0, 0) appears on the center of the screen
	window.default_view.move(-300, -300)

	# start the music before entering the main loop
	music.loop = True
	music.play()

	# start the main loop
	while running:
		for event in window.events:
			if type(event) is sf.CloseEvent:
				running = False

			elif type(event) is sf.KeyEvent and event.pressed:
				if event.code is sf.Keyboard.UP:
					position.y -= 5

				elif event.code is sf.Keyboard.DOWN:
					position.y += 5

				elif event.code is sf.Keyboard.LEFT:
					position.x -= 5

				elif event.code is sf.Keyboard.RIGHT:
					position.x += 5

				elif event.code is sf.Keyboard.ADD:
					if position.z < 400:
						position.z += 5

				elif event.code is sf.Keyboard.SUBTRACT:
					if position.z > -400:
						position.z -= 5

				# update the listener and the hears position
				sf.Listener.set_position(position)

				x, y, z = position
				hears.position = (x, y)
				hears.ratio = (1, 1) + sf.Vector2(z, z)/400.

		# clear screen, draw images and text and display them
		window.clear(sf.Color.WHITE)

		if position.z >= 0:
			window.draw(speaker)
			window.draw(hears)
		else:
			window.draw(hears)
			window.draw(speaker)

		window.draw(instructions)
		window.display()

	window.close()


if __name__ == "__main__":
    main("data/mario.flac")
