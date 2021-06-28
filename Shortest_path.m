 function [NextPoint,NextLT]=Shortest_path(JT_xiuzheng,JT,startpoint,endpoint)
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
for i=1:size(JT_xiuzheng,2)
    for j=2:size(JT_xiuzheng,2)
[dist,lujing] = graphshortestpath(DG,startpoint,endpoint); 
distance(i,j)=dist;
    end
end

 NextPoint=lujing(2);
 NextLT=JT(startpoint,NextPoint);
 end
