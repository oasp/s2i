# The 'My Thai Star' Reference Application

To deploy the [My Thai Star](https://github.com/oasp/my-thai-star) reference application, create a new project:

    $ oadm new-project mythaistar --display-name='My Thai Star' --description='My Thai Star reference application for OASP'

Add the application templates:

    $ oc create -f https://raw.githubusercontent.com/mickuehl/s2i-oasp/master/templates/mythaistar/oasp-mythaistar-java-template.json --namespace=mythaistar
    $ oc create -f https://raw.githubusercontent.com/mickuehl/s2i-oasp/master/templates/mythaistar/oasp-mythaistar-angular-template.json --namespace=mythaistar

Create the backend application:

    $ oc new-app --template=oasp-mythaistar-java-sample --namespace=mythaistar
    $ oc start-build mythaistar-java --namespace=mythaistar

Create the front-end application

    $ oc new-app --template=oasp-mythaistar-angular-sample --namespace=mythaistar

Connect the front-end application with the backend:

    $ oc set env bc/mythaistar-angular REST_ENDPOINT_URL=http://`oc get routes mythaistar-java --no-headers=true --namespace=mythaistar | sed -e's/  */ /g' | cut -d" " -f 2` --namespace=mythaistar

Build the front-end application:

    $ oc start-build mythaistar-angular --namespace=mythaistar

