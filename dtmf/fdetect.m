function[f1,f2]=fdetect(xout);
% scan for a frequency
fs=8000;
N1=2^15;
xabs=abs(xout);
fmatrix=[697 770 852 941 1209 1336 1477];
k=ceil((fmatrix/fs)*N1);
kdev_p=ceil((fmatrix/fs)*N1*1.015);
kdev_m=ceil((fmatrix/fs)*N1*0.985);
for i=1:length(k)
    s_ind(1,i)=kdev_m(i);
    s_ind(2,i)=kdev_p(i);
end
j=1;
for i=1:length(k)
    [peak(i),pindex(i)]=max(xabs(s_ind(2,i)));
    pindex(i)=s_ind(1,i)+pindex(i)-1;
end
[temppeak,tempind]=sort(peak);
for i=1:length(temppeak)
    if fmatrix(tempind(i))<1075
        lowpeak(j)=fmatrix(tempind(i));
    else
        highpeak(j)=fmatrix(tempind(i));
    end;
end
f1=lowpeak(length(lowpeak));
f2=highpeak(length(highpeak));