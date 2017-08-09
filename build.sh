#!/bin/bash

# Create project to store build base-images
oc new-project oasp --display-name='OASP' --description='Open Application Standard Platform'

# Create base-images and add them to OASP project
oc create -f https://raw.githubusercontent.com/cbeldacap/s2i/master/s2i/java/s2i-oasp-java-imagestream.json --namespace=oasp
oc create -f https://raw.githubusercontent.com/cbeldacap/s2i/master/s2i/angular/s2i-oasp-angular-imagestream.json --namespace=oasp

# Build base-images in OASP project
oc start-build s2i-oasp-java --namespace=oasp
oc start-build s2i-oasp-angular --namespace=oasp

sleep 30
ret=`oc status -v -n oasp | grep 'running for'`
while [[ !  -z  $ret  ]]; do
    echo "Waiting for build to complete..."
    ret=`oc status -v -n oasp | grep 'running for'`
    sleep 30
done

# Setup the OASP project as "image-puller" to be used in other projects in the same cluster
oc policy add-role-to-group system:image-puller system:authenticated --namespace=oasp

# Create project to host My Thai Star applications built from OASP's base-images
oc new-project mythaistar --display-name='My Thai Star' --description='My Thai Star reference application for OASP'

# Create templates for both MTS's Angular client and Java server
oc create -f https://raw.githubusercontent.com/cbeldacap/s2i/master/templates/mythaistar/oasp-mythaistar-java-template.json --namespace=mythaistar
oc create -f https://raw.githubusercontent.com/cbeldacap/s2i/master/templates/mythaistar/oasp-mythaistar-angular-template.json --namespace=mythaistar

# Create Java application out of the Java template 
oc new-app --template=oasp-mythaistar-java-sample --namespace=mythaistar
# Build Java application
oc start-build mythaistar-java --namespace=mythaistar

# Create Angular application out of the Angular template
oc new-app --template=oasp-mythaistar-angular-sample --namespace=mythaistar

sleep 10
# Setup Environment Variable pointing to Java application's URL
oc set env bc/mythaistar-angular REST_ENDPOINT_URL=http://`oc get routes mythaistar-java --no-headers=true --namespace=mythaistar | sed -e's/  */ /g' | cut -d" " -f 2` --namespace=mythaistar
# Build Angular application (sets the E.V. in the Angular code)
oc start-build mythaistar-angular --namespace=mythaistar
