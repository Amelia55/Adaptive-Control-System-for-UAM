%�ն����ڵĺ������  ʵʱ������
clear all;close all;clc
%% ��������
TP=120;%ÿ����ڵ����ڳ���
t=1;%ʱ����ʱ�䣬���²���Ϊ1s  ���߸���
TimeGap=1;%ʱ������ʱ�䲽��
tmax=60000;%Ԥ��Ϊ60000s��Ӧ��ֱ�����к�����볡����
Zong_tp=tmax/TP;
Xuhang=1;%����ʱ��
n=20;safetyJG=60;
JT=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic networkԭ.xlsx','JT');%�ն�����ͨ·�������ĳ�ʼֵ
JT_Z=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic networkԭ.xlsx','JT_Z');%�ն�����ͨ·�������ĳ�ʼֵ
JT_YJ=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic networkԭ.xlsx','JT_YJ');

Flight=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network100.xlsx','Flight');%������Ϣ
Intersection_Luhao=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic networkԭ.xlsx','Intersection_Luhao');%�������·�ŵĶ�Ӧ��ϵ,���ݽ���ں��ҵ�·�ţ����ݱ�Ϊ�����
JUZHEN_Baohe_Speed=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic networkԭ.xlsx','Baohe_Speed');%��λ����/s
Roadcapacity = xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic networkԭ.xlsx','Roadcapacity');%����·������
Intersection_Phase=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Intersection_Phase.xlsx');%���뽻�������λ�Ķ�Ӧ��ϵ
Sheet_YXJ1=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Youxianji.xlsx','R=1');%����10%-40%
Sheet_YXJ2=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Youxianji.xlsx','R=2');%����40%-70%
Sheet_YXJ3=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Youxianji.xlsx','R=3');%����70%-100%
CTK=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic networkԭ.xlsx','��ͻ��');%��ͻ����ڵ�Ķ�Ӧ��ϵ
XZK=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic networkԭ.xlsx','���ƿ�');%���ƿ���ڵ�Ķ�Ӧ��ϵ
JUZHEN_Road_Zliuliang=zeros(size(Roadcapacity,1),Zong_tp);%��¼��ʱ�εĺ�����������Ϊ·����Ϊ��tpʱ��  ���뵱ǰֵ����ӦΪ0
ZhuanWanP_Y=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic networkԭ.xlsx','ZhuanWanP_Y');%��·��ת����ʵĸ�ֵԭֵ
[Type,Sheet,Fromat]=xlsfinfo('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\TrafficLight.xlsx');
Phase_Road=zeros(size(Roadcapacity,1),size(Roadcapacity,1),length(Sheet));
JUZHEN_GreenTime=zeros(size(Roadcapacity,1),size(Roadcapacity,1),Zong_tp);%�̵�ʱ��
JZPhase_GreenST=zeros(Zong_tp,size(Phase_Road,3));%����λ���ڸ����ڶΣ��̵ƿ�ʼʱ��
LKXZ_Time=zeros(size(XZK,1),1);%��¼��һ�����뿪���ƿڵ�ʱ��
JT(isnan(JT))=0;
JT_YJ(isnan(JT_YJ))=0;
ZhuanWanP_Y(isnan(ZhuanWanP_Y))=0;
%--------------get_LightControl��Ҫ�ľ�������
JUZHEN_Road_ZQueue=zeros(size(Roadcapacity,1),Zong_tp);%��¼��ʱ�εĺ�����������Ϊ·����Ϊ��tpʱ��
JUZHEN_pressure=zeros(size(Roadcapacity,1),size(Roadcapacity,1),Zong_tp);%��ѹϵ��
JUZHEN_weight=zeros(Zong_tp,size(Phase_Road,3));%Ȩ��ϵ��
JUZHEN_bili=zeros(Zong_tp,size(Phase_Road,3));%�̵Ʊ���
JUZHEN_RemainingCapacity=zeros(size(Roadcapacity,1),Zong_tp);%��¼��ʱ�κ��� ��ʣ����������Ϊ·����Ϊ��tpʱ��
JUZHEN_Phase_GreenTime=zeros(Zong_tp,size(Phase_Road,3));%����λ���̵�ʱ��
JUZHEN_Phase_GreenTime(1,:)=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Phase_GreenTime.xlsx');%tp=1�׶γ�ʼֵ���������̵ĵ� Ҫ
%-----------------------get_luzu��Ҫ�ľ�������
JUZHEN_Intersection_liuliang=zeros(size(JT,1),size(JT,2),Zong_tp);
JZ_Road_AveLiuliang=zeros(size(Roadcapacity,1),Zong_tp);%��¼����·�ľ�����
JZ_Road_Baohedu=zeros(size(Roadcapacity,1),Zong_tp);%��¼����·�ı��Ͷ�
JUZHEN_Intersection_baohedu=zeros(size(JT,1),size(JT,2),Zong_tp);%��¼����·����������ı��Ͷ�
%---------------------------------------------------------
for i=1:length(Sheet)
Phase_Road(:,:,i)=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\TrafficLight.xlsx',num2str(i));%���ζ�����λp����·��i,j���Ŀ��ƹ�ϵ������Ϊ1����Ϊ0 Ҫ
end
XH=Flight(:,1);%�������
JL=Flight(:,2);%���볡
JC=Flight(:,3);%�����������ն������յ㣬�뿪�ն����ĳ�ʼ��
XTBJ=Flight(:,4);%�����ն����ĳ�ʼ�㣬�뿪�ն������յ�
CS=Flight(:,5);%�� ���ն���ʱ��


