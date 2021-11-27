#!/bin/bash

lilypond "$@".ly && gio open "$@".pdf && timidity "$@".midi -Ow -o "$@".wav && mpv "$@".wav
