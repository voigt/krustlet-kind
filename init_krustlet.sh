#!/bin/bash

set -x

kind create cluster --config=examples/kind.yaml --name=kruste

echo "✅ Started Kind..."

sleep 5


# TODO check why error
# ./start_krustlet_kind.sh: line 13: [: too many arguments
echo "Waiting for csr..."
# echo $(kubectl get csr kruste-worker2-tls 2>&1 > /dev/null) $?
# echo $?
# until [ $(kubectl get csr kruste-worker2-tls 2>&1 > /dev/null) $? -eq 0 ]
until $(kubectl get csr kruste-worker2-tls &> /dev/null)
do
    sleep 1
done
# until [ $(kubectl get csr kruste-worker2-tls 2>&1 > /dev/null) $? -eq 0 ]
# do
#     sleep 1
# done

kubectl get csr kruste-worker2-tls
kubectl certificate approve kruste-worker2-tls
echo "🦀 Approved Krustlet..."

kubectl -n kube-system patch ds kindnet -p '{"spec":{"template":{"spec":{"tolerations":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]}}}}'
kubectl -n kube-system patch ds kube-proxy -p '{"spec":{"template":{"spec":{"tolerations":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]}}}}'
echo "Patched DS & Proxy..."