Daodat=zeros(length(XH),n);%��¼����ÿһ�ڵ��ʱ��
Likait=zeros(length(XH),n);%��¼�뿪ÿһ�ڵ��ʱ��
Shidian_Zhongdian=zeros(size(Flight,1),3);%ʼ�յ� ��
Shidian_Zhongdian(:,1)=(1:size(Flight,1));%��һ���Ǻ������
JUZHEN_Road_Queue=zeros(size(Roadcapacity,1),size(Roadcapacity,1),Zong_tp);%�ն�����ʼ״̬���κκ�·�����Ŷ�
ZhuanWanP=zeros(size(Roadcapacity,1),size(Roadcapacity,1));%��·i����·j��ת����ʣ���i,j���ĺ����Ŷ�����/i�����Ŷ�����
JUZHEN_luzu=zeros(size(JT,1),size(JT,2),Zong_tp);%��¼����·����·����£�����������ȷ��
Flight_Stop=zeros(size(Flight,1),3);%��¼����ͣ���������ȴ�ʱ��
Flight_Stop(:,1)=Flight(:,1);%���
JUZHEN_luzu(:,:,1)= JT;%tp=1ʱ��·��
Queue_flights=[];

%% ���ɸ������ʼ��-�յ���󣬳�ʼ������·������·���̵�ʱ��
for  ii=1:length(XH)
    if JL(ii)==1%----------------------------------------------------����  ��������·��
        Shidian_Zhongdian(ii,2)=XTBJ(ii);%ʼ��
        Shidian_Zhongdian(ii,3)=JC(ii);%�յ�
    else%---------------------------------------------------------�볡��������·��
        Shidian_Zhongdian(ii,2)=JC(ii);%ʼ��
        Shidian_Zhongdian(ii,3)=XTBJ(ii);%�յ�
    end
end
index3=zeros(length(XH),1);
Luxian_Intersection=zeros(length(XH),n);
Luxian_Road=zeros(length(XH),n);
for j=1:length(XH)%����ĳ�ʼʱ��ͳ�ʼ��
    index3(j,1)=1;%�������ڵ�ı��,�ڼ�����ţ�����ڣ�
    NextT=CS(j);%��ʼʱ�䣬ӦΪ�����ն���ʱ��
    Luxian_Intersection(j,index3(j))=Shidian_Zhongdian(j,2); %��¼����������нڵ�·��    ����i�ĳ�ʼ�ڵ�
    Luxian_Road(j,index3(j))=Flight(j,8);%��¼������ľ���·��   ����i�ĳ�ʼ·��
    Daodat(j,index3(j))=NextT;%����i����ڳ�ʼ�ڵ��ʱ��
end
%--------------------------------------------------------------------------------------��һ���ڸ�·�γ�ʼ�̵�ʱ��
m=size(Phase_Road,1);
n=size(Phase_Road,2);
kkk=find(Phase_Road);%Ѱ��Phase_Road�еķ���Ԫ��
RoadRaw=rem(rem((kkk-1),m*n),m)+1;%������
RoadColumn=fix(rem((kkk-1),(m*n))/m)+1;%������
RoadPage=fix((kkk-1)/(m*n))+1;%ҳ����
for gg=1:size(RoadRaw,1)
    JUZHEN_GreenTime(RoadRaw(gg),RoadColumn(gg))=JUZHEN_Phase_GreenTime(1,RoadPage(gg));   %��һ���ڸ�·�γ�ʼ�̵�ʱ��
end
  
for rl=1:size(Roadcapacity,1)%��1���ڵ�������
    JUZHEN_Road_Zliuliang(rl,1)=length(find(Flight(:,8)==rl));
end

%%  ģ�����
while t<=tmax
    tp=ceil(t/TP);%����ȡ�����жϵ�ǰ���ں�
    %---------------------------------------------------------------------------------���º������״̬
    FlightCharge=[];
    Now_time=[];
    for sf=1:size(Flight,1)
