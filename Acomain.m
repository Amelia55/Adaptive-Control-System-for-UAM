function[Flight_Paixu,Shijian,Shortest_Route]=Acomain(flights,JG,GT)
%The schedule at the intersection
%% II. data
Num=1;
citys=zeros(size(flights,1),4);
citys(:,2:4)=flights;
for raw=1:size(flights,1)   
    citys(raw,1)=Num;
    Num=Num+1;
end
FCFS=sortrows(citys,3);%sort

%% III. 

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

%% IV. Initialize the parameters
m = 50;                             % The number of ants
alpha = 1;                           % Pheromone importance factor
beta = 5;                            % Heuristic function importance factor
rho = 0.3;                           % Pheromone volatilization factor
Q = 100;                              % Constant coefficient
Eta = 1./D;                          % Heuristic function
Tau = ones(n,n);                     % Pheromone matrix
Table = zeros(m,n);                  % Record table
iter = 1;                            % Initial number of iterations
iter_max = 300;                      % Maximum number of iterations
Route_best = zeros(iter_max,n);      % The best order of each generation       
Length_best = zeros(iter_max,1);     % The time required for the best order of each generation  
Length_ave = zeros(iter_max,1);      
Limit_iter = 0;                      % Number of iterations when the program converges

%% V. Iterations look for the best order
while iter <= iter_max
    
    start = zeros(m,1);
    for pp = 1:m
        temp = randperm(n);
        start(pp) = temp(1);
    end
    Table(:,1) = start;
    
    citys_index = 1:n;
    
    for qq = 1:m
        for dd = 2:n
            tabu = Table(qq,1:(dd - 1));           
            allow_index = ~ismember(citys_index,tabu);
            allow = citys_index(allow_index); 
            P = allow;
            
            for k = 1:length(allow)
                P(k) = (Tau(tabu(end),allow(k))^alpha) * (Eta(tabu(end),allow(k))^beta);
            end
            P = P/sum(P);
            % Roulette
            Pc = cumsum(P);
            target_index = find(Pc >= rand);
            target = allow(target_index(1));
            Table(qq,dd) = target;
        end
    end
    Length = zeros(m,1);
    Shijian=zeros(1,size(citys,1));
    Shijian(1,1)=GT;%The time to switch to a green light
    qqq=1;
    while qqq<=m
        Route = Table(qqq,:);
        ddd=2;
        while ddd <=n
            Shijian(ddd)=Shijian(ddd-1)+D(Route(ddd-1),Route(ddd));
            [yuanweizhi,lie]=find(FCFS(:,1)==Table(qqq,ddd));
            ST=FCFS(:,2);
            YXJ1=FCFS(:,3);
            IMP=max(YXJ1)./YXJ1;
            if sign(yuanweizhi-ddd-5)==1 || sign(ddd-yuanweizhi-5)==1
                Length(qqq)=1000000;
                  ddd=ddd+1;
            else
                Length(qqq)=Length(qqq)+(Shijian(1,ddd)-flights(yuanweizhi,1)).*IMP(yuanweizhi,1);%Objective function
                ddd=ddd+1;
            end
        end
        qqq=qqq+1;
    end
    
   
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
    % Update pheromone
    Delta_Tau = zeros(n,n);
    for qqqq = 1:m
        for dddd = 1:(n - 1)
            Delta_Tau(Table(qqqq,dddd),Table(qqqq,dddd+1)) = Delta_Tau(Table(qqqq,dddd),Table(qqqq,dddd+1)) + Q/Length(qqqq);
        end
        Delta_Tau(Table(qqqq,n),Table(qqqq,1)) = Delta_Tau(Table(qqqq,n),Table(qqqq,1)) + Q/Length(qqqq);
    end
    Tau = (1-rho) * Tau + Delta_Tau;
    iter = iter + 1;
    Table = zeros(m,n);
end

%% VI. result
[Shortest_Length,index] = min(Length_best);
Shortest_Route = Route_best(index,:);
for column=1:size(Shortest_Route,2)
    Flight_Paixu(1,column)=citys(Shortest_Route(1,column),2);
end
end