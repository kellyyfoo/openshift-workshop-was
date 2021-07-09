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
1. Return to your Firefox browser window, and go to the URL outputted by the command run in the previous step.

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

1. In OpenShift console, from the left-panel, select **Networking** > **Routes**.

1. From the _Project_ drop-down list, select `openshift-logging`. 

1. Click on the route URL (listed under the _Location_ column).

1. Click on `Log in with OpenShift`. Click on `Allow selected permissions`.

1. In Kibana console, you'll be prompted to create an index pattern. An index pattern tells Kibana what indices to look for in Elasticsearch. Type `app` so that the index pattern looks like this screenshot:

    ![index pattern app](extras/images/create-index-pattern.png)

    You should see that your pattern matches at least one index. Then click **Next step**.

1. Click the drop-down for **Time Filter field name** and choose **@timestamp**. Then click **Create index pattern**.

    ![index pattern time filter](extras/images/create-index-pattern-time.png)

1. You should see a number of fields populated, around 260. To check that the correct fields have been detected, type `ibm` in the **Filter** text box. You should see many fields beginning with the text `ibm`. If not, try clicking the refresh button (arrows in a circle) in the top right of the page.

    ![ibm index patterns](extras/images/ibm-index-patterns.png)

### Import dashboards (Hands-on)

1. Download [this zip file](dashboards/dashboards.zip) containing dashboards to your computer and unzip to a local directory. (Look for the `download` button on the page.)

1. Let's import dashboards for Liberty and WAS. From the left-panel, click on `Management`. Click on `Saved Objects` tab and then click on `Import`, then `Import` at the top of the panel that appears.

    ![import saved objects](extras/images/import-saved-objects.png)

1. Navigate to the _kibana_ sub-directory and select `ibm-open-liberty-kibana5-problems-dashboard.json` file. Then click the `Import` button at the bottom of the panel. When prompted to resolve pattern conflicts, click select `app*` as the new index and click `Confirm all changes`. It'll take few seconds for the dashboard to import. Click `Done` when it finishes.

    ![select index pattern](extras/images/select-index-pattern.png)

1. Repeat the steps to import `ibm-open-liberty-kibana5-traffic-dashboard.json` and `ibm-websphere-traditional-kibana5-dashboard.json`.

### Explore dashboards (Hands-on)

In Kibana console, from the left-panel, click on `Dashboard`. You'll see 3 dashboards on the list. The first 2 are for Liberty. The last one is for WAS traditional. Read the description next to each dashboard.

#### Liberty applications (Hands-on)

1. Click on _Liberty-Problems-K5-20191122_. This dashboard visualizes message, trace and FFDC information from Liberty applications.

    ![Liberty Problems Dashboard](extras/images/dashboard-liberty-problems.png)

1. By default, data from the last 15 minutes are rendered. Adjust the time-range (from the top-right corner), so that it includes data from when you tried the Open Liberty application.

1. Once the data is rendered, you'll see some information about the namespace, pod, containers where events/problems occurred along with a count for each. 

1. Scroll down to `Liberty Potential Problem Count` section which lists the number of ERROR, FATAL, SystemErr and WARNING events. You'll likely see some WARNING events.

1. Below that you'll see `Liberty Top Message IDs`. This helps to quickly identify most occurring events and their timeline.

1. Scroll-up and click on the number below WARNING. Dashboard will change other panels to show just the events for warnings. Using this, you can determine: whether the failures occurred on one particular pod/server or in multiple instances, whether they occurred around the same or different time.

1. Scroll-down to the actual warning messages. In this case some files from dojo were not found. Even though they are warnings, it'll be good to fix them by updating the application (we won't do that as part of this workshop).

1. Go back to the list of dashboards and click on _Liberty-Traffic-K5-20191122_. This dashboard helps to identify failing or slow HTTP requests on Liberty applications.

    ![Liberty Traffic Dashboard](extras/images/dashboard-liberty-traffic.png)

1. As before, adjust the time-range as necessary if no data is rendered.

1. You'll see some information about the namespace, pod, containers for the traffic along with a count for each. 

1. Scroll-down to `Liberty Error Response Code Count` section which lists the number of requests failed with HTTP response codes in 400s and 500s ranges.

1. Scroll-down to `Liberty Top URLs` which lists the most frequently accessed URLs
    - The _/health_ and _/metrics_ endpoints are running on the same server and are queried frequently for readiness/liveness probes and for scraping metrics information. It's possible to add a filter to include/exclude certain applications.

1. On the right-hand side, you'll see list of endpoints that had the slowest response times.

