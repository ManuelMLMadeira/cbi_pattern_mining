
close all; clear all; clc;

% ordem: F3; F4; C3; Cz; C4; P3; P4; O1; O2

load('bz_beeps_cca.mat');
load('bz_sounds_cca.mat');

load('ac_beeps_cca.mat');
load('ac_sounds_cca.mat');

load('jl_beeps_cca.mat');
load('jl_sounds_cca.mat');

load('wn_beeps_cca.mat');
load('wn_sounds_cca.mat');


%% Inter-Pessoal 
xvalues = ['F3-AC,F4-AC,C3-AC,Cz-AC,C4-AC,P3-AC,P4-AC,O1-AC,O2-AC,F3-BZ,F4-BZ,C3-BZ,Cz-BZ,C4-BZ,P3-BZ,P4-BZ,O1-BZ,O2-BZ,F3-JL,F4-JL,C3-JL,Cz-JL,C4-JL,P3-JL,P4-JL,O1-JL,O2-JL,F3-WN,F4-WN,C3-WN,Cz-WN,C4-WN,P3-WN,P4-WN,O1-WN,O2-WN'];
xvalues = strsplit(xvalues,',');
yvalues = ['F3-AC,F4-AC,C3-AC,Cz-AC,C4-AC,P3-AC,P4-AC,O1-AC,O2-AC,F3-BZ,F4-BZ,C3-BZ,Cz-BZ,C4-BZ,P3-BZ,P4-BZ,O1-BZ,O2-BZ,F3-JL,F4-JL,C3-JL,Cz-JL,C4-JL,P3-JL,P4-JL,O1-JL,O2-JL,F3-WN,F4-WN,C3-WN,Cz-WN,C4-WN,P3-WN,P4-WN,O1-WN,O2-WN'];
yvalues = strsplit(yvalues,',');

% 1 kHz
[R_inter_before_1kHz,P_inter_before_1kHz] = corrcoef([ac_before_1kHz', bz_before_1kHz', jl_before_1kHz', wn_before_1kHz']);
M_inter_before_1kHz = check_CCA_R(R_inter_before_1kHz,P_inter_before_1kHz,xvalues);
H_inter_before_1kHz = HeatMap(R_inter_before_1kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_before_1kHz);
%%
[R_inter_during_1kHz,P_inter_during_1kHz] = corrcoef([ac_during_1kHz', bz_during_1kHz', jl_during_1kHz', wn_during_1kHz']);
M_inter_during_1kHz = check_CCA_R(R_inter_during_1kHz,P_inter_during_1kHz,xvalues);
% H_inter_during_1kHz = HeatMap(R_inter_during_1kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_during_1kHz);
[R_inter_after_1kHz,P_inter_after_1kHz] = corrcoef([ac_after_1kHz', bz_after_1kHz', jl_after_1kHz', wn_after_1kHz']);
M_inter_after_1kHz = check_CCA_R(R_inter_after_1kHz,P_inter_after_1kHz,xvalues);
% H_inter_after_1kHz = HeatMap(R_inter_after_1kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_after_1kHz);

% 2 kHz
[R_inter_before_2kHz,P_inter_before_2kHz] = corrcoef([ac_before_2kHz', bz_before_2kHz', jl_before_2kHz', wn_before_2kHz']);
M_inter_before_2kHz = check_CCA_R(R_inter_before_2kHz,P_inter_before_2kHz,xvalues);
% H_inter_before_2kHz = HeatMap(R_inter_before_2kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_before_2kHz);
[R_inter_during_2kHz,P_inter_during_2kHz] = corrcoef([ac_during_2kHz', bz_during_2kHz', jl_during_2kHz', wn_during_2kHz']);
M_inter_during_2kHz = check_CCA_R(R_inter_during_2kHz,P_inter_during_2kHz,xvalues);
% H_inter_during_2kHz = HeatMap(R_inter_during_2kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_during_2kHz);
[R_inter_after_2kHz,P_inter_after_2kHz] = corrcoef([ac_after_2kHz', bz_after_2kHz', jl_after_2kHz', wn_after_2kHz']);
M_inter_after_2kHz = check_CCA_R(R_inter_after_2kHz,P_inter_after_2kHz,xvalues);
% H_inter_after_2kHz = HeatMap(R_inter_after_2kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_after_2kHz);

