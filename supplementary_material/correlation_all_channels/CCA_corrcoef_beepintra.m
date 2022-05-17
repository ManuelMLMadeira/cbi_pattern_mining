
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

%% Beeps - Tentar perceber se o sinal antes, durante e depois estao relacionados
% Matrizes 27x27 em que as primeiras 1:9 sao de before, 10:18 sao de during e
% 19:27 sao de after

xvalues = ['F3-before,F4-before,C3-before,Cz-before,C4-before,P3-before,P4-before,O1-before,O2-before,F3-during,F4-during,C3-during,Cz-during,C4-during,P3-during,P4-during,O1-during,O2-during,F3-after,F4-after,C3-after,Cz-after,C4-after,P3-after,P4-after,O1-after,O2-after'];
xvalues = strsplit(xvalues,',');
yvalues = ['F3-before,F4-before,C3-before,Cz-before,C4-before,P3-before,P4-before,O1-before,O2-before,F3-during,F4-during,C3-during,Cz-during,C4-during,P3-during,P4-during,O1-during,O2-during,F3-after,F4-after,C3-after,Cz-after,C4-after,P3-after,P4-after,O1-after,O2-after'];
yvalues = strsplit(yvalues,',');
size = length(xvalues);

%% AC (Antonio Cavaco)

