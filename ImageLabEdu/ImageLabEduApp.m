classdef ImageLabEduApp < matlab.apps.AppBase
    % ImageLabEduApp
    % Application pédagogique MATLAB 100 % native pour l'enseignement
    % du traitement d'image, de l'analyse de texture, de la classification
    % et de la stéganographie.

    %% Propriétés UI publiques
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        MainGrid                    matlab.ui.container.GridLayout
        TopGrid                     matlab.ui.container.GridLayout
        ControlPanel                matlab.ui.container.Panel
        ActionGrid                  matlab.ui.container.GridLayout
        LoadButton                  matlab.ui.control.Button
        SaveButton                  matlab.ui.control.Button
        ResetButton                 matlab.ui.control.Button
        HistogramButton             matlab.ui.control.Button
        GrayButton                  matlab.ui.control.Button
        StatusLabel                 matlab.ui.control.Label

        DisplayPanel                matlab.ui.container.Panel
        DisplayGrid                 matlab.ui.container.GridLayout
        UIAxesOriginal              matlab.ui.control.UIAxes
        UIAxesResult                matlab.ui.control.UIAxes

        RightPanel                  matlab.ui.container.Panel
        TabGroup                    matlab.ui.container.TabGroup

        HomeTab                     matlab.ui.container.Tab
        HomeTextArea                matlab.ui.control.TextArea

        PreprocessTab               matlab.ui.container.Tab
        PreprocessGrid              matlab.ui.container.GridLayout
        PreprocessOperationDropDown matlab.ui.control.DropDown
        PreprocessParam1Label       matlab.ui.control.Label
        PreprocessParam1Field       matlab.ui.control.NumericEditField
        PreprocessParam2Label       matlab.ui.control.Label
        PreprocessParam2Field       matlab.ui.control.NumericEditField
        PreprocessApplyButton       matlab.ui.control.Button

        TextureTab                  matlab.ui.container.Tab
        TextureGrid                 matlab.ui.container.GridLayout
        TextureMethodListBox        matlab.ui.control.ListBox
        GrayLevelsSpinner           matlab.ui.control.Spinner
        GLCMDistanceSpinner         matlab.ui.control.Spinner
        GLCMDirectionDropDown       matlab.ui.control.DropDown
        TextureAnalyzeButton        matlab.ui.control.Button
        TextureTable                matlab.ui.control.Table

        GenerationTab               matlab.ui.container.Tab
        GenerationGrid              matlab.ui.container.GridLayout
        TextureGenerationMethodDropDown matlab.ui.control.DropDown
        GenWidthField               matlab.ui.control.NumericEditField
        GenHeightField              matlab.ui.control.NumericEditField
        GenRegularityField          matlab.ui.control.NumericEditField
        GenContrastField            matlab.ui.control.NumericEditField
        GenGranularityField         matlab.ui.control.NumericEditField
        GenerateTextureButton       matlab.ui.control.Button

        HighLevelTab                matlab.ui.container.Tab
        HighLevelGrid               matlab.ui.container.GridLayout
        HighLevelModeDropDown       matlab.ui.control.DropDown
        HighLevelAlphaField         matlab.ui.control.NumericEditField
        HighLevelApplyButton        matlab.ui.control.Button

        ClassificationTab           matlab.ui.container.Tab
        ClassificationGrid          matlab.ui.container.GridLayout
        DatasetPathField            matlab.ui.control.EditField
        BrowseDatasetButton         matlab.ui.control.Button
        FeatureMethodDropDown       matlab.ui.control.DropDown
        ClassifierDropDown          matlab.ui.control.DropDown
        HoldOutField                matlab.ui.control.NumericEditField
        TrainClassifierButton       matlab.ui.control.Button
        TestClassifierButton        matlab.ui.control.Button
        PredictImageButton          matlab.ui.control.Button
        ClassificationTable         matlab.ui.control.Table

        StegoTab                    matlab.ui.container.Tab
        StegoGrid                   matlab.ui.container.GridLayout
        SecretMessageArea           matlab.ui.control.TextArea
        StegoKeyField               matlab.ui.control.EditField
        EncodeStegoButton           matlab.ui.control.Button
        DecodeStegoButton           matlab.ui.control.Button
        CapacityLabel               matlab.ui.control.Label
        StegoMetricsArea            matlab.ui.control.TextArea

        CompareTab                  matlab.ui.container.Tab
        CompareGrid                 matlab.ui.container.GridLayout
        ExportCSVButton             matlab.ui.control.Button
        ExportReportButton          matlab.ui.control.Button
        CompareMetricsTable         matlab.ui.control.Table

        HelpTab                     matlab.ui.container.Tab
        HelpTextArea                matlab.ui.control.TextArea

        LogPanel                    matlab.ui.container.Panel
        LogTextArea                 matlab.ui.control.TextArea
    end

    %% Propriétés de données de l'application
    properties (Access = private)
        OriginalImage               % image originale chargée
        CurrentImage                % image courante affichée / traitée
        ResultImage                 % image résultat courante
        HistogramData               % structure histogrammes
        TextureResults              % structure résultats texture
        DatasetInfo                 % structure dataset
        FeaturesMatrix              % matrice des caractéristiques
        FeatureLabels               % labels de la matrice de caractéristiques
        ClassifierModel             % modèle entraîné
        ClassificationResults       % structure métriques classification
        HiddenMessage char = ''     % dernier message secret
        StegoImage                  % image stéganographiée
        Logs cell                   % historique de logs
        CurrentParams struct        % paramètres courants
    end

    methods (Access = private)

        function startupFcn(app)
            rootFolder = fileparts(mfilename('fullpath'));
            addpath(genpath(rootFolder));

            app.Logs = {};
            app.CurrentParams = struct();
            app.StatusLabel.Text = 'Prêt';
            app.HomeTextArea.Value = {
                'Bienvenue dans ImageLab Edu.'
                'Workflow conseillé :'
                '1) Charger une image'
                '2) Prétraiter'
                '3) Analyser la texture'
                '4) Générer / classifier / comparer'
                '5) Exporter les résultats'
            };
            app.HelpTextArea.Value = {
                'Aide intégrée ImageLab Edu'
                ' '
                'Prétraitement : améliore ou simplifie l''image avant analyse.'
                'Texture : mesure l''organisation locale des intensités.'
                'Classification : apprend à distinguer des classes à partir de descripteurs.'
                'Stéganographie : cache un texte dans les bits de poids faible d''une image.'
                ' '
                'Conseil pédagogique : comparer les résultats avant/après chaque opération.'
            };
            app.logMessage('Application initialisée.');
        end

        function logMessage(app, msg)
            timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
            fullMsg = sprintf('[%s] %s', timestamp, msg);
            app.Logs{end+1} = fullMsg;
            app.LogTextArea.Value = app.Logs(:);
            drawnow limitrate;
        end

        function updateDisplays(app)
            cla(app.UIAxesOriginal);
            cla(app.UIAxesResult);

            if ~isempty(app.OriginalImage)
                showImageOnAxes(app.UIAxesOriginal, app.OriginalImage, 'Image originale');
            end
            if ~isempty(app.CurrentImage)
                showImageOnAxes(app.UIAxesResult, app.CurrentImage, 'Image courante');
            elseif ~isempty(app.ResultImage)
                showImageOnAxes(app.UIAxesResult, app.ResultImage, 'Image résultat');
            end
        end

        function ensureImageLoaded(app)
            if isempty(app.CurrentImage)
                error('Aucune image n''est chargée.');
            end
        end

        function setCurrentAsResult(app, img, labelMsg)
            app.ResultImage = img;
            app.CurrentImage = img;
            app.updateDisplays();
            if nargin >= 3
                app.logMessage(labelMsg);
            end
        end

        %% Callbacks généraux
        function onLoadImage(app, ~)
            try
                [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff','Images'}, 'Choisir une image');
                if isequal(file,0)
                    return;
                end
                img = imread(fullfile(path, file));
                app.OriginalImage = img;
                app.CurrentImage = img;
                app.ResultImage = img;
                app.HistogramData = computeHistogramLocal(img);
                app.StatusLabel.Text = sprintf('Image chargée : %s', file);
                app.logMessage(sprintf('Image chargée : %s', fullfile(path,file)));
                app.updateDisplays();
                app.updateCapacityLabel();
            catch ME
                app.handleError(ME, 'Erreur lors du chargement de l''image');
            end
        end

        function onSaveImage(app, ~)
            try
                app.ensureImageLoaded();
                [file, path] = uiputfile({'*.png','PNG';'*.jpg','JPG';'*.bmp','BMP';'*.tif','TIFF'}, 'Enregistrer l''image');
                if isequal(file,0)
                    return;
                end
                imwrite(toUint8Image(app.CurrentImage), fullfile(path,file));
                app.logMessage(sprintf('Image enregistrée : %s', fullfile(path,file)));
            catch ME
                app.handleError(ME, 'Erreur lors de l''enregistrement de l''image');
            end
        end

        function onReset(app, ~)
            app.CurrentImage = app.OriginalImage;
            app.ResultImage = app.OriginalImage;
            app.TextureResults = [];
            app.StegoImage = [];
            app.updateDisplays();
            app.logMessage('Réinitialisation vers l''image originale.');
        end

        function onShowHistogram(app, ~)
            try
                app.ensureImageLoaded();
                H = computeHistogramLocal(app.CurrentImage);
                app.HistogramData = H;
                cla(app.UIAxesResult);
                if H.isGray
                    bar(app.UIAxesResult, 0:255, H.gray, 'FaceColor', [0.2 0.2 0.2]);
                    title(app.UIAxesResult, 'Histogramme gris');
                    xlabel(app.UIAxesResult, 'Niveau');
                    ylabel(app.UIAxesResult, 'Fréquence');
                else
                    plot(app.UIAxesResult, 0:255, H.red, 'r', 0:255, H.green, 'g', 0:255, H.blue, 'b');
                    grid(app.UIAxesResult, 'on');
                    title(app.UIAxesResult, 'Histogrammes RGB');
                    xlabel(app.UIAxesResult, 'Niveau');
                    ylabel(app.UIAxesResult, 'Fréquence');
                    legend(app.UIAxesResult, {'R','G','B'});
                end
                app.logMessage('Histogramme affiché.');
            catch ME
                app.handleError(ME, 'Erreur lors de l''affichage de l''histogramme');
            end
        end

        function onConvertGray(app, ~)
            try
                app.ensureImageLoaded();
                imgGray = safeIm2Gray(app.CurrentImage);
                app.setCurrentAsResult(imgGray, 'Conversion en niveaux de gris effectuée.');
            catch ME
                app.handleError(ME, 'Erreur de conversion en niveaux de gris');
            end
        end

        %% Prétraitement
        function onApplyPreprocessing(app, ~)
            try
                app.ensureImageLoaded();
                params = struct();
                params.param1 = app.PreprocessParam1Field.Value;
                params.param2 = app.PreprocessParam2Field.Value;
                params.operation = app.PreprocessOperationDropDown.Value;
                out = preprocessImage(app.CurrentImage, params);
                app.CurrentParams.preprocess = params;
                app.setCurrentAsResult(out, ['Prétraitement appliqué : ' params.operation]);
            catch ME
                app.handleError(ME, 'Erreur pendant le prétraitement');
            end
        end

        %% Analyse de texture
        function onAnalyzeTexture(app, ~)
            try
                app.ensureImageLoaded();
                params = struct();
                params.methods = app.TextureMethodListBox.Value;
                params.grayLevels = app.GrayLevelsSpinner.Value;
                params.distance = app.GLCMDistanceSpinner.Value;
                params.direction = app.GLCMDirectionDropDown.Value;

                results = computeTextureFeatures(app.CurrentImage, params);
                app.TextureResults = results;

                % Conversion de la structure vers un tableau pour uitable
                names = fieldnames(results.scalarFeatures);
                values = struct2cell(results.scalarFeatures);
                T = table(names, values, 'VariableNames', {'Mesure','Valeur'});
                app.TextureTable.Data = T;

                app.logMessage('Analyse de texture terminée.');
            catch ME
                app.handleError(ME, 'Erreur pendant l''analyse de texture');
            end
        end

        %% Génération de texture
        function onGenerateTexture(app, ~)
            try
                params = struct();
                params.method = app.TextureGenerationMethodDropDown.Value;
                params.width = round(app.GenWidthField.Value);
                params.height = round(app.GenHeightField.Value);
                params.regularity = app.GenRegularityField.Value;
                params.contrast = app.GenContrastField.Value;
                params.granularity = app.GenGranularityField.Value;
                params.exampleImage = [];
                if ~isempty(app.CurrentImage)
                    params.exampleImage = app.CurrentImage;
                end
                out = generateTexture(params);
                app.setCurrentAsResult(out, ['Texture générée : ' params.method]);
            catch ME
                app.handleError(ME, 'Erreur pendant la génération de texture');
            end
        end

        %% Génération haut niveau
        function onHighLevelGenerate(app, ~)
            try
                app.ensureImageLoaded();
                params = struct();
                params.mode = app.HighLevelModeDropDown.Value;
                params.alpha = app.HighLevelAlphaField.Value;
                params.referenceImage = app.OriginalImage;
                out = highLevelGenerate(app.CurrentImage, params);
                app.setCurrentAsResult(out, ['Génération haut niveau : ' params.mode]);
            catch ME
                app.handleError(ME, 'Erreur pendant la génération haut niveau');
            end
        end

        %% Classification
        function onBrowseDataset(app, ~)
            folder = uigetdir(pwd, 'Choisir le dossier dataset');
            if isequal(folder,0)
                return;
            end
            app.DatasetPathField.Value = folder;
            app.logMessage(['Dataset sélectionné : ' folder]);
        end

        function onTrainClassifier(app, ~)
            try
                datasetPath = strtrim(app.DatasetPathField.Value);
                if isempty(datasetPath) || ~isfolder(datasetPath)
                    error('Sélectionner un dossier dataset valide.');
                end
                ds = loadDatasetFromFolder(datasetPath);
                app.DatasetInfo = ds;

                params = struct();
                params.featureMethod = app.FeatureMethodDropDown.Value;
                params.classifierName = app.ClassifierDropDown.Value;
                params.holdOut = app.HoldOutField.Value;
                params.randomSeed = 42;

                [model, results] = trainImageClassifier(ds, params);
                app.ClassifierModel = model;
                app.ClassificationResults = results;
                app.FeaturesMatrix = results.X;
                app.FeatureLabels = results.Y;
                scalarMetrics = app.scalarMetricsStruct(results.metrics);
                app.ClassificationTable.Data = struct2table(scalarMetrics, 'AsArray', true);
                app.CompareMetricsTable.Data = struct2table(scalarMetrics, 'AsArray', true);
                app.logMessage('Entraînement de classification terminé.');
            catch ME
                app.handleError(ME, 'Erreur pendant l''entraînement du classifieur');
            end
        end

        function onTestClassifier(app, ~)
            try
                if isempty(app.ClassificationResults)
                    error('Aucun modèle entraîné.');
                end
                metrics = app.scalarMetricsStruct(app.ClassificationResults.metrics);
                app.ClassificationTable.Data = struct2table(metrics, 'AsArray', true);
                app.CompareMetricsTable.Data = struct2table(metrics, 'AsArray', true);
                app.logMessage('Affichage des métriques de test.');
            catch ME
                app.handleError(ME, 'Erreur pendant le test du classifieur');
            end
        end

        function onPredictNewImage(app, ~)
            try
                if isempty(app.ClassifierModel)
                    error('Aucun modèle entraîné.');
                end
                [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff','Images'}, 'Choisir une image à prédire');
                if isequal(file,0)
                    return;
                end
                img = imread(fullfile(path, file));
                params = struct('featureMethod', app.FeatureMethodDropDown.Value);
                [label, score] = predictImageClassifier(app.ClassifierModel, img, params);
                app.logMessage(sprintf('Prédiction : %s | Score max = %.4f', string(label), max(score)));
                uialert(app.UIFigure, sprintf('Classe prédite : %s', string(label)), 'Prédiction');
            catch ME
                app.handleError(ME, 'Erreur pendant la prédiction');
            end
        end

        %% Stéganographie
        function updateCapacityLabel(app)
            if isempty(app.CurrentImage)
                app.CapacityLabel.Text = 'Capacité : 0 caractères';
                return;
            end
            img = toUint8Image(app.CurrentImage);
            nBits = numel(img);
            capBytes = floor(nBits/8) - 4; % 4 octets pour la longueur
            capChars = max(capBytes, 0);
            app.CapacityLabel.Text = sprintf('Capacité approx. : %d caractères ASCII', capChars);
        end

        function onEncodeStego(app, ~)
            try
                app.ensureImageLoaded();
                msg = strjoin(app.SecretMessageArea.Value, newline);
                key = app.StegoKeyField.Value;
                [stego, info] = lsbEmbedText(app.CurrentImage, msg, key);
                app.StegoImage = stego;
                app.HiddenMessage = msg;
                app.CurrentImage = stego;
                app.updateDisplays();
                app.updateCapacityLabel();
                app.StegoMetricsArea.Value = {
                    sprintf('Longueur message : %d caractères', info.messageLength)
                    sprintf('Capacité max : %d caractères', info.maxChars)
                    sprintf('PSNR : %.4f dB', info.psnr)
                    sprintf('SSIM : %.6f', info.ssim)
                };
                app.CompareMetricsTable.Data = table(info.psnr, info.ssim, 'VariableNames', {'PSNR','SSIM'});
                app.logMessage('Encodage stéganographique terminé.');
            catch ME
                app.handleError(ME, 'Erreur pendant l''encodage stéganographique');
            end
        end

        function onDecodeStego(app, ~)
            try
                app.ensureImageLoaded();
                key = app.StegoKeyField.Value;
                [msg, info] = lsbExtractText(app.CurrentImage, key);
                app.SecretMessageArea.Value = splitlines(string(msg));
                app.StegoMetricsArea.Value = {
                    sprintf('Message décodé (%d caractères)', strlength(string(msg)))
                    sprintf('Longueur binaire décodée : %d octets', info.messageLength)
                };
                app.logMessage('Décodage stéganographique terminé.');
            catch ME
                app.handleError(ME, 'Erreur pendant le décodage stéganographique');
            end
        end

        %% Export
        function onExportCSV(app, ~)
            try
                if isempty(app.TextureResults) && isempty(app.ClassificationResults)
                    error('Aucun résultat à exporter.');
                end
                [file, path] = uiputfile('*.csv', 'Exporter les résultats en CSV');
                if isequal(file,0)
                    return;
                end
                payload = struct();
                payload.texture = app.TextureResults;
                payload.classification = app.ClassificationResults;
                exportResultsCSV(fullfile(path,file), payload);
                app.logMessage('Résultats exportés en CSV.');
            catch ME
                app.handleError(ME, 'Erreur pendant l''export CSV');
            end
        end

        function onExportReport(app, ~)
            try
                [file, path] = uiputfile('*.txt', 'Exporter un rapport texte');
                if isequal(file,0)
                    return;
                end
                payload = struct();
                payload.logs = app.Logs;
                payload.texture = app.TextureResults;
                payload.classification = app.ClassificationResults;
                payload.params = app.CurrentParams;
                exportSessionReportTXT(fullfile(path,file), payload);
                app.logMessage('Rapport texte exporté.');
            catch ME
                app.handleError(ME, 'Erreur pendant l''export du rapport');
            end
        end

        %% Gestion centralisée des erreurs
        function handleError(app, ME, titleMsg)
            app.logMessage([titleMsg ' : ' ME.message]);
            uialert(app.UIFigure, ME.message, titleMsg, 'Icon', 'error');
        end

        function S = scalarMetricsStruct(app, metrics) %#ok<INUSD>
            S = struct();
            fields = fieldnames(metrics);
            for k = 1:numel(fields)
                val = metrics.(fields{k});
                if isnumeric(val) && isscalar(val)
                    S.(fields{k}) = val;
                end
            end
        end

        %% Création des composants
        function createComponents(app)
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1600 900];
            app.UIFigure.Name = 'ImageLab Edu';

            app.MainGrid = uigridlayout(app.UIFigure, [2 1]);
            app.MainGrid.RowHeight = {'1x', 150};
            app.MainGrid.ColumnWidth = {'1x'};

            app.TopGrid = uigridlayout(app.MainGrid, [1 3]);
            app.TopGrid.Layout.Row = 1;
            app.TopGrid.ColumnWidth = {250, '1x', 450};

            % Colonne gauche : actions globales
            app.ControlPanel = uipanel(app.TopGrid, 'Title', 'Actions globales');
            app.ControlPanel.Layout.Column = 1;
            app.ActionGrid = uigridlayout(app.ControlPanel, [8 1]);
            app.ActionGrid.RowHeight = {35,35,35,35,35,35,'1x',30};

            app.LoadButton = uibutton(app.ActionGrid, 'push', 'Text', 'Charger une image', 'ButtonPushedFcn', @(src,event)onLoadImage(app,event));
            app.SaveButton = uibutton(app.ActionGrid, 'push', 'Text', 'Sauvegarder l''image', 'ButtonPushedFcn', @(src,event)onSaveImage(app,event));
            app.ResetButton = uibutton(app.ActionGrid, 'push', 'Text', 'Réinitialiser', 'ButtonPushedFcn', @(src,event)onReset(app,event));
            app.HistogramButton = uibutton(app.ActionGrid, 'push', 'Text', 'Afficher histogramme', 'ButtonPushedFcn', @(src,event)onShowHistogram(app,event));
            app.GrayButton = uibutton(app.ActionGrid, 'push', 'Text', 'Convertir en gris', 'ButtonPushedFcn', @(src,event)onConvertGray(app,event));
            app.StatusLabel = uilabel(app.ActionGrid, 'Text', 'Prêt');

            % Colonne centrale : affichage images
            app.DisplayPanel = uipanel(app.TopGrid, 'Title', 'Affichage');
            app.DisplayPanel.Layout.Column = 2;
            app.DisplayGrid = uigridlayout(app.DisplayPanel, [1 2]);
            app.DisplayGrid.ColumnWidth = {'1x','1x'};

            app.UIAxesOriginal = uiaxes(app.DisplayGrid);
            title(app.UIAxesOriginal, 'Originale');
            axis(app.UIAxesOriginal, 'image');
            app.UIAxesOriginal.Layout.Column = 1;

            app.UIAxesResult = uiaxes(app.DisplayGrid);
            title(app.UIAxesResult, 'Résultat');
            axis(app.UIAxesResult, 'image');
            app.UIAxesResult.Layout.Column = 2;

            % Colonne droite : onglets fonctionnels
            app.RightPanel = uipanel(app.TopGrid, 'Title', 'Modules');
            app.RightPanel.Layout.Column = 3;
            app.TabGroup = uitabgroup(app.RightPanel, 'Position', [1 1 448 625]);

            % Accueil
            app.HomeTab = uitab(app.TabGroup, 'Title', 'Accueil');
            app.HomeTextArea = uitextarea(app.HomeTab, 'Position', [10 10 420 560], 'Editable', 'off');

            % Prétraitement
            app.PreprocessTab = uitab(app.TabGroup, 'Title', 'Prétraitement');
            app.PreprocessGrid = uigridlayout(app.PreprocessTab, [6 2]);
            app.PreprocessGrid.RowHeight = {30,30,30,30,40,'1x'};
            uilabel(app.PreprocessGrid, 'Text', 'Opération');
            app.PreprocessOperationDropDown = uidropdown(app.PreprocessGrid, 'Items', {
                'Redimensionnement','Normalisation','Contraste','Égalisation histogramme',...
                'Filtre moyenneur','Filtre médian','Filtre gaussien','Contours',...
                'Seuillage','Morphologie - dilatation','Morphologie - érosion',...
                'Morphologie - ouverture','Morphologie - fermeture'});
            app.PreprocessOperationDropDown.Layout.Row = 1; app.PreprocessOperationDropDown.Layout.Column = 2;
            app.PreprocessParam1Label = uilabel(app.PreprocessGrid, 'Text', 'Paramètre 1');
            app.PreprocessParam1Label.Layout.Row = 2;
            app.PreprocessParam1Field = uieditfield(app.PreprocessGrid, 'numeric', 'Value', 3);
            app.PreprocessParam1Field.Layout.Row = 2; app.PreprocessParam1Field.Layout.Column = 2;
            app.PreprocessParam2Label = uilabel(app.PreprocessGrid, 'Text', 'Paramètre 2');
            app.PreprocessParam2Label.Layout.Row = 3;
            app.PreprocessParam2Field = uieditfield(app.PreprocessGrid, 'numeric', 'Value', 1);
            app.PreprocessParam2Field.Layout.Row = 3; app.PreprocessParam2Field.Layout.Column = 2;
            app.PreprocessApplyButton = uibutton(app.PreprocessGrid, 'push', 'Text', 'Appliquer', 'ButtonPushedFcn', @(src,event)onApplyPreprocessing(app,event));
            app.PreprocessApplyButton.Layout.Row = 5; app.PreprocessApplyButton.Layout.Column = [1 2];

            % Texture
            app.TextureTab = uitab(app.TabGroup, 'Title', 'Analyse de texture');
            app.TextureGrid = uigridlayout(app.TextureTab, [6 2]);
            app.TextureGrid.RowHeight = {100,30,30,30,40,'1x'};
            uilabel(app.TextureGrid, 'Text', 'Méthodes');
            app.TextureMethodListBox = uilistbox(app.TextureGrid, 'Items', {'Statistiques','GLCM','LBP','Gabor','Fourier','Laws','Wavelet'}, 'Multiselect', 'on', 'Value', {'Statistiques','GLCM'});
            app.TextureMethodListBox.Layout.Row = 1; app.TextureMethodListBox.Layout.Column = 2;
            uilabel(app.TextureGrid, 'Text', 'Niveaux de gris');
            app.GrayLevelsSpinner = uispinner(app.TextureGrid, 'Limits', [4 256], 'Value', 16, 'Step', 1);
            app.GrayLevelsSpinner.Layout.Row = 2; app.GrayLevelsSpinner.Layout.Column = 2;
            uilabel(app.TextureGrid, 'Text', 'Distance GLCM');
            app.GLCMDistanceSpinner = uispinner(app.TextureGrid, 'Limits', [1 20], 'Value', 1, 'Step', 1);
            app.GLCMDistanceSpinner.Layout.Row = 3; app.GLCMDistanceSpinner.Layout.Column = 2;
            uilabel(app.TextureGrid, 'Text', 'Direction GLCM');
            app.GLCMDirectionDropDown = uidropdown(app.TextureGrid, 'Items', {'0','45','90','135'}, 'Value', '0');
            app.GLCMDirectionDropDown.Layout.Row = 4; app.GLCMDirectionDropDown.Layout.Column = 2;
            app.TextureAnalyzeButton = uibutton(app.TextureGrid, 'push', 'Text', 'Analyser', 'ButtonPushedFcn', @(src,event)onAnalyzeTexture(app,event));
            app.TextureAnalyzeButton.Layout.Row = 5; app.TextureAnalyzeButton.Layout.Column = [1 2];
            app.TextureTable = uitable(app.TextureGrid);
            app.TextureTable.Layout.Row = 6; app.TextureTable.Layout.Column = [1 2];

            % Génération texture
            app.GenerationTab = uitab(app.TabGroup, 'Title', 'Génération de texture');
            app.GenerationGrid = uigridlayout(app.GenerationTab, [7 2]);
            app.GenerationGrid.RowHeight = {30,30,30,30,30,30,'1x'};
            uilabel(app.GenerationGrid, 'Text', 'Méthode');
            app.TextureGenerationMethodDropDown = uidropdown(app.GenerationGrid, 'Items', {'Aléatoire','Périodique','Paramétrique','Par exemple','Par patchs'}, 'Value', 'Aléatoire');
            app.TextureGenerationMethodDropDown.Layout.Row = 1; app.TextureGenerationMethodDropDown.Layout.Column = 2;
            uilabel(app.GenerationGrid, 'Text', 'Largeur');
            app.GenWidthField = uieditfield(app.GenerationGrid, 'numeric', 'Value', 256);
            app.GenWidthField.Layout.Row = 2; app.GenWidthField.Layout.Column = 2;
            uilabel(app.GenerationGrid, 'Text', 'Hauteur');
            app.GenHeightField = uieditfield(app.GenerationGrid, 'numeric', 'Value', 256);
            app.GenHeightField.Layout.Row = 3; app.GenHeightField.Layout.Column = 2;
            uilabel(app.GenerationGrid, 'Text', 'Régularité [0..1]');
            app.GenRegularityField = uieditfield(app.GenerationGrid, 'numeric', 'Value', 0.5);
            app.GenRegularityField.Layout.Row = 4; app.GenRegularityField.Layout.Column = 2;
            uilabel(app.GenerationGrid, 'Text', 'Contraste [0..2]');
            app.GenContrastField = uieditfield(app.GenerationGrid, 'numeric', 'Value', 1.0);
            app.GenContrastField.Layout.Row = 5; app.GenContrastField.Layout.Column = 2;
            uilabel(app.GenerationGrid, 'Text', 'Granularité');
            app.GenGranularityField = uieditfield(app.GenerationGrid, 'numeric', 'Value', 8);
            app.GenGranularityField.Layout.Row = 6; app.GenGranularityField.Layout.Column = 2;
            app.GenerateTextureButton = uibutton(app.GenerationGrid, 'push', 'Text', 'Générer', 'ButtonPushedFcn', @(src,event)onGenerateTexture(app,event));
            app.GenerateTextureButton.Layout.Row = 7; app.GenerateTextureButton.Layout.Column = [1 2];

            % Haut niveau
            app.HighLevelTab = uitab(app.TabGroup, 'Title', 'Génération haut niveau');
            app.HighLevelGrid = uigridlayout(app.HighLevelTab, [3 2]);
            uilabel(app.HighLevelGrid, 'Text', 'Mode');
            app.HighLevelModeDropDown = uidropdown(app.HighLevelGrid, 'Items', {'Stylisation simple','Transfert histogramme','Fusion texture-référence','Accentuation fréquentielle'}, 'Value', 'Stylisation simple');
            app.HighLevelModeDropDown.Layout.Row = 1; app.HighLevelModeDropDown.Layout.Column = 2;
            uilabel(app.HighLevelGrid, 'Text', 'Alpha [0..1]');
            app.HighLevelAlphaField = uieditfield(app.HighLevelGrid, 'numeric', 'Value', 0.5);
            app.HighLevelAlphaField.Layout.Row = 2; app.HighLevelAlphaField.Layout.Column = 2;
            app.HighLevelApplyButton = uibutton(app.HighLevelGrid, 'push', 'Text', 'Appliquer', 'ButtonPushedFcn', @(src,event)onHighLevelGenerate(app,event));
            app.HighLevelApplyButton.Layout.Row = 3; app.HighLevelApplyButton.Layout.Column = [1 2];

            % Classification
            app.ClassificationTab = uitab(app.TabGroup, 'Title', 'Classification');
            app.ClassificationGrid = uigridlayout(app.ClassificationTab, [8 2]);
            app.ClassificationGrid.RowHeight = {30,30,30,30,35,35,35,'1x'};
            uilabel(app.ClassificationGrid, 'Text', 'Dossier dataset');
            app.DatasetPathField = uieditfield(app.ClassificationGrid, 'text');
            app.DatasetPathField.Layout.Row = 1; app.DatasetPathField.Layout.Column = 2;
            app.BrowseDatasetButton = uibutton(app.ClassificationGrid, 'push', 'Text', 'Parcourir', 'ButtonPushedFcn', @(src,event)onBrowseDataset(app,event));
            app.BrowseDatasetButton.Layout.Row = 2; app.BrowseDatasetButton.Layout.Column = [1 2];
            uilabel(app.ClassificationGrid, 'Text', 'Descripteurs');
            app.FeatureMethodDropDown = uidropdown(app.ClassificationGrid, 'Items', {'stats+glcm','lbp','gabor','fusion'}, 'Value', 'fusion');
            app.FeatureMethodDropDown.Layout.Row = 3; app.FeatureMethodDropDown.Layout.Column = 2;
            uilabel(app.ClassificationGrid, 'Text', 'Classifieur');
            app.ClassifierDropDown = uidropdown(app.ClassificationGrid, 'Items', {'knn','svm-ecoc','arbre','random-forest','knn-manuel'}, 'Value', 'knn');
            app.ClassifierDropDown.Layout.Row = 4; app.ClassifierDropDown.Layout.Column = 2;
            uilabel(app.ClassificationGrid, 'Text', 'Hold-out test [0..1]');
            app.HoldOutField = uieditfield(app.ClassificationGrid, 'numeric', 'Value', 0.3);
            app.HoldOutField.Layout.Row = 5; app.HoldOutField.Layout.Column = 2;
            app.TrainClassifierButton = uibutton(app.ClassificationGrid, 'push', 'Text', 'Entraîner', 'ButtonPushedFcn', @(src,event)onTrainClassifier(app,event));
            app.TrainClassifierButton.Layout.Row = 6; app.TrainClassifierButton.Layout.Column = 1;
            app.TestClassifierButton = uibutton(app.ClassificationGrid, 'push', 'Text', 'Tester', 'ButtonPushedFcn', @(src,event)onTestClassifier(app,event));
            app.TestClassifierButton.Layout.Row = 6; app.TestClassifierButton.Layout.Column = 2;
            app.PredictImageButton = uibutton(app.ClassificationGrid, 'push', 'Text', 'Prédire une image', 'ButtonPushedFcn', @(src,event)onPredictNewImage(app,event));
            app.PredictImageButton.Layout.Row = 7; app.PredictImageButton.Layout.Column = [1 2];
            app.ClassificationTable = uitable(app.ClassificationGrid);
            app.ClassificationTable.Layout.Row = 8; app.ClassificationTable.Layout.Column = [1 2];

            % Stéganographie
            app.StegoTab = uitab(app.TabGroup, 'Title', 'Stéganographie');
            app.StegoGrid = uigridlayout(app.StegoTab, [6 2]);
            app.StegoGrid.RowHeight = {120,30,35,35,35,'1x'};
            uilabel(app.StegoGrid, 'Text', 'Texte secret');
            app.SecretMessageArea = uitextarea(app.StegoGrid);
            app.SecretMessageArea.Layout.Row = 1; app.SecretMessageArea.Layout.Column = 2;
            uilabel(app.StegoGrid, 'Text', 'Clé XOR (facultative)');
            app.StegoKeyField = uieditfield(app.StegoGrid, 'text');
            app.StegoKeyField.Layout.Row = 2; app.StegoKeyField.Layout.Column = 2;
            app.EncodeStegoButton = uibutton(app.StegoGrid, 'push', 'Text', 'Encoder', 'ButtonPushedFcn', @(src,event)onEncodeStego(app,event));
            app.EncodeStegoButton.Layout.Row = 3; app.EncodeStegoButton.Layout.Column = [1 2];
            app.DecodeStegoButton = uibutton(app.StegoGrid, 'push', 'Text', 'Décoder', 'ButtonPushedFcn', @(src,event)onDecodeStego(app,event));
            app.DecodeStegoButton.Layout.Row = 4; app.DecodeStegoButton.Layout.Column = [1 2];
            app.CapacityLabel = uilabel(app.StegoGrid, 'Text', 'Capacité : 0 caractères');
            app.CapacityLabel.Layout.Row = 5; app.CapacityLabel.Layout.Column = [1 2];
            app.StegoMetricsArea = uitextarea(app.StegoGrid, 'Editable', 'off');
            app.StegoMetricsArea.Layout.Row = 6; app.StegoMetricsArea.Layout.Column = [1 2];

            % Comparaison / export
            app.CompareTab = uitab(app.TabGroup, 'Title', 'Comparaison / Export');
            app.CompareGrid = uigridlayout(app.CompareTab, [3 2]);
            app.CompareGrid.RowHeight = {35,35,'1x'};
            app.ExportCSVButton = uibutton(app.CompareGrid, 'push', 'Text', 'Exporter CSV', 'ButtonPushedFcn', @(src,event)onExportCSV(app,event));
            app.ExportCSVButton.Layout.Row = 1; app.ExportCSVButton.Layout.Column = 1;
            app.ExportReportButton = uibutton(app.CompareGrid, 'push', 'Text', 'Exporter rapport', 'ButtonPushedFcn', @(src,event)onExportReport(app,event));
            app.ExportReportButton.Layout.Row = 1; app.ExportReportButton.Layout.Column = 2;
            app.CompareMetricsTable = uitable(app.CompareGrid);
            app.CompareMetricsTable.Layout.Row = 3; app.CompareMetricsTable.Layout.Column = [1 2];

            % Aide
            app.HelpTab = uitab(app.TabGroup, 'Title', 'Aide');
            app.HelpTextArea = uitextarea(app.HelpTab, 'Position', [10 10 420 560], 'Editable', 'off');

            % Log
            app.LogPanel = uipanel(app.MainGrid, 'Title', 'Journal / Console');
            app.LogPanel.Layout.Row = 2;
            app.LogTextArea = uitextarea(app.LogPanel, 'Position', [10 10 1560 105], 'Editable', 'off');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)
        function app = ImageLabEduApp
            createComponents(app)
            registerApp(app, app.UIFigure)
            runStartupFcn(app, @(app)startupFcn(app))
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
