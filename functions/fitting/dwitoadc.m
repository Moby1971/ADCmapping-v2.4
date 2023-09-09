% 
% CALCULATION OF ADC MAP FROM SERIES OF DWI ACQUISITIONS
%
% Gustav Strijkers / Bram Coolen
% Academic Medical Center (AMC)
% Amsterdam, the Netherlands
% g.j.strijkers@amc.uva.nl / b.f.coolen@amc.uva.nl
%
%
%
% Version: 15 April 2018
%
%
%
%


clearvars;
close all force;


% ---------- input parameters ----------

mrsdir ='3658';

basedir = '/Users/Gustav/Desktop/ADC-mapping/';

dicomdatadir = join([basedir,mrsdir,'/']);
outputdir = join([basedir,mrsdir,'-ADC/']);

if (~exist(outputdir, 'dir')); mkdir(outputdir); end
delete([outputdir,'/*']);

nr_slices = 5;
bvalue = 800;


% ---------- read the data -----------

disp('Reading the dicom files...');
warning('off');
Files=dir([dicomdatadir,'*.dcm']);       % make list of *.dcm files in dicomdatadir
for k = 1:length(Files)
   im{k} = dicomread([dicomdatadir,Files(k).name]);    % load dicom images
   di{k} = dicominfo([dicomdatadir,Files(k).name]);    % load dicom headers
   im{k} = im{k}*di{k}.RescaleSlope + di{k}.RescaleIntercept;   % Intensity-scaled = Intensity*RescaleSlope + RescaleIntercept
end
warning('on');


% ---------- sort the data in slices and diffusion weighted images  -------

nrg = size(im,2)/nr_slices;   % number of diffusion weighted images including b=0
for k = 1:nr_slices
    for j = 1:nrg
        image(k,j,:,:)=double(im{(j-1)*nr_slices+k});   % sort the images
    end
end
[nr_slices, nrg, dimy, dimx] = size(image);


% ---------- determine masks to discard background ---------------

disp('Masking the images...');
for k = 1:nr_slices
    I = mat2gray(squeeze(image(k,1,:,:)));
    level = graythresh(I);
    mask(k,:,:) = imbinarize(I(:,:),0.55*level);
end


% --------- calculate the ADC images --------------------

disp('Calculating ADC values...');
for k = 1:nr_slices
    for j = 1:nrg-1
        adc(k,j,:,:) = -(1/bvalue)*log(image(k,j+1,:,:)./image(k,1,:,:));    % calculate ADC values
        adc(k,j,:,:) = squeeze(adc(k,j,:,:)).*squeeze(mask(k,:,:));         % mask the data
    end
end


% -------- remove division by zero ------

adc(isinf(adc)) = 0;


% ----------- calculate ADC map, remove unrealistic values, and convert to uint16 ----------------

disp('Calculating ADC-maps...');
for k = 1:nr_slices
    ADCmap(k,:,:) = sum(adc(k,:,:,:),2)/(nrg-1);
end
ADCmap = ADCmap*1000000;
ADCmap(ADCmap<0) = 0;
ADCmap(ADCmap>4095) = 0;
ADCmap = uint16(round(ADCmap));


% ----------- export ADC-maps as dicom images ----------------

disp('Scaling of ADC values: 1000 = 1x10ˆ-3 mmˆ2/s');
disp('Export DICOM images...');

for k=1:nr_slices
    dcm_header = di{k};
    dcm_header.ImageType = 'DERIVED\DIFFUSION\';
    dcm_header.PixelAspectRatio = [1 dimy/dimx];
    fn = ['0000',num2str(k)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [outputdir,'adcmap_',fn,'.dcm'];
    dicomwrite(squeeze(ADCmap(k,:,:)), fname, dcm_header);
end




