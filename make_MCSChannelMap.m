function make_MCSChannelMap(fpath)
% create a channel Map file for simulated data (eMouse)

% here I know a priori what order my channels are in.  So I just manually 
% make a list of channel indices (and give
% an index to dead channels too). chanMap(1) is the row in the raw binary
% file for the first channel. chanMap(1:2) = [33 34] in my case, which happen to
% be dead channels. 

% chanMap = [33 34 8 10 12 14 16 18 20 22 24 26 28 30 32 ...
%     7 9 11 13 15 17 19 21 23 25 27 29 31 1 2 3 4 5 6];

chanMap = [26 36 41 43 35 38 39 30 33 25 27 20 24 34 40 45 ...
    37 21 23 29 28 22 17 50 48 47 18 32 46 19 42 44 54 56 ...
    13 52 2 16 49 31 1 15 3 51 14 4 53 12 11 64 7 60 62 9 58 ...
    5 57 55 6 59 10 63 61 8];
% the first thing Kilosort does is reorder the data with data = data(chanMap, :).
% Now we declare which channels are "connected" in this normal ordering, 
% meaning not dead or used for non-ephys data

% connected = true(34, 1); connected(1:2) = 0;
connected = true(64, 1); connected(find(chanMap>32))= 0;
% connected(1:2) = 0;

% now we define the horizontal (x) and vertical (y) coordinates of these
% 34 channels. For dead or nonephys channels the values won't matter. Again
% I will take this information from the specifications of the probe. These
% are in um here, but the absolute scaling doesn't really matter in the
% algorithm. 

xcoords = [];
ycoords = [];
for ind = 1:16
    xcoords = [xcoords 1 3 2 4];
end

for ind = 1:32
    ycoords = [ycoords ind ind];
end
xcoords = xcoords*32; % 32 um between sites on the same y axis
ycoords = ycoords*20;
% xcoords = 20 * [NaN NaN  1 0 0 1 0 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
% ycoords = 20 * [NaN NaN  7 8 9 9 10 10 11 11 12 12 13 13 14 14 15 15 16 ...
%     17 17 18 18 19 19 20 20 21 21 22 22 23 23 24]; 
 

% Often, multi-shank probes or tetrodes will be organized into groups of
% channels that cannot possibly share spikes with the rest of the probe. This helps
% the algorithm discard noisy templates shared across groups. In
% this case, we set kcoords to indicate which group the channel belongs to.
% In our case all channels are on the same shank in a single group so we
% assign them all to group 1. 

% kcoords = [1 1 1 1 1 1 1 1]; % 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
kcoords = ones(1,64);
% at this point in Kilosort we do data = data(connected, :), ycoords =
% ycoords(connected), xcoords = xcoords(connected) and kcoords =
% kcoords(connected) and no more channel map information is needed (in particular
% no "adjacency graphs" like in KlustaKwik). 
% Now we can save our channel map for the eMouse. 

% would be good to also save the sampling frequency here
fs = 20000; 

save(fullfile(fpath, 'chanMap_MCS.mat'), 'chanMap', 'connected', 'xcoords', 'ycoords', 'kcoords', 'fs')