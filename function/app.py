from flask import Flask, request
from ratings import getData  # Import your Cloud Function
from recc import startRec

app = Flask(__name__)

@app.route('/')
def index():
    return startRec(request)

@app.route('/ratings/')
def ratings():
    return getData(request)

if __name__ == '__main__':
    app.run(host='0.0.0.0' ,port=8080, debug=True)
