function drawSolution(num_chunks,vars,boxes,grid_size,clouds_bad,x1,y1)
    for i = 1:num_chunks
        for j = 1:num_chunks
            ind = vars(i+1,j+1).Solver.getBestSampleIndex()+1;
            %ind = vars(i+1,j+1).Solver.getCurrentSampleIndex()+1;
            chunk = boxes(ind,:,:,:);
            a1 = x1 + (i-1)*grid_size;
            a2 = a1 + grid_size - 1;
            b1 = y1 + (j-1)*grid_size;
            b2 = b1 + grid_size - 1;
            clouds_bad(a1:a2,b1:b2,:) = chunk;
        end
    end
    image(clouds_bad);
    drawnow();
end