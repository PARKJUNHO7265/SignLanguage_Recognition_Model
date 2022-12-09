function [labelCord, label] = autolabel_1_objectlabel(I, algObj)
    [BW, ~] = autolabel_0_createMask(I);

    s = regionprops(BW);
    maxVals = arrayfun(@(struct)max(struct.Area(:)),s);
    [~, i] = max(maxVals);
    labelCord = s(i).BoundingBox;
    labelCord(1)= int16(labelCord(1));  % x 좌표 (왼쪽 상단부터)
    labelCord(2)= int16(labelCord(2));  % y 좌표 (왼쪽 상단부터)
    labelCord(3)= int16(labelCord(3));  % 너비
    labelCord(4)= int16(labelCord(4));  % 높이
    
    label = 'D';
    [a, b] = size(I);
    
    if labelCord(1) + labelCord(4) > a
        labelCord(4) = a - labelCord(1);
    end
    if labelCord(2) + labelCord(3) > b
        labelCord(3) = b - labelCord(2);
    end
end

