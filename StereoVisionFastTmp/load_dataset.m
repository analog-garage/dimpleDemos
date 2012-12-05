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

function dataset = load_dataset(name)
% load_dataset - Loads a Stereovsion dataset.
%
%   Returns a struct with the following fields:
%
%       Alpha       : Scaling factor for truths.
%       Name        : Name of the dataset.
%       Left.Image  : Left scene image.
%       Left.Truth  : Left truth image.
%       Right.Image : Right scene image.
%       Right.Truth : Right truth image.

    thisDir = fileparts(mfilename('fullpath'));
    datasets_path = fullfile(thisDir, 'datasets');
    dataset_path  = fullfile(datasets_path, name);

    if (~exist(fullfile(datasets_path, name, 'dataset.mat'), 'file'))
        error('Stereovision:FPT:LoadDataset', 'The information file does not exist for the dataset named "%s".', name);
    end
    
    % Load dataset file names.
    names = load(fullfile(dataset_path, 'dataset.mat'));
    
    % Create dataset struct.
    dataset = struct( ...
        'Alpha', 0, ...
        'Name', name, ...
        'Left', struct( ...
            'Image', [], ...
            'Truth', []), ...
        'Right', struct( ...
            'Image', [], ...
            'Truth', []));
        
    % Load alpha..
    if isfield(names, 'Alpha')
        dataset.Alpha = names.Alpha;
    end
    
    % Check that image files exist.
    if (~exist(fullfile(dataset_path, names.Left.Image), 'file'))
        error('Stereovision:FPT:LoadDataset', 'The left image file does not exist.');
    elseif (~exist(fullfile(dataset_path, names.Right.Image), 'file'))
        error('Stereovision:FPT:LoadDataset', 'The right image file does not exist.');        
    end
    
    % Load dataset images.
    dataset.Left.Image = imread(fullfile(dataset_path, names.Left.Image));
    dataset.Right.Image = imread(fullfile(dataset_path, names.Right.Image));
    
    % Check that dataset images have the same dimensions.
    if size(dataset.Left.Image) ~= size(dataset.Right.Image)
        error('Stereovision:FPT:LoadDataset', 'The dimensions of the image files do not match.');
    end
    
    % Check that the truth images exist.
    if (exist(fullfile(dataset_path, names.Left.Truth), 'file') || ...
            exist(fullfile(dataset_path, names.Right.Truth), 'file'))
        % Check that the left truth image exists.
        if (~exist(fullfile(dataset_path, names.Left.Truth), 'file'))
            warning('Stereovision:FPT:LoadDataset', 'The left truth image is missing.');
            dataset.Left.Truth = zeros(size(dataset.Left.Image));
        else
            dataset.Left.Truth = imread(fullfile(dataset_path, names.Left.Truth));
        end

        % Check that the right ruth image exists.
        if (~exist(fullfile(dataset_path, names.Right.Truth), 'file'))
            warning('Stereovision:FPT:LoadDataset', 'The right truth image is missing.');
            dataset.Right.Truth = zeros(size(dataset.Right.Image));
        else
            dataset.Right.Truth = imread(fullfile(dataset_path, names.Right.Truth));
        end
    else
        error('Stereovision:FPT:LoadDataset', 'No truth images found.');
    end
end
