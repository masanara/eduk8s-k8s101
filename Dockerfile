FROM quay.io/eduk8s/base-environment:master

COPY --chown=1001:0 . /home/eduk8s/

RUN mv /home/eduk8s/workshop /opt/workshop

RUN fix-permissions /home/eduk8s

USER root
RUN HOME=/root && dnf install -y net-tools iproute bridge-utils && dnf clean all
USER 1001
