function[JUZHEN_Road_Zliuliang,JUZHEN_Road_Queue,JUZHEN_Road_ZQueue]=get_Road_ZLiuliangYC(JUZHEN_GreenTime,tp,Roadcapacity,JUZHEN_Baohe_Speed,JUZHEN_Road_Zliuliang,ZhuanWanP,JUZHEN_Road_Queue,JUZHEN_Road_ZQueue)

%-------------------------------------虚拟交警,航路流量的变化
JUZHEN_Baohe_Speed(isnan(JUZHEN_Baohe_Speed))=0;

% for ll=1:size(Roadcapacity)%第ll条路
%     for zz=1:size(Luxian_Road,1)%第zz个航班
%         if index3(zz)==1
%             [LRow,LColumn,LSum]=find((Luxian_Road(zz,index3(zz)))==ll);
%         else
%             [LRow,LColumn,LSum]=find((Luxian_Road(zz,index3(zz)-1))==ll);
%         end
%         JUZHEN_Road_Zliuliang(ll,tp)=JUZHEN_Road_Zliuliang(ll,tp)+sum(LSum);%t为周期初时，路段的总流量
%     end
% end

for ri=1:size(Roadcapacity,1)   %（i,j）表示链路i去向链路j，预测的排队数量
    Input_Queue=0;
    for rk=1:size(Roadcapacity,1)
        aa=JUZHEN_Baohe_Speed(rk,ri).*JUZHEN_GreenTime(rk,ri,tp);
        bb=JUZHEN_Road_Queue(rk,ri,tp);
        Input_Queue=Input_Queue+min(JUZHEN_Baohe_Speed(rk,ri).*JUZHEN_GreenTime(rk,ri,tp),JUZHEN_Road_Queue(rk,ri,tp));%公式6
    end
    for rj=1:size(Roadcapacity,1)
        JUZHEN_Road_Queue(ri,rj,tp+1)=JUZHEN_Road_Queue(ri,rj,tp)-min(JUZHEN_Baohe_Speed(ri,rj)*JUZHEN_GreenTime(ri,rj,tp),JUZHEN_Road_Queue(ri,rj,tp))+Input_Queue.*ZhuanWanP(ri,rj); %公式6   利用tp周期的排队长度计算tp+1周期的排队长度
    end
end

for rri=1:size(Roadcapacity,1)     %（i,j）表示链路i去向链路j,更新链路i的总流量
    Input=sum(min(JUZHEN_Baohe_Speed(:,rri).*JUZHEN_GreenTime(:,rri,tp),JUZHEN_Road_Zliuliang(:,tp).*ZhuanWanP(:,rri)));%上游  公式15
    Output=sum(min(JUZHEN_Baohe_Speed(rri,:).*JUZHEN_GreenTime(rri,:,tp),JUZHEN_Road_Zliuliang(rri,tp).*ZhuanWanP(rri,:)));%下游，饱和速率不分时段  公式16
    JUZHEN_Road_Zliuliang(rri,tp+1)= min((max(JUZHEN_Road_Zliuliang(rri,tp)+Input-Output,0)),Roadcapacity(rri,2));%流量更新
end


for gi=1:size(Roadcapacity,1)
    JUZHEN_Road_ZQueue(gi,tp+1)=sum(JUZHEN_Road_Queue(gi,:,tp+1));%下一周期，各链路的排队总长度
end
end




