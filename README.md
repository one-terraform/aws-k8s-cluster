# Creating Kubernetes Cluster using Terraform

I recently racked up a $72 USD bill while using AWS Cloud Free Tier creating a K8s cluster.

I understand that there will be usage of services that will generate costs from time to time. However, I didn't expected this much. 

I took the time out to create a Kubernetes cluster using terraform for the infrastructure (1 Manager and 2 Worker Nodes) and shell scripting to create the user data files (manager.sh and worker.sh)

All that is needed now is to create the token on the Manager and copy and run on the Workers

sudo kubeadm token create --print-join-command

### Verify on the Worker Nodes
kubectl get nodes

kubectl get pods
