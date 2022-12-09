%% ResNet 18 불러오기
net = resnet18;
model_name = 'ResNet18';
lgraph = layerGraph(net);

%% Feature Extraction Layer 설정하고, 그 이후로 모두 지우기
featureExtractionLayer = "res5b";
temp = cell(1,71-67);
for i = 67:71
   temp{i-66} = lgraph.Layers(i).Name; 
end
for i = 67:71
    lgraph = removeLayers(lgraph,temp{i-66});
end

%% YOLO v2 Detection Sub-Network를 만들기
% (1) Conv + ReLU + Batch Normalization 부분
filterSize = [3 3];
numFilters = 96;

detectionLayers = [
    convolution2dLayer(filterSize,numFilters,"Name","yolov2Conv1","Padding", "same",...
                        "WeightsInitializer",@(sz)randn(sz)*0.01)
    batchNormalizationLayer("Name","yolov2Batch1")
    reluLayer("Name","yolov2Relu1")
    convolution2dLayer(filterSize,numFilters,"Name","yolov2Conv2","Padding", "same",...
                        "WeightsInitializer",@(sz)randn(sz)*0.01)
    batchNormalizationLayer("Name","yolov2Batch2")
    reluLayer("Name","yolov2Relu2")
    ];

% (2) Conv + Transform + Output Layer 부분
numClasses = width(imageLabel);
numAnchors = 4;
[anchorBoxes, meanIoU] = estimateAnchorBoxes(blds, numAnchors)
numPredictionsPerAnchor = 5;
numFiltersInLastConvLayer = numAnchors * (numClasses + numPredictionsPerAnchor);

detectionLayers = [
    detectionLayers
    convolution2dLayer(1,numFiltersInLastConvLayer,"Name","yolov2ClassConv",...
    "WeightsInitializer", @(sz)randn(sz)*0.01)
    yolov2TransformLayer(numAnchors,"Name","yolov2Transform")
    yolov2OutputLayer(anchorBoxes,"Name","yolov2OutputLayer")
    ];

%% 기존 ResNet에 YOLO v2 Sub-Network 이어 붙이기
lgraph = addLayers(lgraph,detectionLayers);
lgraph = connectLayers(lgraph,featureExtractionLayer,"yolov2Conv1");