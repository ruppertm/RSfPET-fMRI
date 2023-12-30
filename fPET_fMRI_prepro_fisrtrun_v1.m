%title: "CONN_batch_fPETfMRI"
%author: "Marina"
%date: '2023-02-17'
%modified after template by Andrew Jahn and CONN batch webpage
%first run with all subjects
%%loading fMRI and sMRI files
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%returns number of subjects and sessions and will return any files that contain the string
%change TR and filter for each experiment
%folder structure: RSfPET_MR_data -> sub_1->.nii files (with setted origin
%at AC)

NSUBJECTS=26;
cwd=pwd;
FUNCTIONAL_FILE=cellstr(conn_dir('RSfPET*mbep2d_bold*.nii'));
STRUCTURAL_FILE=cellstr(conn_dir('RSfPET*t1_mpr_sag*.nii'));
if rem(length(FUNCTIONAL_FILE), NSUBJECTS),error('mismatch number of functional files %n', length(FUNCTIONAL_FILE)); end
if rem(length(STRUCTURAL_FILE), NSUBJECTS),error('mismatch number of anatomical files %n', length(FUNCTIONAL_FILE)); end
nsessions=length(FUNCTIONAL_FILE)/NSUBJECTS;
FUNCTIONAL_FILE=reshape(FUNCTIONAL_FILE,[NSUBJECTS,nsessions])
STRUCTURAL_FILE={STRUCTURAL_FILE{1:NSUBJECTS}};
disp([num2str(size(FUNCTIONAL_FILE,1)),'subjects'])
disp([num2str(size(FUNCTIONAL_FILE,2)),'sessions'])
TR=1.04;% Repetition Time

%% CONN-SPECIFIC SECTION: RUNS PREPROCESSING/SETUP/DENOISING/ANALYSIS STEPS
%% Prepares batch structure
clear batch;
batch.filename=fullfile(cwd,'conn_RSfPETv3.mat');
batch.Setup.isnew=1;
%conn_batch(batch);

% New conn_*.mat experiment name
%% SETUP & PREPROCESSING step (using default values for most parameters, see help conn_batch to define non-default values)
% CONN Setup                                            % Default options (uses all ROIs in conn/rois/ directory); see conn_batch for additional options
% CONN Setup.preprocessing                        (realignment/coregistration/segmentation/normalization/smoothing)

batch.Setup.nsubjects=NSUBJECTS;
batch.Setup.RT=TR;                                        % TR (seconds)
batch.Setup.functionals=repmat({{}},[NSUBJECTS,1]);       % Point to functional volumes for each subject/session
for nsub=1:NSUBJECTS,for nses=1:nsessions,batch.Setup.functionals{nsub}{nses}{1}=FUNCTIONAL_FILE{nsub,nses}; end; end %note: each subject's data is defined by 1 sessions and one single (4d) file per session
batch.Setup.structurals=STRUCTURAL_FILE;                  % Point to anatomical volumes for each subject
batch.Setup.voxelresolution=3;                            %analysis space will be isotropic 3 mm
batch.Setup.conditions.names={'rest'};%single condition called rest
for ncond=1,for nsub=1:NSUBJECTS,for nses=1:nsessions,              batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0; batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;end;end;end     % rest condition (all sessions)


batch.Setup.preprocessing.fwhm=5;
batch.Setup.preprocessing.voxelsize_func=3;
batch.Setup.preprocessing.removescans=5
batch.Setup.preprocessing.steps={'functional_label','functional_center','functional_realign&unwarp','functional_center','functional_art','functional_normalize_direct','functional_label','structural_center','structural_segment&normalize','functional_smooth','functional_label'}					 		;
batch.Setup.preprocessing.sliceorder='interleaved (Siemens)';
batch.Setup.done=1;
batch.Setup.overwrite='Yes';


%% DENOISING step
% CONN Denoising                                    % Default options (uses White Matter+CSF+realignment+scrubbing+conditions as confound regressors); see conn_batch for additional options
batch.Denoising.filter=[0.01, 0.1];   % frequency filter (band-pass values, in Hz)
batch.Denoising.detrending=1;
batch.Denoising.done=1;
batch.Denoising.overwrite='Yes';


%% FIRST-LEVEL ANALYSIS step
% CONN Analysis                                     % Default options (uses all ROIs in conn/rois/ as connectivity sources); see conn_batch for additional options
batch.Analysis.done=1;
batch.Analysis.overwrite='Yes';

%add voxel-to-voxel ICA analysis                    %performs
%voxel-to-voxel first lebel analysis
batch.vvAnalysis.done=1;
batch.vvAnalysis.measures='group-ICA';
batch.vvAnalysis.overwrite='Yes';


%run batch
conn_batch(batch);


conn
conn('load',fullfile(cwd,'conn_RSfPETv3.mat'));
conn gui_results
