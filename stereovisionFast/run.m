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

%Set parameters
iterations = 20;
depth = 75;
data_set = 'art_scaled';
blockWidth = 2;
blockHeight = blockWidth;
solver = 'sumproduct';
k = 0;
damping = .5;


%Set inputs
disp('Setting inputs...');
dataset = load_dataset(data_set);

% Load images.
imageL = dataset.Left.Image;
imageR = dataset.Right.Image;



% Set parameters.
ed     = 0.01;
ep     = 0.001;
sigmaD = 8;
sigmaP = 0.05;
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


%trim the image so that we can divide into blocks
width = size(imageL,2);
height = size(imageL,1);
width = width - mod(width,blockWidth);
height = height - mod(height,blockHeight);
imageL = imageL(1:height,1:width,:);
imageR = imageR(1:height,1:width,:);

% Check image sizes.
if (size(inputL) ~= size(inputR))
    error('Stereovision:FPT:GetFactorgraph','Mismatched image sizes.');
end

[A,B] = meshgrid(1:height,1:width);
input = zeros(height/blockHeight,width/blockWidth,depth);
for i = 1:depth
    tmp = rho_d_(A,B,i);
    tmp = reshape(tmp,blockHeight,height/blockHeight,blockWidth,width/blockWidth);
    tmp = prod(tmp,1);
    tmp = prod(tmp,3);
    input(:,:,i) = tmp(1,:,1,:);
end

%Create the factor graph
map = java.util.HashMap();
map.put('depth',depth);
map.put('width',width/blockWidth);
map.put('height',height/blockHeight);
map.put('solver',solver);
map.put('k',k);
map.put('damping',damping);

tic
[fg, variables] = stereovision(map);
toc


variables.Input = input;


% Solve using iterate so we can print out the iteration number
disp('solving...');
fg.initialize();
for i = 1:iterations
    fprintf('iteration %d\n',i);
    tic
    fg.Solver.iterate();
    toc
    %Display the results.
    
    output = uint8(variables.Value);
    
    
    %The following code attempts to threshold outliers
    values = sort(unique(output));
    percent = .02;
    total = 1;
    
    for i = 1:length(values)
        v = values(i);
        current_percent = numel(find(output >= v)) / numel(output);
        if current_percent < percent;
            output(output >= v) = v;
            break;
        end
    end
    
    %Finally we show the image
    imagesc(output);
    drawnow;
end


