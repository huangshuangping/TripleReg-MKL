function [] = PreMat(config_file)
%% this function prepare the mat files need later
% creat names of the Image
% creat the labels of TrainSet & TestSet
% random the sequence of the TrainSet
%% load the config
eval(config_file);

%% creat the names of this dataset
% Dir = fullfile ( Work_dir, Current_dataset, AllImage_dir);
% files=dir(Dir);
% AllImage_names = cell(numel(files)-2,1);
% for i=1:numel(files)-2
% %     AllImage_names{i} = sprintf('%s.jpg',files(i+2).name);
%     AllImage_names{i} = files(i+2).name;
% end
% outFName = fullfile( Work_dir, Current_dataset,PreMatDir,'AllImage_names.mat');
% save(outFName,'AllImage_names');

% SimSizeNum = length(nrTrainIndex);
% for x =1 : SimSizeNum
%     SimSizeID = nrTrainImages{nrTrainIndex(x)};
%     SimSizeID = nrTrainImages{nrTrainIndex};    
%     load(fullfile(Work_dir, Current_dataset,PreMatDir,sprintf('caltech101_nTrain%s_N1_labels',SimSizeID)),'tr_label','te_label');
% %     eval(sprintf('epoch = epoch%d',x));
%   
%     output1 = fullfile(PreMatDir,sprintf('AllTrainOrder_rand_trainN%s.mat',SimSizeID));
%     output2 = fullfile(PreMatDir,sprintf('AllTrainLabel_rand_trainN%s.mat',SimSizeID));
%     output3 = fullfile(PreMatDir,sprintf('AllTestLabel_trainN%s.mat',SimSizeID));
%    
%     AllTrainOrder_rand = [];
%     AllTrainLabel_norm = [];
%     AllTrainLabel_rand = [];
%     AllTestLabel = [];
%     
%     %% generate the train ,test and their labels norm order from per class
%     AllTrainNum= length(tr_label);
%     AllTestNum = length(te_label);
%     %% generate the TrainLabel and TestLabel in norm order
%     for i=1:101%AllClsTotal
%         AllTrainLabel_norm = vertcat(AllTrainLabel_norm,(tr_label==i*ones(AllTrainNum,1))');
%         AllTestLabel =  vertcat(AllTestLabel,(te_label==i*ones(AllTestNum,1))');
%     end
%     
%     %% generate the random order of train sample and its label according to epoch
%     for i = 1:epoch
%         ind = randperm(AllTrainNum);
%         AllTrainOrder_rand = horzcat(AllTrainOrder_rand,ind);
%         AllTrainLabel_rand = horzcat(AllTrainLabel_rand,AllTrainLabel_norm(:,ind(:)));
%     end
%     
%     %% save as .mat
%     save(output1,'AllTrainOrder_rand');
%     save(output2,'AllTrainLabel_rand');
%     save(output3,'AllTestLabel');

% ImgDir=fullfile ( Work_dir, Current_dataset,OriginalIMG_dir);
%% inital
TestImage_names=[];
TrainImage_names=[];
AllTrainLabel=[];
AllTestLabel=[];
AllImage_names=[];
TrainNum = eval(nrTrainImages{nrTrainIndex});    
Num.Ntrain=zeros(numel(AllCls),1);
Num.Ntest=zeros(numel(AllCls),1);
Num.Ncls=zeros(numel(AllCls),1);

%% cal the TrainNum TestNum TrainLabel TestLabel
for i=1:length(AllCls)
    cls=dir(fullfile(Work_dir, Current_dataset,OriginalIMG_dir,AllCls{i}));
 % count the total num of each class   
    cls_num=numel(cls)-2;
 % count the TestNum & TrainNum of each class 
    TestNum=cls_num-TrainNum;
 % sum of TestNum & TrainNum
    Num.Ntrain(i)=TrainNum;
    Num.Ntest(i)=TestNum;
    Num.Ncls(i)=cls_num;
%% creat the TestName & TrainName of each class  
 index_Image=[1:cls_num];
 Train_index=index_Image(1,1:TrainNum);
 Test_index=index_Image(1,(TrainNum+1):cls_num); 
 % initial the t_name
 t_name=[];
 
   for j=1:cls_num
        if j<=TrainNum 
            %tr_name{ Allindex(1,j),1}= sprintf('%s_%s',AllCls{i},cls(j+2).name);
            tr_name{j,1}= sprintf('%s_%s',AllCls{i}(1:end),cls(Train_index(1,j)+2).name(1:end));
        else
            t_name{j-TrainNum,1}=sprintf('%s_%s',AllCls{i}(1:end),cls(Test_index(1,j-TrainNum)+2).name(1:end));
        end
    
   end
   AllImage_names=[AllImage_names;tr_name;t_name];
   
 index_Image=randperm(cls_num);%
 t_name=[];
 tr_name=[];
 Train_index=index_Image(1,1:TrainNum);
 Test_index=index_Image(1,(TrainNum+1):cls_num);
    for j=1:cls_num
        if j<=TrainNum 
            %tr_name{ Allindex(1,j),1}= sprintf('%s_%s',AllCls{i},cls(j+2).name);
            tr_name{j,1}= sprintf('%s_%s',AllCls{i}(1:end),cls(Train_index(1,j)+2).name(1:end));
        else
            t_name{j-TrainNum,1}=sprintf('%s_%s',AllCls{i}(1:end),cls(Test_index(1,j-TrainNum)+2).name(1:end));
        end
    
    end    
TestImage_names=[TestImage_names;t_name];
TrainImage_names=[TrainImage_names;tr_name];    
         

%% creat the TrainLabel & TestLabel of each class
    t_label=zeros(numel(AllCls),TestNum);
    tr_label=zeros(numel(AllCls),TrainNum);
    t_label(i,:)=1;
    tr_label(i,:)=1;

 % creat the AllTrainLabel & AllTestLabel   
    AllTrainLabel=[AllTrainLabel,tr_label];
    AllTestLabel=[AllTestLabel,t_label];
end

%% save results

% if(size(dir(outFName),1)~=0)
%     %check if the dictionary file exist, true then skip false then build
%     %condictionary
%     fprintf('The %s dictionary exists,skipping Dictionary forming procedure! \n',ChosenFeature{k});
% else
%     fprintf('Building %s Dictionary\n\n',ChosenFeature{k});
% 
% end

outFName = fullfile( Work_dir, Current_dataset,PreMatDir ,'AllClsNum.mat');
if(size(dir(outFName),1)~=0) fprintf('The %s exists,skipping\n','AllClsNum.mat');
else  save( outFName,'Num');   end

outFName = fullfile( Work_dir, Current_dataset,PreMatDir ,'AllTestLabel.mat');
if(size(dir(outFName),1)~=0)  fprintf('The %s exists,skipping\n','AllTestLabel.mat');  
else  save( outFName,'AllTestLabel'); end

outFName = fullfile( Work_dir, Current_dataset,PreMatDir ,'AllTrainLabel.mat');
if(size(dir(outFName),1)~=0)  fprintf('The %s exists,skipping\n','AllTrainLabel.mat'); 
else save( outFName,'AllTrainLabel'); end

outFName = fullfile( Work_dir, Current_dataset,PreMatDir,'TestImage_names.mat');
if(size(dir(outFName),1)~=0) fprintf('The %s exists,skipping\n','TestImage_names.mat');  
else save( outFName,'TestImage_names'); end

outFName = fullfile( Work_dir, Current_dataset,PreMatDir,'TrainImage_names.mat' );
if(size(dir(outFName),1)~=0) fprintf('The %s exists,skipping\n','TrainImage_names.mat');  
else save(outFName,'TrainImage_names');end

outFName = fullfile( Work_dir, Current_dataset,PreMatDir,'AllImage_names.mat');
if(size(dir(outFName),1)~=0) fprintf('The %s exists,skipping\n','AllImage_names.mat');  
else save(outFName,'AllImage_names');end 