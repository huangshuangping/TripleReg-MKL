%***********************************
% Function description: Online process of TripleReg-MKL, 20150405
%***********************************
function Online_FaiDomain_hinge_two(config_file)
%% Config the global variables
eval(config_file);
%% Directory for the kernel matrices
KernelDir=fullfile(WorkDir,Current_dataset,Kernel_dir);
%% Load the binary labels of TrainSet & TestSet 
inFName = fullfile( WorkDir, Current_dataset,PreMatDir ,'AllTrainLabel.mat');
load( inFName,'AllTrainLabel');
TrainNum=length(AllTrainLabel); % Train number
inFName = fullfile( WorkDir, Current_dataset,PreMatDir ,'AllTestLabel.mat');
load( inFName,'AllTestLabel');
TestNum=length(AllTestLabel); % Test number
%% Train label and test label
[~,TrainLabel] = max(AllTrainLabel,[],1);
[~,TestLabel] = max(AllTestLabel,[],1);
ClassNum=max(TrainLabel);
%% Random the sequence of the TrainLabel
% rand('state',0);
%% Load sample sequence index for the online process
IndexFileName=fullfile(WorkDir,Current_dataset,PreMatDir ,'Index.mat');
if (size(dir(IndexFileName),1)~=0)
    fprintf('skiping Index....\n');
    load(fullfile(WorkDir, Current_dataset,PreMatDir ,'Index.mat'),'index');
else
    index=[];
    for i = 1: PassNum
        ind = randperm(TrainNum);
        index = horzcat(index,ind);
    end
    save(fullfile(WorkDir, Current_dataset,PreMatDir ,'Index.mat'),'index');
end
%% Initialize AC_F
AC_F=[];
%% Load the TrainSim
TrainSim_all=zeros(TrainNum,TrainNum,FeatureNum);
TrainSim=zeros(TrainNum,TrainNum);
for k = 1:FeatureNum
    TrainSim_a=[];
    fprintf('Loading TrainSim_%s,',ChosenFeature{k});
    Const_gamma=str2num(eval(sprintf('%s_gamma{%s_index}',ChosenFeature{k},ChosenFeature{k})));
    Dir4 = fullfile(KernelDir,sprintf('%s_gamma%.2f',ChosenFeature{k}, Const_gamma));
    for f=1:PartNumTrain
        load(fullfile( Dir4, sprintf('TrainSim_%s_Part%d.mat',ChosenFeature{k},f)));
        TrainSim_a=[TrainSim_a ;TrainSim];
    end
    TrainSim_all(:,:,k)=TrainSim_a;
    clear TrainSim
