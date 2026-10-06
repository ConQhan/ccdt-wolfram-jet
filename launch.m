%LAUNCH Open the Centrifugal Compressor Design Tool.
%   Run this file (F5 or the Run button). It adds the tool folders to the
%   MATLAB path and opens the app. The returned handle is kept in the base
%   workspace as "app", so scripts can also call app.runSweep().

tool_root = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(tool_root, 'lib')));
addpath(fullfile(tool_root, 'api'));
addpath(fullfile(tool_root, 'app'));
app = CompressorDesignApp;
clear tool_root
