function [ psnr ] = compute_psnr( image, ref )

    [w, h] = size(image);
    diff_sq = (image-ref).^2;
    mse = sum(diff_sq(:))/(w*h);
    psnr = 10*log10(1/mse);
end

