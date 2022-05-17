% close all; 
% clear all;
clc;

%% Load signals
[header,channels]=edfread('ac.edf');

%% Load individual channels
[Fp1,~]=getedf('ac.edf','EEGFp1');
[Fp2,~]=getedf('ac.edf','EEGFp2');
[F3,~]=getedf('ac.edf','EEGF3');
[F4,~]=getedf('ac.edf','EEGF4');
[C3,~]=getedf('ac.edf','EEGC3');
[Cz,~]=getedf('ac.edf','EEGCz');
[C4,~]=getedf('ac.edf','EEGC4');
[P3,~]=getedf('ac.edf','EEGP3');
[P4,~]=getedf('ac.edf','EEGP4');
[O1,~]=getedf('ac.edf','EEGO1');
[O2,~]=getedf('ac.edf','EEGO2');
[Audio,fsAudio]=getedf('ac.edf','Audio');
[M1,~]=getedf('ac.edf','EEGM1');
[M2,fs]=getedf('ac.edf','EEGM2');

%% analysing audio signal
%9min9seg=549seg  ~inicio beeps
%11min33seg=682seg  ~fim beeps

Audio_1=Audio(549*fsAudio:682*fsAudio);
%soundsc(Audio_1,fsAudio);

%finding time stamps of stimuli - in seconds

timestamps_1=[];
i=1;
while i<=length(Audio_1)
    if Audio_1(i)>200
        timestamps_1=[timestamps_1 i/fsAudio];
        i=i+2*fsAudio;
    else
        i=i+1;
    end
end


%% getting correspondent channel signals

% eye movements
Fp1_1=Fp1(549*fs:682*fs);
Fp2_1=Fp2(549*fs:682*fs);

% 9 channels
F3_1=F3(549*fs:682*fs);
F4_1=F4(549*fs:682*fs);
C3_1=C3(549*fs:682*fs);
C4_1=C4(549*fs:682*fs);
Cz_1=Cz(549*fs:682*fs);
P3_1=P3(549*fs:682*fs);
P4_1=P4(549*fs:682*fs);
O1_1=O1(549*fs:682*fs);
O2_1=O2(549*fs:682*fs);

% references
M1_1=M1(549*fs:682*fs);
M2_1=M2(549*fs:682*fs);

EEG_beeps_before=[Fp1_1;Fp2_1;F3_1;F4_1;C3_1;Cz_1;C4_1;P3_1;P4_1;O1_1;O2_1;M1_1;M2_1];


%% plots

figure;

tt=(0:(682-549)*fsAudio)/fsAudio;
plot(tt,Audio_1);
xlabel('Time (seconds)');
axis tight;

title('"Beep" audio signal');

%% filtering

%first of all, plot of spectrum for random channel:
figure;
ft_bef=abs(fft(F3_1));

freq=fix(length(F3_1)/2)+1;
f=fs*(1:freq)/length(F3_1);
plot(f,(ft_bef(1:freq)));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
axis tight;


%notch

f0=50; %clearly the frequency of power-line interference
w0=2*pi*(f0/fs);
z1=cos(w0)+1j*sin(w0);
z2=cos(w0)-1j*sin(w0);
% Given z1 and z2, the transfer function was obtained (equation 3.149 in the book)
aNotch=[1,0,0];
bNotch=[1,-z1-z2,1];

