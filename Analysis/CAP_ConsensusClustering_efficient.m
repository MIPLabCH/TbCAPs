%% This function performs consensus clustering over a range of K values
% The goal is to provide a measure of how good each value of K is
% 
% Inputs:
% - X is the data matrix (cell array with each cell n_DP x n_DIM)
% - K_range is the range of K values to examine
% - Subsample_type defines how subsampling is done: across items (data
% points) if 'items', and across dimensions if 'dimensions'
% - Subsample_fraction is the fraction of the original data points, or
% dimensions, to keep for a given fold
% - n_folds is the number of folds over which to run
function [Consensus_ordered] = CAP_ConsensusClustering_efficient(X,K_range,Subsample_type,Subsample_fraction,n_folds,DistType)

    % Number of subjects
    n_subjects = length(X);
    
    n_items = 0;
    
    frames_index = cell(1,n_subjects);
    
    for s = 1:n_subjects
        frames_index{s} = n_items + (1:size(X{s},2));
        n_items = n_items + size(X{s},2);
    end
    
    % Number of dimensions
    n_dims = size(X{1},1);
    
    % Loop over all K values to assess
    for k = 1:length(K_range)
    
        disp(['Running consensus clustering for K = ',num2str(K_range(k)),'...']);
        
        
        
        M_sum = zeros(n_items,n_items,'int8');
        I_sum = zeros(n_items,n_items,'int8');
        
        % Loops over all the folds to perform clustering for
        for h = 1:n_folds
            
            h
            
            switch Subsample_type
                case 'items'
                    
                    % Connectivity matrix that will contain 0s or 1s depending on whether
                    % elements are clustered together or not
                    I = zeros(n_items,n_items,'int8');
                    
                    % Number of items to subsample
                    n_items_ss = floor(Subsample_fraction*n_items);
                    
                    % Does the subsampling
                    [X_ss,tmp_ss] = datasample((cell2mat(X))',n_items_ss,1,'Replace',false);
                    
                    % Vector
                    I_vec = zeros(n_items,1);
                    I_vec(tmp_ss) = 1;
                    
                    % Constructs the indicator matrix
                    for i = 1:length(I_vec)
                        for j = 1:length(I_vec)
                            if (I_vec(i) == I_vec(j)) && (I_vec(i) > 0)
                                I(i,j) = 1;
                            end
                        end
                    end
                    
                case 'dims'
                    
                    % Number of dimensions to subsample
                    n_dims_ss = floor(Subsample_fraction*n_dims);
                    
                    % Does the subsampling
                    [X_ss,tmp_ss] = datasample((cell2mat(X))',n_dims_ss,2,'Replace',false);
                    
                    % Constructs the indicator matrix
                    I = ones(n_items,n_items,'int8');
                    
                case 'subjects'
                    
                    I = zeros(n_items,n_items,'int8');
                    
                    % Number of subjects to use in the subsampling
                    n_subjects_ss = floor(Subsample_fraction*n_subjects);
                    
                    tmp = datasample(1:n_subjects,n_subjects_ss,'Replace',false);
                    
                    % n_frames x n_voxels
                    X_ss = (cell2mat(X(tmp)))';
                    tmp_ss = cell2mat(frames_index(tmp));
                    
                    % Vector
                    I_vec = zeros(n_items,1);
                    I_vec(tmp_ss) = 1;
                    
                    % Constructs the indicator matrix
                    for i = 1:length(I_vec)
                        for j = 1:length(I_vec)
                            if (I_vec(i) == I_vec(j)) && (I_vec(i) > 0)
                                I(i,j) = 1;
                            end
                        end
                    end
                    
                otherwise
                    errordlg('PROBLEM IN TYPE OF SUBSAMPLING');
            end
            
            % Does the clustering (for now, only with k-means), so that IDX
            % contains the indices for each datapoint
            IDX = kmeans(X_ss,K_range(k),'Distance',DistType,'Replicates',10,'Start','uniform');
            
            % Builds the connectivity matrix
            M = Build_Connectivity_Matrix(IDX,tmp_ss,Subsample_type,n_items); 
            
            clear I_vec
            clear X_ss
            clear tmp_ss
            clear IDX
            
            M_sum = M_sum + M;
            I_sum = I_sum + I;
        end
        
        % Constructs the consensus matrix for the considered K
        Consensus(:,:,k) = single(M_sum)./single(I_sum); 
        
        tree = linkage(squeeze(1-Consensus(:,:,k)),'average');

        % Leaf ordering to create a nicely looking matrix
        leafOrder = optimalleaforder(tree,squeeze(1-Consensus(:,:,k)));
        
        % Ordered consensus matrix
        Consensus_ordered(:,:,k) = Consensus(leafOrder,leafOrder,k);
        
        clear leafOrder
        clear Dist_vec
        clear test
        clear IDX
        clear M
        clear I
    end
end