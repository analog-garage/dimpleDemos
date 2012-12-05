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

function [fg,Vs] = imageDenoisingCreateGraph(map)

thisDir = fileparts(mfilename('fullpath'));
factorFileName = fullfile(thisDir, 'imageStats', 'FactorTableValues300dpi.mat');
xImageSize = 50;
yImageSize = 50;
xBlockSize = 4;
yBlockSize = 4;
verbose = false;

if ~isempty(map.get('factorFileName')); factorFileName=map.get('factorFileName'); end;
if ~isempty(map.get('xImageSize')); xImageSize=map.get('xImageSize'); end;
if ~isempty(map.get('yImageSize')); yImageSize=map.get('yImageSize'); end;
if ~isempty(map.get('xBlockSize')); xBlockSize=map.get('xBlockSize'); end;
if ~isempty(map.get('yBlockSize')); yBlockSize=map.get('yBlockSize'); end;
if ~isempty(map.get('verbose')); verbose=map.get('verbose'); end;

blockSize = xBlockSize*yBlockSize;

load(factorFileName, 'factorTableValues');    % Loads factor table
factorTableValues = reshape(factorTableValues, 2*ones(1,blockSize));


fg = FactorGraph();


rows = yImageSize;
cols = xImageSize;
blockRows = rows - yBlockSize + 1;
blockCols = cols - xBlockSize + 1;


if (verbose); fprintf('Creating variables\n'); end;
Vs = Bit(rows, cols);
for row = 1:rows
    Vs(row,:).setNames(['V_row' num2str(row)]);
end
if (verbose); fprintf('Done creating variables\n'); end;


domains = cell(1,blockSize);
for i=1:blockSize; domains{i} = DiscreteDomain([0 1]); end;
factorTable = FactorTable(factorTableValues,domains{:});


yList = 1:blockRows;
xList = 1:blockCols;
tempVar = Bit();    % Do this to avoid creating a whole array of temp variables
varPatches = repmat(tempVar,[blockCols,blockRows,xBlockSize*yBlockSize]);
blockOffset = 1;
for yb = 0:yBlockSize-1
    for xb = 0:xBlockSize-1
        varPatches(:,:,blockOffset) = Vs(xb+xList,yb+yList);
        blockOffset = blockOffset + 1;
    end
end
fg.addFactorVectorized(factorTable,{varPatches,[1,2]});


end
