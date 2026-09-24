"""Smoke test the built watchface in an already-running emery emulator.
Run with the Pebble CLI on PATH and Pillow installed. Screenshots go to /tmp.
"""
import os
import subprocess
import time
from pathlib import Path
from PIL import Image

PEBBLE = os.environ.get('PEBBLE_BIN', 'pebble')
UUID = 'f066c042-84e6-4a3e-aaa6-28c517aafcd1'

def command(*args):
    subprocess.run([PEBBLE, args[0], '--emulator', 'emery', *args[1:]], check=True, stdout=subprocess.DEVNULL)
    if args[0] == 'emu-set-time':
        time.sleep(1.5)

def settings(**values):
    command('send-app-message', '--app-uuid', UUID, '--string', *(f'{k}={v}' for k, v in values.items()))

def shot(name):
    path = Path('/tmp') / ('royale-' + name + '.png')
    command('screenshot', '--no-open', '--no-correction', str(path))
    return Image.open(path).convert('RGB')

def seconds(image):
    return image.crop((143, 157, 177, 184)).tobytes()

# Verify a saved minute-only mode is temporarily overridden and restored.
command('emu-set-time', '14:20:05')
settings(**{'10000': 2, '10002': 2, '10003': 5})
a = shot('minute-a')
time.sleep(1.2)
b = shot('minute-b')
assert seconds(a) == seconds(b), 'Minute-only mode refreshed between minute boundaries'
# Preserve the original inactive indicator artwork and position. Check the
# unobstructed part left of the hour glyph (which begins at x=30).
background = Image.open('resources/images/bg.png').convert('RGB')
assert a.crop((23, 153, 30, 159)).tobytes() == background.crop((23, 153, 30, 159)).tobytes(), 'Original inactive PM artwork changed'
command('emu-tap')
c = shot('flick-a')
time.sleep(1.2)
d = shot('flick-b')
assert seconds(c) != seconds(d), 'Flick did not enable live seconds'
# Another flick extends the window.
command('emu-tap')
time.sleep(2.5)
e = shot('flick-extended-a')
time.sleep(1.2)
f = shot('flick-extended-b')
assert seconds(e) != seconds(f), 'Repeated flick did not extend live seconds'
time.sleep(5)
g = shot('expired-a')
time.sleep(1.2)
h = shot('expired-b')
assert seconds(g) == seconds(h), 'Flick timeout did not restore minute-only mode'
settings(**{'10002': 1})
shot('12h')
settings(**{'10002': 2, '10000': 0, '10001': 20})
command('emu-set-time', '12:32:00', '--utc')
shot('paris')
command('emu-set-time', '00:00:00')
shot('midnight')
# Invalid enum values must be ignored, not crash the watch.
settings(**{'10000': 999, '10001': 999, '10002': 999, '10003': 999})
shot('invalid-settings')
print('Emulator smoke checks passed; screenshots: /tmp/royale-*.png')
