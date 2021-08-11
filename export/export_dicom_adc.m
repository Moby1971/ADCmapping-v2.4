function export_dicom_adc(directory,dcm_info,adcmap,m0map,r2map,tag)


% Create new directory 
ready = false;
cnt = 1;
while ~ready
    output_directory = strcat(directory,filesep,num2str(cnt));
    if (~exist(output_directory, 'dir'))
        mkdir(fullfile(directory, num2str(cnt)));
        ready = true;
    end
    cnt = cnt + 1;
end


% Number of images
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



% Export the ADC map Dicoms
for i=1:number_of_images
    dcm_header(i).ProtocolName = 'ADC-map';
    dcm_header(i).SequenceName = 'ADC-map';
    dcm_header(i).EchoTime = 1;
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory,filesep,'ADC',fn,'.dcm'];
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
    fname = [output_directory,filesep,'M0',fn,'.dcm'];
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
    fname = [output_directory,filesep,'R2',fn,'.dcm'];
    image = rot90(squeeze(cast(round(100*r2map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end




end