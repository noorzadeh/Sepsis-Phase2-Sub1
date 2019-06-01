function [score, label] = get_sepsis_score(data, model)
   % read the data
load('method.mat');
load weights.mat
load hmmsimple.mat
D=data;
% discard the non significant features
if ~strcmp(method,'kmeans')
    D (:,indNonSig) = [];
    w(indNonSig) =[];
end

% processing Nans of the Data
if strcmp(dataprocess,'interp')
    D = DataInterpolationfcn(D, 1:size(D,2), 1);
 
else
    D(isnan(D))=0;
end
if ~strcmp(method,'kmeans')
    D = D./repmat(datanorm,[size(D,1),1]);
    D2 = D*w';
%     D2 = round(D2*N)./N;
%     seq=D2*N;
%     if min(seq)<=0
%         seq     = seq - min(seq)+1;
%     end
    if max(D2)==min(D2)
%        D2 = zeros(1,size(D2,1)); 
    else
    D2 = (D2-min(D2))./( max(D2)-min(D2));
    end
    seq =round(D2*N+1);
    
else
    for i=1:size(D,1)
        seq(i)=findCluster(centroids,D);
    end
    seq=seq';
end

PSTATES = hmmdecode(seq',trans_est,emis_est);
scores=PSTATES(2,end)';
score= scores(end);
% try
labels = hmmviterbi(seq',trans_est,emis_est);
    
% catch e
% %     disp(e.message);
% end 
labels=labels-1;
label = labels(end);
if score <.88
    label =0;
end
end
