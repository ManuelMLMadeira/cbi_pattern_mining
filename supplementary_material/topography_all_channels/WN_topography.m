clear all
close all
%% Get coordinates of channels
% figure;brain=imread('brain.JPG');
% imshow(brain)
% [y x]=ginput(3);
% ch=[x y];
% %save('ch','ch')
% %ORDEM: [F3,F4,C3,Cz,C4,P3,P4,O1,O2]

%% Loading variables
load ch

%load channels
load('wn_beep_after.mat')
load('wn_beep_before.mat')
load('wn_beep_during.mat')
load('wn_birds_after.mat')
load('wn_birds_before.mat')
load('wn_birds_during.mat')
load('wn_boom_after.mat')
load('wn_boom_before.mat')
load('wn_boom_during.mat')
load('wn_crying_after.mat')
load('wn_crying_before.mat')
load('wn_crying_during.mat')
load('wn_laughing_after.mat')
load('wn_laughing_before.mat')
load('wn_laughing_during.mat')
load('wn_ringing_after.mat')
load('wn_ringing_before.mat')
load('wn_ringing_during.mat')
load('wn_thunder_after.mat')
load('wn_thunder_before.mat')
load('wn_thunder_during.mat')

%% 1kHz beep
%Area under curve - Trapz
l_before = length(F3_before(1,:));
l_during = length(F3_during(1,:));
l_after = length(F3_after(1,:));

mag_bef_1k = [trapz(l_before,mean(F3_before(1:12,:)));
    trapz(l_before,mean(F4_before(1:12,:))); 
    trapz(l_before,mean(C3_before(1:12,:)));
    trapz(l_before,mean(Cz_before(1:12,:)));
    trapz(l_before,mean(C4_before(1:12,:)));
    trapz(l_before,mean(P3_before(1:12,:)));
    trapz(l_before,mean(P4_before(1:12,:)));
    trapz(l_before,mean(O1_before(1:12,:)));
    trapz(l_before,mean(O2_before(1:12,:)))];

mag_dur_1k = [trapz(l_during,mean(F3_during(1:12,:)));
    trapz(l_during,mean(F4_during(1:12,:))); 
    trapz(l_during,mean(C3_during(1:12,:)));
    trapz(l_during,mean(Cz_during(1:12,:)));
    trapz(l_during,mean(C4_during(1:12,:)));
    trapz(l_during,mean(P3_during(1:12,:)));
    trapz(l_during,mean(P4_during(1:12,:)));
    trapz(l_during,mean(O1_during(1:12,:)));
    trapz(l_during,mean(O2_during(1:12,:)))];

mag_aft_1k = [trapz(l_after,mean(F3_after(1:12,:)));
    trapz(l_after,mean(F4_after(1:12,:))); 
    trapz(l_after,mean(C3_after(1:12,:)));
    trapz(l_after,mean(Cz_after(1:12,:)));
    trapz(l_after,mean(C4_after(1:12,:)));
    trapz(l_after,mean(P3_after(1:12,:)));
    trapz(l_after,mean(P4_after(1:12,:)));
    trapz(l_after,mean(O1_after(1:12,:)));
    trapz(l_after,mean(O2_after(1:12,:)))];


%% Topography of 1kHz

figure;brain=imread('brain.JPG');
imshow(brain)