1. Scroll-up and click on the number listed below 400s. Dashboard will change other panels to show just the traffic with response code in 400s. You can see the timeline and the actual messages below. These are related to warnings from last dashboard about dojo files not being found (response code 404).

#### Traditional WebSphere applications (Hands-on)

1. Go back to the list of dashboards and click on _WAS-traditional-Problems-K5-20190609_. Similar to the first dashboard for Liberty, this dashboard visualizes message and trace information for WebSphere Application Server traditional.

    ![WebSphere Problems Dashboard](extras/images/dashboard-websphere-problems.png)

1. As before, adjust the time-range as necessary if no data is rendered.

1. Explore the panels and filter through the events to see messages corresponding to just those events.

## Application Monitoring (Hands-on)

Building observability into applications externalizes the internal status of a system to enable operations teams to monitor systems more effectively. It is important that applications are written to produce metrics. When the Customer Order Services application was modernized, we used MicroProfile Metrics and it provides a `/metrics` endpoint from where you can access all metrics emitted by the JVM, Open Liberty server and deployed applications. Operations teams can gather the metrics and store them in a database by using tools like Prometheus. The metrics data can then be visualized and analyzed in dashboards, such as Grafana.

### Grafana dashboard (Hands-on)

1. Custom resource [GrafanaDashboard](dashboards/grafana/grafana-dashboard-cos.yaml) defines a set of dashboards for monitoring Customer Order Services application and Open Liberty. In your terminal, run the following command to create the dashboard resource:

   - Before running the command, change directory to /openshift-workshop-was/labs/Openshift/ApplicationManagement if it's not already done.

     ```
     oc apply -f dashboards/grafana/grafana-dashboard-cos.yaml
     ```

1. The following steps to access the created dashboard are illustrated in the screen recording at the end of this section: 

   - In OpenShift console, from the left-panel, select **Networking** > **Routes**.

   - From the _Project_ drop-down list, select `app-monitoring`. 

   - Click on the route URL (listed under the _Location_ column).

   - Click on `Log in with OpenShift`. Click on `Allow selected permissions`.

   - In Grafana, from the left-panel, hover over the dashboard icon and click on `Manage`.

   - You should see `Liberty-Metrics-Dashboard` on the list. Click on it.

   - Explore the dashboards. The first 2 are for Customer Order Services application. The rest are for Liberty.

   - Click on `Customer Order Services - Shopping Cart`. By default, it'll show the data for the last 15 minutes. Adjust the time-range from the top-right as necessary. 

   - You should see the frequency of requests, number of requests, pod information, min/max request times.

   - Scroll-down to expand the `CPU` section. You'll see information about process CPU time, CPU system load for pods.

   - Scroll-down to expand the `Servlets` section. You'll see request count and response times for application servlet as well as health and metrics endpoints.

   - Explore the other sections.

     ![requesting server dump](extras/images/monitoring-dashboard.gif)


## Day-2 Operations (Hands-on)

You may need to gather server traces and/or dumps for analyzing some problems. Open Liberty Operator makes it easy to gather these on a server running inside a container.

A storage must be configured so the generated artifacts can persist, even after the Pod is deleted. This storage can be shared by all instances of the Open Liberty applications. RedHat OpenShift on IBM Cloud utilizes the storage capabilities provided by IBM Cloud. Let's create a request for storage.

### Request storage (Hands-on)

1. In OpenShift console, from the left-panel, select **Storage** > **Persistent Volume Claims**.

1. From the _Project_ drop-down list, select `apps`. 

1. Click on `Create Persistent Volume Claim` button.

1. Ensure that `Storage Class` is `managed-nfs`. If not, make the selection from the list.

1. Enter `liberty` for `Persistent Volume Claim Name` field.

1. Request 1 GiB by entering `1` in the text box for `Size`.

1. Click on `Create`.

1. Created Persistent Volume Claim will be displayed. The `Status` field would display `Pending`. Wait for it to change to `Bound`. It may take 1-2 minutes.

1. Once bound, you should see the volume displayed under `Persistent Volume` field.

### Enable serviceability (Hands-on)

Enable serviceability option for the Customer Order Services application. In productions systems, it's recommended that you do this step with the initial deployment of the application - not when you encounter an issue and need to gather server traces or dumps. OpenShift cannot attach volumes to running Pods so it'll have to create a new Pod, attach the volume and then take down the old Pod. If the problem is intermittent or hard to reproduce, you may not be able to reproduce it on the new instance of server running in the new Pod. The volume can be shared by all Liberty applications that are in the same namespace and the volumes wouldn't be used unless you perform day-2 operation on a particular application - so that should make it easy to enable serviceability with initial deployment.