%         nzero=find(Luxian_Road(sf,:)~=0, 1, 'last' );
%         if Luxian_Road(sf,nzero)~=107
        if isempty(find(Luxian_Intersection(sf,:)==Shidian_Zhongdian(sf,3), 1))==1
            FlightCharge=[FlightCharge;Flight(sf,:)];
            Now_time=[Now_time;t];
        end
    end
    if sum(FlightCharge)~=0
        [StateCharge,YXJ]=get_StateCharge( Now_time,FlightCharge,Xuhang,Flight(:,5),Sheet_YXJ1,Sheet_YXJ2,Sheet_YXJ3);
    end
    if t>120 && tp<Zong_tp && mod(t,TP)==1
        [JUZHEN_Road_Zliuliang,JUZHEN_Road_Queue,JUZHEN_Road_ZQueue]=get_Road_ZLiuliangYC(JUZHEN_GreenTime,tp,Roadcapacity,JUZHEN_Baohe_Speed,JUZHEN_Road_Zliuliang,ZhuanWanP,JUZHEN_Road_Queue,JUZHEN_Road_ZQueue);%����·�ε�������,tp+1���ڵ��Ŷӳ���
    end
    %---------------------------------------------------------------------------------------�����źŵ�
    if tp<Zong_tp && mod(t,TP)==1 %�����ڳ�����һ���ڿ�ʼ���и��£��磺��t=1ʱ����һ���ڳ��ڣ��Եڶ����ڵ��̵�ʱ�����и��¡���t=121s�����ڶ����ڳ����Ե������ڵ���ֵ���и���
        [JUZHEN_GreenTime,JUZHEN_bili,JUZHEN_Phase_GreenTime,JZPhase_GreenST,JUZHEN_pressure,JUZHEN_weight]=get_LightControl(t,JUZHEN_Road_Queue,Roadcapacity,JUZHEN_Baohe_Speed,TP,Zong_tp,Phase_Road,ZhuanWanP,JUZHEN_GreenTime,Intersection_Phase,JUZHEN_Road_ZQueue,JUZHEN_pressure,JUZHEN_weight,JUZHEN_bili,JUZHEN_Phase_GreenTime,JZPhase_GreenST);%���£�i��j������ɫͨ��ʱ��
        if tp~=1
            [JUZHEN_luzu,JZ_Road_AveLiuliang,JZ_Road_Baohedu,JUZHEN_Intersection_baohedu] = get_luzu(JUZHEN_luzu,JUZHEN_Road_Zliuliang,tp,Intersection_Luhao,JT,JZ_Road_AveLiuliang,Zong_tp,Roadcapacity,JZ_Road_Baohedu,JUZHEN_Intersection_baohedu);%ÿ����һ������ڣ����¡�·�衿
        end
    end
    %----------------------------------------------------------------------�ڵ�ǰʱ��t���ҵ�λ�ڸ�����ڵĺ��࣬���̵� ֱ��ͨ�У������ �����ŶӾ���
    equal_index=ismember(Daodat,t);%��Ѱ�ҡ���ǰʱ��t λ�ڽ���ڵĺ���
    if sum(sum(equal_index))~=0  %������һ���ൽ����Ӧ����ڣ�����������ĳһ����ڵĵ���ʱ��С��60
        [TrueRaw,TrueColumn]=find(equal_index==1);
        flight_index=XH(TrueRaw);%��ǰʱ��t ���ｻ��ڵġ�������š�
        P=flight_index;
        for iii=1:length(P)%P(i)�Ǻ����ţ����ÿһ���ｻ��ڵĺ���ѡ��·�����ж��Ƿ���Ҫ�Ŷ�
            if isempty(find(Luxian_Intersection(P(iii),:)==Shidian_Zhongdian(P(iii),3), 1))==1 && StateCharge(StateCharge(:,1)==P(iii),2)>0.16 &&( Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))>16 || Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))<46) %δ���յ�
                [NextPoint,NextT]=Shortest_path(JUZHEN_luzu(:,:,tp),JT,Luxian_Intersection(P(iii),index3(P(iii))),Shidian_Zhongdian(P(iii),3));%�����·�����������뵱ǰ����յ㣬�����һ���н�����������������õ㳤��
                index3(P(iii))= index3(P(iii))+1;
                Luxian_Intersection(P(iii),index3(P(iii)))=NextPoint;%��¼��һ����ڵ�
                Luxian_Road(P(iii),index3(P(iii)))=Intersection_Luhao(Luxian_Intersection(P(iii),index3(P(iii))-1),Luxian_Intersection(P(iii),index3(P(iii))) );%��һ·��
                %---------------------------------------------------------�жϺ��൱ǰ��·i����һ��·j������i��j���ĺ��̵�״̬�뺽��������жϸú����Ƿ���Ҫ����
                ind=find(Phase_Road(Luxian_Road(P(iii),index3(P(iii))-1),Luxian_Road(P(iii),index3(P(iii))),:)==1);
                G2R=JZPhase_GreenST(tp,ind)+JUZHEN_Phase_GreenTime(tp,ind); %��Ƶ�ʱ��
                GS=JZPhase_GreenST(tp,ind);
                if (t>=G2R||t<JZPhase_GreenST(tp,ind)) && t<=tp*TP     %������Ҫ�������������ƣ�����
                    %----------------------------------------------��Ҫ����ĺ������Queue_flights
                    if sum(sum(sum(Queue_flights)))==0
                        Queue_flights(1,1, ind)=P(iii);%��λ����ĺ����,��·�Ŷ�Ӧ�������
                        Queue_flights(1,2, ind)=Daodat(P(iii),index3(P(iii))-1);%��λ���򺽰�ĳ�ʼ����ʱ��
                        Queue_flights(1,3, ind)=YXJ(YXJ(:,1)==P(iii),2);%��Ҫ���򺽰�����ȼ�
                    else
                        Ysize=size(Queue_flights,1);%ʱ��tʱ�������������ע�����п�����ȫ0��
                        Queue_flights(Ysize+1,1,ind)=P(iii);%��λ����ĺ����
                        Queue_flights(Ysize+1,2,ind)=Daodat(P(iii),index3(P(iii))-1);%��λ���򺽰�ĳ�ʼ����ʱ��
                        Queue_flights(Ysize+1,3,ind)=YXJ(YXJ(:,1)==P(iii),2);%��Ҫ���򺽰�����ȼ�
                    end
                else
                    %�����Ӧ��λ���ڵ���֮ǰ�����ŶӺ��࣬���Ŷӣ�����ֱ��ͨ��
                    if  isempty(Queue_flights)==0 && ind<=size(Queue_flights,3) && sum(sum(Queue_flights(:,:,ind)))~=0
                        Ysize=size(Queue_flights,1);%ʱ��tʱ�������������ע�����п�����ȫ0��
                        Queue_flights(Ysize+1,1,ind)=P(iii);%��λ����ĺ����
                        Queue_flights(Ysize+1,2,ind)=Daodat(P(iii),index3(P(iii))-1);%��λ���򺽰�ĳ�ʼ����ʱ��
                        Queue_flights(Ysize+1,3,ind)=YXJ(YXJ(:,1)==P(iii),2);%��Ҫ���򺽰�����ȼ�
                    else
                        Likait(P(iii),index3(P(iii))-1)=round(Daodat(P(iii),index3(P(iii))-1));
                        Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);%��¼������һ�ڵ��ʱ��
                    end
                    [xzk,~]=find(XZK==Luxian_Intersection(P(iii),max(index3(P(iii))-1,1))) ;             %��Ҫͨ���ĳ�ͻ��
                    if LKXZ_Time(xzk,1)~=0
                        Likait(P(iii),index3(P(iii))-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Daodat(P(iii),index3(P(iii))-1)));%�뿪ʱ��ӦΪ max��ǰһ�����뿪ʱ��+��ȫ�����ԭ�뿪ʱ�䣩
                        Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);%��¼������һ�ڵ��ʱ��
                    end
                    LKXZ_Time(xzk,1)= max(Likait(P(iii),index3(P(iii))-1) ,LKXZ_Time(xzk,1));%�����뿪������ʱ���¼
                end
            elseif isempty(find(Luxian_Intersection(P(iii),:)==Shidian_Zhongdian(P(iii),3), 1))==1 && StateCharge(StateCharge(:,1)==P(iii),2)<=0.16 && Flight(P(iii),2)==1 && (Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))<=16 || Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))>=46) %������ĳһ�����ʱ����С��0.1����Ӧ������
                [NextPoint,NextT]=Shortest_path(JT_YJ,JT_YJ,Luxian_Intersection(P(iii),index3(P(iii))),Shidian_Zhongdian(P(iii),3));%�����·�����������뵱ǰ����յ㣬�����һ���н�����������������õ㳤��
                index3(P(iii))= index3(P(iii))+1;
                Luxian_Intersection(P(iii),index3(P(iii)))=NextPoint;%��¼��һ����ڵ�
                %                 Luxian_Road(P(iii),index3(P(iii)))=Intersection_Luhao(Luxian_Intersection(P(iii),index3(P(iii))-1),Luxian_Intersection(P(iii),index3(P(iii))) );%��һ·��
                Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);%��¼������һ�ڵ��ʱ��
                [xzk,~]=find(XZK==Luxian_Intersection(P(iii),max(index3(P(iii))-1,1))) ;             %��Ҫͨ���ĳ�ͻ��
                if LKXZ_Time(xzk,1)~=0
                    Likait(P(iii),index3(P(iii))-1)=round(max(LKXZ_Time(xzk,1)+20,Daodat(P(iii),index3(P(iii))-1)));%�뿪ʱ��ӦΪ max��ǰһӦ�������뿪ʱ��+20��ԭ�뿪ʱ�䣩
                else
                    Likait(P(iii),index3(P(iii))-1)=round(Daodat(P(iii),index3(P(iii))-1));%����Ҫ�Ŷӣ�ֱ��ͨ��
                end
                Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);%��¼������һ�ڵ��ʱ��
                LKXZ_Time(xzk,1)= max(Likait(P(iii),index3(P(iii))-1) ,LKXZ_Time(xzk,1));%�����뿪������ʱ���¼
            else  %�� ��ǰ�ڵ�Ϊ�ú����յ�,
                index3(P(iii))= index3(P(iii))+1;
                Luxian_Road(P(iii),index3(P(iii)))=200;
                
                [xzk,~]=find(XZK==Shidian_Zhongdian(P(iii),3)) ;%��Ҫͨ���ĳ�ͻ�ڣ��յ㣩
                end1=find(Daodat(P(iii),:)~=0, 1, 'last' );
                if LKXZ_Time(xzk,1)~=0 & StateCharge(StateCharge(:,1)==P(iii),2)>0.1
                    Likait(P(iii),index3(P(iii))-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Daodat(P(iii),end1)));%�뿪ʱ��ӦΪ max��ǰһ�����뿪ʱ��+��ȫ�����ԭ�뿪ʱ�䣩
                    Flight_Stop(P(iii),2)=Flight_Stop(P(iii),2)+1;%��ͣ���� %ͳ���ŶӺ����ͣ��������ͣ��ʱ��
                    Flight_Stop(P(iii),3)=Flight_Stop(P(iii),3)+(Likait(P(iii),index3(P(iii))-1)-Daodat(P(iii),end1));%��ͣʱ��
                else
                    Likait(P(iii),index3(P(iii))-1)=Daodat(P(iii),end1);
                end
                LKXZ_Time(xzk,1)= max(Likait(P(iii),index3(P(iii))-1) ,LKXZ_Time(xzk,1));%�����뿪������ʱ���¼
            end
        end
    end
    %----------------------------------------------------------------------------------------------�ѵõ���Ҫ��������ĺ���
    if mod(t,TP)==0 || mod(t,TP)==60 %������ĩ���к�������������ĩ�����·�Ŷӳ��ȣ���Ϊ��һ���ڳ����Ŷӳ���
        for s=1:size(Queue_flights,3)%�ڸ�����ڣ��Ե�ǰʱ����Ҫ����ĺ�����������������뿪��Ӧ����ڵ�ʱ��
            if sum(sum(Queue_flights(:,:,s)))~=0
                Qf= Queue_flights(:,:,s);
                Qf(all(Qf==0,2),:)=[];
                %             a(all(a==0,2),:) = [];%ɾ��ĳ�о�Ϊ0����
                %---------------��·i���Ŷӵķ�������������·i����·j��ת�����
                for z=1:size(Qf,1)
                    for r=1:size(Roadcapacity,1)
                        for c=1:size(Roadcapacity,1)  %-��·iȥ����·j���ŶӺ��������----ת�����
                            [~,~,FlightSum]=find((Luxian_Road(Qf(z,1),index3(Qf(z,1))-1)==r) & ((Luxian_Road(Qf(z,1),index3(Qf(z,1)))==c)));
                            JUZHEN_Road_Queue(r,c,tp+1)=JUZHEN_Road_Queue(r,c,tp+1)+ sum(FlightSum);%��·r����·c���Ŷ�����
                        end
                        [~,~,QueueSum]=find((Luxian_Road(Qf(z,1),index3(Qf(z,1))-1)==r));
                        JUZHEN_Road_ZQueue(r,tp+1)=JUZHEN_Road_ZQueue(r,tp+1)+sum(QueueSum);
                    end
                end
                %-------------------------------------------------------------------------------
                [Intersaction_JG,Airport_JG]=JG_function(size(Qf,1));%���ɽ���ڼ�����𽵳����
                ind2=s;
