%% Spreading activation using Katz walks
%
% The following script computes a random walk similar to the Katz 
% centrality procedure (see for example Newman (2010) "Networks An Introduction"
% to provide a simple implementation of spreading activation.
% It depends on a single paramter alpha, which determines the contribution
% of longer paths (values of alpha should be > 0 and < 1). 
%
% It will create a path-augmented graph G.rw, which include weighted sum
% of all potential paths. This new graph can then be used to derive
% similarities from.  Pointwise mutual information is used to weigh 
% associative response frequency. 
% For more information see De Deyne, Navarro, Perfors & Storms (2018).
% 
% 
% Input: 
% The input should be an adjacency file formatted as i j f, where i and j 
% refer to a cue and response coordinate, and f to the frequency of 
% response j to cue i
% In addition, a file with labels should also be provided where the labels
% correspond to the indices i and j in the adjacency file
%
% Typically the graph corresponding to the adjacency matrix is restricted 
% to the largest strongly connected component and loops are removed
%
% Algorithm:
% - Import cue x cue matrix G.freq from adjacency format file (either based
%   on first responses R1, or all responses R123)
% - Normalize G.freq so the sum of each rom = 1. Each cell now expresses
%   the conditional probability of a response j given a cue i p(r_j|c_i)
% - Weight using positive pointwise mutual information (PPMI) and
%   renormalize
% - Infer indirect paths by adapting Katz centrality 
% - Reweight and renormalize using PPMI to avoid frequency bias and impose
%   sparsity
%
% Output: 
% G.rw: graph with indirect paths, renormalized and ppmi weighted
% S.rw: dense similarity matrix for the graph. 
%
% Notes:
% Alpha. Throughout most experiments alpha = .75 performs reasonably well. 
% To control degrees of freedom this has been taken as a default.
%
% PPMI. PPMI is known to have a bias for rare events, which does not affect
% typical word associations graphs with n < 12,000 words, but becomes
% a concern for larger graphs (Turney & Pantel, 2010). 
% In such cases, weighted PPMI versions can be considered (see for example
% Levy,Goldberg & Dagan, 2015, p 215)
%
% S.rw: calculating the cosine similarity for all possible pairwise combinations
% is memory intensive, only consider doing this when your system has
% sufficient RAM. Otherwise, consider multiplying vectors instead.
%
% Total processing time on an i7 with 32Gb is about 96 seconds.
%
% References:
% De Deyne, S., Navarro, D., Perfors, A., Storms, G. (2016). Structure at 
% every scale: A semantic network account of the similarities between 
% unrelated concepts. Journal of Experimental Psychology. 
% General, 145, 1228-1254.
%
% Levy, O., Goldberg, Y., & Dagan, I. (2015). Improving distributional 
% similarity with lessons learned from word embeddings. Transactions of the 
% Association for Computational Linguistics, 3, 211-225.
%
% Newman, M. (2010). Networks: an introduction. Oxford university press.
%
% Turney, P. D., & Pantel, P. (2010). From frequency to meaning: 
% Vector space models of semantics. Journal of artificial intelligence 
% research, 37, 141-188.
%
% See  networkFunctions.R to generate the adjacency matrix and labels
% https://github.com/SimonDeDeyne/SWOWEN-2018/
% Questions / comments: 
% Simon De Deyne, simon2d@gmail.com
% Last changed: 16/05/2018

%% Anonymous functions
tic
% Normalize the rows of a sparse matrix A
rowNormal = @(A) spdiags(1./sum (A,2), 0, size(A,1), size(A,1)) * A;

% Calculate PPMI for a row-normalized sparse matrix A
ppmi = @(A) max(0,spfun('log2',A/spdiags((sum(A,1)./size(A,1))',0,size(A,2),size(A,2))));

% Katz paths
katzWalk = @(A,alpha) (eye(size(A,1))-alpha*A) \ eye(size(A,1)); 

% L2 norm for calculating cosine similarity
L2Norm = @(A) spdiags(1./sum(abs(A).^2,2).^0.5,0,size(A,1),size(A,1)) * A; 


%% Construct graph

labelsFile = 'SWOW-ENR1_labels.txt';
adjacencyFile = 'SWOW-ENR1_adj.tsv';

X        = importdata(adjacencyFile);
labels   = importdata(labelsFile);
G.labels = string(labels);
n_voc    = numel(labels);
G.freq   = sparse(X(:,1),X(:,2),X(:,3),n_voc,n_voc);


%% Graph weights

% Weigh the responses using Positive Pointwise Mutual Information
G.freq  = rowNormal(G.freq);
G.ppmi  = rowNormal(ppmi(G.freq));


%% Perform katz walk

% Default alpha = 0.75
alpha = 0.75; 

G.rw = rowNormal(katzWalk(G.ppmi,alpha));

% Weight and renormalize to avoid strength bias
G.rw = rowNormal(ppmi(G.rw));


%% Similarity
S.rw = full(L2Norm(G.rw) * L2Norm(G.rw)');

clearvars EXCEPT G S alpha;
toc