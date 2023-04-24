##
# Script to setup the ENV
##
#!/bin/bash

USERS="arch01-developer
arch01-operator
arch02-developer
arch02-operator
"
GROUPSS="arch01-developers
arch01-operators
arch02-developers
arch02-operators
"

##
# Adding user to htpasswd
##
htpasswd -c -b users.htpasswd admin password
for i in $USERS
do
  htpasswd -b users.htpasswd $i $i
done

##
# Creating groups 
##
for i in $GROUPSS
do
  oc adm groups new $i
done

##
# Adding users to groups 
##
for i in $USERS
do
  oc adm groups add-users ${i}s $i
done

##
# Creating htpasswd file in Openshift
##
oc delete secret lab-users -n openshift-config
oc create secret generic lab-users --from-file=htpasswd=users.htpasswd -n openshift-config

##
# Configuring OAuth to authenticate users via htpasswd
##
cat <<EOF > oauth.yaml
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - htpasswd:
      fileData:
        name: lab-users
    mappingMethod: claim
    name: lab-users
    type: HTPasswd
EOF
cat oauth.yaml | oc apply -f -

##
# Install ArgoCD Operator and Instance
##
oc apply -f ocp/subscription.yaml
sleep 60
oc appy -f ocp/role-admin-quotas.yaml
oc adm policy add-cluster-role-to-user admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller
oc adm policy add-cluster-role-to-user admin-quotas system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller
oc new-project argocd
oc new-project gitops-arch02
oc label namespace argocd argocd.argoproj.io/managed-by=openshift-gitops
oc label namespace gitops-arch02 argocd.argoproj.io/managed-by=openshift-gitops
oc apply -f ocp/argocd.yaml -n argocd
oc apply -f ocp/argocd.yaml -n gitops-arch02
oc apply -f ocp/application.yaml