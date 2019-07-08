# Configuration of Dataverse
Configuring dataverse is done in different places. Some things for more "basic"
system configuration is done in Java system properties, residing in the Glassfish
domain configuration. More advanced and flexible options are stored in the
database and configured via API and/or UI.

* See [JVM Options](http://guides.dataverse.org/en/latest/installation/config.html#jvm-options)
  for system properties.
* See [Database Settings](http://guides.dataverse.org/en/latest/installation/config.html#database-settings)
  for all other settings.

Things like file storage, networking, DOI, etc are all *basic system settings*
and can be set via system properties. For your convienience, these can be
stored in a `ConfigMap`.

Some things need sane defaults, which can be found in [default.config](https://github.com/IQSS/dataverse-kubernetes/blob/master/docker/dataverse-k8s/bin/default.config).
You might find those usefull as an example for your personally tuned `ConfigMap`.

## JVM options: mapping from environment variables
The basic idea is to map environment variables to Java system properties each
time a Dataverse container starts with the default entrypoint (being the application
server).

1. Simply pick a [JVM Option](http://guides.dataverse.org/en/latest/installation/config.html#jvm-options)
   from the list and replace "." with "_" ("-" is not allowed in env var names!).
2. Put the transformed name as a key into the `ConfigMap` `.data`.
3. Add your value. Be sure to use simple strings only - no numbers, no complex types.

Example:
```yaml
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: dataverse
  labels:
    app.kubernetes.io/name: configmap
    app.kubernetes.io/version: "1.0"
    app.kubernetes.io/component: configmap
    app.kubernetes.io/part-of: dataverse
    app.kubernetes.io/managed-by: kubectl
data:
  dataverse_fqdn: data.example.org
  dataverse_siteUrl: https://\${dataverse.fqdn}
  doi_username: test.account
  dataverse_auth_password__reset__timeout__in__minutes: 30
```
**DO NOT USE THIS FOR PASSWORDS!** Those are done via k8s secrets, see below.

Currently some JVM options have dashes in them, which is no allowed character for
an environment variable. As a workaround, replace any dash with `__`. It will
be transformed back into `-` internally when the container starts. See example above.

## Database settings: mapping from environment variables, too
As database settings are persistent in, well, the database, they don't need
to get set everytime the container starts. To be consistent and easy to use,
the same `ConfigMap` used for JVM options can be used for these settings,
but you need to create a `Job` or even a `CronJob` to apply them.

*Note:* Of course you can choose to use your own tools and scripts for this.
Basically its just `curl` calls to the Admin API.

#### Provide a setting

1. Pick a [Database setting](http://guides.dataverse.org/en/latest/installation/config.html#database-settings)
2. Remove the `:` and replace it with `db_`. Keep the Pascal case!
3. Put the transformed value into the `ConfigMap` `.data`.
4. Add your value, which can be any value you see in the docs. Keep in mind:
   when you need to use JSON, format it as a string!

Example:
```yaml
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: dataverse
  labels:
    app: dataverse
data:
  # Skipping JVM options here. See above.
  db_SystemEmail: "Ghostbusters <slimer@buh.net>"
  db_Languages: '[{ "locale":"en", "title":"English" }, { "locale":"fr", "title":"Français" }]'
```
**DO NOT USE THIS FOR PASSWORDS OR KEYS!** Those are done via k8s secrets, see below.

#### Delete a setting
When you need to **delete** a setting, just provide an *empty* value.

#### Apply settings
Remember: you will need to update the `ConfigMap` when you want to apply changes.
You need to think about in which file you keep the map - having it in two locations
is a bad idea. It's always a good idea to put it in revision control.

```
# Update ConfigMap:
kubectl apply -f k8s/dataverse/configmap.yaml
# Deploy a new config job:
kubectl create -f k8s/utils/configure-job.yaml
```

You might consider providing a `CronJob` for scheduled, regular updates.
