# Storage for data persistance
This project aims to make things as much stateless as possible. Obviously,
somewhere databases, search indices, research data, etc etc have to reside.

The following sections describe usefull mount locations for Dataverse services.

## Application server (dataverse-k8s)

##### `/data` - research data area
This is the place for any data flying in. Be it during upload as a temporary storage
or for real persistance: it's a good idea to have a volume for this.

Hints and thoughts:
* Use a `ReadWriteMany` volume when using a multi-instance deployment
* When using object storage like S3 or Swift, you might try to make it a `emptyDir`
  volume for temporary upload only.

##### `/docroot` - web application area
In this folder reside things like logos for Dataverse navigation bar or dataverses themes.
You can also place your custom theme, stylesheet, etc here.

As with metadata (see below), you might consider using sidecars to pre-populate
this area with your files.

##### `/metadata` - custom metadata schema area
Please take a look at [metadata documentation](metadata.md) for details.

## Index server (solr-k8s)

##### `/opt/solr/server/solr/collection1/data` - index area
The Solr index data lives here.
