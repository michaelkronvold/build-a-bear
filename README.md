# build-a-bear
scripts to manually manipulate the k8s platform management repo
* Git organization
    * Colors!
        * (TKC folder)
        * (NAMESPACE folder)
        * (APPLICATION folder)
        * (APP DEPLOYMENT folder)
    * /repo/TKG/TKC
        * /tkg/sv1-dev-tkg/sv1-dev-app  
            * /tkg/falco
                * copy (appropriate version of) these into 
                    * /tkg/sv1-dev-tkg/sv1-dev-app-falco
                        * change yamls if needed
                            * would be nice to have SV1-dev-values.yaml for each environment instead
                            * template.yaml
                            * ... diff the yaml and apply the diff on deploy :P
            * /tkg/sv1-dev-tkg/sv1-dev-app-fluentbit
        * /tkg/sv4-stg-tkg/sv4-stg-app
        * /tkg/ch4-prod-tkg/ch4-prod-app
        * /tkg/ch4-dr-tkg/ch4-dr-app
    * values.yaml for clusters??
        * common values across env's = config management.  
        * What are these and where do they come from?  And what uses them?
    * /tkg/build-a-bear
        * dc.list
        * env.list
        * tkg.list
            * tkg-reqs.list
        * tkc.list
            * tkc-reqs.list
        * tns.list
        * mkdc $dc
            * check for duplicate in dc.list or add to dc.list
        * mktkg $dc $env
            * check for duplicate in tkg.list or add to tkg.list
            * check for folder $dc-$env-tkg or create
            * every tkg needs clusters
                * read the tkg-reqs.list and mktkc each
                    * mktkc cops
                    * mktkc capp
        * mktkc $cluster
            * check for duplicate in tkc.list or add to tkc.list
            * check for folder $dc-$env-tkg/$dc-$env-$cluster or create
            * copy cluster policies from skeleton
                * apply tmc'ism's
                * are there any agents or anything that need to be installed for tmc?
                * anything for opa?
            * every tkc needs
                * read the tkc-reqs.list and mkapp each
                    * mkapp falco
                    * mkapp fluentbit
                * Do each of these require configuration?
        * mktns $app
            * This is currently only for Hosting Operations Tools (falco, fluentbit, clamav)
                * maybe for more later?
            * check for duplicate in tns.list or add to list
            * check for folder $dc-$env-tkg/$dc-$env-$cluster-$app
