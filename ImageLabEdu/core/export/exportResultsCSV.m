function exportResultsCSV(filename, payload)
%EXPORTRESULTSCSV Exporte les mesures scalaires en CSV.
    rows = {};
    values = [];

    if isfield(payload, 'texture') && ~isempty(payload.texture) && isfield(payload.texture, 'scalarFeatures')
        f = fieldnames(payload.texture.scalarFeatures);
        for k = 1:numel(f)
            rows{end+1,1} = ['texture_' f{k}]; %#ok<AGROW>
            values(end+1,1) = payload.texture.scalarFeatures.(f{k}); %#ok<AGROW>
        end
    end

    if isfield(payload, 'classification') && ~isempty(payload.classification) && isfield(payload.classification, 'metrics')
        m = payload.classification.metrics;
        metricFields = {'accuracy','precision','recall','f1score','numClasses'};
        for k = 1:numel(metricFields)
            if isfield(m, metricFields{k}) && isscalar(m.(metricFields{k}))
                rows{end+1,1} = ['classification_' metricFields{k}]; %#ok<AGROW>
                values(end+1,1) = m.(metricFields{k}); %#ok<AGROW>
            end
        end
    end

    T = table(rows, values, 'VariableNames', {'Mesure','Valeur'});
    writetable(T, filename);
end
