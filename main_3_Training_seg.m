%% Training Option 설정

initLR = 0.001;
numEpoch = 10;
LRdrop = 0.1;
LRdropPeriod = 20;

options = trainingOptions('adam',...
          'InitialLearnRate',initLR,...
          'LearnRateSchedule','piecewise', ...
          'LearnRateDropFactor',LRdrop, ...
          'LearnRateDropPeriod',LRdropPeriod, ...
          'Verbose',true,...
          'MiniBatchSize',64,...
          'MaxEpochs',numEpoch,...
          'Shuffle','every-epoch',...
          'VerboseFrequency',20,...
          'Plots', 'training-progress');
      
%% 주어진 dataStore에 training option을 적용하여 YOLOv2 network를 학습시킨다.
[detector,info] = trainYOLOv2ObjectDetector(augmentedTrainingData,lgraph,options);

%% 학습된 model에 대한 정보를 출력
% detector
figure
% plot(info.TrainingRMSE,...
plot(info.TrainingLoss,...
    'LineWidth',2,...
    'MarkerSize',10,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5])
grid on
xlabel('Number of Iterations', 'FontSize', 20)
ylabel('Training Loss for Each Iteration', 'FontSize', 20)
ax = gca

% Set x and y font sizes.
ax.XAxis.FontSize = 15;
ax.YAxis.FontSize = 15;

%% 모델 및 학습 내용 저장
% trained_model 폴더에 학습 끝난 모델 저장
if ~exist(fullfile(pwd,'trained_model'), 'dir')
    mkdir trained_model
end
path = fullfile(pwd, 'trained_model');
name = strcat('Model_', string(datetime('now', 'Format','yyMMdd')), datastore_Name,...
                    model_name, '_numEpoch_', num2str(numEpoch), '_InitLR_', num2str(initLR), '.mat'); 
save([name], 'detector');
movefile(name, path);

% training loss에 관한 데이터를 train_result 폴더에 저장
if ~exist(fullfile(pwd,'train_result'), 'dir')
    mkdir train_result
end
path = fullfile(pwd, 'train_result');
name = strcat('Result_', string(datetime('now', 'Format','yyMMdd')), datastore_Name,...
                    model_name, '_numEpoch_', num2str(numEpoch), '_InitLR_', num2str(initLR), '.mat'); 
save([name], 'info');
movefile(name, path);