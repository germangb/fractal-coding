function [ transformed ] = apply_trans( img, index )
%APPLY_TRANS Summary of this function goes here
%   Detailed explanation goes here
    
    if index == 0
        transformed = img;
    elseif index == 4
        transformed = flipdim(img, 1);
    elseif index == 5
        transformed = flipdim(img, 2);
    else
        transformed = imrotate(img, 90*index);
    end
    
end

