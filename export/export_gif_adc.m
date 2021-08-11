function export_gif_adc(gifexportpath,ADCmap,m0map,r2map,tag,ADCMapScale,ADCcmap,m0cmap,r2cmap,aspect,rsquare)

% Exports ADCmaps, M0maps, and r^2 maps to animated gif


[number_of_images,dimx,dimy] = size(ADCmap);

% increase the size of the matrix to make the exported images bigger

numrows = 2*dimx;
numcols = 2*round(dimy*aspect);

delay_time = 2/number_of_images;  % show all gifs in 2 seconds


% Export the ADC maps to gifs

for idx = 1:number_of_images
    
    image = rot90(uint8(round((255/ADCMapScale)*resizem(squeeze(ADCmap(idx,:,:)),[numrows numcols]))));
    
    if idx == 1
        imwrite(image,ADCcmap,[gifexportpath,filesep,'ADCmap-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(image,ADCcmap,[gifexportpath,filesep,'ADCmap-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
    end
end
        

% Export the M0 maps to GIF

for idx = 1:number_of_images
    
    % determine a convenient scale to display M0 maps (same as in the app)
    m0scale = round(2*mean(nonzeros(squeeze(m0map(idx,:,:)))));
    m0scale(isnan(m0scale)) = 100;
    m0scale(m0scale<1) = 1;
    
    % automatic grayscale mapping is used for the gif export
    % the m0map therefore needs to be mapped onto the range of [0 255]
    image = rot90(uint8(round((255/m0scale)*resizem(squeeze(m0map(idx,:,:)),[numrows numcols]))));
    
    if idx == 1
        imwrite(image,m0cmap,[gifexportpath,filesep,'M0map-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(image,m0cmap,[gifexportpath,filesep,'M0map-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
    end
end
         

% Rescale r2 map from rsquare..1 range to 0..1 

r2map = r2map - rsquare;
r2map(r2map<0) = 0;
r2map = r2map*(1/(1-rsquare));

% Export the R2 maps to GIF

for idx = 1:number_of_images
    
    % scale R-square map from 0 - 100
    r2scale = 100;

    image = rot90(uint8(round((255/r2scale)*resizem(squeeze(100*r2map(idx,:,:)),[numrows numcols]))));
    
    if idx == 1
        imwrite(image,r2cmap,[gifexportpath,filesep,'R2map-',tag,'.gif'],'DelayTime',delay_time,'LoopCount',inf);
    else
        imwrite(image,r2cmap,[gifexportpath,filesep,'R2map-',tag,'.gif'],'WriteMode','append','DelayTime',delay_time);
    end
end



end                 