%                 ind2=find(Phase_Road(Luxian_Road(Qf(1,1),index3(Qf(1,1))-1),Luxian_Road(Qf(1,1),index3(Qf(1,1))),:)==1);%��Ӧ����λ
                if mod(JZPhase_GreenST(tp,ind2),TP)==0
                    ind2_GS=JZPhase_GreenST(tp+1,ind2);%��������λ���̵�ʱ���Ǵ�ÿ�����ڳ���ʼ�ģ���Ӧ��λ���̵ƿ�ʼʱ��
                    [Flight_Paixu,Shijian]=Acomain(Qf,Intersaction_JG,ind2_GS);%����Ⱥ���������i����ڵĴ����򺽰ࡢ������󡢵�i������ڵ�tpʱ��ε��̵ƿ�ʼʱ��
                    for k=1:size(Flight_Paixu,2)
                        xh1=Flight_Paixu(1,k);
                        if Shijian(k)>ind2_GS+JUZHEN_Phase_GreenTime(tp+1,ind2)%����ŶӺ���뿪ʱ������̵ƽ�ֹ��ʱ�䣬��Ҫ�����ȴ�
                            Y_Daodat=Daodat(xh1,index3(xh1)-1);
                            Daodat(xh1,index3(xh1)-1)=(tp+1) *TP+1;              %���䵽��ʱ����Ϊ��һ���ڵ��̵ƿ�ʼʱ�䡣
                            Daodat(xh1,index3(xh1):size(Daodat,2))=0;
                            Flight_Stop(xh1,2)=Flight_Stop(xh1,2)+1;%��ͣ���� %ͳ���ŶӺ����ͣ��������ͣ��ʱ��
                            Flight_Stop(xh1,3)=Flight_Stop(xh1,3)+abs((Daodat(xh1,index3(xh1)-1)-Y_Daodat));%��ͣʱ��!!
                            index3(xh1,1)= sum(Daodat(xh1,:)~=0);
                        else
                            [xzk,~]=find(XZK==Luxian_Intersection(xh1,max(index3(xh1)-1,1))) ;             %��Ҫͨ���ĳ�ͻ��
                            if LKXZ_Time(xzk,1)~=0
                                Likait(xh1,index3(xh1)-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Shijian(k)));%�뿪ʱ��ӦΪ max��ǰһ�����뿪ʱ��+60��ԭ�뿪ʱ�䣩
                            else
                                Likait(xh1,index3(xh1)-1)=round(Shijian(k));
                            end
                            Daodat(xh1,index3(xh1))=max(round(Likait(xh1,index3(xh1)-1)+ NextT),t+1);%��¼������һ�ڵ��ʱ��
                            LKXZ_Time(xzk,1)= max(Likait(xh1,index3(xh1)-1) ,LKXZ_Time(xzk,1));%�����뿪������ʱ���¼
                            Flight_Stop(xh1,2)=Flight_Stop(xh1,2)+1;%��ͣ���� %ͳ���ŶӺ����ͣ��������ͣ��ʱ��
                            Flight_Stop(xh1,3)=Flight_Stop(xh1,3)+(Likait(xh1,index3(xh1)-1)-Daodat(xh1,index3(xh1)-1));%��ͣʱ��
                        end
                        
                    end
                else
                    if Qf(1,2)>JZPhase_GreenST(tp,ind2)
                        ind2_GS=JZPhase_GreenST(tp+1,ind2);%��Ӧ��λ���̵ƿ�ʼʱ��
                    else
                        ind2_GS=JZPhase_GreenST(tp,ind2);
                    end
                    [Flight_Paixu,Shijian]=Acomain(Qf,Intersaction_JG,ind2_GS);%����Ⱥ���������i����ڵĴ����򺽰ࡢ������󡢵�i������ڵ�tpʱ��ε��̵ƿ�ʼʱ��
                    for k=1:size(Flight_Paixu,2)
                        xh=Flight_Paixu(1,k);
                        if Shijian(k)>ind2_GS+JUZHEN_Phase_GreenTime(tp+1,ind2)%����ŶӺ���뿪ʱ������̵�ת��Ƶ�ʱ�䣬��Ҫ�����ȴ�
                            Y_Daodat1=Daodat(xh,index3(xh)-1);
                            Daodat(xh,index3(xh)-1)=round(JZPhase_GreenST(tp+1,ind2))+1;              %���䵽��ʱ����Ϊ��һ���ڵ��̵ƿ�ʼʱ��
                            Flight_Stop(xh,2)=Flight_Stop(xh,2)+1;%��ͣ���� %ͳ���ŶӺ����ͣ��������ͣ��ʱ��
                            Flight_Stop(xh,3)=Flight_Stop(xh,3)+(Daodat(xh,index3(xh)-1)-Y_Daodat1);%��ͣʱ��
                            index3(xh,1)= sum(Daodat(xh,:)~=0);
                        else
                            [xzk,~]=find(XZK==Luxian_Intersection(xh,max(index3(xh)-1,1))) ;             %��Ҫͨ�������ƿ�
                            if LKXZ_Time(xzk,1)~=0
                                Likait(xh,index3(xh)-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Shijian(k)));%�뿪ʱ��ӦΪ max��ǰһ�����뿪ʱ��+60��ԭ�뿪ʱ�䣩
                            else
                                Likait(xh,index3(xh)-1)=round(Shijian(k));
                            end
                            Daodat(xh,index3(xh))=max(round(Likait(xh,index3(xh)-1)+ NextT),t+1);%��¼������һ�ڵ��ʱ��
                            LKXZ_Time(xzk,1)= max(Likait(xh,index3(xh)-1) ,LKXZ_Time(xzk,1));%�����뿪������ʱ���¼
                            Flight_Stop(xh,2)=Flight_Stop(xh,2)+1;%��ͣ����
                            Flight_Stop(xh,3)=Flight_Stop(xh,3)+(Likait(xh,index3(xh)-1)-Daodat(xh,index3(xh)-1));%��ͣʱ��
                        end
                        %---------------ͳ���ŶӺ����ͣ��������ͣ��ʱ��
                        
                    end
                end
                
            end
        end
        Queue_flights=[];
    end
    if mod(t,TP)==0
        %---------------------------------------------------����ת�����
        Now_NextRoad=zeros(size(Flight,1),2);ZhuanWanP=ZhuanWanP_Y;
        for fi=1:size(Likait,1)  %�õ������൱ǰ���ڵ�·�ı��
            X=Likait(fi,:);
            max_solve=find(X~=0, 1, 'last' );
            if sum(max_solve)~=0 && Likait(fi,max_solve)<=t
                Now_NextRoad(fi,1)=Luxian_Road(fi,index3(fi));
            elseif sum(max_solve)~=0 && Likait(fi,max_solve)>t %���һ���뿪ʱ�� ���ڵ��� ��ǰʱ��t
                Now_NextRoad(fi,1)=Luxian_Road(fi,max(index3(fi)-1,1));
                Now_NextRoad(fi,2)=Luxian_Road(fi,index3(fi));
            elseif sum(max_solve)==0
                Now_NextRoad(fi,1)= Luxian_Road(fi,index3(fi));
            end
        end
        for ai=1:size(Roadcapacity,1)  %��·����������
            JUZHEN_Road_Zliuliang(ai,tp+1)=length(find(Now_NextRoad(:,1)==ai));
            JUZHEN_Road_Zliuliang(ai,tp+2)=length(find(Now_NextRoad(:,2)==ai));
            SJ=[];
            if tp>1 && JUZHEN_Road_Zliuliang(ai,tp+1)>Roadcapacity(ai,2)%�ӵڶ����ڿ�ʼ�жϣ����·������������������
                [Flightrow,~]=find(Now_NextRoad(:,1)==ai);%�ҵ���ǰ������·�ϵĺ��࣬������
                [Qdian,~]=find(Intersection_Luhao==ai);%ai��·��ǰ��ڵ� 
                [Raw,Col]=find(Luxian_Intersection(Flightrow,:)==Qdian);F=Flightrow(Raw); %ǰ��ڵ��ڶ�Ӧ��Ӧ����� �ڼ��� ·�߽ڵ�
                for fli=1:size(F,1)
                    for flj=1:size(Col,2)
                        SJ=[SJ;Daodat(F(fli),Col(flj))];
                    end
                end
                PX_flight=[F SJ];PX_flight=sortrows(PX_flight,2);%����
                for fl=(Roadcapacity(ai,2)+1):(JUZHEN_Road_Zliuliang(ai,tp+1))%�Գ��������ĺ�����е�������
                    [~,Col1]=find(Luxian_Intersection(PX_flight(fl,1),:)==Qdian);%��Ӧ·�߽ڵ�             
                    y1=Daodat(PX_flight(fl,1),Col1);%ԭ�� �ú��ൽ��õ��ʱ��
                    Daodat(PX_flight(fl,1),Col1)=max(tp*TP+1,y1);
                    x1=Daodat(PX_flight(fl,1),Col1)-y1;%���
                    if x1~=0
                        Daodat(PX_flight(fl,1),Col1+1:size(Daodat,2))=0;Likait(PX_flight(fl,1),Col1:size(Likait,2))=0;Luxian_Intersection(PX_flight(fl,1),Col1+1:size(Luxian_Intersection,2))=0;
                        [~,Col2]=find(Luxian_Road(PX_flight(fl,1),:)==ai);Luxian_Road(PX_flight(fl,1),max(Col2,2):size(Luxian_Road,2))=0;%�ص�·�ε�ǰ��ڵ�
                        index3(PX_flight(fl,1))=sum(Daodat(PX_flight(fl,1),:)~=0);
                        Flight_Stop(PX_flight(fl,1),3)=Flight_Stop(PX_flight(fl,1),2)+x1;                      %������ͣʱ��
                        Flight_Stop(PX_flight(fl,1),2)=Flight_Stop(PX_flight(fl,1),2)+1;                       %������ͣ����
                    end
                end
            else
                for aj=1:size(Roadcapacity,1)
                    [roadR]=find(Now_NextRoad(:,1)==ai & Now_NextRoad(:,2)==aj);
                    nr=length(roadR);
                    if nr~=0
                        ZhuanWanP(ai,aj)=nr./JUZHEN_Road_Zliuliang(ai,tp+1);
                    end
                end
            end
        end
    end
    
    t=t+TimeGap;%ʱ�䲽��
