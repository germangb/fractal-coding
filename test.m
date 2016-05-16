%% REPLACE RANGE WITH BEST MATCHING DOMAIN

Rr = R;
for i=1:length(R)
    Rr(i) = D(CODED(i).index);
end

imshow(join_blocks(Rr, 256, 256));

%% FIND TRANSFORMATIONS

clear all;

B = 4;
V = 4;

Iraw = load_raw('images/lena.lum', 256, 256);
I = double(Iraw)/255;

% get range blocks
[R, Rmeans] = get_blocks(I, B, B);

% get domain blocks
Idec = imresize(I, 0.5);
D = get_blocks(Idec, B, V);
CODED = [];

for i=1:length(R)
    fprintf('matching block %d/%d\n', i, length(R));
    [s, index, trans] = find_best(R(i), D);
    CODED = [CODED, struct('s', s, 's_q', s, 'r', R(i).mean, 'r_q', R(i).mean, 'index', index, 'trans', trans)];
end

%% GRAB MEAN VARIANCE
V_MEAN = 0.0;
for i=1:length(D)
    V_MEAN = V_MEAN + D(i).var;
end
V_MEAN = V_MEAN / length(D);

%% QUANTIZE

% determine bits for each parameter
dr = Rmeans(2) - Rmeans(1);

b_total = 10;
for bits=1:b_total-1

    b_r = floor((b_total + log2(dr/sqrt(V_MEAN)))/2);

    b_r = bits;

    b_s = b_total - b_r;
    bits = [b_r, b_s]

    s_levels = 2^b_s;
    s_q_step = 1/s_levels;

    r_levels = 2^b_r;
    r_q_step = 1/r_levels;

    for i=1:length(CODED)
        s = CODED(i).s;
        r = CODED(i).r;
        CODED(i).s_q = s_q_step * (1+floor(s/s_q_step - s_q_step*1e-16));
        CODED(i).r_q = r_q_step/2 + r_q_step*floor((r - Rmeans(1))/dr/r_q_step - 0.00001);
        CODED(i).r_q = (1-CODED(i).r_q) * Rmeans(1) + CODED(i).r_q * Rmeans(2);
    end

    % RECONSTRUCTION

    F = 1;
    %H = double(load_raw('images/camman.lum', 256, 256))/255;
    H = rand(256, 256);
    H = imresize(H, F);
    IT = 8;

    ITS = [struct('img', H)];
    for iter=1:IT
        %fprintf('Iteration #%d\n', iter);
        Hdec = imresize(H, 0.5);
        Ddec = get_blocks(Hdec, B*F, V*F);
        Hblock = get_blocks(H, B*F, B*F);
        Hnext = get_blocks(H, B*F, B*F);

        for i=1:length(CODED)
            block = Ddec(CODED(i).index);
            block.block = apply_trans(block.block, CODED(i).trans);
            Hnext(i).block = CODED(i).s_q * (block.block - block.mean) + CODED(i).r_q;
        end

        H = join_blocks(Hnext, 256, 256);
        ITS = [ITS, struct('img', H)];
    end

    DEC = ITS(end).img;
    imwrite(DEC, 'tmp.png');
    tmp = imread('tmp.png');
    psnr = compute_psnr(tmp, Iraw);
    list_psnr = [list_psnr, psnr];
end
    
%% PLOT

for i=1:length(ITS)-1
    %break;
    imshow(ITS(i).img); title(sprintf('Iteration #%d', i-1));
    waitforbuttonpress
end

imshow(ITS(end).img); title(sprintf('PSNR = %.02fdB', psnr));

%subplot(1, 2, 1); imshow(I);
%subplot(1, 2, 2); imshow(ITS(i).img); title(sprintf('Iteration #%d', length(ITS)-1));
