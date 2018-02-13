# Open Application Standard Platform Source-To-Image (S2I)

This project provides OpenShift builder images for each of the Open Application Standard Platform ([OASP](https://github.com/oasp)) components.


## Overview

To build the OASP components, OpenShift's [Source-to-Image](https://github.com/openshift/source-to-image) (S2I) functionallity is used. 

Currently there are builder images for

* OASP4J (Java)
* OASP4JS (JavaScript)

In order to get started, additional templates to deploy the [OASP 'My Thai Star'](https://github.com/oasp/my-thai-star) reference application are provided.

## Previous setup

In order to build all of this, it will be necessary, first, to have a running OpenShift cluster.

1. Download the executable `oc.exe` from [here](https://github.com/openshift/origin/releases) and paste it somewhere in your machine.

2. Once extracted and pasted, you can navigate to `oc.exe`'s directory or add it to your PATH and execute `oc cluster up`.

## Usage

Before using the builder images, add them to the OpenShift cluster.

#### Deploy the Source-2-Image builder images

First, create a dedicated `devonfw` project as admin.

    $ oc new-project devonfw --display-name='DevonFW' --description='DevonFW Application Standar Platform'

Now add the builder image configuration and start their build.

    $ oc create -f https://raw.githubusercontent.com/oasp/s2i/master/s2i/angular/s2i-devonfw-java-imagestream.json --namespace=devonfw
    $ oc create -f https://raw.githubusercontent.com/oasp/s2i/master/s2i/angular/s2i-devonfw-angular-imagestream.json --namespace=devonfw
    oc start-build s2i-devonfw-java --namespace=devonfw
    oc start-build s2i-devonfw-angular --namespace=devonfw
    
Make sure other projects can access the builder images:

    oc policy add-role-to-group system:image-puller system:authenticated --namespace=devonfw

That's all !

#### Deploy DevonFW templates

Now, it's time to create devonfw templates to use this s2i and add it to the browse catalog. More information:
- [DevonFW templates](https://github.com/oasp/s2i/tree/master/templates/devonfw#how-to-use).

#### Build All

Use script `build.sh` to automatically install and build all image streams. The script also creates templates devonfw-angular and devonfw-java inside the project 'openshift' to be used by everyone.

1. Open a bash shell as Administrator
2. Execute shell file: 

`$ /PATH/TO/BUILD/FILE/build.sh`

### Further documentation

* The '[My Thai Star](templates/mythaistar)' reference application templates
* [Source-2-Image](https://github.com/openshift/source-to-image)
* [Open Application Standard Platform](https://github.com/oasp)

### Links & References

This is a list of useful articels etc I found while creating the templates.

* [Template Icons](https://github.com/openshift/openshift-docs/issues/1329)
* [Red Hat Cool Store Microservice Demo](https://github.com/jbossdemocentral/coolstore-microservice)