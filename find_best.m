function [ s, g, index, transform ] = find_best( block, domain )
    
    % set up for optimal block matching
    min_dist = 99999999;
    s = 1;
    g = 0;
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
            
            test_g = r_mean - test_s*d_mean;

            % compute transformed domain and compare
            trans = test_s .* dom.block + test_g;
            diff = (trans - block.block).^2;
            test_dist = sum(diff(:));

            if test_dist < min_dist
                s = test_s;
                g = test_g;
                min_dist = test_dist;
                index = i;
                transform = tr;
            end
        end
    end

end

