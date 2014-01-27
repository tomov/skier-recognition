folder = 'images';
training_set_size = 10;
n = 30;
patch_size = 11;
k = 100;

% get the classes and their subfolders

listing = dir(folder);
classes = [];
for i = 1 : size(listing)
    class_folder = listing(i).name;
    if class_folder(1) == '.', continue; end
    
    files = dir(strcat(folder,'/',class_folder));
    filenames = [];
    for j = 1 : size(files)
        filename = files(j).name;
        if filename(1) == '.', continue; end;
        filenames = [filenames; filename];
    end
    
    perm = randperm(size(filenames, 1));
    training_set = perm(1:training_set_size);
    test_set = perm(training_set_size + 1:size(filenames, 1));
    
    class = struct('name', class_folder, 'images', filenames, 'training_set', training_set, 'test_set', test_set);
    classes = [classes class];
end


% get the patches and run k-means clustering

patches = ones(size(classes, 2) * training_set_size * n, patch_size * patch_size + 40);
patch_idx = 1;
for i = 1 : size(classes, 2)
    for j = 1 : training_set_size
        idx = classes(i).training_set(j);
        filename = strcat(folder, '/', classes(i).name, '/', classes(i).images(idx,:));
        pic = imread(filename);
        if size(size(pic), 2) == 3
            pic = im2double(rgb2gray(pic));
        else
            pic = im2double(pic) / 255.0;
        end
        
        corners = corner(filename, 3, patch_size, 5e-8);
        perm = randperm(size(corners, 1));
        fprintf('finished processing %s\n', filename);
        for p = 1 : n
            if (p <= size(perm, 2))
                x = corners(perm(p), 2);
                y = corners(perm(p), 3);
            else
                x = ceil(rand(1)*(size(pic, 1) - patch_size + 1));
                y = ceil(rand(1)*(size(pic, 2) - patch_size + 1));
            end
            patch = pic(x:x+patch_size-1, y:y+patch_size-1);
            patch = patch(:)';
            patch = [patch ones(1,20)*x ones(1,20)*y];
            
            patches(patch_idx,:) = patch;
            patch_idx = patch_idx + 1;
        end
    end
end

[clusters, centers] = kmeans(patches, k, 'emptyaction', 'drop');

histograms = zeros(size(classes, 2), k);

% learn patch histograms

patch_idx = 1;
for i = 1 : size(classes, 2)
    for j = 1 : training_set_size
        for p = 1:n
            histograms(i, clusters(patch_idx)) = histograms(i, clusters(patch_idx)) + 1;
            patch_idx = patch_idx + 1;
        end
    end
end

