close all; clear all;
clc;

%% Load signals
[header,channels]=edfread('ac.edf');

%% Load individual channels
disp('Loading Fp1')
[Fp1,~]=getedf('ac.edf','EEGFp1');
disp('Loading Fp2')
[Fp2,~]=getedf('ac.edf','EEGFp2');
disp('Loading F3')
[F3,~]=getedf('ac.edf','EEGF3');
disp('Loading F4')
[F4,~]=getedf('ac.edf','EEGF4');
disp('Loading C3')
[C3,~]=getedf('ac.edf','EEGC3');
disp('Loading Cz')
[Cz,~]=getedf('ac.edf','EEGCz');
disp('Loading C4')
[C4,~]=getedf('ac.edf','EEGC4');
disp('Loading P3')
[P3,~]=getedf('ac.edf','EEGP3');
disp('Loading P4')
[P4,~]=getedf('ac.edf','EEGP4');
disp('Loading O1')
[O1,~]=getedf('ac.edf','EEGO1');
disp('Loading O2')
[O2,~]=getedf('ac.edf','EEGO2');
disp('Loading Audio')
[Audio,fsAudio]=getedf('ac.edf','Audio');
disp('Loading M1')
[M1,~]=getedf('ac.edf','EEGM1');
disp('Loading M2')
[M2,fs]=getedf('ac.edf','EEGM2');

%% analysing audio signal
%21min52s=1312seg  ~inicio sons 
%23min22s=1402seg  ~fim sons 

Audio_1=Audio(1312*fsAudio:1402*fsAudio);
%soundsc(Audio_1,fsAudio);

%finding time stamps of stimuli - in seconds

timestamps_beg = [];
i = 1;
while i <= length(Audio_1)
    if Audio_1(i)>20
        timestamps_beg=[timestamps_beg i/fsAudio];
        i=i+floor(2.5*fsAudio);
    else
        i=i+1;
    end
end

timestamps_end = [];
i = length(Audio_1);
while i >= 1
    if Audio_1(i)>20
        timestamps_end=[i/fsAudio timestamps_end];
        i=i-floor(2.5*fsAudio);
    else
        i=i-1;
    end
end


%% getting correspondent channel signals

% eye movements
Fp1_1=Fp1(1312*fs:1402*fs);
Fp2_1=Fp2(1312*fs:1402*fs);

% 9 channels
F3_1=F3(1312*fs:1402*fs);
F4_1=F4(1312*fs:1402*fs);
C3_1=C3(1312*fs:1402*fs);
C4_1=C4(1312*fs:1402*fs);
Cz_1=Cz(1312*fs:1402*fs);
P3_1=P3(1312*fs:1402*fs);
P4_1=P4(1312*fs:1402*fs);
O1_1=O1(1312*fs:1402*fs);
O2_1=O2(1312*fs:1402*fs);

% references
M1_1=M1(1312*fs:1402*fs);
M2_1=M2(1312*fs:1402*fs);

EEG_sounds_before=[Fp1_1;Fp2_1;F3_1;F4_1;C3_1;Cz_1;C4_1;P3_1;P4_1;O1_1;O2_1;M1_1;M2_1];


%% plots

figure;

tt=(0:(1402-1312)*fsAudio)/fsAudio;
plot(tt,Audio_1);
xlabel('Time (seconds)');


title('Sound stimuli audio signal');

%% filtering

%first of all, plot of spectrum for random channel:
figure;
ft_bef=abs(fft(F3_1));

freq=fix(length(F3_1)/2)+1;
f=fs*(1:freq)/length(F3_1);
plot(f,(ft_bef(1:freq)));
xlabel('Frequency (Hz)');
ylabel('Magnitude');


% notch

f0=50; %clearly the frequency of power-line interference
w0=2*pi*(f0/fs);
z1=cos(w0)+1j*sin(w0);
z2=cos(w0)-1j*sin(w0);
% Given z1 and z2, the transfer function was obtained (equation 3.149 in the book)
aNotch=[1,0,0];
bNotch=[1,-z1-z2,1];

