function relpower = relpower(psd,fs)
% receives PSD vector and sampling frequency and returns relative power of
% EEG bands
step=(fs/2)/length(psd);
TotPow=trapz(psd);

delta=psd(round(1*step)+1:round(4*step)+1);
theta=psd(round(4*step)+1:round(7*step)+1);
alpha=psd(round(7*step)+1:round(12*step)+1);
beta=psd(round(12*step)+1:round(20*step)+1);
    
RelPowerDelta=trapz(delta)/TotPow;
RelPowerTheta=trapz(theta)/TotPow;
RelPowerAlpha=trapz(alpha)/TotPow;
RelPowerBeta=trapz(beta)/TotPow;

relpower=[RelPowerDelta RelPowerTheta RelPowerAlpha RelPowerBeta];
end