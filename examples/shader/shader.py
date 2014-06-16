from __future__ import division

from random import randint
from math import cos

from sfml import sf

class Effect(sf.Drawable):
    def __init__(self, name):
        sf.Drawable.__init__(self)

        self._name = name
        self.is_loaded = False

    def _get_name(self):
        return self._name

    def load(self):
        self.is_loaded = sf.Shader.is_available() and self.on_load()

    def update(self, time, x, y):
        if self.is_loaded:
            self.on_update(time, x, y)

    def draw(self, target, states):
        if self.is_loaded:
            self.on_draw(target, states)
        else:
            error = sf.Text("Shader not\nsupported")
            error.font = sf.Font.from_file("data/sansation.ttf")
            error.position = (320, 200)
            error.character_size = 36
            target.draw(error, states)

    name = property(_get_name)

class Pixelate(Effect):
    def __init__(self):
        Effect.__init__(self, 'pixelate')

    def on_load(self):
        try:
            # load the texture and initialize the sprite
            self.texture = sf.Texture.from_file("data/background.jpg")
            self.sprite = sf.Sprite(self.texture)

            # load the shader
            self.shader = sf.Shader.from_file(fragment="data/pixelate.frag")
            self.shader.set_parameter("texture")

        except IOError as error:
            print("An error occured: {0}".format(error))
            exit(1)

        return True

    def on_update(self, time, x, y):
        self.shader.set_parameter("pixel_threshold", (x + y) / 30)

    def on_draw(self, target, states):
        states.shader = self.shader
        target.draw(self.sprite, states)


class WaveBlur(Effect):
    def __init__(self):
        Effect.__init__(self, 'wave + blur')

    def on_load(self):
        with open("data/text.txt") as file:
            self.text = sf.Text(file.read())
            self.text.font = sf.Font.from_file("data/sansation.ttf")
            self.text.character_size = 22
            self.text.position = (30, 20)

        try:
            # load the shader
            self.shader = sf.Shader.from_file("data/wave.vert", "data/blur.frag")

        except IOError as error:
            print("An error occured: {0}".format(error))
            exit(1)

        return True

    def on_update(self, time, x, y):
        self.shader.set_parameter("wave_phase", time)
        self.shader.set_parameter("wave_amplitude", x * 40, y * 40)
        self.shader.set_parameter("blur_radius", (x + y) * 0.008)

    def on_draw(self, target, states):
        states.shader = self.shader
        target.draw(self.text, states)


class StormBlink(Effect):
    def __init__(self):
        Effect.__init__(self, 'storm + blink')

        self.points = sf.VertexArray()

    def on_load(self):
        # create the points
        self.points.primitive_type = sf.PrimitiveType.POINTS

        for i in range(40000):
            x = randint(0, 32767) % 800
            y = randint(0, 32767) % 600
            r = randint(0, 32767) % 255
            g = randint(0, 32767) % 255
            b = randint(0, 32767) % 255
            self.points.append(sf.Vertex(sf.Vector2(x, y), sf.Color(r, g, b)))

        try:
            # load the shader
            self.shader = sf.Shader.from_file("data/storm.vert", "data/blink.frag")

        except IOError as error:
            print("An error occured: {0}".format(error))
            exit(1)

        return True

    def on_update(self, time, x, y):
        radius = 200 + cos(time) * 150
        self.shader.set_parameter("storm_position", x * 800, y * 600)
        self.shader.set_parameter("storm_inner_radius", radius / 3)
        self.shader.set_parameter("storm_total_radius", radius)
        self.shader.set_parameter("blink_alpha", 0.5 + cos(time*3) * 0.25)

    def on_draw(self, target, states):
        states.shader = self.shader
        target.draw(self.points, states)

