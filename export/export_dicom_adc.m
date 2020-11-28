function export_dicom_adc(output_directory,dcm_info,adcmap,m0map,r2map,tag)


folder_name = [output_directory,[filesep,'ADCmap-DICOM-',tag]];
if (~exist(folder_name, 'dir')); mkdir(folder_name); end
delete([folder_name,filesep,'*']);


% Flip and rotate in correct orientation
adcmap = flip(permute(adcmap,[1,3,2]),3);
m0map = flip(permute(m0map,[1,3,2]),3);
r2map = flip(permute(r2map,[1,3,2]),3);

% Rotate the images if phase orienation == 1
number_of_images = size(adcmap,1);

% Generate new dicom headers
for i = 1:number_of_images
    
    % Read the Dicom header
    dcm_header(i) = dcm_info{i};
    
    % Changes some tags
    dcm_header(i).ImageType = 'DERIVED\DIFUSION\';
    dcm_header(i).InstitutionName = 'Amsterdam UMC';
    dcm_header(i).InstitutionAddress = 'Amsterdam, Netherlands';
    
end



% Export the T2 map Dicoms
for i=1:number_of_images
    dcm_header(i).ProtocolName = 'ADC-map';
    dcm_header(i).SequenceName = 'ADC-map';
    dcm_header(i).EchoTime = 1;
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory,filesep,'ADCmap-DICOM-',tag,filesep,'ADCmap_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(1000*adcmap(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end



% Export the M0 map Dicoms
for i=1:number_of_images
    dcm_header(i).ProtocolName = 'M0-map';
    dcm_header(i).SequenceName = 'M0-map';
    dcm_header(i).EchoTime = 2;
    
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory,filesep,'ADCmap-DICOM-',tag,filesep,'M0map_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(m0map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end



% Export the  R^2 map Dicoms
for i=1:number_of_images
    dcm_header(i).ProtocolName = 'R2-map';
    dcm_header(i).SequenceName = 'R2-map';
    dcm_header(i).EchoTime = 3;
    
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory,filesep,'ADCmap-DICOM-',tag,filesep,'R2map_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(100*r2map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end




end