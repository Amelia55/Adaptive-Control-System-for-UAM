%不区分进离场！各航段路阻的更新计算函数。适用于tp>1的情况，tp=1时，路阻等于JT
%相关参数：道路容量、到达交叉口的周期号、各时段路网流量记录
function [JUZHEN_luzu,JZ_Road_AveLiuliang,JZ_Road_Baohedu,JUZHEN_Intersection_baohedu] = get_luzu(JUZHEN_luzu,JUZHEN_Road_Zliuliang,tp,Intersection_Luhao,JT,JZ_Road_AveLiuliang,Zong_tp,Roadcapacity,JZ_Road_Baohedu,JUZHEN_Intersection_baohedu)
Intersection_Luhao(isnan(Intersection_Luhao))=0;
%--------------------------------------------------------------计算各路段在当前周期的均流量
for zi=1:size(Roadcapacity,1)
%     if tp==1 %第一周期的均流量
%         JZ_Road_AveLiuliang(zi,tp)=JUZHEN_Road_Zliuliang(zi,tp);
%     elseif tp==2 %第二周期的均流量
%         JZ_Road_AveLiuliang(zi,tp)=(JUZHEN_Road_Zliuliang(zi,tp-1)+JUZHEN_Road_Zliuliang(zi,tp))/2;
%     elseif tp==Zong_tp %最后一周期的均流量
%         JZ_Road_AveLiuliang(zi,tp)=(JUZHEN_Road_Zliuliang(zi,tp-1)+JUZHEN_Road_Zliuliang(zi,tp))/2;
%     else
%         JZ_Road_AveLiuliang(zi,tp)=(JUZHEN_Road_Zliuliang(zi,tp-1)+JUZHEN_Road_Zliuliang(zi,tp)+JUZHEN_Road_Zliuliang(zi,tp+1))/3;
%     end
    if tp==1 %第一周期的均流量
        JZ_Road_AveLiuliang(zi,tp)=JUZHEN_Road_Zliuliang(zi,tp);
    elseif tp==2 %第二周期的均流量
        JZ_Road_AveLiuliang(zi,tp)=(JUZHEN_Road_Zliuliang(zi,tp+1)+JUZHEN_Road_Zliuliang(zi,tp))/2;
    elseif tp==Zong_tp %最后一周期的均流量
        JZ_Road_AveLiuliang(zi,tp)=JUZHEN_Road_Zliuliang(zi,tp);
    else
        JZ_Road_AveLiuliang(zi,tp)=(JUZHEN_Road_Zliuliang(zi,tp+1)+JUZHEN_Road_Zliuliang(zi,tp))/2;
    end
    JZ_Road_Baohedu(zi,tp)=JZ_Road_AveLiuliang(zi,tp)/Roadcapacity(zi,2);%公式24
end
%-------------------------------------------将路段饱和度转化为交叉口间的饱和度，计算交叉口间路阻
for ei=1:size(JT,1)
    for ej=1:size(JT,2)
        if Intersection_Luhao(ei,ej)~=0 %当交叉口i与交叉口j间有通路时
            JUZHEN_Intersection_baohedu(ei,ej,tp)= JZ_Road_Baohedu(Intersection_Luhao(ei,ej),tp);
            JUZHEN_luzu(ei,ej,tp)=real(JT(ei,ej)*(2/(1+(1-JUZHEN_Intersection_baohedu(ei,ej,tp))^0.5)));%公式23,路阻,当航段流量为0，行驶时间t0为JT(eei,eej)
            
        end
    end
end
end