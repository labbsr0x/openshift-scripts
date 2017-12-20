# openshift-scripts

Openshift scripts for various tasks

### Examples

#### Clones all DeploymentConfigurations and Services from a project to a new project
```
oc login
./clone-project.sh myproject myclonedproject
```
#### Exports all DeploymentConfigurations and Services from a project to a file
```
oc login
./export-project.sh myproject myproject.yml
```
