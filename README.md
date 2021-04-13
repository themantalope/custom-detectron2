# custom-detectron2

[Detectron2](https://github.com/facebookresearch/detectron2) is the object detection open source project based on the pytorch made in the Facebook AI Research (FAIR). With modular design, Detectron2 is more flexible, extensible than the existing Detectron. Detectron2 provides models of object detection such as panoptic segmentation, DensePose, Cascade RCNN, and more based on a variety of backbones.

Use these dockerfiles to create images and containers that:
1) utilize your custom detectron2 models
2) run predictions over http(s), with the container running a small flask app to get data into/out of the model

The inference using server is done in the following steps:
1. User publishes an image file
2. server returns a inferred image or json which is information of detected objects.

Note that the server is implemented in flask

You can see the demo server from below site

# How to deploy

this server is dockerized, so it can be built and run using docker commands.

## Docker build

```
docker build -t <your-tag> -f Dockerfile-cpu . --build-arg config_yaml_fil=<detectron2 cfg path> --build-arg model_pth_file=<detectron2 pth path>
```
or
```
docker build -t detectron2 -f Dockerfile-gpu . --build-arg config_yaml_fil=<detectron2 cfg path> --build-arg model_pth_file=<detectron2 pth path>
```

## create a container
```
docker create --name=<container name> <your image>
```

## Run Docker

```
docker run -p 80:80 -it <your container name>
```

Now the server is available at http://localhost.



# References
1. [facebookresearch/detectron2](https://github.com/facebookresearch/detectron2)
2. derivative of the [ainized-detectron2](https://github.com/gkswjdzz/ainized-detectron2) repo
