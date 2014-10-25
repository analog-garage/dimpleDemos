
function testScript(script)
    ok = 0;
    
    savedPath = path;
    try
        % HACK - find builtin 'run' function, which may be shadowed
        list = which('run', '-all');
        realRunPath = list{end}; % Assume it is the last one for now...
        addpath(fileparts(realRunPath));
        run(script);
    catch err
        err
        ok = 42;
    end
    path(savedPath);
    
    exit(ok)
end
