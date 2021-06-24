%终端区内的航班控制  实时仿真框架
clear all;close all;clc
%% 数据输入
TP=120;%每交叉口的周期长度
t=1;%时间轴时间，更新步长为1s  或者更短
TimeGap=1;%时间间隔，时间步长
tmax=60000;%预设为60000s，应该直至所有航班进离场结束
Zong_tp=tmax/TP;
Xuhang=1;%续航时间
n=20;safetyJG=60;
JT=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','JT');%终端区交通路进场网的初始值
JT_Z=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','JT_Z');%终端区交通路进场网的初始值
JT_YJ=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','JT_YJ');

Flight=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network100.xlsx','Flight');%航班信息
Intersection_Luhao=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','Intersection_Luhao');%交叉口与路号的对应关系,根据交叉口号找到路号，横纵标为交叉口
JUZHEN_Baohe_Speed=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','Baohe_Speed');%单位：架/s
Roadcapacity = xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','Roadcapacity');%进场路网容量
Intersection_Phase=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Intersection_Phase.xlsx');%读入交叉口与相位的对应关系
Sheet_YXJ1=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Youxianji.xlsx','R=1');%电量10%-40%
Sheet_YXJ2=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Youxianji.xlsx','R=2');%电量40%-70%
Sheet_YXJ3=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Youxianji.xlsx','R=3');%电量70%-100%
CTK=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','冲突口');%冲突口与节点的对应关系
XZK=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','限制口');%限制口与节点的对应关系
JUZHEN_Road_Zliuliang=zeros(size(Roadcapacity,1),Zong_tp);%记录各时段的航段流量，行为路号列为第tp时段  输入当前值，不应为0
ZhuanWanP_Y=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','ZhuanWanP_Y');%道路间转向概率的赋值原值
[Type,Sheet,Fromat]=xlsfinfo('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\TrafficLight.xlsx');
Phase_Road=zeros(size(Roadcapacity,1),size(Roadcapacity,1),length(Sheet));
JUZHEN_GreenTime=zeros(size(Roadcapacity,1),size(Roadcapacity,1),Zong_tp);%绿灯时间
JZPhase_GreenST=zeros(Zong_tp,size(Phase_Road,3));%各相位，在各周期段，绿灯开始时间
LKXZ_Time=zeros(size(XZK,1),1);%记录上一航班离开限制口的时间
JT(isnan(JT))=0;
JT_YJ(isnan(JT_YJ))=0;
ZhuanWanP_Y(isnan(ZhuanWanP_Y))=0;
%--------------get_LightControl需要的矩阵声明
JUZHEN_Road_ZQueue=zeros(size(Roadcapacity,1),Zong_tp);%记录各时段的航段流量，行为路号列为第tp时段
JUZHEN_pressure=zeros(size(Roadcapacity,1),size(Roadcapacity,1),Zong_tp);%背压系数
JUZHEN_weight=zeros(Zong_tp,size(Phase_Road,3));%权重系数
JUZHEN_bili=zeros(Zong_tp,size(Phase_Road,3));%绿灯比例
JUZHEN_RemainingCapacity=zeros(size(Roadcapacity,1),Zong_tp);%记录各时段航段 总剩余流量，行为路号列为第tp时段
JUZHEN_Phase_GreenTime=zeros(Zong_tp,size(Phase_Road,3));%各相位的绿灯时间
JUZHEN_Phase_GreenTime(1,:)=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Phase_GreenTime.xlsx');%tp=1阶段初始值，包括常绿的灯 要
%-----------------------get_luzu需要的矩阵声明
JUZHEN_Intersection_liuliang=zeros(size(JT,1),size(JT,2),Zong_tp);
JZ_Road_AveLiuliang=zeros(size(Roadcapacity,1),Zong_tp);%记录各道路的均流量
JZ_Road_Baohedu=zeros(size(Roadcapacity,1),Zong_tp);%记录各道路的饱和度
JUZHEN_Intersection_baohedu=zeros(size(JT,1),size(JT,2),Zong_tp);%记录进场路网、交叉点间的饱和度
%---------------------------------------------------------
for i=1:length(Sheet)
Phase_Road(:,:,i)=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\TrafficLight.xlsx',num2str(i));%依次读入相位p对链路（i,j）的控制关系，控制为1否则为0 要
end
XH=Flight(:,1);%航班序号
JL=Flight(:,2);%进离场
JC=Flight(:,3);%机场。进入终端区的终点，离开终端区的初始点
XTBJ=Flight(:,4);%进入终端区的初始点，离开终端区的终点
CS=Flight(:,5);%进 入终端区时间


