function [FD] = CAP_ComputeFD(motfile_name)

    Mot = textread(motfile_name);
    Mot = Mot(:,1:6);
    
    % Gives me the differences (T - 1 by 6)
    Tom = sum(abs(diff(Mot)));
    Tom1 = sum(Tom(1:3));
    Tom2 = sum(Tom(4:6));
    
    % If the first three columns have larger values, then we assume that
    % they are translational parameters and we convert the other three into
    % mm
    % Else, we do the opposite
    % NOTE: We assume that the rotational data is provided in [rad], which
    % is consistent with visual inspection of empirical data so far
    if Tom1 > Tom2
        Mot(:,4:6) = 50*Mot(:,4:6);
    elseif Tom2 > Tom1
        Mot(:,1:3) = 50*Mot(:,1:3);
    else
        errordlg('Inconsistent movement parameter file...');
    end

    % Computes FD
    FD = sum(abs([0 0 0 0 0 0; diff(Mot)]),2);
end