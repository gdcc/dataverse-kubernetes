==============
Object Storage
==============

Dataverse offers storing data on object storage like AWS S3 or OpenStack Swift.
You should read upstream docs on this:

- :guide_dv:`Configure Storage Locations <installation/config.html#file-storage-using-a-local-filesystem-and-or-swift-and-or-s3-object-stores>`
- :guide_dv:`Direct Access for Big Data <developers/big-data-support.html#s3-direct-upload-and-download>`

Since Dataverse v4.20, multiple storage locations are supported for both local
or remote storage or mixed (see also :doc:`/day1/storage`).

To enable object storage locations, you need to follow three steps:

1. Create your ``Secrets``. If you deploy both your storage solution and
   Dataverse to the same cluster / location, you should share them somehow.
   Docs on how to create secrets for Dataverse and apply them to the pod
   can be found in :doc:`/day1/secrets`.
2. Prepare and/or deploy your object storage solution
3. Configure Dataverse to make use of it. See :doc:`/day1/config` for details
   on how to create a configuration.

.. todo:: Describe ``personas/demo-integrate-minio`` example here.
