function [Intersaction_JG,Airport_JG]=JG_function(n)
%计算满足安全间隔的时间矩阵，输入航班信息矩阵和航班量

Intersaction_JG=zeros(n,n);%交叉口间隔
Airport_JG=zeros(n,n);%跑道使用间隔
I_JG=45;
A_JG=45;%参数需修改，单位为秒 英文论文取值为60，大论文中取值45
for gi=1:n
    for gj=1:n
        Intersaction_JG(gi,gj)=I_JG;
        Airport_JG(gi,gj)=A_JG;
    end
end

end
