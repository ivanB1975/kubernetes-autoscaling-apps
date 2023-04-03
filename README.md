# kube-challenge

This application uses a simple flask server:

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

It is dockerized using an alpine version for python and it displays the app number using the environment variable that
will be set in the deployment. It also displays a uuid to show the different replicas when the app is scaled up and down.

First of all the docker image must be created:

    cd docker
    docker build -t kube-challenge/flask-app .
    cd ..

Once the image is created it can be added to minikube:

    minikube image load kube-challenge/flask-app

Now the deployment file can be used to create the deployments app1 and app2 in the minikube cluster:

    kubectl apply -f deployments.yml

The pods can be exposed creating services of type NodePort:

    kubectl apply -f services.yml

This commands creates 3 different services:

* the first one points to the pods in the app1 deployment
* the second one points to the pods in the app2 deployment
* the third one points to both deployments

At this point the services can be made accessible outside the cluster using Ingress. Before to do that the ip where 
the services are exposed can be retrieved by:

    minikube ip

This ip can be places in /etc/hosts to add a domain name that can be used in the Ingress configuration.
For example this line was added to the local /etc/hosts:

    192.168.49.2 simple-web-app.com

Now the ingresses can be created by:

    kubectl apply -f ingresses/ingress_apps.yml

this will apply an ingress fanout configuration that will target 3 paths for the host "simple-web-app.com":

    /app1 for the app1 pods
    /app2 for the app2 pods
    / for both app1 and app2 pods

In order to scale up and down the 2 applications, a new cluster role is created that grants permission to use the 
kubernetes API to scale up and down the applications in the default namespace as default service account.
First the new cluster role is created with this command:

    kubectl apply -f cluster_role_scaler.yml

After that the default service account can be granted the role by using the command:

    kubectl create clusterrolebinding deployments-scaler \
    --clusterrole=deployments-scaler  \
    --serviceaccount=default:default

Now the API can be used internally to a POD. The easiest way to do that is to use the kubectl client inside a POD.
A docker image containing the kubectl client is already available as "bitnami/kubectl". To solve the problem of the 
different loads of the 2 applications, 4 different cronjobs are created. Tha app1 is scaled up every day at 7 a.m. UTC
time to react to the daily load, and it is scaled down at 7 p.m. UTC time. The app2 is scaled up at midnight UTC every
Monday and scaled down at midnight UTC every Saturday to react to the weekly load.

This command is used to create the 4 cronjobs:

    kubectl apply -f cronjobs/app1_up.yml,cronjobs/app1_down.yml,cronjobs/app2_up.yml,cronjobs/app2_down.yml