class Edge(Effect):
    def __init__(self):
        Effect.__init__(self, "edge post-effect")

    def on_load(self):
        # create the off-screen surface
        self.surface = sf.RenderTexture(800, 600)
        self.surface.smooth = True

        # load the textures
        self.background_texture = sf.Texture.from_file("data/sfml.png")
        self.background_texture.smooth = True

        self.entity_texture = sf.Texture.from_file("data/devices.png")
        self.entity_texture.smooth = True

        # initialize the background sprite
        self.background_sprite = sf.Sprite(self.background_texture)
        self.background_sprite.position = (135, 100)

        # load the moving entities
        self.entities = []

        for i in range(6):
            sprite = sf.Sprite(self.entity_texture, (96 * i, 0, 96, 96))
            self.entities.append(sprite)

        # load the shader
        self.shader = sf.Shader.from_file(fragment="data/edge.frag")
        self.shader.set_parameter("texture")

        return True

    def on_update(self, time, x, y):
        self.shader.set_parameter("edge_threshold", 1 - (x + y) / 2)

        # update the position of the moving entities
        for i, entity in enumerate(self.entities):
            x = cos(0.25 * (time * i + (len(self.entities) - i))) * 300 + 350
            y = cos(0.25 * (time * (len(self.entities) - i) + i)) * 200 + 250
            entity.position = (x, y)

        # render the updated scene to the off-screen surface
        self.surface.clear(sf.Color.WHITE)
        self.surface.draw(self.background_sprite)

        for entity in self.entities:
            self.surface.draw(entity)

        self.surface.display()

    def on_draw(self, target, states):
        states.shader = self.shader
        target.draw(sf.Sprite(self.surface.texture), states)


if __name__ == "__main__":
    # create the main window
    window = sf.RenderWindow(sf.VideoMode(800, 600), "pySFML - Shader")
    window.vertical_synchronization = True

    # create the effects
    effects = (Pixelate(), WaveBlur(), StormBlink(), Edge())
    current = 0

    # initialize them
    for effect in effects: effect.load()

    # create the message background
    try:
        text_background_texture = sf.Texture.from_file("data/text-background.png")

    except IOError as error:
        print("An error occured: {0}".format(error))
        exit(1)

    text_background = sf.Sprite(text_background_texture)
    text_background.position = (0, 520)
    text_background.color = sf.Color(255, 255, 255, 200)

    # load the messages font
    try:
        font = sf.Font.from_file("data/sansation.ttf")

    except IOError as error:
        print("An error occured: {0}".format(error))
        exit(1)

    # create the description text
    description = sf.Text("Current effect: {0}".format(effects[current].name), font, 20)
    description.position = (10, 530)
    description.color = sf.Color(80, 80, 80)

    # create the instructions text
    instructions = sf.Text("Press left and right arrows to change the current shader", font, 20)
    instructions.position = (280, 555)
    instructions.color = sf.Color(80, 80, 80)

    clock = sf.Clock()

    # start the game loop
    while window.is_open:

        # update the current example
        x, y = sf.Mouse.get_position(window) / window.size
        effects[current].update(clock.elapsed_time.seconds, x, y)

        # process events
        for event in window.events:

            # close window: exit
            if type(event) is sf.CloseEvent:
                window.close()

            if type(event) is sf.KeyEvent and event.pressed:
                # escapte key: exit
                if event.code == sf.Keyboard.ESCAPE:
                    window.close()

                # left arrow key: previous shader
                elif event.code is sf.Keyboard.LEFT:
                    if current == 0: current = len(effects) - 1
                    else: current -= 1

                    description.string = "Current effect: {0}".format(effects[current].name)

                # right arrow key: next shader
                elif event.code is sf.Keyboard.RIGHT:
                    if current == len(effects) - 1: current = 0
                    else: current += 1

                    description.string = "Current effect: {0}".format(effects[current].name)


        # clear the window
        window.clear(sf.Color(255, 128, 0))

        # draw the current example
        window.draw(effects[current])

        # draw the text
        window.draw(text_background)
        window.draw(instructions)
        window.draw(description)

        # finally, display the rendered frame on screen
        window.display()
