function exportSessionReportTXT(filename, payload)
%EXPORTSESSIONREPORTTXT Exporte un rapport texte simple de la session.
    fid = fopen(filename, 'w');
    if fid < 0
        error('Impossible d''ouvrir le fichier de rapport.');
    end
    cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>

    fprintf(fid, 'ImageLab Edu - Rapport de session\n');
    fprintf(fid, 'Date : %s\n\n', datestr(now));

    if isfield(payload, 'params')
        fprintf(fid, '--- Paramètres courants ---\n');
        dispStructRecursive(fid, payload.params, '');
        fprintf(fid, '\n');
    end

    if isfield(payload, 'texture') && ~isempty(payload.texture)
        fprintf(fid, '--- Résultats texture ---\n');
        if isfield(payload.texture, 'scalarFeatures')
            dispStructRecursive(fid, payload.texture.scalarFeatures, '');
        end
        fprintf(fid, '\n');
    end

    if isfield(payload, 'classification') && ~isempty(payload.classification)
        fprintf(fid, '--- Résultats classification ---\n');
        if isfield(payload.classification, 'metrics')
            dispStructRecursive(fid, payload.classification.metrics, '');
        end
        fprintf(fid, '\n');
    end

    if isfield(payload, 'logs') && ~isempty(payload.logs)
        fprintf(fid, '--- Journal ---\n');
        for k = 1:numel(payload.logs)
            fprintf(fid, '%s\n', payload.logs{k});
        end
    end
end

function dispStructRecursive(fid, S, prefix)
    if ~isstruct(S)
        fprintf(fid, '%s%s\n', prefix, localValueToString(S));
        return;
    end
    f = fieldnames(S);
    for k = 1:numel(f)
        val = S.(f{k});
        if isstruct(val)
            fprintf(fid, '%s%s:\n', prefix, f{k});
            dispStructRecursive(fid, val, [prefix '  ']);
        else
            fprintf(fid, '%s%s = %s\n', prefix, f{k}, localValueToString(val));
        end
    end
end

function s = localValueToString(v)
    if isnumeric(v) || islogical(v)
        if isscalar(v)
            s = num2str(v);
        else
            sz = size(v);
            s = sprintf('[%s %s]', class(v), strjoin(string(sz), 'x'));
        end
    elseif iscategorical(v)
        s = sprintf('[categorical %dx%d]', size(v,1), size(v,2));
    elseif isstring(v) || ischar(v)
        s = char(string(v));
    elseif iscell(v)
        s = sprintf('[cell %dx%d]', size(v,1), size(v,2));
    else
        s = class(v);
    end
end
