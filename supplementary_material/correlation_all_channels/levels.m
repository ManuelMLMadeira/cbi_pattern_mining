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

% xvalues = ['F3-AC,F4-AC,C3-AC,Cz-AC,C4-AC,P3-AC,P4-AC,O1-AC,O2-AC,F3-BZ,F4-BZ,C3-BZ,Cz-BZ,C4-BZ,P3-BZ,P4-BZ,O1-BZ,O2-BZ,F3-JL,F4-JL,C3-JL,Cz-JL,C4-JL,P3-JL,P4-JL,O1-JL,O2-JL,F3-WN,F4-WN,C3-WN,Cz-WN,C4-WN,P3-WN,P4-WN,O1-WN,O2-WN'];
xvalues = ['F3-before,F4-before,C3-before,Cz-before,C4-before,P3-before,P4-before,O1-before,O2-before,F3-during,F4-during,C3-during,Cz-during,C4-during,P3-during,P4-during,O1-during,O2-during,F3-after,F4-after,C3-after,Cz-after,C4-after,P3-after,P4-after,O1-after,O2-after'];
xvalues = strsplit(xvalues,',');
H = HeatMap(L,'Colormap',redbluecmap,'ColumnLabels',xvalues,'RowLabels',xvalues,'DisplayRange', 1);

end

