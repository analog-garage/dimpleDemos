addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
setupDimpleDemos();

%% Add the EdgeFactorFunction java class to the path. 
javaaddpath('./build/classes/main');

%% Set parameters
disp('setting params...');
grid_size = 3;
num_chunks = 4;
solveOnce = false;
use_dist = false;
numsteps = 10;

%% Load the clouds image
clouds_orig = imread('Clouds3.png');

figure(1);
image(clouds_orig);


%% Take a chunk out of it
disp('remove chunk...');
sz = size(clouds_orig);
x1 = floor(sz(1)/2/3)*3+1;
y1 = floor(sz(2)/2/3)*3+1;

x2 = x1 + grid_size*num_chunks - 1;
y2 = y1 + grid_size*num_chunks - 1;

a1 = x1-grid_size*2;
a2 = x2+grid_size*2;
b1 = y1-grid_size*2;
b2 = y2+grid_size*2;
sz1 = a2-a1+1;
sz2 = b2-b1+1;

clouds_bad = clouds_orig;
clouds_bad(x1:x2,y1:y2,:) = 0;


figure(2);
image(clouds_bad);
drawnow();

%% Create blocks
disp('create blocks...');
num_boxes = (sz(1)-grid_size+1)*(sz(2)-grid_size+1);
num_boxes = num_boxes - (grid_size*num_chunks+grid_size-1)^2;
boxes = zeros(num_boxes,grid_size,grid_size,3);

horzdiffs = ones(num_boxes*2,1)*-1;
vertdiffs = ones(num_boxes*2,1)*-1;
horzdiffind = 1;
vertdiffind = 1;

pixel2block = zeros(size(clouds_bad));


%Create all grid_size X grid_size blocks
%and Calculate function of edge relationships
boxes_index = 1;
for i = 1:sz(1)
    for j = 1:sz(2)
        iend = i+grid_size - 1;
        jend = j+grid_size - 1;
        
        %Create all grid_size X grid_size blocks
        %does this go off the ends
        if iend > sz(1) || jend > sz(2)
            goesOffEnd = 1;
        else
            goesOffEnd = 0;
        end
        
        %does it overlap with the box?
        xoverlaps = (i >= x1 && i <= x2) || (iend >= x1 && iend <= x2);
        yoverlaps = (j >= y1 && j <= y2) || (jend >= y1 && jend <= y2);
        if xoverlaps && yoverlaps
            overlaps = 1;
        else
            overlaps = 0;
        end
        
        if ~overlaps && ~goesOffEnd
            if boxes_index > length(boxes)
                display('ACK!');
            end
            boxes(boxes_index,:,:,:) = clouds_bad(i:iend,j:jend,:);
            
            if mod(i,grid_size) == 1 && mod(j,grid_size) == 1
                pixel2block(i:iend,j:jend) = boxes_index;
            end
            
            boxes_index = boxes_index+1;
        end
        
        %Calculate function of edge relationships
        %calculate horz
        %i must be less than sz(1)
        %jend must be less than or equal to sz(2)
        isInPicRange = i < sz(1) && jend <= sz(2);
        
        %(jend must be less than y1 or j must be less than y2)
        %or i must be <= x1-2 or >= x2+1
        notAroundArtifact = (jend < y1 || j > y2) || (i <= x1-2 || i >= x2+1);
        
        if isInPicRange && notAroundArtifact
            x = double(clouds_bad(i,j:jend,:));
            y = double(clouds_bad(i+1,j:jend,:));
            x = reshape(x,numel(x),1);
            y = reshape(y,numel(y),1);
            diff = x-y;
            nm = norm(double(diff));
            horzdiffs(horzdiffind) = nm;
            horzdiffind = horzdiffind+1;
        end
        
        %calculate vert
        isInPicRange = j < sz(2) && iend <= sz(1);
        notAroundArtifact = (iend < x1 || i > x2) || (j <= y1-2 || j >= y2+1);
        if isInPicRange && notAroundArtifact
            x = double(clouds_bad(i:iend,j,:));
            y = double(clouds_bad(i:iend,j+1,:));
            x = reshape(x,numel(x),1);
            y = reshape(y,numel(y),1);
            diff = x-y;
            nm = norm(double(diff));
            vertdiffs(vertdiffind) = nm;
            vertdiffind = vertdiffind+1;
        end
    end
end

%% Create distributions over horizontal and vertical differences
disp('create horizontal and veritcal differences...');
horzdiffs = horzdiffs(1:find(horzdiffs==-1,1)-1);
horzdiffs = sort(horzdiffs);

vertdiffs = vertdiffs(1:find(vertdiffs==-1,1)-1);
vertdiffs = sort(vertdiffs);

