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

function runGibbs()

solver = 'Gibbs';
showIntermedateResults = true;
numSamples = 250;           % Number of Gibbs samples
scansPerSample = 1;         % Number of scans (one update of all variables) per sample
burnInScans = 4;            % Number of burn-in scans before sampling

map = java.util.HashMap;    % Parameters of the graph and data
map.put('fast', 0);         % Each dimension of the original image is divided by this number
map.put('depth', 75);       % Number of distinct depth values
map.put('verbose', true);
map.put('dataset', 'art_scaled');  % Source image pair


% Create the graph
[fg, variables] = stereovisionCreateGraph(map);

% Set solver and solver-specific parameters
fg.Solver = solver;
fg.Solver.setNumSamples(numSamples);
fg.Solver.setScansPerSample(scansPerSample);
fg.Solver.setBurnInScans(burnInScans);

% Solve
fprintf('Starting solver (Gibbs)\n');
t = tic;
if (~showIntermedateResults)  % Solve without showing intermediate results
    fg.solve();
else                          % Solve showing intermediate results
    fg.initialize();
    fg.Solver.burnIn();
    for i=1:numSamples
        fprintf('Sample: %d\n', i);
        fg.Solver.sample();
        output = variables.Value;
        show(output * 2, 'Gibbs');
    end
end
solveTime = toc(t);
fprintf('Solve time: %.1f seconds\n', solveTime);

% Show the result
output = variables.Value;
show(output * 2, 'Gibbs');

% Compute the score of the result
variables.Guess = output;
score = fg.Score;
fprintf('Score of result (Gibbs): %f\n', score);

end