Daodat=zeros(length(XH),n);%记录到达每一节点的时间
Likait=zeros(length(XH),n);%记录离开每一节点的时间
Shidian_Zhongdian=zeros(size(Flight,1),3);%始终点 表
Shidian_Zhongdian(:,1)=(1:size(Flight,1));%第一列是航班序号
JUZHEN_Road_Queue=zeros(size(Roadcapacity,1),size(Roadcapacity,1),Zong_tp);%终端区初始状态，任何航路均无排队
ZhuanWanP=zeros(size(Roadcapacity,1),size(Roadcapacity,1));%航路i到航路j的转弯概率，（i,j）的航班排队数量/i的总排队数量
JUZHEN_luzu=zeros(size(JT,1),size(JT,2),Zong_tp);%记录进场路网的路阻更新，行数与列数确定
Flight_Stop=zeros(size(Flight,1),3);%记录航班停车次数、等待时间
Flight_Stop(:,1)=Flight(:,1);%序号
JUZHEN_luzu(:,:,1)= JT;%tp=1时的路阻
Queue_flights=[];

%% 生成各航班的始点-终点矩阵，初始化航班路径、各路段绿灯时间
for  ii=1:length(XH)
    if JL(ii)==1%----------------------------------------------------进场  航空器的路径
        Shidian_Zhongdian(ii,2)=XTBJ(ii);%始点
        Shidian_Zhongdian(ii,3)=JC(ii);%终点
    else%---------------------------------------------------------离场航空器的路径
        Shidian_Zhongdian(ii,2)=JC(ii);%始点
        Shidian_Zhongdian(ii,3)=XTBJ(ii);%终点
    end
end
index3=zeros(length(XH),1);
Luxian_Intersection=zeros(length(XH),n);
Luxian_Road=zeros(length(XH),n);
for j=1:length(XH)%航班的初始时间和初始点
    index3(j,1)=1;%所经历节点的标号,第几个标号（交叉口）
    NextT=CS(j);%初始时间，应为进入终端区时间
    Luxian_Intersection(j,index3(j))=Shidian_Zhongdian(j,2); %记录各航班的运行节点路径    航班i的初始节点
    Luxian_Road(j,index3(j))=Flight(j,8);%记录各航班的经过路号   航班i的初始路号
    Daodat(j,index3(j))=NextT;%航班i到达第初始节点的时间
end
%--------------------------------------------------------------------------------------第一周期各路段初始绿灯时间
m=size(Phase_Road,1);
n=size(Phase_Road,2);
kkk=find(Phase_Road);%寻找Phase_Road中的非零元素
RoadRaw=rem(rem((kkk-1),m*n),m)+1;%行索引
RoadColumn=fix(rem((kkk-1),(m*n))/m)+1;%列索引
RoadPage=fix((kkk-1)/(m*n))+1;%页索引
for gg=1:size(RoadRaw,1)
    JUZHEN_GreenTime(RoadRaw(gg),RoadColumn(gg))=JUZHEN_Phase_GreenTime(1,RoadPage(gg));   %第一周期各路段初始绿灯时间
end
  
for rl=1:size(Roadcapacity,1)%第1周期的总流量
    JUZHEN_Road_Zliuliang(rl,1)=length(find(Flight(:,8)==rl));
end