hdelta = max(horzdiffs)/numsteps;
vdelta = max(vertdiffs)/numsteps;
vertf = zeros(numsteps,1);
horzf = zeros(numsteps,1);
for i = 1:numel(horzdiffs)
    ind = floor(horzdiffs(i)/hdelta)+1;
    if ind > numsteps
        ind = numsteps;
    end
    horzf(ind) = horzf(ind)+1;
end
for i = 1:numel(vertdiffs)
    ind = floor(vertdiffs(i)/vdelta)+1;
    
    if ind > numsteps
        ind = numsteps;
    end
    vertf(ind) = vertf(ind)+1;
end

horzf = horzf + 1;
vertf = vertf + 1;
horzf = horzf / sum(horzf);
vertf = vertf / sum(vertf);



%% Convert boxes to Dimple form
boxes_l = reshape(boxes(:,:,1,:),size(boxes,1),1,size(boxes,2)*size(boxes,4));
boxes_r = reshape(boxes(:,:,end,:),size(boxes,1),1,size(boxes,2)*size(boxes,4));
boxes_u = reshape(boxes(:,1,:,:),size(boxes,1),1,size(boxes,3)*size(boxes,4));
boxes_d = reshape(boxes(:,end,:,:),size(boxes,1),1,size(boxes,3)*size(boxes,4));
boxes_domain = zeros(size(boxes,1),4,grid_size*grid_size);
boxes_domain(:,1,:) = boxes_l;
boxes_domain(:,2,:) = boxes_r;
boxes_domain(:,3,:) = boxes_u;
boxes_domain(:,4,:) = boxes_d;
tmp = permute(boxes_domain,[2 3 1]);
domain = num2cell(tmp,[1 2]);
domain = reshape(domain,numel(domain),1);

%% Create Factor Graph
disp('creating graph...');


dd = DiscreteDomain(domain);

vars = Discrete(dd,num_chunks+2,num_chunks+2);
eff = com.analog.lyric.clouds.EdgeFactorFunction();
fg = FactorGraph();

fg.Solver = 'gibbs';

hdelta_var = Real();
vdelta_var = Real();

fg.addFactorVectorized(eff,vars(1:end-1,:),vars(2:end,:),horzf,hdelta_var,false,use_dist);
fg.addFactorVectorized(eff,vars(:,1:end-1),vars(:,2:end),vertf,vdelta_var,true,use_dist);

hdelta_var.Solver.setAndHoldSampleValue(hdelta);
vdelta_var.Solver.setAndHoldSampleValue(vdelta);

%% Hold samples
disp('holding samples...');
for i = 1:(num_chunks+2)
    for j = 1:(num_chunks+2)
        if i == 1 || i == (num_chunks+2) || j == 1 || j == num_chunks+2
            a1 = x1-grid_size + (i-1)*grid_size;
            a2 = a1+grid_size - 1;
            b1 = y1-grid_size + (j-1)*grid_size;
            b2 = b1+grid_size-1;
            chunk = clouds_bad(a1:a2,b1:b2,:);
            boxesm = reshape(boxes,size(boxes,1),3*grid_size*grid_size);
            chunkm = reshape(chunk,1,3*grid_size*grid_size);
            comparison = repmat(chunkm,size(boxesm,1),1)==boxesm;
            sm = sum(comparison,2);
            ind = find(sm==max(sm),1);
            clouds_bad(a1:a2,b1:b2,:) = boxes(ind,:,:,:);
            vars(i,j).Solver.setAndHoldSampleIndex(ind-1);
        end
    end
end

%image(clouds_bad);

%% Solve
disp('solving...');
if solveOnce
    numSamples = 100;
    numRestarts = 4;
    burnIn = 10;
    
    fg.setOption('GibbsOptions.numSamples', numSamples);
    fg.setOption('GibbsOptions.numRandomRestarts', numRestarts);
    fg.setOption('GibbsOptions.burnInScans', burnIn);
    
    tic
    fg.solve();
    toc
    
    drawSolution(num_chunks,vars,boxes,grid_size,clouds_bad,x1,y1);
else
    numSamples = 50;
    numRestarts = 0;
    burnIn = 0;
    
    fg.setOption('GibbsOptions.numSamples', numSamples);
    fg.setOption('GibbsOptions.numRandomRestarts', numRestarts);
    fg.setOption('GibbsOptions.burnInScans', burnIn);
    
    fg.initialize();
    fg.Solver.burnIn();


    for iteration = 1:10
        tic
        fg.Solver.sample(numSamples);
        toc

        drawSolution(num_chunks,vars,boxes,grid_size,clouds_bad,x1,y1);
    end
end


