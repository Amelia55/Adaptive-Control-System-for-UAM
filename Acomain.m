function[Flight_Paixu,Shijian,Shortest_Route]=Acomain(flights,JG,GT)
%������Ҫ����ĺ�����Ϣ�������������λ��Ϊ1�ĺ�����뿪ʱ��GT
%% II. ��������
Num=1;
citys=zeros(size(flights,1),4);
citys(:,2:4)=flights;
for raw=1:size(flights,1)    %��һ���Ǻ������
    citys(raw,1)=Num;
    Num=Num+1;
end
FCFS=sortrows(citys,3);%���յ���ʱ���������

%% III. ������м��໥����--����

n = size(citys,1);
D = zeros(n,n);
for kk = 1:n
    for jj = 1:n
        if kk ~= jj
        		D(kk,jj) =JG(kk,jj);
        else
            D(kk,jj) = eps;      
        end
    end    
end

%% IV. ��ʼ������
m = 50;                             % ��������
alpha = 1;                           % ��Ϣ����Ҫ�̶�����
beta = 5;                            % ����������Ҫ�̶�����
rho = 0.3;                           % ��Ϣ�ػӷ�����
Q = 100;                              % ��ϵ��
Eta = 1./D;                          % ��������
Tau = ones(n,n);                     % ��Ϣ�ؾ���
Table = zeros(m,n);                  % ·����¼��
iter = 1;                            % ����������ֵ
iter_max = 300;                      % ���������� 
Route_best = zeros(iter_max,n);      % �������·��       
Length_best = zeros(iter_max,1);     % �������·���ĳ���  
Length_ave = zeros(iter_max,1);      % ����·����ƽ������
Limit_iter = 0;                      % ��������ʱ��������

%% V. ����Ѱ�����·��
while iter <= iter_max
    % ��������������ϵ�������
    start = zeros(m,1);
    for pp = 1:m
        temp = randperm(n);
        start(pp) = temp(1);%50�����ϵĳ�������
    end
    Table(:,1) = start;
    
    citys_index = 1:n;
    % �������·��ѡ��
    for qq = 1:m
        % �������·��ѡ��
        %           j=2;
        for dd = 2:n
            tabu = Table(qq,1:(dd - 1));           % �ѷ��ʵĳ��м���(���ɱ�)
            allow_index = ~ismember(citys_index,tabu);%ismember����һ��������Ԫ���Ƿ�Ϊ�ڶ��������е�ֵ
            allow = citys_index(allow_index);  % �����ʵĳ��м���
            P = allow;
            % ������м�ת�Ƹ���
            for k = 1:length(allow)
                P(k) = (Tau(tabu(end),allow(k))^alpha) * (Eta(tabu(end),allow(k))^beta);
            end
            P = P/sum(P);
            % ���̶ķ�ѡ����һ�����ʳ���
            Pc = cumsum(P);
            target_index = find(Pc >= rand);
            target = allow(target_index(1));
            Table(qq,dd) = target;
        end
    end
    % ����������ϵ�·������
    Length = zeros(m,1);
    Shijian=zeros(1,size(citys,1));
    Shijian(1,1)=GT;%�л�Ϊ�̵Ƶ�ʱ��
    qqq=1;
    while qqq<=m
        Route = Table(qqq,:);
        ddd=2;
        while ddd <=n
            %               if j==1
            %               Shijian(j)=10;%�л�Ϊ�̵Ƶ�ʱ��
            %               else
            Shijian(ddd)=Shijian(ddd-1)+D(Route(ddd-1),Route(ddd));
            %               end
            [yuanweizhi,lie]=find(FCFS(:,1)==Table(qqq,ddd));
            ST=FCFS(:,2);
            YXJ1=FCFS(:,3);
            IMP=max(YXJ1)./YXJ1;
            if sign(yuanweizhi-ddd-5)==1 || sign(ddd-yuanweizhi-5)==1
                Length(qqq)=1000000;%��������Լ��������Ϊ���޴����
                  ddd=ddd+1;
            else
                %                   if Shijian(j)>ST(yuanweizhi)
                Length(qqq)=Length(qqq)+(Shijian(1,ddd)-flights(yuanweizhi,1)).*IMP(yuanweizhi,1);%20210422����Ŀ�꺯���޸�Ϊ �뿪�����ʱ��-����ϵͳʱ��
                ddd=ddd+1;
            end
        end
        qqq=qqq+1;
    end
    
    
    % �������·�����뼰ƽ������
    if iter == 1
        [min_Length,min_index] = min(Length);
        Length_best(iter) = min_Length;
        Length_ave(iter) = mean(Length);
        Route_best(iter,:) = Table(min_index,:);
        Limit_iter = 1;
    else
        [min_Length,min_index] = min(Length);
        Length_best(iter) = min(Length_best(iter - 1),min_Length);
        Length_ave(iter) = mean(Length);
        if Length_best(iter) == min_Length
            Route_best(iter,:) = Table(min_index,:);
            Limit_iter = iter;
        else
            Route_best(iter,:) = Route_best((iter-1),:);
        end
    end
    % ������Ϣ��
    Delta_Tau = zeros(n,n);
    % ������ϼ���
    for qqqq = 1:m
        % ������м���
        for dddd = 1:(n - 1)
            Delta_Tau(Table(qqqq,dddd),Table(qqqq,dddd+1)) = Delta_Tau(Table(qqqq,dddd),Table(qqqq,dddd+1)) + Q/Length(qqqq);
        end
        Delta_Tau(Table(qqqq,n),Table(qqqq,1)) = Delta_Tau(Table(qqqq,n),Table(qqqq,1)) + Q/Length(qqqq);
    end
    Tau = (1-rho) * Tau + Delta_Tau;
    % ����������1�����·����¼��
    %Rlength(iter) = min_Length;
    iter = iter + 1;
    Table = zeros(m,n);
end

%% VI. �����ʾ
[Shortest_Length,index] = min(Length_best);
Shortest_Route = Route_best(index,:);
for column=1:size(Shortest_Route,2)
    Flight_Paixu(1,column)=citys(Shortest_Route(1,column),2);
end

% disp(['Ŀ�꺯��:' num2str(Shortest_Length)]);%�����ʾ
% disp(['����˳��:' num2str(Flight_Paixu)]);
% disp(['ͨ��ʱ��:' num2str(Shijian)]);

%% VII. ��ͼ

end