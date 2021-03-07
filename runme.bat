@echo off
set /p link= "Paste (with right-click) a youtube video link of a run here, then press enter."
cls
mpv\mpv.com --pause --force-seekable --script=flskip.lua %link%
