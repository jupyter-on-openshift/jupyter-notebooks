Jupyter Notebooks for OpenShift
===============================

This repository contains software to make it easier to use Jupyter Notebooks on OpenShift.

This includes input source code for creating a minimal Jupyter notebook image using the Source-to-Image (S2I) build process. The image can be built in OpenShift, or separately using the ``s2i`` tool.

The minimal Jupyter notebook image can be deployed to create an empty Jupyter notebook workspace in OpenShift that you can work with. The same image, can also be used as a S2I builder to create customised Jupyter notebook images with additional Python packages installed, or notebook files preloaded.

Building the Minimal Notebook
-----------------------------

To build the minimal Jupyter notebook run the command:

```
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/images.json
```

This will create a build configuration in your OpenShift project to build the minimal Jupyter notebook image using the Python 3.5 S2I builder. You can watch the progress of the build by running:

```
oc logs --follow bc/minimal-notebook
```

A tagged image ``minimal-notebook:3.5`` should be created in your project.

Once the build is complete, further builds will run to create ``scipy-notebook:3.5`` and ``tensorflow-notebook:3.5``. These are custom notebook images which include additional Python packages. The set of packages installed with these mirrors the images of the same name provided by the Jupyter project team.

Deploying the Minimal Notebook
------------------------------

To deploy the minimal Jupyter notebook image run the following commands:

```
oc new-app minimal-notebook:3.5 --name my-notebook \
    --env JUPYTER_NOTEBOOK_PASSWORD=mypassword
```

The ``JUPYTER_NOTEBOOK_PASSWORD`` environment variable will allow you to access the notebook instance with a known password.

Deployment should be quick, but you can monitor progress if necessary by running:

```
oc rollout status dc/my-notebook
```

Because the notebook instance is not exposed to the public network by default, you will need to expose it. To do this, and ensure that access is over a secure connection run:

```
oc create route edge my-notebook --service my-notebook \
    --insecure-policy Redirect
```

To see the hostname which is assigned to the notebook instance, run:

```
oc get route/my-notebook
```

Access the hostname shown using your browser and enter the password you used above.

To delete the notebook instance when done, run:

```
oc delete all --selector app=my-notebook
```

Creating Custom Notebook Images
-------------------------------

To create custom notebooks images, you can use the ``minimal-notebook:3.5`` image as a S2I builder.

To replicate what loading the ``images.json`` file did in creating builds for ``scipy-notebook``, you could have instead run:

```
oc new-build --name my-scipy-notebook \
  --image-stream minimal-notebook:3.5 \
  --code https://github.com/jupyter-on-openshift/jupyter-notebooks \
  --context-dir scipy-notebook
```

If any build of a custom image fails because the default memory limit on builds in your OpenShift cluster is too small, increase the limit by running:

```
oc patch bc/my-scipy-notebook \
  --patch '{"spec":{"resources":{"limits":{"memory":"1Gi"}}}}'
```

and start a new build by running:

```
oc start-build bc/my-scipy-notebook
```

If using the custom notebook image with JupyterHub running in OpenShift, you also need to set the image lookup policy on the image stream created.

```
oc set image-lookup is/my-scipy-notebook
```

This is necessary so that the image stream reference in the pod definition created by JupyterHub will be able to resolve the name to that of the image stream.

When creating a custom notebook image, the directory in the Git repository the S2I build is run against can contain a ``requirements.txt`` file listing the Python package to be installed in the custom notebook image. Any other files in the directory will also be copied into the image. When the notebook instance is started from the image, those files will then be present in your workspace.

As an additional example, if you want to create a custom notebook image which includes the notebooks from Jake Vanderplas' book found at:

* https://github.com/jakevdp/PythonDataScienceHandbook

run:

```
oc new-build --name jakevdp-notebook \
  --image-stream minimal-notebook:3.5 \
  --code https://github.com/jakevdp/PythonDataScienceHandbook
```

Using the OpenShift Web Console
-------------------------------

To make it easier to build and deploy notebooks images from the web console, templates are provided. To load the templates run:

```
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/templates.json
```

From the _Service Catalog_ filter on _jupyter_.
