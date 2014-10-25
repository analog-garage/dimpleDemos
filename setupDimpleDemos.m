function setupDimpleDemos()

    if ~exist('testDimple')
        thisdir = fileparts(mfilename('fullpath'));
        p = pwd();
        jenkinsDimple = fullfile(thisdir, 'jenkins', 'dimple')
        if exist(jenkinsDimple)
        	cd(jenkinsDimple);
        else
        	cd(fullfile(thisdir, '..', 'dimple'));
        end
        startup();
        cd(p);
    end

end
