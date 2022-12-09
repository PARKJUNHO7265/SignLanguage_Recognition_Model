% 필요할 때 저장된 모델 불러오기

clc, clear, close all

% model_name = 'Model_201206without_IJMNSTZResNet18_numEpoch_10_InitLR_0.01.mat';
% model_name = 'Model_20201204-1439_datastoreName_without_IJMNSTZ_netName_ResNet18.mat';
% model_name = 'Model_20201203-1131_datastoreName_without_IJMNSTZ_netName_ResNet18.mat';
model_name = 'Model_201208without_IJMNSTZResNet18_numEpoch_4_InitLR_0.01.mat';
tempo = load(fullfile(pwd, 'trained_model', model_name));

detector = tempo.detector;

% Test set
if ~exist(fullfile(pwd,'data_test_1'), 'dir')
    mkdir(fullfile('data_test_1'));
end
% data_test
% data_test_1
% data_test_2
% data_test_3

test_Imds = imageDatastore(fullfile(pwd,'data_test_3'), 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

%% 4장 random으로 골라서 Prediction 보여주기

idx = randperm(height(test_Imds.Files), 4);
for i = 1:4
    subplot(2,2,i)
    I = readimage(test_Imds, idx(i));
    I = I + 20;
    
    %IMAGE SEGMENTATION
    img=rgb2ycbcr(I);

    for j=1:size(img,1)
        for k= 1:size(img,2)
            cb = img(j,k,2);
            cr = img(j,k,3);
            if(~(cr > 132 && cr < 173 && cb > 76 && cb < 126))
                img(j,k,1)=235;
                img(j,k,2)=128;
                img(j,k,3)=128;
            end
        end
    end
    img=ycbcr2rgb(img);
    grayImage=rgb2gray(img);

    %GRAY TO BINARY IMAGE
    binaryImage = grayImage < 245;

    % Label the image 
    % label the connected components in an image and assigning each one a unique label
    labeledImage = bwlabel(binaryImage);
    measurements = regionprops(labeledImage, 'BoundingBox', 'Area');
    for j = 1 : length(measurements)
      thisBB = measurements(j).BoundingBox;
    end

    % Let's extract the second biggest blob - that will be the hand.
    allAreas = [measurements.Area];
    if ~isempty(allAreas)
        [sortedAreas, sortingIndexes] = sort(allAreas, 'descend');
        handIndex = sortingIndexes(1);
        % The hand is the second biggest, face is biggest.

        % Use ismember() to extact the hand from the labeled image.
        handImage = ismember(labeledImage, handIndex);

        % Now binarize
        handImage = handImage > 0;
        rect = measurements(handIndex).BoundingBox;
        img = imcrop(img,rect);
    end

    [boxes,scores,labels] = detect(detector, img);
    if(~isempty(rect))
        I = insertObjectAnnotation(I,'rectangle',rect,[char(labels(1)), ' : ', num2str(scores(1))], 'FontSize', 40);
    end
    imshow(I)
end

%% Confusion Matrix

% model_name = 'Model_201206without_IJMNSTZResNet18_numEpoch_10_InitLR_0.01.mat';
% model_name = 'Model_20201204-1439_datastoreName_without_IJMNSTZ_netName_ResNet18.mat';
% model_name = 'Model_20201203-1131_datastoreName_without_IJMNSTZ_netName_ResNet18.mat';
% tempo = load(fullfile(pwd, 'trained_model', model_name));

% detector = tempo.detector;

% Test set
if ~exist(fullfile(pwd,'data_test_1'), 'dir')
    mkdir(fullfile('data_test_1'));
end
% data_test
% data_test_1
% data_test_2
% data_test_3

test_Imds = imageDatastore(fullfile(pwd,'data_test'), 'IncludeSubfolders', true, 'LabelSource', 'foldernames');


idx = randperm(height(test_Imds.Files), height(test_Imds.Files));
tempTruth = [];
tempPred = [];
for i = 1:length(idx)
    I = readimage(test_Imds, idx(i));
% for i = 1:height(test_Imds.Files)
%     I = readimage(test_Imds, i);
    
    %IMAGE SEGMENTATION
    img=rgb2ycbcr(I);

    for j=1:size(img,1)
        for k= 1:size(img,2)
            cb = img(j,k,2);
            cr = img(j,k,3);
            if(~(cr > 132 && cr < 173 && cb > 76 && cb < 126))
                img(j,k,1)=235;
                img(j,k,2)=128;
                img(j,k,3)=128;
            end
        end
    end
    img=ycbcr2rgb(img);
    grayImage=rgb2gray(img);

    %GRAY TO BINARY IMAGE
    binaryImage = grayImage < 245;

    % Label the image 
    % label the connected components in an image and assigning each one a unique label
    labeledImage = bwlabel(binaryImage);
    measurements = regionprops(labeledImage, 'BoundingBox', 'Area');
    for j = 1 : length(measurements)
      thisBB = measurements(j).BoundingBox;
    end

    % Let's extract the second biggest blob - that will be the hand.
    allAreas = [measurements.Area];
    if ~isempty(allAreas)
        [sortedAreas, sortingIndexes] = sort(allAreas, 'descend');
        handIndex = sortingIndexes(1);
        % The hand is the second biggest, face is biggest.

        % Use ismember() to extact the hand from the labeled image.
        handImage = ismember(labeledImage, handIndex);

        % Now binarize
        handImage = handImage > 0;
        rect = measurements(handIndex).BoundingBox;
        img = imcrop(img,rect);
    end

    [boxes,scores,labels] = detect(detector, img);
    if(~isempty(rect) && ~isempty(labels))
        tempPred{i} = char(labels(1));
        tempTruth{i} = char(test_Imds.Labels(idx(i)));
    else
        tempPred{i} = '_FAIL_';
        tempTruth{i} = char(test_Imds.Labels(idx(i)));
    end
end

truthLabels = categorical(tempTruth);
predictionLabels = categorical(tempPred);

accuracy = sum(truthLabels == predictionLabels) / numel(predictionLabels);

cm = confusionchart(truthLabels, predictionLabels);
cm.Title = strcat('Accuracy : ', num2str(accuracy));