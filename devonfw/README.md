# DevonFW templates

This are the templates and icons to use in DevonFW Openshift Origin.

Inside the s2i forlder, we have the s2i templates to build an s2i images inside openshift
Inside the templates folder, we have the angular and java templates to deploy a devonfw apps. (Note: This templates need the s2i builds).
Inside the icons we have a custom icons for openshift.

The DevonFW templates have a custom icons, and to use it, you must modify the master-config.yml inside openshift. More information:
- https://docs.openshift.com/container-platform/3.5/install_config/web_console_customization.html#loading-custom-scripts-and-stylesheets

## How to use

### How to create and build images s2i in openshift

First we must to add the s2i images to a DevonFW project inside openshift. To do that, you must log in as an admin.
```
$ oc login -u system:admin

## Create project to store build base-images
$ oc new-project devonfw --display-name='DevonFW' --description='DevonFW'

## Create base-images and add them to DevonFW project
$ oc create -f https://raw.githubusercontent.com/oasp/s2i/master/devonfw/s2i/s2i-devonfw-java-imagestream.json --namespace=devonfw
$ oc create -f https://raw.githubusercontent.com/oasp/s2i/master/devonfw/s2i/s2i-devonfw-angular-imagestream.json --namespace=devonfw

## Build base-images in DevonFW project
oc start-build s2i-devonfw-java --namespace=devonfw
oc start-build s2i-devonfw-angular --namespace=devonfw

## Wait until the images are finished
sleep 30
ret=`oc status -v -n devonfw | grep 'running for'`
while [[ !  -z  $ret  ]]; do
    echo "Waiting for build to complete..."
    ret=`oc status -v -n devonfw | grep 'running for'`
    sleep 30
done

## Setup the DevonFW project as "image-puller" to be used in other projects in the same cluster
oc policy add-role-to-group system:image-puller system:authenticated --namespace=devonfw

```

### How to create DevonFW templates in openshift

To let all user to use this templates in all openshift projects, you should create it in a openshift namespace. To do that, you must log in as an admin.
```
$ oc login -u system:admin
$ oc create -f https://raw.githubusercontent.com/oasp/s2i/master/devonfw/templates/devonfw-java-template.json --namespace=openshift
$ oc create -f https://raw.githubusercontent.com/oasp/s2i/master/devonfw/templates/devonfw-angular-template.json --namespace=openshift
```

When it finish, remember to logout as an admin and enter with your normal user.
```
$ oc login
```
	
### How to use DevonFW templates in openshift

To use this templates with openshift, you can override any parameter values defined in the file by adding the --param-file=paramfile option.

This file must be a list of <name>=<value> pairs. A parameter reference may appear in any text field inside the template items.

Te parametres that you must override are the followin

    $ cat paramfile
      APPLICATION_NAME=app Name
	  GIT_URI=Git uri
	  GIT_REF=master
	  CONTEXT_DIR=/context
		
The following parametres are opcional

	$ cat paramfile
	  APPLICATION_HOSTNAME=Custom hostname for service routes. Leave blank for default hostname, e.g.: <application-name>.<project>.<default-domain-suffix>,
	  # Only for angular
	  REST_ENDPOINT_URL=The URL of the backend's REST API endpoint. This can be declarated after,
	  REST_ENDPOINT_PATTERN=The pattern URL of the backend's REST API endpoint that must be modify by the REST_ENDPOINT_URL variable,

For example, to deploy My Thai Star Java

    $ cat paramfile
	  APPLICATION_NAME="mythaistar-java"
	  GIT_URI="https://github.com/oasp/my-thai-star.git"
	  GIT_REF="develop"
	  CONTEXT_DIR="/java/mtsj"
    $ oc new-app --template=devonfw-java --namespace=devportal --param-file=paramfile
