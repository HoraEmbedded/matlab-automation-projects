function [label, score] = predictImageClassifier(model, I, params)
%PREDICTIMAGECLASSIFIER Prédit la classe d'une nouvelle image.
    feat = extractFeatureVector(I, params.featureMethod);
    X = (feat - model.preprocessing.mu) ./ model.preprocessing.sigma;

    switch string(model.preprocessing.classifierName)
        case {"knn", "svm-ecoc", "arbre", "random-forest"}
            [label, score] = predict(model.mdl, X);
        case "knn-manuel"
            label = localManualKnnPredict(model.mdl, X);
            score = localScoresFromLabel(label, model.classNames);
        otherwise
            error('Type de modèle non reconnu.');
    end
end

function label = localManualKnnPredict(mdl, x)
    d = sum((mdl.XTrain - x).^2, 2);
    [~, idx] = sort(d, 'ascend');
    neigh = mdl.YTrain(idx(1:mdl.K));
    label = mode(neigh);
end

function score = localScoresFromLabel(label, classNames)
    score = zeros(1, numel(classNames));
    c = find(strcmp(string(label), string(classNames)), 1);
    if ~isempty(c)
        score(c) = 1;
    end
end
