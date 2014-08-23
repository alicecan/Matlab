function y=tone(fd);
% this function is used to generate a single
% tone at the desired frequency, fd, with
% specified 'duration'
% t=cos(2*pi*fd*n/fs);

% Y(z)=H(z)*X(z) where X(z)=1
% H(z)=(1-cos(omega)z^-1)/(1-2cos(omega)z^-1+z^-2)
fs=8000;
duration=0.25;
Ts=1/fs;
Na=0.25/Ts;
n=Na-1;
omega=2*pi*fd/fs;
b=[1-cos(omega)]; a=[1-2*cos(omega) 1];
x=[1 zeros(1,n)];
y=filter(b,a,x);

