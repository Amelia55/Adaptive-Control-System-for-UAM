%State of Charge
function[StateCharge,YXJ]=get_StateCharge(Now_time,FlightCharge,Xuhang,Daodat,Sheet_YXJ1,Sheet_YXJ2,Sheet_YXJ3)
StateCharge(:,1)=FlightCharge(:,1);
StateCharge(:,2)=FlightCharge(:,6);
YXJ=zeros(size(FlightCharge,1),2);
YXJ(:,1)=FlightCharge(:,1);
UrgentTask=FlightCharge(:,7);
JL=FlightCharge(:,2);            
UnitCharge=1/Xuhang/3600;  
Gama1=rand()*0.05+0.95;       
for ci=1:size(FlightCharge,1)
    if Now_time(ci,1)> Daodat(FlightCharge(ci,1),1)
    StateCharge(ci,2)=FlightCharge(ci,6)- Gama1*UnitCharge*(Now_time(ci,1)-Daodat(FlightCharge(ci,1),1));
    end
    if StateCharge(ci,2)>=0 && StateCharge(ci,2)<0.32
        YXJ(ci,2)=Sheet_YXJ1(UrgentTask(ci),JL(ci));
    elseif StateCharge(ci,2)>=0.32 && StateCharge(ci,2)<0.66
        YXJ(ci,2)=Sheet_YXJ2(UrgentTask(ci),JL(ci));
    elseif StateCharge(ci,2)>=0.66 && StateCharge(ci,2)<1
        YXJ(ci,2)=Sheet_YXJ3(UrgentTask(ci),JL(ci));
    elseif StateCharge(ci,2)<=0
        YXJ(ci,2)=1;
    end
end

end
