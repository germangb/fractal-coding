function [ blocks, mean_dyn ] = get_blocks( img, B, adv )

    [w, h] = size(img);
    
    x_steps = floor((w - B) / adv) + 1;
    y_steps = floor((h - B) / adv) + 1;

    blocks = [];
    mean_dyn = [Inf, -Inf];
    
    for x=1:x_steps
        for y=1:y_steps
            x_off = adv * (x-1);
            y_off = adv * (y-1);
            block = img(1+x_off:x_off+B, 1+y_off:y_off+B);
            %figure;
            %imshow(block);
            
            mean = sum(block(:))/(B*B);

            % compute variance
            tmp = block(:) - mean;
            var = (tmp' * tmp) / (B*B);
            
            blocks = [blocks, struct('block', block, 'mean', mean, 'var', var)];
            
            mean_dyn(1) = min(mean_dyn(1), mean);
            mean_dyn(2) = max(mean_dyn(2), mean);
        end
    end
end

