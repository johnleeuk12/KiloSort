%% Testing xblaster data with Kilosort 

fpath = 'D:\DATA\Spikes\testing\';
if ~exist(fpath, 'dir'); mkdir(fpath); end
addpath(genpath('D:\DATA\Spikes\testing\'))

addpath(genpath('C:\Users\John.Lee\Documents\GitHub\KiloSort')) % path to kilosort folder
addpath(genpath('C:\Users\John.Lee\Documents\GitHub\npy-matlab')) % path to npy-matlab scripts

% filtering = preprocessing data a bit)
% filter = fir1(256, [300 3000]/(24414/2));
% not a good idea

path = 'Z:\Data\Experiments\M132D\';

datasetnb = [965 966 967 968 970 972 974 976 978 980 982 984 986 988 990 992 994];

datt = [];
fid = fopen(fullfile(fpath,'test_binary.dat'),'w');

for i = 1:6
    disp(i)
    filename = ['M132D0' num2str(datasetnb(i)) '.m'];
    filename = [path filename];
    obj = xb3.XBlasterStandardLogSource(filename);
    
    tempdat = [];
    for trial = 1:100
        temp = obj.AnalogDataFile.get_analog_data(1,trial,'UseVolts',true);
        %         tempdat = [tempdat ;filtfilt(filter,1,temp{1})]; % filtered data
        tempdat = [tempdat ;temp{1}];
    end
    datt = [datt tempdat(1:1500000,1)];
    
end

datt = int16(datt*200*3.33);
fwrite(fid,datt.','int16');
fclose(fid);


% make_eMouseChannelMap(fpath); 
run(fullfile('config_test_binary.m'))




tic; % start timer

% This part runs the normal Kilosort processing on the simulated data
[rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization
rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively
rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

% save(fullfile(fpath,  'rez.mat'), 'rez', '-v7.3');

% save python results file for Phy
rezToPhy(rez, fpath);


% automerge     
rez = merge_posthoc2(rez);

save(fullfile(fpath,  'rez.mat'), 'rez', '-v7.3');

% remove temporary file
delete(ops.fproc);

toc;