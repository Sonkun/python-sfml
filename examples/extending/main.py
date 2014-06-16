from sfml import sf

import pyximport; pyximport.install()
import extension

window = sf.RenderWindow(sf.VideoMode(640, 480), "sfml")

image = sf.Image.from_file("image.jpg")
extension.flip_image(image)

texture = sf.Texture.from_image(image)

window.clear()
window.draw(sf.Sprite(texture))
window.display()

sf.sleep(sf.seconds(5))
