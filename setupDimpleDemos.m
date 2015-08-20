function setupDimpleDemos()

    if true || ~exist('testDimple') % FIXME - this test is no longer working!
        thisdir = fileparts(mfilename('fullpath'));
        p = pwd();
        jenkinsDimple = fullfile(thisdir, 'jenkins', 'dimple')
        if exist(jenkinsDimple)
        	cd(jenkinsDimple);
        else
        	cd(fullfile(thisdir, '..', 'dimple'));
        end
        pwd()
        startup();
        cd(p);
    end

end
