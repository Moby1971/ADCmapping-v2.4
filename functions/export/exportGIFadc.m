function exportGIFadc(app, gifExportpath)

% Exports ADCmaps, M0maps, and r^2 maps to animated gif

ADCmap = app.adcmap;
M0map = app.m0map;
R2map = app.r2map;
tag = app.tag;
ADCMapScale = app.ADCScaleEditField.Value;
ADCcmap = app.adccmap;
m0cmap = app.m0cmap;
r2cmap = app.r2cmap;
aspectRatio = app.aspectRatio;
rSquare = app.Rsquare.Value;

if ~exist(gifExportpath, 'dir')
    mkdir(gifExportpath); 
end

[numberOfImages,dimX,dimY] = size(ADCmap);


% increase the size of the matrix to make the exported images bigger
numRows = 2*dimX;
numCols = 2*round(dimY*aspectRatio);

delay_time = 2/numberOfImages;  % show all gifs in 2 seconds


% Export the ADC maps to gifs

for idx = 1:numberOfImages
    
    image = rot90(uint8(round((255/ADCMapScale)*imresize(squeeze(ADCmap(idx,:,:)),[numRows numCols]))));
    
    if idx == 1
        imwrite(image,ADCcmap,strcat(gifExportpath,filesep,'ADCmap-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(image,ADCcmap,strcat(gifExportpath,filesep,'ADCmap-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
    end
end
        

% Export the M0 maps to GIF

for idx = 1:numberOfImages
    
    % determine a convenient scale to display M0 maps (same as in the app)
    m0scale = round(2*mean(nonzeros(squeeze(M0map(idx,:,:)))));
    m0scale(isnan(m0scale)) = 100;
    m0scale(m0scale<1) = 1;
    
    % automatic grayscale mapping is used for the gif export
    % the m0map therefore needs to be mapped onto the range of [0 255]
    image = rot90(uint8(round((255/m0scale)*imresize(squeeze(M0map(idx,:,:)),[numRows numCols]))));
    
    if idx == 1
        imwrite(image,m0cmap,strcat(gifExportpath,filesep,'M0map-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(image,m0cmap,strcat(gifExportpath,filesep,'M0map-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
    end
end
         

% Rescale r2 map from rsquare..1 range to 0..1 

R2map = R2map - rSquare;
R2map(R2map<0) = 0;
R2map = R2map*(1/(1-rSquare));

% Export the R2 maps to GIF

for idx = 1:numberOfImages
    
    % scale R-square map from 0 - 100
    r2scale = 100;

    image = rot90(uint8(round((255/r2scale)*imresize(squeeze(100*R2map(idx,:,:)),[numRows numCols]))));
    
    if idx == 1
        imwrite(image,r2cmap,strcat(gifExportpath,filesep,'R2map-',tag,'.gif'),'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(image,r2cmap,strcat(gifExportpath,filesep,'R2map-',tag,'.gif'),'WriteMode','append','DelayTime',delay_time);
    end
end



end                 