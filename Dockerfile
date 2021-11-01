ARG IMAGE=kindest/node
ARG VERSION=1.21
ARG MINOR=1
ARG OS=xUbuntu_21.04

FROM ${IMAGE}:v${VERSION}.${MINOR}

ARG VERSION
ARG OS

ARG TARGETARCH="amd64"
ARG KRUSTLET_VERSION="1.0.0-alpha.1"
ARG KRUSTLET_BASE_URL="https://krustlet.blob.core.windows.net/releases"
ARG KRUSTLET_URL="${KRUSTLET_BASE_URL}/krustlet-v${KRUSTLET_VERSION}-linux-${TARGETARCH}.tar.gz"

COPY --chmod=0644 files/etc/default/krustlet-init.sh /etc/default/
COPY --chmod=0644 files/etc/systemd/system/krustlet.service /etc/systemd/system/

ARG YQ_URL="https://github.com/mikefarah/yq/releases/download/v4.13.4/yq_linux_amd64.tar.gz"

# This fixes CNI Tolerations
# But needs to be run by control-plane image to take effect
# But control-plane must not deactivate its kubelet ;)
# RUN echo "Installing yq ..." \
#     && curl -sSL --retry 5 --output /tmp/yq.amd64.tar.gz "${YQ_URL}" \
#     && tar -C /usr/bin -xzvf /tmp/yq.amd64.tar.gz \
#     && mv /usr/bin/yq_linux_amd64 /usr/bin/yq \
#     && yq eval --inplace 'select(documentIndex == 3) .spec.template.spec.tolerations =[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]' /kind/manifests/default-cni.yaml \
#     && sed -i "s/          value: {? {.PodSubnet: ''} : ''}/          value: {{ .PodSubnet }}/g"  /kind/manifests/default-cni.yaml

RUN echo "Installing Krustlet ..." \
    && curl -sSL --retry 5 --output /tmp/krustlet.${TARGETARCH}.tar.gz "${KRUSTLET_URL}" \
    && tar -C /usr/local/bin -xzvf /tmp/krustlet.${TARGETARCH}.tar.gz \
    && rm -f /usr/local/bin/README.md /usr/local/bin/LICENSE \
    && mkdir -p /root/.krustlet/config \
    && ln -s /etc/kubernetes/kubelet.conf ~/.krustlet/config/kubeconfig \
    && chmod +x /etc/default/krustlet-init.sh \
    && systemctl disable kubelet \
    && systemctl enable krustlet
    # && systemctl start krustlet
    # TODO:
    # - create (and enable) systemd task that starts a
    # - script which checks if its running on API-Server (if on API server, patch kube-proxy!); if its not running on api server, then
    # - systemctl disable kubelet
    # - and
    # - systemctl start krustlet


# KUBECONFIG=~/.krustlet/config/kubeconfig krustlet-wasi --node-ip $(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1) --bootstrap-file=~/.krustlet/config/bootstrap.conf