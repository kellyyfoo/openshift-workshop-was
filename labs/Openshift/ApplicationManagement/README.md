# Application Management

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Application Logging](#application-logging-hands-on) (Hands-on)
- [Application Monitoring](#application-monitoring-hands-on) (Hands-on)
- [Day-2 Operations](#day-2-operations-hands-on) (Hands-on)
- [Summary](#summary)

## Introduction

In this lab, you'll learn about managing your running applications efficiently using various tools available to you as part of OpenShift and OperatorHub, including the Open Liberty Operator.

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

## Prerequisites

1. Open a terminal window from the VM desktop.

    ![terminal window](extras/images/build1.png)

1. Login to OpenShift CLI with the `oc login` command from the web terminal. When prompted for the username and password, enter the following login credentials:
    - Username: **ibmadmin**
    - Password: **engageibm**
    
      ![oc login](extras/images/build2.png)

1. If you have not yet cloned the GitHub repo with the lab artifacts, then run the following command on your terminal:
    ```
    git clone https://github.com/IBM/openshift-workshop-was.git
    ```


## Build and deploy the traditional WebSphere application (Hands-on)

1. Change to the lab's directory:
   ```
   cd openshift-workshop-was/labs/Openshift/OperationalModernization
   ```

1. Create and switch over to the project `apps-was`. 
    > Note: The first step `oc new-project` may fail if the project already exists. If so, proceed to the next command.
   ```
   oc new-project apps-was
   oc project apps-was
   ```

 1. Build and deploy the application by running the commands in the following sequence. Reminder: the `.` at the end of the first command.
    ```
    docker build --tag default-route-openshift-image-registry.apps.demo.ibmdte.net/apps-was/cos-was .
    docker login -u openshift -p $(oc whoami -t) default-route-openshift-image-registry.apps.demo.ibmdte.net
    docker push default-route-openshift-image-registry.apps.demo.ibmdte.net/apps-was/cos-was
    oc apply -f deploy
    ```
    Example output: 
    ```
    deployment.apps/cos-was created
    route.route.openshift.io/cos-was created
    secret/authdata created
    service/cos-was created
    ```

1. Wait for the pod to be available, check status via `oc get pod`
    
    The output should be: 
    ```
    NAME                      READY   STATUS    RESTARTS   AGE
    cos-was-7d5ff6945-4hjzr   1/1     Running   0          88s
    ```

1. Get the URL to the application:
   ```
   echo http://$(oc get route cos-was  --template='{{ .spec.host }}')/CustomerOrderServicesWeb
   ```
   Example output:
   ```
   http://cos-was-apps-was.apps.demo.ibmdte.net/CustomerOrderServicesWeb
   ```
1. Open a Firefox web browser window from within the VM.

    ![firefox](extras/images/analysis1.png)

1. Go to the URL outputted by the command run in the previous step.

1. You will be prompted to login in order to access the application. Enter the following credentials:
    - Username: **skywalker**
    - Password: **force**

    ![accessapplication1](extras/images/accessapplication1.png)

1. After login, the application page titled _Electronic and Movie Depot_ will be displayed. From the `Shop` tab, click on an item (a movie) and on the next pop-up panel, drag and drop the item into the shopping cart. 

    ![accessapplication2](extras/images/accessapplication2.png)

1. Add a few items to the cart. As the items are added, they’ll be shown under _Current Shopping Cart_ (on the upper right) with _Order Total_.

    ![accessapplication3](extras/images/accessapplication3.png)

1. Close the browser.

## Build and deploy the Liberty application 
(Skip this step if you just finished the previous lab [Runtime Modernization](https://github.com/IBM/openshift-workshop-was/tree/master/labs/Openshift/RuntimeModernization) and did not clean up the deployment)

> Note: The following steps are to help you re-deploy the Liberty application if the deployment has been deleted from the previous lab Runtime Modernization.  The deployment is required to generate data for the follow-on steps in monitoring.

1. From the top level directory, change to the lab's directory `RuntimeModernization` folder:
   ```
   cd openshift-workshop-was/labs/Openshift/RuntimeModernization
   ```

1. Create and switch over to the project `apps`. Also, enable monitoring for the project. 
    > Note: The first step `oc new-project` may fail if the project already exists. If so, proceed to the next command.
   ```
   oc new-project apps
   oc project apps
   oc label namespace apps app-monitoring=true
   ```

1. Build and deploy the application by running the commands in the following sequence. Reminder: the `.` at the end of the first command:
   ```
   docker build --tag default-route-openshift-image-registry.apps.demo.ibmdte.net/apps/cos .
   docker login -u openshift -p $(oc whoami -t) default-route-openshift-image-registry.apps.demo.ibmdte.net
   docker push default-route-openshift-image-registry.apps.demo.ibmdte.net/apps/cos
   oc apply -k deploy/overlay-apps
   ```
   Example output:
   ```
   configmap/cos-config created
   secret/db-creds created
   secret/liberty-creds created
   openlibertyapplication.openliberty.io/cos created
   ```

1. Verify the route for the application is created:
   ```
   oc get route cos
   ```
   Example output:
   ```
   NAME   HOST/PORT                       PATH   SERVICES   PORT       TERMINATION          WILDCARD
   cos    cos-apps.apps.demo.ibmdte.net          cos        9443-tcp   reencrypt/Redirect   None
   ```

1. Verify your pod is ready:
   ```
   oc get pod 
   ```
   Example output:
   ```
   NAME                   READY   STATUS    RESTARTS   AGE
   cos-54975b94c6-rh6kt   1/1     Running   0          3m11s
   ```

1. Get the application URL:
   ```
   echo http://$(oc get route cos  --template='{{ .spec.host }}')/CustomerOrderServicesWeb
   ```
   Example output:
   ```
   http://cos-apps.apps.demo.ibmdte.net/CustomerOrderServicesWeb
   ```

1. Return to your Firefox browser window and go to the URL outputted by the command run in the previous step.

1. You will be prompted to login in order to access the application. Enter the following credentials:
    - Username: **skywalker**
    - Password: **force**

    ![accessapplication1](extras/images/accessapplication1.png)

1. After login, the application page titled _Electronic and Movie Depot_ will be displayed. From the `Shop` tab, click on an item (a movie) and on the next pop-up panel, drag and drop the item into the shopping cart. **Add multiple items to the shopping cart to trigger more logging.**

    ![accessapplication2](extras/images/accessapplication2.png)

1. Add a few items to the cart. As the items are added, they’ll be shown under _Current Shopping Cart_ (on the upper right) with _Order Total_.

    ![accessapplication3](extras/images/accessapplication3.png)
  
## Application Logging (Hands-on)

Pod processes running in OpenShift frequently produce logs. To effectively manage this log data and ensure no loss of log data occurs when a pod terminates, a log aggregation tool should be deployed on the cluster. Log aggregation tools help users persist, search, and visualize the log data that is gathered from the pods across the cluster. Let's look at application logging with log aggregation using EFK (Elasticsearch, Fluentd, and Kibana). Elasticsearch is a search and analytics engine. Fluentd receives, cleans and parses the log data. Kibana lets users visualize data stored in Elasticsearch with charts and graphs.

If it has been a long time (more than 15 minutes) since the Liberty or WebSphere pods last started, you may want to delete each pod and let a new one start, to ensure that Liberty and WebSphere create some recent logs for Kibana to find.

### Launch Kibana (Hands-on)
1. In your Firefox window, click on the **openshift console** bookmark in the top left, and log in with the **htpasswd** option.

    ![openshift console](extras/images/analysis2.png)

1. Log in to the OpenShift account using the following credentials:
    - Username: **ibmadmin**
    - Password: **engageibm**

    ![login](extras/images/analysis3.png)

1. In the OpenShift console, from the left-panel, select **Networking** > **Routes**.

1. From the _Project_ drop-down list, select `openshift-logging`. 

1. In the `kibana` route, click on the URL listed under _Location_.

    ![applogging1](extras/images/applogging1.png)

1. This will open a new tab asking you to authorize access. Click on `Allow selected permissions`.

    ![applogging2](extras/images/applogging2.png)

1. In the Kibana console, you'll be prompted to create an index pattern. An index pattern tells Kibana what indices to look for in Elasticsearch. Type `app` so that the index pattern looks like this screenshot:

    ![index pattern app](extras/images/create-index-pattern.png)

    You should see that your pattern matches at least one index. Then click **Next step**.

1. Click the drop-down for **Time Filter field name** and choose **@timestamp**. Then click **Create index pattern**.

    ![index pattern time filter](extras/images/create-index-pattern-time.png)

1. You should see a number of fields populated, around 260. To check that the correct fields have been detected, type `ibm` in the **Filter** text box. You should see many fields beginning with the text `ibm`. If not, try clicking the refresh button (arrows in a circle) at the top right of the page.

    ![ibm index patterns](extras/images/ibm-index-patterns.png)

### Import dashboards (Hands-on)

1. Download [this zip file](dashboards/dashboards.zip) containing dashboards to your VM and unzip it to a local directory. This will extract the **grafana** and **kibana** folders.

    ![unzip](extras/images/applogging5.png)

1. Let's import dashboards for Liberty and WAS. From the left-panel, click on **Management**. Click on the **Saved Objects** tab and then click on **Import**.

    ![import saved objects](extras/images/applogging3.png)

1. Click on **Import** from the right panel that is displayed.

    ![import saved objects](extras/images/applogging4.png)

1. This will open your VM's files. Navigate to where you unzipped the dashboards file. Open the **kibana** folder and select the `ibm-open-liberty-kibana5-problems-dashboard.json` file. Click **Open**.

    ![import saved objects](extras/images/applogging6.png)

1. Click the **Import** button at the bottom of the panel. 

    ![import saved objects](extras/images/applogging7.png)

1. When prompted to resolve pattern conflicts, select `app*` as the new index from the drop down menu. Click **Confirm all changes**. 

    ![select index pattern](extras/images/applogging8.png)

1. It'll take few seconds for the dashboard to import. Click **Done** when it finishes.

    ![select index pattern](extras/images/applogging9.png)

1. Repeat the steps 3 - 7 to import the `ibm-open-liberty-kibana5-traffic-dashboard.json` and `ibm-websphere-traditional-kibana5-dashboard.json` files from the **kibana** folder of the unzipped file.

### Explore dashboards (Hands-on)

In the Kibana console, from the left-panel, click on the **Dashboard** tab. You'll see 3 dashboards on the list. The first 2 are for Liberty. The last one is for WAS traditional. Read the description next to each dashboard.

![dashboards](extras/images/applogging10.png)

#### Liberty applications (Hands-on)

1. Click on the `Liberty-Problems-K5-20191122` dashboard. This dashboard visualizes message, trace and FFDC information from Liberty applications.

    ![Liberty Problems Dashboard](extras/images/applogging11.png)

1. By default, data from the last 15 minutes are rendered. Adjust the time-range (from the top-right corner), so that it includes data from when you tried the Open Liberty application.

    ![Liberty Problems Dashboard](extras/images/applogging12.png)

1. Once the data is rendered, you'll see some information about the namespace, pod, containers where events/problems occurred along with a count for each. 

    ![Liberty Problems Dashboard](extras/images/dashboard-liberty-problems.png)

1. Scroll down to **Liberty Potential Problem Count** section which lists the number of ERROR, FATAL, SystemErr and WARNING events. You'll likely see some WARNING events.

1. Below that you'll see **Liberty Top Message IDs**. This helps to quickly identify frequently occurring events and their timeline.

    ![Liberty Problems Dashboard](extras/images/applogging13.png)

1. Click on the number above **WARNING**. The dashboard will change other panels to show just the events for warnings. Using this, you can determine whether the failures occurred on one or multiple pods/servers and whether they occurred around the same or different time.

    ![Liberty Problems Dashboard](extras/images/applogging14.png)

1. Scroll-down to the actual warning messages. In this case, some dojo files were not found. Even though they are warnings, it'll be good to fix them by updating the application (we won't do that as part of this workshop).

    ![Liberty Problems Dashboard](extras/images/applogging15.png)

1. Go back to the list of dashboards and click on `Liberty-Traffic-K5-20191122`. This dashboard helps to identify failing or slow HTTP requests on Liberty applications.

    ![Liberty Traffic Dashboard](extras/images/applogging16.png)

1. As before, adjust the time-range at the top right of the page if no data is rendered.

1. You'll see some information about the namespace, pod, containers for the traffic along with a count for each. 

    ![Liberty Traffic Dashboard](extras/images/dashboard-liberty-traffic.png)

1. Scroll-down to the **Liberty Error Response Code Count** section which lists the number of failed requests with HTTP response codes in the 400s and 500s ranges.

1. Scroll-down to **Liberty Top URLs** which lists the most frequently accessed URLs

    ![Liberty Traffic Dashboard](extras/images/applogging17.png)

    - The _/health_ and _/metrics_ endpoints are running on the same server and are queried frequently for readiness/liveness probes and scraping metrics information.

1. On the right-hand side, you'll see list of endpoints that had the slowest response times.

1. Click on the number listed above **400s - Count**. The dashboard will change other panels to show only the traffic with response codes in 400s. You can see the timeline and the actual messages below. These are related to warnings from last dashboard about dojo files not being found (response code 404).

    ![Liberty Traffic Dashboard](extras/images/applogging18.png)

#### Traditional WebSphere applications (Hands-on)

1. Return to the list of dashboards and click on `WAS-traditional-Problems-K5-20190609`. Similar to the first dashboard for Liberty, this dashboard visualizes message and trace information for WebSphere Application Server traditional.

    ![WebSphere Problems Dashboard](extras/images/applogging19.png)
    
1. Again, adjust the time-range as necessary if no data is rendered.

1. Same as before, explore the panels and filter through the events to see messages corresponding to just those events.

    ![WebSphere Problems Dashboard](extras/images/dashboard-websphere-problems.png)

## Application Monitoring (Hands-on)

Building observability into applications externalizes the internal status of a system, enabling operations teams to monitor systems more effectively. It is important that applications are written to produce metrics. When the Customer Order Services application was modernized, we used MicroProfile Metrics and it provided a `/metrics` endpoint from where all metrics emitted by the JVM, Open Liberty server and deployed applications could be accessed. Operations teams can gather the metrics and store them in a database with tools like Prometheus. The metrics data can then be visualized and analyzed in dashboards, such as Grafana.

### Grafana dashboard (Hands-on)

1. Custom resource [GrafanaDashboard](dashboards/grafana/grafana-dashboard-cos.yaml) defines a set of dashboards for monitoring the Customer Order Services application and Open Liberty. In your terminal, run the following command to create the dashboard resource:

   - Before running the command, change directory to `/openshift-workshop-was/labs/Openshift/ApplicationManagement` if not done so already.

     ```
     oc apply -f dashboards/grafana/grafana-dashboard-cos.yaml
     ```
    Example output: 
    ```
    grafanadashboard.integreatly.org/liberty-metrics-dashboard created
    ```

1. The following steps to access the created dashboard are illustrated in the screen recording at the end of this section: 

   - In the OpenShift console, from the left-panel, select **Networking** > **Routes**.

   - From the Project drop-down list, select `app-monitoring`. 

   - In the `grafana-route` route, click on the URL listed under the **Location** column.

   - Click on **Log in with OpenShift**. Then, click on **Allow selected permissions**.

   - In the Grafana home page, from the left-panel, hover over the dashboard icon and click on **Manage**.

   - You should see `Liberty-Metrics-Dashboard` listed. Click on it.

   - Explore the dashboards. The first 2 are for the Customer Order Services application. The rest are for Liberty.

   - Click on **Customer Order Services - Shopping Cart**. By default, it'll show data from the last 15 minutes. Adjust the time-range from the top-right as necessary. 

   - You should see the frequency of requests, number of requests, pod information, and min/max request times.

   - Scroll-down to expand the **CPU** section. You'll see information about process CPU time and CPU system load for pods.

   - Scroll-down to expand the **Servlets** section. You'll see request count and response times for application servlet as well as health and metrics endpoints.

   - Explore the other sections.

     ![requesting server dump](extras/images/monitoring-dashboard.gif)


## Day-2 Operations (Hands-on)

You may need to gather server traces and/or dumps for analyzing some problems. Open Liberty Operator makes it easy to gather these on a server running inside a container.

A storage must be configured so the generated artifacts can persist, even after the Pod is deleted. This storage can be shared by all instances of the Open Liberty applications. RedHat OpenShift on IBM Cloud utilizes the storage capabilities provided by IBM Cloud. Let's create a request for storage.

### Request storage (Hands-on)

1. In the OpenShift console, from the left-panel, select **Storage** > **Persistent Volume Claims**.

1. From the Project drop-down list, select `apps`. 

1. Click on the **Create Persistent Volume Claim** button.

    ![create volume claim](extras/images/operations1.png)

1. Ensure that **Storage Class** is `managed-nfs`. If not, select it from the list.

1. Enter `liberty` for the **Persistent Volume Claim Name** field.

1. Request 1 GiB by entering `1` in the text box for **Size**.

1. Click on **Create**.

    ![create volume claim](extras/images/operations2.png)

1. The created Persistent Volume Claim will be displayed. Wait for the **Status** field to change from `Pending` to `Bound`. It may take 1-2 minutes.

1. Once bound, you should see the volume displayed under the **Persistent Volume** field.

    ![create volume claim](extras/images/operations3.png)

### Enable serviceability (Hands-on)

Now, let's enable the serviceability option for the Customer Order Services application. It's recommended that you do this step during initial deployment of the application - not when you encounter an issue and need to gather server traces or dumps. OpenShift cannot attach volumes to running Pods. It'll have to create a new Pod, attach the volume, and then take down the old Pod. If the problem is intermittent or hard to reproduce, you may not be able to reproduce it on the new instance of server running in the new Pod. The volume can be shared by all Liberty applications that are in the same namespace and won't be used unless you perform day-2 operation on a particular application. This makes it easy to enable serviceability with initial deployment.

1. Specify the name of the storage request (Persistent Volume Claim) you made earlier to the `spec.serviceability.volumeClaimName` parameter provided by the `OpenLibertyApplication` custom resource. The Open Liberty Operator will attach the volume bound to the claim to each instance of the server. 

    In your terminal, run the following command:

    ```
    oc patch olapp cos -n apps --patch '{"spec":{"serviceability":{"volumeClaimName":"liberty"}}}' --type=merge
    ```
    - This patches the definition of `olapp` (shortname for `OpenLibertyApplication`) instance `cos` in namespace `apps` (indicated by `-n` option). 
    - The `--patch` option specifies the content to patch with. In this case, we set the value of `spec.serviceability.volumeClaimName` field to `liberty`, which is the name of the Persistent Volume Claim you created earlier. 
    - The `--type=merge` option specifies to merge the previous content with the newly specified field and its value.

1. Run the following command to get the status of `cos` application. Verify that the changes were reconciled and there are no errors:

    ```
    oc get olapp cos -n apps -o wide
    ```
    Example output:
    ```
    NAME IMAGE                                                      EXPOSED   RECONCILED  REASON  MESSAGE  DEPENDENCIESSATISFIED                        AGE
    cos  image-registry.openshift-image-registry.svc:5000/apps/cos  true      True                         True                                   14h

    ```
    The value under `RECONCILED` should be `True`. 
    
    > Note: If it's `False`, then an error occurred. The `REASON` and `MESSAGE` columns will display the cause of the failure. A common mistake is creating the Persistent Volume Claim in another namespace. Ensure that it is created in the `apps` namespace.


1. In the OpenShift console, from the left-panel, click on **Workloads** > **Pods**. Wait until there is only 1 pod on the list and its **Ready** column says 1/1.

1. Click on this pod.

    ![pod name](extras/images/operations4.png)

1. The pod's name is needed for requesting server dump and trace in the next sections. Scroll down and copy the value under the **Name** field.

    ![requesting server dump](extras/images/operations5.png)

### Request server dump (Hands-on)

You can request a snapshot of the server status including different types of server dumps, from an instance of Open Liberty server running inside a Pod, using Open Liberty Operator and `OpenLibertyDump` custom resource (CR). 

The following steps to request a server dump are illustrated in the screen recording below:

1. From the left-panel of the OpenShift console, click on **Operators** > **Installed Operators**.

1. From the **Open Liberty Operator** row, click on `Open Liberty Dump` (displayed under the **Provided APIs** column).

1. Click on the **Create OpenLibertyDump** button. 

1. Replace `Specify_Pod_Name_Here` in the **Pod Name** text field with the pod name you copied earlier.

1. The **Include** field specifies the type of server dumps to request. Let's use the default `heap` and `thread` values.

1. Click on the **Create** button.

1. Click on `example-dump` from the list.

1. Scroll-down to the **Conditions** section and you should see `Started` status has value `True`. Wait for the operator to complete the dump operation. You should see status `Completed` with value `True`.

    ![requesting server dump](extras/images/day2-dump-operation.gif)

### Request server traces (Hands-on)

You can also request server traces from an instance of Open Liberty server running inside a Pod using the `OpenLibertyTrace` custom resource (CR).

The following steps to request a server trace are illustrated in the screen recording below:

1. From the left-panel of the OpenShift console, click on **Operators** > **Installed Operators**.

1. From the **Open Liberty Operator** row, click on `Open Liberty Trace`.

1. Click on the **Create OpenLibertyTrace** button.

1. Replace `Specify_Pod_Name_Here` under the **Pod Name** text field with the pod name you copied earlier.

1. The **Trace Specification** field specifies the trace string to be used to selectively enable trace on Liberty server. Let's use the default value. 

1. Click on the **Create** button.

1. Click on `example-trace` from the list.

1. Scroll-down to the **Conditions** section and you should see `Enabled` status has value `True`. 
    - _Note:_ Once the trace has started, it can be stopped by setting the `disable` parameter to true. Deleting the CR will also stop the tracing. Changing the `podName` will first stop the tracing on the old Pod before enabling traces on the new Pod. Maximum trace file size (in MB) and the maximum number of files before rolling over can be specified using `maxFileSize` and `maxFiles` parameters.

    ![requesting server trace](extras/images/day2-trace-operation.gif)

### Accessing the generated files (Hands-on)

The generated trace and dump files should now be in the persistent volume. You used storage from IBM Cloud, and we have to go through a number of steps using a different tool to access those files. Since the volume is attached to the Pod, we can instead use the Pod's terminal to easily verify that the trace and dump files are present.

The following steps to access the files are illustrated in the screen recording below:

1. Remote shell to your pod via one of two ways:
    - From your terminal:
        ```
        oc rsh <pod-name>
        ```
    - From OpenShift console: click on **Workloads** > **Pods**. Click on the pod and then click on **Terminal** tab. 

1. Enter the following command to list the files:
    ```
    ls -R serviceability/apps
    ```
    Example output:
    ```
    serviceability/apps:
    cos-dc4cf7fdd-mvbs7

    serviceability/apps/cos-dc4cf7fdd-mvbs7:
    2021-07-13_16:05:25.zip  messages.log  trace_21.07.13_16.52.34.0.log  trace.log
    ```
    The shared volume is mounted at the `serviceability` folder. The sub-folder `apps` is the namespace of the Pod. You should see a zip file for dumps and trace log files. These are produced by the day-2 operations you performed.
    
    

    ![day-2 files](extras/images/day2-files.gif)


## Summary

Congratulations! You've completed **Application Management** lab! 


