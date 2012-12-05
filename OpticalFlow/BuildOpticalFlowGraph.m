function [fg, sps] = BuildOpticalFlowGraph(args)

    offsets = args.get('offsets');
    solver = args.get('solver');
    numHsp = args.get('numHsp');
    numWsp = args.get('numWsp');
    do_similarity = args.get('doSimilarity');
    ep = args.get('ep');
    sigmaP = args.get('sigmaP');
    k = args.get('k');
    
    
    domain = num2cell(offsets,2);

    fg = FactorGraph();
    fg.Solver = solver;
    fg.Scheduler = 'SequentialScheduler';

    %create variables
    sps = Discrete(domain,numHsp,numWsp);

    %generate similarity factors
    rho_p_ = @(x,y) rho_p(x,y,ep,sigmaP);
    if do_similarity
        fh = fg.addFactorVectorized(rho_p_,sps(1:(end-1),:),sps(2:end,:));
        fv = fg.addFactorVectorized(rho_p_,sps(:,1:(end-1)),sps(:,2:end));
        fh.invokeSolverMethod('setK',uint32(k));
        fv.invokeSolverMethod('setK',uint32(k));
    end

end