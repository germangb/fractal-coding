function [ image ] = join_blocks( blocks, width, height )

    [B, B] = size(blocks(1).block);
    
    image = zeros(width, height);
    
    x_steps = width / B;
    y_steps = height / B;
    
    i = 1;
    for x=1:x_steps
        for y=1:y_steps
            x_off = B * (x-1);
            y_off = B * (y-1);
            image(1+x_off:x_off+B, 1+y_off:y_off+B) = blocks(i).block;
            i = i+1;
        end
    end
end

