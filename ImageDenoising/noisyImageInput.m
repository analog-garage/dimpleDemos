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

function [scaledImage, noisyImage, likelihoods, LLR] = noisyImageInput(map)

imageFileName = 'TEMP.png';
noiseSigma = 1;
xImageOffset = 0;
yImageOffset = 0;
xImageSize = 50;
yImageSize = 50;


if ~isempty(map.get('imageFileName')); imageFileName=map.get('imageFileName'); end;
if ~isempty(map.get('noiseSigma')); noiseSigma=map.get('noiseSigma'); end;
if ~isempty(map.get('xImageOffset')); xImageOffset=map.get('xImageOffset'); end;
if ~isempty(map.get('yImageOffset')); yImageOffset=map.get('yImageOffset'); end;
if ~isempty(map.get('xImageSize')); xImageSize=map.get('xImageSize'); end;
if ~isempty(map.get('yImageSize')); yImageSize=map.get('yImageSize'); end;


im = imread(imageFileName, 'png');
im = im(:,:,1);
im = im(yImageOffset+1:yImageOffset+yImageSize,xImageOffset+1:xImageOffset+xImageSize);   % Extract a small part
threshold = 128*ones(size(im));
im = (im > threshold);
scaledImage = (double(im)*2)-1; % Scaled to +/- 1
clear im;
clear threshold;

noiseVariance = noiseSigma^2;
noise = randn(size(scaledImage));                                    % Gaussian noise
noisyImage = scaledImage + noiseSigma * noise;
LLR = -2*noisyImage/noiseVariance;                                   % Gaussian noise
likelihoods = 1./(1+exp(LLR));


end




