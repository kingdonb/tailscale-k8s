export TS_ROUTES=10.17.12.0/24,10.17.13.0/24,10.32.0.0/12,10.96.0.0/12
export KUBE_SECRET=tailscale-auth
export SA_NAME=tailscale
export SERVICE_CIDR=10.96.0.0/12
echo $TS_ROUTES
export IMAGE_TAG=kingdonb/tailscale-k8s:0.0.14

