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

function [factorgraph, variables] = stereovision(map)
    depth = map.get('depth');
    width = map.get('width');
    height = map.get('height');
    solver = map.get('solver');
    k = map.get('k');
    damping = map.get('damping');
    scheduler = map.get('scheduler');

ep     = 0.001;
sigmaP = 0.05;

    

rho_p_ = @(ds, dt) ((1-ep)*exp(-abs(ds-dt)/sigmaP)+ep);



% Create Factor Graph and set solver.
factorgraph = FactorGraph();
factorgraph.Solver = solver;

% Create variables and add factors connection variables.
variables = Variable(0:(depth - 1), height, width);


%Set horizontal similarity factors
disp('horizontal factors...');
hfs = factorgraph.addFactorVectorized(rho_p_,variables(1:end,1:end-1),variables(1:end,2:end));

%Support K-Best
if k ~= 0
    hfs.invokeSolverMethod('setK',k);
end

%Set vertical similarity factors
disp('vertical factors...');
vfs = factorgraph.addFactorVectorized(rho_p_,variables(1:end-1,1:end),variables(2:end,1:end));

%Support K-Best
if k ~= 0
    vfs.invokeSolverMethod('setK',uint32(k));
end

factorgraph.Solver.setDamping(damping);
factorgraph.Scheduler = scheduler;

end