%%  模拟仿真
while t<=tmax
    tp=ceil(t/TP);%向上取整，判断当前周期号
    %---------------------------------------------------------------------------------更新航班电量状态
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
        [JUZHEN_Road_Zliuliang,JUZHEN_Road_Queue,JUZHEN_Road_ZQueue]=get_Road_ZLiuliangYC(JUZHEN_GreenTime,tp,Roadcapacity,JUZHEN_Baohe_Speed,JUZHEN_Road_Zliuliang,ZhuanWanP,JUZHEN_Road_Queue,JUZHEN_Road_ZQueue);%更新路段的总流量,tp+1周期的排队长度
    end
    %---------------------------------------------------------------------------------------更新信号灯
    if tp<Zong_tp && mod(t,TP)==1 %从周期初对下一周期开始进行更新，如：在t=1时，第一周期初期，对第二周期的绿灯时长进行更新。在t=121s初，第二周期初，对第三周期的数值进行更新
        [JUZHEN_GreenTime,JUZHEN_bili,JUZHEN_Phase_GreenTime,JZPhase_GreenST,JUZHEN_pressure,JUZHEN_weight]=get_LightControl(t,JUZHEN_Road_Queue,Roadcapacity,JUZHEN_Baohe_Speed,TP,Zong_tp,Phase_Road,ZhuanWanP,JUZHEN_GreenTime,Intersection_Phase,JUZHEN_Road_ZQueue,JUZHEN_pressure,JUZHEN_weight,JUZHEN_bili,JUZHEN_Phase_GreenTime,JZPhase_GreenST);%更新（i，j）的绿色通行时间
        if tp~=1
            [JUZHEN_luzu,JZ_Road_AveLiuliang,JZ_Road_Baohedu,JUZHEN_Intersection_baohedu] = get_luzu(JUZHEN_luzu,JUZHEN_Road_Zliuliang,tp,Intersection_Luhao,JT,JZ_Road_AveLiuliang,Zong_tp,Roadcapacity,JZ_Road_Baohedu,JUZHEN_Intersection_baohedu);%每到达一个交叉口，更新【路阻】
        end
    end
    %----------------------------------------------------------------------在当前时刻t，找到位于各交叉口的航班，若绿灯 直接通行，若红灯 进入排队矩阵
    equal_index=ismember(Daodat,t);%【寻找】当前时间t 位于交叉口的航班
    if sum(sum(equal_index))~=0  %至少有一航班到达相应交叉口，当两航班在某一交叉口的到达时间小于60
        [TrueRaw,TrueColumn]=find(equal_index==1);
        flight_index=XH(TrueRaw);%当前时间t 到达交叉口的【航班序号】
        P=flight_index;
        for iii=1:length(P)%P(i)是航班标号，针对每一到达交叉口的航班选择路径，判断是否需要排队
            if isempty(find(Luxian_Intersection(P(iii),:)==Shidian_Zhongdian(P(iii),3), 1))==1 && StateCharge(StateCharge(:,1)==P(iii),2)>0.16 &&( Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))>16 || Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))<46) %未到终点
                [NextPoint,NextT]=Shortest_path(JUZHEN_luzu(:,:,tp),JT,Luxian_Intersection(P(iii),index3(P(iii))),Shidian_Zhongdian(P(iii),3));%【最短路径函数】输入当前点和终点，获得下一运行交叉点的索引，及到达该点长度
                index3(P(iii))= index3(P(iii))+1;
                Luxian_Intersection(P(iii),index3(P(iii)))=NextPoint;%记录下一交叉口点
                Luxian_Road(P(iii),index3(P(iii)))=Intersection_Luhao(Luxian_Intersection(P(iii),index3(P(iii))-1),Luxian_Intersection(P(iii),index3(P(iii))) );%下一路号
                %---------------------------------------------------------判断航班当前链路i与下一链路j——（i，j）的红绿灯状态与航班电量，判断该航班是否需要排序
                ind=find(Phase_Road(Luxian_Road(P(iii),index3(P(iii))-1),Luxian_Road(P(iii),index3(P(iii))),:)==1);
                G2R=JZPhase_GreenST(tp,ind)+JUZHEN_Phase_GreenTime(tp,ind); %红灯的时刻
                GS=JZPhase_GreenST(tp,ind);
                if (t>=G2R||t<JZPhase_GreenST(tp,ind)) && t<=tp*TP     %排序需要满足的条件：红灯；电量
                    %----------------------------------------------需要排序的航班矩阵Queue_flights
                    if sum(sum(sum(Queue_flights)))==0
                        Queue_flights(1,1, ind)=P(iii);%相位排序的航班号,把路号对应到交叉口
                        Queue_flights(1,2, ind)=Daodat(P(iii),index3(P(iii))-1);%相位排序航班的初始到达时间
                        Queue_flights(1,3, ind)=YXJ(YXJ(:,1)==P(iii),2);%需要排序航班的优先级
                    else
                        Ysize=size(Queue_flights,1);%时间t时，矩阵的行数，注意其中可能有全0行
                        Queue_flights(Ysize+1,1,ind)=P(iii);%相位排序的航班号
                        Queue_flights(Ysize+1,2,ind)=Daodat(P(iii),index3(P(iii))-1);%相位排序航班的初始到达时间
                        Queue_flights(Ysize+1,3,ind)=YXJ(YXJ(:,1)==P(iii),2);%需要排序航班的优先级
                    end
                else
                    %如果对应相位，在到达之前已有排队航班，需排队，否则直接通过
                    if  isempty(Queue_flights)==0 && ind<=size(Queue_flights,3) && sum(sum(Queue_flights(:,:,ind)))~=0
                        Ysize=size(Queue_flights,1);%时间t时，矩阵的行数，注意其中可能有全0行
                        Queue_flights(Ysize+1,1,ind)=P(iii);%相位排序的航班号
                        Queue_flights(Ysize+1,2,ind)=Daodat(P(iii),index3(P(iii))-1);%相位排序航班的初始到达时间
                        Queue_flights(Ysize+1,3,ind)=YXJ(YXJ(:,1)==P(iii),2);%需要排序航班的优先级
                    else
                        Likait(P(iii),index3(P(iii))-1)=round(Daodat(P(iii),index3(P(iii))-1));
                        Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);%记录到达下一节点的时间
                    end
                    [xzk,~]=find(XZK==Luxian_Intersection(P(iii),max(index3(P(iii))-1,1))) ;             %所要通过的冲突口
                    if LKXZ_Time(xzk,1)~=0
                        Likait(P(iii),index3(P(iii))-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Daodat(P(iii),index3(P(iii))-1)));%离开时间应为 max（前一航班离开时间+安全间隔，原离开时间）
                        Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);%记录到达下一节点的时间
                    end
                    LKXZ_Time(xzk,1)= max(Likait(P(iii),index3(P(iii))-1) ,LKXZ_Time(xzk,1));%航班离开交叉点的时间记录
                end
            elseif isempty(find(Luxian_Intersection(P(iii),:)==Shidian_Zhongdian(P(iii),3), 1))==1 && StateCharge(StateCharge(:,1)==P(iii),2)<=0.16 && Flight(P(iii),2)==1 && (Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))<=16 || Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))>=46) %若到达某一交叉点时电量小于0.1，走应急程序
                [NextPoint,NextT]=Shortest_path(JT_YJ,JT_YJ,Luxian_Intersection(P(iii),index3(P(iii))),Shidian_Zhongdian(P(iii),3));%【最短路径函数】输入当前点和终点，获得下一运行交叉点的索引，及到达该点长度
                index3(P(iii))= index3(P(iii))+1;
                Luxian_Intersection(P(iii),index3(P(iii)))=NextPoint;%记录下一交叉口点
                %                 Luxian_Road(P(iii),index3(P(iii)))=Intersection_Luhao(Luxian_Intersection(P(iii),index3(P(iii))-1),Luxian_Intersection(P(iii),index3(P(iii))) );%下一路号
                Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);%记录到达下一节点的时间
                [xzk,~]=find(XZK==Luxian_Intersection(P(iii),max(index3(P(iii))-1,1))) ;             %所要通过的冲突口
                if LKXZ_Time(xzk,1)~=0
                    Likait(P(iii),index3(P(iii))-1)=round(max(LKXZ_Time(xzk,1)+20,Daodat(P(iii),index3(P(iii))-1)));%离开时间应为 max（前一应急航班离开时间+20，原离开时间）
                else
                    Likait(P(iii),index3(P(iii))-1)=round(Daodat(P(iii),index3(P(iii))-1));%不需要排队，直接通过
                end
                Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);%记录到达下一节点的时间
                LKXZ_Time(xzk,1)= max(Likait(P(iii),index3(P(iii))-1) ,LKXZ_Time(xzk,1));%航班离开交叉点的时间记录
            else  %当 当前节点为该航班终点,
                index3(P(iii))= index3(P(iii))+1;
                Luxian_Road(P(iii),index3(P(iii)))=200;
                
                [xzk,~]=find(XZK==Shidian_Zhongdian(P(iii),3)) ;%所要通过的冲突口（终点）
                end1=find(Daodat(P(iii),:)~=0, 1, 'last' );
                if LKXZ_Time(xzk,1)~=0 & StateCharge(StateCharge(:,1)==P(iii),2)>0.1
                    Likait(P(iii),index3(P(iii))-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Daodat(P(iii),end1)));%离开时间应为 max（前一航班离开时间+安全间隔，原离开时间）
                    Flight_Stop(P(iii),2)=Flight_Stop(P(iii),2)+1;%悬停次数 %统计排队航班的停车次数、停车时间
                    Flight_Stop(P(iii),3)=Flight_Stop(P(iii),3)+(Likait(P(iii),index3(P(iii))-1)-Daodat(P(iii),end1));%悬停时间
                else
                    Likait(P(iii),index3(P(iii))-1)=Daodat(P(iii),end1);
                end
                LKXZ_Time(xzk,1)= max(Likait(P(iii),index3(P(iii))-1) ,LKXZ_Time(xzk,1));%航班离开交叉点的时间记录
            end
        end
    end
    %----------------------------------------------------------------------------------------------已得到需要进行排序的航班
    if mod(t,TP)==0 || mod(t,TP)==60 %在周期末进行航班排序。在周期末计算道路排队长度，作为下一周期初的排队长度
        for s=1:size(Queue_flights,3)%在各交叉口，对当前时间需要排序的航班进行排序，生成其离开相应交叉口的时间
            if sum(sum(Queue_flights(:,:,s)))~=0
                Qf= Queue_flights(:,:,s);
                Qf(all(Qf==0,2),:)=[];
                %             a(all(a==0,2),:) = [];%删除某行均为0的行
                %---------------航路i上排队的飞行器数量、航路i到航路j的转弯概率
                for z=1:size(Qf,1)
                    for r=1:size(Roadcapacity,1)
                        for c=1:size(Roadcapacity,1)  %-航路i去往航路j的排队航班的数量----转弯概率
                            [~,~,FlightSum]=find((Luxian_Road(Qf(z,1),index3(Qf(z,1))-1)==r) & ((Luxian_Road(Qf(z,1),index3(Qf(z,1)))==c)));
                            JUZHEN_Road_Queue(r,c,tp+1)=JUZHEN_Road_Queue(r,c,tp+1)+ sum(FlightSum);%航路r到航路c的排队数量
                        end
                        [~,~,QueueSum]=find((Luxian_Road(Qf(z,1),index3(Qf(z,1))-1)==r));
                        JUZHEN_Road_ZQueue(r,tp+1)=JUZHEN_Road_ZQueue(r,tp+1)+sum(QueueSum);
                    end
                end
                %-------------------------------------------------------------------------------
                [Intersaction_JG,Airport_JG]=JG_function(size(Qf,1));%生成交叉口间隔和起降场间隔
                ind2=s;
