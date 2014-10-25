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

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
setupDimpleDemos();

solver = 'SumProduct';
showIntermedateResults = true;
imageDimension = 100;       % Size of each dimension of the image section
iterations = 10;            % Number of iterations of BP

map = java.util.HashMap;    % Parameters of the graph and data
map.put('factorFileName', 'imageStats/FactorTableValues300dpi.mat');
map.put('imageFileName', 'images/1202.4002.3.png');
map.put('xImageOffset', 800);
map.put('yImageOffset', 1925);
map.put('xImageSize', imageDimension);
map.put('yImageSize', imageDimension);
map.put('xBlockSize', 4);
map.put('yBlockSize', 4);
map.put('noiseSigma', 1.0);


% Get input images and plot them
[scaledImage, noisyImage, likelihoods] = noisyImageInput(map);
figure(1);
screenSize = get(0,'ScreenSize');
figure('Position',[screenSize(3)/8 screenSize(4)/8 3*screenSize(3)/4 3*screenSize(4)/4])
subplot(2,2,1);
imagesc(scaledImage);
colormap(gray);
title('Original binary image');
subplot(2,2,2);
imagesc(noisyImage);
colormap(gray);
title('Noisy image');
subplot(2,2,3);
imagesc(noisyImage > 0);
colormap(gray);
title('Noisy binary image');
drawnow;

% Create the graph
[fg, Vs] = imageDenoisingCreateGraph(map);

% Set the inputs
Vs.Input = likelihoods;

% Set solver and solver-specific parameters
fg.Solver = solver;
fg.NumIterations = iterations;

% Solve
fprintf('Starting solver\n');
t=tic;
if (~showIntermedateResults)  % Solve without showing intermediate results
    fg.solve();
else                          % Solve showing intermediate results
    fg.Solver.useMultithreading(true);
    fg.initialize();
    
    for i=1:iterations
        fprintf('Iteration: %d\n', i);
        fg.Solver.iterate();
        output = Vs.Value;
        subplot(2,2,4);
        imagesc(output);
        colormap(gray);
        title('Intermediate result');
        drawnow;
    end
end
solveTime = toc(t);
fprintf('Solve time: %.1f seconds\n', solveTime);

% Show the result
output = Vs.Value;
subplot(2,2,4);
imagesc(output);
title('Final result');
colormap(gray);

% Compute the score of the result
score = fg.Score;
fprintf('Score of result (BP): %f\n', score);

end
