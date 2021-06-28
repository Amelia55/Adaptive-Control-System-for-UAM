%Flight control real-time simulation framework in the terminal area
clear all;close all;clc
%% 数据输入
TP=120;%Time period TP
t=1;
TimeGap=1;%The time step
tmax=60000;%The time at which the simulation ended
Zong_tp=tmax/TP;
Xuhang=1;%Duration
n=20;safetyJG=60;
JT=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','JT');%The air route network of the terminal area
JT_Z=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','JT_Z');
JT_YJ=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','JT_YJ');%Emergency layer in the terminal area

Flight=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\自适应系统的比较\随机到达\Case8\Terminal area traffic network8.xlsx','Flight');
Intersection_Luhao=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','Intersection_Luhao');%The correspondence between the intersection and the road number
JUZHEN_Baohe_Speed=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','Baohe_Speed');%Saturation speed
Roadcapacity = xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','Roadcapacity');
Intersection_Phase=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Intersection_Phase.xlsx');%The correspondence between the intersection and the phase
Sheet_YXJ1=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Youxianji.xlsx','R=1');%SOC10%-40%
Sheet_YXJ2=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Youxianji.xlsx','R=2');%SOC40%-70%
Sheet_YXJ3=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Youxianji.xlsx','R=3');%SOC70%-100%
CTK=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','冲突口');%Conflict point
XZK=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','限制口');%The limit point
JUZHEN_Road_Zliuliang=zeros(size(Roadcapacity,1),Zong_tp);%The route flow at each time period
ZhuanWanP_Y=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Terminal area traffic network原.xlsx','ZhuanWanP_Y');%The initial value of the turn probability
[Type,Sheet,Fromat]=xlsfinfo('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\TrafficLight.xlsx');
Phase_Road=zeros(size(Roadcapacity,1),size(Roadcapacity,1),length(Sheet));
JUZHEN_GreenTime=zeros(size(Roadcapacity,1),size(Roadcapacity,1),Zong_tp);%Green Time
JZPhase_GreenST=zeros(Zong_tp,size(Phase_Road,3));%The green light start time for each phase during each period
LKXZ_Time=zeros(size(XZK,1),1);
JT(isnan(JT))=0;
JT_YJ(isnan(JT_YJ))=0;
ZhuanWanP_Y(isnan(ZhuanWanP_Y))=0;
%--------------get_LightControl
JUZHEN_Road_ZQueue=zeros(size(Roadcapacity,1),Zong_tp);
JUZHEN_pressure=zeros(size(Roadcapacity,1),size(Roadcapacity,1),Zong_tp);
JUZHEN_weight=zeros(Zong_tp,size(Phase_Road,3));%
JUZHEN_bili=zeros(Zong_tp,size(Phase_Road,3));%The proportion of green light time
JUZHEN_RemainingCapacity=zeros(size(Roadcapacity,1),Zong_tp);%The remaining flow of the segment during each period
JUZHEN_Phase_GreenTime=zeros(Zong_tp,size(Phase_Road,3));
JUZHEN_Phase_GreenTime(1,:)=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\Phase_GreenTime.xlsx');%tp=1, The initial value of the green light time
%----------------------- Update of the route resistance
JUZHEN_Intersection_liuliang=zeros(size(JT,1),size(JT,2),Zong_tp);
JZ_Road_AveLiuliang=zeros(size(Roadcapacity,1),Zong_tp);%Average flow on each road
JZ_Road_Baohedu=zeros(size(Roadcapacity,1),Zong_tp);%Saturation
JUZHEN_Intersection_baohedu=zeros(size(JT,1),size(JT,2),Zong_tp);
%---------------------------------------------------------
for i=1:length(Sheet)
Phase_Road(:,:,i)=xlsread('C:\Users\Administrator.DESKTOP-7UUHJUA\Desktop\DATA\TrafficLight.xlsx',num2str(i));%Phase p controls the segment, with a value of 1, otherwise 0
end
XH=Flight(:,1);%Flight serial number
JL=Flight(:,2);%approach/departure
JC=Flight(:,3);%vertiport
XTBJ=Flight(:,4);%Enter the boundary point of MVS-TA
CS=Flight(:,5);%Time to enter MVS-TA