%                 ind2=find(Phase_Road(Luxian_Road(Qf(1,1),index3(Qf(1,1))-1),Luxian_Road(Qf(1,1),index3(Qf(1,1))),:)==1);%对应的相位
                if mod(JZPhase_GreenST(tp,ind2),TP)==0
                    ind2_GS=JZPhase_GreenST(tp+1,ind2);%若，该相位的绿灯时间是从每个周期初开始的，对应相位的绿灯开始时间
                    [Flight_Paixu,Shijian]=Acomain(Qf,Intersaction_JG,ind2_GS);%【蚁群排序】输入第i交叉口的待排序航班、间隔矩阵、第i交叉口在第tp时间段的绿灯开始时间
                    for k=1:size(Flight_Paixu,2)
                        xh1=Flight_Paixu(1,k);
                        if Shijian(k)>ind2_GS+JUZHEN_Phase_GreenTime(tp+1,ind2)%如果排队后的离开时间大于绿灯截止的时间，需要继续等待
                            Y_Daodat=Daodat(xh1,index3(xh1)-1);
                            Daodat(xh1,index3(xh1)-1)=(tp+1) *TP+1;              %将其到达时间视为下一周期的绿灯开始时间。
                            Daodat(xh1,index3(xh1):size(Daodat,2))=0;
                            Flight_Stop(xh1,2)=Flight_Stop(xh1,2)+1;%悬停次数 %统计排队航班的停车次数、停车时间
                            Flight_Stop(xh1,3)=Flight_Stop(xh1,3)+abs((Daodat(xh1,index3(xh1)-1)-Y_Daodat));%悬停时间!!
                            index3(xh1,1)= sum(Daodat(xh1,:)~=0);
                        else
                            [xzk,~]=find(XZK==Luxian_Intersection(xh1,max(index3(xh1)-1,1))) ;             %所要通过的冲突口
                            if LKXZ_Time(xzk,1)~=0
                                Likait(xh1,index3(xh1)-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Shijian(k)));%离开时间应为 max（前一航班离开时间+60，原离开时间）
                            else
                                Likait(xh1,index3(xh1)-1)=round(Shijian(k));
                            end
                            Daodat(xh1,index3(xh1))=max(round(Likait(xh1,index3(xh1)-1)+ NextT),t+1);%记录到达下一节点的时间
                            LKXZ_Time(xzk,1)= max(Likait(xh1,index3(xh1)-1) ,LKXZ_Time(xzk,1));%航班离开交叉点的时间记录
                            Flight_Stop(xh1,2)=Flight_Stop(xh1,2)+1;%悬停次数 %统计排队航班的停车次数、停车时间
                            Flight_Stop(xh1,3)=Flight_Stop(xh1,3)+(Likait(xh1,index3(xh1)-1)-Daodat(xh1,index3(xh1)-1));%悬停时间
                        end
                        
                    end
                else
                    if Qf(1,2)>JZPhase_GreenST(tp,ind2)
                        ind2_GS=JZPhase_GreenST(tp+1,ind2);%对应相位的绿灯开始时间
                    else
                        ind2_GS=JZPhase_GreenST(tp,ind2);
                    end
                    [Flight_Paixu,Shijian]=Acomain(Qf,Intersaction_JG,ind2_GS);%【蚁群排序】输入第i交叉口的待排序航班、间隔矩阵、第i交叉口在第tp时间段的绿灯开始时间
                    for k=1:size(Flight_Paixu,2)
                        xh=Flight_Paixu(1,k);
                        if Shijian(k)>ind2_GS+JUZHEN_Phase_GreenTime(tp+1,ind2)%如果排队后的离开时间大于绿灯转红灯的时间，需要继续等待
                            Y_Daodat1=Daodat(xh,index3(xh)-1);
                            Daodat(xh,index3(xh)-1)=round(JZPhase_GreenST(tp+1,ind2))+1;              %将其到达时间视为下一周期的绿灯开始时间
                            Flight_Stop(xh,2)=Flight_Stop(xh,2)+1;%悬停次数 %统计排队航班的停车次数、停车时间
                            Flight_Stop(xh,3)=Flight_Stop(xh,3)+(Daodat(xh,index3(xh)-1)-Y_Daodat1);%悬停时间
                            index3(xh,1)= sum(Daodat(xh,:)~=0);
                        else
                            [xzk,~]=find(XZK==Luxian_Intersection(xh,max(index3(xh)-1,1))) ;             %所要通过的限制口
                            if LKXZ_Time(xzk,1)~=0
                                Likait(xh,index3(xh)-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Shijian(k)));%离开时间应为 max（前一航班离开时间+60，原离开时间）
                            else
                                Likait(xh,index3(xh)-1)=round(Shijian(k));
                            end
                            Daodat(xh,index3(xh))=max(round(Likait(xh,index3(xh)-1)+ NextT),t+1);%记录到达下一节点的时间
                            LKXZ_Time(xzk,1)= max(Likait(xh,index3(xh)-1) ,LKXZ_Time(xzk,1));%航班离开交叉点的时间记录
                            Flight_Stop(xh,2)=Flight_Stop(xh,2)+1;%悬停次数
                            Flight_Stop(xh,3)=Flight_Stop(xh,3)+(Likait(xh,index3(xh)-1)-Daodat(xh,index3(xh)-1));%悬停时间
                        end
                        %---------------统计排队航班的停车次数、停车时间
                        
                    end
                end
                
            end
        end
        Queue_flights=[];
    end
    if mod(t,TP)==0
        %---------------------------------------------------更新转弯概率
        Now_NextRoad=zeros(size(Flight,1),2);ZhuanWanP=ZhuanWanP_Y;
        for fi=1:size(Likait,1)  %得到各航班当前所在道路的标号
            X=Likait(fi,:);
            max_solve=find(X~=0, 1, 'last' );
            if sum(max_solve)~=0 && Likait(fi,max_solve)<=t
                Now_NextRoad(fi,1)=Luxian_Road(fi,index3(fi));
            elseif sum(max_solve)~=0 && Likait(fi,max_solve)>t %最后一个离开时间 大于等于 当前时间t
                Now_NextRoad(fi,1)=Luxian_Road(fi,max(index3(fi)-1,1));
                Now_NextRoad(fi,2)=Luxian_Road(fi,index3(fi));
            elseif sum(max_solve)==0
                Now_NextRoad(fi,1)= Luxian_Road(fi,index3(fi));
            end
        end
        for ai=1:size(Roadcapacity,1)  %航路的容量限制
            JUZHEN_Road_Zliuliang(ai,tp+1)=length(find(Now_NextRoad(:,1)==ai));
            JUZHEN_Road_Zliuliang(ai,tp+2)=length(find(Now_NextRoad(:,2)==ai));
            SJ=[];
            if tp>1 && JUZHEN_Road_Zliuliang(ai,tp+1)>Roadcapacity(ai,2)%从第二周期开始判断，如果路段总流量超过了容量
                [Flightrow,~]=find(Now_NextRoad(:,1)==ai);%找到当前在这条路上的航班，并排列
                [Qdian,~]=find(Intersection_Luhao==ai);%ai道路的前序节点 
                [Raw,Col]=find(Luxian_Intersection(Flightrow,:)==Qdian);F=Flightrow(Raw); %前序节点在对应相应航班的 第几个 路线节点
                for fli=1:size(F,1)
                    for flj=1:size(Col,2)
                        SJ=[SJ;Daodat(F(fli),Col(flj))];
                    end
                end
                PX_flight=[F SJ];PX_flight=sortrows(PX_flight,2);%排序
                for fl=(Roadcapacity(ai,2)+1):(JUZHEN_Road_Zliuliang(ai,tp+1))%对超过容量的航班进行到达点更新
                    [~,Col1]=find(Luxian_Intersection(PX_flight(fl,1),:)==Qdian);%对应路线节点             
                    y1=Daodat(PX_flight(fl,1),Col1);%原来 该航班到达该点的时间
                    Daodat(PX_flight(fl,1),Col1)=max(tp*TP+1,y1);
                    x1=Daodat(PX_flight(fl,1),Col1)-y1;%差距
                    if x1~=0
                        Daodat(PX_flight(fl,1),Col1+1:size(Daodat,2))=0;Likait(PX_flight(fl,1),Col1:size(Likait,2))=0;Luxian_Intersection(PX_flight(fl,1),Col1+1:size(Luxian_Intersection,2))=0;
                        [~,Col2]=find(Luxian_Road(PX_flight(fl,1),:)==ai);Luxian_Road(PX_flight(fl,1),max(Col2,2):size(Luxian_Road,2))=0;%回到路段的前序节点
                        index3(PX_flight(fl,1))=sum(Daodat(PX_flight(fl,1),:)~=0);
                        Flight_Stop(PX_flight(fl,1),3)=Flight_Stop(PX_flight(fl,1),2)+x1;                      %更新悬停时间
                        Flight_Stop(PX_flight(fl,1),2)=Flight_Stop(PX_flight(fl,1),2)+1;                       %更新悬停次数
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
    
    t=t+TimeGap;%时间步长
