 function [NextPoint,NextLT]=Shortest_path(JT_xiuzheng,JT,startpoint,endpoint)
% JT=xlsread('C:\Users\Lenovo\Desktop\DATA\Terminal area traffic network.xlsx','JT');%�ն�����ͨ·�������ĳ�ʼֵ
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
% h = view(biograph(DG,[],'ShowWeights','on')) %��ͼ, �������
% Find shortest path from ��� to �յ�
for i=1:size(JT_xiuzheng,2)
    for j=2:size(JT_xiuzheng,2)
[dist,lujing] = graphshortestpath(DG,startpoint,endpoint); %�Ҷ��㵽�յ�����·��!
distance(i,j)=dist;
    end
end
% Mark the nodes and edges of the shortest path
% set(h.Nodes(lujing),'Color',[1 0.4 0.4]) %��ɫ
% edges = getedgesbynodeid(h,get(h.Nodes(lujing),'ID'));
% set(edges,'LineColor',[1 0 0]) %��ɫ
% set(edges,'LineWidth',1.5) %��ɫ

 NextPoint=lujing(2);
 NextLT=JT(startpoint,NextPoint);
 end
