oc create -f img-resource.yaml
oc create -f git-resource.yaml
oc create -f buildah.yaml
oc create -f oc-deploy-klp.yaml
oc create -f pipeline-deploy.yaml
oc create -f pipeline-deploy-run.yaml