1. Specify the name of the storage request (Persistent Volume Claim) you made earlier to `spec.serviceability.volumeClaimName` parameter provided by `OpenLibertyApplication` custom resource. Open Liberty Operator will attach the volume bound to the claim to each instance of the server. In your terminal, run the following command:

    ```
    oc patch olapp cos -n apps --patch '{"spec":{"serviceability":{"volumeClaimName":"liberty"}}}' --type=merge
    ```

    Above command patches the definition of `olapp` (shortname for `OpenLibertyApplication`) instance `cos` in namespace `apps` (indicated by `-n` option). The `--patch` option specifies the content to patch with. In this case, we set the value of `spec.serviceability.volumeClaimName` field to `liberty`, which is the name of the Persistent Volume Claim you created earlier. The `--type=merge` option specifies to merge the previous content with newly specified field and its value.

1. Run the following command to get the status of `cos` application, to verify that the changes were reconciled and there is no error:

    ```
    oc get olapp cos -n apps -o wide
    ```
    The value under `RECONCILED` column should be _True_. 
    
    _Note:_ If it's _False_ then an error occurred. The `REASON` and `MESSAGE` columns will display the cause of the failure. A common mistake is creating the Persistent Volume Claim in another namespace. Ensure that it is created in the `apps` namespace.


1. In OpenShift console, from the left-panel, click on **Workloads** > **Pods**. Wait until there is only 1 pod on the list and its _Readiness_ column changed to _Ready_.

1. Pod's name is needed for requesting server dump and trace in the next sections. Click on the pod and copy the value under `Name` field.

    ![requesting server dump](extras/images/pod-name.png)

### Request server dump (Hands-on)

You can request a snapshot of the server status including different types of server dumps, from an instance of Open Liberty server running inside a Pod, using Open Liberty Operator and `OpenLibertyDump` custom resource (CR). 

The following steps to request a server dump are illustrated in the screen recording below:

1. From the left-panel, click on **Operators** > **Installed Operators**.

1. From the `Open Liberty Operator` row, click on `Open Liberty Dump` (displayed under `Provided APIs` column).

1. Click on `Create OpenLibertyDump` button. 

1. Replace `Specify_Pod_Name_Here` with the pod name you copied earlier.

1. The `include` field specifies the type of server dumps to request. Heap and thread dumps are specified by default. Let's use the default values.

1. Click on `Create`.

1. Click on `example-dump` from the list.

1. Scroll-down to the `Conditions` section and you should see `Started` status with `True` value. Wait for the operator to complete the dump operation. You should see status `Completed` with `True` value.

    ![requesting server dump](extras/images/day2-dump-operation.gif)

### Request server traces (Hands-on)

You can also request server traces, from an instance of Open Liberty server running inside a Pod, using `OpenLibertyTrace` custom resource (CR).

The following steps to request a server trace are illustrated in the screen recording below:

1. From the left-panel, click on **Operators** > **Installed Operators**.

1. From the `Open Liberty Operator` row, click on `Open Liberty Trace`.

1. Click on `Create OpenLibertyTrace` button.

1. Replace `Specify_Pod_Name_Here` with the pod name you copied earlier.

1. The `traceSpecification` field specifies the trace string to be used to selectively enable trace on Liberty server. Let's use the default value. 

1. Click on `Create`.

1. Click on `example-trace` from the list.

1. Scroll-down to the `Conditions` section and you should see `Enabled` status with `True` value. 
    - _Note:_ Once the trace has started, it can be stopped by setting the `disable` parameter to true. Deleting the CR will also stop the tracing. Changing the `podName` will first stop the tracing on the old Pod before enabling traces on the new Pod. Maximum trace file size (in MB) and the maximum number of files before rolling over can be specified using `maxFileSize` and `maxFiles` parameters.

    ![requesting server trace](extras/images/day2-trace-operation.gif)

### Accessing the generated files (Hands-on)

The generated trace and dump files should now be in the persistent volume. You used storage from IBM Cloud and we have to go through a number of steps using a different tool to access those files. Since the volume is attached to the Pod, we can instead use Pod's terminal to easily verify that trace and dump files are present.

The following steps to access the files are illustrated in the screen recording below:

1. Remote shell to your pod via one of two ways:
  - From your terminal:
    ```
    oc rsh <pod-name>
    ```
  - From console: click on **Workloads** > **Pods**. Click on the pod and then click on `Terminal` tab. 

1. Enter `ls -R serviceability/apps` to list the files. The shared volume is mounted at `serviceability` folder. The sub-folder `apps` is the namespace of the Pod. You should see a zip file for dumps and trace log files. These are produced by the day-2 operations you performed.

    ![day-2 files](extras/images/day2-files.gif)


## Summary

Congratulations! You've completed **Application Management** lab! 


