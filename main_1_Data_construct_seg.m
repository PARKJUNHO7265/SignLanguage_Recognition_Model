%% 레이블링이 완료되어 있는 ground truth datastore 불러오기
%Image Labeler 앱 이용해서 미리 Labeling하고 mat파일로 저장해야함.

clc, clear, close all

% 파일 이름만 바꿔주기
datastore_Name = 'without_IJMNSTZ';
datastore = load(fullfile(pwd, 'datastore_labeled_train', [datastore_Name '.mat']));
gTruth = datastore.gTruth;

%% 파일 경로 변경
LabelNames = gTruth.LabelData.Properties.VariableNames;

for i = 1:length(LabelNames)
    originalPath = string(fullfile('C:\Users\banel\Desktop\pleaseYOLO\data_processed_train', LabelNames{i}));
    newPath = string(fullfile(pwd, 'data_processed_train', LabelNames{i}));
    alternativePaths = {[originalPath newPath]};
    unresolvedPaths = changeFilePaths(gTruth, alternativePaths);
end

%% 데이터베이스 구축
imageFilename = gTruth.DataSource.Source;
imageLabel = gTruth.LabelData;

rng(0);
shuffledIds = randperm(height(imageFilename));
imageFilename = imageFilename(shuffledIds,:);
imageLabel = imageLabel(shuffledIds,:);

imds = imageDatastore([imageFilename]);
blds = boxLabelDatastore(imageLabel);
dataStore = combine(imds, blds);

%% Data Augmentation
data = read(dataStore);
I = data{1};
bbxs = data{2};
lbls = data{3};

augmentedTrainingData = transform(dataStore,@function_jitterImageColorAndWarp);

data = readall(augmentedTrainingData);
numObservations = 4;
rgb = cell(numObservations,1);
for k = 1:numObservations
    I = data{k,1};
    bbox = data{k,2};
    labels = data{k,3};
    rgb{k} = insertObjectAnnotation(I,'rectangle',bbox,labels,'LineWidth',8,'FontSize',40);
end
montage(rgb)