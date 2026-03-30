function metrics = evaluateClassification(YTrue, YPred)
%EVALUATECLASSIFICATION Calcule matrice de confusion et métriques.
    classNames = union(categories(YTrue), categories(YPred));
    C = zeros(numel(classNames));
    for i = 1:numel(YTrue)
        r = find(strcmp(string(YTrue(i)), string(classNames)), 1);
        c = find(strcmp(string(YPred(i)), string(classNames)), 1);
        if ~isempty(r) && ~isempty(c)
            C(r,c) = C(r,c) + 1;
        end
    end

    tp = diag(C);
    fp = sum(C,1)' - tp;
    fn = sum(C,2) - tp;

    precisionPerClass = tp ./ max(tp + fp, eps);
    recallPerClass = tp ./ max(tp + fn, eps);
    f1PerClass = 2 * precisionPerClass .* recallPerClass ./ max(precisionPerClass + recallPerClass, eps);

    accuracy = sum(tp) / max(sum(C(:)), 1);

    metrics = struct();
    metrics.accuracy = accuracy;
    metrics.precision = mean(precisionPerClass);
    metrics.recall = mean(recallPerClass);
    metrics.f1score = mean(f1PerClass);
    metrics.numClasses = numel(classNames);
    metrics.confusionMatrix = C;
    metrics.classNames = classNames;
end