Daodat=zeros(length(XH),n);%Record when each node is reached
Likait=zeros(length(XH),n);%The time to leave each node
Shidian_Zhongdian=zeros(size(Flight,1),3);%The initial point and end point
Shidian_Zhongdian(:,1)=(1:size(Flight,1));
JUZHEN_Road_Queue=zeros(size(Roadcapacity,1),size(Roadcapacity,1),Zong_tp);
ZhuanWanP=zeros(size(Roadcapacity,1),size(Roadcapacity,1));%Turn probability
JUZHEN_luzu=zeros(size(JT,1),size(JT,2),Zong_tp);%Road resistance
Flight_Stop=zeros(size(Flight,1),3);
Flight_Stop(:,1)=Flight(:,1);
JUZHEN_luzu(:,:,1)= JT;
Queue_flights=[];

%% Generate the start-end matrix for each flight, initialize the flight path, and the green light time for each segment
for  ii=1:length(XH)
    if JL(ii)==1%----------------------------------------------------approach
        Shidian_Zhongdian(ii,2)=XTBJ(ii);
        Shidian_Zhongdian(ii,3)=JC(ii);
    else%---------------------------------------------------------departure
        Shidian_Zhongdian(ii,2)=JC(ii);
        Shidian_Zhongdian(ii,3)=XTBJ(ii);
    end
end
index3=zeros(length(XH),1);
Luxian_Intersection=zeros(length(XH),n);
Luxian_Road=zeros(length(XH),n);
for j=1:length(XH)
    index3(j,1)=1;
    NextT=CS(j);
    Luxian_Intersection(j,index3(j))=Shidian_Zhongdian(j,2); 
    Luxian_Road(j,index3(j))=Flight(j,8);
    Daodat(j,index3(j))=NextT;
end
%--------------------------------------------------------------------------------------The initial green light time for each section of the first cycle
m=size(Phase_Road,1);
n=size(Phase_Road,2);
kkk=find(Phase_Road);
RoadRaw=rem(rem((kkk-1),m*n),m)+1;
RoadColumn=fix(rem((kkk-1),(m*n))/m)+1;
RoadPage=fix((kkk-1)/(m*n))+1;
for gg=1:size(RoadRaw,1)
    JUZHEN_GreenTime(RoadRaw(gg),RoadColumn(gg))=JUZHEN_Phase_GreenTime(1,RoadPage(gg));   
end
  
for rl=1:size(Roadcapacity,1)
    JUZHEN_Road_Zliuliang(rl,1)=length(find(Flight(:,8)==rl));
end

