from sfml import sf
import client, server

# python 2.* compatability
try: input = raw_input
except NameError: pass

# choose a random port for opening sockets (ports < 1024 are reserved)
PORT = 2435

# client or server ?
print("Do you want to be a server (s) or a client (c) ?")
who = input()

if who == 's':
    server.do_server(PORT)
else:
    client.do_client(PORT)

input("Press any key to exit...")
