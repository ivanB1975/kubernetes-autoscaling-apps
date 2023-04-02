



kubectl create clusterrolebinding deployments-scaler \
  --clusterrole=deployments-scaler  \
  --serviceaccount=default:default