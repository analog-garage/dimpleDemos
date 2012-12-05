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

function [fg, sps] = BuildOpticalFlowGraph(args)

    offsets = args.get('offsets');
    solver = args.get('solver');
    numHsp = args.get('numHsp');
    numWsp = args.get('numWsp');
    do_similarity = args.get('doSimilarity');
    ep = args.get('ep');
    sigmaP = args.get('sigmaP');
    k = args.get('k');
    
    
    domain = num2cell(offsets,2);

    fg = FactorGraph();
    fg.Solver = solver;
    fg.Scheduler = 'SequentialScheduler';

    %create variables
    sps = Discrete(domain,numHsp,numWsp);

    %generate similarity factors
    rho_p_ = @(x,y) rho_p(x,y,ep,sigmaP);
    if do_similarity
        fh = fg.addFactorVectorized(rho_p_,sps(1:(end-1),:),sps(2:end,:));
        fv = fg.addFactorVectorized(rho_p_,sps(:,1:(end-1)),sps(:,2:end));
        fh.invokeSolverMethod('setK',uint32(k));
        fv.invokeSolverMethod('setK',uint32(k));
    end

end