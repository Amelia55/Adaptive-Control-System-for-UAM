function[JUZHEN_Road_Zliuliang,JUZHEN_Road_Queue,JUZHEN_Road_ZQueue]=get_Road_ZLiuliangYC(JUZHEN_GreenTime,tp,Roadcapacity,JUZHEN_Baohe_Speed,JUZHEN_Road_Zliuliang,ZhuanWanP,JUZHEN_Road_Queue,JUZHEN_Road_ZQueue)

%-------------------------------------The change of flow on the route
JUZHEN_Baohe_Speed(isnan(JUZHEN_Baohe_Speed))=0;
for ri=1:size(Roadcapacity,1)   %Predicted number of queues
    Input_Queue=0;
    for rk=1:size(Roadcapacity,1)
        aa=JUZHEN_Baohe_Speed(rk,ri).*JUZHEN_GreenTime(rk,ri,tp);
        bb=JUZHEN_Road_Queue(rk,ri,tp);
        Input_Queue=Input_Queue+min(JUZHEN_Baohe_Speed(rk,ri).*JUZHEN_GreenTime(rk,ri,tp),JUZHEN_Road_Queue(rk,ri,tp));
    end
    for rj=1:size(Roadcapacity,1)
        JUZHEN_Road_Queue(ri,rj,tp+1)=JUZHEN_Road_Queue(ri,rj,tp)-min(JUZHEN_Baohe_Speed(ri,rj)*JUZHEN_GreenTime(ri,rj,tp),JUZHEN_Road_Queue(ri,rj,tp))+Input_Queue.*ZhuanWanP(ri,rj); %Eq.6
    end
end

for rri=1:size(Roadcapacity,1)     
    Input=sum(min(JUZHEN_Baohe_Speed(:,rri).*JUZHEN_GreenTime(:,rri,tp),JUZHEN_Road_Zliuliang(:,tp).*ZhuanWanP(:,rri)));%Eq.13
    Output=sum(min(JUZHEN_Baohe_Speed(rri,:).*JUZHEN_GreenTime(rri,:,tp),JUZHEN_Road_Zliuliang(rri,tp).*ZhuanWanP(rri,:)));%Eq.14
    JUZHEN_Road_Zliuliang(rri,tp+1)= min((max(JUZHEN_Road_Zliuliang(rri,tp)+Input-Output,0)),Roadcapacity(rri,2));
end


for gi=1:size(Roadcapacity,1)
    JUZHEN_Road_ZQueue(gi,tp+1)=sum(JUZHEN_Road_Queue(gi,:,tp+1));%In the next cycle, the total queue length of each link
end
end