EEG_notch=filter(bNotch,aNotch,EEG_beeps_before')';

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
EEG_beeps=filter(B,A,EEG_notch')';


%% plots
figure;

for i=1:9
    subplot (3,3,i);
    plot(EEG_beeps(i+2,:));
    axis tight; 
    title(header.label(i+2));
end
suptitle('EEG channels');

% figure;
% subplot 211;
% plot((0:length(EEG_beeps)-1)/fs,EEG_beeps(1,:));
% hold on;
% plot((0:length(EEG_beeps)-1)/fs,EEG_beeps(2,:));
% axis tight;
% legend('Fp1','Fp2');
% title('Eye movements');
% 
% subplot 212;
% plot((0:length(EEG_beeps)-1)/fs,EEG_beeps(12,:));
% hold on;
% plot((0:length(EEG_beeps)-1)/fs,EEG_beeps(13,:));
% legend('M1','M2');
% axis tight;
% title('Reference channels');
save('EEG_beeps.mat','EEG_beeps');

%% after performing ICA to remove artifacts
file = matfile('recBeeps.mat');
EEG_beeps = file.recEEG_beeps;
%% segmentation

eeg_stamps=round(timestamps_1*fs); %converting time stamps to eeg samples

%first 12 segments - 1kHz 
%second 12 segments - 2kHz
%last 12 segments - 3kHz

%% before stimuli - 2 seconds before

for i=1:length(eeg_stamps)
    F3_before(i,:)=EEG_beeps(1,eeg_stamps(i)-2*fs:eeg_stamps(i)-1);
    F4_before(i,:)=EEG_beeps(2,eeg_stamps(i)-2*fs:eeg_stamps(i)-1);
    C3_before(i,:)=EEG_beeps(3,eeg_stamps(i)-2*fs:eeg_stamps(i)-1);
    Cz_before(i,:)=EEG_beeps(4,eeg_stamps(i)-2*fs:eeg_stamps(i)-1);
    C4_before(i,:)=EEG_beeps(5,eeg_stamps(i)-2*fs:eeg_stamps(i)-1);
    P3_before(i,:)=EEG_beeps(6,eeg_stamps(i)-2*fs:eeg_stamps(i)-1);
    P4_before(i,:)=EEG_beeps(7,eeg_stamps(i)-2*fs:eeg_stamps(i)-1);
    O1_before(i,:)=EEG_beeps(8,eeg_stamps(i)-2*fs:eeg_stamps(i)-1);
    O2_before(i,:)=EEG_beeps(9,eeg_stamps(i)-2*fs:eeg_stamps(i)-1);
end


%% during stimuli

for i=1:length(eeg_stamps)
    F3_during(i,:)=EEG_beeps(1,eeg_stamps(i):eeg_stamps(i)+fs);
    F4_during(i,:)=EEG_beeps(2,eeg_stamps(i):eeg_stamps(i)+fs);
    C3_during(i,:)=EEG_beeps(3,eeg_stamps(i):eeg_stamps(i)+fs);
    Cz_during(i,:)=EEG_beeps(4,eeg_stamps(i):eeg_stamps(i)+fs);
    C4_during(i,:)=EEG_beeps(5,eeg_stamps(i):eeg_stamps(i)+fs);
    P3_during(i,:)=EEG_beeps(6,eeg_stamps(i):eeg_stamps(i)+fs);
    P4_during(i,:)=EEG_beeps(7,eeg_stamps(i):eeg_stamps(i)+fs);
    O1_during(i,:)=EEG_beeps(8,eeg_stamps(i):eeg_stamps(i)+fs);
    O2_during(i,:)=EEG_beeps(9,eeg_stamps(i):eeg_stamps(i)+fs);
end


%% after stimuli - 2 seconds after

for i=1:length(eeg_stamps)
    F3_after(i,:)=EEG_beeps(1,eeg_stamps(i)+fs:eeg_stamps(i)+3*fs);
    F4_after(i,:)=EEG_beeps(2,eeg_stamps(i)+fs:eeg_stamps(i)+3*fs);
    C3_after(i,:)=EEG_beeps(3,eeg_stamps(i)+fs:eeg_stamps(i)+3*fs);
    Cz_after(i,:)=EEG_beeps(4,eeg_stamps(i)+fs:eeg_stamps(i)+3*fs);
    C4_after(i,:)=EEG_beeps(5,eeg_stamps(i)+fs:eeg_stamps(i)+3*fs);
    P3_after(i,:)=EEG_beeps(6,eeg_stamps(i)+fs:eeg_stamps(i)+3*fs);
    P4_after(i,:)=EEG_beeps(7,eeg_stamps(i)+fs:eeg_stamps(i)+3*fs);
    O1_after(i,:)=EEG_beeps(8,eeg_stamps(i)+fs:eeg_stamps(i)+3*fs);
    O2_after(i,:)=EEG_beeps(9,eeg_stamps(i)+fs:eeg_stamps(i)+3*fs);
end

%% plots for channel F3

figure;

%1kHz
subplot 331;
for i=1:12
    plot((0:length(F3_before)-1)/fs,F3_before(i,:));
    hold on;
end
plot((0:length(F3_before)-1)/fs,mean(F3_before(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot((0:length(F3_during)-1)/fs,F3_during(i,:));
    hold on;
end
plot((0:length(F3_during)-1)/fs,mean(F3_during(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (1kHz)');

subplot 337;
for i=1:12
    plot((0:length(F3_after)-1)/fs,F3_after(i,:));
    hold on;
end
plot((0:length(F3_after)-1)/fs,mean(F3_after(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot((0:length(F3_before)-1)/fs,F3_before(i,:));
    hold on;
end
plot((0:length(F3_before)-1)/fs,mean(F3_before(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot((0:length(F3_during)-1)/fs,F3_during(i,:));
    hold on;
end
plot((0:length(F3_during)-1)/fs,mean(F3_during(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (2kHz)');

subplot 338;
for i=13:24
    plot((0:length(F3_after)-1)/fs,F3_after(i,:));
    hold on;
end
plot((0:length(F3_after)-1)/fs,mean(F3_after(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot((0:length(F3_before)-1)/fs,F3_before(i,:));
    hold on;
end
plot((0:length(F3_before)-1)/fs,mean(F3_before(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot((0:length(F3_during)-1)/fs,F3_during(i,:));
    hold on;
end
plot((0:length(F3_during)-1)/fs,mean(F3_during(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (3kHz)');

subplot 339;
for i=25:36
    plot((0:length(F3_after)-1)/fs,F3_after(i,:));
    hold on;
end
plot((0:length(F3_after)-1)/fs,mean(F3_after(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After(3kHz)');

suptitle('Channel F3');

%% plots for channel F4

figure;

%1kHz
subplot 331;
for i=1:12
    plot((0:length(F4_before)-1)/fs,F4_before(i,:));
    hold on;
end
plot((0:length(F4_before)-1)/fs,mean(F4_before(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot((0:length(F4_during)-1)/fs,F4_during(i,:));
    hold on;
end
plot((0:length(F4_during)-1)/fs,mean(F4_during(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (1kHz)');

subplot 337;
for i=1:12
    plot((0:length(F4_after)-1)/fs,F4_after(i,:));
    hold on;
end
plot((0:length(F4_after)-1)/fs,mean(F4_after(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot((0:length(F4_before)-1)/fs,F4_before(i,:));
    hold on;
end
plot((0:length(F4_before)-1)/fs,mean(F4_before(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot((0:length(F4_during)-1)/fs,F4_during(i,:));
    hold on;
end
plot((0:length(F4_during)-1)/fs,mean(F4_during(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (2kHz)');

subplot 338;
for i=13:24
    plot((0:length(F4_after)-1)/fs,F4_after(i,:));
    hold on;
end
plot((0:length(F4_after)-1)/fs,mean(F4_after(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot((0:length(F4_before)-1)/fs,F4_before(i,:));
    hold on;
end
plot((0:length(F4_before)-1)/fs,mean(F4_before(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot((0:length(F4_during)-1)/fs,F4_during(i,:));
    hold on;
end
plot((0:length(F4_during)-1)/fs,mean(F4_during(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (3kHz)');

subplot 339;
for i=25:36
    plot((0:length(F4_after)-1)/fs,F4_after(i,:));
    hold on;
end
plot((0:length(F4_after)-1)/fs,mean(F4_after(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After(3kHz)');

suptitle('Channel F4');

%% plots for channel C3

figure;

%1kHz
subplot 331;
for i=1:12
    plot((0:length(C3_before)-1)/fs,C3_before(i,:));
    hold on;
end
plot((0:length(C3_before)-1)/fs,mean(C3_before(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot((0:length(C3_during)-1)/fs,C3_during(i,:));
    hold on;
end
plot((0:length(C3_during)-1)/fs,mean(C3_during(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (1kHz)');

subplot 337;
for i=1:12
    plot((0:length(C3_after)-1)/fs,C3_after(i,:));
    hold on;
end
plot((0:length(C3_after)-1)/fs,mean(C3_after(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot((0:length(C3_before)-1)/fs,C3_before(i,:));
    hold on;
end
plot((0:length(C3_before)-1)/fs,mean(C3_before(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot((0:length(C3_during)-1)/fs,C3_during(i,:));
    hold on;
end
plot((0:length(C3_during)-1)/fs,mean(C3_during(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (2kHz)');

subplot 338;
for i=13:24
    plot((0:length(C3_after)-1)/fs,C3_after(i,:));
    hold on;
end
plot((0:length(C3_after)-1)/fs,mean(C3_after(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot((0:length(C3_before)-1)/fs,C3_before(i,:));
    hold on;
end
plot((0:length(C3_before)-1)/fs,mean(C3_before(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot((0:length(C3_during)-1)/fs,C3_during(i,:));
    hold on;
end
plot((0:length(C3_during)-1)/fs,mean(C3_during(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (3kHz)');

subplot 339;
for i=25:36
    plot((0:length(C3_after)-1)/fs,C3_after(i,:));
    hold on;
end
plot((0:length(C3_after)-1)/fs,mean(C3_after(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After(3kHz)');

suptitle('Channel C3');

%% plots for channel Cz

figure;

%1kHz
subplot 331;
for i=1:12
    plot((0:length(Cz_before)-1)/fs,Cz_before(i,:));
    hold on;
end
plot((0:length(Cz_before)-1)/fs,mean(Cz_before(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot((0:length(Cz_during)-1)/fs,Cz_during(i,:));
    hold on;
end
plot((0:length(Cz_during)-1)/fs,mean(Cz_during(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (1kHz)');

subplot 337;
for i=1:12
    plot((0:length(Cz_after)-1)/fs,Cz_after(i,:));
    hold on;
end
plot((0:length(Cz_after)-1)/fs,mean(Cz_after(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot((0:length(Cz_before)-1)/fs,Cz_before(i,:));
    hold on;
end
plot((0:length(Cz_before)-1)/fs,mean(Cz_before(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot((0:length(Cz_during)-1)/fs,Cz_during(i,:));
    hold on;
end
plot((0:length(Cz_during)-1)/fs,mean(Cz_during(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (2kHz)');

subplot 338;
for i=13:24
    plot((0:length(Cz_after)-1)/fs,Cz_after(i,:));
    hold on;
end
plot((0:length(Cz_after)-1)/fs,mean(Cz_after(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot((0:length(Cz_before)-1)/fs,Cz_before(i,:));
    hold on;
end
plot((0:length(Cz_before)-1)/fs,mean(Cz_before(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot((0:length(Cz_during)-1)/fs,Cz_during(i,:));
    hold on;
end
plot((0:length(Cz_during)-1)/fs,mean(Cz_during(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (3kHz)');

subplot 339;
for i=25:36
    plot((0:length(Cz_after)-1)/fs,Cz_after(i,:));
    hold on;
end
plot((0:length(Cz_after)-1)/fs,mean(Cz_after(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After(3kHz)');

suptitle('Channel Cz');

%% plots for channel C4

figure;

%1kHz
subplot 331;
for i=1:12
    plot((0:length(C4_before)-1)/fs,C4_before(i,:));
    hold on;
end
plot((0:length(C4_before)-1)/fs,mean(C4_before(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot((0:length(C4_during)-1)/fs,C4_during(i,:));
    hold on;
end
plot((0:length(C4_during)-1)/fs,mean(C4_during(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (1kHz)');

subplot 337;
for i=1:12
    plot((0:length(C4_after)-1)/fs,C4_after(i,:));
    hold on;
end
plot((0:length(C4_after)-1)/fs,mean(C4_after(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot((0:length(C4_before)-1)/fs,C4_before(i,:));
    hold on;
end
plot((0:length(C4_before)-1)/fs,mean(C4_before(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot((0:length(C4_during)-1)/fs,C4_during(i,:));
    hold on;
end
plot((0:length(C4_during)-1)/fs,mean(C4_during(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (2kHz)');

subplot 338;
for i=13:24
    plot((0:length(C4_after)-1)/fs,C4_after(i,:));
    hold on;
end
plot((0:length(C4_after)-1)/fs,mean(C4_after(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot((0:length(C4_before)-1)/fs,C4_before(i,:));
    hold on;
end
plot((0:length(C4_before)-1)/fs,mean(C4_before(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot((0:length(C4_during)-1)/fs,C4_during(i,:));
    hold on;
end
plot((0:length(C4_during)-1)/fs,mean(C4_during(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (3kHz)');

subplot 339;
for i=25:36
    plot((0:length(C4_after)-1)/fs,C4_after(i,:));
    hold on;
end
plot((0:length(C4_after)-1)/fs,mean(C4_after(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After(3kHz)');

suptitle('Channel C4');

%% plots for channel P3

figure;

%1kHz
subplot 331;
for i=1:12
    plot((0:length(P3_before)-1)/fs,P3_before(i,:));
    hold on;
end
plot((0:length(P3_before)-1)/fs,mean(P3_before(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot((0:length(P3_during)-1)/fs,P3_during(i,:));
    hold on;
end
plot((0:length(P3_during)-1)/fs,mean(P3_during(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (1kHz)');

subplot 337;
for i=1:12
    plot((0:length(P3_after)-1)/fs,P3_after(i,:));
    hold on;
end
plot((0:length(P3_after)-1)/fs,mean(P3_after(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot((0:length(P3_before)-1)/fs,P3_before(i,:));
    hold on;
end
plot((0:length(P3_before)-1)/fs,mean(P3_before(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot((0:length(P3_during)-1)/fs,P3_during(i,:));
    hold on;
end
plot((0:length(P3_during)-1)/fs,mean(P3_during(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (2kHz)');

subplot 338;
for i=13:24
    plot((0:length(P3_after)-1)/fs,P3_after(i,:));
    hold on;
end
plot((0:length(P3_after)-1)/fs,mean(P3_after(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot((0:length(P3_before)-1)/fs,P3_before(i,:));
    hold on;
end
plot((0:length(P3_before)-1)/fs,mean(P3_before(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot((0:length(P3_during)-1)/fs,P3_during(i,:));
    hold on;
end
plot((0:length(P3_during)-1)/fs,mean(P3_during(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (3kHz)');

subplot 339;
for i=25:36
    plot((0:length(P3_after)-1)/fs,P3_after(i,:));
    hold on;
end
plot((0:length(P3_after)-1)/fs,mean(P3_after(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After(3kHz)');

suptitle('Channel P3');

%% plots for channel P3

figure;

%1kHz
subplot 331;
for i=1:12
    plot((0:length(P4_before)-1)/fs,P4_before(i,:));
    hold on;
end
plot((0:length(P4_before)-1)/fs,mean(P4_before(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot((0:length(P4_during)-1)/fs,P4_during(i,:));
    hold on;
end
plot((0:length(P4_during)-1)/fs,mean(P4_during(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (1kHz)');

subplot 337;
for i=1:12
    plot((0:length(P4_after)-1)/fs,P4_after(i,:));
    hold on;
end
plot((0:length(P4_after)-1)/fs,mean(P4_after(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot((0:length(P4_before)-1)/fs,P4_before(i,:));
    hold on;
end
plot((0:length(P4_before)-1)/fs,mean(P4_before(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot((0:length(P4_during)-1)/fs,P4_during(i,:));
    hold on;
end
plot((0:length(P4_during)-1)/fs,mean(P4_during(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (2kHz)');

subplot 338;
for i=13:24
    plot((0:length(P4_after)-1)/fs,P4_after(i,:));
    hold on;
end
plot((0:length(P4_after)-1)/fs,mean(P4_after(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot((0:length(P4_before)-1)/fs,P4_before(i,:));
    hold on;
end
plot((0:length(P4_before)-1)/fs,mean(P4_before(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot((0:length(P4_during)-1)/fs,P4_during(i,:));
    hold on;
end
plot((0:length(P4_during)-1)/fs,mean(P4_during(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (3kHz)');

subplot 339;
for i=25:36
    plot((0:length(P4_after)-1)/fs,P4_after(i,:));
    hold on;
end
plot((0:length(P4_after)-1)/fs,mean(P4_after(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After(3kHz)');

suptitle('Channel P4');

%% plots for channel O1

figure;

%1kHz
subplot 331;
for i=1:12
    plot((0:length(O1_before)-1)/fs,O1_before(i,:));
    hold on;
end
plot((0:length(O1_before)-1)/fs,mean(O1_before(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot((0:length(O1_during)-1)/fs,O1_during(i,:));
    hold on;
end
plot((0:length(O1_during)-1)/fs,mean(O1_during(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (1kHz)');

subplot 337;
for i=1:12
    plot((0:length(O1_after)-1)/fs,O1_after(i,:));
    hold on;
end
plot((0:length(O1_after)-1)/fs,mean(O1_after(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot((0:length(O1_before)-1)/fs,O1_before(i,:));
    hold on;
end
plot((0:length(O1_before)-1)/fs,mean(O1_before(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot((0:length(O1_during)-1)/fs,O1_during(i,:));
    hold on;
end
plot((0:length(O1_during)-1)/fs,mean(O1_during(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (2kHz)');

subplot 338;
for i=13:24
    plot((0:length(O1_after)-1)/fs,O1_after(i,:));
    hold on;
end
plot((0:length(O1_after)-1)/fs,mean(O1_after(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot((0:length(O1_before)-1)/fs,O1_before(i,:));
    hold on;
end
plot((0:length(O1_before)-1)/fs,mean(O1_before(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot((0:length(O1_during)-1)/fs,O1_during(i,:));
    hold on;
end
plot((0:length(O1_during)-1)/fs,mean(O1_during(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (3kHz)');

subplot 339;
for i=25:36
    plot((0:length(O1_after)-1)/fs,O1_after(i,:));
    hold on;
end
plot((0:length(O1_after)-1)/fs,mean(O1_after(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After(3kHz)');

suptitle('Channel O1');

%% plots for channel O2

figure;

%1kHz
subplot 331;
for i=1:12
    plot((0:length(O2_before)-1)/fs,O2_before(i,:));
    hold on;
end
plot((0:length(O2_before)-1)/fs,mean(O2_before(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot((0:length(O2_during)-1)/fs,O2_during(i,:));
    hold on;
end
plot((0:length(O2_during)-1)/fs,mean(O2_during(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (1kHz)');

subplot 337;
for i=1:12
    plot((0:length(O2_after)-1)/fs,O2_after(i,:));
    hold on;
end
plot((0:length(O2_after)-1)/fs,mean(O2_after(1:12,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot((0:length(O2_before)-1)/fs,O2_before(i,:));
    hold on;
end
plot((0:length(O2_before)-1)/fs,mean(O2_before(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot((0:length(O2_during)-1)/fs,O2_during(i,:));
    hold on;
end
plot((0:length(O2_during)-1)/fs,mean(O2_during(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (2kHz)');

subplot 338;
for i=13:24
    plot((0:length(O2_after)-1)/fs,O2_after(i,:));
    hold on;
end
plot((0:length(O2_after)-1)/fs,mean(O2_after(13:24,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot((0:length(O2_before)-1)/fs,O2_before(i,:));
    hold on;
end
plot((0:length(O2_before)-1)/fs,mean(O2_before(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot((0:length(O2_during)-1)/fs,O2_during(i,:));
    hold on;
end
plot((0:length(O2_during)-1)/fs,mean(O2_during(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('During (3kHz)');

subplot 339;
for i=25:36
    plot((0:length(O2_after)-1)/fs,O2_after(i,:));
    hold on;
end
plot((0:length(O2_after)-1)/fs,mean(O2_after(25:36,:)),'m','LineWidth',2);
xlabel('Time (seconds)');
title('After(3kHz)');

suptitle('Channel O2');

%% PSD estimates

% F3
pxx_F3_before=pwelch(F3_before')';
pxx_F3_during=pwelch(F3_during')';
pxx_F3_after=pwelch(F3_after')';

% F4
pxx_F4_before=pwelch(F4_before')';
pxx_F4_during=pwelch(F4_during')';
pxx_F4_after=pwelch(F4_after')';

% C3
pxx_C3_before=pwelch(C3_before')';
pxx_C3_during=pwelch(C3_during')';
pxx_C3_after=pwelch(C3_after')';

% Cz
pxx_Cz_before=pwelch(Cz_before')';
pxx_Cz_during=pwelch(Cz_during')';
pxx_Cz_after=pwelch(Cz_after')';

% C4
pxx_C4_before=pwelch(C4_before')';
pxx_C4_during=pwelch(C4_during')';
pxx_C4_after=pwelch(C4_after')';

% P3
pxx_P3_before=pwelch(P3_before')';
pxx_P3_during=pwelch(P3_during')';
pxx_P3_after=pwelch(P3_after')';

% P4
pxx_P4_before=pwelch(P4_before')';
pxx_P4_during=pwelch(P4_during')';
pxx_P4_after=pwelch(P4_after')';

% O1
pxx_O1_before=pwelch(O1_before')';
pxx_O1_during=pwelch(O1_during')';
pxx_O1_after=pwelch(O1_after')';

% O2
pxx_O2_before=pwelch(O2_before')';
pxx_O2_during=pwelch(O2_during')';
pxx_O2_after=pwelch(O2_after')';

%% plots
fpxx=(0:128)*fs/(2*128);

%% plots for channel F3

figure;

%1kHz
subplot 331;
for i=1:12
    plot(fpxx,pxx_F3_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F3_before(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
ylim([0 200000]);
xlim([0 30]);
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot(fpxx,pxx_F3_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F3_during(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 200000]);
title('During (1kHz)');

subplot 337;
for i=1:12
    plot(fpxx,pxx_F3_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F3_after(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 200000]);
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot(fpxx,pxx_F3_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F3_before(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 200000]);
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot(fpxx,pxx_F3_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F3_during(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 200000]);
title('During (2kHz)');

subplot 338;
for i=13:24
    plot(fpxx,pxx_F3_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F3_after(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 200000]);
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot(fpxx,pxx_F3_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F3_before(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 200000]);
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot(fpxx,pxx_F3_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F3_during(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 200000]);
title('During (3kHz)');

subplot 339;
for i=25:36
    plot(fpxx,pxx_F3_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F3_after(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 200000]);
title('After(3kHz)');

suptitle('Channel F3 - PSD');
%% plots for channel F4

figure;

%1kHz
subplot 331;
for i=1:12
    plot(fpxx,pxx_F4_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F4_before(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot(fpxx,pxx_F4_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F4_during(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (1kHz)');

subplot 337;
for i=1:12
    plot(fpxx,pxx_F4_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F4_after(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot(fpxx,pxx_F4_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F4_before(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot(fpxx,pxx_F4_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F4_during(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (2kHz)');

subplot 338;
for i=13:24
    plot(fpxx,pxx_F4_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F4_after(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot(fpxx,pxx_F4_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F4_before(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot(fpxx,pxx_F4_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F4_during(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (3kHz)');

subplot 339;
for i=25:36
    plot(fpxx,pxx_F4_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_F4_after(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After(3kHz)');

suptitle('Channel F4 - PSD');

%% plots for channel C3

figure;

%1kHz
subplot 331;
for i=1:12
    plot(fpxx,pxx_C3_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C3_before(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot(fpxx,pxx_C3_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C3_during(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('During (1kHz)');

subplot 337;
for i=1:12
    plot(fpxx,pxx_C3_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C3_after(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot(fpxx,pxx_C3_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C3_before(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
ylim([0 20000]);
xlim([0 30]);
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot(fpxx,pxx_C3_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C3_during(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('During (2kHz)');

subplot 338;
for i=13:24
    plot(fpxx,pxx_C3_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C3_after(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot(fpxx,pxx_C3_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C3_before(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot(fpxx,pxx_C3_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C3_during(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('During (3kHz)');

subplot 339;
for i=25:36
    plot(fpxx,pxx_C3_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C3_after(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 20000]);
title('After(3kHz)');

suptitle('Channel C3 - PSD');

%% plots for channel Cz

figure;

%1kHz
subplot 331;
for i=1:12
    plot(fpxx,pxx_Cz_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_Cz_before(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 7000]);
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot(fpxx,pxx_Cz_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_Cz_during(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 7000]);
title('During (1kHz)');

subplot 337;
for i=1:12
    plot(fpxx,pxx_Cz_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_Cz_after(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 7000]);
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot(fpxx,pxx_Cz_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_Cz_before(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 7000]);
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot(fpxx,pxx_Cz_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_Cz_during(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 7000]);
title('During (2kHz)');

subplot 338;
for i=13:24
    plot(fpxx,pxx_Cz_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_Cz_after(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 7000]);
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot(fpxx,pxx_Cz_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_Cz_before(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 7000]);
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot(fpxx,pxx_Cz_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_Cz_during(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 7000]);
title('During (3kHz)');

subplot 339;
for i=25:36
    plot(fpxx,pxx_Cz_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_Cz_after(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 7000]);
title('After(3kHz)');

suptitle('Channel Cz - PSD');


%% plots for channel C4

figure;

%1kHz
subplot 331;
for i=1:12
    plot(fpxx,pxx_C4_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C4_before(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 15000]);
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot(fpxx,pxx_C4_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C4_during(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 15000]);
title('During (1kHz)');

subplot 337;
for i=1:12
    plot(fpxx,pxx_C4_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C4_after(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 15000]);
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot(fpxx,pxx_C4_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C4_before(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 15000]);
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot(fpxx,pxx_C4_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C4_during(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 15000]);
title('During (2kHz)');

subplot 338;
for i=13:24
    plot(fpxx,pxx_C4_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C4_after(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 15000]);
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot(fpxx,pxx_C4_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C4_before(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 15000]);
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot(fpxx,pxx_C4_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C4_during(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 15000]);
title('During (3kHz)');

subplot 339;
for i=25:36
    plot(fpxx,pxx_C4_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_C4_after(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 15000]);
title('After(3kHz)');

suptitle('Channel C4 - PSD');

%% plots for channel P3

figure;

%1kHz
subplot 331;
for i=1:12
    plot(fpxx,pxx_P3_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P3_before(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot(fpxx,pxx_P3_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P3_during(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('During (1kHz)');

subplot 337;
for i=1:12
    plot(fpxx,pxx_P3_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P3_after(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot(fpxx,pxx_P3_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P3_before(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot(fpxx,pxx_P3_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P3_during(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('During (2kHz)');

subplot 338;
for i=13:24
    plot(fpxx,pxx_P3_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P3_after(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot(fpxx,pxx_P3_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P3_before(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot(fpxx,pxx_P3_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P3_during(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('During (3kHz)');

subplot 339;
for i=25:36
    plot(fpxx,pxx_P3_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P3_after(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('After(3kHz)');

suptitle('Channel P3 - PSD');

%% plots for channel P4

figure;

%1kHz
subplot 331;
for i=1:12
    plot(fpxx,pxx_P4_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P4_before(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot(fpxx,pxx_P4_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P4_during(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (1kHz)');

subplot 337;
for i=1:12
    plot(fpxx,pxx_P4_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P4_after(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot(fpxx,pxx_P4_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P4_before(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot(fpxx,pxx_P4_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P4_during(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (2kHz)');

subplot 338;
for i=13:24
    plot(fpxx,pxx_P4_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P4_after(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot(fpxx,pxx_P4_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P4_before(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot(fpxx,pxx_P4_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P4_during(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('During (3kHz)');

subplot 339;
for i=25:36
    plot(fpxx,pxx_P4_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_P4_after(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 25000]);
title('After(3kHz)');

suptitle('Channel P4 - PSD');

%% plots for channel O1

figure;

%1kHz
subplot 331;
for i=1:12
    plot(fpxx,pxx_O1_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O1_before(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5500]);
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot(fpxx,pxx_O1_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O1_during(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5500]);
title('During (1kHz)');

subplot 337;
for i=1:12
    plot(fpxx,pxx_O1_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O1_after(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5500]);
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot(fpxx,pxx_O1_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O1_before(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5500]);
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot(fpxx,pxx_O1_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O1_during(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5500]);
title('During (2kHz)');

subplot 338;
for i=13:24
    plot(fpxx,pxx_O1_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O1_after(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5500]);
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot(fpxx,pxx_O1_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O1_before(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5500]);
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot(fpxx,pxx_O1_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O1_during(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5500]);
title('During (3kHz)');

subplot 339;
for i=25:36
    plot(fpxx,pxx_O1_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O1_after(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 5500]);
title('After(3kHz)');

suptitle('Channel O1 - PSD');

%% plots for channel O2

figure;

%1kHz
subplot 331;
for i=1:12
    plot(fpxx,pxx_O2_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O2_before(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('Before (1kHz)');

subplot 334;
for i=1:12
    plot(fpxx,pxx_O2_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O2_during(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('During (1kHz)');

subplot 337;
for i=1:12
    plot(fpxx,pxx_O2_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O2_after(1:12,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('After (1kHz)');

%2kHz
subplot 332;
for i=13:24
    plot(fpxx,pxx_O2_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O2_before(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('Before (2kHz)');

subplot 335;
for i=13:24
    plot(fpxx,pxx_O2_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O2_during(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('During (2kHz)');

subplot 338;
for i=13:24
    plot(fpxx,pxx_O2_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O2_after(13:24,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('After (2kHz)');

%3kHz
subplot 333;
for i=25:36
    plot(fpxx,pxx_O2_before(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O2_before(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('Before (3kHz)');

subplot 336;
for i=25:36
    plot(fpxx,pxx_O2_during(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O2_during(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('During (3kHz)');

subplot 339;
for i=25:36
    plot(fpxx,pxx_O2_after(i,:));
    hold on;
end
plot(fpxx,mean(pxx_O2_after(25:36,:)),'m','LineWidth',2);
xlabel('Frequency (Hz)');
xlim([0 30]);
ylim([0 10000]);
title('After(3kHz)');

suptitle('Channel O2 - PSD');

%% COMPUTING RELATIVE POWERS

% 1 kHz

rp_bef_1_F3=relpower(mean(pxx_F3_before(1:12,:)),fs);
rp_bef_1_F4=relpower(mean(pxx_F4_before(1:12,:)),fs);
rp_bef_1_C3=relpower(mean(pxx_C3_before(1:12,:)),fs);
rp_bef_1_Cz=relpower(mean(pxx_Cz_before(1:12,:)),fs);
rp_bef_1_C4=relpower(mean(pxx_C4_before(1:12,:)),fs);
rp_bef_1_P3=relpower(mean(pxx_P3_before(1:12,:)),fs);
rp_bef_1_P4=relpower(mean(pxx_P4_before(1:12,:)),fs);
rp_bef_1_O1=relpower(mean(pxx_O1_before(1:12,:)),fs);
rp_bef_1_O2=relpower(mean(pxx_O2_before(1:12,:)),fs);

rp_dur_1_F3=relpower(mean(pxx_F3_during(1:12,:)),fs);
rp_dur_1_F4=relpower(mean(pxx_F4_during(1:12,:)),fs);
rp_dur_1_C3=relpower(mean(pxx_C3_during(1:12,:)),fs);
rp_dur_1_Cz=relpower(mean(pxx_Cz_during(1:12,:)),fs);
rp_dur_1_C4=relpower(mean(pxx_C4_during(1:12,:)),fs);
rp_dur_1_P3=relpower(mean(pxx_P3_during(1:12,:)),fs);
rp_dur_1_P4=relpower(mean(pxx_P4_during(1:12,:)),fs);
rp_dur_1_O1=relpower(mean(pxx_O1_during(1:12,:)),fs);
rp_dur_1_O2=relpower(mean(pxx_O2_during(1:12,:)),fs);

rp_aft_1_F3=relpower(mean(pxx_F3_after(1:12,:)),fs);
rp_aft_1_F4=relpower(mean(pxx_F4_after(1:12,:)),fs);
rp_aft_1_C3=relpower(mean(pxx_C3_after(1:12,:)),fs);
rp_aft_1_Cz=relpower(mean(pxx_Cz_after(1:12,:)),fs);
rp_aft_1_C4=relpower(mean(pxx_C4_after(1:12,:)),fs);
rp_aft_1_P3=relpower(mean(pxx_P3_after(1:12,:)),fs);
rp_aft_1_P4=relpower(mean(pxx_P4_after(1:12,:)),fs);
rp_aft_1_O1=relpower(mean(pxx_O1_after(1:12,:)),fs);
rp_aft_1_O2=relpower(mean(pxx_O2_after(1:12,:)),fs);


% 2 kHz

rp_bef_2_F3=relpower(mean(pxx_F3_before(13:24,:)),fs);
rp_bef_2_F4=relpower(mean(pxx_F4_before(13:24,:)),fs);
rp_bef_2_C3=relpower(mean(pxx_C3_before(13:24,:)),fs);
rp_bef_2_Cz=relpower(mean(pxx_Cz_before(13:24,:)),fs);
rp_bef_2_C4=relpower(mean(pxx_C4_before(13:24,:)),fs);
rp_bef_2_P3=relpower(mean(pxx_P3_before(13:24,:)),fs);
rp_bef_2_P4=relpower(mean(pxx_P4_before(13:24,:)),fs);
rp_bef_2_O1=relpower(mean(pxx_O1_before(13:24,:)),fs);
rp_bef_2_O2=relpower(mean(pxx_O2_before(13:24,:)),fs);

rp_dur_2_F3=relpower(mean(pxx_F3_during(13:24,:)),fs);
rp_dur_2_F4=relpower(mean(pxx_F4_during(13:24,:)),fs);
rp_dur_2_C3=relpower(mean(pxx_C3_during(13:24,:)),fs);
rp_dur_2_Cz=relpower(mean(pxx_Cz_during(13:24,:)),fs);
rp_dur_2_C4=relpower(mean(pxx_C4_during(13:24,:)),fs);
rp_dur_2_P3=relpower(mean(pxx_P3_during(13:24,:)),fs);
rp_dur_2_P4=relpower(mean(pxx_P4_during(13:24,:)),fs);
rp_dur_2_O1=relpower(mean(pxx_O1_during(13:24,:)),fs);
rp_dur_2_O2=relpower(mean(pxx_O2_during(13:24,:)),fs);

rp_aft_2_F3=relpower(mean(pxx_F3_after(13:24,:)),fs);
rp_aft_2_F4=relpower(mean(pxx_F4_after(13:24,:)),fs);
rp_aft_2_C3=relpower(mean(pxx_C3_after(13:24,:)),fs);
rp_aft_2_Cz=relpower(mean(pxx_Cz_after(13:24,:)),fs);
rp_aft_2_C4=relpower(mean(pxx_C4_after(13:24,:)),fs);
rp_aft_2_P3=relpower(mean(pxx_P3_after(13:24,:)),fs);
rp_aft_2_P4=relpower(mean(pxx_P4_after(13:24,:)),fs);
rp_aft_2_O1=relpower(mean(pxx_O1_after(13:24,:)),fs);
rp_aft_2_O2=relpower(mean(pxx_O2_after(13:24,:)),fs);


% 3 kHz

rp_bef_3_F3=relpower(mean(pxx_F3_before(25:36,:)),fs);
rp_bef_3_F4=relpower(mean(pxx_F4_before(25:36,:)),fs);
rp_bef_3_C3=relpower(mean(pxx_C3_before(25:36,:)),fs);
rp_bef_3_Cz=relpower(mean(pxx_Cz_before(25:36,:)),fs);
rp_bef_3_C4=relpower(mean(pxx_C4_before(25:36,:)),fs);
rp_bef_3_P3=relpower(mean(pxx_P3_before(25:36,:)),fs);
rp_bef_3_P4=relpower(mean(pxx_P4_before(25:36,:)),fs);
rp_bef_3_O1=relpower(mean(pxx_O1_before(25:36,:)),fs);
rp_bef_3_O2=relpower(mean(pxx_O2_before(25:36,:)),fs);

rp_dur_3_F3=relpower(mean(pxx_F3_during(25:36,:)),fs);
rp_dur_3_F4=relpower(mean(pxx_F4_during(25:36,:)),fs);
rp_dur_3_C3=relpower(mean(pxx_C3_during(25:36,:)),fs);
rp_dur_3_Cz=relpower(mean(pxx_Cz_during(25:36,:)),fs);
rp_dur_3_C4=relpower(mean(pxx_C4_during(25:36,:)),fs);
rp_dur_3_P3=relpower(mean(pxx_P3_during(25:36,:)),fs);
rp_dur_3_P4=relpower(mean(pxx_P4_during(25:36,:)),fs);
rp_dur_3_O1=relpower(mean(pxx_O1_during(25:36,:)),fs);
rp_dur_3_O2=relpower(mean(pxx_O2_during(25:36,:)),fs);

rp_aft_3_F3=relpower(mean(pxx_F3_after(25:36,:)),fs);
rp_aft_3_F4=relpower(mean(pxx_F4_after(25:36,:)),fs);
rp_aft_3_C3=relpower(mean(pxx_C3_after(25:36,:)),fs);
rp_aft_3_Cz=relpower(mean(pxx_Cz_after(25:36,:)),fs);
rp_aft_3_C4=relpower(mean(pxx_C4_after(25:36,:)),fs);
rp_aft_3_P3=relpower(mean(pxx_P3_after(25:36,:)),fs);
rp_aft_3_P4=relpower(mean(pxx_P4_after(25:36,:)),fs);
rp_aft_3_O1=relpower(mean(pxx_O1_after(25:36,:)),fs);
rp_aft_3_O2=relpower(mean(pxx_O2_after(25:36,:)),fs);


%% MAKING TABLES

rowNames={'Delta','Theta','Alpha','Beta'};
varNames={'Before','During','After'};

RP_1kHz_F3=table(rp_bef_1_F3',rp_dur_1_F3',rp_aft_1_F3','VariableNames',varNames,'RowNames',rowNames)
RP_2kHz_F3=table(rp_bef_2_F3',rp_dur_2_F3',rp_aft_2_F3','VariableNames',varNames,'RowNames',rowNames)
RP_3kHz_F3=table(rp_bef_3_F3',rp_dur_3_F3',rp_aft_3_F3','VariableNames',varNames,'RowNames',rowNames)

RP_1kHz_F4=table(rp_bef_1_F4',rp_dur_1_F4',rp_aft_1_F4','VariableNames',varNames,'RowNames',rowNames)
RP_2kHz_F4=table(rp_bef_2_F4',rp_dur_2_F4',rp_aft_2_F4','VariableNames',varNames,'RowNames',rowNames)
RP_3kHz_F4=table(rp_bef_3_F4',rp_dur_3_F4',rp_aft_3_F4','VariableNames',varNames,'RowNames',rowNames)

RP_1kHz_C3=table(rp_bef_1_C3',rp_dur_1_C3',rp_aft_1_C3','VariableNames',varNames,'RowNames',rowNames)
RP_2kHz_C3=table(rp_bef_2_C3',rp_dur_2_C3',rp_aft_2_C3','VariableNames',varNames,'RowNames',rowNames)
RP_3kHz_C3=table(rp_bef_3_C3',rp_dur_3_C3',rp_aft_3_C3','VariableNames',varNames,'RowNames',rowNames)

RP_1kHz_Cz=table(rp_bef_1_Cz',rp_dur_1_Cz',rp_aft_1_Cz','VariableNames',varNames,'RowNames',rowNames)
RP_2kHz_Cz=table(rp_bef_2_Cz',rp_dur_2_Cz',rp_aft_2_Cz','VariableNames',varNames,'RowNames',rowNames)
RP_3kHz_Cz=table(rp_bef_3_Cz',rp_dur_3_Cz',rp_aft_3_Cz','VariableNames',varNames,'RowNames',rowNames)

RP_1kHz_C4=table(rp_bef_1_C4',rp_dur_1_C4',rp_aft_1_C4','VariableNames',varNames,'RowNames',rowNames)
RP_2kHz_C4=table(rp_bef_2_C4',rp_dur_2_C4',rp_aft_2_C4','VariableNames',varNames,'RowNames',rowNames)
RP_3kHz_C4=table(rp_bef_3_C4',rp_dur_3_C4',rp_aft_3_C4','VariableNames',varNames,'RowNames',rowNames)

RP_1kHz_P3=table(rp_bef_1_P3',rp_dur_1_P3',rp_aft_1_P3','VariableNames',varNames,'RowNames',rowNames)
RP_2kHz_P3=table(rp_bef_2_P3',rp_dur_2_P3',rp_aft_2_P3','VariableNames',varNames,'RowNames',rowNames)
RP_3kHz_P3=table(rp_bef_3_P3',rp_dur_3_P3',rp_aft_3_P3','VariableNames',varNames,'RowNames',rowNames)

RP_1kHz_P4=table(rp_bef_1_P4',rp_dur_1_P4',rp_aft_1_P4','VariableNames',varNames,'RowNames',rowNames)
RP_2kHz_P4=table(rp_bef_2_P4',rp_dur_2_P4',rp_aft_2_P4','VariableNames',varNames,'RowNames',rowNames)
RP_3kHz_P4=table(rp_bef_3_P4',rp_dur_3_P4',rp_aft_3_P4','VariableNames',varNames,'RowNames',rowNames)

RP_1kHz_O1=table(rp_bef_1_O1',rp_dur_1_O1',rp_aft_1_O1','VariableNames',varNames,'RowNames',rowNames)
RP_2kHz_O1=table(rp_bef_2_O1',rp_dur_2_O1',rp_aft_2_O1','VariableNames',varNames,'RowNames',rowNames)
RP_3kHz_O1=table(rp_bef_3_O1',rp_dur_3_O1',rp_aft_3_O1','VariableNames',varNames,'RowNames',rowNames)

RP_1kHz_O2=table(rp_bef_1_O2',rp_dur_1_O2',rp_aft_1_O2','VariableNames',varNames,'RowNames',rowNames)
RP_2kHz_O2=table(rp_bef_2_O2',rp_dur_2_O2',rp_aft_2_O2','VariableNames',varNames,'RowNames',rowNames)
RP_3kHz_O2=table(rp_bef_3_O2',rp_dur_3_O2',rp_aft_3_O2','VariableNames',varNames,'RowNames',rowNames)