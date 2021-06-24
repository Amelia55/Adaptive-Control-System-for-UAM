%�����ʱ����·��i��j��������Ŷӳ���,�����i��j�����̵�ʱ�����
%�̶�������λ��ѹ���Խ����źŵ���ʱ
function [JUZHEN_GreenTime,JUZHEN_bili,JUZHEN_Phase_GreenTime,JZPhase_GreenST,JUZHEN_pressure,JUZHEN_weight]=get_LightControl(t,JUZHEN_Road_Queue,Roadcapacity,JUZHEN_Baohe_Speed,TP,Zong_tp,Phase_Road,ZhuanWanP,JUZHEN_GreenTime,Intersection_Phase,JUZHEN_Road_ZQueue,JUZHEN_pressure,JUZHEN_weight,JUZHEN_bili,JUZHEN_Phase_GreenTime,JZPhase_GreenST)
% Phase_Road=xlsread('C:\Users\Lenovo\Desktop\DATA\TrafficLight.xlsx','Phase_Road');
% -------------------------------------��λ����·�Ķ�Ӧ��ϵ�����ƹ�ϵ��(i,j,p)��ά
JUZHEN_Baohe_Speed(isnan(JUZHEN_Baohe_Speed))=0;
Intersection_Phase(isnan(Intersection_Phase))=0;
tp=ceil(t/TP);
Eta=40;%����ʱ�����Ĳ���������
% Eta=ones(1,size(JUZHEN_weight,2)).*50;%����Ϊ��λ����

for ggi=1:size(Roadcapacity,1)
    for ggj=1:size(Roadcapacity,1)
        JUZHEN_pressure(ggi,ggj,tp+1)=JUZHEN_Road_Queue(ggi,ggj,tp+1)-ZhuanWanP(ggi,ggj).*(JUZHEN_Road_ZQueue(ggj,tp+1));%��ʽ9,���㱳ѹϵ��
    end
end
for gggi=1:size(Phase_Road,3)%ѭ��������λ
    JUZHEN_weight(tp+1,gggi)=sum(sum(Phase_Road(:,:,gggi).* JUZHEN_pressure(:,:,tp+1).*JUZHEN_Baohe_Speed));
%     Eta(1,gggi)=0.7185.*(mean( JUZHEN_weight(tp+1,gggi))^(-0.533));%����ʱ�����Ĳ���,ÿһ��λȡֵ������ͬ
end
for li=2:size(Intersection_Phase,1)%ѭ�����н����
    [~,Nzero]=find(Intersection_Phase(li,:)~=0);
    Fenmu=0;
    for ni=1:length(Nzero)
        Fenmu=Fenmu+exp(Eta.*JUZHEN_weight(tp+1,Intersection_Phase(li,Nzero(ni))));
%         Fenmu=Fenmu+exp(Eta(Intersection_Phase(li,Nzero(ni))).*JUZHEN_weight(tp+1,Intersection_Phase(li,Nzero(ni))));
    end
    for nni=1:length(Nzero)
        JUZHEN_bili(tp+1,Intersection_Phase(li,Nzero(nni)))=exp(Eta.*JUZHEN_weight(tp+1,Intersection_Phase(li,Nzero(nni)))) / Fenmu;
%         JUZHEN_bili(tp+1,Intersection_Phase(li,Nzero(nni)))=exp(Eta(Intersection_Phase(li,Nzero(ni))).*JUZHEN_weight(tp+1,Intersection_Phase(li,Nzero(nni)))) / Fenmu;
        JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(li,Nzero(nni)))=TP.*JUZHEN_bili(tp+1,Intersection_Phase(li,Nzero(nni)));%�õ�����λ����ɫͨ��ʱ��,ʱ��
    end
end

for ggggi=1:size(Phase_Road,3)
    [IntRow,~]=find(Intersection_Phase==ggggi);%�ҵ�ggggi��λ���ڵĽ������
    if sum(any(Intersection_Phase(IntRow,:),1))==2 %���н���ڶ�Ӧ2����λ
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,1))=tp*TP;%�ý���ڵ�һ����λ���̵ƿ�ʼʱ��Ϊ ���ڿ�ʼʱ��
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,2))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,1))+tp*TP;%�ý���ڵڶ�����λ���̵ƿ�ʼʱ��Ϊǰһ��λ�̵ƽ���ʱ��
    elseif sum(any(Intersection_Phase(IntRow,:),1))==3
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,1))=tp*TP;%�ý���ڵ�һ����λ���̵ƿ�ʼʱ��Ϊ ���ڿ�ʼʱ��
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,2))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,1))+tp*TP;
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,3))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,2))+JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,2));
    elseif sum(any(Intersection_Phase(IntRow,:),1))==4
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,1))=tp*TP;%�ý���ڵ�һ����λ���̵ƿ�ʼʱ��Ϊ ���ڿ�ʼʱ��
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,2))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,1))+tp*TP;
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,3))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,2))+JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,2));
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,4))=JUZHEN_Phase_GreenTime(tp+1,Intersection_Phase(IntRow,2))+JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,3));
    else
        JZPhase_GreenST(tp+1,Intersection_Phase(IntRow,1))=tp*TP;%�ý����ֻ��һ����λ���̵ƿ�ʼʱ��Ϊ ���ڿ�ʼʱ��
    end
    %     YuZhi=JUZHEN_RemainingCapacity(:,tp+1)./JUZHEN_Baohe_Speed;%��ûд��
    
    if tp<Zong_tp
    [Road_Row,Road_Column]=find(Phase_Road(:,:,ggggi)~=0);
        for oi=1:length(Road_Row)
            for oj=1:length(Road_Column)
                JUZHEN_GreenTime(Road_Row(oi),Road_Column(oj),tp+1)= JUZHEN_Phase_GreenTime(tp+1,ggggi).*Phase_Road(Road_Row(oi),Road_Column(oj),ggggi);%�õ���·��i,j�����̵ƿ���ʱ��,ggggi��ʾ��λ
            end
        end
    end
    
    
    
end


end