% 3 kHz
[R_inter_before_3kHz,P_inter_before_3kHz] = corrcoef([ac_before_3kHz', bz_before_3kHz', jl_before_3kHz', wn_before_3kHz']);
M_inter_before_3kHz = check_CCA_R(R_inter_before_3kHz,P_inter_before_3kHz,xvalues);
% H_inter_before_3kHz = HeatMap(R_inter_before_3kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_before_3kHz);
[R_inter_during_3kHz,P_inter_during_3kHz] = corrcoef([ac_during_3kHz', bz_during_3kHz', jl_during_3kHz', wn_during_3kHz']);
M_inter_during_3kHz = check_CCA_R(R_inter_during_3kHz,P_inter_during_3kHz,xvalues);
% H_inter_during_3kHz = HeatMap(R_inter_during_3kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_during_3kHz);
[R_inter_after_3kHz,P_inter_after_3kHz] = corrcoef([ac_after_3kHz', bz_after_3kHz', jl_after_3kHz', wn_after_3kHz']);
M_inter_after_3kHz = check_CCA_R(R_inter_after_3kHz,P_inter_after_3kHz,xvalues);
% H_inter_after_3kHz = HeatMap(R_inter_after_3kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_after_3kHz);

% Birds
[R_inter_before_birds,P_inter_before_birds] = corrcoef([ac_before_birds', bz_before_birds', jl_before_birds', wn_before_birds']);
M_inter_before_birds = check_CCA_R(R_inter_before_birds,P_inter_before_birds,xvalues);
% H_inter_before_birds = HeatMap(R_inter_before_birds,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_before_birds);
[R_inter_during_birds,P_inter_during_birds] = corrcoef([ac_during_birds', bz_during_birds(1:9,1:485)', jl_during_birds', wn_during_birds']);
M_inter_during_birds = check_CCA_R(R_inter_during_birds,P_inter_during_birds,xvalues);
% H_inter_during_birds = HeatMap(R_inter_during_birds,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_during_birds);
[R_inter_after_birds,P_inter_after_birds] = corrcoef([ac_after_birds', bz_after_birds', jl_after_birds', wn_after_birds']);
M_inter_after_birds = check_CCA_R(R_inter_after_birds,P_inter_after_birds,xvalues);
% H_inter_after_birds = HeatMap(R_inter_after_birds,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_after_birds);

% Boom
[R_inter_before_boom,P_inter_before_boom] = corrcoef([ac_before_boom', bz_before_boom', jl_before_boom', wn_before_boom']);
M_inter_before_boom = check_CCA_R(R_inter_before_boom,P_inter_before_boom,xvalues);
% H_inter_before_boom = HeatMap(R_inter_before_boom,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_before_boom);
[R_inter_during_boom,P_inter_during_boom] = corrcoef([ac_during_boom', bz_during_boom(1:9,1:606)', jl_during_boom', wn_during_boom(1:9,1:606)']);
M_inter_during_boom = check_CCA_R(R_inter_during_boom,P_inter_during_boom,xvalues);
% H_inter_during_boom = HeatMap(R_inter_during_boom,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_during_boom);
[R_inter_after_boom,P_inter_after_boom] = corrcoef([ac_after_boom', bz_after_boom', jl_after_boom', wn_after_boom']);
M_inter_after_boom = check_CCA_R(R_inter_after_boom,P_inter_after_boom,xvalues);
% H_inter_after_boom = HeatMap(R_inter_after_boom,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_after_boom);

