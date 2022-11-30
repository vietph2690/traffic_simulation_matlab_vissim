clear all;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[m,n] = getMN();
[nRoads, nJunctions, typeJunction, phase_1, phase_2, phase_3, phase_4, roadFromTo, iRdsJunction, oRdsJunction, tleft, tright, tstraight, ratiosMatrix] = getInfoTrafficNetwork();
nS = load('nS.csv');
qS = load('qS.csv');
nolanes = load('dataLinks.csv');
trafficData(1,1) = {nS};
trafficData(1,2) = {qS};
R = (1/3)*ones(nRoads, 3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n0 = 0.2*ones(nRoads,1);% + 0.3*rand(nRoads,1);
for i = 1:nRoads
    n0(i,1) = n0(i,1)*nS(i,1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inflowDisturbance = 30;
inFlowLinks = inflowDisturbance*ones(nRoads, 10);
inFlow0 = 1200*ones(nRoads, 10);
for i = 1:nRoads
    nShift = mod(i,10);
    if ((roadFromTo(i,1) == 0) && (nolanes(i,1) > 2))
        inFlowLinks(i,:) = inFlow0(nShift+1:nShift+10);
%         if ((i > 12) && (i < 105))
%             inFlowLinks(i,:) = inFlow0(nShift+1:nShift+10);
%         end
    end
end
% turnR = ratiosMatrix;
% for i = 1:nRoads
%     ifFlowTemp(i,1) = inFlowLinks(i,1)*80/3600;
% end
% fTemp = (eye(nRoads) - turnR')\ifFlowTemp;
% for i = 1:nJunctions
%     for j = 1:4
%         zRoadIdx = iRdsJunction(i,j);
%         if iRdsJunction(i,j) > 0
%             lTimeControl(i,j) = fTemp(iRdsJunction(i,j),1)/qS(iRdsJunction(i,j),1);
%         end
%     end
% end
% checkTime = lTimeControl*ones(4,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
K = 2;
cycleT = 60;
maxGreenOut = cycleT/3;
tempMax = round(maxGreenOut + 1,0);
difInOutFlows = zeros(nRoads,1);
percentOfUncertainty = 0.25;
for i = 1:nRoads
    if roadFromTo(i,1) == 0
        difInOutFlows(i,1) = 1200/3600*cycleT*nolanes(i,1)/4;%*(1 + 0.1*rand(1,1));
    else
        difInOutFlows(i,1) = 30/3600*cycleT;
    end
end
% difInOutFlows(59,1) = 1000/3600*cycleT;
% difInOutFlows(87,1) = 1000/3600*cycleT;
% difInOutFlows(105,1) = 1000/3600*cycleT;
trafficData(1,4) = {difInOutFlows};
upOutFlow = zeros(nRoads,1);
for i = 1:nRoads
    if roadFromTo(i,2) == 0
        upOutFlow(i,1) = cycleT;
    end
end
trafficData(1,3) = {ones(nRoads,1)*cycleT/3};
[stTurnRatios, stCoeffFlows, realTurnRatios, realCoeffFlows] = getStochastiData(6);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lTimeControl, lSequenceControl] = computeNominalMPCSignalControl(K, cycleT, trafficData, stTurnRatios{1,1}, n0);
% [lTimeControl, lSequenceControl] = computeStochasticMPCSignalControl(K, cycleT, trafficData, stTurnRatios, stCoeffFlows, n0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
checkTime = lTimeControl*ones(size(lTimeControl,2),1);
abc = 1;
abc = abc + 1;