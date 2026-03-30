function [model, results] = trainImageClassifier(ds, params)
%TRAINIMAGECLASSIFIER Pipeline complet de classification.
% Classifieurs : knn, svm-ecoc, arbre, random-forest, knn-manuel.

    rng(params.randomSeed);
    numSamples = ds.numImages;
    labels = ds.labels;

    % Extraction des caractéristiques
    X = [];
    for i = 1:numSamples
        img = imread(ds.files{i});
        feat = extractFeatureVector(img, params.featureMethod);
        if isempty(X)
            X = zeros(numSamples, numel(feat));
        end
        X(i,:) = feat;
    end

    % Normalisation z-score manuelle
    mu = mean(X,1);
    sigma = std(X,0,1);
    sigma(sigma < eps) = 1;
    Xn = (X - mu) ./ sigma;

    % Split train/test manuel
    [idxTrain, idxTest] = localHoldOutIndices(labels, params.holdOut);
    XTrain = Xn(idxTrain,:); YTrain = labels(idxTrain);
    XTest  = Xn(idxTest,:);  YTest  = labels(idxTest);

    classifierName = string(params.classifierName);
    trainer = struct('mu', mu, 'sigma', sigma, 'featureMethod', params.featureMethod, 'classifierName', classifierName);

    switch classifierName
        case "knn"
            requireStatsToolbox('k-NN');
            mdl = fitcknn(XTrain, YTrain, 'NumNeighbors', 3, 'Distance', 'euclidean');
            yPred = predict(mdl, XTest);
            score = localScoresFromLabels(yPred, categories(labels));
        case "svm-ecoc"
            requireStatsToolbox('SVM/ECOC');
            t = templateSVM('KernelFunction', 'rbf', 'KernelScale', 'auto', 'Standardize', false);
            mdl = fitcecoc(XTrain, YTrain, 'Learners', t);
            [yPred, score] = predict(mdl, XTest);
        case "arbre"
            requireStatsToolbox('arbre de décision');
            mdl = fitctree(XTrain, YTrain);
            [yPred, score] = predict(mdl, XTest);
        case "random-forest"
            requireStatsToolbox('random forest');
            t = templateTree('MaxNumSplits', 20);
            mdl = fitcensemble(XTrain, YTrain, 'Method', 'Bag', 'NumLearningCycles', 50, 'Learners', t);
            [yPred, score] = predict(mdl, XTest);
        case "knn-manuel"
            mdl = struct('XTrain', XTrain, 'YTrain', YTrain, 'K', 3);
            yPred = manualKnnPredict(mdl, XTest);
            score = localScoresFromLabels(yPred, categories(labels));
        otherwise
            error('Classifieur non reconnu.');
    end

    metrics = evaluateClassification(YTest, yPred);

    model = struct();
    model.mdl = mdl;
    model.preprocessing = trainer;
    model.classNames = categories(labels);

    results = struct();
    results.X = Xn;
    results.Y = labels;
    results.XTrain = XTrain;
    results.YTrain = YTrain;
    results.XTest = XTest;
    results.YTest = YTest;
    results.YPred = yPred;
    results.score = score;
    results.metrics = metrics;
end

function requireStatsToolbox(name)
    if ~(exist('fitcknn','file') == 2 || exist('fitcecoc','file') == 2 || exist('fitctree','file') == 2)
        error('Le module %s requiert Statistics and Machine Learning Toolbox.', name);
    end
end

function [idxTrain, idxTest] = localHoldOutIndices(Y, holdOut)
    classes = categories(Y);
    idxTrain = false(size(Y));
    idxTest = false(size(Y));
    for k = 1:numel(classes)
        idx = find(Y == classes{k});
        idx = idx(randperm(numel(idx)));
        nTest = max(1, round(holdOut * numel(idx)));
        idxTest(idx(1:nTest)) = true;
        idxTrain(idx(nTest+1:end)) = true;
    end
end

function yPred = manualKnnPredict(mdl, XTest)
    YTrain = mdl.YTrain;
    XTrain = mdl.XTrain;
    K = mdl.K;
    yPred = categorical(strings(size(XTest,1),1), categories(YTrain));
    for i = 1:size(XTest,1)
        d = sum((XTrain - XTest(i,:)).^2, 2);
        [~, idx] = sort(d, 'ascend');
        neigh = YTrain(idx(1:K));
        yPred(i) = mode(neigh);
    end
end

function score = localScoresFromLabels(yPred, classNames)
    score = zeros(numel(yPred), numel(classNames));
    for i = 1:numel(yPred)
        c = find(strcmp(string(yPred(i)), string(classNames)), 1);
        if ~isempty(c)
            score(i,c) = 1;
        end
    end
end
