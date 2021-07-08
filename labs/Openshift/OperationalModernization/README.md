# Operational Modernization

## Table of Contents

- [Introduction](#introduction)
- [Analysis](#analysis) (Hands-on)
- [Build](#build) (Hands-on)
- [Deploy without operator](#deploy) (Hands-on)
- [Access the Application without operator](#access-the-application) (Hands-on)
- [Alternate Deployment via Runtime Component Operator](#deploy-rco) (Hands-on)
- [Summary](#summary)
- [Next](#next)

<a name="introduction"></a>
## Introduction

**Operational modernization** gives an operations team the opportunity to embrace modern operations best practices without putting change requirements on the development team. 
Modernizing from WebSphere Network Deployment (ND) to the **traditional WebSphere Application Server Base V9 runtime** in a container allows the application to be moved to the cloud without code changes.

**This type of modernization shouldn't require any code changes** and can be driven by the operations team. **This path gets the application in to a container with the least amount of effort but doesn't modernize the application or the runtime.**

In this lab, we'll use **Customer Order Services** application as an example. In order to modernize, the application will go through **analysis**, **build** and **deploy** phases. Click [here](extras/application.md) and get to know the application, its architecture and components.

<a name="Login_VM"> </a>
## Login to the VM
1. If the VM is not already started, start it by clicking the Play button.
 
   ![start VM](extras/images/loginvm1.png)
   
3. After the VM is started, click the **desktop** VM to access it.
   
   ![desktop VM](extras/images/loginvm2.png)
   
3. Login with **ibmuser** ID.
   * Click on the **ibmuser** icon on the Ubuntu screen.
   * When prompted for the password for **ibmuser**, enter "**engageibm**" as the password: \
     Password: **engageibm**
     
     ![login VM](extras/images/loginvm3.png)
     
4. Resize the Skytap environment window for a larger viewing area while doing the lab. From the Skytap menu bar, click on the "**Fit to Size**" icon. This will enlarge the viewing area to fit the size of your browser window. 

   ![fit to size icon](extras/images/loginvm4.png)

<a name="analysis"></a>
## Analysis (Hands-on)
IBM Cloud Transformation Advisor can be used to analyze the Customer Order Service Application running in the WebSphere ND environment. The Transformation Advisor helps you to analyze your on-premises workloads for modernization. It determines the complexity of your applications, estimates a development cost to perform the move to the cloud, and recommends the best target environment. 

The steps needed to analyze the existing Customer Order Services application are:
1. Open a Firefox browser window from within the VM. 
    ![firefox](extras/images/analysis1.png)

1. Click on the **openshift console** bookmark in the top left and log in with the **htpasswd** option.

    ![openshift console](extras/images/analysis2.png)

1. Log in to the OpenShift account using the following credentials:
    - Username: **ibmadmin**
    - Password: **engageibm**

    ![login](extras/images/analysis3.png)

1. From the Red Hat OpenShift Container Platform console, go to the **Networking** tab and click on **Routes**. Ensure that you are in the **ta** project by using the project drop down and click on the Location URL next to **ta-ui-route**.

    ![ta](extras/images/analysis4.png)

1. This will open the Transformation Advisor user interface. Click **Create new** under **Workspaces** to create a new workspace. 

    ![TA starting page](extras/images/ta-create-collection.png)

1. Name it **OperationalModernization** and click **Next**. 

    ![Choose workspace name](extras/images/ta-name-workspace.png)
    
    You'll be asked to create a new collection to store the data collected from the **Customer Order Services** application. Name it **CustomerOrderServices**. Click **Create**. 
    
    ![Choose collection name](extras/images/ta-name-collection.png)

1. To provide data and receive recommendations, you can either download and execute the **Data Collector** against an existing WebSphere environment or upload an existing data collection archive. The archive has already been created for you and the resulting data is stored [here](resources/datacollection.zip). 

    ![TA no recommendations available screen](extras/images/ta-upload.png)
    
    Upload the results of the data collection (the [**datacollector.zip**](resources/datacollection.zip) file) to IBM Cloud Transformation Advisor.
    
    ![TA upload collection screen](extras/images/ta-upload-datacollection-dialog.png)

1. When the upload is complete, you will see a list of applications analyzed from the source environment. At the top of the page, you can see the source environment and the target environment settings.  

    ![TA recommendations screen for the data collection](extras/images/ta-migration-target.png)
    
    Under the **Migration target** field, click the down arrow and select **Compatible runtimes**. This will show you an entry for each application for each compatible destination runtime you can migrate it to.
    
    ![TA choosing compatible runtimes](extras/images/ta-compatible-runtimes.png)

1. Click the **CustomerOrderServicesApp.ear** application with the **WebSphere traditional** migration target to open the **Application details page**. 

    ![TA choosing CustomerOrderServices tWAS target](extras/images/ta-cos-twas.png)
    
1. Look over the migration analysis. You can view a summary of the complexity of migrating this application to this target, see detailed information about issues, and view additional reports about the application. In summary, no code changes are required to move this application to the traditional WebSphere Base v9 runtime, so it is a good candidate to proceed with the operational modernization.

    ![TA detailed analysis for CustomerOrderServices](extras/images/ta-detailed-analysis.png)

1. Click on **View migration plan** in the top right corner of the page. 
    
    ![TA migration plan button](extras/images/ta-migration-bundle-button.png)
    
    This page will help you assemble an archive containing:
    - your application's source or binary files (you upload these here or specify Maven coordinates to download them)
    - any required drivers or libraries (you upload these here or specify Maven coordinates to download them)
    - the wsadmin scripts needed to configure your application and its resources (generated by Transformation Advisor and automatically included)
    - the deployment artifacts needed to create the container image and deploy the application to OCP (generated by Transformation Advisor and automatically included)

    ![TA migration plan page](extras/images/ta-migration-bundle.png)

> NOTE: These artifacts have already been provided for you as part of the lab files, so you don't need to download the migration plan. However, you can do so if you wish to look around at the files. These files can also be sent to a Git repository by Transformation Advisor.

For a more detailed walkthrough of the Transformation Advisor process, see [this document](extras/WAS-analyze.md). 


<a name="build"></a>
## Build (Hands-on)

In this section, you'll learn how to build a Docker image for Customer Order Services application running on traditional WebSphere Base v9.

Building this image could take around ~8 minutes. So, let's kick that process off before explaining what you did. The image should be built by the time you complete this section.

1. Open a new terminal window from the VM desktop.

    ![terminal window](extras/images/build1.png)

1. Login to OpenShift CLI with the `oc login` command from the web terminal. When prompted for the username and password, enter the following login credentials:
    - Username: **ibmadmin**
    - Password: **engageibm**
    
      ![oc login](extras/images/build2.png)

1. If you have not yet cloned the GitHub repo with the lab artifacts, run the following command on your terminal:
    ```
    git clone https://github.com/IBM/openshift-workshop-was.git
    ```

1. Change directory to where this lab is located:
    ```
    cd openshift-workshop-was/labs/Openshift/OperationalModernization
    ls
    ```

1. Run the following command to create a new project named `apps-was` in OpenShift. 
   
     ```
     oc new-project apps-was
     ```

     Example output:
     ```
     Now using project "apps-was" on server "https://c115-e.us-south.containers.cloud.ibm.com:32661".
     . . .
     ```
     
1. Run the following command to start building the image. Make sure to copy the entire command, including the `"."` at the end (which indicates current directory). 
    ```
    docker build --tag default-route-openshift-image-registry.apps.demo.ibmdte.net/apps-was/cos-was .
    ```

### Build image (Hands-on)

1. Review the command you ran earlier:

   ```
   docker build --tag default-route-openshift-image-registry.apps.demo.ibmdte.net/apps-was/cos-was .
   ```

   - It instructs docker to build the image following the instructions in the Dockerfile in current directory (indicated by the `"."` at the end).
   - A specific name to tag the built image is also specified after `--tag`.
   - The value `default-route-openshift-image-registry.apps.demo.ibmdte.net` in the tag is the default address of the internal image registry provided by OpenShift. 
   - Image registry is a content server that can store and serve container images. 
   - The registry is accessible within the cluster via its exposed `Service`. 
   - The format of a Service address: _name_._namespace_._svc_. 
   - In this case, the image registry is named `image-registry` and it's in namespace `openshift-image-registry`.
   - Later when we push the image to OpenShift's internal image registry, we'll refer to the image by the same values.


1. You should see the following message if the image was successfully built. Please wait if it's still building.

   ```
   Successfully built aa6babbb5ce9
   Successfully tagged default-route-openshift-image-registry.apps.demo.ibmdte.net/apps-was/cos-was:latest
   ```

1. Validate that image is in the repository by running the command:

   ```
   docker images
   ```

   - Notice that the base image, websphere-traditional, is also listed. It was pulled as the first step of building application image.
     
     Example output:
     ```
     REPOSITORY                                                             TAG                 IMAGE ID            CREATED             SIZE
     default-route-openshift-image-registry.apps.demo.ibmdte.net/apps-was/cos-was      latest              9394150a5a15        10 minutes ago      2.05GB
     ibmcom/websphere-traditional                                           latest              898f9fd79b36        12 minutes ago      1.86GB
     ```

   - Note that `docker images` only lists those images that are cached locally.
   - The name of the image also contains the host name where the image is hosted. 
   - If there is no host name, the image is hosted on docker hub. For example, the image `ibmcom/websphere-traditional` has no host name. It is hosted on docker hub.
   - The image we just built, `default-route-openshift-image-registry.apps.demo.ibmdte.net/apps-was/cos-was`, has host name `default-route-openshift-image-registry.apps.demo.ibmdte.net`. It is to be hosted in the Openshift image registry for your lab cluster.
   - If you change an image, or build a new image, the changes are only available locally. You must `push` the image to propagate the changes to the remote registry.

1. Let's push the image you just built to your OpenShift cluster's built-in image registry. 
   - First, login to the image registry by running the following command in the terminal. 
     - Note: A session token is obtained from the value of another command `oc whoami -t` and used as the password to login.

     ```
     docker login -u $(oc whoami) -p $(oc whoami -t) default-route-openshift-image-registry.apps.demo.ibmdte.net
     ```

     Example output:
     ```
     WARNING! Using --password via the CLI is insecure. Use --password-stdin.
     WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
     Configure a credential helper to remove this warning. See
     https://docs.docker.com/engine/reference/commandline/login/#credentials-store

     Login Succeeded
     ```
     
   - Now, push the image into OpenShift cluster's internal image registry, which will take 1-2 minutes:

     ```
     docker push default-route-openshift-image-registry.apps.demo.ibmdte.net/apps-was/cos-was
     ```

     Example output: 
     ```
      Using default tag: latest
      The push refers to repository [default-route-openshift-image-registry.apps.demo.ibmdte.net/apps-was/cos-was]
      470e7d3b0bec: Pushed 
      c38e61da8211: Pushed 
      2a72e88fe5eb: Pushed 
      334c79ff1b2e: Pushed 
      ccf8ea26529f: Pushed 
      af0f17433f77: Pushed 
      4254aef2aa12: Pushed 
      855301ffdcce: Pushed 
      ea252e2474a5: Pushed 
      68a4c9686496: Pushed 
      87ecb86bc8e5: Pushed 
      066b59214d49: Pushed 
      211f972e9c63: Pushed 
      b93eee2b1ddb: Pushed 
      a6ab5ae423d9: Pushed 
      3f785cf0a0ae: Pushed 
      latest: digest: sha256:4f4e8ae82fa22c83febc4f884b5026d01815fc704df6196431db8ed7a7def6a0 size: 3672
     ```

1. Verify that the image is in the image registry. The following command will get the images in the registry. Filter through the results to get only the image you pushed. Run the following command:

   ```
   oc get images | grep apps-was/cos-was
   ```

   - The application image you just pushed should be listed. The hash of the image is stored alongside (indicated by the SHA-256 value).
     
     Example output:
     ```
     image-registry.openshift-image-registry.svc:5000/apps-was/cos-was@sha256:bc072d3b78ae6adcd843af75552965e5ed863bcce4fc3f1bc5d194570bc16953
     ```

1. OpenShift uses _ImageStream_ to provide an abstraction for referencing container images from within the cluster. When an image is pushed to registry, an _ImageStream_ is created automatically, if one doesn't already exist. Run the following command to see the _ImageStream_ that's created:
  
   ```
   oc get imagestreams -n apps-was
   ```

   Example output:
     ```
    NAME      IMAGE REPOSITORY                                                              TAGS      UPDATED           
    cos-was   default-route-openshift-image-registry.apps.demo.ibmdte.net/apps-was/cos-was  latest    2 minutes ago         

     ```

   - You can also use the OpenShift console (UI) to see the _ImageStream_:
     - From the panel on left-side, click on **Builds** > **Image Streams**. 
     - Then select `apps-was` from the **Project** drop-down menu. 
     - Click on `cos-was` from the list. 

        ![imagestream1](extras/images/buildimage1.png)

     - Scroll down to the bottom to see the image that you pushed.

        ![imagestream2](extras/images/buildimage2.png) 

<a name="deploy"></a>
## Deploy without operator 

The following steps will deploy the modernized Customer Order Services application in a traditional WebSphere Base container to a RedHat OpenShift cluster.

Customer Order Services application uses DB2 as its database. 
You can connect to an on-prem database that already exists or migrate the database to cloud. 
Since migrating the database is not the focus of this particular workshop and to save time, the database needed by the application is already configured in the OpenShift cluster you are using.


### Deploy application without operator (Hands-on)

1. Run the following command to deploy the resources (*.yaml files) in the `deploy` directory:

   ```
   oc apply -f deploy
   ```
   Output:
   ```
   deployment.apps/cos-was created
   route.route.openshift.io/cos-was created
   secret/authdata created
   service/cos-was created 
   ```

1. Let's review what we just did. 
   - The directory `deploy` contains the following yaml files:
     - `Deployment.yaml`:  the specification for creating a Kubernetes deployment
     - `Service.yaml`: the specification to expose the deployment as a cluster-wide Kubernetes service.
     - `Route.yaml`: the specification to expose the service as a route visible outside of the cluster.
     - `Secret.yaml`: the specification that the `properties based configuration` properties file used to configure database user/password when the container starts.

   - The file `Deployment.yaml` looks like:

     ```yaml
     apiVersion: apps/v1
     kind: Deployment
     metadata:
       name: cos-was
       namespace: apps-was
     spec:
       selector:
         matchLabels:
           app: cos-was
       replicas: 1
       template:
         metadata:
           labels:
             app: cos-was
         spec:
           containers:
           - name: cos-was
             image: image-registry.openshift-image-registry.svc:5000/apps-was/cos-was
             ports:
               - containerPort: 9080
             livenessProbe:
               httpGet:
                 path: /CustomerOrderServicesWeb/index.html
                 port: 9080
               periodSeconds: 30
               failureThreshold: 6
               initialDelaySeconds: 90
             readinessProbe:
               httpGet:
                 path: /CustomerOrderServicesWeb/index.html
                 port: 9080
               periodSeconds: 10
               failureThreshold: 3
             volumeMounts:
             - mountPath: /etc/websphere
               name: authdata
               readOnly: true
           volumes:
           - name: authdata
             secret:
                 secretName: authdata
     ```

     - Note:
       - The liveness probe is used to tell Kubernetes when the application is live. Due to the size of the traditional WAS image, the initialDelaySeconds attribute has been set to 90 seconds to give the container time to start.
       - The readiness probe is used to tell Kubernetes whether the application is ready to serve requests. 
       - You may store property file based configuration files such as configmaps and secrets, and bind their contents into the `/etc/websphere` directory. 
       - When the container starts, the server startup script will apply all the property files found in the `/etc/websphere` directory to reconfigure the server.
       - For our example, the `volumeMounts` and `volumes` are used to bind the contents of the secret `authdata` into the directory `/etc/websphere` during container startup. 
       - After it is bound, it will appear as the file `/etc/websphere/authdata.properties`. 
         - For volumeMounts:
           - The mountPath, `/etc/websphere`, specifies the directory where the files are bound.
           - the name, `authdata`, specifies the name of the volume
         - For volumes:
           - the secretName specifies the name of the secret whose contents are to be bound.

   - The file `Secret.yaml` looks like:

     ```yaml
     apiVersion: v1
     kind: Secret
     metadata:
       name: authdata
       namespace: apps-was
     type: Opaque
     stringData:
       authdata.props: |-
         #
         # Configuration properties file for cells/DefaultCell01|security.xml#JAASAuthData_1597094577206#
         # Extracted on Tue Aug 11 15:30:36 UTC 2020
         #

         #
         # Section 1.0 ## Cell=!{cellName}:Security=:JAASAuthData=alias#DBUser
         #

         #
         # SubSection 1.0.0 # JAASAuthData Section
         #
         ResourceType=JAASAuthData
         ImplementingResourceType=GenericType
         ResourceId=Cell=!{cellName}:Security=:JAASAuthData=alias#DBUser
         AttributeInfo=authDataEntries
         #

         #
         #Properties
         #
         password="{xor}Oz1tNjEsK24=" #required
         alias=DBUser #required
         userId=db2inst1 #required
         description=

         #
         # End of Section 1.0# Cell=!{cellName}:Security=:JAASAuthData=alias#DBUser
         #
         #
         #
         EnvironmentVariablesSection
         #
         #
         #Environment Variables
         cellName=DefaultCell01
     ```

     - The attribute `authdata.properties` contains the properties file based configure used to update the database userId and password for the JAASAuthData whose alias is DBUser. 
     - The configuration in Deployment.yaml maps it as the file `/etc/websphere/authdata.properties` during container startup so that the application server startup script can automatically configure the server with these entries. 


<a name="access-the-application"></a>
## Access the application without operator (Hands-on)

1. Confirm you're at the current project `apps-was`:
   ```
   oc project
   ```
   
   Example output:
   ```
   Using project "apps-was" on server "https://c114-e.us-south.containers.cloud.ibm.com:30016".
   ```
   - If it's not at the project `apps-was`, then switch:
     ```
     oc project apps-was
     ```
1. Run the following command to verify the pod is running:
   ```
   oc get pod
   ```
   If the status does not show `1/1` READY, wait a while, checking status periodically:
   ```
   NAME                       READY   STATUS    RESTARTS   AGE
   cos-was-6bd4767bf6-xhr92   1/1     Running   0          120m
   ```

1. Run the following command to get the URL of your application (the route URL plus the application contextroot): 
   ```
   echo http://$(oc get route cos-was  --template='{{ .spec.host }}')/CustomerOrderServicesWeb
   ```
   
   Example output:
   ```
   http://cos-was-apps-was.apps.demo.ibmdte.net/CustomerOrderServicesWeb
   ```

1. Return to your Firefox browser window and go to the URL outputted by the command run in the previous step.

1. You will be prompted to login in order to access the application. Enter the following credentials:
    - Username: **skywalker**
    - Password: **force**

    ![accessapplication1](extras/images/accessapplication1.png)

1. After login, the application page titled _Electronic and Movie Depot_ will be displayed. From the `Shop` tab, click on an item (a movie) and on the next pop-up panel, drag and drop the item into the shopping cart. 

    ![accessapplication2](extras/images/accessapplication2.png)

1. Add a few items to the cart. As the items are added, they’ll be shown under _Current Shopping Cart_ (on the upper right) with _Order Total_.

    ![accessapplication3](extras/images/accessapplication3.png)

1. Close the browser.

### Review the application workload flow without operator (Hands-on)

1. Below is an overview diagram on the deployment you've completed from the above steps: 
   - Note: DB2 in the middle of the diagram is pre-installed through a different project `db` and has been up and running before your hands-on.  Also it will not be impacted when you're removing the deployment in next step.

   ![application flow with standard deployment](extras/images/app-flowchart_1.jpg)
   
 
1. Return to the Firefox browser and open the OpenShift Console to view the resources on the deployment.

1. View the resources in the project `apps-was`:
     - Select the `apps-was` project from the project drop down menu.
     - View `deployment` details:
       - Click on the **Deployments** tab under **Workloads** from the left menu and select `cos-was`
     
         ![app-was deployment1](extras/images/workload-deploy1.jpg)
   
       - Navigate to the `YAML` tab to view the content of yaml
     
         ![app-was deployment2](extras/images/workload-deploy2.jpg)
     
     
     - View `pod` details:
       - Click on the **Pods** tab under **Workloads** from the left menu and select the pod with name starting with `cos-was`
     
         ![app-was pod1](extras/images/workload-pod1.jpg)
     
       - Navigate to the `Logs` tab to view the WebSphere Application Server log
     
         ![app-was pod3](extras/images/workload-pod3.jpg)
     
       - Navigate to the `Terminal` tab to view the files inside the container
     
         ![app-was pod4](extras/images/workload-pod4.jpg)
     
     
         ![app-was pod5](extras/images/workload-pod5.jpg)
     
     
     - View `secret` details:
       - Click on the **Secrets** tab under **Workloads** from the left menu and select the `authdata` secret.
     
         ![app-was secret1](extras/images/workload-secret1.jpg)
      
       - Scroll down to the **Data** section and click on the copy icon to view the content.
     
         ![app-was secret2](extras/images/workload-secret2.jpg)
      
      
     - View `service` details:
       - Click on the **Services** tab under **Networking** from the left menu and select the `cos-was` service.

         ![service](extras/images/reviewapplication1.png)

       - Review service information including address and port mapping details.
   
         ![app-was service](extras/images/network-service.jpg)
      
      
     - View `route` details:
       - Click on the **Routes** tab under **Networking** from the left menu and select the `cos-was` route.

         ![app-was route](extras/images/network-route.jpg)

     <a name="db project resource"></a>
  1. View the resources in the project `db`:
     - Select the `db` project from the project drop down menu.

     - View `deployment` details:   
       - Click on the **Deployments** tab under **Workloads** from the left menu and select `cos-db-was`
       
         ![db deploy1](extras/images/db_deploy_1.jpg)

       - Navigate to the `YAML` tab to view the content of yaml
       
         ![db deploy2](extras/images/db_deploy_2.jpg)
        
     - View `pod` details:
       - Click on the **Pods** tab under **Workloads** from the left menu and select the pod with name starting with `cos-db-was`
       
         ![db pod1](extras/images/db_pod_1.jpg)
       
       - Navigate to the `Logs` tab to view the database logs
       - Navigate to the `Terminal` tab to view the files in the database container
       
         ![db pod2](extras/images/db_pod_2.jpg)
        
     - View `service` details:
       - Click on the **Services** tab under **Networking** from the left menu and select the `cos-db-was` service.
       
         ![db service1](extras/images/db_net_service_1.jpg)

         ![db service2](extras/images/db_net_service_2.jpg)



## Remove your deployment (standard deployment without operator) (Hands-on)

To remove the deploment from the above scenario without the operator, run the command:
> Note: The pre-installed resources such as DB2, are not removed.

```
oc delete -f deploy
```

Output:
```
deployment.apps "cos-was" deleted
route.route.openshift.io "cos-was" deleted
secret "authdata" deleted
service "cos-was" deleted
```

<a name="deploy-rco"></a>
## Alternate Deployment Via Runtime Component Operator

Another way to deploy the application is via the Runtime Component Operator. It is a generic operator used to deploy different types of application images. The operator has already been installed into your environment. For more information, see: https://github.com/application-stacks/runtime-component-operator

### Deploy application (via Runtime Component Operator) (Hands-on)

1. Run the following command which uses the Runtime Component Operator to deploy the same Customer Order Service application image:
   ```
   oc apply -f deploy-rco
   ```
   
   Output:
   ```
   runtimecomponent.app.stacks/cos-was-rco created
   secret/authdata-rco created
   ```

1. Let's review what we just did. 
   - First, list the contents of the `deploy-rco` directory:

     ```
     ls deploy-rco
     ```

     The output shows there are only two yaml files:
     ```
     RuntimeComponent.yaml  Secret.yaml
     ```

   - Review Secret.yaml: 
     ```
     cat deploy-rco/Secret.yaml
     ```

     - Note that it is the same as the `Secret.yaml` in the `deploy` directory, except the name has been changed to `authdata-rco`.  
     - It serves the same purpose for this new deployment - to override the database user/password.


    - Review RuntimeComponent.yaml:
      ```
      cat deploy-rco/RuntimeComponent.yaml
      ```

      And the output:
      
      ```yaml
      apiVersion: app.stacks/v1beta1
      kind: RuntimeComponent
      metadata:
        name: cos-was-rco
        namespace: apps-was
      spec:
        applicationImage: image-registry.openshift-image-registry.svc:5000/apps-was/cos-was
        service:
          port: 9080
        readinessProbe:
          httpGet:
            path: /CustomerOrderServicesWeb/index.html
            port: 9080
          periodSeconds: 10
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /CustomerOrderServicesWeb/index.html
            port: 9080
          periodSeconds: 30
          failureThreshold: 6
          initialDelaySeconds: 90
        expose: true
        route:
          termination: edge
          insecureEdgeTerminationPolicy: Redirect
        volumeMounts:
          - mountPath: /etc/websphere
            name: authdata-rco
            readOnly: true
        volumes:
          - name: authdata-rco
            secret:
                secretName: authdata-rco
      ```

      Note that:
      - The kind is `RuntimeComponent`
      - The `expose` attribute is set to `true` to expose a route
      - The attributes within the yaml file are essentially the same information that you provided for the `Service`, `Route`, and `Deployment` resources in the `deploy` directory.
      - The controller for the RuntimeComponent custom resource reacts to changes in the above specification, and creates the corresponding `Service`, `Route`, and `Deployment` objects. Issue the following commands to view what the controller has created:

         ```
         oc get Deployment cos-was-rco -o yaml
         oc get Service cos-was-rco -o yaml
         oc get Route cos-was-rco -o yaml
         ```

## Access the application (via Runtime Component Operator) (Hands-on)

1. Confirm you're at the current project `apps-was`:
   ```
   oc project
   ```
   
   Example output:
   ```
   Using project "apps-was" on server "https://c114-e.us-south.containers.cloud.ibm.com:30016".
   ```
   - If it's not at the project `apps-was`, then switch:
     ```
     oc project apps-was
     ```
1. Run the following command to verify the pod is running:
   ```
   oc get pod
   ```

   If the status does not show `1/1` READY, wait a while, checking status periodically. Note the prefix name for the pod is `cos-was-rco`.
   ```
   NAME                           READY   STATUS    RESTARTS   AGE
   cos-was-rco-6779784fc8-pz92m   1/1     Running   0          2m59s
   ```

1. Run the following command to get the URL of your application (the route URL plus the application contextroot): 

   ```
   echo http://$(oc get route cos-was-rco  --template='{{ .spec.host }}')/CustomerOrderServicesWeb
   ```
   
   Example output:
   ```
   http://cos-was-rco-apps-was.apps.demo.ibmdte.net/CustomerOrderServicesWeb
   ```

1. Return to your Firefox browser window and go to the URL outputted by the command run in the previous step. The steps to access the application are the same as those used when deploying without the operator.

1. You will be prompted to login in order to access the application. Enter the following credentials:
    - Username: **skywalker**
    - Password: **force**

    ![withoutoperator1](extras/images/withoutoperator1.png)

1. After login, the application page titled _Electronic and Movie Depot_ will be displayed. From the `Shop` tab, click on an item (a movie) and on the next pop-up panel, drag and drop the item into the shopping cart. 

    ![accessapplication2](extras/images/accessapplication2.png)

1. Add a few items to the cart. As the items are added, they’ll be shown under _Current Shopping Cart_ (on the upper right) with _Order Total_.

    ![accessapplication3](extras/images/accessapplication3.png)

1. Close the browser.
  

### Review the application workload flow with Runtime Component Operator (Hands-on)

1. Below is an overview diagram on the deployment you've completed from the above steps using Runtime Component Operator: 
   - Note: DB2 in the middle of the diagram is pre-installed through a different project `db` and has been up and running before your hands-on.

   ![applicaiton flow with runtime component operator deployment](extras/images/app-flowchart_2.jpg)


1. Return to the Firefox browser and open the OpenShift Console to view the resources on the deployment.

1. View the resources in the project `openshift-operators`:
     - Select the `openshift-operators` project from the project drop down menu.
     - View operator `deployment` details:
       - Click on the **Deployments** tab under **Workloads** from the left menu and select `runtime-component-operator`
             
         ![rco deploy1](extras/images/rco-deploy1.jpg)
         
       - Navigate to the `YAML` tab to view the content of yaml
       
         ![rco deploy2](extras/images/rco-deploy2.jpg)
   
     - View operator `pod` details:
       - Click on the **Pods** tab under **Workloads** from the left menu and select the pod with name starting with `runtime-component-operator`
       
         ![rco pod1](extras/images/rco-pod1.jpg)
         
       - Navigate to `Logs` to view the runtime-component-operator container log
       
         ![rco pod2](extras/images/rco-pod2.jpg)
         
       - Navigate to `Terminal` to view the files in the container
       
          ![rco pod3](extras/images/rco-pod3.jpg)
               
   
  1. View the resources in the project `apps-was`:
     - Select the `apps-was` project from the project drop down menu.
   
     - View `Runtime Component` instance details:
       - Click on the **Installed Operators** tab under **Operators** from the left menu and select `Runtime Component Operator`.  
          > Note: The operator is installed at cluster level and is visible to all existing projects, but Runtime Component instance is created under the project `apps-was`.
     
         ![rco op1](extras/images/rco-op1.jpg)

       - Navigate to the `YAML` tab to view the content of yaml
     
         ![rco op2](extras/images/rco-op2.jpg)

       - Navigate to the`Runtime Component` tab and select `cos-was-rco` to view the deails of Runtime Component instance
       
         ![rco op3](extras/images/rco-op3.jpg)
     
     - View `deployment` details:
       - Click on the **Deployments** tab under **Workloads** from the left menu and select `cos-was-rco`.
       
         ![rc workload deploy1](extras/images/rc-workload-deploy1.jpg)  
       
       - Navigate to the `YAML` tab to view the content of yaml.    
          > Note the deployment is created through the controller of RuntimeComponent custom resource.
       
         ![rc workload deploy2](extras/images/rc-workload-deploy2.jpg)
         
         
     - View `pod` details:    
       - Click on the **Pods** tab under **Workloads** from the left menu and select the pod starting with `cos-was-rco`
       
         ![rc workload pod1](extras/images/rc-workload-pod1.jpg)  
       
       - Navigate to the `Logs` tab to view the WebSphere Application Server log
       
         ![rc workload pod2](extras/images/rc-workload-pod2.jpg)  
         
     - View `service` details:
       - Click on the **Services** tab under **Networking** from the left menu and select `cos-was-rco`
       
         ![rc network service1](extras/images/rc-net-service1.jpg) 
         
       - Navigate to the `YAML` tab to view the content of yaml.    
          > Note the service is created through the controller of RuntimeComponent custom resource.
         
         ![rc network service2](extras/images/rc-net-service2.jpg) 
       
     - View `route` details:
       - Click on the **Routes** tab under **Networking** from the left menu and select `cos-was-rco`
       
         ![rc network route1](extras/images/rc-net-route1.jpg) 
         
       - Navigate to the `YAML` tab to view the content of yaml.  
          > Note the route is created through the controller of RuntimeComponent custom resource.
         
         ![rc network route2](extras/images/rc-net-route2.jpg)   
     
      - View `secret` details:
        - Click on the **Secrets** tab under **Workloads** from the left menu and select `authdata-rco`
        
          ![rc workload secret1](extras/images/rc-workload-secret1.jpg) 
        
  1.  Resources in the project `db`: 
      - Same information as listed in the section above in **Review the application workload flow without operator**.
         
         
## Cleanup (the deployment with Runtime Component Operator) (Hands-on)

1. Run the following command in a terminal window to remove the deployment from the above secenario with Runtime Component instance:
   - Note: The pre-installed resources such as Runtime Component Operator, DB2, are not removed.

     ```
     oc delete -f deploy-rco
     ```
   
     Output:
     ```
     runtimecomponent.app.stacks "cos-was-rco" deleted
     secret "authdata-rco" deleted
     ```

1. Verify that the corresponding application `Service`, `Route`, and `Deployment` have also been deleted:

   ```
   oc get Deployment 
   oc get Service 
   oc get Route 
   ```
   
   Output from each `get` command above should be:
   ```
   No resources found in apps-was namespace.
   ```

<a name="summary"></a>
## Summary

Congratulations! You've completed the **Operational Modernization** lab. You containerized and deployed a monolith application to cloud!

<a name="next"></a>
## Next
Please follow the link to the next lab **Runtime Modernization**:
- [Runtime Modernization](../RuntimeModernization)

