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

function [im1,im2,numHsp,numWsp] = BuildData(do_dither, dscale,do_crop,...
    do_synthetic,super_pixel_width,cropx,cropy,cropwidth,cropheight)

    images = cell(4,1);

    for i = 1:4
        x = imread(sprintf('eval-data-gray/Pen/Pen%d.jpg',i));
        g = mean(x,3);
        g = g(550:1350,1200:2000);
        images{i} = g;
        %imagesc(g);
        %colormap('gray');
    end

    im1 = images{1};
    im2 = images{2};
    
    %load two frames of data set
    %im1 = imread(frame1);
    %im2 = imread(frame2);
    
    
    if do_dither
        dither1 = randn(size(im1))*dscale;
        dither2 = randn(size(im2))*dscale;
        im1 = double(im1) + dither1;
        im2 = double(im2) + dither2;
    end
    %im2 = im1;
    if do_crop
        im1 = im1(cropy:(cropy+cropheight-1),cropx:(cropwidth+cropx-1));
        im2 = im2(cropy:(cropy+cropheight-1),cropx:(cropwidth+cropx-1));
    end
    %setup synthetic data


    if do_synthetic
        orig = rand(40,40);
        im1 = orig;
        im2 = orig;
        offsetX = -5;
        offsetY = 2;
        widthX = 10;
        widthY = 10;
        X = 20;
        Y = 20;
        im1(Y:(widthY+Y-1),X:(widthX+X-1)) = rand(widthY,widthX);
        im2(Y+offsetY:Y+offsetY+widthY-1,X+offsetX:X+offsetX+widthX-1) = im1(Y:(widthY+Y-1),X:(widthX+X-1));
    end


    %figure out super pixels
    %first trim the image
    imwidth = size(im1,2);
    imheight = size(im1,1);
    newwidth = floor(imwidth/super_pixel_width)*super_pixel_width;
    newheight = floor(imheight/super_pixel_width)*super_pixel_width;
    im1 = im1(1:newheight,1:newwidth);
    im2 = im2(1:newheight,1:newwidth);

    %im2 = im1;
    
    numHsp = newheight/super_pixel_width;
    numWsp = newwidth/super_pixel_width;


end