end
%% 输出结果
JS_Time=zeros(size(Likait,1),1);
for sj=1:size(Likait,1)
    nling=find(Likait(sj,:)~=0,1,'last');
    JS_Time(sj,1)=Likait(sj,nling);%改成likait
end
 [JS_StateCharge,~]=get_StateCharge(JS_Time,Flight,Xuhang,Daodat,Sheet_YXJ1,Sheet_YXJ2,Sheet_YXJ3);
 
 %终端区的利用率
%  ZD_liuliang=zeros(1,Zong_tp);
%  for hb=1:size(Flight,1)
%      JR=ceil(Daodat(hb,1)/TP);
%      LK=ceil(JS_Time(hb,1)/TP);
%      for tpi=JR:LK
%          ZD_liuliang(1,tpi)=ZD_liuliang(1,tpi)+1;%各时段的终端区总流量
%      end
%  end
%  Liyong= ZD_liuliang./sum(Roadcapacity(1:102,2));
 
 %------------------------冲突点-内层环层设置冲突点----------自适应内层8个大交叉口，传统9-16
  CTK_Time=zeros(size(CTK,1),size(Flight,1));
 for cti=1:size(CTK,1)
     for ctj=1:sum(~isnan(CTK(cti,:)))
         [NumF,NumInt]=find(Luxian_Intersection==CTK(cti,ctj)); %找到经过点CTK(cti,ctj)的航班号与列数
         for fi=1:length(NumF)
            A=Likait(NumF(fi),NumInt(fi));
            CTK_Time(cti,NumF(fi))= A;      %将时间放在第cti行冲突口
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
            if jg<20 %当经过该点间隔小于60，触发报警机制
                CTBJ=CTBJ+1;%计算报警次数
            end
        end
    end
