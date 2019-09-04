%%%Description
%Neural Network
    %Structure of NNs
    %One hidden layer perceptron.
    %The Number of perceptron is 100.

%bias node excluded  

%%%Parameter Setting part
%User setting parameter
theNumOfHiddenLayerM=100;
epochNum=1000; %The Number of epoch
%epochNum=2000;
%epochNum=2;
learningRate=0.1;
%The threshold of abs(X-Y)
thresholdTrain=0.001;
thresholdTest=0.001;

%%%Data Processing part
%list import
TrainList =importdata('downgesture_train.list');
TestList =importdata('downgesture_test.list');

%Label Ytrain and Ytest making by suing List file
Ytrain=makingLabel(TrainList);
Ytest=makingLabel(TestList);

predictY=[];
totalPredictY=[];
cor=0;
eachEpochCor=[];

onlyF=0;
onlyS=0;


%test variable
test=[];
tempTest=[];

%%%Main part
%Train part(Feed Forward, Backpropagation, and W resetting) 
for re=1:epochNum
    for index=1:size(TrainList,1)
        %data import from list
        fileName=char(TrainList(index));
        pixelInputData = imread(fileName);
        %A=image(pixelInputData);
        
        
        %Input data:grayPixelInputDat
        grayPixelInputData = mat2gray(pixelInputData);
        %B=imshow(grayPixelInputData);
        gPInputDataRowIndex=size(grayPixelInputData,1);
        gPInputDataColIndex=size(grayPixelInputData,2);

        if onlyF==0
            %First, Randomly setting W 
            W{1}= weightHiddenLayerPerceptron(gPInputDataRowIndex,gPInputDataColIndex,theNumOfHiddenLayerM);
            onlyF=onlyF+1;
        end
        
        %X{1}==Input data
        X{1}=grayPixelInputData(:);
        tempTest=sum(X{1})/960;
        test=[test;tempTest];

        
        S{1}=W{1}*X{1};

        X{2}=calculateXfromS(S{1});

        if onlyS==0
            W{2}=weightHiddenLayerPerceptron(1,1,size(X{2}));
            W{2}=W{2}';
            onlyS=onlyS+1;
        end
        %S{2} is not matrix,that is just scalar.
        S{2}=W{2}*X{2};
        X{3}=exp(S{2})/(1+exp(S{2}));
        
        %check whether I need backpropagation 
        %If X{3}-Ytrain(index)==0, my prediction is correct. So I do not need it.
        %If X{3}-Ytrain(index)!=0, my prediction is wrong. So I do need it.

        %if (X{3}-Ytrain(index))==0
        if (abs(X{3}-Ytrain(index))<thresholdTrain)
            X=[];
            S=[];

            continue;
        end

        if(abs(X{3}-Ytrain(index))>=thresholdTrain)
            %Need to implement(note 4' refer)
            %Epsi is Delta. I should have wrote it as delta, not Epsi.
            Epsi=backpropagation(W,X,S,Ytrain(index));
            W=upgradeW(W,learningRate,Epsi,X);

        end

        %By using epsilon, upgrade W from bottom level.
        %Need to implement
        
        X=[];
        S=[];
    end
    index=1;
%end


    predictY=[];
    
    %Test Part
    for tIndex=1:size(TestList,1)
        
        %data import from list
        fileName=char(TestList(tIndex));
        pixelTestData = imread(fileName);
        %A=image(pixelInputData);


        %Input data:grayPixelInputDat
        grayTestData = mat2gray(pixelTestData);


        %X{1}==Input data
        X{1}=grayTestData(:);

        S{1}=W{1}*X{1};

        X{2}=calculateXfromS(S{1});


        %S{2} is not matrix,that is just scalar.
        S{2}=W{2}*X{2};
        X{3}=exp(S{2})/(1+exp(S{2}));

        %check whether I need backpropagation 
        %If X{3}-Ytrain(index)==0, my prediction is correct. So I do not need it.
        %If X{3}-Ytrain(index)!=0, my prediction is wrong. So I do need it.
        
        X{3};
        Ytest(tIndex);
        
        
        if ((X{3}>0.9 & (Ytest(tIndex)==1))| (X{3}<0.1 & (Ytest(tIndex)==0)))
        %if ((X{3}>0 & (Ytest(tIndex)==1))| (X{3}<0.05 & (Ytest(tIndex)==0)))
        %if (abs(X{3}-Ytest(tIndex)))<thresholdTest
            cor=cor+1;

        end



        predictY=[predictY;X{3}];
        

    end

    eachEpochCor=[eachEpochCor,cor];
    cor=0;
    %predictY=[];
    X=[];
    S=[];
    totalPredictY=[totalPredictY,predictY];
end

figure;
hold on;

axis([0 1000 0:1] );
hold on;
plot(1-(eachEpochCor)/size(Ytest,1),'-*');

table=[totalPredictY(:,1000),Ytest]

%percent=cor/size(Ytest,1)

