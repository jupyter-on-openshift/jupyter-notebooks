Jupyter Notebooks for OpenShift
===============================

This repository contains software to make it easier to use Jupyter Notebooks on OpenShift.

This includes input source code for creating a minimal Jupyter notebook image using the Source-to-Image (S2I) build process. The image can be built in OpenShift, separately using the ``s2i`` tool, or using a ``docker build``.

The minimal Jupyter notebook image can be deployed to create an empty Jupyter notebook workspace in OpenShift that you can work with. The same image, can also be used as an S2I builder to create customised Jupyter notebook images with additional Python packages installed, or notebook files preloaded.

Use a stable version of this repository
---------------------------------------

When using this repository, unless you are participating in the development and testing of the images produced from this repository, always use a tagged version. Do not use master or development branches as your builds or deployments could break across versions.

You should therefore always use any files for creating images or templates from the required tagged version. These will reference the appropriate version. If you have created your own resource definitions to build from the repository, ensure that the ``ref`` field of the Git settings for the build refers to the desired version.

Why not use Jupyter Project images?
-----------------------------------

The Jupyter Project provides a number of images for notebooks on Docker Hub. These are:

* base-notebook
* r-notebook
* minimal-notebook
* scipy-notebook
* tensorflow-notebook
* datascience-notebook
* pyspark-notebook
* all-spark-notebook

The GitHub repository used to create these is:

* https://github.com/jupyter/docker-stacks

There are two problems with using these images with OpenShift.

The first is that the images will not run out of the box on an OpenShift installation. This is because they have not been designed properly to work with an assigned user ID without additional configuration. One can use them, but you need to edit the deployment so that the container is run with an extra supplemental group with ``gid`` of ``100``.

The second problem is the size of these images. The ``base-notebook`` image is close to 3GB in size. This means they cannot be used on OpenShift environments, such as OpenShift Online, which cap image/container filesystem size at 3GB. The minimal notebook image created from this repository in contrast is about 1GB in size. Part of the issue with the size of the Jupyter Project images appears to be due to the use of an ``ubuntu`` base image and Anaconda Python distribution.

For most use cases, the variants of the above images for just Python, which are provided here will work as substitutes. The images here also have the added benefit of being able to be used as Source-to-Image (S2I) builders so you can easily incorporate notebook files and required packages into a derived new image.

Importing the Minimal Notebook
------------------------------

A pre-built version of the minimal notebook which is based on CentOS, can be found at on quay.io at:

* https://quay.io/organization/jupyteronopenshift

The name of the latest build version of this image is:

* quay.io/jupyteronopenshift/s2i-minimal-notebook-py36:latest

Although this image could be imported into an OpenShift cluster using ``oc import-image``, it is recommended instead that you load it using the supplied image stream definition, using:

```
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/image-streams/s2i-minimal-notebook.json
```

This is preferred, as it will create an image stream with tag corresponding to the Python version being used, with the underlying image reference referring to a specific version of the image on quay.io, rather than the latest build. This ensures that the version of the image doesn't change to a newer version of the image which you haven't tested.

Once the image stream definition is loaded, the project it is loaded into should have the tagged image:

* s2i-minimal-notebook:3.6

Building the Minimal Notebook
-----------------------------

Instead of using the pre-built version of the minimal notebook, you can build the minimal notebook from source code. You may want to do this where you need it to use a RHEL base image included with your OpenShift cluster, instead of CentOS. Do be aware though that certain third party system packages may not be available for RHEL if you need to extend the image. One known example of this is image/video processing libraries, which although they may be able to be added to a CentOS base image, do not work with RHEL.

In order to build the minimal notebook image from source code in your OpenShift cluster use the command:

```
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/build-configs/s2i-minimal-notebook.json
```

This will create a build configuration in your OpenShift project to build the minimal notebook image using the Python 3.6 S2I builder included with your OpenShift cluster. You can watch the progress of the build by running:

```
oc logs --follow bc/s2i-minimal-notebook-py36
```

A tagged image ``s2i-minimal-notebook:3.6`` should be created in your project. Since it uses the same image name as when loading the image using the image stream, referencing the image on quay.io, only do one or the other. Don't try to both load the image stream, and build the minimal notebook from source code.

Deploying the Minimal Notebook
------------------------------

To deploy the minimal notebook image run the following commands:

```
oc new-app s2i-minimal-notebook:3.6 --name minimal-notebook \
    --env JUPYTER_NOTEBOOK_PASSWORD=mypassword
```

The ``JUPYTER_NOTEBOOK_PASSWORD`` environment variable will allow you to access the notebook instance with a known password.

Deployment should be quick if you build the minimal notebook from source code. If you used the image stream, the first deployment may be slow as the image will need to be pulled down from quay.io. You can monitor progress of the deployment if necessary by running:

```
oc rollout status dc/minimal-notebook
```

Because the notebook instance is not exposed to the public network by default, you will need to expose it. To do this, and ensure that access is over a secure connection run:

```
oc create route edge minimal-notebook --service minimal-notebook \
    --insecure-policy Redirect
```

