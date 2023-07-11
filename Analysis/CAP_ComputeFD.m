function [FD] = CAP_ComputeFD(motfile_name)

    Mot = textread(motfile_name);
    Mot = Mot(:,1:6);
    
    % Gives me the differences (T - 1 by 6)
    Tom = sum(abs(diff(Mot)));
    
    % Tom1 is the set of the first 3 parameters
    Tom1 = sum(Tom(1:3));
    
    % Tom2 is the set of next 3 parameters
    Tom2 = sum(Tom(4:6));
    
    % Computes median framewise displacement for both sets
    Alison1 = median(Tom1(:));
    Alison2 = median(Tom2(:));
    
    % If the first three regressors have significantly larger values than
    % the last three, it means that they are in [mm] and the others are in
    % [rad]; consequently, we multiply the latter
    if Alison1 > 10*Alison2
        Mot(:,4:6) = 50*Mot(:,4:6);
        
    % Same process for the other subcase
    elseif Alison2 > 10*Alison1
        Mot(:,1:3) = 50*Mot(:,1:3);
        
    % Else, everything is already in [mm] and we keep the values as such
    else
        
    end

    % Computes FD
    FD = sum(abs([0 0 0 0 0 0; diff(Mot)]),2);
end