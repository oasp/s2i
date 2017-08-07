#!/bin/bash

oadm new-project oasp --display-name='OASP' --description='Open Application Standard Platform'

oc create -f https://raw.githubusercontent.com/mickuehl/s2i-oasp/master/s2i/java/s2i-oasp-java-imagestream.json --namespace=oasp
oc create -f https://raw.githubusercontent.com/mickuehl/s2i-oasp/master/s2i/angular/s2i-oasp-angular-imagestream.json --namespace=oasp

oc start-build s2i-oasp-java --namespace=oasp
oc start-build s2i-oasp-angular --namespace=oasp

sleep 30
ret=`oc status -v -n oasp | grep 'running for'`
while [[ !  -z  $ret  ]]; do
    echo "Waiting for build to complete..."
    ret=`oc status -v -n oasp | grep 'running for'`
    sleep 30
done

oadm policy add-role-to-group system:image-puller system:authenticated --namespace=oasp

oadm new-project mythaistar --display-name='My Thai Star' --description='My Thai Star reference application for OASP'
oc create -f https://raw.githubusercontent.com/mickuehl/s2i-oasp/master/templates/mythaistar/oasp-mythaistar-java-template.json --namespace=mythaistar
oc create -f https://raw.githubusercontent.com/mickuehl/s2i-oasp/master/templates/mythaistar/oasp-mythaistar-angular-template.json --namespace=mythaistar

oc new-app --template=oasp-mythaistar-java-sample --namespace=mythaistar
oc start-build mythaistar-java --namespace=mythaistar

oc new-app --template=oasp-mythaistar-angular-sample --namespace=mythaistar

sleep 10
oc set env bc/mythaistar-angular REST_ENDPOINT_URL=http://`oc get routes mythaistar-java --no-headers=true --namespace=mythaistar | sed -e's/  */ /g' | cut -d" " -f 2` --namespace=mythaistar
oc start-build mythaistar-angular --namespace=mythaistar
