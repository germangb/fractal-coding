%%
I = double(load_raw('images/mandril.lum', 128, 128))/255;

%% REPLACE RANGE WITH BEST MATCHING DOMAIN

Rr = R;
for i=1:length(R)
    Rr(i) = D(CODED(i).index);
end

imshow(join_blocks(Rr, 128, 128));

%% FIND TRANSFORMATIONS

B = 4;
V = 4;

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

%% RECONSTRUCTION

F = 32;
H = rand(128*F, 128*F);
IT = 8;
Hr = rand(128*F, 128*F);
ITS = [struct('img', Hr)];
for iter=1:IT
    fprintf('Iteration #%d\n', iter);
    Hdec = imresize(Hr, 0.5);
    Ddec = get_blocks(Hdec, B*F, V*F);
    Hblock = get_blocks(Hr, B*F, B*F);
    Hnext = get_blocks(Hr, B*F, B*F);

    for i=1:length(CODED)
        block = Ddec(CODED(i).index);
        block.block = apply_trans(block.block, CODED(i).trans);
        Hnext(i).block = CODED(i).s * (block.block - block.mean) + CODED(i).r;
    end

    Hr = join_blocks(Hnext, 128*F, 128*F);
    ITS = [ITS, struct('img', Hr)];
end

DEC = ITS(end).img;
figure;
subplot(1,2,1); imshow(I);
subplot(1,2,2); imshow(DEC);

%% PLOT

for i=1:length(ITS)-1
    %break;
    imshow(ITS(i).img); title(sprintf('Iteration #%d', i-1));
    waitforbuttonpress
end

imshow(ITS(end).img); title(sprintf('PSNR = %.02fdB', psnr));

%subplot(1, 2, 1); imshow(I);
%subplot(1, 2, 2); imshow(ITS(i).img); title(sprintf('Iteration #%d', length(ITS)-1));