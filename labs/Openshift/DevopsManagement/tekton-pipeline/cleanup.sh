oc delete -f pipeline-deploy-run.yaml
oc delete -f pipeline-deploy.yaml
oc delete -f buildah.yaml
oc delete -f oc-deploy.yaml
oc delete -f git-clone.yaml

oc delete -f  ../deploy/base/olapp-cos.yaml
oc delete configmap cos-config
oc delete secret db-creds
oc delete secret liberty-creds





