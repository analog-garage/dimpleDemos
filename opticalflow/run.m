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

%%%%%%%%%%%%%%%%% Set Parameters %%%%%%%%%%%%%%%%%%%%

%Similarity
ep     = 0.001;
%ep = .5;
%sigmaP = 0.05;
sigmaP = 1;
do_similarity = 1;

%Input parameters
ed     = 0.01;
sigmaD = 8;
sigmaF = 1;

%Things to affect speed vs accuracy
max_pixel_distance = 4;
super_pixel_width = 10;
numiters = 100;
k = 5000;
offset_scale = 1;

%Cropping for smaller images
%Van
%cropy = 220;
%cropx = 520;
%truck
%cropy = 180;
%cropx = 120;
%cropheight = 100;
%cropwidth = 100;
cropy = 100;
cropx = 100;
cropheight = 300;
cropwidth = 300;
do_crop = 0;

%Dither parameters
do_dither = 1;
dscale = .001;

%Other parameters
damping = .75;
do_synthetic = 0;
solver = 'minsum';


%%%%%%%%%%%%%%%%% Build the Colormap %%%%%%%%%%%%%%%%%%%%

%Build color map given maxpixel
[offsets,rgb, colormap_image,numvalues] = BuildOffsetsAndColorMap(max_pixel_distance,offset_scale);

%Display colormap
figure(2);
colormap(rgb);
image(colormap_image);
title('color map');
drawnow();


%%%%%%%%%%%%%%%%% Get Data %%%%%%%%%%%%%%%%%%%%

[im1,im2,numHsp,numWsp] = BuildData(do_dither,dscale,do_crop,...
    do_synthetic,super_pixel_width,cropx,cropy,cropwidth,cropheight);

figure(1);
colormap('gray');
image(im1);
title('The original image');
drawnow();

figure(3)
imagesc(abs(im1-im2));
title('image difference');


%%%%%%%%%%%%%%%%% Create the Graph %%%%%%%%%%%%%%%%%%%%

domain = num2cell(offsets,2);

fg = FactorGraph();
fg.Solver = solver;

%create variables
sps = Discrete(domain,numHsp,numWsp);

%create index variables
spsi = Discrete((1:numvalues)',numHsp,numWsp);
ft = FactorTable(repmat((0:(numvalues-1))',1,2),ones(numvalues,1),sps.Domain,spsi.Domain);
fg.addFactorVectorized(ft,sps,spsi);


%generate similarity factors
rho_p_ = @(x,y) rho_p(x,y,ep,sigmaP);
if do_similarity
    fh = fg.addFactorVectorized(rho_p_,sps(1:(end-1),:),sps(2:end,:));
    fv = fg.addFactorVectorized(rho_p_,sps(:,1:(end-1)),sps(:,2:end));
    fh.VectorObject.invokeSolverMethod('setK',uint32(k));
    fv.VectorObject.invokeSolverMethod('setK',uint32(k));
end

%generate inputs
disp('Setting inputs...');
input = BuildInputs(im1,im2,offsets,super_pixel_width,sigmaF,ed,sigmaD);
sps.Input = input;

%display inputs
tmp = zeros(size(input,1),size(input,2));
for i = 1:size(input,1)
    for j = 1:size(input,2)
        mx = max(input(i,j,:));
        tmp(i,j) = find(input(i,j,:)==mx,1);
    end
end


%display it
figure(4);
colormap(rgb);
image(tmp);
title('Prior');
drawnow();



%%%%%%%%%%%%%%%%% Solve the Graph %%%%%%%%%%%%%%%%%%%%


disp('solving...');
fg.Solver.setDamping(damping);
fg.initialize();

for i = 1:numiters
    disp(['iteration ' num2str(i) '...']);
    fg.Solver.iterate();
    
    %display the graph
    figure(5);
    colormap(rgb);
    tmp = spsi.Value;
    image(tmp);
    title('Current best');
    drawnow();
    
end

