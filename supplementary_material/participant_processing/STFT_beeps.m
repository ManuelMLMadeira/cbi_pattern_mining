
%% SPECTROGRAMS BEEPS

% mean of the 12 repetitions for each beep frequency
%spectrogram of the mean signals 
%limit of f from [0,60] to distinguish better the low scale values



%% F3 CHANNEL

%%          PARAMETERS

F3_total_1=[F3_before(1:12,:) F3_during(1:12,:) F3_after(1:12,:)];
F3_mean_1=mean(F3_total_1(1:12,:));
F3_fft_1=fft(F3_mean_1); 

F3_total_2=[F3_before(13:24,:) F3_during(13:24,:) F3_after(13:24,:)];
F3_mean_2=mean(F3_total_2(1:12,:));
F3_fft_2=fft(F3_mean_2); 

F3_total_3=[F3_before(25:36,:) F3_during(25:36,:) F3_after(25:36,:)];
F3_mean_3=mean(F3_total_3(1:12,:));
F3_fft_3=fft(F3_mean_3); 


% F3_total_1=[F3_before(1:12,:) F3_during(1:12,:) F3_after(1:12,:)];
% F3_beep_1=F3_total_1(1,:)
% F3_fft_1=fft(F3_beep_1); 
% 
% F3_total_2=[F3_before(13:24,:) F3_during(13:24,:) F3_after(13:24,:)];
% F3_beep_2=F3_total_2(1,:);
% F3_fft_2=fft(F3_beep_2); 
% 
% F3_total_3=[F3_before(25:36,:) F3_during(25:36,:) F3_after(25:36,:)];
% F3_beep_3=F3_total_3(1,:);
% F3_fft_3=fft(F3_beep_3); 

%%          Testing different windows
nfft=length(F3_fft_1);

figure;

subplot 221;
spectrogram(F3_mean_1,rectwin(256),floor(0.5*256),nfft,fs,'yaxis')
title('Rectangular window');

subplot 222;
spectrogram(F3_mean_1,triang(256),floor(0.5*256),nfft,fs,'yaxis')
title('Triangular window');

subplot 223;
spectrogram(F3_mean_1,gausswin(256),floor(0.5*256),nfft,fs,'yaxis')
title('Gaussian window');

subplot 224;
spectrogram(F3_mean_1,hamming(256),floor(0.5*256),nfft,fs,'yaxis')
title('Hamming window');

suptitle('Spectrograms using different windows');

% Due to the complexity of the sound, it is difficult to assess the best
% window for the laboratory purpose. As mentioned in exercice 1, tapered
% windows (all except rectangular) reduce spectral leakage, yet, they
% suffer a loss of spectral resolution, as obtained in the spectrograms.
% Normally, Hamming window is the most commonly used one due to its
% relatively low side lobes and relatively narrow main lobe. However, by
% the plots observation, it is difficult to conclude about which window
% should be used.
% Moreover, less information of the signal is lost due to the low side
% lobes of the tapered windows when overlap is applied, as previously
% discussed.


%%          Testing different overlaps

figure;
subplot 231;
spectrogram(F3_mean_1,hamming(256),0,nfft,fs,'yaxis')
title('0%');

subplot 232
spectrogram(F3_mean_1,hamming(256),floor(256*0.25),nfft,fs,'yaxis')
title('25%')

subplot 233;
spectrogram(F3_mean_1,hamming(256),floor(256*0.5),nfft,fs,'yaxis')
title('50%');

subplot 234;
spectrogram(F3_mean_1,hamming(256),floor(256*0.75),nfft,fs,'yaxis')
title('75%');

subplot 235
spectrogram(F3_mean_1,hamming(256),floor(0.9*256),nfft,fs,'yaxis')
title('90%');


suptitle('Spectrograms for different overlaps');

% By increasing the overlap, one can see that the time resolution of the
% spectrogram seems to improve, even if the effective time resolution is
% unchanged. This happens because, when there is more overlap, the signal
% is divided in more segments, and the assessment of frequency changes over
% time is enhanced. The spectrogram obtained is, consenquently smoother. 