end
XT_Time=zeros(size(Flight,1),1);
%预计跑道时间及悬停/地面等待时间
YJJS_Time=zeros(size(Flight,1),1);                    %各航班，的预计结束时间，即位于离开终端区时的时间
for hb=1:size(Flight,1)
        YJJS_Time(hb,1)=Flight(hb,5);
        LX=Luxian_Intersection(hb,:);
        LX(LX==0)=[];
        for lx=1:(size(LX,2)-1)
            YJJS_Time(hb,1)=YJJS_Time(hb,1)+max(JT_Z(Luxian_Intersection(hb,lx),Luxian_Intersection(hb,lx+1)),JT_YJ(Luxian_Intersection(hb,lx),Luxian_Intersection(hb,lx+1)));
        end
        XT_Time(hb,1)=max(0,round(JS_Time(hb,1)-YJJS_Time(hb,1)));
end
%----------------各机场平均起降间隔----------------------------
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
%-------------------------关于航班离开的时间间隔-作图-----------
% JR_SJ=zeros(1,max(JS_Time));%进入终端区时间的累计航班数量
% LK_SJ=zeros(1,max(JS_Time));%离开终端区时间的累计航班数量
% for tt=1:max(JS_Time)
%     [JR_Row,~]=find(Flight(:,5)<=tt);
%     JR_SJ(1,tt)=length(JR_Row);
%     [LK_Row,~]=find(JS_Time<=tt);
%     LK_SJ(1,tt)=length(LK_Row);
% end
% 
% tt=1:max(JS_Time);
% plot(tt,JR_SJ,tt,LK_SJ); 
 