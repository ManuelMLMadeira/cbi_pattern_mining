%% ICA

%% beeps

%load('EEG_beeps.mat');

[sourcesICA,A,W]=fastica(EEG_beeps(1:11,:));
nsourcesICA=zscore(sourcesICA')';

figure;
for i = 1:size(sourcesICA,1)
    subplot(size(sourcesICA,1),1,i);
    plot(nsourcesICA(i,:));
    axis tight;
    title(['Estimated source #', num2str(i)]);
end

%source corresponding to Fp1
for i=1:size(sourcesICA)
    correlationFp1(1,i)=abs(corr(nsourcesICA(i,:)',EEG_beeps(1,:)'));
end
[maxFp1,indexFp1]=max(correlationFp1);

%source corresponding to Fp2
for i=1:size(sourcesICA)
    correlationFp2(1,i)=abs(corr(nsourcesICA(i,:)',EEG_beeps(2,:)'));
end
[maxFp2,indexFp2]=max(correlationFp2);

if indexFp2==indexFp1
    correlationFp2(indexFp1)=0;
end

[maxFp2_2,indexFp2]=max(correlationFp2);
%% reconstruct 
newMix=A; %mixing matrix
newMix(:,indexFp1)=0;
newMix(:,indexFp2)=0;

recEEG_beeps=newMix*nsourcesICA;

%% matching channels

match=recEEG_beeps; %para poder alterar os dados

%F3
for i=1:size(match)
    correlationF3(1,i)=abs(corr(match(i,:)',EEG_beeps(3,:)'));
end
[maxF3,indexF3]=max(correlationF3);
match(indexF3,:)=0;

%F4
for i=1:size(match)
    correlationF4(1,i)=abs(corr(match(i,:)',EEG_beeps(4,:)'));
end
[maxF4,indexF4]=max(correlationF4);
match(indexF4,:)=0;

%C3
for i=1:size(match)
    correlationC3(1,i)=abs(corr(match(i,:)',EEG_beeps(5,:)'));
end
[maxC3,indexC3]=max(correlationC3);
match(indexC3,:)=0;

%Cz
for i=1:size(match)
    correlationCz(1,i)=abs(corr(match(i,:)',EEG_beeps(6,:)'));
end
[maxC3,indexCz]=max(correlationCz);
match(indexCz,:)=0;

%C4
for i=1:size(match)
    correlationC4(1,i)=abs(corr(match(i,:)',EEG_beeps(7,:)'));
end
[maxC4,indexC4]=max(correlationC4);
match(indexC4,:)=0;

%P3
for i=1:size(match)
    correlationP3(1,i)=abs(corr(match(i,:)',EEG_beeps(8,:)'));
end
[maxP3,indexP3]=max(correlationP3);
match(indexP3,:)=0;

%P4
for i=1:size(match)
    correlationP4(1,i)=abs(corr(match(i,:)',EEG_beeps(9,:)'));
end
[maxP4,indexP4]=max(correlationP4);
match(indexP4,:)=0;

%O1
for i=1:size(match)
    correlationO1(1,i)=abs(corr(match(i,:)',EEG_beeps(10,:)'));
end
[maxO1,indexO1]=max(correlationO1);
match(indexO1,:)=0;

%O2
for i=1:size(match)
    correlationO2(1,i)=abs(corr(match(i,:)',EEG_beeps(11,:)'));
end
[maxO2,indexO2]=max(correlationO2);
match(indexO2,:)=0;

%% plotting relevant reconstructed channels

figure;

subplot 331;

plot(EEG_beeps_before(3,:),'y');
hold on;
plot(recEEG_beeps(indexF3,:));
title('F3');
axis tight;

subplot 332;
plot(EEG_beeps_before(4,:),'y');
hold on;
plot(recEEG_beeps(indexF4,:));
title('F4');
axis tight;

subplot 333;
plot(EEG_beeps_before(5,:),'y');
hold on;
plot(recEEG_beeps(indexC3,:));

title('C3');
axis tight;

subplot 334;
plot(EEG_beeps_before(6,:),'y');
hold on;
plot(recEEG_beeps(indexCz,:));

title('Cz');
axis tight;

subplot 335;
plot(EEG_beeps_before(7,:),'y');
hold on;
plot(recEEG_beeps(indexC4,:));

title('C4');
axis tight;

subplot 336;
plot(EEG_beeps_before(8,:),'y');
hold on;
plot(recEEG_beeps(indexP3,:));

title('P3');
axis tight;

subplot 337;
plot(EEG_beeps_before(9,:),'y');
hold on;
plot(recEEG_beeps(indexP4,:));

title('P4');
axis tight;

subplot 338;
plot(EEG_beeps_before(10,:),'y');
hold on;
plot(recEEG_beeps(indexO1,:));

title('O1');
axis tight;

subplot 339;
plot(EEG_beeps_before(11,:),'y');
hold on;
plot(recEEG_beeps(indexO2,:));

title('O2');
axis tight;

suptitle('Reconstructed channels after ICA to remove eye movement artifacts');

%% sounds

load EEG_sounds;
[sourcesICA,A,W]=fastica(EEG_sounds(1:11,:));
nsourcesICA=zscore(sourcesICA')';

figure;
for i = 1:size(sourcesICA,1)
    subplot(size(sourcesICA,1),1,i);
    plot(nsourcesICA(i,:));
    axis tight;
    title(['Estimated source #', num2str(i)]);
end

%source corresponding to Fp1
for i=1:size(sourcesICA)
    correlationFp1(1,i)=abs(corr(nsourcesICA(i,:)',EEG_sounds(1,:)'));
end
[maxFp1,indexFp1]=max(correlationFp1);

%source corresponding to Fp2
for i=1:size(sourcesICA)
    correlationFp2(1,i)=abs(corr(nsourcesICA(i,:)',EEG_sounds(2,:)'));
end
[maxFp2,indexFp2]=max(correlationFp2);

if indexFp2==indexFp1
    correlationFp2(indexFp1)=0;
end

[maxFp2_2,indexFp2]=max(correlationFp2);
%% reconstruct 
newMix=A; %mixing matrix
newMix(:,indexFp1)=0;
newMix(:,indexFp2)=0;

recEEG_sounds=newMix*nsourcesICA;

%% matching channels

match=recEEG_sounds; %para poder alterar os dados

%F3
for i=1:size(match)
    correlationF3(1,i)=abs(corr(match(i,:)',EEG_sounds(3,:)'));
end
[maxF3,indexF3]=max(correlationF3);
match(indexF3,:)=0;

%F4
for i=1:size(match)
    correlationF4(1,i)=abs(corr(match(i,:)',EEG_sounds(4,:)'));
end
[maxF4,indexF4]=max(correlationF4);
match(indexF4,:)=0;

%C3
for i=1:size(match)
    correlationC3(1,i)=abs(corr(match(i,:)',EEG_sounds(5,:)'));
end
[maxC3,indexC3]=max(correlationC3);
match(indexC3,:)=0;

%Cz
for i=1:size(match)
    correlationCz(1,i)=abs(corr(match(i,:)',EEG_sounds(6,:)'));
end
[maxC3,indexCz]=max(correlationCz);
match(indexCz,:)=0;

%C4
for i=1:size(match)
    correlationC4(1,i)=abs(corr(match(i,:)',EEG_sounds(7,:)'));
end
[maxC4,indexC4]=max(correlationC4);
match(indexC4,:)=0;

%P3
for i=1:size(match)
    correlationP3(1,i)=abs(corr(match(i,:)',EEG_sounds(8,:)'));
end
[maxP3,indexP3]=max(correlationP3);
match(indexP3,:)=0;

%P4
for i=1:size(match)
    correlationP4(1,i)=abs(corr(match(i,:)',EEG_sounds(9,:)'));
end
[maxP4,indexP4]=max(correlationP4);
match(indexP4,:)=0;

%O1
for i=1:size(match)
    correlationO1(1,i)=abs(corr(match(i,:)',EEG_sounds(10,:)'));
end
[maxO1,indexO1]=max(correlationO1);
match(indexO1,:)=0;

%O2
for i=1:size(match)
    correlationO2(1,i)=abs(corr(match(i,:)',EEG_sounds(11,:)'));
end
[maxO2,indexO2]=max(correlationO2);
match(indexO2,:)=0;

%% plotting relevant reconstructed channels

figure;

subplot 331;
plot(recEEG_sounds(indexF3,:));
title('F3');
axis tight;

subplot 332;
plot(recEEG_sounds(indexF4,:));
title('F4');
axis tight;

subplot 333;
plot(recEEG_sounds(indexC3,:));
title('C3');
axis tight;

subplot 334;
plot(recEEG_sounds(indexCz,:));
title('Cz');
axis tight;

subplot 335;
plot(recEEG_sounds(indexC4,:));
title('C4');
axis tight;

subplot 336;
plot(recEEG_sounds(indexP3,:));
title('P3');
axis tight;

subplot 337;
plot(recEEG_sounds(indexP4,:));
title('P4');
axis tight;

subplot 338;
plot(recEEG_sounds(indexO1,:));
title('O1');
axis tight;

subplot 339;
plot(recEEG_sounds(indexO2,:));
title('O2');
axis tight;

suptitle('Reconstructed channels after ICA to remove eye movement artifacts');

save('recBeeps.mat','recEEG_beeps');
save('recSounds.mat','recEEG_sounds');