end
%% ������
JS_Time=zeros(size(Likait,1),1);
for sj=1:size(Likait,1)
    nling=find(Likait(sj,:)~=0,1,'last');
    JS_Time(sj,1)=Likait(sj,nling);%�ĳ�likait
end
 [JS_StateCharge,~]=get_StateCharge(JS_Time,Flight,Xuhang,Daodat,Sheet_YXJ1,Sheet_YXJ2,Sheet_YXJ3);
 
 %�ն�����������
%  ZD_liuliang=zeros(1,Zong_tp);
%  for hb=1:size(Flight,1)
%      JR=ceil(Daodat(hb,1)/TP);
%      LK=ceil(JS_Time(hb,1)/TP);
%      for tpi=JR:LK
%          ZD_liuliang(1,tpi)=ZD_liuliang(1,tpi)+1;%��ʱ�ε��ն���������
%      end
%  end
%  Liyong= ZD_liuliang./sum(Roadcapacity(1:102,2));
 
 %------------------------��ͻ��-�ڲ㻷�����ó�ͻ��----------����Ӧ�ڲ�8���󽻲�ڣ���ͳ9-16
  CTK_Time=zeros(size(CTK,1),size(Flight,1));
 for cti=1:size(CTK,1)
     for ctj=1:sum(~isnan(CTK(cti,:)))
         [NumF,NumInt]=find(Luxian_Intersection==CTK(cti,ctj)); %�ҵ�������CTK(cti,ctj)�ĺ����������
         for fi=1:length(NumF)
            A=Likait(NumF(fi),NumInt(fi));
            CTK_Time(cti,NumF(fi))= A;      %��ʱ����ڵ�cti�г�ͻ��
         end
     end
 end
 CTBJ=0;
