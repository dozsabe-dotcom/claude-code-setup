#!/bin/bash
# Csak akkor szólal meg, ha a VS Code (Code) nincs előtérben
TERMINAL_APP="Code"
FRONTMOST=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
if [ "$FRONTMOST" != "$TERMINAL_APP" ]; then
    afplay /System/Library/Sounds/Glass.aiff
fi
