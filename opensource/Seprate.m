function  [gnssMeas_BKS, gnssMeas_NBKS]=Seprate(gnssRaw, gnssMeas,prFileName)
figure;
[colors] = PlotPseudoranges(gnssMeas,prFileName);
figure;
PlotCno(gnssMeas,prFileName,colors);


% % pick out the strongest sat signal as stander
% % every sat strongest(max) -> strongest's strongest
% [strongestSig,SigIndex]=max(gnssMeas.Cn0DbHz);
% [MaxCn0DbHz,Index]=max(strongestSig);
% StongestSvid=gnssMeas.Svid(Index);

% 


% Index = 8;


gnssCno = gnssMeas.Cn0DbHz;

% set the nan as 0
for i=1:numel(gnssCno)
    if isnan(gnssCno(i)) 
       gnssCno(i)=0; 
    end
    
end

average = var(gnssCno);
variance = std(gnssCno);
[MaxCn0Pick,Index]=min(variance);
SuitabelSvid=gnssMeas.Svid(Index);

gnssCnoMax=gnssCno(:,Index);

% plot for scale view
figure;
plot(gnssCnoMax);

% window length 4
% split data into two parts
LenGnss = length(gnssCnoMax);
% pickUp -> backscattered sat signal  BKS
% pickDn -> original sat signal       NBKS
pickUp = zeros(1, LenGnss);
pickDn = zeros(1, LenGnss);
midThre = 0;
cntPick = ones(1,2);
for i=1:LenGnss
    if i+3 <= LenGnss
        if mod(i,4) == 1
           dataBuf = gnssCnoMax(i:i+3); 
           midThre = median(dataBuf); 
        end
    end
    
    if gnssCnoMax(i) >= midThre - 1
        pickUp(i) = 1;
%         cntPick(1) = cntPick(1) + 1;
    else
        pickDn(i) = 1;
%         cntPick(2) = cntPick(2) + 1;
    end
    
end

% gnssMeasSep.Bks = pickUp .* gnssCnoMax';
% gnssMeasSep.Org = pickDn .* gnssCnoMax';
% figure
% plot(gnssCnoMax);
% hold on
% plot(gnssMeasSep.Bks);
% plot(gnssMeasSep.Org);
% hold off

% Seperate BKS and NBKS from
iBKS = pickUp==1;
iORG = pickDn==1;
cellGnssMeas = struct2cell(gnssMeas);
fieldMeas = fieldnames(gnssMeas);
NumCell = length(cellGnssMeas);
cellGnssMeas_BKS = cellGnssMeas;
cellGnssMeas_NBKS = cellGnssMeas;
for i=1:NumCell
    if length(cellGnssMeas{i,1}(:,1)) > 1
       cellGnssMeas_BKS{i,1} = cellGnssMeas{i,1}(iBKS,:) ;
       cellGnssMeas_NBKS{i,1} = cellGnssMeas{i,1}(iORG,:) ;
    end
end
gnssMeas_BKS = cell2struct(cellGnssMeas_BKS, fieldMeas, 1);
gnssMeas_NBKS = cell2struct(cellGnssMeas_NBKS, fieldMeas, 1);

save( 'gnssMean.mat','gnssMeas', 'gnssMeas_BKS', 'gnssMeas_NBKS');

figure;
plot(gnssMeas_BKS.Cn0DbHz(:,1));



% chose data for later processing
% LocsCnoIndex= find(pickUp==1);
% LocsCnoIndex= find(pickDn==1);
% gnssMeasBackscattered=gnssMeas(LocsCnoIndex);
%
% gnssMeasBackscattered.Svid=gnssMeas.Svid;
% gnssMeasBackscattered.AzDeg=gnssMeas.AzDeg;
% gnssMeasBackscattered.ElDeg=gnssMeas.ElDeg;
% gnssMeasBackscattered.FctSeconds=gnssMeas.FctSeconds(LocsCnoIndex,:);
% gnssMeasBackscattered.ClkDCount=gnssMeas.ClkDCount(LocsCnoIndex,:);
% gnssMeasBackscattered.HwDscDelS=gnssMeas.HwDscDelS(LocsCnoIndex,:);
% gnssMeasBackscattered.tRxSeconds=gnssMeas.tRxSeconds(LocsCnoIndex,:);
% gnssMeasBackscattered.tTxSeconds=gnssMeas.tTxSeconds(LocsCnoIndex,:);
% gnssMeasBackscattered.PrM=gnssMeas.PrM(LocsCnoIndex,:);
% gnssMeasBackscattered.PrSigmaM=gnssMeas.PrSigmaM(LocsCnoIndex,:);
% gnssMeasBackscattered.DelPrM=gnssMeas.DelPrM(LocsCnoIndex,:);
% gnssMeasBackscattered.PrrMps=gnssMeas.PrrMps(LocsCnoIndex,:);
% gnssMeasBackscattered.PrrSigmaMps=gnssMeas.PrrSigmaMps(LocsCnoIndex,:);
% gnssMeasBackscattered.AdrM=gnssMeas.AdrM(LocsCnoIndex,:);
% gnssMeasBackscattered.AdrSigmaM=gnssMeas.AdrSigmaM(LocsCnoIndex,:);
% gnssMeasBackscattered.AdrState=gnssMeas.AdrState(LocsCnoIndex,:);
% gnssMeasBackscattered.Cn0DbHz=gnssMeas.Cn0DbHz(LocsCnoIndex,:);
% gnssBksCnoMax=gnssMeasBackscattered.Cn0DbHz(:,Index);
% figure;
% plot(gnssBksCnoMax);

end