for ctk=1:size(CTK_Time,1)
    CTK_Time1=CTK_Time(ctk,:);
    CTK_Time1(CTK_Time1==0)=[];
    for cti=1:size(CTK_Time1,2)-1
        for ctj=(cti+1):size(CTK_Time1,2)
            jg=abs(CTK_Time1(cti)-CTK_Time1(ctj));
            if jg<20 %�������õ���С��60��������������
                CTBJ=CTBJ+1;%���㱨������
            end
        end
    end
end
XT_Time=zeros(size(Flight,1),1);
%Ԥ���ܵ�ʱ�估��ͣ/����ȴ�ʱ��
YJJS_Time=zeros(size(Flight,1),1);                    %�����࣬��Ԥ�ƽ���ʱ�䣬��λ���뿪�ն���ʱ��ʱ��
for hb=1:size(Flight,1)
        YJJS_Time(hb,1)=Flight(hb,5);
        LX=Luxian_Intersection(hb,:);
        LX(LX==0)=[];
        for lx=1:(size(LX,2)-1)
            YJJS_Time(hb,1)=YJJS_Time(hb,1)+max(JT_Z(Luxian_Intersection(hb,lx),Luxian_Intersection(hb,lx+1)),JT_YJ(Luxian_Intersection(hb,lx),Luxian_Intersection(hb,lx+1)));
        end
        XT_Time(hb,1)=max(0,round(JS_Time(hb,1)-YJJS_Time(hb,1)));
