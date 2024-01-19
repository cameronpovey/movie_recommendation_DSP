from flask import Flask, request
from main import getData  # Import your Cloud Function

app = Flask(__name__)

@app.route('/')
def index():
    return getData(request)

if __name__ == '__main__':
    app.run(port=8080, debug=True)