figure;
subplot 131
[z,map] = eegplot(mag_bef_1k,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels before 1kHz beep, wn')
drawnow;

subplot 132
[z,map] = eegplot(mag_dur_1k,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels during 1kHz beep, wn')
drawnow;

subplot 133
[z,map] = eegplot(mag_aft_1k,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels after 1kHz beep, wn')
drawnow;


%% 2kHz beep

%Area under curve - Trapz
l_before = length(F3_before(13,:));
l_during = length(F3_during(13,:));
l_after = length(F3_after(13,:));

mag_bef_2k = [trapz(l_before,mean(F3_before(13:24,:)));
    trapz(l_before,mean(F4_before(13:24,:))); 
    trapz(l_before,mean(C3_before(13:24,:)));
    trapz(l_before,mean(Cz_before(13:24,:)));
    trapz(l_before,mean(C4_before(13:24,:)));
    trapz(l_before,mean(P3_before(13:24,:)));
    trapz(l_before,mean(P4_before(13:24,:)));
    trapz(l_before,mean(O1_before(13:24,:)));
    trapz(l_before,mean(O2_before(13:24,:)))];

mag_dur_2k = [trapz(l_during,mean(F3_during(13:24,:)));
    trapz(l_during,mean(F4_during(13:24,:))); 
    trapz(l_during,mean(C3_during(13:24,:)));
    trapz(l_during,mean(Cz_during(13:24,:)));
    trapz(l_during,mean(C4_during(13:24,:)));
    trapz(l_during,mean(P3_during(13:24,:)));
    trapz(l_during,mean(P4_during(13:24,:)));
    trapz(l_during,mean(O1_during(13:24,:)));
    trapz(l_during,mean(O2_during(13:24,:)))];

mag_aft_2k = [trapz(l_after,mean(F3_after(13:24,:)));
    trapz(l_after,mean(F4_after(13:24,:))); 
    trapz(l_after,mean(C3_after(13:24,:)));
    trapz(l_after,mean(Cz_after(13:24,:)));
    trapz(l_after,mean(C4_after(13:24,:)));
    trapz(l_after,mean(P3_after(13:24,:)));
    trapz(l_after,mean(P4_after(13:24,:)));
    trapz(l_after,mean(O1_after(13:24,:)));
    trapz(l_after,mean(O2_after(13:24,:)))];


%% Topography of 2kHz


figure;
subplot 131
[z,map] = eegplot(mag_bef_2k,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels before 2kHz beep, wn')
drawnow;

subplot 132
[z,map] = eegplot(mag_dur_2k,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels during 2kHz beep, wn')
drawnow;

subplot 133
[z,map] = eegplot(mag_aft_2k,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels after 2kHz beep, wn')
drawnow;

%% 3kHz beep

%Area under curve - Trapz
l_before = length(F3_before(25,:));
l_during = length(F3_during(25,:));
l_after = length(F3_after(25,:));

mag_bef_3k = [trapz(l_before,mean(F3_before(25:36,:)));
    trapz(l_before,mean(F4_before(25:36,:))); 
    trapz(l_before,mean(C3_before(25:36,:)));
    trapz(l_before,mean(Cz_before(25:36,:)));
    trapz(l_before,mean(C4_before(25:36,:)));
    trapz(l_before,mean(P3_before(25:36,:)));
    trapz(l_before,mean(P4_before(25:36,:)));
    trapz(l_before,mean(O1_before(25:36,:)));
    trapz(l_before,mean(O2_before(25:36,:)))];

mag_dur_3k = [trapz(l_during,mean(F3_during(25:36,:)));
    trapz(l_during,mean(F4_during(25:36,:))); 
    trapz(l_during,mean(C3_during(25:36,:)));
    trapz(l_during,mean(Cz_during(25:36,:)));
    trapz(l_during,mean(C4_during(25:36,:)));
    trapz(l_during,mean(P3_during(25:36,:)));
    trapz(l_during,mean(P4_during(25:36,:)));
    trapz(l_during,mean(O1_during(25:36,:)));
    trapz(l_during,mean(O2_during(25:36,:)))];

mag_aft_3k = [trapz(l_after,mean(F3_after(25:36,:)));
    trapz(l_after,mean(F4_after(25:36,:))); 
    trapz(l_after,mean(C3_after(25:36,:)));
    trapz(l_after,mean(Cz_after(25:36,:)));
    trapz(l_after,mean(C4_after(25:36,:)));
    trapz(l_after,mean(P3_after(25:36,:)));
    trapz(l_after,mean(P4_after(25:36,:)));
    trapz(l_after,mean(O1_after(25:36,:)));
    trapz(l_after,mean(O2_after(25:36,:)))];


%% Topography of 3kHz


figure;
subplot 131
[z,map] = eegplot(mag_bef_3k,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels before 3kHz beep, wn')
drawnow;

subplot 132
[z,map] = eegplot(mag_dur_3k,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels during 3kHz beep, wn')
drawnow;

subplot 133
[z,map] = eegplot(mag_aft_3k,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels after 3kHz beep, wn')
drawnow;

%% Boom

%Area under curve - Trapz
l_before = length(boom_F3_before(1,:));
l_during = length(boom_F3_during(1,:));
l_after = length(boom_F3_after(1,:));

mag_bef_boom = [trapz(l_before,mean(boom_F3_before(1:3,:)));
    trapz(l_before,mean(boom_F4_before(1:3,:))); 
    trapz(l_before,mean(boom_C3_before(1:3,:)));
    trapz(l_before,mean(boom_Cz_before(1:3,:)));
    trapz(l_before,mean(boom_C4_before(1:3,:)));
    trapz(l_before,mean(boom_P3_before(1:3,:)));
    trapz(l_before,mean(boom_P4_before(1:3,:)));
    trapz(l_before,mean(boom_O1_before(1:3,:)));
    trapz(l_before,mean(boom_O2_before(1:3,:)))];

mag_dur_boom = [trapz(l_during,mean(boom_F3_during(1:3,:)));
    trapz(l_during,mean(boom_F4_during(1:3,:))); 
    trapz(l_during,mean(boom_C3_during(1:3,:)));
    trapz(l_during,mean(boom_Cz_during(1:3,:)));
    trapz(l_during,mean(boom_C4_during(1:3,:)));
    trapz(l_during,mean(boom_P3_during(1:3,:)));
    trapz(l_during,mean(boom_P4_during(1:3,:)));
    trapz(l_during,mean(boom_O1_during(1:3,:)));
    trapz(l_during,mean(boom_O2_during(1:3,:)))];

mag_aft_boom = [trapz(l_after,mean(boom_F3_after(1:3,:)));
    trapz(l_after,mean(boom_F4_after(1:3,:))); 
    trapz(l_after,mean(boom_C3_after(1:3,:)));
    trapz(l_after,mean(boom_Cz_after(1:3,:)));
    trapz(l_after,mean(boom_C4_after(1:3,:)));
    trapz(l_after,mean(boom_P3_after(1:3,:)));
    trapz(l_after,mean(boom_P4_after(1:3,:)));
    trapz(l_after,mean(boom_O1_after(1:3,:)));
    trapz(l_after,mean(boom_O2_after(1:3,:)))];


%% Topography of Boom

figure;
subplot 131
[z,map] = eegplot(mag_bef_boom,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels before boom, wn')
drawnow;

subplot 132
[z,map] = eegplot(mag_dur_boom,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels during boom, wn')
drawnow;

subplot 133
[z,map] = eegplot(mag_aft_boom,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels after Boom, wn')
drawnow;

%% Ringing

%Area under curve - Trapz
l_before = length(ringing_F3_before(1,:));
l_during = length(ringing_F3_during(1,:));
l_after = length(ringing_F3_after(1,:));

mag_bef_ringing = [trapz(l_before,mean(ringing_F3_before(1:3,:)));
    trapz(l_before,mean(ringing_F4_before(1:3,:))); 
    trapz(l_before,mean(ringing_C3_before(1:3,:)));
    trapz(l_before,mean(ringing_Cz_before(1:3,:)));
    trapz(l_before,mean(ringing_C4_before(1:3,:)));
    trapz(l_before,mean(ringing_P3_before(1:3,:)));
    trapz(l_before,mean(ringing_P4_before(1:3,:)));
    trapz(l_before,mean(ringing_O1_before(1:3,:)));
    trapz(l_before,mean(ringing_O2_before(1:3,:)))];

mag_dur_ringing = [trapz(l_during,mean(ringing_F3_during(1:3,:)));
    trapz(l_during,mean(ringing_F4_during(1:3,:))); 
    trapz(l_during,mean(ringing_C3_during(1:3,:)));
    trapz(l_during,mean(ringing_Cz_during(1:3,:)));
    trapz(l_during,mean(ringing_C4_during(1:3,:)));
    trapz(l_during,mean(ringing_P3_during(1:3,:)));
    trapz(l_during,mean(ringing_P4_during(1:3,:)));
    trapz(l_during,mean(ringing_O1_during(1:3,:)));
    trapz(l_during,mean(ringing_O2_during(1:3,:)))];

mag_aft_ringing = [trapz(l_after,mean(ringing_F3_after(1:3,:)));
    trapz(l_after,mean(ringing_F4_after(1:3,:))); 
    trapz(l_after,mean(ringing_C3_after(1:3,:)));
    trapz(l_after,mean(ringing_Cz_after(1:3,:)));
    trapz(l_after,mean(ringing_C4_after(1:3,:)));
    trapz(l_after,mean(ringing_P3_after(1:3,:)));
    trapz(l_after,mean(ringing_P4_after(1:3,:)));
    trapz(l_after,mean(ringing_O1_after(1:3,:)));
    trapz(l_after,mean(ringing_O2_after(1:3,:)))];


%% Topography of ringing

figure;
subplot 131
[z,map] = eegplot(mag_bef_ringing,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels before ringing, wn')
drawnow;

subplot 132
[z,map] = eegplot(mag_dur_ringing,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels during ringing, wn')
drawnow;

subplot 133
[z,map] = eegplot(mag_aft_ringing,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels after ringing, wn')
drawnow;

%% Crying

%Area under curve - Trapz
l_before = length(crying_F3_before(1,:));
l_during = length(crying_F3_during(1,:));
l_after = length(crying_F3_after(1,:));

mag_bef_crying = [trapz(l_before,mean(crying_F3_before(1:3,:)));
    trapz(l_before,mean(crying_F4_before(1:3,:))); 
    trapz(l_before,mean(crying_C3_before(1:3,:)));
    trapz(l_before,mean(crying_Cz_before(1:3,:)));
    trapz(l_before,mean(crying_C4_before(1:3,:)));
    trapz(l_before,mean(crying_P3_before(1:3,:)));
    trapz(l_before,mean(crying_P4_before(1:3,:)));
    trapz(l_before,mean(crying_O1_before(1:3,:)));
    trapz(l_before,mean(crying_O2_before(1:3,:)))];

mag_dur_crying = [trapz(l_during,mean(crying_F3_during(1:3,:)));
    trapz(l_during,mean(crying_F4_during(1:3,:))); 
    trapz(l_during,mean(crying_C3_during(1:3,:)));
    trapz(l_during,mean(crying_Cz_during(1:3,:)));
    trapz(l_during,mean(crying_C4_during(1:3,:)));
    trapz(l_during,mean(crying_P3_during(1:3,:)));
    trapz(l_during,mean(crying_P4_during(1:3,:)));
    trapz(l_during,mean(crying_O1_during(1:3,:)));
    trapz(l_during,mean(crying_O2_during(1:3,:)))];

mag_aft_crying = [trapz(l_after,mean(crying_F3_after(1:3,:)));
    trapz(l_after,mean(crying_F4_after(1:3,:))); 
    trapz(l_after,mean(crying_C3_after(1:3,:)));
    trapz(l_after,mean(crying_Cz_after(1:3,:)));
    trapz(l_after,mean(crying_C4_after(1:3,:)));
    trapz(l_after,mean(crying_P3_after(1:3,:)));
    trapz(l_after,mean(crying_P4_after(1:3,:)));
    trapz(l_after,mean(crying_O1_after(1:3,:)));
    trapz(l_after,mean(crying_O2_after(1:3,:)))];


%% Topography of crying


figure;
subplot 131
[z,map] = eegplot(mag_bef_crying,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels before crying, wn')
drawnow;

subplot 132
[z,map] = eegplot(mag_dur_crying,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels during crying, wn')
drawnow;

subplot 133
[z,map] = eegplot(mag_aft_crying,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels after crying, wn')
drawnow;
%% Laughing

%Area under curve - Trapz
l_before = length(laughing_F3_before(1,:));
l_during = length(laughing_F3_during(1,:));
l_after = length(laughing_F3_after(1,:));

mag_bef_laughing = [trapz(l_before,mean(laughing_F3_before(1:3,:)));
    trapz(l_before,mean(laughing_F4_before(1:3,:))); 
    trapz(l_before,mean(laughing_C3_before(1:3,:)));
    trapz(l_before,mean(laughing_Cz_before(1:3,:)));
    trapz(l_before,mean(laughing_C4_before(1:3,:)));
    trapz(l_before,mean(laughing_P3_before(1:3,:)));
    trapz(l_before,mean(laughing_P4_before(1:3,:)));
    trapz(l_before,mean(laughing_O1_before(1:3,:)));
    trapz(l_before,mean(laughing_O2_before(1:3,:)))];

mag_dur_laughing = [trapz(l_during,mean(laughing_F3_during(1:3,:)));
    trapz(l_during,mean(laughing_F4_during(1:3,:))); 
    trapz(l_during,mean(laughing_C3_during(1:3,:)));
    trapz(l_during,mean(laughing_Cz_during(1:3,:)));
    trapz(l_during,mean(laughing_C4_during(1:3,:)));
    trapz(l_during,mean(laughing_P3_during(1:3,:)));
    trapz(l_during,mean(laughing_P4_during(1:3,:)));
    trapz(l_during,mean(laughing_O1_during(1:3,:)));
    trapz(l_during,mean(laughing_O2_during(1:3,:)))];

mag_aft_laughing = [trapz(l_after,mean(laughing_F3_after(1:3,:)));
    trapz(l_after,mean(laughing_F4_after(1:3,:))); 
    trapz(l_after,mean(laughing_C3_after(1:3,:)));
    trapz(l_after,mean(laughing_Cz_after(1:3,:)));
    trapz(l_after,mean(laughing_C4_after(1:3,:)));
    trapz(l_after,mean(laughing_P3_after(1:3,:)));
    trapz(l_after,mean(laughing_P4_after(1:3,:)));
    trapz(l_after,mean(laughing_O1_after(1:3,:)));
    trapz(l_after,mean(laughing_O2_after(1:3,:)))];


%% Topography of laughing

figure;
subplot 131
[z,map] = eegplot(mag_bef_laughing,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels before laughing, wn')
drawnow;

subplot 132
[z,map] = eegplot(mag_dur_laughing,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels during laughing, wn')
drawnow;

subplot 133
[z,map] = eegplot(mag_aft_laughing,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels after laughing, wn')
drawnow;

%% Birds

%Area under curve - Trapz
l_before = length(birds_F3_before(1,:));
l_during = length(birds_F3_during(1,:));
l_after = length(birds_F3_after(1,:));

mag_bef_birds = [trapz(l_before,mean(birds_F3_before(1:3,:)));
    trapz(l_before,mean(birds_F4_before(1:3,:))); 
    trapz(l_before,mean(birds_C3_before(1:3,:)));
    trapz(l_before,mean(birds_Cz_before(1:3,:)));
    trapz(l_before,mean(birds_C4_before(1:3,:)));
    trapz(l_before,mean(birds_P3_before(1:3,:)));
    trapz(l_before,mean(birds_P4_before(1:3,:)));
    trapz(l_before,mean(birds_O1_before(1:3,:)));
    trapz(l_before,mean(birds_O2_before(1:3,:)))];

mag_dur_birds = [trapz(l_during,mean(birds_F3_during(1:3,:)));
    trapz(l_during,mean(birds_F4_during(1:3,:))); 
    trapz(l_during,mean(birds_C3_during(1:3,:)));
    trapz(l_during,mean(birds_Cz_during(1:3,:)));
    trapz(l_during,mean(birds_C4_during(1:3,:)));
    trapz(l_during,mean(birds_P3_during(1:3,:)));
    trapz(l_during,mean(birds_P4_during(1:3,:)));
    trapz(l_during,mean(birds_O1_during(1:3,:)));
    trapz(l_during,mean(birds_O2_during(1:3,:)))];

mag_aft_birds = [trapz(l_after,mean(birds_F3_after(1:3,:)));
    trapz(l_after,mean(birds_F4_after(1:3,:))); 
    trapz(l_after,mean(birds_C3_after(1:3,:)));
    trapz(l_after,mean(birds_Cz_after(1:3,:)));
    trapz(l_after,mean(birds_C4_after(1:3,:)));
    trapz(l_after,mean(birds_P3_after(1:3,:)));
    trapz(l_after,mean(birds_P4_after(1:3,:)));
    trapz(l_after,mean(birds_O1_after(1:3,:)));
    trapz(l_after,mean(birds_O2_after(1:3,:)))];


%% Topography of birds

figure;
subplot 131
[z,map] = eegplot(mag_bef_birds,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels before birds, wn')
drawnow;

subplot 132
[z,map] = eegplot(mag_dur_birds,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels during birds, wn')
drawnow;

subplot 133
[z,map] = eegplot(mag_aft_birds,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels after birds, wn')
drawnow;

%% Thunder

%Area under curve - Trapz
l_before = length(thunder_F3_before(1,:));
l_during = length(thunder_F3_during(1,:));
l_after = length(thunder_F3_after(1,:));

mag_bef_thunder = [trapz(l_before,mean(thunder_F3_before(1:3,:)));
    trapz(l_before,mean(thunder_F4_before(1:3,:))); 
    trapz(l_before,mean(thunder_C3_before(1:3,:)));
    trapz(l_before,mean(thunder_Cz_before(1:3,:)));
    trapz(l_before,mean(thunder_C4_before(1:3,:)));
    trapz(l_before,mean(thunder_P3_before(1:3,:)));
    trapz(l_before,mean(thunder_P4_before(1:3,:)));
    trapz(l_before,mean(thunder_O1_before(1:3,:)));
    trapz(l_before,mean(thunder_O2_before(1:3,:)))];

mag_dur_thunder = [trapz(l_during,mean(thunder_F3_during(1:3,:)));
    trapz(l_during,mean(thunder_F4_during(1:3,:))); 
    trapz(l_during,mean(thunder_C3_during(1:3,:)));
    trapz(l_during,mean(thunder_Cz_during(1:3,:)));
    trapz(l_during,mean(thunder_C4_during(1:3,:)));
    trapz(l_during,mean(thunder_P3_during(1:3,:)));
    trapz(l_during,mean(thunder_P4_during(1:3,:)));
    trapz(l_during,mean(thunder_O1_during(1:3,:)));
    trapz(l_during,mean(thunder_O2_during(1:3,:)))];

mag_aft_thunder = [trapz(l_after,mean(thunder_F3_after(1:3,:)));
    trapz(l_after,mean(thunder_F4_after(1:3,:))); 
    trapz(l_after,mean(thunder_C3_after(1:3,:)));
    trapz(l_after,mean(thunder_Cz_after(1:3,:)));
    trapz(l_after,mean(thunder_C4_after(1:3,:)));
    trapz(l_after,mean(thunder_P3_after(1:3,:)));
    trapz(l_after,mean(thunder_P4_after(1:3,:)));
    trapz(l_after,mean(thunder_O1_after(1:3,:)));
    trapz(l_after,mean(thunder_O2_after(1:3,:)))];


%% Topography of thunder


figure;
subplot 131
[z,map] = eegplot(mag_bef_thunder,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels before thunder, wn')
drawnow;

subplot 132
[z,map] = eegplot(mag_dur_thunder,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels during thunder, wn')
drawnow;

subplot 133
[z,map] = eegplot(mag_aft_thunder,ch,[],1,[],[]);
imshow(z);
colormap(map)
colorbar
title('Mean of Channels after thunder, wn')
drawnow;
