#!/bin/sh

kind create cluster --config=examples/kind.yaml --name=kruste

echo "Started Kind..."

sleep 5

kubectl -n kube-system patch ds kindnet -p '{"spec":{"template":{"spec":{"tolerations":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]}}}}'
kubectl -n kube-system patch ds kube-proxy -p '{"spec":{"template":{"spec":{"tolerations":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]}}}}'
echo "Patched DS..."

# TODO check why error
# ./start_krustlet_kind.sh: line 13: [: too many arguments
echo "Waiting for csr..."
until [ $(kubectl get csr kruste-worker2-tls 2>&1 > /dev/null) $? -eq 0 ]
do
    sleep 1
done

kubectl get csr kruste-worker2-tls
kubectl certificate approve kruste-worker2-tls
echo "Approed Krustlet..."
