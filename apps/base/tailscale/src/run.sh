# Copyright (c) 2021 Tailscale Inc & AUTHORS All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

#! /bin/sh

SERVICE_CIDR="${SERVICE_CIDR:-10.0.0.0/16}"
POD_CIDR="${POD_CIDR:-10.244.0.0/16}"
LB_CIDR="${LB_CIDR:-}"
HOME_CIDR="${HOME_CIDR:-}"
# LB_CIDR=172.18.0.0/16
# HOME_CIDR=10.17.12.0/24
export TS_ROUTES=$SERVICE_CIDR,$POD_CIDR,$LB_CIDR,$HOME_CIDR

export PATH=$PATH:/tailscale/bin

AUTH_KEY="${AUTH_KEY:-}"
TS_ROUTES="${TS_ROUTES:-}"
DEST_IP="${DEST_IP:-}"
EXTRA_ARGS="${EXTRA_ARGS:-}"
USERSPACE="${USERSPACE:-true}"
KUBE_SECRET="${KUBE_SECRET:-tailscale}"

set -e

TAILSCALED_ARGS="--state=kube:${KUBE_SECRET} --socket=/tmp/tailscaled.sock"

if [[ "${USERSPACE}" == "true" ]]; then
  if [[ ! -z "${DEST_IP}" ]]; then
    echo "IP forwarding is not supported in userspace mode"
    exit 1
  fi
  TAILSCALED_ARGS="${TAILSCALED_ARGS} --tun=userspace-networking"
else
  if [[ ! -d /dev/net ]]; then
    mkdir -p /dev/net
  fi

  if [[ ! -c /dev/net/tun ]]; then
    mknod /dev/net/tun c 10 200
  fi
fi

echo "Starting tailscaled"
tailscaled ${TAILSCALED_ARGS} &
PID=$!

UP_ARGS="--accept-dns=false --advertise-exit-node"
if [[ ! -z "${TS_ROUTES}" ]]; then
  UP_ARGS="--advertise-routes=${TS_ROUTES} ${UP_ARGS}"
fi
if [[ ! -z "${AUTH_KEY}" ]]; then
  UP_ARGS="--authkey=${AUTH_KEY} ${UP_ARGS}"
fi
if [[ ! -z "${EXTRA_ARGS}" ]]; then
  UP_ARGS="${UP_ARGS} ${EXTRA_ARGS:-}"
fi

echo "Running tailscale up"
tailscale --socket=/tmp/tailscaled.sock up ${UP_ARGS}

if [[ ! -z "${DEST_IP}" ]]; then
  echo "Adding iptables rule for DNAT"
  iptables -t nat -I PREROUTING -d "$(tailscale --socket=/tmp/tailscaled.sock ip -4)" -j DNAT --to-destination "${DEST_IP}"
fi

wait ${PID}
