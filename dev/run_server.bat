@echo off
cd /d "C:\Users\antoi\Documents\Home\tools\dev\sorting"
call venv\Scripts\activate.bat

:: Update pip inside the virtual environment
python -m pip install --upgrade pip

:: Ensure the websocket-capable version of uvicorn is installed
pip install uvicorn[standard]

:: Run the server
uvicorn server:app --host 127.0.0.1 --port 8000 --reload
pause