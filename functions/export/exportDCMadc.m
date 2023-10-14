function exportDCMadc(app, folder)

dcmInfo = app.dcmInfo;
adcMap = app.adcmap;
m0Map = app.m0map;
r2Map = app.r2map;


% Create new directory
ready = false;
cnt = 1;
while ~ready
    outputFolder = strcat(folder,filesep,num2str(cnt));
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
        ready = true;
    end
    cnt = cnt + 1;
end


% Number of images
numberOfImages = size(adcMap,1);


% Generate new dicom headers
for i = 1:numberOfImages

    % Read the Dicom header
    dcmHeader(i) = dcmInfo{i}; %#ok<*AGROW>

    % Changes some tags
    dcmHeader(i).ImageType = 'DERIVED\DIFUSION\';
    dcmHeader(i).InstitutionName = 'Amsterdam UMC';
    dcmHeader(i).InstitutionAddress = 'Amsterdam, Netherlands';

end



% Export the ADC map Dicoms
for i=1:numberOfImages

    dcmHeader(i).ProtocolName = 'ADC-map';
    dcmHeader(i).SequenceName = 'ADC-map';
    dcmHeader(i).EchoTime = 1;

    fn = strcat('0000',num2str(i));
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = strcat(outputFolder,filesep,'ADC',fn,'.dcm');
    image = rot90(squeeze(cast(round(1000*adcMap(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcmHeader(i));

end



% Export the M0 map Dicoms
for i=1:numberOfImages

    dcmHeader(i).ProtocolName = 'M0-map';
    dcmHeader(i).SequenceName = 'M0-map';
    dcmHeader(i).EchoTime = 2;

    fn = strcat('0000',num2str(i));
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = strcat(outputFolder,filesep,'M0',fn,'.dcm');
    image = rot90(squeeze(cast(round(m0Map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcmHeader(i));

end



% Export the  R^2 map Dicoms
for i=1:numberOfImages

    dcmHeader(i).ProtocolName = 'R2-map';
    dcmHeader(i).SequenceName = 'R2-map';
    dcmHeader(i).EchoTime = 3;

    fn = strcat('0000',num2str(i));
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = strcat(outputFolder,filesep,'R2',fn,'.dcm');
    image = rot90(squeeze(cast(round(100*r2Map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcmHeader(i));
    
end




end