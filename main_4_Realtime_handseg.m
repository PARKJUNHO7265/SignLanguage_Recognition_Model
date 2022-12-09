% % 필요할 때 저장된 모델 불러오기
% 
% model_name = 'Model_201206without_IJMNSTZResNet18_numEpoch_10_InitLR_0.01.mat';
% model_name = 'Model_20201203-1131_datastoreName_without_IJMNSTZ_netName_ResNet18.mat';
% model_name = 'Model_20201204-1439_datastoreName_without_IJMNSTZ_netName_ResNet18.mat';
model_name = 'Model_201208without_IJMNSTZResNet18_numEpoch_10_InitLR_0.01.mat';
tempo = load(fullfile(pwd, 'trained_model', model_name));

detector = tempo.detector;

%% Real time으로 확인해보기 (지금은 detection을 못하는 듯?)

% 카메라 이름 설정하기
camera = webcam('Iriun Webcam');
camera.Resolution = camera.AvailableResolutions{1};
viewer = vision.DeployableVideoPlayer();
% Auxiliary variables
inputSize = detector.Network.Layers(1).InputSize(1:2);
fps = 0;
avgfps = [];
cont = true;
% % Figure Box 범위 설정
% ax1 = axes('Position',[0.1 0.1 0.5 0.8],'Box','on');
% ax2 = axes('Position',[0.65 0.51 0.25 0.39],'Box','on');
% ax3 = axes('Position',[0.65 0.1 0.25 0.39],'Box','on');
% % Figure 화면 크게
% set(gcf,'units','normalized','outerposition',[0 0 1 1]);


while cont
    frame = snapshot(camera);       % 카메라를 통해 순간 사진을 캡쳐 : frame
    tic;                            % Count FPS
    
    %IMAGE SEGMENTATION
    img=rgb2ycbcr(frame);          % 128 X 128로 조정된 frame1에 대해서 image segmentation 진행
    for i=1:size(img,1)
        for j= 1:size(img,2)
            cb = img(i,j,2);
            cr = img(i,j,3);
            if(~(cr > 132 && cr < 173 && cb > 76 && cb < 126))
                % 132 < img(i,j,3) < 173이 아니고, 76 < img(i,j,2) < 126이 아니면) 
                % 하얗게 배경 처리한다.
                img(i,j,1)=235;
                img(i,j,2)=128;
                img(i,j,3)=128;
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
    for k = 1 : length(measurements)
      thisBB = measurements(k).BoundingBox;
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
        rect = measurements(handIndex).BoundingBox;   % (128X128)에서 쳐진 Bounding Box : rect
        img = imcrop(img,rect);                 % (128X128) 사이즈의 이미지 img에서 rect 영역을 잘라낸 게 imgcroped
    end
    
    % detect object with trained yolo network
    tic;
    % (128X128)의 이미지에서 잘라낸 영역인 imgcroped를 가지고 객체 검출 진행
    % 객체 검출 결과, bounding box는 bbox에 저장
    [bbox, score, label] = detect(detector, img, 'ExecutionEnvironment', "cpu", 'Threshold', 0.8);
%   You can use below after generating CUDA mex with GPU Coder.
%   [bbox, score, label] = yolov2_detect_mex(frame1, 0.55);
    newt = toc;
    
    % fps
    fps = .9*fps + .1*(1/newt);
    avgfps = [avgfps, fps];
    
    num = numel(bbox(:,1));     % detector가 감지한 bounding box의 개수?
    detectedImg = frame;
    annotation = [];
    color =[];
    bbox1 =[];
    
    if num > 0
        label = categorical(label);
        k=1;
        
        % set annotation and color of bbox
        % 감지해낸 num개의 bounding box들에 대해서 label 및 score 정보를 표시 (annotation)
        for n=1:num     
            annotation{k} = sprintf('%s: ( %f)', label(1), score(1));
            color{k} = 'yellow';
            %bbox1(k,:) = rect(n,:);
            % rect는 항상 1개인데, detector가 검출해낸 건 여러 개일 수 있어서(?)
            % rect의 index를 초과하기 때문에 오류가 발생?
            if ~isempty(allAreas)
                bbox1(k,:) = rect(1,:);
            end
            k=k+1;
        end
        
        % add anotations to show the result
        detectedImg = insertObjectAnnotation(detectedImg, 'rectangle', bbox1, annotation,'Color',color);   
    end
    
    % show the result
    detectedImg = insertText(detectedImg, [1, 1],  sprintf('FPS %2.2f', fps), 'FontSize', 26, 'BoxColor', 'y');    
    %% detectedImg, handImage, score 한개의 figure에 출력
%     imagesc(ax1,detectedImg)
%     imagesc(ax2,handImage)
%     axes(ax3);
%     x = [label()];
%     y = [score()];
%     bar(x,y,0.3);
    
        
    viewer(detectedImg);
    cont = isOpen(viewer);
    
    

end
