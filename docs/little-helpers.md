## Little Helpers
### Inplace Re-Index Job
Sometimes when you upgrade to a new Dataverse version, the Solr configuration
has been changed by upstream. In these cases, release notes will advise you to
[do an "inplace reindex"](http://guides.dataverse.org/en/latest/admin/solr-search-index.html#reindex-in-place).

For your convienience, a batch job has been added containing actions mentioned
in the docs for you. Simply deploy it during off-hours (or fork and create a CronJob):
```
kubectl create -f k8s/dataverse/jobs/inplace-reindex.yaml
```

### Metadata Housekeeping
See [Metadata docs](metadata.md).

### Catching emails from Dataverse easily
While doing a showcase, developing or other purposes, it comes in handy
to see what emails are sent by Dataverse.
Instead of relying on an external service as Mailinator, Mailtrap.io or similar,
just use [MailCatcher](https://mailcatcher.me/) as a small extra deployment:

```bash
kubectl create -f k8s/utils/mailcatcher.yaml
minikube service mailcatcher
```
(The last will open the web UI in your default browser.)

The SMTP server can be used via `postfix:25`, which is also the default config
for Dataverse when you "just use" the deployments found in `k8s/`. (It will
*"Just Work (TM)"*).

**Please note** that all sent mails will be **deleted** when you restart or
delete the deployment/pod/container.
