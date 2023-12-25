function [m0map,ADCmap,r2map] = dotheADCfit(app,imagesIn,mask)


% -----------------------
% Performs the ADC map fitting for 1 slice
%
% Gustav Strijkers
% 25 Dec 2023
% -----------------------


% Threshold and R-square
threshold = app.Threshold.Value;
rSquare = app.Rsquare.Value;


% Dimensions of the data
[~,dimx,dimy] = size(imagesIn);
m0map = zeros(dimx,dimy);
ADCmap = zeros(dimx,dimy);
r2map = zeros(dimx,dimy);


% B-values
for i = 1:app.nr
    b(i) = app.binfo(1+(i-1)*app.ns).bvalue; %#ok<AGROW>
end


% Drop the bvalues that are deselected in the app
delements = find(app.nrSelection==0);
b(delements) = [];


% Check that remaining b-values are not all the same
if b==b(1)
    ME = MException('ADCmapp:allBvalueSame','ERROR: Fitting needs at least 2 unique b-values ...');
    throw(ME);
end


% Prepare the x-values for fitting
x = [ones(length(b),1),b'];


% Drop the images that are deselected in the app
s = [];
cnt = 1;
for j = 1:length(delements)
    for i = 1:app.ns
        s(cnt) = (delements(j)-1)*app.ns + i; %#ok<AGROW>
        cnt = cnt + 1;
    end
end
imagesIn(delements,:,:) = [];


% for all x-coordinates
parfor j=1:dimx

    % For all y-coordinates
    for k=1:dimy

        % Only fit when mask value indicates valid data point
        if mask(j,k) == 1

            % Pixel value as function of TE
            y = log(squeeze(imagesIn(:,j,k)));

            % Do the linear regression
            b = x\y;

            % Make the maps
            m0map(j,k) = exp(b(1)); %#ok<*PFOUS>
            ADCmap(j,k) = -1000*b(2);

            % R2 map
            yCalc2 = x * b;
            r2map(j,k) = 1 - sum((y - yCalc2).^2)/sum((y - mean(y)).^2)

        end

    end

end


% Some criteria
m0map(isnan(ADCmap)) = 0;
r2map(isnan(ADCmap)) = 0;
ADCmap(isnan(ADCmap)) = 0;
m0map(ADCmap<0) = 0;
r2map(ADCmap<0) = 0;
ADCmap(ADCmap<0) = 0;
m0map(isinf(ADCmap)) = 0;
r2map(isinf(ADCmap)) = 0;
ADCmap(isinf(ADCmap)) = 0;


% R-square
if threshold
    ADCmap(r2map<rSquare) = 0;
    m0map(r2map<rSquare) = 0;
end


% Return the maps
ADCmap = abs(ADCmap);
m0map = abs(m0map);
r2map = abs(r2map);


end