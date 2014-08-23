% *********************************
% main program
% *********************************
dtmf_key = ['1', '2', '3';          % define DTMF tones
            '4', '5', '6';
            '7', '8', '9';
            '*', '0', '#'];
lower_freq=[697;770;852;941];       % 4x1 matrix
upper_freq=[1209,1336,1477];        % 1x3 matrix
dtmf_col=lower_freq*ones(1,4);      % the resulting matrix is 4x4 with each col as (697 770 852 941)
dtmf_row=ones(4,1)*upper_freq;     % the resulting matrix is 4x2 with each row as (1209 1336 1477)
fs=8000; Ts=1/fs;                   % sampling frequency

%=======================================
% encoder (use tone.m)           
%=======================================
% TONE GENERATION
% prompt for phone number from the user and check if it's 10-digit long
in_key=input('please ener the phone number(xxx-xxx-xxxx): ', 's');
while (size(in_key)~=10)
    in_key=input('The phone number must contain 10 digits, please re-enter: ', 's');
end
% get the dtmf tones and generate frequencies by summing two tones
for len=1:length(in_key)
    [i,j]=find(dtmf_key==in_key(len));
    x(len,:)=tone(dtmf_row(i,j))+tone(dtmf_col(i,j));
end

% number of points used for FFT, higher the N, higher the frequency
% resolution. Since the data points are 2000(i.e.2^11 if put into closest
% index with radix 2), in order to have sufficient points to get a
% better spectrum, we take N=32768 i.e. 2^15
% INPUT SPECTRA FOR ALL 10 DIGITS 
N1=2^15;
F1=[-N1/2:N1/2-1]/N1;
for i=1:length(in_key)
    tempx=x(i,:);
    X1(i,:)=abs(fft(tempx,N1));
    Xshift(i,:)=fftshift(X1(i,:));
    subplot(5,2,i);
    plot(F1,Xshift(i,:));
    ylabel(['digit',in_key(i)]);
    axis([-0.5 0.5 0 1500])
    if (i==9)|(i==10)
        xlabel('X(\Omega)(frequency/f_s)');
    end;
end

% GUARD BAND/PAUSE PERIOD of 0.1s
Tzp=0.1; Nz=Tzp/Ts;
% zero padding for the pause time
for k=1:length(in_key)
    xz(k,:)=[x(k,:) zeros(1,Nz)];
end

%=======================================
% gaussian noise channel: y[n]=x[n]+w[n];
%=======================================
% prompt for signal-to-noise ratio
snr=input('what SNR(in dB) do you want? ');
ratio=10^(snr/10);
% total length of the input sequence=10*2800
totalN=length(in_key)*length(xz);
sum=0;
for i=1:10
    for j=1:length(xz)
        sum=sum+(abs(xz(i,j)))^2;
    end;
end
% average energy over the samples and calcalate
% the noise variance
x_power=sum/totalN;
w_alpha=sqrt(x_power/ratio);
noise=w_alpha*randn(length(in_key), length(xz));
y=xz+noise;

% OUTPUT SPECTRA FOR ALL 10 DIGITS(OPTIONAL)
N2=2^15;
F2=[-N2/2:N2/2-1]/N2;
for i=1:length(in_key)
    tempy(i,:)=y(i,1:2000);
    Y(i,:)=abs(fft(tempy(i,:),N2));
    Yshift(i,:)=fftshift(Y(i,:));
    subplot(5,2,i);
    plot(F2,Yshift(i,:));
    ylabel(['digit', in_key(i)]);
    axis([-0.5 0.5 0 1500])
    if (i==9)|(i==10)
        xlabel('Y(\Omega)(frequency/f_s)');
    end;
end

%
% decoder(use fdetect.m)
% scan for a frequency
for i=1:length(in_key)
    [f1,f2]=fdetect(Y(i,:));
    switch f1
        case 697
            row=1;
        case 770
            row=2;
        case 852
            row=3;
        case 941
            row=4;
    end;
    switch f2
        case 1209
            col=1;
        case 1336
            col=2;
        case 1477
            col=3;
    end;
    digit(i)=dtmf_key(row,col);
end
disp(['The phone number is ',digit(1),digit(2),digit(3),'',...
    digit(4),digit(5),digit(6),'',...
    digit(7),digit(8),digit(9),digit(10)]);
clf;
subplot(2,1,1);
plot(F1,Xshift(10,:));
axis([-0.5 0.5 0 1200]);
set(gca,'Fontsize',10);
g=text(0.3,1100,'AtEncoder');
set(g,'Fontsize',13);
h=text(-0.4,700,['Digit''',in_key(10),'''']);
set(h, 'Fontsize',13);
xlabel('X(\Omega)(normalized frequency/f_s)');
subplot(2,1,2);
plot(F2,Yshift(10,:));
axis([-0.5 0.5 0 1200]);
g=text(0.3,1100,'At Decoder');
set(g,'Fontsize',13);
set(gca,'Fontsize',10);
xlabel('Y(\Omega)(normalized frequency/f_s)');