% Crying 
[R_inter_before_crying,P_inter_before_crying] = corrcoef([ac_before_crying', bz_before_crying', jl_before_crying', wn_before_crying']);
M_inter_before_crying = check_CCA_R(R_inter_before_crying,P_inter_before_crying,xvalues);
% H_inter_before_crying = HeatMap(R_inter_before_crying,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_before_crying);
[R_inter_during_crying,P_inter_during_crying] = corrcoef([ac_during_crying', bz_during_crying(1:9,1:395)', jl_during_crying', wn_during_crying(1:9,1:395)']);
M_inter_during_crying = check_CCA_R(R_inter_during_crying,P_inter_during_crying,xvalues);
% H_inter_during_crying = HeatMap(R_inter_during_crying,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_during_crying);
[R_inter_after_crying,P_inter_after_crying] = corrcoef([ac_after_crying', bz_after_crying', jl_after_crying', wn_after_crying']);
M_inter_after_crying = check_CCA_R(R_inter_after_crying,P_inter_after_crying,xvalues);
% H_inter_after_crying = HeatMap(R_inter_after_crying,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_after_crying);

% Laughing
[R_inter_before_laughing,P_inter_before_laughing] = corrcoef([ac_before_laughing', bz_before_laughing', jl_before_laughing', wn_before_laughing']);
M_inter_before_laughing = check_CCA_R(R_inter_before_laughing,P_inter_before_laughing,xvalues);
% H_inter_before_laughing = HeatMap(R_inter_before_laughing,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_before_laughing);
[R_inter_during_laughing,P_inter_during_laughing] = corrcoef([ac_during_laughing', bz_during_laughing', jl_during_laughing', wn_during_laughing']);
M_inter_during_laughing = check_CCA_R(R_inter_during_laughing,P_inter_during_laughing,xvalues);
% H_inter_during_laughing = HeatMap(R_inter_during_laughing,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_during_laughing);
[R_inter_after_laughing,P_inter_after_laughing] = corrcoef([ac_after_laughing', bz_after_laughing', jl_after_laughing', wn_after_laughing']);
M_inter_after_laughing = check_CCA_R(R_inter_after_laughing,P_inter_after_laughing,xvalues);
% H_inter_after_laughing = HeatMap(R_inter_after_laughing,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_after_laughing);

% Ringing
[R_inter_before_ringing,P_inter_before_ringing] = corrcoef([ac_before_ringing', bz_before_ringing', jl_before_ringing', wn_before_ringing']);
M_inter_before_ringing = check_CCA_R(R_inter_before_ringing,P_inter_before_ringing,xvalues);
% H_inter_before_ringing = HeatMap(R_inter_before_ringing,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_before_ringing);
[R_inter_during_ringing,P_inter_during_ringing] = corrcoef([ac_during_ringing', bz_during_ringing', jl_during_ringing', wn_during_ringing']);
M_inter_during_ringing = check_CCA_R(R_inter_during_ringing,P_inter_during_ringing,xvalues);
% H_inter_during_ringing = HeatMap(R_inter_during_ringing,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_during_ringing);
[R_inter_after_ringing,P_inter_after_ringing] = corrcoef([ac_after_ringing', bz_after_ringing', jl_after_ringing', wn_after_ringing']);
M_inter_after_ringing = check_CCA_R(R_inter_after_ringing,P_inter_after_ringing,xvalues);
% H_inter_after_ringing = HeatMap(R_inter_after_ringing,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_after_ringing);

% Thunder
[R_inter_before_thunder,P_inter_before_thunder] = corrcoef([ac_before_thunder', bz_before_thunder', jl_before_thunder', wn_before_thunder']);
M_inter_before_thunder = check_CCA_R(R_inter_before_thunder,P_inter_before_thunder,xvalues);
% H_inter_before_thunder = HeatMap(R_inter_before_thunder,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_before_thunder);
[R_inter_during_thunder,P_inter_during_thunder] = corrcoef([ac_during_thunder', bz_during_thunder(1:9,1:535)', jl_during_thunder', wn_during_thunder']);
M_inter_during_thunder = check_CCA_R(R_inter_during_thunder,P_inter_during_thunder,xvalues);
% H_inter_during_thunder = HeatMap(R_inter_during_thunder,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_during_thunder);
[R_inter_after_thunder,P_inter_after_thunder] = corrcoef([ac_after_thunder', bz_after_thunder', jl_after_thunder', wn_after_thunder']);
M_inter_after_thunder = check_CCA_R(R_inter_after_thunder,P_inter_after_thunder,xvalues);
% H_inter_after_thunder = HeatMap(R_inter_after_thunder,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels1(R_inter_after_thunder);