function M = check_CCA_R( R, P , ch)
% Receives two matrices (one with the correlation coefficients - R - and other  
% with the corresponding p_values - P) and an array ch with the names
% referring to the corresponding channel
% It ouputs a matrix M where each rows corresponds to an entry with a 
% correlation coefficients bigger than pre-defined threshold. The first two
% entries of each row show the channels where the correlation was found,
% the third the correlation coefficient itself.
% If that result is significant (p<0.05), 
% the 4th entry of the row is True. Otherwise, it is False. 
% 5th and 6th are the coordinates of the entry in the original P and R
% matrices.

size = length(R);
relevance_threshold_down = 0.30;
relevance_threshold_up = 0.50;
% Reason for this value:
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3576830/ 
% See Section:
% Practical use of correlation coefficient 
% See Fig.:
% Rule of Thumb for Interpreting the Size of a Correlation Coefficient

M = [];
N = [];
for i = 1:size
    for j = i+1:size
        if (abs(R(i,j)) >= relevance_threshold_up) && (P(i,j)<0.05)
            M = [M; ch(i), ch(j), R(i,j), true, i, j];
        elseif  (abs(R(i,j)) <= relevance_threshold_down) && (P(i,j)<0.05)
            N = [N; ch(i), ch(j), R(i,j), false, i ,j]; 
        end
    end
end 

separation = ['-,-,-,-,-,-'];
separation = strsplit(separation,',');
M = [M;separation;N];

end

