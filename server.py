from flask import Flask
import uuid

app = Flask(__name__)

# Generating uuid at the app start
app_code = str(uuid.uuid4())

@app.route("/")
def hello_world():
    return "<p>This is the app " + app_code + "</p>"


if __name__ == "__main__":
    app.run(debug=True)

