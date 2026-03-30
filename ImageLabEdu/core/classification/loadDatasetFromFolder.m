function ds = loadDatasetFromFolder(datasetPath)
%LOADDATASETFROMFOLDER Charge un dataset organisé par sous-dossiers de classes.
% Ex. dataset/classA/*.png, dataset/classB/*.png
    exts = {'.png','.jpg','.jpeg','.bmp','.tif','.tiff'};
    classes = dir(datasetPath);
    classes = classes([classes.isdir]);
    classes = classes(~ismember({classes.name},{'.','..'}));
    if isempty(classes)
        error('Aucun sous-dossier de classe trouvé dans le dataset.');
    end

    files = {};
    labels = strings(0,1);
    for k = 1:numel(classes)
        className = string(classes(k).name);
        classFolder = fullfile(datasetPath, classes(k).name);
        content = dir(classFolder);
        for i = 1:numel(content)
            if content(i).isdir, continue; end
            [~,~,ext] = fileparts(content(i).name);
            if any(strcmpi(ext, exts))
                files{end+1,1} = fullfile(classFolder, content(i).name); %#ok<AGROW>
                labels(end+1,1) = className; %#ok<AGROW>
            end
        end
    end

    if isempty(files)
        error('Aucune image valide dans le dataset.');
    end

    ds = struct();
    ds.path = datasetPath;
    ds.files = files;
    ds.labels = categorical(labels);
    ds.classNames = categories(ds.labels);
    ds.numImages = numel(files);
    ds.numClasses = numel(ds.classNames);
end
