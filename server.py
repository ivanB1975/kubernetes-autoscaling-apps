from flask import Flask
import uuid
import os

app = Flask(__name__)

# Generating uuid at the app start
app_id = str(uuid.uuid4())
app_number = os.getenv('APP_NUMBER')

@app.route("/")
def hello_world():
    return "<p>This is the app " + app_number + " with id: " + app_id + "</p>"


if __name__ == "__main__":
    app.run(debug=True)

