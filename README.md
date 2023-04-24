# Argo CD Multi-Clients Onboarding 

This repository contains an automated process to configure Argo CD multi-clients instances with diferent permissions based on a Helm Chart and GitOps approach.

This multi-clients environment tries to reproduce a supposed Platform as a Service environment where there are a set of Openshift Clusters that have to be shared by multiple clients, named architectures.

The idea is to provide a Helm Chart to automate the architectures onboarding process with a GitOps approach managing the following elements:

- Namespaces per architecture
- RoleBindings to manage these namespaces from the respective architecture's Argo CD instance
- ResourceQuotas to limit the cluster resources at namespace level for the respective architecture
- Argo CD *AppProject* object to ensure the respective permissions are granted for users/groups in the respective architecture's Argo CD instance

## Prerequisites

- Openshift Cluster +4.12

## Lab Cluster Setup

An automated process has been designed in order to setup an Openshift cluster generating the following configuration:

- Install Red Hat GitOps Operator (The latest version available)
- Create a set of users/groups to emulate the different architecture's personas
- Deploy 2 extra Argo CD Instances for delegating the administration to the different architectures
- Create an Argo CD Application to generate the respective namespaces and resources required to manage an architecture environment

Please follow the next procedure to setting up the lab environment:

```$bash
sh ocp/setup.sh
```

## Onboarding following GitOps

The idea of this automated procedure is to follow a GitOps approach having all configuration included in a Git repository and being able to modify this configuration in a simple way. 

For this reason, it was decided to generate an umbrella chart architecture with the following characteristics and beneficts:

- *./charts/arch-operation* is a helm chart that includes the templates and default values for creating the required objects in Openshift
- *Chart.yaml and values.yaml* define an umbrella helm chart that is able to import the previous charts as a dependency multiple times, making possible to reuse the previous chart for different architectures and environments. 

The idea is to be able to modify the respective **values.yaml** in order to include new configuration or modify the configuration generated for a specific architecture, delete an specific architecture or create a new one.

## Author

Asier Cidon @RedHat