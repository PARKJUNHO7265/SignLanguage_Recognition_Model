% clc, clear, close all
% 
% % 클래스 이름 설정
class_name = 'A';
% 
% % 생성하는 이미지 개수
img_num = 500;
% 
imds = imageDatastore(fullfile(pwd,'data_original_train', class_name));
% 
%                 % 132 < img(j,k,3) < 173이 아니고, 76 < img(j,k,2) < 126이 아니면) 
%                 % 하얗게 배경 처리한다.
%% Image Segmentation

for x=1:height(imds.Files)   
    %IMAGE SEGMENTATION
    img = imread(imds.Files{x});
    img = rgb2ycbcr(img);
    for i=1:size(img,1)
        for j= 1:size(img,2)
            cb = img(i,j,2);
            cr = img(i,j,3);
            if(~(cr > 132 && cr < 173 && cb > 76 && cb < 126))
                img(i,j,1)=235;
                img(i,j,2)=128;
                img(i,j,3)=128;
            end
        end
    end
    img = ycbcr2rgb(img);
%     imshow(img)
    grayImage = rgb2gray(img);
   
    %GRAY TO BINARY IMAGE
    binaryImage = grayImage < 245;
    
    % Label the image 
    % label the connected components in an image and assigning each one a unique label
    labeledImage = bwlabel(binaryImage); 
    measurements = regionprops(labeledImage, 'BoundingBox', 'Area');
    for i = 1 : length(measurements)
      thisBB = measurements(i).BoundingBox;
      rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
                'EdgeColor','r','LineWidth',2 );
    end
    
    % Let's extract the second biggest blob - that will be the hand.
    allAreas = [measurements.Area];
    [sortedAreas, sortingIndexes] = sort(allAreas, 'descend');
    handIndex = sortingIndexes(1); 
    % The hand is the second biggest, face is biggest.
    
    % Use ismember() to extact the hand from the labeled image.
    handImage = ismember(labeledImage, handIndex);
    
    % Now binarize
    handImage = handImage > 0;
    rect = measurements(handIndex).BoundingBox;
    imgcroped = imcrop(img,rect);
%     imshow(imgcroped)
end

% data_processed_train 폴더 생성
if ~exist(fullfile(pwd,'data_processed_train', class_name), 'dir')
    mkdir(fullfile('data_processed_train', class_name));
end

for x=1:height(imds.Files)
    temp = class_name;
    for j=1:(length(num2str(img_num))+1)-length(num2str(x))
        temp = strcat(temp, num2str(zeros));
    end
    movefile([temp num2str(x) '.jpg'], fullfile(pwd,'data_processed_train', class_name));
end

%% Segmentation이 완료된 이미지들을 imds로 작업 공간에 생성

    temp = class_name;
    for j=1:(length(num2str(img_num))+1)-length(num2str(x))
        temp = strcat(temp, num2str(zeros));
    end
    imwrite(imgcroped ,[temp num2str(x) '.jpg']);
imds = imageDatastore(fullfile(pwd,'data_processed_train', class_name));

% 이 상태로 바로 Image Labeler가서 labeling -> 사진 load할 때 작업공간에서 imds 불러오기
% autolabel_1_objectlabel.m 가서 label을 변경해준 후에 labeling 하기

% labeling 완료된 후 gTruth 파일을 저장하기 위해 datastore_labeled_train 폴더 생성
if ~exist(fullfile(pwd,'datastore_labeled_train'), 'dir')
    mkdir(fullfile('datastore_labeled_train'));
end