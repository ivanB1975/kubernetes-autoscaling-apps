# kube-challenge

This application uses a simple flask server:

    from flask import Flask

    app = Flask(__name__)

    @app.route("/")
    def hello_world():
    return "<p>Hello, World!</p>"

It is dockerized using an alpine version for python