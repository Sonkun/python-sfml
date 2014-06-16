from __future__ import division

from math import cos, sin, fabs, pi
from random import randint

from sfml import sf


# define some constants
game_size = sf.Vector2(800, 600)
paddle_size = sf.Vector2(25, 100)
ball_radius = 10.

# create the window of the application
w, h = game_size
window = sf.RenderWindow(sf.VideoMode(w, h), "pySFML - Pong")
window.vertical_synchronization = True

# load the sounds used in the game
ball_sound_buffer = sf.SoundBuffer.from_file("data/ball.wav")
ball_sound = sf.Sound(ball_sound_buffer)

# create the left paddle
left_paddle = sf.RectangleShape()
left_paddle.size = paddle_size - (3, 3)
left_paddle.outline_thickness = 3
left_paddle.outline_color = sf.Color.BLACK
left_paddle.fill_color = sf.Color(100, 100, 200)
left_paddle.origin = paddle_size / 2

# create the right paddle
right_paddle = sf.RectangleShape()
right_paddle.size = paddle_size - (3, 3)
right_paddle.outline_thickness = 3
right_paddle.outline_color = sf.Color.BLACK
right_paddle.fill_color = sf.Color(200, 100, 100)
right_paddle.origin = paddle_size / 2

# create the ball
ball = sf.CircleShape()
ball.radius = ball_radius - 3
ball.outline_thickness = 3
ball.outline_color = sf.Color.BLACK
ball.fill_color = sf.Color.WHITE
ball.origin = (ball_radius / 2, ball_radius / 2)

# load the font
font = sf.Font.from_file("data/sansation.ttf")

# initialize the pause message
pause_message = sf.Text()
pause_message.font = font
pause_message.character_size = 40
pause_message.position = (170, 150)
pause_message.color = sf.Color.WHITE
pause_message.string = "Welcome to pySFML pong!\nPress space to start the game"

# define the paddles properties
ai_timer = sf.Clock()
ai_time = sf.seconds(0.1)
paddle_speed = 400.
right_paddle_speed = 0.
ball_speed = 400.
ball_angle = 0. # to be changed later

clock = sf.Clock()
is_playing = False

while window.is_open:

    # handle events
    for event in window.events:
        # window closed or escape key pressed: exit
        if type(event) is sf.CloseEvent:
            window.close()

        # space key pressed: play
        if type(event) is sf.KeyEvent and event.pressed and event.code is sf.Keyboard.SPACE:
            if not is_playing:
                # (re)start the game
                is_playing = True
                clock.restart()

                # reset the position of the paddles and ball
                left_paddle.position = (10 + paddle_size.x / 2, game_size.y / 2)
                right_paddle.position = (game_size.x - 10 - paddle_size.x / 2, game_size.y / 2)
                ball.position = game_size / 2

                # reset the ball angle
                while True:
                    # make sure the ball initial angle is not too much vertical
                    ball_angle = (randint(0, 32767) % 360) * 2 * pi / 360
                    if not fabs(cos(ball_angle)) < 0.7: break

    if is_playing:
        delta_time = clock.restart().seconds

        # move the player's paddle
        if sf.Keyboard.is_key_pressed(sf.Keyboard.UP) and left_paddle.position.y - paddle_size.y / 2 > 5:
            left_paddle.move((0, -paddle_speed * delta_time))

        elif sf.Keyboard.is_key_pressed(sf.Keyboard.DOWN) and left_paddle.position.y + paddle_size.y / 2 < game_size.y - 5:
            left_paddle.position += (0, paddle_speed * delta_time)

        # move the computer' paddle
        if (right_paddle_speed < 0 and right_paddle.position.y - paddle_size.x / 2 > 5) or (right_paddle_speed > 0 and right_paddle.position.y + paddle_size.y / 2 < game_size.y - 5):
            right_paddle.position += (0, right_paddle_speed * delta_time)


        # update the computer's paddle direction according to the ball position
        if ai_timer.elapsed_time > ai_time:
            ai_timer.restart()
            if ball.position.y + ball_radius > right_paddle.position.y + paddle_size.y / 2:
                right_paddle_speed = paddle_speed
            elif ball.position.y - ball_radius < right_paddle.position.y - paddle_size.y / 2:
                right_paddle_speed = - paddle_speed
            else:
                right_paddle_speed = 0

        # move the ball
        factor = ball_speed * delta_time
        ball.move((cos(ball_angle) * factor, sin(ball_angle) * factor))

        # check collisions between the ball and the screen
        if ball.position.x - ball_radius < 0:
            is_playing = False
            pause_message.string = "You lost!\nPress space to restart or\nescape to exit"

        if ball.position.x + ball_radius > game_size.x:
            is_playing = False
            pause_message.string = "You won !\nPress space to restart or\nescape to exit"

        if ball.position.y - ball_radius < 0:
            ball_sound.play()
            ball_angle = - ball_angle
            ball.position.y = ball_radius + 0.1

        if ball.position.y + ball_radius > game_size.y:
            ball_sound.play()
            ball_angle = - ball_angle
            ball.position.y = game_size.y - ball_radius - 0.1

        # check the collisions between the ball and the paddles
        # left paddle
        if ball.position.x - ball_radius < left_paddle.position.x + paddle_size.x / 2 and ball.position.x - ball_radius > left_paddle.position.x and ball.position.y + ball_radius >= left_paddle.position.y - paddle_size.y / 2 and ball.position.y - ball_radius <= left_paddle.position.y + paddle_size.y / 2:
            if ball.position.y > left_paddle.position.y:
                ball_angle = pi - ball_angle + (randint(0, 32767) % 20) * pi / 180
            else:
                ball_angle = pi - ball_angle - (randint(0, 32767) % 20) * pi / 180

            ball_sound.play()
            ball.position = (left_paddle.position.x + ball_radius + paddle_size.x / 2 + 0.1, ball.position.y)

        # right paddle
        if ball.position.x + ball_radius > right_paddle.position.x - paddle_size.x / 2 and ball.position.x + ball_radius < right_paddle.position.x and ball.position.y + ball_radius >= right_paddle.position.y - paddle_size.y / 2 and ball.position.y - ball_radius <= right_paddle.position.y + paddle_size.y / 2:
            if ball.position.y > right_paddle.position.y:
                ball_angle = pi - ball_angle + (randint(0, 32767) % 20) * pi / 180
            else:
                ball_angle = pi - ball_angle - (randint(0, 32767) % 20) * pi / 180

            ball_sound.play()
            ball.position = (right_paddle.position.x - ball_radius - paddle_size.x / 2 - 0.1, ball.position.y)

    window.clear(sf.Color(50, 200, 50))

    if is_playing:
        # draw the paddles and the ball
        window.draw(left_paddle)
        window.draw(right_paddle)
        window.draw(ball)

    else:
        # draw the pause message
        window.draw(pause_message)

    # display things on screen
    window.display()
