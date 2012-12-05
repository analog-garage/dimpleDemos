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

% This script recreates the classic Cave-Neuwirth experiment. They ran 
% EM on a corpus of English text, modeling it as an HMM with 2 hidden
% states.  They found that the 2 states essentially corresponded to
% consonants and vowels.

% In our version, we take the first 1000 characters of Huckleberry Finn
% and convert the text to 27 characters (a-z and space; we discard
% punctuation and compress consecutive whitespace.)  After running EM, we
% consider the 27x2 emission matrix, and divide the characters into 2
% clusters based on which hidden state is more likely.

% Running this does, indeed, separate the vowels (plus "y" and a few other
% letters) into one group, and the consonants into the other.

% For the original Cave-Neuwirth article, see John D. Ferguson, editor.
% Symposium on the application of hidden Markov models to text and speech.
% Institute for Defense Analyses, Communications Research Division, 1980.


tic;

%% Load data
data_cell=importdata('Huckleberry_parsed.txt');
data=data_cell{1}-'a'+1;

% Clean up any weird characters in the data
data(data<0)=27;
data(data>27)=27;

% Truncate data to speed up EM.
character_limit=1200;
data=data(1:character_limit);

%% Set parameters
% N = number of observations
% A = number of observable states
% H = number of hidden states
N=length(data);
H=2;
A=27; % a through z, plus space.
numReEstimations = 25;
numRestarts = 100;

fprintf('N=%d, H=%d, A=%d\n',N,H,A);
fprintf('numReEstimations=%d, numRestarts=%d\n',numReEstimations, numRestarts);

%% Make factor graph
fg = FactorGraph();
fg.Solver.setSeed(0);
xv = Discrete((1:H),N,1);
yv = Discrete((1:A),N,1);

% Add in Markov chain
guessT = FactorTable(rand(H),xv.Domain,xv.Domain);
guessT.normalize(1);
fg.addFactorVectorized(guessT,xv(1:(end-1)),xv(2:end)).DirectedTo = xv(2:end);

% Add in relationship between hidden state and observation
guessE = FactorTable(rand(H,A),xv.Domain,yv.Domain);
guessE.normalize(1);
fg.addFactorVectorized(guessE,xv(1:end),yv(1:end)).DirectedTo = yv(1:end);

% Add in observations
for i=1:N
    pr=zeros(A,1);
    pr(data(i))=1;
    yv(i).Input=pr;
end

%% Run EM
disp('running EM...');
fg.baumWelch({guessT,guessE},numRestarts,numReEstimations);

%% Examine results
disp('results...');
finalT=full(sparse(guessT.Indices(:,1)+1,guessT.Indices(:,2)+1,guessT.Weights));
finalE=full(sparse(guessE.Indices(:,1)+1,guessE.Indices(:,2)+1,guessE.Weights));

for i=1:H
    fprintf('=====  Cluster %d  =====\n',i);
    for j=1:27
        [tmp likelihood_mode]=max(finalE(:,j));
        if (likelihood_mode == i)
            if (j<27)
                fprintf(' %c',j+'a'-1);
            else
                fprintf(' _');
            end
        end
    end
    fprintf('\n');
end
    
toc;