%%          Testing different window lengths w (with 50% overlap and Hamming window)

figure;
subplot 231;
spectrogram(F3_mean_1,hamming(64),floor(64*0.5),nfft,fs,'yaxis')
title('w = 64');

subplot 232;
spectrogram(F3_mean_1,hamming(128),floor(128*0.5),nfft,fs,'yaxis')
title('w = 128');

subplot 233;
spectrogram(F3_mean_1,hamming(256),floor(256*0.5),nfft,fs,'yaxis')
title('w = 256');

subplot 234;
spectrogram(F3_mean_1,hamming(512),floor(512*0.5),nfft,fs,'yaxis')
title('w = 512');

subplot 235
spectrogram(F3_mean_1,hamming(1024),floor(1024*0.5),nfft,fs,'yaxis')
title('w=1024')


suptitle('Spectrograms for different window lengths');

% We can confirm that longer windows provide better frequency resolution,
% which is important in the case of complex signals with multiple
% frequencies which change in time. There is, however, a trade-off: the
% longer the window chosen, the worse the time resolution of the
% spectrogram. In order to analyse both the time and frequency of the
% audio signal, we must compromise with a window length short enough to
% have good time resolution, but long enough to capture the frequencies of
% interest.

%%           Ideal testing parameters

%windowing
wlen=256;
window= hamming(wlen);
nfft=length(F3_fft_1);
h=floor(0.5*wlen);


%plot of the spectrogram
figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
subplot 311
spectrogram(F3_mean_1,window,h,nfft,fs,'yaxis')
title('1Hz beep ')
ylim ([0,60]);

subplot 312
spectrogram(F3_mean_2,window,h,nfft,fs,'yaxis')
title('2Hz beep ')
ylim ([0,60]);

subplot 313
spectrogram(F3_mean_3,window,h,nfft,fs,'yaxis')
title(' 3Hz beep ')
ylim ([0,60]);

suptitle('F3 channel');

%% F4 CHANNEL

F4_total_1=[F4_before(1:12,:) F4_during(1:12,:) F4_after(1:12,:)];
F4_mean_1=mean(F4_total_1(1:12,:));
F4_fft_1=fft(F4_mean_1); 

F4_total_2=[F4_before(13:24,:) F4_during(13:24,:) F4_after(13:24,:)];
F4_mean_2=mean(F4_total_2(1:12,:));
F4_fft_2=fft(F4_mean_2); 

F4_total_3=[F4_before(25:36,:) F4_during(25:36,:) F4_after(25:36,:)];
F4_mean_3=mean(F4_total_3(1:12,:));
F4_fft_3=fft(F4_mean_3); 

%plot of the spectrogram
figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
subplot 311
spectrogram(F4_mean_1,window,h,nfft,fs,'yaxis')
title('1Hz beep ')
ylim ([0,60]);

subplot 312
spectrogram(F4_mean_2,window,h,nfft,fs,'yaxis')
title('2Hz beep ')
ylim ([0,60]);

subplot 313
spectrogram(F4_mean_3,window,h,nfft,fs,'yaxis')
title(' 3Hz beep ')
ylim ([0,60]);

suptitle('F4 channel');

%% P3 CHANNEL

P3_total_1=[P3_before(1:12,:) P3_during(1:12,:) P3_after(1:12,:)];
P3_mean_1=mean(P3_total_1(1:12,:));
P3_fft_1=fft(P3_mean_1); 

P3_total_2=[P3_before(13:24,:) P3_during(13:24,:) P3_after(13:24,:)];
P3_mean_2=mean(P3_total_2(1:12,:));
P3_fft_2=fft(P3_mean_2); 

P3_total_3=[P3_before(25:36,:) P3_during(25:36,:) P3_after(25:36,:)];
P3_mean_3=mean(P3_total_3(1:12,:));
P3_fft_3=fft(P3_mean_3); 

