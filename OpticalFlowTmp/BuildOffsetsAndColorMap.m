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

function [offsets,rgb, colormap_image,numvalues] = BuildOffsetsAndColorMap(maxpixel,offset_scale)
    index = 1;
    numvalues = 0;
    offsets = ones((maxpixel*2+1)^2,2)*(maxpixel+1);
    cmap = zeros(size(offsets,1),3);
    myimage = zeros(maxpixel*2+1);
    for i = -maxpixel:maxpixel
        for j = -maxpixel:maxpixel
            distance = sqrt(i^2+j^2);
            if distance < (maxpixel+1);
                numvalues = index;
                offsets(index,:) = [i j];
                %TODO: make up color map
                %TODO: store the i and j for this index
                offset = 0;
                if i < 0
                    offset = pi;
                elseif j < 0
                    offset = 2*pi;
                end
                sign1 = sign(i);
                if sign1 == 0
                    sign1 = 1;
                end
                sign2 = sign(j);
                if sign2 == 0;
                    sign2 = 1;
                end
                multiplier = sign1*sign2;
                if j == 0 && i == 0
                    hue = 0;
                else
                    hue = (offset + multiplier*atan(abs(j)/abs(i)))/(2*pi);
                end
                if isnan(hue)
                    disp('ack');
                end
                saturation = min(sqrt(i^2+j^2)/maxpixel,1);
                cmap(index,:) = [hue saturation 1];
                myimage(i+maxpixel+1,j+maxpixel+1) = index;
                index = index+1;
            end
        end
    end

    theend = find(offsets(:,1)==(maxpixel+1),1);
    if ~isempty(theend)
        offsets = offsets(1:(theend-1),:);
    end
    offsets = offsets*offset_scale;
    cmap = cmap(1:size(offsets,1),:);
    rgb = hsv2rgb(cmap);
    
    colormap_image = myimage;

end