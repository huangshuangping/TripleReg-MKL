function Evaluation(config_file,c,TestNum,TestLabel,Wbeta,TestSim,AllClsTotal)
%
% this evaluate the accuary base on the value of p
% Input
%   trimage_names:the list of the trainning images'names
%   p:            the possibility of each the sample
%   tr_label:     the true label of the testing sample
%
% Output:
%  accuracy;      the value of accuracy

%% initial
eval(config_file);

% Dir1 = fullfile( PreMat_dir );
Dir2 = fullfile(fullfile(Result_dir,ResultDir));

TrainNum = c;

%% compute p
TestSim = repmat(TestSim,[1 1 AllClsTotal]);
% linear regularize
% min_value = repmat(min(Wbeta,[],1),[c+1 FeatureNum]);
% max_value = repmat(max(Wbeta,[],1),[c+1 FeatureNum]);
% Wbeta =( Wbeta-min_value )./ (max_value - min_value );
% Wbeta = 2*Wbeta - 1;
% Wbeta(:,:,AllClsTotal) = 0;

% gaussian 0
% mean_value = repmat( mean(Wbeta, 1),[c+1 FeatureNum 1] );
% var_value = repmat( var(Wbeta, 1,1),[c+1 FeatureNum 1] );
% Wbeta =( Wbeta - mean_value ) ./var_value;
% Wbeta(:,:,AllClsTotal) = 0;

% norm 1
% w_s = sum(abs(Wbeta),1);
% Wbeta = Wbeta./repmat(w_s,[c+1 1 1]);
% Wbeta(:,:,AllClsTotal) = 0;
Wbeta = reshape(Wbeta,[TrainNum+1,1,AllClsTotal*FeatureNum]);
% Test_f = reshape( sum( reshape( sum( bsxfun( @times,TestSim,Wbeta),1),...
%     [1 TestNum FeatureNum AllClsTotal]),3),[1 TestNum AllClsTotal]);
Test_f = reshape( sum( reshape( sum( bsxfun( @times,TestSim,Wbeta(2:end,:,:)),1),...
    [1 TestNum FeatureNum AllClsTotal]),3),[1 TestNum AllClsTotal]);
Test_expf = exp( Test_f );
Test_p = Test_expf./(repmat( sum(Test_expf, 3),[1 1 AllClsTotal]));
% [~,PreLabel] = max(Test_p,[],3);
[~,PreLabel] = max(Test_f,[],3);


%% evaluate
[TestLabel,~] = find( TestLabel == 1 );
accuracy = sum(TestLabel == PreLabel' )/ TestNum;

%% save the record
outFName = fullfile( Dir2,sprintf('ClassNum=%d.txt',AllClsTotal) );
if c == EvaluationStep
    fid = fopen( outFName,'w');
else
    fid = fopen( outFName,'a');
    
end
fprintf(fid,sprintf('%d %f ',c,accuracy));
% for cl = 1: AllClsTotal
%     ind_pr = PreLabel' == cl;
%     ind_tr = TestLabel == cl;
%     accuracy_cls  = sum(ind_pr == ind_tr)/TestNum;
%     fprintf(fid,sprintf('%.3f ',accuracy_cls));
% end
fprintf(fid,'\n');
fclose(fid);
%% visulization
% figure;
% subplot(1,2,1);
% title('the test result with f');
% xlabel('the testnum');
% ylabel('the value_f')
% hold on;
% ind_pos = find(TestLabel == 1);
% ind_neg = find(TestLabel ==0);
% TestNum_pos = length(ind_pos);
% TestNum_neg = length(ind_neg);
% x = 1:1:TestNum_pos;
% y = f_test(ind_pos,1);
% plot(x,y,'r*');
% hold on;
% x = TestNum_pos+1:1:TestNum;
% y = f_test(ind_neg);
% plot(x,y,'b+');
% hold on;
% x = 1: 1: TestNum;
% y = value_f;
% plot(x,y,'k');
% 
% 
% % the plot of p
% subplot(1,2,2);
% title('the test result with p');
% hold on;
% xlabel('the testnum');
% ylabel('the value_p')
% hold on;
% x = 1:1:TestNum_pos;
% y = p_test(ind_pos,1);
% plot(x,y,'r*');
% hold on;
% x = TestNum_pos+1:1:TestNum_pos+TestNum_neg;
% y = p_test(ind_neg,1);
% plot(x,y,'b+');
% hold on;
% x = 1: 1: TestNum;
% y =0.5;
% plot(x,y,'k');
