function[Flight_Paixu,Shijian,Shortest_Route]=Acomain(flights,JG,GT)
%输入需要排序的航班信息、间隔矩阵、排序位置为1的航班的离开时间GT
%% II. 导入数据
Num=1;
citys=zeros(size(flights,1),4);
citys(:,2:4)=flights;
for raw=1:size(flights,1)    %第一列是航班序号
    citys(raw,1)=Num;
    Num=Num+1;
end
FCFS=sortrows(citys,3);%按照到达时间进行排序

%% III. 计算城市间相互距离--航班

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

%% IV. 初始化参数
m = 50;                             % 蚂蚁数量
alpha = 1;                           % 信息素重要程度因子
beta = 5;                            % 启发函数重要程度因子
rho = 0.3;                           % 信息素挥发因子
Q = 100;                              % 常系数
Eta = 1./D;                          % 启发函数
Tau = ones(n,n);                     % 信息素矩阵
Table = zeros(m,n);                  % 路径记录表
iter = 1;                            % 迭代次数初值
iter_max = 300;                      % 最大迭代次数 
Route_best = zeros(iter_max,n);      % 各代最佳路径       
Length_best = zeros(iter_max,1);     % 各代最佳路径的长度  
Length_ave = zeros(iter_max,1);      % 各代路径的平均长度
Limit_iter = 0;                      % 程序收敛时迭代次数

%% V. 迭代寻找最佳路径
while iter <= iter_max
    % 随机产生各个蚂蚁的起点城市
    start = zeros(m,1);
    for pp = 1:m
        temp = randperm(n);
        start(pp) = temp(1);%50个蚂蚁的出发城市
    end
    Table(:,1) = start;
    
    citys_index = 1:n;
    % 逐个蚂蚁路径选择
    for qq = 1:m
        % 逐个城市路径选择
        %           j=2;
        for dd = 2:n
            tabu = Table(qq,1:(dd - 1));           % 已访问的城市集合(禁忌表)
            allow_index = ~ismember(citys_index,tabu);%ismember检查第一个矩阵中元素是否为第二个矩阵中的值
            allow = citys_index(allow_index);  % 待访问的城市集合
            P = allow;
            % 计算城市间转移概率
            for k = 1:length(allow)
                P(k) = (Tau(tabu(end),allow(k))^alpha) * (Eta(tabu(end),allow(k))^beta);
            end
            P = P/sum(P);
            % 轮盘赌法选择下一个访问城市
            Pc = cumsum(P);
            target_index = find(Pc >= rand);
            target = allow(target_index(1));
            Table(qq,dd) = target;
        end
    end
    % 计算各个蚂蚁的路径距离
    Length = zeros(m,1);
    Shijian=zeros(1,size(citys,1));
    Shijian(1,1)=GT;%切换为绿灯的时刻
    qqq=1;
    while qqq<=m
        Route = Table(qqq,:);
        ddd=2;
        while ddd <=n
            %               if j==1
            %               Shijian(j)=10;%切换为绿灯的时刻
            %               else
            Shijian(ddd)=Shijian(ddd-1)+D(Route(ddd-1),Route(ddd));
            %               end
            [yuanweizhi,lie]=find(FCFS(:,1)==Table(qqq,ddd));
            ST=FCFS(:,2);
            YXJ1=FCFS(:,3);
            IMP=max(YXJ1)./YXJ1;
            if sign(yuanweizhi-ddd-5)==1 || sign(ddd-yuanweizhi-5)==1
                Length(qqq)=1000000;%若不符合约束条件，为无限大的数
                  ddd=ddd+1;
            else
                %                   if Shijian(j)>ST(yuanweizhi)
                Length(qqq)=Length(qqq)+(Shijian(1,ddd)-flights(yuanweizhi,1)).*IMP(yuanweizhi,1);%20210422，将目标函数修改为 离开交叉口时间-进入系统时间
                ddd=ddd+1;
            end
        end
        qqq=qqq+1;
    end
    
    
    % 计算最短路径距离及平均距离
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
    % 更新信息素
    Delta_Tau = zeros(n,n);
    % 逐个蚂蚁计算
    for qqqq = 1:m
        % 逐个城市计算
        for dddd = 1:(n - 1)
            Delta_Tau(Table(qqqq,dddd),Table(qqqq,dddd+1)) = Delta_Tau(Table(qqqq,dddd),Table(qqqq,dddd+1)) + Q/Length(qqqq);
        end
        Delta_Tau(Table(qqqq,n),Table(qqqq,1)) = Delta_Tau(Table(qqqq,n),Table(qqqq,1)) + Q/Length(qqqq);
    end
    Tau = (1-rho) * Tau + Delta_Tau;
    % 迭代次数加1，清空路径记录表
    %Rlength(iter) = min_Length;
    iter = iter + 1;
    Table = zeros(m,n);
end

%% VI. 结果显示
[Shortest_Length,index] = min(Length_best);
Shortest_Route = Route_best(index,:);
for column=1:size(Shortest_Route,2)
    Flight_Paixu(1,column)=citys(Shortest_Route(1,column),2);
end

% disp(['目标函数:' num2str(Shortest_Length)]);%结果显示
% disp(['航班顺序:' num2str(Flight_Paixu)]);
% disp(['通过时间:' num2str(Shijian)]);

%% VII. 绘图

end