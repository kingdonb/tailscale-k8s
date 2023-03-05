export ROUTES=10.17.12.0/24,10.32.0.0/12,10.96.0.0/12
vi Makefile
export KUBE_SECRET=tailscale-auth
vi Makefile
export SA_NAME=tailscale
vi Makefile
SERVICE_CIDR=10.96.0.0/12
echo $ROUTES
export IMAGE_TAG=kingdonb/tailscale-k8s:0.0.12-amd64

