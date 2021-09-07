%% Converts CAPs (matlab matrix) into NIFTI files
% CAP must have size n_CAPs x n_voxels
function [] = CAPToNIFTI_atlas(CAP,PathToAtlas,savedir,savename)

    HDR_atlas = spm_vol(PathToAtlas);
    V_atlas = spm_read_vols(HDR_atlas);

    % Number of CAPs
    n_CAPs = size(CAP,1);
    
    % Creates a new volume, same size as the atlas
    V_out = zeros(size(V_atlas));
    
    % Number of atlas regions at hand
    n_regions = max(V_atlas(:));
    
    % Voxel size
    voxel_size = diag(HDR_atlas.mat);
    voxel_size = voxel_size(1:end-1)';
    
    voxel_shift = HDR_atlas.mat(:,4);
    voxel_shift = voxel_shift(1:end-1)';
    
    % Fills the volume iteratively
    for i = 1:n_CAPs
        for r = 1:n_regions
            V_out(V_atlas == r) = CAP(i,r);
        end
        
        tmp_NIFTI = make_nii(V_out,voxel_size,-voxel_shift./voxel_size);
        
        tmp_NIFTI.hdr.dime.datatype=64;
        tmp_NIFTI.hdr.dime.bitpix=64;
        
        %y_Write(V,brain_info,fullfile(savedir,[savename,'_CAP',num2str(i),'.nii']));
        save_nii(tmp_NIFTI,fullfile(savedir,[savename,'_CAP',num2str(i),'.nii']));
    end
end