end
%----------------������ƽ���𽵼��----------------------------
JC25=[];JC26=[];JC27=[];JG=zeros(4,1);
for hb1=1:size(Flight,1)
    if Flight(hb1,3)==25 && Flight(hb1,2)==2
        JC25=[JC25;[Daodat(hb1,1)]];
    elseif Flight(hb1,3)==25 && Flight(hb1,2)==1
        JC25=[JC25;[Daodat(hb1,find(Likait(sj,:)~=0,1,'last'))]];
    elseif Flight(hb1,3)==26 && Flight(hb1,2)==2
        JC26=[JC26;[Daodat(hb1,1)]];
    elseif Flight(hb1,3)==26 && Flight(hb1,2)==1
        JC26=[JC26;[Daodat(hb1,find(Likait(sj,:)~=0,1,'last'))]];
    elseif Flight(hb1,3)==27 && Flight(hb1,2)==2
        JC27=[JC27;[Daodat(hb1,1)]];
    elseif Flight(hb1,3)==27 && Flight(hb1,2)==1
        JC27=[JC27;[Daodat(hb1,find(Likait(sj,:)~=0,1,'last'))]];
    end
end
JC25=sort(JC25);JC26=sort(JC26);JC27=sort(JC27);
for z1=1:size(JC25,1)-1
    JC25(z1,2)=JC25(z1+1,1)-JC25(z1,1);
