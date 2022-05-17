function L = levels(R)

size = length(R);
L = zeros(size, size);
for i=1:size
    for j=1:size
        if abs(R(i,j))>=0.5
            L(i,j) = 1;
        elseif abs(R(i,j))>=0.3
            L(i,j) = 0.5;
        end
    end
end

xvalues = ['F3-AC,F4-AC,C3-AC,Cz-AC,C4-AC,P3-AC,P4-AC,O1-AC,O2-AC,F3-BZ,F4-BZ,C3-BZ,Cz-BZ,C4-BZ,P3-BZ,P4-BZ,O1-BZ,O2-BZ,F3-JL,F4-JL,C3-JL,Cz-JL,C4-JL,P3-JL,P4-JL,O1-JL,O2-JL,F3-WN,F4-WN,C3-WN,Cz-WN,C4-WN,P3-WN,P4-WN,O1-WN,O2-WN'];
xvalues = strsplit(xvalues,',');
H = HeatMap(L,'Colormap',redbluecmap,'ColumnLabels',xvalues,'RowLabels',xvalues,'DisplayRange', 1);

end

