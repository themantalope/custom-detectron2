FROM nvidia/cuda:10.1-cudnn7-devel
CMD ["bash"]

ARG cfg_yaml_file
ARG model_pth_file

RUN apt-get update
RUN mkdir /workspace
RUN mkdir /workspace/uploads 
WORKDIR /workspace

ENV CFG_FILE=/workspace/$cfg_yaml_file
ENV MODEL_FILE=/workspace/$model_pth_file

COPY $cfg_yaml_file $CFG_FILE
COPY $model_pth_file $MODEL_FILE

RUN apt-get update && apt-get install -y python3-dev git wget
RUN rm -rf /var/lib/apt/lists/*

RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py
RUN rm get-pip.py

COPY requirements.txt .
RUN pip install numpy
RUN pip install tensorboard cython
RUN pip install torch==1.5+cu101 torchvision==0.6+cu101 -f https://download.pytorch.org/whl/torch_stable.html
RUN pip install 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'
RUN pip install -r requirements.txt

RUN git clone -b v0.1.3 https://github.com/facebookresearch/detectron2 detectron2_repo
ENV FORCE_CUDA="1"
ENV TORCH_CUDA_ARCH_LIST="Kepler;Kepler+Tesla;Maxwell;Maxwell+Tegra;Pascal;Volta;Turing"
RUN pip install -e detectron2_repo

RUN  pip install -e detectron2_repo/projects/TensorMask

RUN apt-get install wget
#denspose model
# RUN wget https://dl.fbaipublicfiles.com/densepose/densepose_rcnn_R_50_FPN_s1x/143908701/model_final_dd99d2.pkl -O /workspace/detectron2_repo/densepose_rcnn_R_50_FPN_s1x.pkl
# RUN wget http://images.cocodataset.org/val2017/000000439715.jpg -O /workspace/uploads/input.jpg
RUN apt-get update
RUN apt-get install -y libsm6 libxext6 libxrender-dev
RUN apt-get install -y libgtk2.0-dev

RUN pip install requests

COPY apply_net.py .
COPY apply_net-gpu.py .
COPY demo.py .
COPY demo-gpu.py .
COPY predictor.py .

RUN mv /workspace/demo-gpu.py /workspace/detectron2_repo/demo.py
RUN mv /workspace/apply_net-gpu.py /workspace/detectron2_repo/apply_net.py
RUN mv /workspace/predictor.py /workspace/detectron2_repo/predictor.py
RUN mv /workspace/demo.py /workspace/detectron2_repo/demo-cpu.py

RUN mv /workspace/detectron2_repo/projects/DensePose/densepose/ /workspace/detectron2_repo/densepose    
RUN cp -rl /workspace/detectron2_repo/projects/DensePose/configs/ /workspace/detectron2_repo/

RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
RUN python --version

# model download and test
# RUN python /workspace/detectron2_repo/demo-cpu.py \
#     --input /workspace/uploads/input.jpg \
#     --output /workspace/uploads/output_test1.jpg \
#     --config-file /workspace/detectron2_repo/configs/quick_schedules/panoptic_fpn_R_50_inference_acc_test.yaml
# RUN python /workspace/detectron2_repo/demo-cpu.py \
#     --input /workspace/uploads/input.jpg \
#     --output /workspace/uploads/output_test2.jpg \
#     --config-file /workspace/detectron2_repo/configs/quick_schedules/mask_rcnn_R_50_FPN_inference_acc_test.yaml
# RUN python /workspace/detectron2_repo/demo-cpu.py \
#     --input /workspace/uploads/input.jpg \
#     --output /workspace/uploads/output_test3.jpg \
#     --config-file /workspace/detectron2_repo/configs/quick_schedules/keypoint_rcnn_R_50_FPN_inference_acc_test.yaml

COPY server-gpu.py ./detectron2_repo
EXPOSE 80
ENTRYPOINT python ./detectron2_repo/server-gpu.py

LABEL AINIZE_MEMORY_REQUIREMENT=10Gi
