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

function out = BirchfieldTomasi(x, y, d, sigmaF, viewL, viewR)
    invalid = x-d <= 0;
    ds = ones(size(x))*d;
    ds = ds .* (1-invalid);
    
    ys = y(:);
    xs = x(:);
    dss = ds(:);
    inds1 = sub2ind(size(viewL),ys,xs);
    inds2 = sub2ind(size(viewL),ys,xs-dss);

    il1 = viewL(inds1);    
    ir1 = viewR(inds2);
    out = abs(il1 - ir1) / sigmaF;
    out = out .* (1-invalid(:)) + invalid(:)*5000;
    out = reshape(out,size(x,1),size(x,2))';
    
end
