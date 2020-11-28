function [m0map_out,ADCmap_out,r2map_out] = dotheADCfit_xdim_opt(input_images,mask,nr,ns,binfo,nr_selection,treshold,rsquare)

% performs the ADC map fitting for 1 line

[~,dimx] = size(input_images);
m0map = zeros(dimx,1);
ADCmap = zeros(dimx,1);
r2map = zeros(dimx,1);

for i = 1:nr
    b(i) = binfo(1+(i-1)*ns).bvalue;
end

% drop the bvalues that are deselected in the app
delements = find(nr_selection==0);
b(delements) = [];
x = [ones(length(b),1),b'];

% drop the images that are deselected in the app
s = [];
cnt = 1;
for j = 1:length(delements)
    for i = 1:ns
        s(cnt) = (delements(j)-1)*ns + i;
        cnt = cnt + 1;
    end
end
input_images(delements,:) = [];


parfor j=1:dimx
    % for all x-coordinates
    
    if mask(j) == 1
        % only fit when mask value indicates valid data point
        
        % pixel value as function of TE
        y = log(squeeze(input_images(:,j)));
        
        % do the linear regression
        b = x\y;
        
        % make the maps
        m0map(j) = exp(b(1));
        ADCmap(j) = -1000*b(2);
        
        % R2 map
        yCalc2 = x * b;
        r2map(j) = 1 - sum((y - yCalc2).^2)/sum((y - mean(y)).^2)
        
        if (treshold == 1) && (r2map(j) < rsquare)
            ADCmap(j) = 0;
            m0map(j) = 0;
            r2map(j) = 0;
        end
        
    end
    
end

ADCmap(ADCmap<0) = 0;
ADCmap(isnan(ADCmap)) = 0;
m0map(isnan(m0map)) = 0;
r2map(isnan(r2map)) = 0;

ADCmap_out = ADCmap;
m0map_out = m0map;    
r2map_out = r2map;
    
end