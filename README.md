# scepter-mpv-extension
An mpv lua script that makes retiming runs much easier

Shortcuts:
Mark run start: Ctrl+Alt+1
Mark run end: Ctrl+Alt+2
Add bookmark (at load start or end): Ctrl+B
Show retime: Ctrl+Alt+R (must have start and end marked)
Save Retime: Ctrl+Alt+S

Mark the start and end of the run before creating bookmarks.  Two consecutive bookmarks (ctrl+Bs) must be start and end of a singular load.  

If a console does not display in MPV, hit the ~/` button.  Press escape to regain control for shortcuts.

You may pass a local file path in to runme.bat instead of a URL to a vod and it will work. Twitch vods are fucky so I don't recommend them, youtube is much more stable.
