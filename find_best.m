function [ s, index, transform ] = find_best( block, domain )
    % set up for optimal block matching
    min_dist = 99999999;
    s = 1;
    index = 1;
    transform = 0;
        
    for i=1:length(domain)
        
        % use more affine transforms
        for tr=0:0
            % domain block being tested
            dom = domain(i);
            dom.block = apply_trans(dom.block, tr);

            % compute means
            d_mean = dom.mean;
            r_mean = block.mean;

            % interm. computations
            a = block.block - r_mean;
            b = dom.block - d_mean;

            % compute optimal affine parameters
            a_times_b = a .* b;
            b_times_b = b .* b;
            test_s = sum(a_times_b(:)) / sum(b_times_b(:)) - rand(1,1);
            test_s = min(test_s, 1);
            test_s = max(test_s, 0);
            
            var_r_v = block.block - block.mean;
            var_r_v = var_r_v(:);
            var_r = var_r_v' * var_r_v;
            
            var_d_v = dom.block - dom.mean;
            var_d_v = var_d_v(:);
            var_d = var_d_v' * var_d_v;
            
            test_dist = var_r - test_s*test_s*var_d;
            
            if test_dist < min_dist
                s = test_s;
                min_dist = test_dist;
                index = i;
                transform = tr;
            end
        end
    end

end

