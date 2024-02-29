function exportDCMadc(app, folder)

%------------------------------------------------------------
%
% DICOM EXPORT OF ADC MAPS
% DICOM HEADER INFORMATION AVAILABLE
%
% Gustav Strijkers
% Amsterdam UMC
% g.j.strijkers@amsterdamumc.nl
% Feb 2024
%
%------------------------------------------------------------



dcmInfo = app.dcmInfo;
adcMap = app.adcmap;
m0Map = app.m0map;
r2Map = app.r2map;


% Create new directories
ready = false;
cnt = 1;
while ~ready
    outputFolder = strcat(folder,filesep,app.tag,"ADC",filesep,num2str(cnt),filesep);
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
        ready = true;
    end
    cnt = cnt + 1;
end

dir41 = 'ADC';
dir42 = 'M0';
dir43 = 'R2';

output_directory1 = strcat(outputFolder,dir41);
if ~exist(output_directory1, 'dir')
    mkdir(output_directory1);
end
delete(strcat(output_directory1,filesep,'*'));

output_directory2 = strcat(outputFolder,dir42);
if ~exist(output_directory2, 'dir')
    mkdir(output_directory2);
end
delete(strcat(output_directory2,filesep,'*'));

output_directory3 = strcat(outputFolder,dir43);
if ~exist(output_directory3, 'dir')
    mkdir(output_directory3);
end
delete(strcat(output_directory3,filesep,'*'));


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
    dcmHeader(i).StudyDescription = 'ADC mapping';
       
end



% Export the ADC map Dicoms
seriesInstanceID = dicomuid;
for i=1:numberOfImages

    dcmHeader(i).ProtocolName = 'ADC-map';
    dcmHeader(i).SequenceName = 'ADC-map';
    dcmHeader(i).SeriesInstanceUID = seriesInstanceID;

    fn = strcat('0000',num2str(i));
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = strcat(output_directory1,filesep,'ADC',fn,'.dcm');
    image = rot90(squeeze(cast(round(1000*adcMap(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcmHeader(i));

end



% Export the M0 map Dicoms
seriesInstanceID = dicomuid;
for i=1:numberOfImages

    dcmHeader(i).ProtocolName = 'M0-map';
    dcmHeader(i).SequenceName = 'M0-map';
    dcmHeader(i).SeriesInstanceUID = seriesInstanceID;

    fn = strcat('0000',num2str(i));
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = strcat(output_directory2,filesep,'M0',fn,'.dcm');
    image = rot90(squeeze(cast(round(m0Map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcmHeader(i));

end



% Export the  R^2 map Dicoms
seriesInstanceID = dicomuid;
for i=1:numberOfImages

    dcmHeader(i).ProtocolName = 'R2-map';
    dcmHeader(i).SequenceName = 'R2-map';
    dcmHeader(i).SeriesInstanceUID = seriesInstanceID;

    fn = strcat('0000',num2str(i));
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = strcat(output_directory3,filesep,'R2',fn,'.dcm');
    image = rot90(squeeze(cast(round(100*r2Map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcmHeader(i));

end




end