@echo off
cd /d "C:\Users\antoi\Documents\Home\tools\dev\sorting"
call venv\Scripts\activate.bat
uvicorn server:app --host 127.0.0.1 --port 8000
pause