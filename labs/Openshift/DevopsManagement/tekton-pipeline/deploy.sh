
oc create -f git-clone.yaml
oc create -f buildah.yaml
oc create -f oc-deploy.yaml
oc create -f pipeline-deploy.yaml
oc create -f pipeline-deploy-run.yaml
