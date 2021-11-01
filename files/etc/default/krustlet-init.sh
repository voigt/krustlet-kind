#!/bin/bash

INITDONE=/root/.krustlet/initdone
if [ ! -f "$INITDONE" ]; then
    # Wait until kubeadm started
    until [ $(pgrep kubeadm) ]
    do
        # echo "kubeadm did not yet start"
        sleep 1
    done

    # kubeadm started
    # echo "kubeadm started!"

    # wait until kubeadm is done
    KUBEADMRUNNING=0
    while [ $KUBEADMRUNNING -eq 0 ]; do
        # echo "Waiting for finish..."
        pgrep kubeadm > /dev/null || KUBEADMRUNNING=1
        sleep 1
    done

    # kubeadm is done
    # echo "kubeadm finished..."

    # wait until kubelet is there
    until [ $(pgrep kubelet) ]
    do
        # echo "kubelet started"
        sleep 1
    done

    # give kubelet some time to fix lease
    sleep 20

    # kill kubelet
    KUBELETRUNNING=0
    while [ $KUBELETRUNNING -eq 0 ]; do
        # echo "killing kubelet"
        pgrep kubelet > /dev/null && systemctl stop kubelet && KUBELETRUNNING=1
        sleep 1
    done

    touch $INITDONE
fi

IP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo $IP
PORT=10250
KUBECONFIG=~/.krustlet/config/kubeconfig krustlet-wasi --node-ip=$IP --port=10250 --bootstrap-file=/etc/kubernetes/bootstrap-kubelet.conf