%plot of the spectrogram
figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
subplot 311
spectrogram(P3_mean_1,window,h,nfft,fs,'yaxis')
title('1Hz beep ')
ylim ([0,60]);

subplot 312
spectrogram(P3_mean_2,window,h,nfft,fs,'yaxis')
title('2Hz beep ')
ylim ([0,60]);

subplot 313
spectrogram(P3_mean_3,window,h,nfft,fs,'yaxis')
title(' 3Hz beep ')
ylim ([0,60]);

suptitle('P3 channel');

%% P4 CHANNEL

P4_total_1=[P4_before(1:12,:) P4_during(1:12,:) P4_after(1:12,:)];
P4_mean_1=mean(P4_total_1(1:12,:));
P4_fft_1=fft(P4_mean_1); 

P4_total_2=[P4_before(13:24,:) P4_during(13:24,:) P4_after(13:24,:)];
P4_mean_2=mean(P4_total_2(1:12,:));
P4_fft_2=fft(P4_mean_2); 

P4_total_3=[P4_before(25:36,:) P4_during(25:36,:) P4_after(25:36,:)];
P4_mean_3=mean(P4_total_3(1:12,:));
P4_fft_3=fft(P4_mean_3); 

%plot of the spectrogram
figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
subplot 311
spectrogram(P4_mean_1,window,h,nfft,fs,'yaxis')
title('1Hz beep ')
ylim ([0,60]);

subplot 312
spectrogram(P4_mean_2,window,h,nfft,fs,'yaxis')
title('2Hz beep ')
ylim ([0,60]);

subplot 313
spectrogram(P4_mean_3,window,h,nfft,fs,'yaxis')
title(' 3Hz beep ')
ylim ([0,60]);

suptitle('P4 channel');

%% C3 CHANNEL

C3_total_1=[C3_before(1:12,:) C3_during(1:12,:) C3_after(1:12,:)];
C3_mean_1=mean(C3_total_1(1:12,:));
C3_fft_1=fft(C3_mean_1); 

C3_total_2=[C3_before(13:24,:) C3_during(13:24,:) C3_after(13:24,:)];
C3_mean_2=mean(C3_total_2(1:12,:));
C3_fft_2=fft(C3_mean_2); 

C3_total_3=[C3_before(25:36,:) C3_during(25:36,:) C3_after(25:36,:)];
C3_mean_3=mean(C3_total_3(1:12,:));
C3_fft_3=fft(C3_mean_3); 


%plot of the spectrogram
figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
subplot 311
spectrogram(C3_mean_1,window,h,nfft,fs,'yaxis')
title('1Hz beep ')
ylim ([0,60]);

subplot 312
spectrogram(C3_mean_2,window,h,nfft,fs,'yaxis')
title('2Hz beep ')
ylim ([0,60]);

subplot 313
spectrogram(C3_mean_3,window,h,nfft,fs,'yaxis')
title(' 3Hz beep ')
ylim ([0,60]);

suptitle('C3 channel');

%% Cz CHANNEL

Cz_total_1=[Cz_before(1:12,:) Cz_during(1:12,:) Cz_after(1:12,:)];
Cz_mean_1=mean(Cz_total_1(1:12,:));
Cz_fft_1=fft(Cz_mean_1); 

Cz_total_2=[Cz_before(13:24,:) Cz_during(13:24,:) Cz_after(13:24,:)];
Cz_mean_2=mean(Cz_total_2(1:12,:));
Cz_fft_2=fft(Cz_mean_2); 

Cz_total_3=[Cz_before(25:36,:) Cz_during(25:36,:) Cz_after(25:36,:)];
Cz_mean_3=mean(Cz_total_3(1:12,:));
Cz_fft_3=fft(Cz_mean_3); 


%plot of the spectrogram
figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
subplot 311
spectrogram(Cz_mean_1,window,h,nfft,fs,'yaxis')
title('1Hz beep ')
ylim ([0,60]);

