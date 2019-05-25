from flask import Flask, request
app = Flask(__name__)

@app.route('/', methods=['GET', 'POST', 'PUT'])
def index():
    print("got request")
    print(request.headers)
    print(request.data)
    return "successfully requested"

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=8888)