To see the hostname which is assigned to the notebook instance, run:

```
oc get route/minimal-notebook
```

Access the hostname shown using your browser and enter the password you used above.

To delete the notebook instance when done, run:

```
oc delete all --selector app=minimal-notebook
```

Creating Custom Notebook Images
-------------------------------

To create custom notebooks images, you can use the ``s2i-minimal-notebook:3.6`` image as an S2I builder. This repository contains two examples for extending the minimal notebook. These can be found in:

* [scipy-notebook](./scipy-notebook)
* [tensorflow-notebook](./tensorflow-notebook)

These are intended to mimic the images of the same name available from the Jupyter project.

In the directories you will find a ``requirements.txt`` file listing the additional Python packages that need to be installed from PyPi. You will also find a ``.s2i/bin/assemble`` script which will be triggered by the S2I build process, and which installs further packages and extensions.

To use the S2I build process to create a custom image, you can then run the command:

```
oc new-build --name custom-notebook \
  --image-stream s2i-minimal-notebook:3.6 \
  --code https://github.com/jupyter-on-openshift/jupyter-notebooks \
  --context-dir scipy-notebook
```

If any build of a custom image fails because the default memory limit on builds in your OpenShift cluster is too small, you can increase the limit by running:

```
oc patch bc/custom-notebook \
  --patch '{"spec":{"resources":{"limits":{"memory":"1Gi"}}}}'
```

and start a new build by running:

```
oc start-build bc/custom-notebook
```

If using the custom notebook image with JupyterHub running in OpenShift, you may also need to set the image lookup policy on the image stream created.

```
oc set image-lookup is/custom-notebook
```

This is necessary so that the image stream reference in the pod definition created by JupyterHub will be able to resolve the name to that of the image stream.

For the ``scipy-notebook`` and ``tensorflow-notebook`` examples provided, if you wish to use the images, instead of running the above commands, after you have loaded the image stream for, or built the minimal notebook image, you can instead run the commands:

```
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/build-configs/s2i-scipy-notebook.json
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/build-configs/s2i-tensorflow-notebook.json
```

When creating a custom notebook image, the directory in the Git repository the S2I build is run against can contain a ``requirements.txt`` file listing the Python package to be installed in the custom notebook image. Any other files in the directory will also be copied into the image. When the notebook instance is started from the image, those files will then be present in your workspace.

As an additional example, if you want to create a custom notebook image which includes the notebooks from Jake Vanderplas' book found at:

* https://github.com/jakevdp/PythonDataScienceHandbook

run:

```
oc new-build --name jakevdp-notebook \
  --image-stream s2i-minimal-notebook:3.6 \
  --code https://github.com/jakevdp/PythonDataScienceHandbook
```

Enabling JupyterLab Interface
-----------------------------

By default the minimal notebook when deployed will start up with the classic Jupyter notebook web interface. If you prefer to use the newer JupyterLab web interface, it can be enabled by setting the ``JUPYTER_NOTEBOOK_INTERFACE`` environment variable to ``lab``. This can be set on the deployment configuration using:

```
oc set env dc/minimal-notebook JUPYTER_NOTEBOOK_INTERFACE=lab
```

This indicates a preference only for what web interface is used. If you wish for a custom notebook to always be deployed using the JupyterLab interface regardless of what is expressed as a preference, you can use an environment variable set on the image. This is done by setting the ``JUPYTER_ENABLE_LAB=true`` environment variable on the build configuration using:

```
oc set env bc/custom-notebook JUPYTER_ENABLE_LAB=true
```

Set this to ``false`` if you want to force the use of the classic web interface instead.

You can also set the ``JUPYTER_ENABLE_LAB`` environment variable as part of the source code repository used as input to the S2I build for the custom notebook, by adding an ``.s2i/environment`` file, containing:

```
JUPYTER_ENABLE_LAB=true
```

Using OpenShift Templates
-------------------------

To make it easier to build and deploy Jupyter Notebooks, a number of templates are provided.

The templates are:

* ``notebook-deployer`` - Template for deploying a Jupyter Notebook image.
* ``notebook-builder`` - Template for building a custom Jupyter Notebook image using Source-to-Image (S2I) against a hosted Git repository. Python packages listed in the ``requirements.txt`` file of the Git repository will be installed and any files, including notebook images, will be copied into the image. The image can then be deployed using ``notebook-deployer``.
* ``notebook-quickstart`` Template for building and deploying a custom Jupyter Notebook image. This effectively combines ``notebook-builder`` and ``notebook-deployer``.
* ``notebook-workspace`` - Template for deploying a Jupyter Notebook image which also attaches a persistent volume, and copies any installed Python packages and notebooks into the persistent volume. Any work done on the notebooks or to install additional Python packages will survive a restart of the Jupyter Notebook environment. A webdav interface is also enabled to allow remote mounting of the persistent volume.

To load the templates run:

```
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/templates/notebook-deployer.json
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/templates/notebook-builder.json
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/templates/notebook-quickstart.json
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/templates/notebook-workspace.json
```

The templates can be used from the command line or from the web console.
