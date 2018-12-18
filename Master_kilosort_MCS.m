useGPU = 0;

fpath = 'D:\DATA\Spikes\MCS\';
if ~exist(fpath, 'dir'); mkdir(fpath); end
addpath(genpath('D:\DATA\Spikes\MCS\'))

addpath(genpath('C:\Users\John.Lee\Documents\GitHub\KiloSort')) % path to kilosort folder
addpath(genpath('C:\Users\John.Lee\Documents\GitHub\npy-matlab')) % path to npy-matlab scripts

% filtering = preprocessing data a bit)
% filter = fir1(256, [300 3000]/(24414/2));
% not a good idea

path = 'C:\Users\John.Lee\Documents\GitHub\MCS\';

%% Collecting data, coverting from HDF5 to dat.
animal = 'M94W';
filenb = '0196';
filepath = ['D:\DATA\MCS' filesep animal];
filepath2 = 'Z:\Data\Experiments\M94W'; %file path for .m files
addpath(filepath)
data1 = McsHDF5.McsData([filepath filesep animal filenb '.h5']);

if size(data1.Recording{1, 1}.EventStream,2) == 1
    event_times = data1.Recording{1, 1}.EventStream{1, 1}.Events{1,1}(1,:).';
else
    event_times = data1.Recording{1, 1}.EventStream{1, 2}.Events{1,1}(1,:).';
end

start_trigger = event_times(1);

datt = data1.Recording{1, 1}.AnalogStream{1, 2}.ChannelData;
timeStamp = data1.Recording{1, 1}.AnalogStream{1, 2}.ChannelDataTimeStamps;
datt = datt(:,find(timeStamp == start_trigger):end)*10e-9;
datt = [datt; zeros(32,length(datt))];
%% preprocessing data
disp('preprocessing data...')
[b,a] = butter(4, [0.0244 0.6104]);
filtData = zeros(32, length(datt));

for ch = 1:32
    filtData(ch,:) = filtfilt(b,a,datt(ch,:));
end

CommonMedian = median(filtData(1:32,:));
% st_dev = zeros(1,32);
for ch = 1:32
    filtData(ch,:) = filtData(ch,:)-CommonMedian;
%     st_dev(ch) = median(abs(Output.filtData(ch,:))/0.6745);
end


disp('preprocessing end')

fid = fopen(fullfile(fpath,'test_binary.dat'),'w');

datt = int16(filtData*200*3.33);
fwrite(fid,datt,'int16');
fclose(fid);

%% Run kilosort
make_MCSChannelMap(fpath)
run(fullfile('config_MCS.m'))





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