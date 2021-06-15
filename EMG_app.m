%load data
load EMGRT.mat
N = length(rts);
%Getting sample trials
%One is selected to be relatively clean while the other is not
trials2plot = [4 29];
%plotting the figure
figure(1),clf
%Plot of Movement times
plot(rts,'s-','markerfacecolor','w');
xlabel('Trials'),ylabel('Movement time(ms)');
set(gca,'xlim',[0 N+1])
%Histogram of RTs
figure(2),clf
histogram(rts,40)
xlabel('Count'),ylabel('Movement Time(ms)')
figure(3),clf
for i = 1:2
    subplot(2,1,i),hold on
    plot(timevec,emg(trials2plot(i),:),'r','linew',1)
    plot([1 1]*rts(trials2plot(i)),get(gca,'ylim'),'k--','linew',1)
    xlabel('Time(ms)')
    legend({'EMG';'Button Press'})
end
%detect EMG onsets
%define baseline time window for normalization
baseidx = dsearchn(timevec',[-500 0]');
%pick the z-threshold
zthresh = 100;
%intialization of outputs
emgonsets = zeros(N,1);
%initiate filtered signal
emgSelected = emg(29,:);
emgf = emgSelected;
%the loop implementation
for i = 2:length(emgSelected)-1
    emgf(i) = emgSelected(i)^2 - (emgSelected(i-1)*emgSelected(i+1));
end

%Normalization because the filtered signal is not in the same scale as the
%original.For that we use the prezero section
emgZ = (emgSelected-mean(emgSelected(baseidx(1):baseidx(2))))/std(emgSelected(baseidx(1):baseidx(2)));
emgZf = (emgf-mean(emgf(baseidx(1):baseidx(2))))/std(emgf(baseidx(1):baseidx(2)));
%plotting the zscored
figure(4),clf,hold on
plot(timevec,emgSelected,'b','linew',2);
plot(timevec,emgZf,'m','linew',2);
xlabel('Time(ms)'),ylabel('Z score relative to prestimulus')
legend({'EMG'; 'EMG TKEO'});

for triali = 1:N
    %convert to energy via TKEO
    tkeo = emg(triali,2:end-1).^2-(emg(triali,1:end-2).*emg(triali,3:end));
    tkeo = (tkeo-mean(tkeo(baseidx(1):baseidx(2))))./std(tkeo(baseidx(1):baseidx(2)));
    tkeoThresh = tkeo > zthresh;
    tkeoThresh(timevec<0) = 0;
    tkeoPnts = find(tkeoThresh);
    emgonsets(triali) = timevec(tkeoPnts(1)+1);
end
figure(5), clf
plot(rts,emgonsets,'bo','markerfacecolor','b','markersize',5)
xlabel('Button press time')
ylabel('EMG onset time')
axis square
%Get the correlation results
[R,P,RL,RU] = corrcoef(emgonsets,rts);
%Getting the stat parameters
minOnSet = min(emgonsets);
maxOnSet = max(emgonsets);
meanOnset = mean(emgonsets);
medianOnset = median(emgonsets);
stdOnset = std(emgonsets);
varOnset = stdOnset^2;
minMT = min(rts);
maxMT = max(rts);
meanMT = mean(rts);
medianMT = median(rts);
stdMT = std(rts);
varMT = stdMT^2;

