
import os
import random
import subprocess
from kitty.boss import get_boss
from kitty.fast_data_types import LATEST_KITTY_WINDOW_ID
from kittens.tui.handler import result_handler

def main(args):
    pass

@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    # Get the path to the wallpapers directory
    wallpapers_dir = os.path.expanduser("~/Pictures/Wallpapers/")

    # Get a list of all the wallpapers in the directory
    wallpapers = [os.path.join(wallpapers_dir, f) for f in os.listdir(wallpapers_dir) if os.path.isfile(os.path.join(wallpapers_dir, f))]

    # Choose a random wallpaper
    random_wallpaper = random.choice(wallpapers)

    # Run pywal to generate a new color scheme
    subprocess.run(["wal", "-i", random_wallpaper, "-n"])

    # Apply the new color scheme to the new window
    boss.set_colors_for_window(window, boss.get_colors())

from kitty.remote_control import RCFunc

@RCFunc("My watcher")
def my_watcher(boss, window, payload):
    if payload["type"] == "focus-in" and window.id == LATEST_KITTY_WINDOW_ID:
        handle_result(None, None, window.id, boss)