%%  simulation
while t<=tmax
    tp=ceil(t/TP);
    %---------------------------------------------------------------------------------Update the flight's battery status
    FlightCharge=[];
    Now_time=[];
    for sf=1:size(Flight,1)
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
    %---------------------------------------------------------------------------------------Update the green time
    if tp<Zong_tp && mod(t,TP)==1 %Update the next cycle from the beginning of the cycle
        [JUZHEN_GreenTime,JUZHEN_bili,JUZHEN_Phase_GreenTime,JZPhase_GreenST,JUZHEN_pressure,JUZHEN_weight]=get_LightControl(t,JUZHEN_Road_Queue,Roadcapacity,JUZHEN_Baohe_Speed,TP,Zong_tp,Phase_Road,ZhuanWanP,JUZHEN_GreenTime,Intersection_Phase,JUZHEN_Road_ZQueue,JUZHEN_pressure,JUZHEN_weight,JUZHEN_bili,JUZHEN_Phase_GreenTime,JZPhase_GreenST);%更新（i，j）的绿色通行时间
        if tp~=1
            [JUZHEN_luzu,JZ_Road_AveLiuliang,JZ_Road_Baohedu,JUZHEN_Intersection_baohedu] = get_luzu(JUZHEN_luzu,JUZHEN_Road_Zliuliang,tp,Intersection_Luhao,JT,JZ_Road_AveLiuliang,Zong_tp,Roadcapacity,JZ_Road_Baohedu,JUZHEN_Intersection_baohedu);%每到达一个交叉口，更新【路阻】
        end
    end
    %----------------------------------------------------------------------Queued flight
    equal_index=ismember(Daodat,t);
    if sum(sum(equal_index))~=0  
        [TrueRaw,TrueColumn]=find(equal_index==1);
        flight_index=XH(TrueRaw);
        P=flight_index;
        for iii=1:length(P)
            if isempty(find(Luxian_Intersection(P(iii),:)==Shidian_Zhongdian(P(iii),3), 1))==1 && StateCharge(StateCharge(:,1)==P(iii),2)>0.16 &&( Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))>16 || Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))<46) %未到终点
                [NextPoint,NextT]=Shortest_path(JUZHEN_luzu(:,:,tp),JT,Luxian_Intersection(P(iii),index3(P(iii))),Shidian_Zhongdian(P(iii),3));%Shortest path planning
                index3(P(iii))= index3(P(iii))+1;
                Luxian_Intersection(P(iii),index3(P(iii)))=NextPoint;%Next intersection
                Luxian_Road(P(iii),index3(P(iii)))=Intersection_Luhao(Luxian_Intersection(P(iii),index3(P(iii))-1),Luxian_Intersection(P(iii),index3(P(iii))) );%next road
                %---------------------------------------------------------Determine whether the flight needs to be sorted.
                ind=find(Phase_Road(Luxian_Road(P(iii),index3(P(iii))-1),Luxian_Road(P(iii),index3(P(iii))),:)==1);
                G2R=JZPhase_GreenST(tp,ind)+JUZHEN_Phase_GreenTime(tp,ind); 
                GS=JZPhase_GreenST(tp,ind);
                if (t>=G2R||t<JZPhase_GreenST(tp,ind)) && t<=tp*TP     
                    %----------------------------------------------Queue_flights
                    if sum(sum(sum(Queue_flights)))==0
                        Queue_flights(1,1, ind)=P(iii);
                        Queue_flights(1,2, ind)=Daodat(P(iii),index3(P(iii))-1);
                        Queue_flights(1,3, ind)=YXJ(YXJ(:,1)==P(iii),2);
                    else
                        Ysize=size(Queue_flights,1);
                        Queue_flights(Ysize+1,1,ind)=P(iii);
                        Queue_flights(Ysize+1,2,ind)=Daodat(P(iii),index3(P(iii))-1);%
                        Queue_flights(Ysize+1,3,ind)=YXJ(YXJ(:,1)==P(iii),2);%Priority of the flights
                    end
                else
                    %Queue flight=0,pass;Queueflight>0,wait and queue
                    if  isempty(Queue_flights)==0 && ind<=size(Queue_flights,3) && sum(sum(Queue_flights(:,:,ind)))~=0
                        Ysize=size(Queue_flights,1);
                        Queue_flights(Ysize+1,1,ind)=P(iii);
                        Queue_flights(Ysize+1,2,ind)=Daodat(P(iii),index3(P(iii))-1);
                        Queue_flights(Ysize+1,3,ind)=YXJ(YXJ(:,1)==P(iii),2);%Priority of the flights
                    else
                        Likait(P(iii),index3(P(iii))-1)=round(Daodat(P(iii),index3(P(iii))-1));
                        Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);
                    end
                    [xzk,~]=find(XZK==Luxian_Intersection(P(iii),max(index3(P(iii))-1,1))) ;          
                    if LKXZ_Time(xzk,1)~=0
                        Likait(P(iii),index3(P(iii))-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Daodat(P(iii),index3(P(iii))-1)));%The time of leaving
                        Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);%The time at which the next node will be reached
                    end
                    LKXZ_Time(xzk,1)= max(Likait(P(iii),index3(P(iii))-1) ,LKXZ_Time(xzk,1));
                end
            elseif isempty(find(Luxian_Intersection(P(iii),:)==Shidian_Zhongdian(P(iii),3), 1))==1 && StateCharge(StateCharge(:,1)==P(iii),2)<=0.16 && Flight(P(iii),2)==1 && (Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))<=16 || Luxian_Intersection(P(iii),find(Luxian_Intersection(P(iii),:)~=0, 1, 'last' ))>=46) %若到达某一交叉点时电量小于0.1，走应急程序
                [NextPoint,NextT]=Shortest_path(JT_YJ,JT_YJ,Luxian_Intersection(P(iii),index3(P(iii))),Shidian_Zhongdian(P(iii),3));%Shortest path planning
                index3(P(iii))= index3(P(iii))+1;
                Luxian_Intersection(P(iii),index3(P(iii)))=NextPoint;
             
                Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);
                [xzk,~]=find(XZK==Luxian_Intersection(P(iii),max(index3(P(iii))-1,1))) ;             
                if LKXZ_Time(xzk,1)~=0
                    Likait(P(iii),index3(P(iii))-1)=round(max(LKXZ_Time(xzk,1)+20,Daodat(P(iii),index3(P(iii))-1)));
                else
                    Likait(P(iii),index3(P(iii))-1)=round(Daodat(P(iii),index3(P(iii))-1));
                end
                Daodat(P(iii),index3(P(iii)))=round(Likait(P(iii),index3(P(iii))-1)+ NextT);
                LKXZ_Time(xzk,1)= max(Likait(P(iii),index3(P(iii))-1) ,LKXZ_Time(xzk,1));
            else  %When the current node is the end point of the flight,
                index3(P(iii))= index3(P(iii))+1;
                Luxian_Road(P(iii),index3(P(iii)))=200;
                
                [xzk,~]=find(XZK==Shidian_Zhongdian(P(iii),3)) ;
                end1=find(Daodat(P(iii),:)~=0, 1, 'last' );
                if LKXZ_Time(xzk,1)~=0 & StateCharge(StateCharge(:,1)==P(iii),2)>0.1
                    Likait(P(iii),index3(P(iii))-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Daodat(P(iii),end1)));
                    Flight_Stop(P(iii),2)=Flight_Stop(P(iii),2)+1;
                    Flight_Stop(P(iii),3)=Flight_Stop(P(iii),3)+(Likait(P(iii),index3(P(iii))-1)-Daodat(P(iii),end1));
                else
                    Likait(P(iii),index3(P(iii))-1)=Daodat(P(iii),end1);
                end
                LKXZ_Time(xzk,1)= max(Likait(P(iii),index3(P(iii))-1) ,LKXZ_Time(xzk,1));
            end
        end
    end
    %----------------------------------------------------------------------------------------------Scheduling at intersections
    if mod(t,TP)==0 || mod(t,TP)==60 
        for s=1:size(Queue_flights,3)
            if sum(sum(Queue_flights(:,:,s)))~=0
                Qf= Queue_flights(:,:,s);
                Qf(all(Qf==0,2),:)=[];
                for z=1:size(Qf,1)
                    for r=1:size(Roadcapacity,1)
                        for c=1:size(Roadcapacity,1)  
                            [~,~,FlightSum]=find((Luxian_Road(Qf(z,1),index3(Qf(z,1))-1)==r) & ((Luxian_Road(Qf(z,1),index3(Qf(z,1)))==c)));
                            JUZHEN_Road_Queue(r,c,tp+1)=JUZHEN_Road_Queue(r,c,tp+1)+ sum(FlightSum);
                        end
                        [~,~,QueueSum]=find((Luxian_Road(Qf(z,1),index3(Qf(z,1))-1)==r));
                        JUZHEN_Road_ZQueue(r,tp+1)=JUZHEN_Road_ZQueue(r,tp+1)+sum(QueueSum);
                    end
                end
                %-------------------------------------------------------------------------------
                [Intersaction_JG,Airport_JG]=JG_function(size(Qf,1),safetyJG);%Intersection interval and take-off and landing interval
                ind2=s;
                if mod(JZPhase_GreenST(tp,ind2),TP)==0
                    ind2_GS=JZPhase_GreenST(tp+1,ind2);
                    [Flight_Paixu,Shijian]=Acomain(Qf,Intersaction_JG,ind2_GS);%ACO
                    for k=1:size(Flight_Paixu,2)
                        xh1=Flight_Paixu(1,k);
                        if Shijian(k)>ind2_GS+JUZHEN_Phase_GreenTime(tp+1,ind2)
                            Y_Daodat=Daodat(xh1,index3(xh1)-1);
                            Daodat(xh1,index3(xh1)-1)=(tp+1) *TP+1;              
                            Daodat(xh1,index3(xh1):size(Daodat,2))=0;
                            Flight_Stop(xh1,2)=Flight_Stop(xh1,2)+1;
                            Flight_Stop(xh1,3)=Flight_Stop(xh1,3)+abs((Daodat(xh1,index3(xh1)-1)-Y_Daodat));
                            index3(xh1,1)= sum(Daodat(xh1,:)~=0);
                        else
                            [xzk,~]=find(XZK==Luxian_Intersection(xh1,max(index3(xh1)-1,1))) ;           
                            if LKXZ_Time(xzk,1)~=0
                                Likait(xh1,index3(xh1)-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Shijian(k)));
                            else
                                Likait(xh1,index3(xh1)-1)=round(Shijian(k));
                            end
                            Daodat(xh1,index3(xh1))=max(round(Likait(xh1,index3(xh1)-1)+ NextT),t+1);
                            LKXZ_Time(xzk,1)= max(Likait(xh1,index3(xh1)-1) ,LKXZ_Time(xzk,1));
                            Flight_Stop(xh1,2)=Flight_Stop(xh1,2)+1;
                            Flight_Stop(xh1,3)=Flight_Stop(xh1,3)+(Likait(xh1,index3(xh1)-1)-Daodat(xh1,index3(xh1)-1));
                        end
                        
                    end
                else
                    if Qf(1,2)>JZPhase_GreenST(tp,ind2)
                        ind2_GS=JZPhase_GreenST(tp+1,ind2);%The start time of the green light corresponding to the phase
                    else
                        ind2_GS=JZPhase_GreenST(tp,ind2);
                    end
                    [Flight_Paixu,Shijian]=Acomain(Qf,Intersaction_JG,ind2_GS);
                    for k=1:size(Flight_Paixu,2)
                        xh=Flight_Paixu(1,k);
                        if Shijian(k)>ind2_GS+JUZHEN_Phase_GreenTime(tp+1,ind2)
                            Y_Daodat1=Daodat(xh,index3(xh)-1);
                            Daodat(xh,index3(xh)-1)=round(JZPhase_GreenST(tp+1,ind2))+1;             
                            Flight_Stop(xh,2)=Flight_Stop(xh,2)+1;
                            Flight_Stop(xh,3)=Flight_Stop(xh,3)+(Daodat(xh,index3(xh)-1)-Y_Daodat1);%Hovering time
                            index3(xh,1)= sum(Daodat(xh,:)~=0);
                        else
                            [xzk,~]=find(XZK==Luxian_Intersection(xh,max(index3(xh)-1,1))) ;            
                            if LKXZ_Time(xzk,1)~=0
                                Likait(xh,index3(xh)-1)=round(max(LKXZ_Time(xzk,1)+safetyJG,Shijian(k)));
                            else
                                Likait(xh,index3(xh)-1)=round(Shijian(k));
                            end
                            Daodat(xh,index3(xh))=max(round(Likait(xh,index3(xh)-1)+ NextT),t+1);
                            LKXZ_Time(xzk,1)= max(Likait(xh,index3(xh)-1) ,LKXZ_Time(xzk,1));
                            Flight_Stop(xh,2)=Flight_Stop(xh,2)+1;
                            Flight_Stop(xh,3)=Flight_Stop(xh,3)+(Likait(xh,index3(xh)-1)-Daodat(xh,index3(xh)-1));
                        end
                      
                        
                    end
                end
                
            end
        end
        Queue_flights=[];
    end
    if mod(t,TP)==0
        %---------------------------------------------------Update turn probability
        Now_NextRoad=zeros(size(Flight,1),2);ZhuanWanP=ZhuanWanP_Y;
        for fi=1:size(Likait,1)  %Get the label of the current road of each flight
            X=Likait(fi,:);
            max_solve=find(X~=0, 1, 'last' );
            if sum(max_solve)~=0 && Likait(fi,max_solve)<=t
                Now_NextRoad(fi,1)=Luxian_Road(fi,index3(fi));
            elseif sum(max_solve)~=0 && Likait(fi,max_solve)>t 
                Now_NextRoad(fi,1)=Luxian_Road(fi,max(index3(fi)-1,1));
                Now_NextRoad(fi,2)=Luxian_Road(fi,index3(fi));
            elseif sum(max_solve)==0
                Now_NextRoad(fi,1)= Luxian_Road(fi,index3(fi));
            end
        end
        for ai=1:size(Roadcapacity,1)  %Capacity limitation of air route
            JUZHEN_Road_Zliuliang(ai,tp+1)=length(find(Now_NextRoad(:,1)==ai));
            JUZHEN_Road_Zliuliang(ai,tp+2)=length(find(Now_NextRoad(:,2)==ai));
            SJ=[];
            if tp>1 && JUZHEN_Road_Zliuliang(ai,tp+1)>Roadcapacity(ai,2)
                [Flightrow,~]=find(Now_NextRoad(:,1)==ai);
                [Qdian,~]=find(Intersection_Luhao==ai);
                [Raw,Col]=find(Luxian_Intersection(Flightrow,:)==Qdian);F=Flightrow(Raw); 
                for fli=1:size(F,1)
                    for flj=1:size(Col,2)
                        SJ=[SJ;Daodat(F(fli),Col(flj))];
                    end
                end
                PX_flight=[F SJ];PX_flight=sortrows(PX_flight,2);
                for fl=(Roadcapacity(ai,2)+1):(JUZHEN_Road_Zliuliang(ai,tp+1))
                    [~,Col1]=find(Luxian_Intersection(PX_flight(fl,1),:)==Qdian);         
                    y1=Daodat(PX_flight(fl,1),Col1);
                    Daodat(PX_flight(fl,1),Col1)=max(tp*TP+1,y1);
                    x1=Daodat(PX_flight(fl,1),Col1)-y1;
                    if x1~=0
                        Daodat(PX_flight(fl,1),Col1+1:size(Daodat,2))=0;Likait(PX_flight(fl,1),Col1:size(Likait,2))=0;Luxian_Intersection(PX_flight(fl,1),Col1+1:size(Luxian_Intersection,2))=0;
                        [~,Col2]=find(Luxian_Road(PX_flight(fl,1),:)==ai);Luxian_Road(PX_flight(fl,1),max(Col2,2):size(Luxian_Road,2))=0;
                        index3(PX_flight(fl,1))=sum(Daodat(PX_flight(fl,1),:)~=0);
                        Flight_Stop(PX_flight(fl,1),3)=Flight_Stop(PX_flight(fl,1),2)+x1;                    
                        Flight_Stop(PX_flight(fl,1),2)=Flight_Stop(PX_flight(fl,1),2)+1;                       
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
    
    t=t+TimeGap;
