function [Intersaction_JG,Airport_JG]=JG_function(n)
%�������㰲ȫ�����ʱ��������뺽����Ϣ����ͺ�����

Intersaction_JG=zeros(n,n);%����ڼ��
Airport_JG=zeros(n,n);%�ܵ�ʹ�ü��
I_JG=45;
A_JG=45;%�������޸ģ���λΪ�� Ӣ������ȡֵΪ60����������ȡֵ45
for gi=1:n
    for gj=1:n
        Intersaction_JG(gi,gj)=I_JG;
        Airport_JG(gi,gj)=A_JG;
    end
end

end
