##
# 
##
#!/bin/bash

oc apply -f subscription.yaml

sleep 60

oc new-project argocd

oc apply -f argocd.yaml -n argocd