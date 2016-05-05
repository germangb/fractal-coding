function [ img ] = load_raw( file, width, height )

    fid = fopen(file);
    img = uint8(zeros(width, height));
    img(:) = fread(fid, width*height, 'uint8');
    img = img';
    fclose(fid);
end