end
%% Initialize model related parameters
model.n_cls=ClassNum;
model.T=PassNum*TrainNum;
model.errTot=0;
model.aer=zeros(model.T,1);
model.updates = 0;
model.time = 0;
t40=0;
UPDATE_AveTime = zeros(1,model.T);
modeltime=zeros(1,model.T);
ACC_UPDATE_AER = zeros(4,41);
%% Online procedure to update model parameters
for i=1:PassNum
    for counter =1: TrainNum
        if i==1 && counter == 1
            IncTrainNum = 0;
            theta_line_squre = zeros(ClassNum,FeatureNum);
            theta_dimension = zeros(1,FeatureNum);
            theta_cube = 0;
            beta = zeros(TrainNum,ClassNum,FeatureNum);
            SV = []; % Support vector index recorder
            CBC = []; % To record the belonging condition of support vector with respect to each class
            all_score = zeros(1,ClassNum);   % Initalize the score collector
            s = [];
        end
        tic;
        IncTrainNum=IncTrainNum+1;
        % Use supportvectors to creat trainsim s
        if numel(SV)>0
            s=zeros(numel(SV), FeatureNum);
            s=reshape((TrainSim_all(index(SV),index(IncTrainNum),:)),size(s)) ;
            all_score = sum(sum(repmat(TrainSim_all(:,index(IncTrainNum),:),[1,ClassNum,1]).* beta,3),1);
        end
        y_true = TrainLabel(index(IncTrainNum));  % Get true label in decimal format
        score_true = all_score(y_true);
        all_score(y_true) = -inf;
        [score_pre,y_pre] = max(all_score);
        
        loss = max(1-score_true+score_pre,0);
        model.errTot=model.errTot+(score_true<=score_pre);% total errors
        model.aer(IncTrainNum) = model.errTot/IncTrainNum;% average errors rate 
        if loss>0
            CurrentBelongCondi = zeros(ClassNum,1);
            CurrentBelongCondi(y_true) = 1;
            CurrentBelongCondi(y_pre) = -1;
            CBC = horzcat(CBC,CurrentBelongCondi);
            model.updates=model.updates+1;
            
            if numel(SV)>0
                for m = 1:FeatureNum
                    for j = 1:ClassNum
                        theta_line_squre(j,m) = (theta_line_squre(j,m)+2*(1/c)*CurrentBelongCondi(j)*...
                            CBC(j,1:end-1)*s(:,m)+CurrentBelongCondi(j)^2);
                    end
                    theta_dimension(m) = (sum(theta_line_squre(:,m).^(q1/2)))^(1/q1);
                end
                theta_cube = (sum(theta_dimension(:).^(q2)))^(1/q2);
                
                for m = 1:FeatureNum
                    for j = 1: ClassNum
                        beta(index(IncTrainNum),j,m) =  beta(index(IncTrainNum),j,m)+(1/c)*(theta_cube ^(2-q2))*(theta_dimension(m)...
                            ^(q2-q1))*(theta_line_squre(j,m))^((q1-2)/2)*CBC(j,model.updates)';
                    end
                end
            end
            SV = [SV,IncTrainNum];
        end
        toc;
        model.time=model.time+toc;
        modeltime(1, IncTrainNum)=model.time;
        UPDATE_AveTime(1, IncTrainNum)=model.time/ IncTrainNum;
        if mod(IncTrainNum,TrainNum*PassNum/40)==0||IncTrainNum==TrainNum*PassNum||IncTrainNum==1
            t40=t40+1;
            ColmDemsion=ceil(TestNum/PartNumTest);
            ColmDemsion_last=TestNum-(PartNumTest-1)*ColmDemsion;  %the last part
            f_test=[];
            %% Load TestSim
            for i=1:PartNumTest
                if i==PartNumTest
                    TestSim_all=zeros(TrainNum,ColmDemsion_last,FeatureNum);
                    f_test_k=zeros(ColmDemsion_last,model.n_cls);%矩阵
                    TestNum_1=ColmDemsion_last;
                else
                    TestSim_all=zeros(TrainNum,ColmDemsion,FeatureNum);
                    f_test_k=zeros(ColmDemsion,model.n_cls);
                    TestNum_1=ColmDemsion;
                end
                
                for k = 1:FeatureNum
                    fprintf('Loading TestSim_%s_Part%d\n',ChosenFeature{k},i);
                    Const_gamma=str2num(eval(sprintf('%s_gamma{%s_index}',ChosenFeature{k},ChosenFeature{k})));
                    Dir4 = fullfile(KernelDir,sprintf('%s_gamma%.2f',ChosenFeature{k}, Const_gamma));
                    load(fullfile( Dir4, sprintf('TestSim_%s_Part%d.mat',ChosenFeature{k},i)));
                    TestSim_all(:,:,k)=TestSim';
                    clear TestSim;
                end
                
                for k = 1:TestNum_1
                    f_test_k(k,:) = sum(sum(repmat(TestSim_all(:,k,:),[1,ClassNum,1]).*...
                        beta,3),1);
                end
                f_test=[f_test;f_test_k];
            end
        
            [~,PreLabel_f]= max(f_test,[],2);
            accuracy_f = sum(TestLabel == PreLabel_f' )/TestNum;
            fprintf('###########Iteration:%d,AC_F=%.4f,errTot:%d,aer:%.4f,Updates:%d##########\n',IncTrainNum,accuracy_f,...
                model.errTot,model.aer(IncTrainNum),model.updates);
            % Record statistic information
            ACC_UPDATE_AER(1,t40) = accuracy_f;
            ACC_UPDATE_AER(2,t40) = modeltime(IncTrainNum);
            ACC_UPDATE_AER(3,t40) =  UPDATE_AveTime(IncTrainNum);
            ACC_UPDATE_AER(4,t40) =model.errTot/IncTrainNum;
            save ../ACC_UPDATE_AER.mat ACC_UPDATE_AER;
            AC_F=[AC_F,accuracy_f];
        end
    end
end
save ../UPDATE_AveTime.mat UPDATE_AveTime;
save ../modeltime.mat modeltime;