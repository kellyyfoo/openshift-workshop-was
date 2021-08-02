oc delete -f pipeline-deploy-run.yaml
oc delete -f pipeline-deploy.yaml
oc delete -f buildah.yaml
oc delete -f oc-deploy-klp.yaml

oc delete -f  deploy/base/olapp-cos.yaml
oc delete configmap cos-config
oc delete secret db-creds
oc delete secret liberty-creds

oc delete -f img-resource.yaml
oc delete -f git-resource.yaml

#oc delete -f run-task-deploy.yaml 