end
%% Output result
JS_Time=zeros(size(Likait,1),1);
for sj=1:size(Likait,1)
    nling=find(Likait(sj,:)~=0,1,'last');
    JS_Time(sj,1)=Likait(sj,nling);
end
 [JS_StateCharge,~]=get_StateCharge(JS_Time,Flight,Xuhang,Daodat,Sheet_YXJ1,Sheet_YXJ2,Sheet_YXJ3);
 
 
 %------------------------The number of alarms at the conflicting port
  CTK_Time=zeros(size(CTK,1),size(Flight,1));
 for cti=1:size(CTK,1)
     for ctj=1:sum(~isnan(CTK(cti,:)))
         [NumF,NumInt]=find(Luxian_Intersection==CTK(cti,ctj)); 
         for fi=1:length(NumF)
            A=Likait(NumF(fi),NumInt(fi));
            CTK_Time(cti,NumF(fi))= A;     
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
            if jg<20 %20s
                CTBJ=CTBJ+1;
            end
        end
    end
end
XT_Time=zeros(size(Flight,1),1);

YJJS_Time=zeros(size(Flight,1),1);                    %The estimated end time of each flight, that is, the time when it is located when it leaves the terminal area.
for hb=1:size(Flight,1)
        YJJS_Time(hb,1)=Flight(hb,5);
        LX=Luxian_Intersection(hb,:);
        LX(LX==0)=[];
        for lx=1:(size(LX,2)-1)
            YJJS_Time(hb,1)=YJJS_Time(hb,1)+max(JT_Z(Luxian_Intersection(hb,lx),Luxian_Intersection(hb,lx+1)),JT_YJ(Luxian_Intersection(hb,lx),Luxian_Intersection(hb,lx+1)));
        end
        XT_Time(hb,1)=max(0,round(JS_Time(hb,1)-YJJS_Time(hb,1)));
end
%----------------Average take-off and landing intervals of each airport----------------------------
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
 