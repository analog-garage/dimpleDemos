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

function [factorgraph, variables] = stereovisionCreateGraph(varargin)

map = java.util.HashMap;
if nargin > 0
    map = varargin{1};
end
if (~map.containsKey('fast')); map.put('fast', 0); end;
if (~map.containsKey('depth')); map.put('depth', 75); end;
if (~map.containsKey('verbose')); map.put('verbose', false); end;
if (~map.containsKey('dataset')); map.put('dataset', 'art_scaled'); end;


% Build the FactorGraph...
%
fast = map.get('fast');         % Each dimension of the original image is divided by this number
depth = map.get('depth');       % Number of depth levels represented
verbose = map.get('verbose');
dataset = load_dataset(map.get('dataset'));

% Capture start time.
if (verbose)
    timeStart = tic;
end

% Load images.
imageL = dataset.Left.Image;
imageR = dataset.Right.Image;

% For Testing Purposes...
if (fast > 0)
%   imageL = imageL(1:fast:end, 1:fast:end, :);
%   imageR = imageR(1:fast:end, 1:fast:end, :);
    [h w c] = size(imageL);
    hf = floor(h/fast);
    wf = floor(w/fast);
    hs = floor(hf/2);
    ws = floor(wf/2);
    imageL = imageL(1+hs:1+hs+hf, 1+ws:1+ws+wf, :);
    imageR = imageR(1+hs:1+hs+hf, 1+ws:1+ws+wf, :);
end

% Set parameters.
ed     = 0.01;
ep     = 0.05;
sigmaD = 8;
sigmaP = 0.6;
sigmaF = 0.3;

% Convert the images to grayscale without using the image processing
% toolbox.
color2gray = @(image) ...
    0.2989 * double(image(:, :, 1)) + ...
    0.5870 * double(image(:, :, 2)) + ...
    0.1140 * double(image(:, :, 3));
inputL = color2gray(imageL);
inputR = color2gray(imageR);
[height, width] = size(inputL);

% Create temporary function handles.
rho_d_ = @(y, x, d) rho_d(x, y, d, ed, sigmaD, sigmaF, inputL, inputR);
rho_p_ = @(ds, dt) rho_p(ds, dt, ep, sigmaP);

% Check image sizes.
if (size(inputL) ~= size(inputR))
    error('Stereovision:FPT:GetFactorgraph','Mismatched image sizes.');
end

% Output status.
if (verbose)
    fprintf('Loaded images with dimensions %dx%d pixels\n', height, width);
end

% Create Factor Graph.
factorgraph = FactorGraph();

% Create variables and add inputs.
if (verbose); fprintf('Creating variables and setting inputs\n'); end;
variables = Variable(0:(depth - 1), height, width);
inputs = zeros(height, width, depth);
depthRange = 0:depth-1;
for i = 1:height
    for j = 1:width
        inputs(i,j,:) = rho_d_(i, j, depthRange);
    end
end
variables.Input = inputs;

% Add factors.
if (verbose); fprintf('Adding factors\n'); end;
vLeft = variables(:,1:end-1);
vRight = variables(:,2:end);
vLower = variables(1:end-1,:);
vUpper = variables(2:end,:);
factorgraph.addFactorVectorized(rho_p_, vLeft, vRight);
factorgraph.addFactorVectorized(rho_p_, vLower, vUpper);


if (verbose)
    fprintf('Graph construction time: %.1f seconds\n', toc(timeStart));
end
end
