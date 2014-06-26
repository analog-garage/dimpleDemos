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

function run()

solver = 'SumProduct';
showIntermedateResults = true;
iterations = 25;          % Number of iterations of BP

map = java.util.HashMap;  % Parameters of the graph and data
map.put('fast', 0);       % Each dimension of the original image is divided by this number
map.put('depth', 75);     % Number of distinct depth values
map.put('verbose', true);
map.put('dataset', 'art_scaled');  % Source image pair


% Create the graph
[fg, variables] = stereovisionCreateGraph(map);

% Set solver and solver-specific parameters
fg.Solver = solver;
fg.Solver.setNumIterations(1);
fg.Solver.setDefaultOptimizedUpdateEnabled(true);

% Solve
fprintf('Starting solver (BP)\n');
t = tic;
if (~showIntermedateResults)  % Solve without showing intermediate results
    fg.solve();
else                          % Solve showing intermediate results
    fg.initialize();
    fg.Solver.useMultithreading(true);
    for i=1:iterations
        fprintf('Iteration: %d\n', i);
        tic
        fg.Solver.iterate();
        toc
        output = variables.Value;
        show(output * 2, 'BP');
    end
end
solveTime = toc(t);
fprintf('Solve time: %.1f seconds\n', solveTime);

% Show the result
output = variables.Value;
show(output * 2, 'BP');

% Compute the score of the result
score = fg.Score;
fprintf('Score of result (BP): %f\n', score);

end