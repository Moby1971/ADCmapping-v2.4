function registerImagesBart(app)

% Registration of multi-echo images with Bart
% Gustav Strijkers
% Latest changes: June 2025

imagesIn = app.images;

[dimD,dimZ,dimY,dimX] = size(imagesIn);

imagesIn = imagesIn .* reshape(app.mask, [1, dimZ, dimY, dimX]);

app.TextMessage('Image registration ...');

if app.bartDetectedFlag

    switch app.RegistrationDropDown.Value
        case 'Translation'
            regType = 'T';
        case 'Rigid'
            regType = 'R';
        case 'Affine'
            regType = 'A';
    end
 
    app.TextMessage('Registering images using Bart ...');

    % Timing parameters
    app.EstimatedRegTimeViewField.Value = 'Calculating ...';
    elapsedTime = 0;
    totalNumberOfSteps = dimZ*(dimD-1);
    app.RegProgressGauge.Value = 0;
    app.abortRegFlag = false;
    cnt = 1;

    % Bart dimensions
    % 	READ_DIM,       1   z
    % 	PHS1_DIM,       2   y
    % 	PHS2_DIM,       3   x
    % 	COIL_DIM,       4   coils
    % 	MAPS_DIM,       5   sense maps
    % 	TE_DIM,         6   TIs / TEs
    % 	COEFF_DIM,      7
    % 	COEFF2_DIM,     8
    % 	ITER_DIM,       9
    % 	CSHIFT_DIM,     10
    % 	TIME_DIM,       11  dynamics
    % 	TIME2_DIM,      12
    % 	LEVEL_DIM,      13
    % 	SLICE_DIM,      14  slices
    % 	AVG_DIM,        15

    slice = 0;

    while slice<dimZ && ~app.abortRegFlag

        slice = slice + 1;

        app.TextMessage(strcat("Slice = ",num2str(slice)," ..."));

        diffIm = 1;

        % Reference image
        image0 = squeeze(imagesIn(1,slice,:,:));
        Rin = imref2d(size(image0));

        while diffIm<dimD  && ~app.abortRegFlag

            diffIm = diffIm + 1;

            tic;

            % Moving image
            image1 = squeeze(imagesIn(diffIm,slice,:,:));

            % Register
            if app.GPUpresentFlag
                aff = bart(app,['affinereg -g -',regType],image0,image1);
            else
                aff = bart(app,['affinereg -',regType],image0,image1);
            end
            tr = affinetform2d(aff(1:3,1:3));
            image2 = imwarp(image1,tr,'OutputView',Rin);

            % New registered image
            imagesIn(diffIm,slice,:,:) = image2;

            % Update the registration progress gauge
            app.RegProgressGauge.Value = round(100*(cnt/totalNumberOfSteps));

            % Update the timing indicator
            elapsedTime = elapsedTime + toc;
            estimatedtotaltime = elapsedTime * totalNumberOfSteps / cnt;
            timeRemaining = estimatedtotaltime * (totalNumberOfSteps - cnt) / totalNumberOfSteps;
            timeRemaining(timeRemaining<0) = 0;
            app.EstimatedRegTimeViewField.Value = strcat(datestr(seconds(timeRemaining),'MM:SS')," min:sec"); %#ok<*DATST>
            drawnow;

            cnt = cnt + 1;

        end
        
    end

    app.TextMessage('Finished ... ');
    app.EstimatedRegTimeViewField.Value = 'Finished ...';

else

    % Matlab

    app.TextMessage('Registering images using Matlab ...');

    [optimizer, metric] = imregconfig('multimodal');

    switch app.RegistrationDropDown.Value
        case 'Translation'
            method = 'translation';
        case 'Rigid'
            method = 'rigid';
        case 'Affine'
            method = 'affine';
    end

    % Timing parameters
    app.EstimatedRegTimeViewField.Value = 'Calculating ...';
    elapsedTime = 0;
    totalNumberOfSteps = dimZ*(dimD-1);
    app.RegProgressGauge.Value = 0;
    app.abortRegFlag = false;
    cnt = 1;

    slice = 0;

    while slice<dimZ && ~app.abortRegFlag

        slice = slice + 1;

        app.TextMessage(strcat("Slice = ",num2str(slice)," ..."));

        diffIm = 1;

        while diffIm<dimD  && ~app.abortRegFlag

            diffIm = diffIm + 1;

            tic;

            % Fixed and moving image
            image0 = squeeze(imagesIn(1,slice,:,:));
            image1 = squeeze(imagesIn(diffIm,slice,:,:));

            % Threshold
            threshold = graythresh(mat2gray(image0)) * max(image0(:));
            image0(image0 < threshold) = 0;
            image1(image0 < threshold) = 0;

            % Register
            image2 = imregister(image1,image0,method,optimizer, metric,'DisplayOptimization',0);

            % New registered image
            imagesIn(diffIm,slice,:,:) = image2;

            % Update the registration progress gauge
            app.RegProgressGauge.Value = round(100*(cnt/totalNumberOfSteps));

            % Update the timing indicator
            elapsedTime = elapsedTime + toc;
            estimatedtotaltime = elapsedTime * totalNumberOfSteps / cnt;
            timeRemaining = estimatedtotaltime * (totalNumberOfSteps - cnt) / totalNumberOfSteps;
            timeRemaining(timeRemaining<0) = 0;
            app.EstimatedRegTimeViewField.Value = strcat(datestr(seconds(timeRemaining),'MM:SS')," min:sec"); %#ok<*DATST>
            drawnow;

            cnt = cnt + 1;

        end

    end

    app.TextMessage('Finished ... ');
    app.EstimatedRegTimeViewField.Value = 'Finished ...';

end

% Renormalize
imagesIn = 32767*imagesIn/max(imagesIn(:));

app.images = imagesIn;

end