EEG_notch=filter(bNotch,aNotch,EEG_sounds_before')';

hold on;
ft_af=abs(fft(EEG_notch(3,:)));
plot(f,(ft_af(1:freq)));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
axis tight;

legend('Before','After ');
title('Spectra of F3 channel before and after applying the notch filter');

%bandpass
[B,A]=butter(6,[0.5/(fs/2),30/(fs/2)],'bandpass');
EEG_sounds=filter(B,A,EEG_notch')';

%% plots
figure;

for i=1:9
    subplot (3,3,i);
    plot((0:length(EEG_sounds)-1)/fs,EEG_sounds(i+2,:));
     axis tight;
    title(header.label(i+2));
end
suptitle('EEG channels');
% 
% figure;
% subplot 211;
% plot((0:length(EEG_sounds)-1)/fs,EEG_sounds(1,:));
% hold on;
% plot((0:length(EEG_sounds)-1)/fs,EEG_sounds(2,:));
% 
% legend('Fp1','Fp2');
% title('Eye movements');
% 
% subplot 212;
% plot((0:length(EEG_sounds)-1)/fs,EEG_sounds(12,:));
% hold on;
% plot((0:length(EEG_sounds)-1)/fs,EEG_sounds(13,:));
% legend('M1','M2');
% 
% title('Reference channels');
save('EEG_sounds.mat','EEG_sounds');

%% after performing ICA to remove artifacts
file = matfile('recSounds.mat');
EEG_sounds = file.recEEG_sounds;

%% segmentation

eeg_stamps_beg=round(timestamps_beg*fs); %converting time stamps (beginnings) to eeg samples
eeg_stamps_end=round(timestamps_end*fs); %converting time stamps (ends) to eeg samples

%% boom 

boom_eeg_stamps_beg = [eeg_stamps_beg(1) eeg_stamps_beg(7) eeg_stamps_beg(13)];
boom_eeg_stamps_end = [eeg_stamps_end(1) eeg_stamps_end(7) eeg_stamps_end(13)];

%% before stimuli - 1 second before

for i=1:length(boom_eeg_stamps_beg)
    boom_F3_before(i,:)=EEG_sounds(1,boom_eeg_stamps_beg(i)-1*fs:boom_eeg_stamps_beg(i)-1);
    boom_F4_before(i,:)=EEG_sounds(2,boom_eeg_stamps_beg(i)-1*fs:boom_eeg_stamps_beg(i)-1);
    boom_C3_before(i,:)=EEG_sounds(3,boom_eeg_stamps_beg(i)-1*fs:boom_eeg_stamps_beg(i)-1);
    boom_Cz_before(i,:)=EEG_sounds(4,boom_eeg_stamps_beg(i)-1*fs:boom_eeg_stamps_beg(i)-1);
    boom_C4_before(i,:)=EEG_sounds(5,boom_eeg_stamps_beg(i)-1*fs:boom_eeg_stamps_beg(i)-1);
    boom_P3_before(i,:)=EEG_sounds(6,boom_eeg_stamps_beg(i)-1*fs:boom_eeg_stamps_beg(i)-1);
    boom_P4_before(i,:)=EEG_sounds(7,boom_eeg_stamps_beg(i)-1*fs:boom_eeg_stamps_beg(i)-1);
    boom_O1_before(i,:)=EEG_sounds(8,boom_eeg_stamps_beg(i)-1*fs:boom_eeg_stamps_beg(i)-1);
    boom_O2_before(i,:)=EEG_sounds(9,boom_eeg_stamps_beg(i)-1*fs:boom_eeg_stamps_beg(i)-1);
end

%% during stimuli

boom_length = round(mean(boom_eeg_stamps_end - boom_eeg_stamps_beg));

for i=1:length(boom_eeg_stamps_beg)
    boom_F3_during(i,:)=EEG_sounds(1,boom_eeg_stamps_beg(i):boom_eeg_stamps_beg(i)+boom_length);
    boom_F4_during(i,:)=EEG_sounds(2,boom_eeg_stamps_beg(i):boom_eeg_stamps_beg(i)+boom_length);
    boom_C3_during(i,:)=EEG_sounds(3,boom_eeg_stamps_beg(i):boom_eeg_stamps_beg(i)+boom_length);
    boom_Cz_during(i,:)=EEG_sounds(4,boom_eeg_stamps_beg(i):boom_eeg_stamps_beg(i)+boom_length);
    boom_C4_during(i,:)=EEG_sounds(5,boom_eeg_stamps_beg(i):boom_eeg_stamps_beg(i)+boom_length);
    boom_P3_during(i,:)=EEG_sounds(6,boom_eeg_stamps_beg(i):boom_eeg_stamps_beg(i)+boom_length);
    boom_P4_during(i,:)=EEG_sounds(7,boom_eeg_stamps_beg(i):boom_eeg_stamps_beg(i)+boom_length);
    boom_O1_during(i,:)=EEG_sounds(8,boom_eeg_stamps_beg(i):boom_eeg_stamps_beg(i)+boom_length);
    boom_O2_during(i,:)=EEG_sounds(9,boom_eeg_stamps_beg(i):boom_eeg_stamps_beg(i)+boom_length);
end


%% after stimuli - 2 seconds after

for i=1:length(boom_eeg_stamps_end)
    boom_F3_after(i,:)=EEG_sounds(1,boom_eeg_stamps_end(i):boom_eeg_stamps_end(i)+fs);
    boom_F4_after(i,:)=EEG_sounds(2,boom_eeg_stamps_end(i):boom_eeg_stamps_end(i)+fs);
    boom_C3_after(i,:)=EEG_sounds(3,boom_eeg_stamps_end(i):boom_eeg_stamps_end(i)+fs);
    boom_Cz_after(i,:)=EEG_sounds(4,boom_eeg_stamps_end(i):boom_eeg_stamps_end(i)+fs);
    boom_C4_after(i,:)=EEG_sounds(5,boom_eeg_stamps_end(i):boom_eeg_stamps_end(i)+fs);
    boom_P3_after(i,:)=EEG_sounds(6,boom_eeg_stamps_end(i):boom_eeg_stamps_end(i)+fs);
    boom_P4_after(i,:)=EEG_sounds(7,boom_eeg_stamps_end(i):boom_eeg_stamps_end(i)+fs);
    boom_O1_after(i,:)=EEG_sounds(8,boom_eeg_stamps_end(i):boom_eeg_stamps_end(i)+fs);
    boom_O2_after(i,:)=EEG_sounds(9,boom_eeg_stamps_end(i):boom_eeg_stamps_end(i)+fs);
end


%% ringing

ringing_eeg_stamps_beg = [eeg_stamps_beg(2) eeg_stamps_beg(8) eeg_stamps_beg(14)];
ringing_eeg_stamps_end = [eeg_stamps_end(2) eeg_stamps_end(8) eeg_stamps_end(14)];

%% before stimuli - 1 second before

for i=1:length(ringing_eeg_stamps_beg)
    ringing_F3_before(i,:)=EEG_sounds(1,ringing_eeg_stamps_beg(i)-1*fs:ringing_eeg_stamps_beg(i)-1);
    ringing_F4_before(i,:)=EEG_sounds(2,ringing_eeg_stamps_beg(i)-1*fs:ringing_eeg_stamps_beg(i)-1);
    ringing_C3_before(i,:)=EEG_sounds(3,ringing_eeg_stamps_beg(i)-1*fs:ringing_eeg_stamps_beg(i)-1);
    ringing_Cz_before(i,:)=EEG_sounds(4,ringing_eeg_stamps_beg(i)-1*fs:ringing_eeg_stamps_beg(i)-1);
    ringing_C4_before(i,:)=EEG_sounds(5,ringing_eeg_stamps_beg(i)-1*fs:ringing_eeg_stamps_beg(i)-1);
    ringing_P3_before(i,:)=EEG_sounds(6,ringing_eeg_stamps_beg(i)-1*fs:ringing_eeg_stamps_beg(i)-1);
    ringing_P4_before(i,:)=EEG_sounds(7,ringing_eeg_stamps_beg(i)-1*fs:ringing_eeg_stamps_beg(i)-1);
    ringing_O1_before(i,:)=EEG_sounds(8,ringing_eeg_stamps_beg(i)-1*fs:ringing_eeg_stamps_beg(i)-1);
    ringing_O2_before(i,:)=EEG_sounds(9,ringing_eeg_stamps_beg(i)-1*fs:ringing_eeg_stamps_beg(i)-1);
end

%% during stimuli

ringing_length = round(mean(ringing_eeg_stamps_end - ringing_eeg_stamps_beg));

for i=1:length(ringing_eeg_stamps_beg)
    ringing_F3_during(i,:)=EEG_sounds(1,ringing_eeg_stamps_beg(i):ringing_eeg_stamps_beg(i)+ringing_length);
    ringing_F4_during(i,:)=EEG_sounds(2,ringing_eeg_stamps_beg(i):ringing_eeg_stamps_beg(i)+ringing_length);
    ringing_C3_during(i,:)=EEG_sounds(3,ringing_eeg_stamps_beg(i):ringing_eeg_stamps_beg(i)+ringing_length);
    ringing_Cz_during(i,:)=EEG_sounds(4,ringing_eeg_stamps_beg(i):ringing_eeg_stamps_beg(i)+ringing_length);
    ringing_C4_during(i,:)=EEG_sounds(5,ringing_eeg_stamps_beg(i):ringing_eeg_stamps_beg(i)+ringing_length);
    ringing_P3_during(i,:)=EEG_sounds(6,ringing_eeg_stamps_beg(i):ringing_eeg_stamps_beg(i)+ringing_length);
    ringing_P4_during(i,:)=EEG_sounds(7,ringing_eeg_stamps_beg(i):ringing_eeg_stamps_beg(i)+ringing_length);
    ringing_O1_during(i,:)=EEG_sounds(8,ringing_eeg_stamps_beg(i):ringing_eeg_stamps_beg(i)+ringing_length);
    ringing_O2_during(i,:)=EEG_sounds(9,ringing_eeg_stamps_beg(i):ringing_eeg_stamps_beg(i)+ringing_length);
end


%% after stimuli - 2 seconds after

for i=1:length(ringing_eeg_stamps_end)
    ringing_F3_after(i,:)=EEG_sounds(1,ringing_eeg_stamps_end(i):ringing_eeg_stamps_end(i)+fs);
    ringing_F4_after(i,:)=EEG_sounds(2,ringing_eeg_stamps_end(i):ringing_eeg_stamps_end(i)+fs);
    ringing_C3_after(i,:)=EEG_sounds(3,ringing_eeg_stamps_end(i):ringing_eeg_stamps_end(i)+fs);
    ringing_Cz_after(i,:)=EEG_sounds(4,ringing_eeg_stamps_end(i):ringing_eeg_stamps_end(i)+fs);
    ringing_C4_after(i,:)=EEG_sounds(5,ringing_eeg_stamps_end(i):ringing_eeg_stamps_end(i)+fs);
    ringing_P3_after(i,:)=EEG_sounds(6,ringing_eeg_stamps_end(i):ringing_eeg_stamps_end(i)+fs);
    ringing_P4_after(i,:)=EEG_sounds(7,ringing_eeg_stamps_end(i):ringing_eeg_stamps_end(i)+fs);
    ringing_O1_after(i,:)=EEG_sounds(8,ringing_eeg_stamps_end(i):ringing_eeg_stamps_end(i)+fs);
    ringing_O2_after(i,:)=EEG_sounds(9,ringing_eeg_stamps_end(i):ringing_eeg_stamps_end(i)+fs);
end

%% crying

crying_eeg_stamps_beg = [eeg_stamps_beg(3) eeg_stamps_beg(9) eeg_stamps_beg(15)];
crying_eeg_stamps_end = [eeg_stamps_end(3) eeg_stamps_end(9) eeg_stamps_end(15)];

%% before stimuli - 1 second before

for i=1:length(crying_eeg_stamps_beg)
    crying_F3_before(i,:)=EEG_sounds(1,crying_eeg_stamps_beg(i)-1*fs:crying_eeg_stamps_beg(i)-1);
    crying_F4_before(i,:)=EEG_sounds(2,crying_eeg_stamps_beg(i)-1*fs:crying_eeg_stamps_beg(i)-1);
    crying_C3_before(i,:)=EEG_sounds(3,crying_eeg_stamps_beg(i)-1*fs:crying_eeg_stamps_beg(i)-1);
    crying_Cz_before(i,:)=EEG_sounds(4,crying_eeg_stamps_beg(i)-1*fs:crying_eeg_stamps_beg(i)-1);
    crying_C4_before(i,:)=EEG_sounds(5,crying_eeg_stamps_beg(i)-1*fs:crying_eeg_stamps_beg(i)-1);
    crying_P3_before(i,:)=EEG_sounds(6,crying_eeg_stamps_beg(i)-1*fs:crying_eeg_stamps_beg(i)-1);
    crying_P4_before(i,:)=EEG_sounds(7,crying_eeg_stamps_beg(i)-1*fs:crying_eeg_stamps_beg(i)-1);
    crying_O1_before(i,:)=EEG_sounds(8,crying_eeg_stamps_beg(i)-1*fs:crying_eeg_stamps_beg(i)-1);
    crying_O2_before(i,:)=EEG_sounds(9,crying_eeg_stamps_beg(i)-1*fs:crying_eeg_stamps_beg(i)-1);
end

%% during stimuli

crying_length = round(mean(crying_eeg_stamps_end - crying_eeg_stamps_beg));

for i=1:length(crying_eeg_stamps_beg)
    crying_F3_during(i,:)=EEG_sounds(1,crying_eeg_stamps_beg(i):crying_eeg_stamps_beg(i)+crying_length);
    crying_F4_during(i,:)=EEG_sounds(2,crying_eeg_stamps_beg(i):crying_eeg_stamps_beg(i)+crying_length);
    crying_C3_during(i,:)=EEG_sounds(3,crying_eeg_stamps_beg(i):crying_eeg_stamps_beg(i)+crying_length);
    crying_Cz_during(i,:)=EEG_sounds(4,crying_eeg_stamps_beg(i):crying_eeg_stamps_beg(i)+crying_length);
    crying_C4_during(i,:)=EEG_sounds(5,crying_eeg_stamps_beg(i):crying_eeg_stamps_beg(i)+crying_length);
    crying_P3_during(i,:)=EEG_sounds(6,crying_eeg_stamps_beg(i):crying_eeg_stamps_beg(i)+crying_length);
    crying_P4_during(i,:)=EEG_sounds(7,crying_eeg_stamps_beg(i):crying_eeg_stamps_beg(i)+crying_length);
    crying_O1_during(i,:)=EEG_sounds(8,crying_eeg_stamps_beg(i):crying_eeg_stamps_beg(i)+crying_length);
    crying_O2_during(i,:)=EEG_sounds(9,crying_eeg_stamps_beg(i):crying_eeg_stamps_beg(i)+crying_length);
end


%% after stimuli - 2 seconds after

for i=1:length(crying_eeg_stamps_end)
    crying_F3_after(i,:)=EEG_sounds(1,crying_eeg_stamps_end(i):crying_eeg_stamps_end(i)+fs);
    crying_F4_after(i,:)=EEG_sounds(2,crying_eeg_stamps_end(i):crying_eeg_stamps_end(i)+fs);
    crying_C3_after(i,:)=EEG_sounds(3,crying_eeg_stamps_end(i):crying_eeg_stamps_end(i)+fs);
    crying_Cz_after(i,:)=EEG_sounds(4,crying_eeg_stamps_end(i):crying_eeg_stamps_end(i)+fs);
    crying_C4_after(i,:)=EEG_sounds(5,crying_eeg_stamps_end(i):crying_eeg_stamps_end(i)+fs);
    crying_P3_after(i,:)=EEG_sounds(6,crying_eeg_stamps_end(i):crying_eeg_stamps_end(i)+fs);
    crying_P4_after(i,:)=EEG_sounds(7,crying_eeg_stamps_end(i):crying_eeg_stamps_end(i)+fs);
    crying_O1_after(i,:)=EEG_sounds(8,crying_eeg_stamps_end(i):crying_eeg_stamps_end(i)+fs);
    crying_O2_after(i,:)=EEG_sounds(9,crying_eeg_stamps_end(i):crying_eeg_stamps_end(i)+fs);
end

%% laughing

laughing_eeg_stamps_beg = [eeg_stamps_beg(4) eeg_stamps_beg(10) eeg_stamps_beg(16)];
laughing_eeg_stamps_end = [eeg_stamps_end(4) eeg_stamps_end(10) eeg_stamps_end(16)];

%% before stimuli - 1 second before

for i=1:length(laughing_eeg_stamps_beg)
    laughing_F3_before(i,:)=EEG_sounds(1,laughing_eeg_stamps_beg(i)-1*fs:laughing_eeg_stamps_beg(i)-1);
    laughing_F4_before(i,:)=EEG_sounds(2,laughing_eeg_stamps_beg(i)-1*fs:laughing_eeg_stamps_beg(i)-1);
    laughing_C3_before(i,:)=EEG_sounds(3,laughing_eeg_stamps_beg(i)-1*fs:laughing_eeg_stamps_beg(i)-1);
    laughing_Cz_before(i,:)=EEG_sounds(4,laughing_eeg_stamps_beg(i)-1*fs:laughing_eeg_stamps_beg(i)-1);
    laughing_C4_before(i,:)=EEG_sounds(5,laughing_eeg_stamps_beg(i)-1*fs:laughing_eeg_stamps_beg(i)-1);
    laughing_P3_before(i,:)=EEG_sounds(6,laughing_eeg_stamps_beg(i)-1*fs:laughing_eeg_stamps_beg(i)-1);
    laughing_P4_before(i,:)=EEG_sounds(7,laughing_eeg_stamps_beg(i)-1*fs:laughing_eeg_stamps_beg(i)-1);
    laughing_O1_before(i,:)=EEG_sounds(8,laughing_eeg_stamps_beg(i)-1*fs:laughing_eeg_stamps_beg(i)-1);
    laughing_O2_before(i,:)=EEG_sounds(9,laughing_eeg_stamps_beg(i)-1*fs:laughing_eeg_stamps_beg(i)-1);
end

%% during stimuli

laughing_length = round(mean(laughing_eeg_stamps_end - laughing_eeg_stamps_beg));

for i=1:length(laughing_eeg_stamps_beg)
    laughing_F3_during(i,:)=EEG_sounds(1,laughing_eeg_stamps_beg(i):laughing_eeg_stamps_beg(i)+laughing_length);
    laughing_F4_during(i,:)=EEG_sounds(2,laughing_eeg_stamps_beg(i):laughing_eeg_stamps_beg(i)+laughing_length);
    laughing_C3_during(i,:)=EEG_sounds(3,laughing_eeg_stamps_beg(i):laughing_eeg_stamps_beg(i)+laughing_length);
    laughing_Cz_during(i,:)=EEG_sounds(4,laughing_eeg_stamps_beg(i):laughing_eeg_stamps_beg(i)+laughing_length);
    laughing_C4_during(i,:)=EEG_sounds(5,laughing_eeg_stamps_beg(i):laughing_eeg_stamps_beg(i)+laughing_length);
    laughing_P3_during(i,:)=EEG_sounds(6,laughing_eeg_stamps_beg(i):laughing_eeg_stamps_beg(i)+laughing_length);
    laughing_P4_during(i,:)=EEG_sounds(7,laughing_eeg_stamps_beg(i):laughing_eeg_stamps_beg(i)+laughing_length);
    laughing_O1_during(i,:)=EEG_sounds(8,laughing_eeg_stamps_beg(i):laughing_eeg_stamps_beg(i)+laughing_length);
    laughing_O2_during(i,:)=EEG_sounds(9,laughing_eeg_stamps_beg(i):laughing_eeg_stamps_beg(i)+laughing_length);
end


%% after stimuli - 2 seconds after

for i=1:length(laughing_eeg_stamps_end)
    laughing_F3_after(i,:)=EEG_sounds(1,laughing_eeg_stamps_end(i):laughing_eeg_stamps_end(i)+fs);
    laughing_F4_after(i,:)=EEG_sounds(2,laughing_eeg_stamps_end(i):laughing_eeg_stamps_end(i)+fs);
    laughing_C3_after(i,:)=EEG_sounds(3,laughing_eeg_stamps_end(i):laughing_eeg_stamps_end(i)+fs);
    laughing_Cz_after(i,:)=EEG_sounds(4,laughing_eeg_stamps_end(i):laughing_eeg_stamps_end(i)+fs);
    laughing_C4_after(i,:)=EEG_sounds(5,laughing_eeg_stamps_end(i):laughing_eeg_stamps_end(i)+fs);
    laughing_P3_after(i,:)=EEG_sounds(6,laughing_eeg_stamps_end(i):laughing_eeg_stamps_end(i)+fs);
    laughing_P4_after(i,:)=EEG_sounds(7,laughing_eeg_stamps_end(i):laughing_eeg_stamps_end(i)+fs);
    laughing_O1_after(i,:)=EEG_sounds(8,laughing_eeg_stamps_end(i):laughing_eeg_stamps_end(i)+fs);
    laughing_O2_after(i,:)=EEG_sounds(9,laughing_eeg_stamps_end(i):laughing_eeg_stamps_end(i)+fs);
end

%% birds

birds_eeg_stamps_beg = [eeg_stamps_beg(5) eeg_stamps_beg(11) eeg_stamps_beg(17)];
birds_eeg_stamps_end = [eeg_stamps_end(5) eeg_stamps_end(11) eeg_stamps_end(17)];

%% before stimuli - 1 second before

for i=1:length(birds_eeg_stamps_beg)
    birds_F3_before(i,:)=EEG_sounds(1,birds_eeg_stamps_beg(i)-1*fs:birds_eeg_stamps_beg(i)-1);
    birds_F4_before(i,:)=EEG_sounds(2,birds_eeg_stamps_beg(i)-1*fs:birds_eeg_stamps_beg(i)-1);
    birds_C3_before(i,:)=EEG_sounds(3,birds_eeg_stamps_beg(i)-1*fs:birds_eeg_stamps_beg(i)-1);
    birds_Cz_before(i,:)=EEG_sounds(4,birds_eeg_stamps_beg(i)-1*fs:birds_eeg_stamps_beg(i)-1);
    birds_C4_before(i,:)=EEG_sounds(5,birds_eeg_stamps_beg(i)-1*fs:birds_eeg_stamps_beg(i)-1);
    birds_P3_before(i,:)=EEG_sounds(6,birds_eeg_stamps_beg(i)-1*fs:birds_eeg_stamps_beg(i)-1);
    birds_P4_before(i,:)=EEG_sounds(7,birds_eeg_stamps_beg(i)-1*fs:birds_eeg_stamps_beg(i)-1);
    birds_O1_before(i,:)=EEG_sounds(8,birds_eeg_stamps_beg(i)-1*fs:birds_eeg_stamps_beg(i)-1);
    birds_O2_before(i,:)=EEG_sounds(9,birds_eeg_stamps_beg(i)-1*fs:birds_eeg_stamps_beg(i)-1);
end

%% during stimuli

birds_length = round(mean(birds_eeg_stamps_end - birds_eeg_stamps_beg));

for i=1:length(birds_eeg_stamps_beg)
    birds_F3_during(i,:)=EEG_sounds(1,birds_eeg_stamps_beg(i):birds_eeg_stamps_beg(i)+birds_length);
    birds_F4_during(i,:)=EEG_sounds(2,birds_eeg_stamps_beg(i):birds_eeg_stamps_beg(i)+birds_length);
    birds_C3_during(i,:)=EEG_sounds(3,birds_eeg_stamps_beg(i):birds_eeg_stamps_beg(i)+birds_length);
    birds_Cz_during(i,:)=EEG_sounds(4,birds_eeg_stamps_beg(i):birds_eeg_stamps_beg(i)+birds_length);
    birds_C4_during(i,:)=EEG_sounds(5,birds_eeg_stamps_beg(i):birds_eeg_stamps_beg(i)+birds_length);
    birds_P3_during(i,:)=EEG_sounds(6,birds_eeg_stamps_beg(i):birds_eeg_stamps_beg(i)+birds_length);
    birds_P4_during(i,:)=EEG_sounds(7,birds_eeg_stamps_beg(i):birds_eeg_stamps_beg(i)+birds_length);
    birds_O1_during(i,:)=EEG_sounds(8,birds_eeg_stamps_beg(i):birds_eeg_stamps_beg(i)+birds_length);
    birds_O2_during(i,:)=EEG_sounds(9,birds_eeg_stamps_beg(i):birds_eeg_stamps_beg(i)+birds_length);
end


%% after stimuli - 2 seconds after

for i=1:length(birds_eeg_stamps_end)
    birds_F3_after(i,:)=EEG_sounds(1,birds_eeg_stamps_end(i):birds_eeg_stamps_end(i)+fs);
    birds_F4_after(i,:)=EEG_sounds(2,birds_eeg_stamps_end(i):birds_eeg_stamps_end(i)+fs);
    birds_C3_after(i,:)=EEG_sounds(3,birds_eeg_stamps_end(i):birds_eeg_stamps_end(i)+fs);
    birds_Cz_after(i,:)=EEG_sounds(4,birds_eeg_stamps_end(i):birds_eeg_stamps_end(i)+fs);
    birds_C4_after(i,:)=EEG_sounds(5,birds_eeg_stamps_end(i):birds_eeg_stamps_end(i)+fs);
    birds_P3_after(i,:)=EEG_sounds(6,birds_eeg_stamps_end(i):birds_eeg_stamps_end(i)+fs);
    birds_P4_after(i,:)=EEG_sounds(7,birds_eeg_stamps_end(i):birds_eeg_stamps_end(i)+fs);
    birds_O1_after(i,:)=EEG_sounds(8,birds_eeg_stamps_end(i):birds_eeg_stamps_end(i)+fs);
    birds_O2_after(i,:)=EEG_sounds(9,birds_eeg_stamps_end(i):birds_eeg_stamps_end(i)+fs);
end

%% thunder

thunder_eeg_stamps_beg = [eeg_stamps_beg(6) eeg_stamps_beg(12) eeg_stamps_beg(18)];
thunder_eeg_stamps_end = [eeg_stamps_end(6) eeg_stamps_end(12) eeg_stamps_end(18)];

%% before stimuli - 1 second before

for i=1:length(thunder_eeg_stamps_beg)
    thunder_F3_before(i,:)=EEG_sounds(1,thunder_eeg_stamps_beg(i)-1*fs:thunder_eeg_stamps_beg(i)-1);
    thunder_F4_before(i,:)=EEG_sounds(2,thunder_eeg_stamps_beg(i)-1*fs:thunder_eeg_stamps_beg(i)-1);
    thunder_C3_before(i,:)=EEG_sounds(3,thunder_eeg_stamps_beg(i)-1*fs:thunder_eeg_stamps_beg(i)-1);
    thunder_Cz_before(i,:)=EEG_sounds(4,thunder_eeg_stamps_beg(i)-1*fs:thunder_eeg_stamps_beg(i)-1);
    thunder_C4_before(i,:)=EEG_sounds(5,thunder_eeg_stamps_beg(i)-1*fs:thunder_eeg_stamps_beg(i)-1);
    thunder_P3_before(i,:)=EEG_sounds(6,thunder_eeg_stamps_beg(i)-1*fs:thunder_eeg_stamps_beg(i)-1);
    thunder_P4_before(i,:)=EEG_sounds(7,thunder_eeg_stamps_beg(i)-1*fs:thunder_eeg_stamps_beg(i)-1);
    thunder_O1_before(i,:)=EEG_sounds(8,thunder_eeg_stamps_beg(i)-1*fs:thunder_eeg_stamps_beg(i)-1);
    thunder_O2_before(i,:)=EEG_sounds(9,thunder_eeg_stamps_beg(i)-1*fs:thunder_eeg_stamps_beg(i)-1);
end

%% during stimuli

thunder_length = round(mean(thunder_eeg_stamps_end - thunder_eeg_stamps_beg));

for i=1:length(thunder_eeg_stamps_beg)
    thunder_F3_during(i,:)=EEG_sounds(1,thunder_eeg_stamps_beg(i):thunder_eeg_stamps_beg(i)+thunder_length);
    thunder_F4_during(i,:)=EEG_sounds(2,thunder_eeg_stamps_beg(i):thunder_eeg_stamps_beg(i)+thunder_length);
    thunder_C3_during(i,:)=EEG_sounds(3,thunder_eeg_stamps_beg(i):thunder_eeg_stamps_beg(i)+thunder_length);
    thunder_Cz_during(i,:)=EEG_sounds(4,thunder_eeg_stamps_beg(i):thunder_eeg_stamps_beg(i)+thunder_length);
    thunder_C4_during(i,:)=EEG_sounds(5,thunder_eeg_stamps_beg(i):thunder_eeg_stamps_beg(i)+thunder_length);
    thunder_P3_during(i,:)=EEG_sounds(6,thunder_eeg_stamps_beg(i):thunder_eeg_stamps_beg(i)+thunder_length);
    thunder_P4_during(i,:)=EEG_sounds(7,thunder_eeg_stamps_beg(i):thunder_eeg_stamps_beg(i)+thunder_length);
    thunder_O1_during(i,:)=EEG_sounds(8,thunder_eeg_stamps_beg(i):thunder_eeg_stamps_beg(i)+thunder_length);
    thunder_O2_during(i,:)=EEG_sounds(9,thunder_eeg_stamps_beg(i):thunder_eeg_stamps_beg(i)+thunder_length);
end


%% after stimuli - 2 seconds after

for i=1:length(thunder_eeg_stamps_end)
    thunder_F3_after(i,:)=EEG_sounds(1,thunder_eeg_stamps_end(i):thunder_eeg_stamps_end(i)+fs);
    thunder_F4_after(i,:)=EEG_sounds(2,thunder_eeg_stamps_end(i):thunder_eeg_stamps_end(i)+fs);
    thunder_C3_after(i,:)=EEG_sounds(3,thunder_eeg_stamps_end(i):thunder_eeg_stamps_end(i)+fs);
    thunder_Cz_after(i,:)=EEG_sounds(4,thunder_eeg_stamps_end(i):thunder_eeg_stamps_end(i)+fs);
    thunder_C4_after(i,:)=EEG_sounds(5,thunder_eeg_stamps_end(i):thunder_eeg_stamps_end(i)+fs);
    thunder_P3_after(i,:)=EEG_sounds(6,thunder_eeg_stamps_end(i):thunder_eeg_stamps_end(i)+fs);
    thunder_P4_after(i,:)=EEG_sounds(7,thunder_eeg_stamps_end(i):thunder_eeg_stamps_end(i)+fs);
    thunder_O1_after(i,:)=EEG_sounds(8,thunder_eeg_stamps_end(i):thunder_eeg_stamps_end(i)+fs);
    thunder_O2_after(i,:)=EEG_sounds(9,thunder_eeg_stamps_end(i):thunder_eeg_stamps_end(i)+fs);
end

%% plots for channel F3

figure;

% boom
subplot (3,6,1);
for i=1:3
    plot((0:length(boom_F3_before)-1)/fs,boom_F3_before(i,:));
    hold on;
end
plot((0:length(boom_F3_before)-1)/fs,mean(boom_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot((0:length(boom_F3_during)-1)/fs,boom_F3_during(i,:));
    hold on;
end
plot((0:length(boom_F3_during)-1)/fs,mean(boom_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot((0:length(boom_F3_after)-1)/fs,boom_F3_after(i,:));
    hold on;
end
plot((0:length(boom_F3_after)-1)/fs,mean(boom_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After (Boom)');


% ringing
subplot (3,6,2);
for i=1:3
    plot((0:length(ringing_F3_before)-1)/fs,ringing_F3_before(i,:));
    hold on;
end
plot((0:length(ringing_F3_before)-1)/fs,mean(ringing_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Ringing)');

subplot (3,6,8);
for i=1:3
    plot((0:length(ringing_F3_during)-1)/fs,ringing_F3_during(i,:));
    hold on;
end
plot((0:length(ringing_F3_during)-1)/fs,mean(ringing_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Ringing)');

subplot (3,6,14);
for i=1:3
    plot((0:length(ringing_F3_after)-1)/fs,ringing_F3_after(i,:));
    hold on;
end
plot((0:length(ringing_F3_after)-1)/fs,mean(ringing_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After (Ringing)');

% crying 
subplot (3,6,3);
for i=1:3
    plot((0:length(crying_F3_before)-1)/fs,crying_F3_before(i,:));
    hold on;
end
plot((0:length(crying_F3_before)-1)/fs,mean(crying_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Crying)');

subplot (3,6,9);
for i=1:3
    plot((0:length(crying_F3_during)-1)/fs,crying_F3_during(i,:));
    hold on;
end
plot((0:length(crying_F3_during)-1)/fs,mean(crying_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Crying)');

subplot (3,6,15);
for i=1:3
    plot((0:length(crying_F3_after)-1)/fs,crying_F3_after(i,:));
    hold on;
end
plot((0:length(crying_F3_after)-1)/fs,mean(crying_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(Crying)');

% laughing
subplot (3,6,4);
for i=1:3
    plot((0:length(laughing_F3_before)-1)/fs,laughing_F3_before(i,:));
    hold on;
end
plot((0:length(laughing_F3_before)-1)/fs,mean(laughing_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Laughing)');

subplot (3,6,10);
for i=1:3
    plot((0:length(laughing_F3_during)-1)/fs,laughing_F3_during(i,:));
    hold on;
end
plot((0:length(laughing_F3_during)-1)/fs,mean(laughing_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Laughing)');

subplot (3,6,16);
for i=1:3
    plot((0:length(laughing_F3_after)-1)/fs,laughing_F3_after(i,:));
    hold on;
end
plot((0:length(laughing_F3_after)-1)/fs,mean(laughing_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(Laughing)');

% birds
subplot (3,6,5);
for i=1:3
    plot((0:length(birds_F3_before)-1)/fs,birds_F3_before(i,:));
    hold on;
end
plot((0:length(birds_F3_before)-1)/fs,mean(birds_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot((0:length(birds_F3_during)-1)/fs,birds_F3_during(i,:));
    hold on;
end
plot((0:length(birds_F3_during)-1)/fs,mean(birds_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot((0:length(birds_F3_after)-1)/fs,birds_F3_after(i,:));
    hold on;
end
plot((0:length(birds_F3_after)-1)/fs,mean(birds_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(birds)');

% thunder
subplot (3,6,6);
for i=1:3
    plot((0:length(thunder_F3_before)-1)/fs,thunder_F3_before(i,:));
    hold on;
end
plot((0:length(thunder_F3_before)-1)/fs,mean(thunder_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot((0:length(thunder_F3_during)-1)/fs,thunder_F3_during(i,:));
    hold on;
end
plot((0:length(thunder_F3_during)-1)/fs,mean(thunder_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot((0:length(thunder_F3_after)-1)/fs,thunder_F3_after(i,:));
    hold on;
end
plot((0:length(thunder_F3_after)-1)/fs,mean(thunder_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(thunder)');

suptitle('Channel F3');

%% plots for channel F4

figure;

% boom
subplot (3,6,1);
for i=1:3
    plot((0:length(boom_F4_before)-1)/fs,boom_F4_before(i,:));
    hold on;
end
plot((0:length(boom_F4_before)-1)/fs,mean(boom_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot((0:length(boom_F4_during)-1)/fs,boom_F4_during(i,:));
    hold on;
end
plot((0:length(boom_F4_during)-1)/fs,mean(boom_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot((0:length(boom_F4_after)-1)/fs,boom_F4_after(i,:));
    hold on;
end
plot((0:length(boom_F4_after)-1)/fs,mean(boom_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After (Boom)');


% ringing
subplot (3,6,2);
for i=1:3
    plot((0:length(ringing_F4_before)-1)/fs,ringing_F4_before(i,:));
    hold on;
end
plot((0:length(ringing_F4_before)-1)/fs,mean(ringing_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Ringing)');

subplot (3,6,8);
for i=1:3
    plot((0:length(ringing_F4_during)-1)/fs,ringing_F4_during(i,:));
    hold on;
end
plot((0:length(ringing_F4_during)-1)/fs,mean(ringing_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Ringing)');

subplot (3,6,14);
for i=1:3
    plot((0:length(ringing_F4_after)-1)/fs,ringing_F4_after(i,:));
    hold on;
end
plot((0:length(ringing_F4_after)-1)/fs,mean(ringing_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After (Ringing)');

% crying 
subplot (3,6,3);
for i=1:3
    plot((0:length(crying_F4_before)-1)/fs,crying_F4_before(i,:));
    hold on;
end
plot((0:length(crying_F4_before)-1)/fs,mean(crying_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Crying)');

subplot (3,6,9);
for i=1:3
    plot((0:length(crying_F4_during)-1)/fs,crying_F4_during(i,:));
    hold on;
end
plot((0:length(crying_F4_during)-1)/fs,mean(crying_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Crying)');

subplot (3,6,15);
for i=1:3
    plot((0:length(crying_F4_after)-1)/fs,crying_F4_after(i,:));
    hold on;
end
plot((0:length(crying_F4_after)-1)/fs,mean(crying_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(Crying)');

% laughing
subplot (3,6,4);
for i=1:3
    plot((0:length(laughing_F4_before)-1)/fs,laughing_F4_before(i,:));
    hold on;
end
plot((0:length(laughing_F4_before)-1)/fs,mean(laughing_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Laughing)');

subplot (3,6,10);
for i=1:3
    plot((0:length(laughing_F4_during)-1)/fs,laughing_F4_during(i,:));
    hold on;
end
plot((0:length(laughing_F4_during)-1)/fs,mean(laughing_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Laughing)');

subplot (3,6,16);
for i=1:3
    plot((0:length(laughing_F4_after)-1)/fs,laughing_F4_after(i,:));
    hold on;
end
plot((0:length(laughing_F4_after)-1)/fs,mean(laughing_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(Laughing)');

% birds
subplot (3,6,5);
for i=1:3
    plot((0:length(birds_F4_before)-1)/fs,birds_F4_before(i,:));
    hold on;
end
plot((0:length(birds_F4_before)-1)/fs,mean(birds_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot((0:length(birds_F4_during)-1)/fs,birds_F4_during(i,:));
    hold on;
end
plot((0:length(birds_F4_during)-1)/fs,mean(birds_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot((0:length(birds_F4_after)-1)/fs,birds_F4_after(i,:));
    hold on;
end
plot((0:length(birds_F4_after)-1)/fs,mean(birds_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(birds)');

% thunder
subplot (3,6,6);
for i=1:3
    plot((0:length(thunder_F4_before)-1)/fs,thunder_F4_before(i,:));
    hold on;
end
plot((0:length(thunder_F4_before)-1)/fs,mean(thunder_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot((0:length(thunder_F4_during)-1)/fs,thunder_F4_during(i,:));
    hold on;
end
plot((0:length(thunder_F4_during)-1)/fs,mean(thunder_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot((0:length(thunder_F4_after)-1)/fs,thunder_F4_after(i,:));
    hold on;
end
plot((0:length(thunder_F4_after)-1)/fs,mean(thunder_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(thunder)');

suptitle('Channel F4');

%% plots for channel C3

figure;

% boom
subplot (3,6,1);
for i=1:3
    plot((0:length(boom_C3_before)-1)/fs,boom_C3_before(i,:));
    hold on;
end
plot((0:length(boom_C3_before)-1)/fs,mean(boom_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot((0:length(boom_C3_during)-1)/fs,boom_C3_during(i,:));
    hold on;
end
plot((0:length(boom_C3_during)-1)/fs,mean(boom_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot((0:length(boom_C3_after)-1)/fs,boom_C3_after(i,:));
    hold on;
end
plot((0:length(boom_C3_after)-1)/fs,mean(boom_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After (Boom)');


% ringing
subplot (3,6,2);
for i=1:3
    plot((0:length(ringing_C3_before)-1)/fs,ringing_C3_before(i,:));
    hold on;
end
plot((0:length(ringing_C3_before)-1)/fs,mean(ringing_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Ringing)');

subplot (3,6,8);
for i=1:3
    plot((0:length(ringing_C3_during)-1)/fs,ringing_C3_during(i,:));
    hold on;
end
plot((0:length(ringing_C3_during)-1)/fs,mean(ringing_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Ringing)');

subplot (3,6,14);
for i=1:3
    plot((0:length(ringing_C3_after)-1)/fs,ringing_C3_after(i,:));
    hold on;
end
plot((0:length(ringing_C3_after)-1)/fs,mean(ringing_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After (Ringing)');

% crying 
subplot (3,6,3);
for i=1:3
    plot((0:length(crying_C3_before)-1)/fs,crying_C3_before(i,:));
    hold on;
end
plot((0:length(crying_C3_before)-1)/fs,mean(crying_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Crying)');

subplot (3,6,9);
for i=1:3
    plot((0:length(crying_C3_during)-1)/fs,crying_C3_during(i,:));
    hold on;
end
plot((0:length(crying_C3_during)-1)/fs,mean(crying_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Crying)');

subplot (3,6,15);
for i=1:3
    plot((0:length(crying_C3_after)-1)/fs,crying_C3_after(i,:));
    hold on;
end
plot((0:length(crying_C3_after)-1)/fs,mean(crying_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(Crying)');

% laughing
subplot (3,6,4);
for i=1:3
    plot((0:length(laughing_C3_before)-1)/fs,laughing_C3_before(i,:));
    hold on;
end
plot((0:length(laughing_C3_before)-1)/fs,mean(laughing_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (Laughing)');

subplot (3,6,10);
for i=1:3
    plot((0:length(laughing_C3_during)-1)/fs,laughing_C3_during(i,:));
    hold on;
end
plot((0:length(laughing_C3_during)-1)/fs,mean(laughing_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (Laughing)');

subplot (3,6,16);
for i=1:3
    plot((0:length(laughing_C3_after)-1)/fs,laughing_C3_after(i,:));
    hold on;
end
plot((0:length(laughing_C3_after)-1)/fs,mean(laughing_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(Laughing)');

% birds
subplot (3,6,5);
for i=1:3
    plot((0:length(birds_C3_before)-1)/fs,birds_C3_before(i,:));
    hold on;
end
plot((0:length(birds_C3_before)-1)/fs,mean(birds_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot((0:length(birds_C3_during)-1)/fs,birds_C3_during(i,:));
    hold on;
end
plot((0:length(birds_C3_during)-1)/fs,mean(birds_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot((0:length(birds_C3_after)-1)/fs,birds_C3_after(i,:));
    hold on;
end
plot((0:length(birds_C3_after)-1)/fs,mean(birds_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(birds)');

% thunder
subplot (3,6,6);
for i=1:3
    plot((0:length(thunder_C3_before)-1)/fs,thunder_C3_before(i,:));
    hold on;
end
plot((0:length(thunder_C3_before)-1)/fs,mean(thunder_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot((0:length(thunder_C3_during)-1)/fs,thunder_C3_during(i,:));
    hold on;
end
plot((0:length(thunder_C3_during)-1)/fs,mean(thunder_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot((0:length(thunder_C3_after)-1)/fs,thunder_C3_after(i,:));
    hold on;
end
plot((0:length(thunder_C3_after)-1)/fs,mean(thunder_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-55 55]);

title('After(thunder)');

suptitle('Channel C3');

%% plots for channel Cz

figure;

% boom
subplot (3,6,1);
for i=1:3
    plot((0:length(boom_Cz_before)-1)/fs,boom_Cz_before(i,:));
    hold on;
end
plot((0:length(boom_Cz_before)-1)/fs,mean(boom_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot((0:length(boom_Cz_during)-1)/fs,boom_Cz_during(i,:));
    hold on;
end
plot((0:length(boom_Cz_during)-1)/fs,mean(boom_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot((0:length(boom_Cz_after)-1)/fs,boom_Cz_after(i,:));
    hold on;
end
plot((0:length(boom_Cz_after)-1)/fs,mean(boom_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After (Boom)');


% ringing
subplot (3,6,2);
for i=1:3
    plot((0:length(ringing_Cz_before)-1)/fs,ringing_Cz_before(i,:));
    hold on;
end
plot((0:length(ringing_Cz_before)-1)/fs,mean(ringing_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Ringing)');

subplot (3,6,8);
for i=1:3
    plot((0:length(ringing_Cz_during)-1)/fs,ringing_Cz_during(i,:));
    hold on;
end
plot((0:length(ringing_Cz_during)-1)/fs,mean(ringing_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Ringing)');

subplot (3,6,14);
for i=1:3
    plot((0:length(ringing_Cz_after)-1)/fs,ringing_Cz_after(i,:));
    hold on;
end
plot((0:length(ringing_Cz_after)-1)/fs,mean(ringing_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After (Ringing)');

% crying 
subplot (3,6,3);
for i=1:3
    plot((0:length(crying_Cz_before)-1)/fs,crying_Cz_before(i,:));
    hold on;
end
plot((0:length(crying_Cz_before)-1)/fs,mean(crying_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Crying)');

subplot (3,6,9);
for i=1:3
    plot((0:length(crying_Cz_during)-1)/fs,crying_Cz_during(i,:));
    hold on;
end
plot((0:length(crying_Cz_during)-1)/fs,mean(crying_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Crying)');

subplot (3,6,15);
for i=1:3
    plot((0:length(crying_Cz_after)-1)/fs,crying_Cz_after(i,:));
    hold on;
end
plot((0:length(crying_Cz_after)-1)/fs,mean(crying_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(Crying)');

% laughing
subplot (3,6,4);
for i=1:3
    plot((0:length(laughing_Cz_before)-1)/fs,laughing_Cz_before(i,:));
    hold on;
end
plot((0:length(laughing_Cz_before)-1)/fs,mean(laughing_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Laughing)');

subplot (3,6,10);
for i=1:3
    plot((0:length(laughing_Cz_during)-1)/fs,laughing_Cz_during(i,:));
    hold on;
end
plot((0:length(laughing_Cz_during)-1)/fs,mean(laughing_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Laughing)');

subplot (3,6,16);
for i=1:3
    plot((0:length(laughing_Cz_after)-1)/fs,laughing_Cz_after(i,:));
    hold on;
end
plot((0:length(laughing_Cz_after)-1)/fs,mean(laughing_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(Laughing)');

% birds
subplot (3,6,5);
for i=1:3
    plot((0:length(birds_Cz_before)-1)/fs,birds_Cz_before(i,:));
    hold on;
end
plot((0:length(birds_Cz_before)-1)/fs,mean(birds_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot((0:length(birds_Cz_during)-1)/fs,birds_Cz_during(i,:));
    hold on;
end
plot((0:length(birds_Cz_during)-1)/fs,mean(birds_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot((0:length(birds_Cz_after)-1)/fs,birds_Cz_after(i,:));
    hold on;
end
plot((0:length(birds_Cz_after)-1)/fs,mean(birds_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(birds)');

% thunder
subplot (3,6,6);
for i=1:3
    plot((0:length(thunder_Cz_before)-1)/fs,thunder_Cz_before(i,:));
    hold on;
end
plot((0:length(thunder_Cz_before)-1)/fs,mean(thunder_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot((0:length(thunder_Cz_during)-1)/fs,thunder_Cz_during(i,:));
    hold on;
end
plot((0:length(thunder_Cz_during)-1)/fs,mean(thunder_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot((0:length(thunder_Cz_after)-1)/fs,thunder_Cz_after(i,:));
    hold on;
end
plot((0:length(thunder_Cz_after)-1)/fs,mean(thunder_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(thunder)');

suptitle('Channel Cz');

%% plots for channel C4

figure;

% boom
subplot (3,6,1);
for i=1:3
    plot((0:length(boom_C4_before)-1)/fs,boom_C4_before(i,:));
    hold on;
end
plot((0:length(boom_C4_before)-1)/fs,mean(boom_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot((0:length(boom_C4_during)-1)/fs,boom_C4_during(i,:));
    hold on;
end
plot((0:length(boom_C4_during)-1)/fs,mean(boom_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot((0:length(boom_C4_after)-1)/fs,boom_C4_after(i,:));
    hold on;
end
plot((0:length(boom_C4_after)-1)/fs,mean(boom_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After (Boom)');


% ringing
subplot (3,6,2);
for i=1:3
    plot((0:length(ringing_C4_before)-1)/fs,ringing_C4_before(i,:));
    hold on;
end
plot((0:length(ringing_C4_before)-1)/fs,mean(ringing_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Ringing)');

subplot (3,6,8);
for i=1:3
    plot((0:length(ringing_C4_during)-1)/fs,ringing_C4_during(i,:));
    hold on;
end
plot((0:length(ringing_C4_during)-1)/fs,mean(ringing_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Ringing)');

subplot (3,6,14);
for i=1:3
    plot((0:length(ringing_C4_after)-1)/fs,ringing_C4_after(i,:));
    hold on;
end
plot((0:length(ringing_C4_after)-1)/fs,mean(ringing_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After (Ringing)');

% crying 
subplot (3,6,3);
for i=1:3
    plot((0:length(crying_C4_before)-1)/fs,crying_C4_before(i,:));
    hold on;
end
plot((0:length(crying_C4_before)-1)/fs,mean(crying_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Crying)');

subplot (3,6,9);
for i=1:3
    plot((0:length(crying_C4_during)-1)/fs,crying_C4_during(i,:));
    hold on;
end
plot((0:length(crying_C4_during)-1)/fs,mean(crying_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Crying)');

subplot (3,6,15);
for i=1:3
    plot((0:length(crying_C4_after)-1)/fs,crying_C4_after(i,:));
    hold on;
end
plot((0:length(crying_C4_after)-1)/fs,mean(crying_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(Crying)');

% laughing
subplot (3,6,4);
for i=1:3
    plot((0:length(laughing_C4_before)-1)/fs,laughing_C4_before(i,:));
    hold on;
end
plot((0:length(laughing_C4_before)-1)/fs,mean(laughing_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Laughing)');

subplot (3,6,10);
for i=1:3
    plot((0:length(laughing_C4_during)-1)/fs,laughing_C4_during(i,:));
    hold on;
end
plot((0:length(laughing_C4_during)-1)/fs,mean(laughing_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Laughing)');

subplot (3,6,16);
for i=1:3
    plot((0:length(laughing_C4_after)-1)/fs,laughing_C4_after(i,:));
    hold on;
end
plot((0:length(laughing_C4_after)-1)/fs,mean(laughing_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(Laughing)');

% birds
subplot (3,6,5);
for i=1:3
    plot((0:length(birds_C4_before)-1)/fs,birds_C4_before(i,:));
    hold on;
end
plot((0:length(birds_C4_before)-1)/fs,mean(birds_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot((0:length(birds_C4_during)-1)/fs,birds_C4_during(i,:));
    hold on;
end
plot((0:length(birds_C4_during)-1)/fs,mean(birds_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot((0:length(birds_C4_after)-1)/fs,birds_C4_after(i,:));
    hold on;
end
plot((0:length(birds_C4_after)-1)/fs,mean(birds_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(birds)');

% thunder
subplot (3,6,6);
for i=1:3
    plot((0:length(thunder_C4_before)-1)/fs,thunder_C4_before(i,:));
    hold on;
end
plot((0:length(thunder_C4_before)-1)/fs,mean(thunder_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot((0:length(thunder_C4_during)-1)/fs,thunder_C4_during(i,:));
    hold on;
end
plot((0:length(thunder_C4_during)-1)/fs,mean(thunder_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot((0:length(thunder_C4_after)-1)/fs,thunder_C4_after(i,:));
    hold on;
end
plot((0:length(thunder_C4_after)-1)/fs,mean(thunder_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(thunder)');

suptitle('Channel C4');

%% plots for channel P3

figure;

% boom
subplot (3,6,1);
for i=1:3
    plot((0:length(boom_P3_before)-1)/fs,boom_P3_before(i,:));
    hold on;
end
plot((0:length(boom_P3_before)-1)/fs,mean(boom_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot((0:length(boom_P3_during)-1)/fs,boom_P3_during(i,:));
    hold on;
end
plot((0:length(boom_P3_during)-1)/fs,mean(boom_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot((0:length(boom_P3_after)-1)/fs,boom_P3_after(i,:));
    hold on;
end
plot((0:length(boom_P3_after)-1)/fs,mean(boom_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After (Boom)');


% ringing
subplot (3,6,2);
for i=1:3
    plot((0:length(ringing_P3_before)-1)/fs,ringing_P3_before(i,:));
    hold on;
end
plot((0:length(ringing_P3_before)-1)/fs,mean(ringing_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Ringing)');

subplot (3,6,8);
for i=1:3
    plot((0:length(ringing_P3_during)-1)/fs,ringing_P3_during(i,:));
    hold on;
end
plot((0:length(ringing_P3_during)-1)/fs,mean(ringing_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Ringing)');

subplot (3,6,14);
for i=1:3
    plot((0:length(ringing_P3_after)-1)/fs,ringing_P3_after(i,:));
    hold on;
end
plot((0:length(ringing_P3_after)-1)/fs,mean(ringing_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After (Ringing)');

% crying 
subplot (3,6,3);
for i=1:3
    plot((0:length(crying_P3_before)-1)/fs,crying_P3_before(i,:));
    hold on;
end
plot((0:length(crying_P3_before)-1)/fs,mean(crying_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Crying)');

subplot (3,6,9);
for i=1:3
    plot((0:length(crying_P3_during)-1)/fs,crying_P3_during(i,:));
    hold on;
end
plot((0:length(crying_P3_during)-1)/fs,mean(crying_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Crying)');

subplot (3,6,15);
for i=1:3
    plot((0:length(crying_P3_after)-1)/fs,crying_P3_after(i,:));
    hold on;
end
plot((0:length(crying_P3_after)-1)/fs,mean(crying_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(Crying)');

% laughing
subplot (3,6,4);
for i=1:3
    plot((0:length(laughing_P3_before)-1)/fs,laughing_P3_before(i,:));
    hold on;
end
plot((0:length(laughing_P3_before)-1)/fs,mean(laughing_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (Laughing)');

subplot (3,6,10);
for i=1:3
    plot((0:length(laughing_P3_during)-1)/fs,laughing_P3_during(i,:));
    hold on;
end
plot((0:length(laughing_P3_during)-1)/fs,mean(laughing_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (Laughing)');

subplot (3,6,16);
for i=1:3
    plot((0:length(laughing_P3_after)-1)/fs,laughing_P3_after(i,:));
    hold on;
end
plot((0:length(laughing_P3_after)-1)/fs,mean(laughing_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(Laughing)');

% birds
subplot (3,6,5);
for i=1:3
    plot((0:length(birds_P3_before)-1)/fs,birds_P3_before(i,:));
    hold on;
end
plot((0:length(birds_P3_before)-1)/fs,mean(birds_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot((0:length(birds_P3_during)-1)/fs,birds_P3_during(i,:));
    hold on;
end
plot((0:length(birds_P3_during)-1)/fs,mean(birds_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot((0:length(birds_P3_after)-1)/fs,birds_P3_after(i,:));
    hold on;
end
plot((0:length(birds_P3_after)-1)/fs,mean(birds_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(birds)');

% thunder
subplot (3,6,6);
for i=1:3
    plot((0:length(thunder_P3_before)-1)/fs,thunder_P3_before(i,:));
    hold on;
end
plot((0:length(thunder_P3_before)-1)/fs,mean(thunder_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot((0:length(thunder_P3_during)-1)/fs,thunder_P3_during(i,:));
    hold on;
end
plot((0:length(thunder_P3_during)-1)/fs,mean(thunder_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot((0:length(thunder_P3_after)-1)/fs,thunder_P3_after(i,:));
    hold on;
end
plot((0:length(thunder_P3_after)-1)/fs,mean(thunder_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-50 50]);

title('After(thunder)');

suptitle('Channel P3');

%% plots for channel O1

figure;

% boom
subplot (3,6,1);
for i=1:3
    plot((0:length(boom_O1_before)-1)/fs,boom_O1_before(i,:));
    hold on;
end
plot((0:length(boom_O1_before)-1)/fs,mean(boom_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot((0:length(boom_O1_during)-1)/fs,boom_O1_during(i,:));
    hold on;
end
plot((0:length(boom_O1_during)-1)/fs,mean(boom_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot((0:length(boom_O1_after)-1)/fs,boom_O1_after(i,:));
    hold on;
end
plot((0:length(boom_O1_after)-1)/fs,mean(boom_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After (Boom)');


% ringing
subplot (3,6,2);
for i=1:3
    plot((0:length(ringing_O1_before)-1)/fs,ringing_O1_before(i,:));
    hold on;
end
plot((0:length(ringing_O1_before)-1)/fs,mean(ringing_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (Ringing)');

subplot (3,6,8);
for i=1:3
    plot((0:length(ringing_O1_during)-1)/fs,ringing_O1_during(i,:));
    hold on;
end
plot((0:length(ringing_O1_during)-1)/fs,mean(ringing_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (Ringing)');

subplot (3,6,14);
for i=1:3
    plot((0:length(ringing_O1_after)-1)/fs,ringing_O1_after(i,:));
    hold on;
end
plot((0:length(ringing_O1_after)-1)/fs,mean(ringing_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After (Ringing)');

% crying 
subplot (3,6,3);
for i=1:3
    plot((0:length(crying_O1_before)-1)/fs,crying_O1_before(i,:));
    hold on;
end
plot((0:length(crying_O1_before)-1)/fs,mean(crying_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (Crying)');

subplot (3,6,9);
for i=1:3
    plot((0:length(crying_O1_during)-1)/fs,crying_O1_during(i,:));
    hold on;
end
plot((0:length(crying_O1_during)-1)/fs,mean(crying_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (Crying)');

subplot (3,6,15);
for i=1:3
    plot((0:length(crying_O1_after)-1)/fs,crying_O1_after(i,:));
    hold on;
end
plot((0:length(crying_O1_after)-1)/fs,mean(crying_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After(Crying)');

% laughing
subplot (3,6,4);
for i=1:3
    plot((0:length(laughing_O1_before)-1)/fs,laughing_O1_before(i,:));
    hold on;
end
plot((0:length(laughing_O1_before)-1)/fs,mean(laughing_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (Laughing)');

subplot (3,6,10);
for i=1:3
    plot((0:length(laughing_O1_during)-1)/fs,laughing_O1_during(i,:));
    hold on;
end
plot((0:length(laughing_O1_during)-1)/fs,mean(laughing_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (Laughing)');

subplot (3,6,16);
for i=1:3
    plot((0:length(laughing_O1_after)-1)/fs,laughing_O1_after(i,:));
    hold on;
end
plot((0:length(laughing_O1_after)-1)/fs,mean(laughing_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After(Laughing)');

% birds
subplot (3,6,5);
for i=1:3
    plot((0:length(birds_O1_before)-1)/fs,birds_O1_before(i,:));
    hold on;
end
plot((0:length(birds_O1_before)-1)/fs,mean(birds_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot((0:length(birds_O1_during)-1)/fs,birds_O1_during(i,:));
    hold on;
end
plot((0:length(birds_O1_during)-1)/fs,mean(birds_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-39 40]);

title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot((0:length(birds_O1_after)-1)/fs,birds_O1_after(i,:));
    hold on;
end
plot((0:length(birds_O1_after)-1)/fs,mean(birds_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After(birds)');

% thunder
subplot (3,6,6);
for i=1:3
    plot((0:length(thunder_O1_before)-1)/fs,thunder_O1_before(i,:));
    hold on;
end
plot((0:length(thunder_O1_before)-1)/fs,mean(thunder_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot((0:length(thunder_O1_during)-1)/fs,thunder_O1_during(i,:));
    hold on;
end
plot((0:length(thunder_O1_during)-1)/fs,mean(thunder_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot((0:length(thunder_O1_after)-1)/fs,thunder_O1_after(i,:));
    hold on;
end
plot((0:length(thunder_O1_after)-1)/fs,mean(thunder_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After(thunder)');

suptitle('Channel O1');

%% plots for channel O2

figure;

% boom
subplot (3,6,1);
for i=1:3
    plot((0:length(boom_O2_before)-1)/fs,boom_O2_before(i,:));
    hold on;
end
plot((0:length(boom_O2_before)-1)/fs,mean(boom_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot((0:length(boom_O2_during)-1)/fs,boom_O2_during(i,:));
    hold on;
end
plot((0:length(boom_O2_during)-1)/fs,mean(boom_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot((0:length(boom_O2_after)-1)/fs,boom_O2_after(i,:));
    hold on;
end
plot((0:length(boom_O2_after)-1)/fs,mean(boom_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After (Boom)');


% ringing
subplot (3,6,2);
for i=1:3
    plot((0:length(ringing_O2_before)-1)/fs,ringing_O2_before(i,:));
    hold on;
end
plot((0:length(ringing_O2_before)-1)/fs,mean(ringing_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (Ringing)');

subplot (3,6,8);
for i=1:3
    plot((0:length(ringing_O2_during)-1)/fs,ringing_O2_during(i,:));
    hold on;
end
plot((0:length(ringing_O2_during)-1)/fs,mean(ringing_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (Ringing)');

subplot (3,6,14);
for i=1:3
    plot((0:length(ringing_O2_after)-1)/fs,ringing_O2_after(i,:));
    hold on;
end
plot((0:length(ringing_O2_after)-1)/fs,mean(ringing_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After (Ringing)');

% crying 
subplot (3,6,3);
for i=1:3
    plot((0:length(crying_O2_before)-1)/fs,crying_O2_before(i,:));
    hold on;
end
plot((0:length(crying_O2_before)-1)/fs,mean(crying_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (Crying)');

subplot (3,6,9);
for i=1:3
    plot((0:length(crying_O2_during)-1)/fs,crying_O2_during(i,:));
    hold on;
end
plot((0:length(crying_O2_during)-1)/fs,mean(crying_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (Crying)');

subplot (3,6,15);
for i=1:3
    plot((0:length(crying_O2_after)-1)/fs,crying_O2_after(i,:));
    hold on;
end
plot((0:length(crying_O2_after)-1)/fs,mean(crying_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After(Crying)');

% laughing
subplot (3,6,4);
for i=1:3
    plot((0:length(laughing_O2_before)-1)/fs,laughing_O2_before(i,:));
    hold on;
end
plot((0:length(laughing_O2_before)-1)/fs,mean(laughing_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (Laughing)');

subplot (3,6,10);
for i=1:3
    plot((0:length(laughing_O2_during)-1)/fs,laughing_O2_during(i,:));
    hold on;
end
plot((0:length(laughing_O2_during)-1)/fs,mean(laughing_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (Laughing)');

subplot (3,6,16);
for i=1:3
    plot((0:length(laughing_O2_after)-1)/fs,laughing_O2_after(i,:));
    hold on;
end
plot((0:length(laughing_O2_after)-1)/fs,mean(laughing_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After(Laughing)');

% birds
subplot (3,6,5);
for i=1:3
    plot((0:length(birds_O2_before)-1)/fs,birds_O2_before(i,:));
    hold on;
end
plot((0:length(birds_O2_before)-1)/fs,mean(birds_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot((0:length(birds_O2_during)-1)/fs,birds_O2_during(i,:));
    hold on;
end
plot((0:length(birds_O2_during)-1)/fs,mean(birds_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot((0:length(birds_O2_after)-1)/fs,birds_O2_after(i,:));
    hold on;
end
plot((0:length(birds_O2_after)-1)/fs,mean(birds_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After(birds)');

% thunder
subplot (3,6,6);
for i=1:3
    plot((0:length(thunder_O2_before)-1)/fs,thunder_O2_before(i,:));
    hold on;
end
plot((0:length(thunder_O2_before)-1)/fs,mean(thunder_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot((0:length(thunder_O2_during)-1)/fs,thunder_O2_during(i,:));
    hold on;
end
plot((0:length(thunder_O2_during)-1)/fs,mean(thunder_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot((0:length(thunder_O2_after)-1)/fs,thunder_O2_after(i,:));
    hold on;
end
plot((0:length(thunder_O2_after)-1)/fs,mean(thunder_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
ylim([-40 40]);

title('After(thunder)');

suptitle('Channel O2');

%% PSD estimates

%% F3

%boom
boom_pxx_F3_before=pwelch(boom_F3_before')';
boom_pxx_F3_during=pwelch(boom_F3_during')';
boom_pxx_F3_after=pwelch(boom_F3_after')';

%ringing
ringing_pxx_F3_before=pwelch(ringing_F3_before')';
ringing_pxx_F3_during=pwelch(ringing_F3_during')';
ringing_pxx_F3_after=pwelch(ringing_F3_after')';

%crying 
crying_pxx_F3_before=pwelch(crying_F3_before')';
crying_pxx_F3_during=pwelch(crying_F3_during')';
crying_pxx_F3_after=pwelch(crying_F3_after')';

%laughing 
laughing_pxx_F3_before=pwelch(laughing_F3_before')';
laughing_pxx_F3_during=pwelch(laughing_F3_during')';
laughing_pxx_F3_after=pwelch(laughing_F3_after')';

%birds 
birds_pxx_F3_before=pwelch(birds_F3_before')';
birds_pxx_F3_during=pwelch(birds_F3_during')';
birds_pxx_F3_after=pwelch(birds_F3_after')';

%thunder
thunder_pxx_F3_before=pwelch(thunder_F3_before')';
thunder_pxx_F3_during=pwelch(thunder_F3_during')';
thunder_pxx_F3_after=pwelch(thunder_F3_after')';

%% F4

% boom
boom_pxx_F4_before=pwelch(boom_F4_before')';
boom_pxx_F4_during=pwelch(boom_F4_during')';
boom_pxx_F4_after=pwelch(boom_F4_after')';

% ringing
ringing_pxx_F4_before=pwelch(ringing_F4_before')';
ringing_pxx_F4_during=pwelch(ringing_F4_during')';
ringing_pxx_F4_after=pwelch(ringing_F4_after')';

%crying 
crying_pxx_F4_before=pwelch(crying_F4_before')';
crying_pxx_F4_during=pwelch(crying_F4_during')';
crying_pxx_F4_after=pwelch(crying_F4_after')';

%laughing 
laughing_pxx_F4_before=pwelch(laughing_F4_before')';
laughing_pxx_F4_during=pwelch(laughing_F4_during')';
laughing_pxx_F4_after=pwelch(laughing_F4_after')';

%birds 
birds_pxx_F4_before=pwelch(birds_F4_before')';
birds_pxx_F4_during=pwelch(birds_F4_during')';
birds_pxx_F4_after=pwelch(birds_F4_after')';

%thunder
thunder_pxx_F4_before=pwelch(thunder_F4_before')';
thunder_pxx_F4_during=pwelch(thunder_F4_during')';
thunder_pxx_F4_after=pwelch(thunder_F4_after')';

%% C3
% boom
boom_pxx_C3_before=pwelch(boom_C3_before')';
boom_pxx_C3_during=pwelch(boom_C3_during')';
boom_pxx_C3_after=pwelch(boom_C3_after')';

% ringing
ringing_pxx_C3_before=pwelch(ringing_C3_before')';
ringing_pxx_C3_during=pwelch(ringing_C3_during')';
ringing_pxx_C3_after=pwelch(ringing_C3_after')';

%crying 
crying_pxx_C3_before=pwelch(crying_C3_before')';
crying_pxx_C3_during=pwelch(crying_C3_during')';
crying_pxx_C3_after=pwelch(crying_C3_after')';

%laughing 
laughing_pxx_C3_before=pwelch(laughing_C3_before')';
laughing_pxx_C3_during=pwelch(laughing_C3_during')';
laughing_pxx_C3_after=pwelch(laughing_C3_after')';

%birds 
birds_pxx_C3_before=pwelch(birds_C3_before')';
birds_pxx_C3_during=pwelch(birds_C3_during')';
birds_pxx_C3_after=pwelch(birds_C3_after')';

%thunder
thunder_pxx_C3_before=pwelch(thunder_C3_before')';
thunder_pxx_C3_during=pwelch(thunder_C3_during')';
thunder_pxx_C3_after=pwelch(thunder_C3_after')';

%% Cz
% boom
boom_pxx_Cz_before=pwelch(boom_Cz_before')';
boom_pxx_Cz_during=pwelch(boom_Cz_during')';
boom_pxx_Cz_after=pwelch(boom_Cz_after')';

% ringing
ringing_pxx_Cz_before=pwelch(ringing_Cz_before')';
ringing_pxx_Cz_during=pwelch(ringing_Cz_during')';
ringing_pxx_Cz_after=pwelch(ringing_Cz_after')';

%crying 
crying_pxx_Cz_before=pwelch(crying_Cz_before')';
crying_pxx_Cz_during=pwelch(crying_Cz_during')';
crying_pxx_Cz_after=pwelch(crying_Cz_after')';

%laughing 
laughing_pxx_Cz_before=pwelch(laughing_Cz_before')';
laughing_pxx_Cz_during=pwelch(laughing_Cz_during')';
laughing_pxx_Cz_after=pwelch(laughing_Cz_after')';

%birds 
birds_pxx_Cz_before=pwelch(birds_Cz_before')';
birds_pxx_Cz_during=pwelch(birds_Cz_during')';
birds_pxx_Cz_after=pwelch(birds_Cz_after')';

%thunder
thunder_pxx_Cz_before=pwelch(thunder_Cz_before')';
thunder_pxx_Cz_during=pwelch(thunder_Cz_during')';
thunder_pxx_Cz_after=pwelch(thunder_Cz_after')';

%% C4
% boom
boom_pxx_C4_before=pwelch(boom_C4_before')';
boom_pxx_C4_during=pwelch(boom_C4_during')';
boom_pxx_C4_after=pwelch(boom_C4_after')';

% ringing
ringing_pxx_C4_before=pwelch(ringing_C4_before')';
ringing_pxx_C4_during=pwelch(ringing_C4_during')';
ringing_pxx_C4_after=pwelch(ringing_C4_after')';

%crying 
crying_pxx_C4_before=pwelch(crying_C4_before')';
crying_pxx_C4_during=pwelch(crying_C4_during')';
crying_pxx_C4_after=pwelch(crying_C4_after')';

%laughing 
laughing_pxx_C4_before=pwelch(laughing_C4_before')';
laughing_pxx_C4_during=pwelch(laughing_C4_during')';
laughing_pxx_C4_after=pwelch(laughing_C4_after')';

%birds 
birds_pxx_C4_before=pwelch(birds_C4_before')';
birds_pxx_C4_during=pwelch(birds_C4_during')';
birds_pxx_C4_after=pwelch(birds_C4_after')';

%thunder
thunder_pxx_C4_before=pwelch(thunder_C4_before')';
thunder_pxx_C4_during=pwelch(thunder_C4_during')';
thunder_pxx_C4_after=pwelch(thunder_C4_after')';

%% P3
% boom
boom_pxx_P3_before=pwelch(boom_P3_before')';
boom_pxx_P3_during=pwelch(boom_P3_during')';
boom_pxx_P3_after=pwelch(boom_P3_after')';

% ringing
ringing_pxx_P3_before=pwelch(ringing_P3_before')';
ringing_pxx_P3_during=pwelch(ringing_P3_during')';
ringing_pxx_P3_after=pwelch(ringing_P3_after')';

%crying 
crying_pxx_P3_before=pwelch(crying_P3_before')';
crying_pxx_P3_during=pwelch(crying_P3_during')';
crying_pxx_P3_after=pwelch(crying_P3_after')';

%laughing 
laughing_pxx_P3_before=pwelch(laughing_P3_before')';
laughing_pxx_P3_during=pwelch(laughing_P3_during')';
laughing_pxx_P3_after=pwelch(laughing_P3_after')';

%birds 
birds_pxx_P3_before=pwelch(birds_P3_before')';
birds_pxx_P3_during=pwelch(birds_P3_during')';
birds_pxx_P3_after=pwelch(birds_P3_after')';

%thunder
thunder_pxx_P3_before=pwelch(thunder_P3_before')';
thunder_pxx_P3_during=pwelch(thunder_P3_during')';
thunder_pxx_P3_after=pwelch(thunder_P3_after')';

%% P4
% boom
boom_pxx_P4_before=pwelch(boom_P4_before')';
boom_pxx_P4_during=pwelch(boom_P4_during')';
boom_pxx_P4_after=pwelch(boom_P4_after')';

% ringing
ringing_pxx_P4_before=pwelch(ringing_P4_before')';
ringing_pxx_P4_during=pwelch(ringing_P4_during')';
ringing_pxx_P4_after=pwelch(ringing_P4_after')';

%crying 
crying_pxx_P4_before=pwelch(crying_P4_before')';
crying_pxx_P4_during=pwelch(crying_P4_during')';
crying_pxx_P4_after=pwelch(crying_P4_after')';

%laughing 
laughing_pxx_P4_before=pwelch(laughing_P4_before')';
laughing_pxx_P4_during=pwelch(laughing_P4_during')';
laughing_pxx_P4_after=pwelch(laughing_P4_after')';

%birds 
birds_pxx_P4_before=pwelch(birds_P4_before')';
birds_pxx_P4_during=pwelch(birds_P4_during')';
birds_pxx_P4_after=pwelch(birds_P4_after')';

%thunder
thunder_pxx_P4_before=pwelch(thunder_P4_before')';
thunder_pxx_P4_during=pwelch(thunder_P4_during')';
thunder_pxx_P4_after=pwelch(thunder_P4_after')';

%% O1
% boom
boom_pxx_O1_before=pwelch(boom_O1_before')';
boom_pxx_O1_during=pwelch(boom_O1_during')';
boom_pxx_O1_after=pwelch(boom_O1_after')';

% ringing
ringing_pxx_O1_before=pwelch(ringing_O1_before')';
ringing_pxx_O1_during=pwelch(ringing_O1_during')';
ringing_pxx_O1_after=pwelch(ringing_O1_after')';

%crying 
crying_pxx_O1_before=pwelch(crying_O1_before')';
crying_pxx_O1_during=pwelch(crying_O1_during')';
crying_pxx_O1_after=pwelch(crying_O1_after')';

%laughing 
laughing_pxx_O1_before=pwelch(laughing_O1_before')';
laughing_pxx_O1_during=pwelch(laughing_O1_during')';
laughing_pxx_O1_after=pwelch(laughing_O1_after')';

%birds 
birds_pxx_O1_before=pwelch(birds_O1_before')';
birds_pxx_O1_during=pwelch(birds_O1_during')';
birds_pxx_O1_after=pwelch(birds_O1_after')';

%thunder
thunder_pxx_O1_before=pwelch(thunder_O1_before')';
thunder_pxx_O1_during=pwelch(thunder_O1_during')';
thunder_pxx_O1_after=pwelch(thunder_O1_after')';

%% O2
% boom
boom_pxx_O2_before=pwelch(boom_O2_before')';
boom_pxx_O2_during=pwelch(boom_O2_during')';
boom_pxx_O2_after=pwelch(boom_O2_after')';

% ringing
ringing_pxx_O2_before=pwelch(ringing_O2_before')';
ringing_pxx_O2_during=pwelch(ringing_O2_during')';
ringing_pxx_O2_after=pwelch(ringing_O2_after')';

%crying 
crying_pxx_O2_before=pwelch(crying_O2_before')';
crying_pxx_O2_during=pwelch(crying_O2_during')';
crying_pxx_O2_after=pwelch(crying_O2_after')';

%laughing 
laughing_pxx_O2_before=pwelch(laughing_O2_before')';
laughing_pxx_O2_during=pwelch(laughing_O2_during')';
laughing_pxx_O2_after=pwelch(laughing_O2_after')';

%birds 
birds_pxx_O2_before=pwelch(birds_O2_before')';
birds_pxx_O2_during=pwelch(birds_O2_during')';
birds_pxx_O2_after=pwelch(birds_O2_after')';

%thunder
thunder_pxx_O2_before=pwelch(thunder_O2_before')';
thunder_pxx_O2_during=pwelch(thunder_O2_during')';
thunder_pxx_O2_after=pwelch(thunder_O2_after')';

%% plots
fpxx=(0:128)*fs/(2*128);

%% plots for channel F3

figure;

%boom
subplot (3,6,1);
for i=1:3
    plot(fpxx,boom_pxx_F3_before(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot(fpxx,boom_pxx_F3_during(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot(fpxx,boom_pxx_F3_after(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (Boom)');

%ringing
subplot (3,6,2);
for i=1:3
    plot(fpxx,ringing_pxx_F3_before(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (ringing)');

subplot (3,6,8);
for i=1:3
    plot(fpxx,ringing_pxx_F3_during(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (ringing)');

subplot (3,6,14);
for i=1:3
    plot(fpxx,ringing_pxx_F3_after(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (ringing)');

%crying
subplot (3,6,3);
for i=1:3
    plot(fpxx,crying_pxx_F3_before(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (crying)');

subplot (3,6,9);
for i=1:3
    plot(fpxx,crying_pxx_F3_during(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (crying)');

subplot (3,6,15);
for i=1:3
    plot(fpxx,crying_pxx_F3_after(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (crying)');

%laughing
subplot (3,6,4);
for i=1:3
    plot(fpxx,laughing_pxx_F3_before(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (laughing)');

subplot (3,6,10);
for i=1:3
    plot(fpxx,laughing_pxx_F3_during(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (laughing)');

subplot (3,6,16);
for i=1:3
    plot(fpxx,laughing_pxx_F3_after(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (laughing)');

%birds
subplot (3,6,5);
for i=1:3
    plot(fpxx,birds_pxx_F3_before(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot(fpxx,birds_pxx_F3_during(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot(fpxx,birds_pxx_F3_after(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (birds)');

%thunder
subplot (3,6,6);
for i=1:3
    plot(fpxx,thunder_pxx_F3_before(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_F3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot(fpxx,thunder_pxx_F3_during(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_F3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot(fpxx,thunder_pxx_F3_after(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_F3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (thunder)');

suptitle('Channel F3 - PSD');
%% plots for channel F4

figure;

%boom
subplot (3,6,1);
for i=1:3
    plot(fpxx,boom_pxx_F4_before(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot(fpxx,boom_pxx_F4_during(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot(fpxx,boom_pxx_F4_after(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (Boom)');

%ringing
subplot (3,6,2);
for i=1:3
    plot(fpxx,ringing_pxx_F4_before(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (ringing)');

subplot (3,6,8);
for i=1:3
    plot(fpxx,ringing_pxx_F4_during(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (ringing)');

subplot (3,6,14);
for i=1:3
    plot(fpxx,ringing_pxx_F4_after(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (ringing)');

%crying
subplot (3,6,3);
for i=1:3
    plot(fpxx,crying_pxx_F4_before(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (crying)');

subplot (3,6,9);
for i=1:3
    plot(fpxx,crying_pxx_F4_during(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (crying)');

subplot (3,6,15);
for i=1:3
    plot(fpxx,crying_pxx_F4_after(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (crying)');

%laughing
subplot (3,6,4);
for i=1:3
    plot(fpxx,laughing_pxx_F4_before(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (laughing)');

subplot (3,6,10);
for i=1:3
    plot(fpxx,laughing_pxx_F4_during(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (laughing)');

subplot (3,6,16);
for i=1:3
    plot(fpxx,laughing_pxx_F4_after(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (laughing)');

%birds
subplot (3,6,5);
for i=1:3
    plot(fpxx,birds_pxx_F4_before(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot(fpxx,birds_pxx_F4_during(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot(fpxx,birds_pxx_F4_after(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (birds)');

%thunder
subplot (3,6,6);
for i=1:3
    plot(fpxx,thunder_pxx_F4_before(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_F4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot(fpxx,thunder_pxx_F4_during(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_F4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot(fpxx,thunder_pxx_F4_after(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_F4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 8000]);
title('After (thunder)');

suptitle('Channel F4 - PSD');

%% plots for channel C3

figure;

%boom
subplot (3,6,1);
for i=1:3
    plot(fpxx,boom_pxx_C3_before(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot(fpxx,boom_pxx_C3_during(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot(fpxx,boom_pxx_C3_after(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('After (Boom)');

%ringing
subplot (3,6,2);
for i=1:3
    plot(fpxx,ringing_pxx_C3_before(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('Before (ringing)');

subplot (3,6,8);
for i=1:3
    plot(fpxx,ringing_pxx_C3_during(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('During (ringing)');

subplot (3,6,14);
for i=1:3
    plot(fpxx,ringing_pxx_C3_after(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('After (ringing)');

%crying
subplot (3,6,3);
for i=1:3
    plot(fpxx,crying_pxx_C3_before(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('Before (crying)');

subplot (3,6,9);
for i=1:3
    plot(fpxx,crying_pxx_C3_during(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('During (crying)');

subplot (3,6,15);
for i=1:3
    plot(fpxx,crying_pxx_C3_after(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('After (crying)');

%laughing
subplot (3,6,4);
for i=1:3
    plot(fpxx,laughing_pxx_C3_before(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('Before (laughing)');

subplot (3,6,10);
for i=1:3
    plot(fpxx,laughing_pxx_C3_during(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('During (laughing)');

subplot (3,6,16);
for i=1:3
    plot(fpxx,laughing_pxx_C3_after(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('After (laughing)');

%birds
subplot (3,6,5);
for i=1:3
    plot(fpxx,birds_pxx_C3_before(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot(fpxx,birds_pxx_C3_during(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot(fpxx,birds_pxx_C3_after(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('After (birds)');

%thunder
subplot (3,6,6);
for i=1:3
    plot(fpxx,thunder_pxx_C3_before(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_C3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot(fpxx,thunder_pxx_C3_during(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_C3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot(fpxx,thunder_pxx_C3_after(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_C3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('After (thunder)');

suptitle('Channel C3 - PSD');

%% plots for channel Cz

figure;

%boom
subplot (3,6,1);
for i=1:3
    plot(fpxx,boom_pxx_Cz_before(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot(fpxx,boom_pxx_Cz_during(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot(fpxx,boom_pxx_Cz_after(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After (Boom)');

%ringing
subplot (3,6,2);
for i=1:3
    plot(fpxx,ringing_pxx_Cz_before(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (ringing)');

subplot (3,6,8);
for i=1:3
    plot(fpxx,ringing_pxx_Cz_during(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (ringing)');

subplot (3,6,14);
for i=1:3
    plot(fpxx,ringing_pxx_Cz_after(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After (ringing)');

%crying
subplot (3,6,3);
for i=1:3
    plot(fpxx,crying_pxx_Cz_before(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (crying)');

subplot (3,6,9);
for i=1:3
    plot(fpxx,crying_pxx_Cz_during(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (crying)');

subplot (3,6,15);
for i=1:3
    plot(fpxx,crying_pxx_Cz_after(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After (crying)');

%laughing
subplot (3,6,4);
for i=1:3
    plot(fpxx,laughing_pxx_Cz_before(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (laughing)');

subplot (3,6,10);
for i=1:3
    plot(fpxx,laughing_pxx_Cz_during(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (laughing)');

subplot (3,6,16);
for i=1:3
    plot(fpxx,laughing_pxx_Cz_after(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After (laughing)');

%birds
subplot (3,6,5);
for i=1:3
    plot(fpxx,birds_pxx_Cz_before(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot(fpxx,birds_pxx_Cz_during(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot(fpxx,birds_pxx_Cz_after(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After (birds)');

%thunder
subplot (3,6,6);
for i=1:3
    plot(fpxx,thunder_pxx_Cz_before(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_Cz_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot(fpxx,thunder_pxx_Cz_during(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_Cz_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot(fpxx,thunder_pxx_Cz_after(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_Cz_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After (thunder)');

suptitle('Channel Cz - PSD');

%% plots for channel C4

figure;

%boom
subplot (3,6,1);
for i=1:3
    plot(fpxx,boom_pxx_C4_before(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot(fpxx,boom_pxx_C4_during(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot(fpxx,boom_pxx_C4_after(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (Boom)');

%ringing
subplot (3,6,2);
for i=1:3
    plot(fpxx,ringing_pxx_C4_before(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (ringing)');

subplot (3,6,8);
for i=1:3
    plot(fpxx,ringing_pxx_C4_during(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (ringing)');

subplot (3,6,14);
for i=1:3
    plot(fpxx,ringing_pxx_C4_after(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (ringing)');

%crying
subplot (3,6,3);
for i=1:3
    plot(fpxx,crying_pxx_C4_before(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (crying)');

subplot (3,6,9);
for i=1:3
    plot(fpxx,crying_pxx_C4_during(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (crying)');

subplot (3,6,15);
for i=1:3
    plot(fpxx,crying_pxx_C4_after(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (crying)');

%laughing
subplot (3,6,4);
for i=1:3
    plot(fpxx,laughing_pxx_C4_before(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (laughing)');

subplot (3,6,10);
for i=1:3
    plot(fpxx,laughing_pxx_C4_during(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (laughing)');

subplot (3,6,16);
for i=1:3
    plot(fpxx,laughing_pxx_C4_after(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (laughing)');

%birds
subplot (3,6,5);
for i=1:3
    plot(fpxx,birds_pxx_C4_before(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot(fpxx,birds_pxx_C4_during(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot(fpxx,birds_pxx_C4_after(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (birds)');

%thunder
subplot (3,6,6);
for i=1:3
    plot(fpxx,thunder_pxx_C4_before(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_C4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot(fpxx,thunder_pxx_C4_during(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_C4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot(fpxx,thunder_pxx_C4_after(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_C4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (thunder)');

suptitle('Channel C4 - PSD');

%% plots for channel P3

figure;

%boom
subplot (3,6,1);
for i=1:3
    plot(fpxx,boom_pxx_P3_before(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot(fpxx,boom_pxx_P3_during(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot(fpxx,boom_pxx_P3_after(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (Boom)');

%ringing
subplot (3,6,2);
for i=1:3
    plot(fpxx,ringing_pxx_P3_before(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (ringing)');

subplot (3,6,8);
for i=1:3
    plot(fpxx,ringing_pxx_P3_during(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (ringing)');

subplot (3,6,14);
for i=1:3
    plot(fpxx,ringing_pxx_P3_after(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (ringing)');

%crying
subplot (3,6,3);
for i=1:3
    plot(fpxx,crying_pxx_P3_before(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (crying)');

subplot (3,6,9);
for i=1:3
    plot(fpxx,crying_pxx_P3_during(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (crying)');

subplot (3,6,15);
for i=1:3
    plot(fpxx,crying_pxx_P3_after(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (crying)');

%laughing
subplot (3,6,4);
for i=1:3
    plot(fpxx,laughing_pxx_P3_before(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (laughing)');

subplot (3,6,10);
for i=1:3
    plot(fpxx,laughing_pxx_P3_during(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (laughing)');

subplot (3,6,16);
for i=1:3
    plot(fpxx,laughing_pxx_P3_after(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (laughing)');

%birds
subplot (3,6,5);
for i=1:3
    plot(fpxx,birds_pxx_P3_before(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot(fpxx,birds_pxx_P3_during(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot(fpxx,birds_pxx_P3_after(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (birds)');

%thunder
subplot (3,6,6);
for i=1:3
    plot(fpxx,thunder_pxx_P3_before(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_P3_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot(fpxx,thunder_pxx_P3_during(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_P3_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot(fpxx,thunder_pxx_P3_after(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_P3_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (thunder)');

suptitle('Channel P3 - PSD');

%% plots for channel P4

figure;

%boom
subplot (3,6,1);
for i=1:3
    plot(fpxx,boom_pxx_P4_before(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_P4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot(fpxx,boom_pxx_P4_during(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_P4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot(fpxx,boom_pxx_P4_after(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_P4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (Boom)');

%ringing
subplot (3,6,2);
for i=1:3
    plot(fpxx,ringing_pxx_P4_before(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_P4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (ringing)');

subplot (3,6,8);
for i=1:3
    plot(fpxx,ringing_pxx_P4_during(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_P4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (ringing)');

subplot (3,6,14);
for i=1:3
    plot(fpxx,ringing_pxx_P4_after(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_P4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (ringing)');

%crying
subplot (3,6,3);
for i=1:3
    plot(fpxx,crying_pxx_P4_before(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_P4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (crying)');

subplot (3,6,9);
for i=1:3
    plot(fpxx,crying_pxx_P4_during(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_P4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (crying)');

subplot (3,6,15);
for i=1:3
    plot(fpxx,crying_pxx_P4_after(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_P4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (crying)');

%laughing
subplot (3,6,4);
for i=1:3
    plot(fpxx,laughing_pxx_P4_before(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_P4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (laughing)');

subplot (3,6,10);
for i=1:3
    plot(fpxx,laughing_pxx_P4_during(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_P4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (laughing)');

subplot (3,6,16);
for i=1:3
    plot(fpxx,laughing_pxx_P4_after(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_P4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (laughing)');

%birds
subplot (3,6,5);
for i=1:3
    plot(fpxx,birds_pxx_P4_before(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_P4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot(fpxx,birds_pxx_P4_during(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_P4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot(fpxx,birds_pxx_P4_after(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_P4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (birds)');

%thunder
subplot (3,6,6);
for i=1:3
    plot(fpxx,thunder_pxx_P4_before(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_P4_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot(fpxx,thunder_pxx_P4_during(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_P4_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot(fpxx,thunder_pxx_P4_after(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_P4_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (thunder)');

suptitle('Channel P4 - PSD');


%% plots for channel O1

figure;

%boom
subplot (3,6,1);
for i=1:3
    plot(fpxx,boom_pxx_O1_before(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot(fpxx,boom_pxx_O1_during(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot(fpxx,boom_pxx_O1_after(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (Boom)');

%ringing
subplot (3,6,2);
for i=1:3
    plot(fpxx,ringing_pxx_O1_before(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (ringing)');

subplot (3,6,8);
for i=1:3
    plot(fpxx,ringing_pxx_O1_during(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (ringing)');

subplot (3,6,14);
for i=1:3
    plot(fpxx,ringing_pxx_O1_after(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (ringing)');

%crying
subplot (3,6,3);
for i=1:3
    plot(fpxx,crying_pxx_O1_before(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (crying)');

subplot (3,6,9);
for i=1:3
    plot(fpxx,crying_pxx_O1_during(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (crying)');

subplot (3,6,15);
for i=1:3
    plot(fpxx,crying_pxx_O1_after(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (crying)');

%laughing
subplot (3,6,4);
for i=1:3
    plot(fpxx,laughing_pxx_O1_before(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (laughing)');

subplot (3,6,10);
for i=1:3
    plot(fpxx,laughing_pxx_O1_during(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (laughing)');

subplot (3,6,16);
for i=1:3
    plot(fpxx,laughing_pxx_O1_after(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (laughing)');

%birds
subplot (3,6,5);
for i=1:3
    plot(fpxx,birds_pxx_O1_before(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot(fpxx,birds_pxx_O1_during(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot(fpxx,birds_pxx_O1_after(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (birds)');

%thunder
subplot (3,6,6);
for i=1:3
    plot(fpxx,thunder_pxx_O1_before(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_O1_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot(fpxx,thunder_pxx_O1_during(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_O1_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot(fpxx,thunder_pxx_O1_after(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_O1_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5000]);
title('After (thunder)');

suptitle('Channel O1 - PSD');

%% plots for channel O2

figure;

%boom
subplot (3,6,1);
for i=1:3
    plot(fpxx,boom_pxx_O2_before(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (Boom)');

subplot (3,6,7);
for i=1:3
    plot(fpxx,boom_pxx_O2_during(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (Boom)');

subplot (3,6,13);
for i=1:3
    plot(fpxx,boom_pxx_O2_after(i,:));
    hold on;
end
plot(fpxx,mean(boom_pxx_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (Boom)');

%ringing
subplot (3,6,2);
for i=1:3
    plot(fpxx,ringing_pxx_O2_before(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (ringing)');

subplot (3,6,8);
for i=1:3
    plot(fpxx,ringing_pxx_O2_during(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (ringing)');

subplot (3,6,14);
for i=1:3
    plot(fpxx,ringing_pxx_O2_after(i,:));
    hold on;
end
plot(fpxx,mean(ringing_pxx_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (ringing)');

%crying
subplot (3,6,3);
for i=1:3
    plot(fpxx,crying_pxx_O2_before(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (crying)');

subplot (3,6,9);
for i=1:3
    plot(fpxx,crying_pxx_O2_during(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (crying)');

subplot (3,6,15);
for i=1:3
    plot(fpxx,crying_pxx_O2_after(i,:));
    hold on;
end
plot(fpxx,mean(crying_pxx_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (crying)');

%laughing
subplot (3,6,4);
for i=1:3
    plot(fpxx,laughing_pxx_O2_before(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (laughing)');

subplot (3,6,10);
for i=1:3
    plot(fpxx,laughing_pxx_O2_during(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (laughing)');

subplot (3,6,16);
for i=1:3
    plot(fpxx,laughing_pxx_O2_after(i,:));
    hold on;
end
plot(fpxx,mean(laughing_pxx_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (laughing)');

%birds
subplot (3,6,5);
for i=1:3
    plot(fpxx,birds_pxx_O2_before(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (birds)');

subplot (3,6,11);
for i=1:3
    plot(fpxx,birds_pxx_O2_during(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (birds)');

subplot (3,6,17);
for i=1:3
    plot(fpxx,birds_pxx_O2_after(i,:));
    hold on;
end
plot(fpxx,mean(birds_pxx_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (birds)');

%thunder
subplot (3,6,6);
for i=1:3
    plot(fpxx,thunder_pxx_O2_before(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_O2_before(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('Before (thunder)');

subplot (3,6,12);
for i=1:3
    plot(fpxx,thunder_pxx_O2_during(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_O2_during(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('During (thunder)');

subplot (3,6,18);
for i=1:3
    plot(fpxx,thunder_pxx_O2_after(i,:));
    hold on;
end
plot(fpxx,mean(thunder_pxx_O2_after(1:3,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 4000]);
title('After (thunder)');

suptitle('Channel O2 - PSD');

%% COMPUTING RELATIVE POWERS

% Boom

rp_bef_boom_F3=relpower(mean(boom_pxx_F3_before(1:3,:)),fs);
rp_bef_boom_F4=relpower(mean(boom_pxx_F4_before(1:3,:)),fs);
rp_bef_boom_C3=relpower(mean(boom_pxx_C3_before(1:3,:)),fs);
rp_bef_boom_Cz=relpower(mean(boom_pxx_Cz_before(1:3,:)),fs);
rp_bef_boom_C4=relpower(mean(boom_pxx_C4_before(1:3,:)),fs);
rp_bef_boom_P3=relpower(mean(boom_pxx_P3_before(1:3,:)),fs);
rp_bef_boom_P4=relpower(mean(boom_pxx_P4_before(1:3,:)),fs);
rp_bef_boom_O1=relpower(mean(boom_pxx_O1_before(1:3,:)),fs);
rp_bef_boom_O2=relpower(mean(boom_pxx_O2_before(1:3,:)),fs);

rp_dur_boom_F3=relpower(mean(boom_pxx_F3_during(1:3,:)),fs);
rp_dur_boom_F4=relpower(mean(boom_pxx_F4_during(1:3,:)),fs);
rp_dur_boom_C3=relpower(mean(boom_pxx_C3_during(1:3,:)),fs);
rp_dur_boom_Cz=relpower(mean(boom_pxx_Cz_during(1:3,:)),fs);
rp_dur_boom_C4=relpower(mean(boom_pxx_C4_during(1:3,:)),fs);
rp_dur_boom_P3=relpower(mean(boom_pxx_P3_during(1:3,:)),fs);
rp_dur_boom_P4=relpower(mean(boom_pxx_P4_during(1:3,:)),fs);
rp_dur_boom_O1=relpower(mean(boom_pxx_O1_during(1:3,:)),fs);
rp_dur_boom_O2=relpower(mean(boom_pxx_O2_during(1:3,:)),fs);

rp_aft_boom_F3=relpower(mean(boom_pxx_F3_after(1:3,:)),fs);
rp_aft_boom_F4=relpower(mean(boom_pxx_F4_after(1:3,:)),fs);
rp_aft_boom_C3=relpower(mean(boom_pxx_C3_after(1:3,:)),fs);
rp_aft_boom_Cz=relpower(mean(boom_pxx_Cz_after(1:3,:)),fs);
rp_aft_boom_C4=relpower(mean(boom_pxx_C4_after(1:3,:)),fs);
rp_aft_boom_P3=relpower(mean(boom_pxx_P3_after(1:3,:)),fs);
rp_aft_boom_P4=relpower(mean(boom_pxx_P4_after(1:3,:)),fs);
rp_aft_boom_O1=relpower(mean(boom_pxx_O1_after(1:3,:)),fs);
rp_aft_boom_O2=relpower(mean(boom_pxx_O2_after(1:3,:)),fs);


% Ringing

rp_bef_ringing_F3=relpower(mean(ringing_pxx_F3_before(1:3,:)),fs);
rp_bef_ringing_F4=relpower(mean(ringing_pxx_F4_before(1:3,:)),fs);
rp_bef_ringing_C3=relpower(mean(ringing_pxx_C3_before(1:3,:)),fs);
rp_bef_ringing_Cz=relpower(mean(ringing_pxx_Cz_before(1:3,:)),fs);
rp_bef_ringing_C4=relpower(mean(ringing_pxx_C4_before(1:3,:)),fs);
rp_bef_ringing_P3=relpower(mean(ringing_pxx_P3_before(1:3,:)),fs);
rp_bef_ringing_P4=relpower(mean(ringing_pxx_P4_before(1:3,:)),fs);
rp_bef_ringing_O1=relpower(mean(ringing_pxx_O1_before(1:3,:)),fs);
rp_bef_ringing_O2=relpower(mean(ringing_pxx_O2_before(1:3,:)),fs);

rp_dur_ringing_F3=relpower(mean(ringing_pxx_F3_during(1:3,:)),fs);
rp_dur_ringing_F4=relpower(mean(ringing_pxx_F4_during(1:3,:)),fs);
rp_dur_ringing_C3=relpower(mean(ringing_pxx_C3_during(1:3,:)),fs);
rp_dur_ringing_Cz=relpower(mean(ringing_pxx_Cz_during(1:3,:)),fs);
rp_dur_ringing_C4=relpower(mean(ringing_pxx_C4_during(1:3,:)),fs);
rp_dur_ringing_P3=relpower(mean(ringing_pxx_P3_during(1:3,:)),fs);
rp_dur_ringing_P4=relpower(mean(ringing_pxx_P4_during(1:3,:)),fs);
rp_dur_ringing_O1=relpower(mean(ringing_pxx_O1_during(1:3,:)),fs);
rp_dur_ringing_O2=relpower(mean(ringing_pxx_O2_during(1:3,:)),fs);

rp_aft_ringing_F3=relpower(mean(ringing_pxx_F3_after(1:3,:)),fs);
rp_aft_ringing_F4=relpower(mean(ringing_pxx_F4_after(1:3,:)),fs);
rp_aft_ringing_C3=relpower(mean(ringing_pxx_C3_after(1:3,:)),fs);
rp_aft_ringing_Cz=relpower(mean(ringing_pxx_Cz_after(1:3,:)),fs);
rp_aft_ringing_C4=relpower(mean(ringing_pxx_C4_after(1:3,:)),fs);
rp_aft_ringing_P3=relpower(mean(ringing_pxx_P3_after(1:3,:)),fs);
rp_aft_ringing_P4=relpower(mean(ringing_pxx_P4_after(1:3,:)),fs);
rp_aft_ringing_O1=relpower(mean(ringing_pxx_O1_after(1:3,:)),fs);
rp_aft_ringing_O2=relpower(mean(ringing_pxx_O2_after(1:3,:)),fs);


% Crying

rp_bef_crying_F3=relpower(mean(crying_pxx_F3_before(1:3,:)),fs);
rp_bef_crying_F4=relpower(mean(crying_pxx_F4_before(1:3,:)),fs);
rp_bef_crying_C3=relpower(mean(crying_pxx_C3_before(1:3,:)),fs);
rp_bef_crying_Cz=relpower(mean(crying_pxx_Cz_before(1:3,:)),fs);
rp_bef_crying_C4=relpower(mean(crying_pxx_C4_before(1:3,:)),fs);
rp_bef_crying_P3=relpower(mean(crying_pxx_P3_before(1:3,:)),fs);
rp_bef_crying_P4=relpower(mean(crying_pxx_P4_before(1:3,:)),fs);
rp_bef_crying_O1=relpower(mean(crying_pxx_O1_before(1:3,:)),fs);
rp_bef_crying_O2=relpower(mean(crying_pxx_O2_before(1:3,:)),fs);

rp_dur_crying_F3=relpower(mean(crying_pxx_F3_during(1:3,:)),fs);
rp_dur_crying_F4=relpower(mean(crying_pxx_F4_during(1:3,:)),fs);
rp_dur_crying_C3=relpower(mean(crying_pxx_C3_during(1:3,:)),fs);
rp_dur_crying_Cz=relpower(mean(crying_pxx_Cz_during(1:3,:)),fs);
rp_dur_crying_C4=relpower(mean(crying_pxx_C4_during(1:3,:)),fs);
rp_dur_crying_P3=relpower(mean(crying_pxx_P3_during(1:3,:)),fs);
rp_dur_crying_P4=relpower(mean(crying_pxx_P4_during(1:3,:)),fs);
rp_dur_crying_O1=relpower(mean(crying_pxx_O1_during(1:3,:)),fs);
rp_dur_crying_O2=relpower(mean(crying_pxx_O2_during(1:3,:)),fs);

rp_aft_crying_F3=relpower(mean(crying_pxx_F3_after(1:3,:)),fs);
rp_aft_crying_F4=relpower(mean(crying_pxx_F4_after(1:3,:)),fs);
rp_aft_crying_C3=relpower(mean(crying_pxx_C3_after(1:3,:)),fs);
rp_aft_crying_Cz=relpower(mean(crying_pxx_Cz_after(1:3,:)),fs);
rp_aft_crying_C4=relpower(mean(crying_pxx_C4_after(1:3,:)),fs);
rp_aft_crying_P3=relpower(mean(crying_pxx_P3_after(1:3,:)),fs);
rp_aft_crying_P4=relpower(mean(crying_pxx_P4_after(1:3,:)),fs);
rp_aft_crying_O1=relpower(mean(crying_pxx_O1_after(1:3,:)),fs);
rp_aft_crying_O2=relpower(mean(crying_pxx_O2_after(1:3,:)),fs);


% Laughing

rp_bef_laughing_F3=relpower(mean(laughing_pxx_F3_before(1:3,:)),fs);
rp_bef_laughing_F4=relpower(mean(laughing_pxx_F4_before(1:3,:)),fs);
rp_bef_laughing_C3=relpower(mean(laughing_pxx_C3_before(1:3,:)),fs);
rp_bef_laughing_Cz=relpower(mean(laughing_pxx_Cz_before(1:3,:)),fs);
rp_bef_laughing_C4=relpower(mean(laughing_pxx_C4_before(1:3,:)),fs);
rp_bef_laughing_P3=relpower(mean(laughing_pxx_P3_before(1:3,:)),fs);
rp_bef_laughing_P4=relpower(mean(laughing_pxx_P4_before(1:3,:)),fs);
rp_bef_laughing_O1=relpower(mean(laughing_pxx_O1_before(1:3,:)),fs);
rp_bef_laughing_O2=relpower(mean(laughing_pxx_O2_before(1:3,:)),fs);

rp_dur_laughing_F3=relpower(mean(laughing_pxx_F3_during(1:3,:)),fs);
rp_dur_laughing_F4=relpower(mean(laughing_pxx_F4_during(1:3,:)),fs);
rp_dur_laughing_C3=relpower(mean(laughing_pxx_C3_during(1:3,:)),fs);
rp_dur_laughing_Cz=relpower(mean(laughing_pxx_Cz_during(1:3,:)),fs);
rp_dur_laughing_C4=relpower(mean(laughing_pxx_C4_during(1:3,:)),fs);
rp_dur_laughing_P3=relpower(mean(laughing_pxx_P3_during(1:3,:)),fs);
rp_dur_laughing_P4=relpower(mean(laughing_pxx_P4_during(1:3,:)),fs);
rp_dur_laughing_O1=relpower(mean(laughing_pxx_O1_during(1:3,:)),fs);
rp_dur_laughing_O2=relpower(mean(laughing_pxx_O2_during(1:3,:)),fs);

rp_aft_laughing_F3=relpower(mean(laughing_pxx_F3_after(1:3,:)),fs);
rp_aft_laughing_F4=relpower(mean(laughing_pxx_F4_after(1:3,:)),fs);
rp_aft_laughing_C3=relpower(mean(laughing_pxx_C3_after(1:3,:)),fs);
rp_aft_laughing_Cz=relpower(mean(laughing_pxx_Cz_after(1:3,:)),fs);
rp_aft_laughing_C4=relpower(mean(laughing_pxx_C4_after(1:3,:)),fs);
rp_aft_laughing_P3=relpower(mean(laughing_pxx_P3_after(1:3,:)),fs);
rp_aft_laughing_P4=relpower(mean(laughing_pxx_P4_after(1:3,:)),fs);
rp_aft_laughing_O1=relpower(mean(laughing_pxx_O1_after(1:3,:)),fs);
rp_aft_laughing_O2=relpower(mean(laughing_pxx_O2_after(1:3,:)),fs);


% Birds

rp_bef_birds_F3=relpower(mean(birds_pxx_F3_before(1:3,:)),fs);
rp_bef_birds_F4=relpower(mean(birds_pxx_F4_before(1:3,:)),fs);
rp_bef_birds_C3=relpower(mean(birds_pxx_C3_before(1:3,:)),fs);
rp_bef_birds_Cz=relpower(mean(birds_pxx_Cz_before(1:3,:)),fs);
rp_bef_birds_C4=relpower(mean(birds_pxx_C4_before(1:3,:)),fs);
rp_bef_birds_P3=relpower(mean(birds_pxx_P3_before(1:3,:)),fs);
rp_bef_birds_P4=relpower(mean(birds_pxx_P4_before(1:3,:)),fs);
rp_bef_birds_O1=relpower(mean(birds_pxx_O1_before(1:3,:)),fs);
rp_bef_birds_O2=relpower(mean(birds_pxx_O2_before(1:3,:)),fs);

rp_dur_birds_F3=relpower(mean(birds_pxx_F3_during(1:3,:)),fs);
rp_dur_birds_F4=relpower(mean(birds_pxx_F4_during(1:3,:)),fs);
rp_dur_birds_C3=relpower(mean(birds_pxx_C3_during(1:3,:)),fs);
rp_dur_birds_Cz=relpower(mean(birds_pxx_Cz_during(1:3,:)),fs);
rp_dur_birds_C4=relpower(mean(birds_pxx_C4_during(1:3,:)),fs);
rp_dur_birds_P3=relpower(mean(birds_pxx_P3_during(1:3,:)),fs);
rp_dur_birds_P4=relpower(mean(birds_pxx_P4_during(1:3,:)),fs);
rp_dur_birds_O1=relpower(mean(birds_pxx_O1_during(1:3,:)),fs);
rp_dur_birds_O2=relpower(mean(birds_pxx_O2_during(1:3,:)),fs);

rp_aft_birds_F3=relpower(mean(birds_pxx_F3_after(1:3,:)),fs);
rp_aft_birds_F4=relpower(mean(birds_pxx_F4_after(1:3,:)),fs);
rp_aft_birds_C3=relpower(mean(birds_pxx_C3_after(1:3,:)),fs);
rp_aft_birds_Cz=relpower(mean(birds_pxx_Cz_after(1:3,:)),fs);
rp_aft_birds_C4=relpower(mean(birds_pxx_C4_after(1:3,:)),fs);
rp_aft_birds_P3=relpower(mean(birds_pxx_P3_after(1:3,:)),fs);
rp_aft_birds_P4=relpower(mean(birds_pxx_P4_after(1:3,:)),fs);
rp_aft_birds_O1=relpower(mean(birds_pxx_O1_after(1:3,:)),fs);
rp_aft_birds_O2=relpower(mean(birds_pxx_O2_after(1:3,:)),fs);


% Thunder

rp_bef_thunder_F3=relpower(mean(thunder_pxx_F3_before(1:3,:)),fs);
rp_bef_thunder_F4=relpower(mean(thunder_pxx_F4_before(1:3,:)),fs);
rp_bef_thunder_C3=relpower(mean(thunder_pxx_C3_before(1:3,:)),fs);
rp_bef_thunder_Cz=relpower(mean(thunder_pxx_Cz_before(1:3,:)),fs);
rp_bef_thunder_C4=relpower(mean(thunder_pxx_C4_before(1:3,:)),fs);
rp_bef_thunder_P3=relpower(mean(thunder_pxx_P3_before(1:3,:)),fs);
rp_bef_thunder_P4=relpower(mean(thunder_pxx_P4_before(1:3,:)),fs);
rp_bef_thunder_O1=relpower(mean(thunder_pxx_O1_before(1:3,:)),fs);
rp_bef_thunder_O2=relpower(mean(thunder_pxx_O2_before(1:3,:)),fs);

rp_dur_thunder_F3=relpower(mean(thunder_pxx_F3_during(1:3,:)),fs);
rp_dur_thunder_F4=relpower(mean(thunder_pxx_F4_during(1:3,:)),fs);
rp_dur_thunder_C3=relpower(mean(thunder_pxx_C3_during(1:3,:)),fs);
rp_dur_thunder_Cz=relpower(mean(thunder_pxx_Cz_during(1:3,:)),fs);
rp_dur_thunder_C4=relpower(mean(thunder_pxx_C4_during(1:3,:)),fs);
rp_dur_thunder_P3=relpower(mean(thunder_pxx_P3_during(1:3,:)),fs);
rp_dur_thunder_P4=relpower(mean(thunder_pxx_P4_during(1:3,:)),fs);
rp_dur_thunder_O1=relpower(mean(thunder_pxx_O1_during(1:3,:)),fs);
rp_dur_thunder_O2=relpower(mean(thunder_pxx_O2_during(1:3,:)),fs);

rp_aft_thunder_F3=relpower(mean(thunder_pxx_F3_after(1:3,:)),fs);
rp_aft_thunder_F4=relpower(mean(thunder_pxx_F4_after(1:3,:)),fs);
rp_aft_thunder_C3=relpower(mean(thunder_pxx_C3_after(1:3,:)),fs);
rp_aft_thunder_Cz=relpower(mean(thunder_pxx_Cz_after(1:3,:)),fs);
rp_aft_thunder_C4=relpower(mean(thunder_pxx_C4_after(1:3,:)),fs);
rp_aft_thunder_P3=relpower(mean(thunder_pxx_P3_after(1:3,:)),fs);
rp_aft_thunder_P4=relpower(mean(thunder_pxx_P4_after(1:3,:)),fs);
rp_aft_thunder_O1=relpower(mean(thunder_pxx_O1_after(1:3,:)),fs);
rp_aft_thunder_O2=relpower(mean(thunder_pxx_O2_after(1:3,:)),fs);

%% MAKING TABLES

rowNames={'Delta','Theta','Alpha','Beta'};
varNames={'Before','During','After'};

RP_boom_F3=table(rp_bef_boom_F3',rp_dur_boom_F3',rp_aft_boom_F3','VariableNames',varNames,'RowNames',rowNames)
RP_ringing_F3=table(rp_bef_ringing_F3',rp_dur_ringing_F3',rp_aft_ringing_F3','VariableNames',varNames,'RowNames',rowNames)
RP_crying_F3=table(rp_bef_crying_F3',rp_dur_crying_F3',rp_aft_crying_F3','VariableNames',varNames,'RowNames',rowNames)
RP_laughing_F3=table(rp_bef_laughing_F3',rp_dur_laughing_F3',rp_aft_laughing_F3','VariableNames',varNames,'RowNames',rowNames)
RP_birds_F3=table(rp_bef_birds_F3',rp_dur_birds_F3',rp_aft_birds_F3','VariableNames',varNames,'RowNames',rowNames)
RP_thunder_F3=table(rp_bef_thunder_F3',rp_dur_thunder_F3',rp_aft_thunder_F3','VariableNames',varNames,'RowNames',rowNames)


RP_boom_F4=table(rp_bef_boom_F4',rp_dur_boom_F4',rp_aft_boom_F4','VariableNames',varNames,'RowNames',rowNames)
RP_ringing_F4=table(rp_bef_ringing_F4',rp_dur_ringing_F4',rp_aft_ringing_F4','VariableNames',varNames,'RowNames',rowNames)
RP_crying_F4=table(rp_bef_crying_F4',rp_dur_crying_F4',rp_aft_crying_F4','VariableNames',varNames,'RowNames',rowNames)
RP_laughing_F4=table(rp_bef_laughing_F4',rp_dur_laughing_F4',rp_aft_laughing_F4','VariableNames',varNames,'RowNames',rowNames)
RP_birds_F4=table(rp_bef_birds_F4',rp_dur_birds_F4',rp_aft_birds_F4','VariableNames',varNames,'RowNames',rowNames)
RP_thunder_F4=table(rp_bef_thunder_F4',rp_dur_thunder_F4',rp_aft_thunder_F4','VariableNames',varNames,'RowNames',rowNames)


RP_boom_C3=table(rp_bef_boom_C3',rp_dur_boom_C3',rp_aft_boom_C3','VariableNames',varNames,'RowNames',rowNames)
RP_ringing_C3=table(rp_bef_ringing_C3',rp_dur_ringing_C3',rp_aft_ringing_C3','VariableNames',varNames,'RowNames',rowNames)
RP_crying_C3=table(rp_bef_crying_C3',rp_dur_crying_C3',rp_aft_crying_C3','VariableNames',varNames,'RowNames',rowNames)
RP_laughing_C3=table(rp_bef_laughing_C3',rp_dur_laughing_C3',rp_aft_laughing_C3','VariableNames',varNames,'RowNames',rowNames)
RP_birds_C3=table(rp_bef_birds_C3',rp_dur_birds_C3',rp_aft_birds_C3','VariableNames',varNames,'RowNames',rowNames)
RP_thunder_C3=table(rp_bef_thunder_C3',rp_dur_thunder_C3',rp_aft_thunder_C3','VariableNames',varNames,'RowNames',rowNames)


RP_boom_Cz=table(rp_bef_boom_Cz',rp_dur_boom_Cz',rp_aft_boom_Cz','VariableNames',varNames,'RowNames',rowNames)
RP_ringing_Cz=table(rp_bef_ringing_Cz',rp_dur_ringing_Cz',rp_aft_ringing_Cz','VariableNames',varNames,'RowNames',rowNames)
RP_crying_Cz=table(rp_bef_crying_Cz',rp_dur_crying_Cz',rp_aft_crying_Cz','VariableNames',varNames,'RowNames',rowNames)
RP_laughing_Cz=table(rp_bef_laughing_Cz',rp_dur_laughing_Cz',rp_aft_laughing_Cz','VariableNames',varNames,'RowNames',rowNames)
RP_birds_Cz=table(rp_bef_birds_Cz',rp_dur_birds_Cz',rp_aft_birds_Cz','VariableNames',varNames,'RowNames',rowNames)
RP_thunder_Cz=table(rp_bef_thunder_Cz',rp_dur_thunder_Cz',rp_aft_thunder_Cz','VariableNames',varNames,'RowNames',rowNames)


RP_boom_C4=table(rp_bef_boom_C4',rp_dur_boom_C4',rp_aft_boom_C4','VariableNames',varNames,'RowNames',rowNames)
RP_ringing_C4=table(rp_bef_ringing_C4',rp_dur_ringing_C4',rp_aft_ringing_C4','VariableNames',varNames,'RowNames',rowNames)
RP_crying_C4=table(rp_bef_crying_C4',rp_dur_crying_C4',rp_aft_crying_C4','VariableNames',varNames,'RowNames',rowNames)
RP_laughing_C4=table(rp_bef_laughing_C4',rp_dur_laughing_C4',rp_aft_laughing_C4','VariableNames',varNames,'RowNames',rowNames)
RP_birds_C4=table(rp_bef_birds_C4',rp_dur_birds_C4',rp_aft_birds_C4','VariableNames',varNames,'RowNames',rowNames)
RP_thunder_C4=table(rp_bef_thunder_C4',rp_dur_thunder_C4',rp_aft_thunder_C4','VariableNames',varNames,'RowNames',rowNames)


RP_boom_P3=table(rp_bef_boom_P3',rp_dur_boom_P3',rp_aft_boom_P3','VariableNames',varNames,'RowNames',rowNames)
RP_ringing_P3=table(rp_bef_ringing_P3',rp_dur_ringing_P3',rp_aft_ringing_P3','VariableNames',varNames,'RowNames',rowNames)
RP_crying_P3=table(rp_bef_crying_P3',rp_dur_crying_P3',rp_aft_crying_P3','VariableNames',varNames,'RowNames',rowNames)
RP_laughing_P3=table(rp_bef_laughing_P3',rp_dur_laughing_P3',rp_aft_laughing_P3','VariableNames',varNames,'RowNames',rowNames)
RP_birds_P3=table(rp_bef_birds_P3',rp_dur_birds_P3',rp_aft_birds_P3','VariableNames',varNames,'RowNames',rowNames)
RP_thunder_P3=table(rp_bef_thunder_P3',rp_dur_thunder_P3',rp_aft_thunder_P3','VariableNames',varNames,'RowNames',rowNames)


RP_boom_P4=table(rp_bef_boom_P4',rp_dur_boom_P4',rp_aft_boom_P4','VariableNames',varNames,'RowNames',rowNames)
RP_ringing_P4=table(rp_bef_ringing_P4',rp_dur_ringing_P4',rp_aft_ringing_P4','VariableNames',varNames,'RowNames',rowNames)
RP_crying_P4=table(rp_bef_crying_P4',rp_dur_crying_P4',rp_aft_crying_P4','VariableNames',varNames,'RowNames',rowNames)
RP_laughing_P4=table(rp_bef_laughing_P4',rp_dur_laughing_P4',rp_aft_laughing_P4','VariableNames',varNames,'RowNames',rowNames)
RP_birds_P4=table(rp_bef_birds_P4',rp_dur_birds_P4',rp_aft_birds_P4','VariableNames',varNames,'RowNames',rowNames)
RP_thunder_P4=table(rp_bef_thunder_P4',rp_dur_thunder_P4',rp_aft_thunder_P4','VariableNames',varNames,'RowNames',rowNames)


RP_boom_O1=table(rp_bef_boom_O1',rp_dur_boom_O1',rp_aft_boom_O1','VariableNames',varNames,'RowNames',rowNames)
RP_ringing_O1=table(rp_bef_ringing_O1',rp_dur_ringing_O1',rp_aft_ringing_O1','VariableNames',varNames,'RowNames',rowNames)
RP_crying_O1=table(rp_bef_crying_O1',rp_dur_crying_O1',rp_aft_crying_O1','VariableNames',varNames,'RowNames',rowNames)
RP_laughing_O1=table(rp_bef_laughing_O1',rp_dur_laughing_O1',rp_aft_laughing_O1','VariableNames',varNames,'RowNames',rowNames)
RP_birds_O1=table(rp_bef_birds_O1',rp_dur_birds_O1',rp_aft_birds_O1','VariableNames',varNames,'RowNames',rowNames)
RP_thunder_O1=table(rp_bef_thunder_O1',rp_dur_thunder_O1',rp_aft_thunder_O1','VariableNames',varNames,'RowNames',rowNames)


RP_boom_O2=table(rp_bef_boom_O2',rp_dur_boom_O2',rp_aft_boom_O2','VariableNames',varNames,'RowNames',rowNames)
RP_ringing_O2=table(rp_bef_ringing_O2',rp_dur_ringing_O2',rp_aft_ringing_O2','VariableNames',varNames,'RowNames',rowNames)
RP_crying_O2=table(rp_bef_crying_O2',rp_dur_crying_O2',rp_aft_crying_O2','VariableNames',varNames,'RowNames',rowNames)
RP_laughing_O2=table(rp_bef_laughing_O2',rp_dur_laughing_O2',rp_aft_laughing_O2','VariableNames',varNames,'RowNames',rowNames)
RP_birds_O2=table(rp_bef_birds_O2',rp_dur_birds_O2',rp_aft_birds_O2','VariableNames',varNames,'RowNames',rowNames)
RP_thunder_O2=table(rp_bef_thunder_O2',rp_dur_thunder_O2',rp_aft_thunder_O2','VariableNames',varNames,'RowNames',rowNames)
