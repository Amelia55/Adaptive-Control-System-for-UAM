%输入各时段链路（i，j）方向的排队长度,输出（i，j）的绿灯时间矩阵
%固定周期相位背压策略进行信号灯配时
function [JUZHEN_GreenTime,JUZHEN_bili,JUZHEN_Phase_GreenTime,JZPhase_GreenST,JUZHEN_pressure,JUZHEN_weight]=get_LightControl(t,JUZHEN_Road_Queue,Roadcapacity,JUZHEN_Baohe_Speed,TP,Zong_tp,Phase_Road,ZhuanWanP,JUZHEN_GreenTime,Intersection_Phase,JUZHEN_Road_ZQueue,JUZHEN_pressure,JUZHEN_weight,JUZHEN_bili,JUZHEN_Phase_GreenTime,JZPhase_GreenST)
% Phase_Road=xlsread('C:\Users\Lenovo\Desktop\DATA\TrafficLight.xlsx','Phase_Road');
% -------------------------------------相位与链路的对应关系（控制关系）(i,j,p)三维
JUZHEN_Baohe_Speed(isnan(JUZHEN_Baohe_Speed))=0;
Intersection_Phase(isnan(Intersection_Phase))=0;
tp=ceil(t/TP);
Eta=40;%求绿时比例的参数，调整
% Eta=ones(1,size(JUZHEN_weight,2)).*50;%列数为相位数量

for ggi=1:size(Roadcapacity,1)
    for ggj=1:size(Roadcapacity,1)
        JUZHEN_pressure(ggi,ggj,tp+1)=JUZHEN_Road_Queue(ggi,ggj,tp+1)-ZhuanWanP(ggi,ggj).*(JUZHEN_Road_ZQueue(ggj,tp+1));%公式9,计算背压系数
    end
end
for gggi=1:size(Phase_Road,3)%循环所有相位
    JUZHEN_weight(tp+1,gggi)=sum(sum(Phase_Road(:,:,gggi).* JUZHEN_pressure(:,:,tp+1).*JUZHEN_Baohe_Speed));
%     Eta(1,gggi)=0.7185.*(mean( JUZHEN_weight(tp+1,gggi))^(-0.533));%求绿时比例的参数,每一相位取值都不相同
end
for li=2:size(Intersection_Phase,1)%循环所有交叉口
    [~,Nzero]=find(Intersection_Phase(li,:)~=0);
    Fenmu=0;
    for ni=1:length(Nzero)
        Fenmu=Fenmu+exp(Eta.*JUZHEN_weight(tp+1,Intersection_Phase(li,Nzero(ni))));
%         Fenmu=Fenmu+exp(Eta(Intersection_Phase(li,Nzero(ni))).*JUZHEN_weight(tp+1,Intersection_Phase(li,Nzero(ni))));
    end
    for nni=1:length(Nzero)
        JUZHEN_bili(tp+1,Intersection_Phase(li,Nzero(nni)))=exp(Eta.*JUZHEN_weight(tp+1,Intersection_Phase(li,Nzero(nni)))) / Fenmu;
%         JUZHEN_bili(tp+1,Intersection_Phase(li,Nzero(nni)))=exp(Eta(Intersection_Phase(li,Nzero(ni))).*JUZHEN_weight(tp+1,Intersection_Phase(li,Nzero(nni)))) / Fenmu;
        JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(li,Nzero(nni)))=TP.*JUZHEN_bili(tp+1,Intersection_Phase(li,Nzero(nni)));%得到各相位的绿色通行时间,时长
    end
end

for ggggi=1:size(Phase_Road,3)
    [IntRow,~]=find(Intersection_Phase==ggggi);%找到ggggi相位所在的交叉口行
    if sum(any(Intersection_Phase(IntRow,:),1))==2 %该行交叉口对应2个相位
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,1))=tp*TP;%该交叉口第一个相位的绿灯开始时间为 周期开始时间
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,2))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,1))+tp*TP;%该交叉口第二个相位的绿灯开始时间为前一相位绿灯结束时间
    elseif sum(any(Intersection_Phase(IntRow,:),1))==3
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,1))=tp*TP;%该交叉口第一个相位的绿灯开始时间为 周期开始时间
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,2))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,1))+tp*TP;
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,3))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,2))+JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,2));
    elseif sum(any(Intersection_Phase(IntRow,:),1))==4
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,1))=tp*TP;%该交叉口第一个相位的绿灯开始时间为 周期开始时间
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,2))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,1))+tp*TP;
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,3))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,2))+JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,2));
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,4))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,2))+JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,3));
    else
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,1))=tp*TP;%该交叉口只有一个相位，绿灯开始时间为 周期开始时间
    end
    %     YuZhi=JUZHEN_RemainingCapacity(:,tp+1)./JUZHEN_Baohe_Speed;%还没写完
    
    if tp<Zong_tp
    [Road_Row,Road_Column]=find(Phase_Road(:,:,ggggi)~=0);
        for oi=1:length(Road_Row)
            for oj=1:length(Road_Column)
                JUZHEN_GreenTime(Road_Row(oi),Road_Column(oj),tp+1)= JUZHEN_Phase_GreenTime(tp+1,ggggi).*Phase_Road(Road_Row(oi),Road_Column(oj),ggggi);%得到链路（i,j）的绿灯控制时间,ggggi表示相位
            end
        end
    end
    
    
    
end


end









