%% REPLACE RANGE WITH BEST MATCHING DOMAIN

Rr = R;
for i=1:length(R)
    Rr(i) = D(CODED(i).index);
end

imshow(join_blocks(Rr, 256, 256));

%% FIND TRANSFORMATIONS

clear all;

B = 8;
V = 4;

I = double(load_raw('images/lena.lum', 256, 256))/255;

% get range blocks
R = get_blocks(I, B, B);

% get domain blocks
Idec = imresize(I, 0.5);
D = get_blocks(Idec, B, V);
CODED = [];

for i=1:length(R)
    fprintf('matching block %d/%d\n', i, length(R));
    [s, g, index, trans] = find_best(R(i), D);
    CODED = [CODED, struct('s', s, 'g', g, 'r', R(i).mean, 'index', index, 'trans', trans)];
end

%% RECONSTRUCTION

F = 4;
S = 256*F;
H = rand(S, S);
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
        %Hnext(i).block = block.block * CODED(i).s + CODED(i).g;
        Hnext(i).block = CODED(i).s * (block.block - block.mean) + CODED(i).r;
    end
    
    H = join_blocks(Hnext, S, S);
    ITS = [ITS, struct('img', H)];
end

DEC = ITS(end).img;
imshow(DEC);

%% PLOT

for i=1:length(ITS)-1
    imshow(ITS(i).img); title(sprintf('Iteration #%d', i-1));
    waitforbuttonpress
end

%imshow(ITS(end).img);
%compute_psnr(ITS(end).img, I)

subplot(1, 2, 1); imshow(I);
subplot(1, 2, 2); imshow(ITS(i).img); title(sprintf('Iteration #%d', length(ITS)-1));
