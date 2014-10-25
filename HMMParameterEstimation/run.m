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

function run()

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
setupDimpleDemos();

% Graph parameters
numStates = 4;                      % Number of states in the HMM
numObsValues = 4;                   % Number of states in the observed value
hmmLength = 2000;                   % Length of the HMM
repeatable = false;                 % Make this run repeat all the same random values
plotScore = false;                  % For Gibbs solver, plot score as a function of sample

% Gibbs solver parameters
numSamples = 100;                   % Total number of Gibbs samples to run
scansPerSample = 1;                 % Number of scans (one update of all variables) per sample
burnInScans = 0;                    % Number of burn-in scans before sampling

% Baum-Welch parameters
numReEstimations = 20;
numRestarts = 20;


if (repeatable)
    seed = 1;
    rs=RandStream('mt19937ar');
    RandStream.setGlobalStream(rs);
    reset(rs,seed);
end


%**************************************************************************
% Sample from system to be estimated
%**************************************************************************

% Randomly generate stochastic transition and observation matrices
transMatrix = randStochasticStrongDiag(numStates, numStates, 2);
obsMatrix = randStochasticStrongDiag(numObsValues, numStates, 10);
disp('******************************************************************');
disp('HMM matrices');
disp('******************************************************************');
disp('Observation matrix:'); disp(obsMatrix);
disp('Transition matrix:'); disp(transMatrix);


% Run the HMM to produce an observation sequence.
% This will subsequently be used to estimate the HMM transition matrix.
% In this demo, the observation matrix is assumed to be known.
stateRealization = zeros(hmmLength,1);
obsRealization = zeros(hmmLength,1);
initDist = randSimplex(numStates);
stateRealization(1) = multinomialSample(initDist);
obsRealization(1) = multinomialSample(obsMatrix(:,stateRealization(1)));
for i = 2:hmmLength
	stateRealization(i) = multinomialSample(transMatrix(:,stateRealization(i-1)));
	obsRealization(i) = multinomialSample(obsMatrix(:,stateRealization(i)));
end




%**************************************************************************
% Solve using Gibbs sampling solver
%**************************************************************************
disp('******************************************************************');
disp('Gibbs sampler parameter estimation');
disp('******************************************************************');
fg = FactorGraph();
fg.Solver = 'gibbs';
fg.setOption('GibbsOptions.numSamples', numSamples);
fg.setOption('GibbsOptions.scansPerSample', scansPerSample);
fg.setOption('GibbsOptions.burnInScans', burnInScans);

% Variables
A = RealJoint(numStates, 1, numStates);         % Transition matrix
state = Discrete(0:numStates-1,1,hmmLength);    % State variables

% Prior on columns of A
A.Input = FactorFunction('Dirichlet',ones(1,numStates));

% Add transition factors
fg.addFactorVectorized('DiscreteTransition', state(2:end), state(1:end-1), {A,[]});

% Add observation factors
state.Input = obsMatrix(obsRealization,:);

if (plotScore)
    fg.setOption('GibbsOptions.saveAllScores', true);  % Save scores
end

if (repeatable)
    fg.Solver.setSeed(1);		% Make the Gibbs solver repeatable
end

% Solve
disp('Starting Gibbs solver');
t = tic;
fg.solve();
st = toc(t);
fprintf('Solve time: %.2f seconds\n', st);

% Get the estimated transition matrix
output = cell2mat(A.invokeSolverMethodWithReturnValue('getBestSample'));
output = output./repmat(sum(output,1),numStates,1);
disp('Gibbs estimate:'); disp(output);

% Compute the KL-divergence rate
KLDivergenceRate = kLDivergenceRate(transMatrix, output);
fprintf('Gibbs KL divergence rate: %f\n\n', KLDivergenceRate);

if (plotScore)
    figure; plot(fg.Solver.getAllScores); drawnow;
end


%**************************************************************************
% Solve using Baum-Welch
%**************************************************************************
disp('******************************************************************');
disp('Baum-Welch parameter estimation');
disp('******************************************************************');
fg2 = FactorGraph();
fg2.Solver = 'sumproduct';
fg2.NumIterations = 1;

% Variables
state2 = Discrete(0:numStates-1,1,hmmLength);

% Add random transition factors
transitionFactor2 = FactorTable(randStochasticMatrix(numStates, numStates),state2.Domain,state2.Domain);
fg2.addFactorVectorized(transitionFactor2, state2(2:end), state2(1:end-1)).DirectedTo = state2(2:end);

% Add observation factors
state2.Input = obsMatrix(obsRealization,:);

% Solve
disp('Starting Baum-Welch');
t = tic;
fg2.baumWelch({transitionFactor2},numRestarts,numReEstimations);
st = toc(t);
fprintf('Solve time: %.2f seconds\n', st);

% Get the estimated transition matrix
output2 = zeros(numStates,numStates);
for i = 1:length(transitionFactor2.Weights)
    output2(transitionFactor2.Indices(i,1)+1, transitionFactor2.Indices(i,2)+1) = transitionFactor2.Weights(i);
end
output2 = output2./repmat(sum(output2,1),numStates,1);
disp('Baum-Welch estimate:'); disp(output2);

% Compute the KL-divergence rate
KLDivergenceRate2 = kLDivergenceRate(transMatrix, output2);
fprintf('Baum-Welch KL divergence rate: %f\n', KLDivergenceRate2);


end



% Compute the KL-divergence rate
function KLDivergenceRate = kLDivergenceRate(baseMatrix, estimatedMatrix)
numStates = size(baseMatrix,1);
piStationary = (baseMatrix^1000) * ones(numStates,1)/numStates; % Approximate stationary distribution
P = baseMatrix;
Q = estimatedMatrix;
KLDivergenceRate = 0;
for inState = 1:numStates
    Si = 0;
    for outState = 1:numStates
        Si = Si + P(outState,inState) * log(P(outState,inState) / Q(outState,inState));
    end
    KLDivergenceRate = KLDivergenceRate + piStationary(inState) * Si;
end

end



function m = randStochasticStrongDiag(dOut, dIn, diagStrength)
m = randStochasticMatrix(dOut,dIn);
m = m + diagStrength * eye(dOut,dIn);
m = m ./ repmat(sum(m,1), dOut, 1);
end


function m = randStochasticMatrix(dOut, dIn)
m = zeros(dOut,dIn);
for i = 1:dIn
    m(:,i) = randSimplex(dOut);
end
end


function m = randSparseStochasticMatrix(dOut, dIn, sparsity)
m = zeros(dOut,dIn);
for i = 1:dIn
    m(:,i) = randSkeletonSimplex(dOut, sparsity);
end
end


% Given a column vector x in R^k contained in the standard (k-1)-simplex,
% choose n in {1,...,k} according to the multinomial distribution x
function n = multinomialSample(x)
	n = 1+sum(cumsum(x)<rand);
end

% Choose a column vector in R^k uniformly from the standard (k-1)-simplex
function x = randSimplex(k)
	x = normalize(randExp([k,1]));
end

% Choose a column vector in R^k with expected sparsity p uniformly over the
% union of the appropriate (k-1)-simplices
function x = randSimplexSkeleton(k,p)
	mask = rand([k,1]) < p;
	% Make sure the vector we try to normalize is nonzero somewhere
	if max(mask) == 0
		mask(ceil(k*rand())) = 1;
	end
	x = normalize(mask.*randExp([k,1]));
end

% Standard exponential random variables
function x = randExp(varargin)
	x = -log(rand(varargin{:}));
end

% Normalize a vector
function out = normalize(in)
	out = in/sum(in);
end


