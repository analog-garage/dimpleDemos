function setupDimpleDemos()

    if ~exist('testDimple')
        thisdir = fileparts(mfilename('fullpath'));
        p = pwd();
        cd(fullfile(thisdir, '..', 'dimple'));
        startup();
        cd(p);
    end

end
