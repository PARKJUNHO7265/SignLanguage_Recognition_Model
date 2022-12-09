clc, clear, close all

% 클래스 이름 설정
class_name = 'E';

% 생성하는 이미지 개수
img_num = 20;

%% Get Image
vid = videoinput('winvideo', 1, 'YUY2_640x480');
set(vid, 'ReturnedColorSpace', 'RGB');
preview(vid);

for i=1:img_num
    temp = class_name;
    for j=1:(length(num2str(img_num))+1)-length(num2str(i))
        temp = strcat(temp, num2str(zeros));
    end
    img = getsnapshot(vid);
    imwrite(img,[temp num2str(i) '.jpg'])
end

% % data_origial_train 폴더 생성
% if ~exist(fullfile(pwd,'data_original_train', class_name), 'dir')
%     mkdir(fullfile('data_original_train', class_name));
% end

% data_test 폴더 생성
if ~exist(fullfile(pwd,'data_test_2', class_name), 'dir')
    mkdir(fullfile('data_test_2', class_name));
end

for i=1:img_num
    temp = class_name;
    for j=1:(length(num2str(img_num))+1)-length(num2str(i))
        temp = strcat(temp, num2str(zeros));
    end
    movefile([temp num2str(i) '.jpg'], fullfile(pwd,'data_test_2', class_name));
end
closepreview(vid)
