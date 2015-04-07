%************************************** ****************
% Function description: Configure global variables  before running the
% mainbody of TripleReg-MKL 20150405
% *******************************************************
%% Directory Name
CurrentDir= fileparts( mfilename('fullpath') );
Current_dataset='TripleReg-MKL-Github';
WorkDir='C:\Applied Soft Computing´¦Àí\20150313-ÐÞ¸Ä\';
Result_dir = 'Result';
FeatureData = 'FeatureData';
OriginalIMG_dir = 'SourceIMG';
AllFeature={'D_hsv';'D_hog';'D_siftint';'D_siftbdy'};
%% All the kernel types
AllSimWay = {'spm';'eucli';'chi2'};
%% Single or combined feature(s) used in the current run
FeaIndex = [3;2;1;4];
%% Kernel type selected for the current run
SimIndex = [3;3;3;3];
%% Mutlipasses
PassNum = 40;
%% Feature numbers selected
FeatureNum=size(FeaIndex,1);
%% Feature(s) and kernel type(s) selected
ChosenFeature = cell(FeatureNum,1);
ChosenSim = cell(FeatureNum,1);
for n=1:FeatureNum
    ChosenFeature{n}=AllFeature{FeaIndex(n)};
end
for n=1:FeatureNum
    ChosenSim{n} = AllSimWay{SimIndex(n)};
end
%% choose the number of trainning images
nrTrainImages = {'5';'10';'15';'20';'25';'30';'40';'45';'60';'80'};
nrTrainIndex = [2];
TrainNum=str2num(nrTrainImages{nrTrainIndex});
%% set feature's gamma and choose one
D_hsv_gamma = {'349'};
D_hsvindex = [1];
D_hog_gamma = {'100'};
D_hogindex = [1];
D_siftint_gamma = {'160'};
D_siftintindex = [1];
D_siftbdy_gamma = {'160'};
D_siftbdyindex = [1];

D_hsv_index = size(D_hsvindex,1);
D_hog_index = size(D_hogindex,1);
D_siftint_index = size(D_siftintindex,1);
D_siftbdy_index = size(D_siftbdyindex,1);
for y=1:FeatureNum
    ChosenFeature{y}=AllFeature{FeaIndex(y)};
    Feature_para_Num=eval(sprintf('%s_index',ChosenFeature{y}));
    c=[];
    for n=1:Feature_para_Num
        a=eval(sprintf('%sindex(%d)',ChosenFeature{y},n));
        b=str2num(eval(sprintf('%s_gamma{%d}',ChosenFeature{y},a)));%Lbpindex(n)};
        c=[c,b];
        str=[sprintf('Chosen_%s_index',ChosenFeature{y}),'=c;'];
        eval(str);
    end
    eval(sprintf('%s_para_Num=%d',ChosenFeature{y},Feature_para_Num));
end
%% the result directory for different
temp_name = sprintf('trainN%s',nrTrainImages{nrTrainIndex(:)});
if FeatureNum>1
    for i=1:FeatureNum
        Const_gamma=eval(sprintf('%s_gamma{%s_index}',ChosenFeature{i},ChosenFeature{i}));
        temp_name=strcat(temp_name,'@',AllFeature{FeaIndex(i)},'_',AllSimWay{SimIndex(i)},'_',Const_gamma);
    end
    ResultDir=sprintf('MergeResult_%s',temp_name);
else
    ResultDir=sprintf('SingleResult_%s@%s_%s_%.2f',temp_name,AllFeature{FeaIndex(1)},AllSimWay{SimIndex(1)},str2num(eval(sprintf('%s_gamma{%s_index}',AllFeature{FeaIndex(1)},AllFeature{FeaIndex(1)}))));
end
%% Name the file with the train number
temp=sprintf('trainN%s',nrTrainImages{nrTrainIndex(:)});
Kernel_dir = sprintf('KernelData_%s',temp);
Distance_dir=sprintf('Distance_%s',temp);
PreMatDir=sprintf('PreMat_%s',temp);
TrainsimIndex_dir=sprintf('TrainsimIndex_%s',temp);
%% Names of all classes
Dir1 = fullfile ( WorkDir, Current_dataset, OriginalIMG_dir);
files=dir(Dir1);
AllCls = cell(numel(files)-2,1);
for i=1:numel(files)-2
    AllCls{i} = files(i+2).name;
end
Dir2=fullfile(WorkDir, Current_dataset,PreMatDir );
save(fullfile( Dir2,'AllCls.mat'),'AllCls');
%% Number of trainsim and testsim batches
PartNumTrain=2;
PartNumTest=2;
%% Regularization parameters of Oxford Flower 102 dataset
q1 = 2.2;
q2 = 3.6;
c=16;