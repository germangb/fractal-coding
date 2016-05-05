function [ blocks ] = get_blocks( img, B, adv )

    [w, h] = size(img);
    
    x_steps = floor((w - B) / adv) + 1;
    y_steps = floor((h - B) / adv) + 1;

    blocks = [];
    
    for x=1:x_steps
        for y=1:y_steps
            x_off = adv * (x-1);
            y_off = adv * (y-1);
            block = img(1+x_off:x_off+B, 1+y_off:y_off+B);
            %figure;
            %imshow(block);
            
            blocks = [blocks, struct('block', block, 'mean', sum(block(:))/(B*B))];
        end
    end
end

