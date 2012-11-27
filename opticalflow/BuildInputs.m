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

function result = BuildInputs(F1,F2,offsets, superPixelW,sigmaF,ed,sigmaD)
    %create border around F2 given distances
    mx_y = max(offsets(:,1));
    trim_bottom_pixels = ceil(mx_y/superPixelW)*superPixelW;
    trim_bottom_sp = trim_bottom_pixels/superPixelW;
    mn_y = min(offsets(:,1));
    trim_top_pixels = ceil(-mn_y/superPixelW)*superPixelW;
    trim_top_sp = trim_top_pixels/superPixelW;
    mx_x = max(offsets(:,2));
    trim_right_pixels = ceil(mx_x/superPixelW)*superPixelW;
    trim_right_sp = trim_right_pixels/superPixelW;
    mn_x = min(offsets(:,2));
    trim_left_pixels = ceil(-mn_x/superPixelW)*superPixelW;
    trim_left_sp = trim_left_pixels/superPixelW;
    
    %Build F2trimmed
    F1trimmed = F1((trim_top_pixels+1):(end-trim_bottom_pixels),(trim_left_pixels+1):(end-trim_right_pixels));
    
    spTrimmedHeight = size(F1trimmed,1)/superPixelW;
    spTrimmedWidth = size(F1trimmed,2)/superPixelW;
    
    spHeight = size(F1,1)/superPixelW;
    spWidth = size(F1,2)/superPixelW;
    
    result = ones(spHeight,spWidth,size(offsets,1));
    
    for i = 1:length(offsets)
        offset = offsets(i,:);
        offy = offset(1);
        offx = offset(2);
        
        %shift F1 against F2
        F2trimmed = F2((trim_top_pixels+1+offy):(end-trim_bottom_pixels+offy),...
            (trim_left_pixels+1+offx):(end-trim_right_pixels+offx));
        
        %compute norms of patch differences
        squared = (F1trimmed - F2trimmed).^2;
        squared = reshape(squared,superPixelW,spTrimmedHeight,superPixelW,spTrimmedWidth);
        squared = sum(squared,1);
        squared = sum(squared,3);
        squared = reshape(squared,spTrimmedHeight,spTrimmedWidth)/(sigmaF*superPixelW^2);
        

        %compute rho_p
        rhop = ((1-ed)*exp(-abs(squared)/sigmaD)+ed);
        
        %add boundary back in
        result((trim_top_sp+1):(end-trim_bottom_sp),(trim_left_sp+1):(end-trim_right_sp),i) = rhop;
    end
end