[R_ac_intra_1kHz,P_ac_intra_1kHz] = corrcoef([ac_before_1kHz(1:9,251:500)', ac_during_1kHz(1:9,1:250)', ac_after_1kHz(1:9,1:250)']);
M_ac_intra_1kHz = check_CCA_R_beepi(R_ac_intra_1kHz,P_ac_intra_1kHz,xvalues);
H_ac_intra_1kHz = HeatMap(R_ac_intra_1kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_ac_intra_1kHz);
%%
[R_ac_intra_2kHz,P_ac_intra_2kHz] = corrcoef([ac_before_2kHz(1:9,251:500)', ac_during_2kHz(1:9,1:250)', ac_after_2kHz(1:9,1:250)']);
M_ac_intra_2kHz = check_CCA_R_beepi(R_ac_intra_2kHz,P_ac_intra_2kHz,xvalues);
% H_ac_intra_2kHz = HeatMap(R_ac_intra_2kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_ac_intra_2kHz);
[R_ac_intra_3kHz,P_ac_intra_3kHz] = corrcoef([ac_before_3kHz(1:9,251:500)', ac_during_3kHz(1:9,1:250)', ac_after_3kHz(1:9,1:250)']);
M_ac_intra_3kHz = check_CCA_R_beepi(R_ac_intra_3kHz,P_ac_intra_3kHz,xvalues);
% H_ac_intra_3kHz = HeatMap(R_ac_intra_3kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_ac_intra_3kHz);


% [R_ac_intra_birds,P_ac_intra_birds] = corrcoef([ac_before_birds(1:9,1:250)' ac_during_birds(1:9,1:250)' ac_after_birds(1:9,1:250)']);
% M_ac_intra_birds = check_CCA_R_beepi(R_ac_intra_birds,P_ac_intra_birds,xvalues);
% [R_ac_intra_boom,P_ac_intra_boom] = corrcoef([ac_before_boom(1:9,1:250)' ac_during_boom(1:9,1:250)' ac_after_boom(1:9,1:250)']);
% M_ac_intra_boom = check_CCA_R_beepi(R_ac_intra_boom,P_ac_intra_boom,xvalues);
% [R_ac_intra_crying,P_ac_intra_crying] = corrcoef([ac_before_crying(1:9,1:250)' ac_during_crying(1:9,1:250)' ac_after_crying(1:9,1:250)']);
% M_ac_intra_crying = check_CCA_R_beepi(R_ac_intra_crying,P_ac_intra_crying,xvalues);
% [R_ac_intra_laughing,P_ac_intra_laughing] = corrcoef([ac_before_laughing(1:9,1:250)' ac_during_laughing(1:9,1:250)' ac_after_laughing(1:9,1:250)']);
% M_ac_intra_laughing = check_CCA_R_beepi(R_ac_intra_laughing,P_ac_intra_laughing,xvalues);
% [R_ac_intra_ringing,P_ac_intra_ringing] = corrcoef([ac_before_ringing(1:9,1:250)' ac_during_ringing(1:9,1:250)' ac_after_ringing(1:9,1:250)']);
% M_ac_intra_ringing = check_CCA_R_beepi(R_ac_intra_ringing,P_ac_intra_ringing,xvalues);
% [R_ac_intra_thunder,P_ac_intra_thunder] = corrcoef([ac_before_thunder(1:9,1:250)' ac_during_thunder(1:9,1:250)' ac_after_thunder(1:9,1:250)']);
% M_ac_intra_thunder = check_CCA_R_beepi(R_ac_intra_thunder,P_ac_intra_thunder,xvalues);

%% BZ (Bruno Zorro)

[R_bz_intra_1kHz,P_bz_intra_1kHz] = corrcoef([bz_before_1kHz(1:9,251:500)', bz_during_1kHz(1:9,1:250)', bz_after_1kHz(1:9,1:250)']);
M_bz_intra_1kHz = check_CCA_R_beepi(R_bz_intra_1kHz,P_bz_intra_1kHz,xvalues);
% H_bz_intra_1kHz = HeatMap(R_bz_intra_1kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_bz_intra_1kHz);
[R_bz_intra_2kHz,P_bz_intra_2kHz] = corrcoef([bz_before_2kHz(1:9,251:500)', bz_during_2kHz(1:9,1:250)', bz_after_2kHz(1:9,1:250)']);
M_bz_intra_2kHz = check_CCA_R_beepi(R_bz_intra_2kHz,P_bz_intra_2kHz,xvalues);
% H_bz_intra_2kHz = HeatMap(R_bz_intra_2kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_bz_intra_2kHz);
[R_bz_intra_3kHz,P_bz_intra_3kHz] = corrcoef([bz_before_3kHz(1:9,251:500)', bz_during_3kHz(1:9,1:250)', bz_after_3kHz(1:9,1:250)']);
M_bz_intra_3kHz = check_CCA_R_beepi(R_bz_intra_3kHz,P_bz_intra_3kHz,xvalues);
% H_bz_intra_3kHz = HeatMap(R_bz_intra_3kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_bz_intra_3kHz);


% [R_bz_intra_birds,P_bz_intra_birds] = corrcoef([bz_before_birds(1:9,1:250)' bz_during_birds(1:9,1:250)' bz_after_birds(1:9,1:250)']);
% M_bz_intra_birds = check_CCA_R_beepi(R_bz_intra_birds,P_bz_intra_birds,xvalues);
% [R_bz_intra_boom,P_bz_intra_boom] = corrcoef([bz_before_boom(1:9,1:250)' bz_during_boom(1:9,1:250)' bz_after_boom(1:9,1:250)']);
% M_bz_intra_boom = check_CCA_R_beepi(R_bz_intra_boom,P_bz_intra_boom,xvalues);
% [R_bz_intra_crying,P_bz_intra_crying] = corrcoef([bz_before_crying(1:9,1:250)' bz_during_crying(1:9,1:250)' bz_after_crying(1:9,1:250)']);
% M_bz_intra_crying = check_CCA_R_beepi(R_bz_intra_crying,P_bz_intra_crying,xvalues);
% [R_bz_intra_laughing,P_bz_intra_laughing] = corrcoef([bz_before_laughing(1:9,1:250)' bz_during_laughing(1:9,1:250)' bz_after_laughing(1:9,1:250)']);
% M_bz_intra_laughing = check_CCA_R_beepi(R_bz_intra_laughing,P_bz_intra_laughing,xvalues);
% [R_bz_intra_ringing,P_bz_intra_ringing] = corrcoef([bz_before_ringing(1:9,1:250)' bz_during_ringing(1:9,1:250)' bz_after_ringing(1:9,1:250)']);
% M_bz_intra_ringing = check_CCA_R_beepi(R_bz_intra_ringing,P_bz_intra_ringing,xvalues);
% [R_bz_intra_thunder,P_bz_intra_thunder] = corrcoef([bz_before_thunder(1:9,1:250)' bz_during_thunder(1:9,1:250)' bz_after_thunder(1:9,1:250)']);
% M_bz_intra_thunder = check_CCA_R_beepi(R_bz_intra_thunder,P_bz_intra_thunder,xvalues);

%% JL (Joao Loureiro)

[R_jl_intra_1kHz,P_jl_intra_1kHz] = corrcoef([jl_before_1kHz(1:9,251:500)', jl_during_1kHz(1:9,1:250)', jl_after_1kHz(1:9,1:250)']);
M_jl_intra_1kHz = check_CCA_R_beepi(R_jl_intra_1kHz,P_jl_intra_1kHz,xvalues);
% H_jl_intra_1kHz = HeatMap(R_jl_intra_1kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_jl_intra_1kHz);
[R_jl_intra_2kHz,P_jl_intra_2kHz] = corrcoef([jl_before_2kHz(1:9,251:500)', jl_during_2kHz(1:9,1:250)', jl_after_2kHz(1:9,1:250)']);
M_jl_intra_2kHz = check_CCA_R_beepi(R_jl_intra_2kHz,P_jl_intra_2kHz,xvalues);
% H_jl_intra_2kHz = HeatMap(R_jl_intra_2kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_jl_intra_2kHz);
[R_jl_intra_3kHz,P_jl_intra_3kHz] = corrcoef([jl_before_3kHz(1:9,251:500)', jl_during_3kHz(1:9,1:250)', jl_after_3kHz(1:9,1:250)']);
M_jl_intra_3kHz = check_CCA_R_beepi(R_jl_intra_3kHz,P_jl_intra_3kHz,xvalues);
% H_jl_intra_3kHz = HeatMap(R_jl_intra_3kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_jl_intra_3kHz);


% [R_jl_intra_birds,P_jl_intra_birds] = corrcoef([jl_before_birds(1:9,1:250)' jl_during_birds(1:9,1:250)' jl_after_birds(1:9,1:250)']);
% M_jl_intra_birds = check_CCA_R_beepi(R_jl_intra_birds,P_jl_intra_birds,xvalues);
% [R_jl_intra_boom,P_jl_intra_boom] = corrcoef([jl_before_boom(1:9,1:250)' jl_during_boom(1:9,1:250)' jl_after_boom(1:9,1:250)']);
% M_jl_intra_boom = check_CCA_R_beepi(R_jl_intra_boom,P_jl_intra_boom,xvalues);
% [R_jl_intra_crying,P_jl_intra_crying] = corrcoef([jl_before_crying(1:9,1:250)' jl_during_crying(1:9,1:250)' jl_after_crying(1:9,1:250)']);
% M_jl_intra_crying = check_CCA_R_beepi(R_jl_intra_crying,P_jl_intra_crying,xvalues);
% [R_jl_intra_laughing,P_jl_intra_laughing] = corrcoef([jl_before_laughing(1:9,1:250)' jl_during_laughing(1:9,1:250)' jl_after_laughing(1:9,1:250)']);
% M_jl_intra_laughing = check_CCA_R_beepi(R_jl_intra_laughing,P_jl_intra_laughing,xvalues);
% [R_jl_intra_ringing,P_jl_intra_ringing] = corrcoef([jl_before_ringing(1:9,1:250)' jl_during_ringing(1:9,1:250)' jl_after_ringing(1:9,1:250)']);
% M_jl_intra_ringing = check_CCA_R_beepi(R_jl_intra_ringing,P_jl_intra_ringing,xvalues);
% [R_jl_intra_thunder,P_jl_intra_thunder] = corrcoef([jl_before_thunder(1:9,1:250)' jl_during_thunder(1:9,1:250)' jl_after_thunder(1:9,1:250)']);
% M_jl_intra_thunder = check_CCA_R_beepi(R_jl_intra_thunder,P_jl_intra_thunder,xvalues);

%% WN (Walter Nunes)

[R_wn_intra_1kHz,P_wn_intra_1kHz] = corrcoef([wn_before_1kHz(1:9,251:500)', wn_during_1kHz(1:9,1:250)', wn_after_1kHz(1:9,1:250)']);
M_wn_intra_1kHz = check_CCA_R_beepi(R_wn_intra_1kHz,P_wn_intra_1kHz,xvalues);
% H_wn_intra_1kHz = HeatMap(R_wn_intra_1kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_wn_intra_1kHz);
[R_wn_intra_2kHz,P_wn_intra_2kHz] = corrcoef([wn_before_2kHz(1:9,251:500)', wn_during_2kHz(1:9,1:250)', wn_after_2kHz(1:9,1:250)']);
M_wn_intra_2kHz = check_CCA_R_beepi(R_wn_intra_2kHz,P_wn_intra_2kHz,xvalues);
% H_wn_intra_2kHz = HeatMap(R_wn_intra_2kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_wn_intra_2kHz);
[R_wn_intra_3kHz,P_wn_intra_3kHz] = corrcoef([wn_before_3kHz(1:9,251:500)', wn_during_3kHz(1:9,1:250)', wn_after_3kHz(1:9,1:250)']);
M_wn_intra_3kHz = check_CCA_R_beepi(R_wn_intra_3kHz,P_wn_intra_3kHz,xvalues);
% H_wn_intra_3kHz = HeatMap(R_wn_intra_3kHz,'Colormap',redbluecmap,'Annotate',true,'ColumnLabels',xvalues,'RowLabels',yvalues,'DisplayRange', 1);
L = levels(R_wn_intra_3kHz);


% [R_wn_intra_birds,P_wn_intra_birds] = corrcoef([wn_before_birds(1:9,1:250)' wn_during_birds(1:9,1:250)' wn_after_birds(1:9,1:250)']);
% M_wn_intra_birds = check_CCA_R_beepi(R_wn_intra_birds,P_wn_intra_birds,xvalues);
% [R_wn_intra_boom,P_wn_intra_boom] = corrcoef([wn_before_boom(1:9,1:250)' wn_during_boom(1:9,1:250)' wn_after_boom(1:9,1:250)']);
% M_wn_intra_boom = check_CCA_R_beepi(R_wn_intra_boom,P_wn_intra_boom,xvalues);
% [R_wn_intra_crying,P_wn_intra_crying] = corrcoef([wn_before_crying(1:9,1:250)' wn_during_crying(1:9,1:250)' wn_after_crying(1:9,1:250)']);
% M_wn_intra_crying = check_CCA_R_beepi(R_wn_intra_crying,P_wn_intra_crying,xvalues);
% [R_wn_intra_laughing,P_wn_intra_laughing] = corrcoef([wn_before_laughing(1:9,1:250)' wn_during_laughing(1:9,1:250)' wn_after_laughing(1:9,1:250)']);
% M_wn_intra_laughing = check_CCA_R_beepi(R_wn_intra_laughing,P_wn_intra_laughing,xvalues);
% [R_wn_intra_ringing,P_wn_intra_ringing] = corrcoef([wn_before_ringing(1:9,1:250)' wn_during_ringing(1:9,1:250)' wn_after_ringing(1:9,1:250)']);
% M_wn_intra_ringing = check_CCA_R_beepi(R_wn_intra_ringing,P_wn_intra_ringing,xvalues);
% [R_wn_intra_thunder,P_wn_intra_thunder] = corrcoef([wn_before_thunder(1:9,1:250)' wn_during_thunder(1:9,1:250)' wn_after_thunder(1:9,1:250)']);
% M_wn_intra_thunder = check_CCA_R_beepi(R_wn_intra_thunder,P_wn_intra_thunder,xvalues);