function [Intersaction_JG,Airport_JG]=JG_function(n,safetyJG)
%Calculate the time matrix that satisfies the safety interval.

Intersaction_JG=zeros(n,n);
Airport_JG=zeros(n,n);
I_JG=safetyJG;
A_JG=safetyJG;% s
for gi=1:n
    for gj=1:n
        Intersaction_JG(gi,gj)=I_JG;
        Airport_JG(gi,gj)=A_JG;
    end
end

end
