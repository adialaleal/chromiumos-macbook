#!/usr/bin/env python3
"""
Apple MacBook Keyboard Scancode & HWDB Validator
Maps USB HID scancodes to Linux input event keycodes for Apple keyboards.
"""

import sys

MACBOOK_KEYMAP = {
    "7003a": ("KEY_BRIGHTNESSDOWN", "F1 - Screen Brightness Down"),
    "7003b": ("KEY_BRIGHTNESSUP",   "F2 - Screen Brightness Up"),
    "7003c": ("KEY_SCALE",          "F3 - Mission Control / Task Switcher"),
    "7003d": ("KEY_HOMEPAGE",       "F4 - Launchpad / ChromeOS Launcher"),
    "7003e": ("KEY_KBDILLUMDOWN",   "F5 - Keyboard Backlight Down"),
    "7003f": ("KEY_KBDILLUMUP",     "F6 - Keyboard Backlight Up"),
    "70040": ("KEY_PREVIOUSSONG",   "F7 - Media Previous"),
    "70041": ("KEY_PLAYPAUSE",      "F8 - Media Play/Pause"),
    "70042": ("KEY_NEXTSONG",       "F9 - Media Next"),
    "70043": ("KEY_MUTE",           "F10 - Audio Mute"),
    "70044": ("KEY_VOLUMEDOWN",     "F11 - Audio Volume Down"),
    "70045": ("KEY_VOLUMEUP",       "F12 - Audio Volume Up"),
    "70066": ("KEY_POWER",          "Power / Eject Key"),
}

def generate_hwdb_block():
    print("# Generated HWDB Block for Apple USB/HID Keyboard")
    print("evdev:input:b0003v05Acp*")
    for scancode, (keycode, desc) in MACBOOK_KEYMAP.items():
        print(f" KEYBOARD_KEY_{scancode}={keycode.lower().replace('key_', '')}   # {desc}")

if __name__ == "__main__":
    print("Apple MacBook HWDB Validation Utility")
    print("-------------------------------------")
    generate_hwdb_block()
