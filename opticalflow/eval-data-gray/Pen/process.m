
images = cell(4,1);

for i = 1:4
    x = imread(sprintf('Pen%d.jpg',i));
    g = mean(x,3);
    g = g(550:1350,1200:2000);
    images{i} = g;
    imagesc(g);
    colormap('gray');
end

%read images



%crop


%save to png