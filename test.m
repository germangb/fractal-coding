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

I = double(load_raw('images/me.lum', 256, 256))/255;

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

%% QUANTIZE

b_total = 8;
b_s = 4;
b_r = b_total - b_s;

s_levels = 2^6;
s_q_step = 1/s_levels;

for i=1:length(CODED)
    s = CODED(i).s;
    r = CODED(i).r;
    CODED(i).s_q = q_step * (1+floor(s/s_q_step - s_q_step*1e-16));
end

% RECONSTRUCTION

F = 1;
S = 256*F;
H = double(load_raw('images/camman.lum', 256, 256))/255;
H = imresize(H, F);
IT = 8;

ITS = [struct('img', H)];
for iter=1:IT
    fprintf('Iteration #%d\n', iter);
    Hdec = imresize(H, 0.5);
    Ddec = get_blocks(Hdec, B*F, V*F);
    Hblock = get_blocks(H, B*F, B*F);
    Hnext = get_blocks(H, B*F, B*F);
    
    for i=1:length(CODED)
        block = Ddec(CODED(i).index);
        block.block = apply_trans(block.block, CODED(i).trans);
        Hnext(i).block = CODED(i).s_q * (block.block - block.mean) + CODED(i).r;
    end
    
    H = join_blocks(Hnext, S, S);
    ITS = [ITS, struct('img', H)];
end

DEC = ITS(end).img;
%imshow(DEC);

% PLOT

for i=1:length(ITS)-1
    %break;
    imshow(ITS(i).img); title(sprintf('Iteration #%d', i-1));
    waitforbuttonpress
end

psnr = compute_psnr(ITS(end).img, I);
imshow(ITS(end).img); title(sprintf('PSNR = %.02fdB', psnr));

%subplot(1, 2, 1); imshow(I);
%subplot(1, 2, 2); imshow(ITS(i).img); title(sprintf('Iteration #%d', length(ITS)-1));
