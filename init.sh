#!/bin/sh

mkdir /opt/confluence-pod
mkdir /opt/confluence-pod/data
mkdir /opt/confluence-pod/data/app
mkdir /opt/confluence-pod/data/db

cp ./confluence-pod.yaml /opt/confluence-pod
cp ./confluence-pod.kube /usr/share/containers/systemd/
