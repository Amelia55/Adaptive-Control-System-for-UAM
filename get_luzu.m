%Update calculation function of road resistance of each segment. It is suitable for tp > 1, when tp=1, the road resistance is equal to JT.

function [JUZHEN_luzu,JZ_Road_AveLiuliang,JZ_Road_Baohedu,JUZHEN_Intersection_baohedu] = get_luzu(JUZHEN_luzu,JUZHEN_Road_Zliuliang,tp,Intersection_Luhao,JT,JZ_Road_AveLiuliang,Zong_tp,Roadcapacity,JZ_Road_Baohedu,JUZHEN_Intersection_baohedu)
Intersection_Luhao(isnan(Intersection_Luhao))=0;
%--------------------------------------------------------------Calculate the average flow of each road section in the current cycle
for zi=1:size(Roadcapacity,1)

    if tp==1 
        JZ_Road_AveLiuliang(zi,tp)=JUZHEN_Road_Zliuliang(zi,tp);
    elseif tp==2 
        JZ_Road_AveLiuliang(zi,tp)=(JUZHEN_Road_Zliuliang(zi,tp+1)+JUZHEN_Road_Zliuliang(zi,tp))/2;
    elseif tp==Zong_tp 
        JZ_Road_AveLiuliang(zi,tp)=JUZHEN_Road_Zliuliang(zi,tp);
    else
        JZ_Road_AveLiuliang(zi,tp)=(JUZHEN_Road_Zliuliang(zi,tp+1)+JUZHEN_Road_Zliuliang(zi,tp))/2;
    end
    JZ_Road_Baohedu(zi,tp)=JZ_Road_AveLiuliang(zi,tp)/Roadcapacity(zi,2);%Eq.20
end
%-------------------------------------------Calculation of road resistance between intersections
for ei=1:size(JT,1)
    for ej=1:size(JT,2)
        if Intersection_Luhao(ei,ej)~=0 
            JUZHEN_Intersection_baohedu(ei,ej,tp)= JZ_Road_Baohedu(Intersection_Luhao(ei,ej),tp);
            JUZHEN_luzu(ei,ej,tp)=real(JT(ei,ej)*(2/(1+(1-JUZHEN_Intersection_baohedu(ei,ej,tp))^0.5)));%Eq.19
            
        end
    end
end
end