%% Constructs a diffusion gradient table from MR Solutions gradient directions file for DSI studio
%
%
%  Gustav Strijkers
%  Academic Medical Center, Amsterdam
%  
%  Version: 28 April 2018
%

clearvars;
close all force;


%% Read data and parameters



data = importdata('/Users/Gustav/Dropbox/Reconstruction_and_analysis_tools/Matlab-develop/DTI/gradient_directions11DTI.txt',',');
outputdir = '/Users/gustav/Desktop/';

bvalue = 800;

dim = size(data,1);


%% normalize to b-value

for i=1:dim
    for j=1:3
        data(i,j) = data(i,j)/1000;
    end
end


%% construct b-value column

for i=1:dim
    bvdata(i,1) = bvalue;
    if data(i,1)==0 && data(i,2)==0 && data(i,3)==0 bvdata(i,1)=0; end
end

%% combine columns & permute

data = [bvdata data];
%data = data(:,[1,3,4,2]);


%% export as CSV file

csvwrite([outputdir,'b-value-file.txt'],data);


%{
%% read  NIFTII file

correct_slice_thickness = 0.7;

datafile = '/Users/Gustav/Desktop/173-ExVivoBrain/DWI-Unrepeated_dwi_data.nii';
dataoutfile = '/Users/Gustav/Desktop/173-ExVivoBrain/DWI-Unrepeated_dwi_data_cst.nii';
info = niftiinfo(datafile);
niidata = niftiread(datafile);
info.PixelDimensions(3) = correct_slice_thickness;
info.raw.pixdim(4) = correct_slice_thickness;
info.raw.srow_z(3) = correct_slice_thickness;
niftiwrite(niidata,dataoutfile,info);
%}


%% read MRD file - RUSLAN CODE

%{

datafile = '/Users/Gustav/Dropbox/Projects/POC 7T brain/Test_30April2018/160/3955/3955_0.MRD';
[imagedata,dimensions,par] = Get_mrd_3D4(datafile,'seq','cen');

btablefilename = '/Users/gustav/Desktop/b-value-file.txt';

  fid3 = fopen(btablefilename,'w');
    for bstep=1:par.no_b_steps
        for direction=1:par.no_diff_dir
            offset = 3*(direction-1);
            vec = par.diff_grad_dir(offset+1:offset+3);
            veclength = sqrt(sum(vec.*vec))/1000;
            if (veclength>0)
               truebvalue = par.b_steps_array(bstep)*veclength*veclength;
                % avoid rounding errors
                if abs(truebvalue-par.b_steps_array(bstep))<1
                    truebvalue = par.b_steps_array(bstep);
                end
                vec = vec/veclength/1000;           
            else
                truebvalue = 0;
            end
            fprintf(fid3, '%5.2f\t%f\t%f\t%f\n', truebvalue, vec(1), vec(2), vec(3));
        end
    end
    fclose(fid3);

%}