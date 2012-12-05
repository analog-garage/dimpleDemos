%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright 2012 Analog Devices, Inc.
%
%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maxpixel = 5;
offset_scale = 1;
offsets = BuildOffsetsAndColorMap(maxpixel,offset_scale);
solver = 'minsum';
numHsp = 10;
numWsp = 10;
do_similarity = 1;
k = 1e9;
ep     = 0.001;
sigmaP = 1;

GP5Benchmarks.addConstructor('BuildOpticalFlowGraph', @BuildOpticalFlowGraph);

results = compareSolvers(...
    'graphConstructor', 'BuildOpticalFlowGraph',...
    'itr', 3,...
    'solver', solver,...
    'offsets', offsets, ...
    'solver',solver, ...
	'numHsp', numHsp, ...
	'numWsp', numWsp, ...
	'doSimilarity', 1, ...
	'k', k, ...
	'ep', ep, ...
    'sigmaP', sigmaP,...
    'displayTimeLogs',true ...
);

pc = results.get('IntelMS');
gp5 = results.get('BehavioralMS');
pc/gp5