end
JG(1,1)=mean(JC25(1:size(JC25,1)-1,2));
for z1=1:size(JC26,1)-1
    JC26(z1,2)=JC26(z1+1,1)-JC26(z1,1);
end
JG(2,1)=mean(JC26(1:size(JC26,1)-1,2));
for z1=1:size(JC27,1)-1
    JC27(z1,2)=JC27(z1+1,1)-JC27(z1,1);
end
JG(3,1)=mean(JC27(1:size(JC27,1)-1,2));
JG(4,1)=mean(JG(1:3,1));
DLBJ=sum(JS_StateCharge(:,2)<-0.1);
%-------------------------���ں����뿪��ʱ����-��ͼ-----------
% JR_SJ=zeros(1,max(JS_Time));%�����ն���ʱ����ۼƺ�������
% LK_SJ=zeros(1,max(JS_Time));%�뿪�ն���ʱ����ۼƺ�������
% for tt=1:max(JS_Time)
%     [JR_Row,~]=find(Flight(:,5)<=tt);
%     JR_SJ(1,tt)=length(JR_Row);
%     [LK_Row,~]=find(JS_Time<=tt);
%     LK_SJ(1,tt)=length(LK_Row);
% end
% 
% tt=1:max(JS_Time);
% plot(tt,JR_SJ,tt,LK_SJ); 
 