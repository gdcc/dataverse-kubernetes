--------------------
Cloud Provider Hints
--------------------

If you want to add some notes about a cloud provider you know, please create
a pull request. Feel free to include files in the ``examples`` directory.

Microsoft Azure
---------------

You might need to patch your ``PersistentVolumeClaim``\ s according to the
`Azure AKS storage docs <https://docs.microsoft.com/en-US/azure/aks/azure-disks-dynamic-pv#built-in-storage-classes>`_.
This depends on your requirements and should be tested. An example is given below.

.. code-block:: yaml
  :caption: patch-azure-pvc.yaml

  ---
  kind: PersistentVolumeClaim
  apiVersion: v1
  metadata:
    name: XXX
  spec:
    storageClassName: managed-premium

Remember that for ``ReadWriteMany`` volumes you have to use a different type of
them, documented as `Azure Files <https://docs.microsoft.com/en-US/azure/aks/azure-files-dynamic-pv>`_.
