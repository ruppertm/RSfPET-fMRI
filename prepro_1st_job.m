%-----------------------------------------------------------------------
% Job saved on 09-Aug-2023 10:19:08 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
subjects = [001 002 003 004 005 006 007 008 010 011 012 014 015 016 017 018 019 020 021 022 023 024 025 026 027 028 029];% list of all subjects 

user = getenv('USERNAME'); % username

for subject=subjects
    
subject = num2str(subject, '%03d'); 
% Zero-pads each number so that the subject ID is 3 characters long
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'RSfPET';
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{['C:\Users\' user '\Documents\RSfPET\RSfPET_fPETdata\RSfPET_prepro\2nd_run\sub_' subject '\RSfPET' subject '_d2n_61-90_4D.nii']}};

%realignment
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Named File Selector: RSfPET(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

%old normalize
matlabbatch{3}.spm.tools.oldnorm.estwrite.subj.source(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{3}.spm.tools.oldnorm.estwrite.subj.wtsrc = '';
matlabbatch{3}.spm.tools.oldnorm.estwrite.subj.resample(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
matlabbatch{3}.spm.tools.oldnorm.estwrite.eoptions.template = {['C:\Users\' user '\Documents\RSfPET\RSfPET_fPETdata\RSfPET_prepro\2nd_run\91x109x91TEMPLATE_FDGPET_100.nii,1']};
matlabbatch{3}.spm.tools.oldnorm.estwrite.eoptions.weight = '';
matlabbatch{3}.spm.tools.oldnorm.estwrite.eoptions.smosrc = 8;
matlabbatch{3}.spm.tools.oldnorm.estwrite.eoptions.smoref = 0;
matlabbatch{3}.spm.tools.oldnorm.estwrite.eoptions.regtype = 'mni';
matlabbatch{3}.spm.tools.oldnorm.estwrite.eoptions.cutoff = 25;
matlabbatch{3}.spm.tools.oldnorm.estwrite.eoptions.nits = 16;
matlabbatch{3}.spm.tools.oldnorm.estwrite.eoptions.reg = 1;
matlabbatch{3}.spm.tools.oldnorm.estwrite.roptions.preserve = 0;
matlabbatch{3}.spm.tools.oldnorm.estwrite.roptions.bb = [NaN NaN NaN
                                                         NaN NaN NaN];
matlabbatch{3}.spm.tools.oldnorm.estwrite.roptions.vox = [3 3 3];
matlabbatch{3}.spm.tools.oldnorm.estwrite.roptions.interp = 1;
matlabbatch{3}.spm.tools.oldnorm.estwrite.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.tools.oldnorm.estwrite.roptions.prefix = 'w';

%smoothing
matlabbatch{4}.spm.spatial.smooth.data(1) = cfg_dep('Old Normalise: Estimate & Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{4}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{4}.spm.spatial.smooth.dtype = 0;
matlabbatch{4}.spm.spatial.smooth.im = 0;
matlabbatch{4}.spm.spatial.smooth.prefix = 's';

spm_jobman('run', matlabbatch);


end