subplot 312
spectrogram(Cz_mean_2,window,h,nfft,fs,'yaxis')
title('2Hz beep ')
ylim ([0,60]);

subplot 313
spectrogram(Cz_mean_3,window,h,nfft,fs,'yaxis')
title(' 3Hz beep ')
ylim ([0,60]);

suptitle('Cz channel');

%% C4 CHANNEL

C4_total_1=[C4_before(1:12,:) C4_during(1:12,:) C4_after(1:12,:)];
C4_mean_1=mean(C4_total_1(1:12,:));
C4_fft_1=fft(C4_mean_1); 

C4_total_2=[C4_before(13:24,:) C4_during(13:24,:) C4_after(13:24,:)];
C4_mean_2=mean(C4_total_2(1:12,:));
C4_fft_2=fft(C4_mean_2); 

C4_total_3=[C4_before(25:36,:) C4_during(25:36,:) C4_after(25:36,:)];
C4_mean_3=mean(C4_total_3(1:12,:));
C4_fft_3=fft(C4_mean_3); 


%plot of the spectrogram
figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
subplot 311
spectrogram(C4_mean_1,window,h,nfft,fs,'yaxis')
title('1Hz beep ')
ylim ([0,60]);

subplot 312
spectrogram(C4_mean_2,window,h,nfft,fs,'yaxis')
title('2Hz beep ')
ylim ([0,60]);

subplot 313
spectrogram(C4_mean_3,window,h,nfft,fs,'yaxis')
title(' 3Hz beep ')
ylim ([0,60]);

suptitle('C4 channel');

%% 01 CHANNEL

O1_total_1=[O1_before(1:12,:) O1_during(1:12,:) O1_after(1:12,:)];
O1_mean_1=mean(O1_total_1(1:12,:));
O1_fft_1=fft(O1_mean_1); 

O1_total_2=[O1_before(13:24,:) O1_during(13:24,:) O1_after(13:24,:)];
O1_mean_2=mean(O1_total_2(1:12,:));
O1_fft_2=fft(O1_mean_2); 

O1_total_3=[O1_before(25:36,:) O1_during(25:36,:) O1_after(25:36,:)];
O1_mean_3=mean(O1_total_3(1:12,:));
O1_fft_3=fft(O1_mean_3); 


%plot of the spectrogram
figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
subplot 311
spectrogram(O1_mean_1,window,h,nfft,fs,'yaxis')
title('1Hz beep ')
ylim ([0,60]);

subplot 312
spectrogram(O1_mean_2,window,h,nfft,fs,'yaxis')
title('2Hz beep ')
ylim ([0,60]);

subplot 313
spectrogram(O1_mean_3,window,h,nfft,fs,'yaxis')
title(' 3Hz beep ')
ylim ([0,60]);

suptitle('O1 channel');


%% 02 CHANNEL

O2_total_1=[O2_before(1:12,:) O2_during(1:12,:) O2_after(1:12,:)];
O2_mean_1=mean(O2_total_1(1:12,:));
O2_fft_1=fft(O2_mean_1); 

O2_total_2=[O2_before(13:24,:) O2_during(13:24,:) O2_after(13:24,:)];
O2_mean_2=mean(O2_total_2(1:12,:));
O2_fft_2=fft(O2_mean_2); 

O2_total_3=[O2_before(25:36,:) O2_during(25:36,:) O2_after(25:36,:)];
O2_mean_3=mean(O2_total_3(1:12,:));
O2_fft_3=fft(O2_mean_3); 


%plot of the spectrogram
figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
subplot 311
spectrogram(O2_mean_1,window,h,nfft,fs,'yaxis')
title('1Hz beep ')
ylim ([0,60]);

subplot 312
spectrogram(O2_mean_2,window,h,nfft,fs,'yaxis')
title('2Hz beep ')
ylim ([0,60]);

subplot 313
spectrogram(O2_mean_3,window,h,nfft,fs,'yaxis')
title(' 3Hz beep ')
ylim ([0,60]);

suptitle('O2 channel');
