#!/bin/bash

sed -i "s/USERNAME/${USERNAME}/g" headless-service-for-driver.yaml

oc apply -f headless-service-for-driver.yaml
