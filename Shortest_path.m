 function [NextPoint,NextLT]=Shortest_path(JT_xiuzheng,JT,startpoint,endpoint)
% JT=xlsread('C:\Users\Lenovo\Desktop\DATA\Terminal area traffic network.xlsx','JT');%终端区交通路进场网的初始值
% startpoint=1;
% endpoint=8;
JT_xiuzheng(isnan(JT_xiuzheng))=inf;
c1=zeros(1,length(JT_xiuzheng));
c2=zeros(1,length(JT_xiuzheng));
s=1;
for i=1:length(JT_xiuzheng)
    for count=1:length(JT_xiuzheng)
        c1(1,count+(s-1)*length(JT_xiuzheng))=i;
    end
    s=s+1;
end

for i=1:length(JT_xiuzheng)
    for count=1:length(JT_xiuzheng)
        c2(1,count+(i-1)*length(JT_xiuzheng))=count;
    end
end
 DG = sparse(c2,c1,JT_xiuzheng);  
% h = view(biograph(DG,[],'ShowWeights','on')) %画图, 这个好玩
% Find shortest path from 起点 to 终点
for i=1:size(JT_xiuzheng,2)
    for j=2:size(JT_xiuzheng,2)
[dist,lujing] = graphshortestpath(DG,startpoint,endpoint); %找顶点到终点的最短路径!
distance(i,j)=dist;
    end
end
% Mark the nodes and edges of the shortest path
% set(h.Nodes(lujing),'Color',[1 0.4 0.4]) %上色
% edges = getedgesbynodeid(h,get(h.Nodes(lujing),'ID'));
% set(edges,'LineColor',[1 0 0]) %上色
% set(edges,'LineWidth',1.5) %上色

 NextPoint=lujing(2);
 NextLT=JT(startpoint,NextPoint);
 end
