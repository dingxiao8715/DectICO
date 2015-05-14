%% ======================================
global parameter;
parameter = load('selection.txt');
global parameter_length;
parameter_length = length(parameter);
filename_tr = input('Please input the filename of the training feature maxtrix:','s');
vector_number11=input('Please input the number of positive samples:');
vector_number22=input('Please input the number of negative samples:');
filename='tr.txt';
vector_number2=num2str(vector_number11+vector_number22-1);
vector_number1=num2str(vector_number11);
fes_str='features_';
fe_str='feature_';
fe_txt='.txt';
fe_pl='.pl';
vector_number=vector_number11+vector_number22;
yapp(vector_number)=2;
%% ======================================
creat_perl=perl ('perl_tr.pl',filename_tr);
filename_pl='tr_pl.pl';
fid=fopen(filename_pl,'wt+');
fprintf(fid,'%s\n',creat_perl);
perl (filename_pl);
%% ======================================
for i=1:vector_number11
    yapp(i)=1;
end
for i=1:vector_number22
    yapp(i+vector_number11)=2;
end
yapp=yapp';
tmp=importdata(filename);
xapp=tmp.data';
FeatureNames=tmp.textdata(:,1);
FeatureNames(1,:)=[];
clear tmp;
save pls.mat;
%% ======================================
clearvars -except vector_number1 vector_number2;
clc
load pls
 Filename_txt{ parameter_length }='0';
 Filename_pl{ parameter_length }='0';
 Filename_cv{ parameter_length }='0';
%% ======================================
fopen('n.bat','wt+');
for i_select=1: parameter_length
    fes_str='features_';
    fe_str='feature_';
    model_str='model_';
    fe_txt='.txt';
    fe_pl='.pl';
    fe_cv='_cv.txt';
    num_SelectedGenes = parameter(i_select);
    Filename_txt{ i_select } = [fes_str,num2str(parameter(i_select)),fe_txt];
    Modelname_txt{ i_select } = [model_str,num2str(parameter(i_select))];
    Filename_pl{ i_select } = [fe_str,num2str(parameter(i_select)),fe_pl];
    Filename_cv{ i_select } = [num2str(parameter(i_select)),fe_cv];

    %% ======================================
    X = normalizemeanstd( xapp );

    Y = binarize( yapp );

    num_Component = 10;
    alpha = 1;
    coef = 0.1;


    Kxx = kernel( X, X, 'polynomial', alpha, coef );
    Kxy = kernel( X, X([1:2:size(X,1)], : ), 'polynomial', alpha, coef );

    [ kplsXS ] = kernelPLS( Kxx, Kxy, Y, num_Component );

    kX0 = X - ones( size(X,1), 1 )*mean( X );
    kWeight = pinv( kX0 )*kplsXS;

    kVIP = calVIP( Y, kplsXS( :, 1:num_Component ), kWeight( :, 1:num_Component ) );

    [ ~, FeatureRank ] = sort( kVIP, 'descend' );


    for i = 1:num_SelectedGenes
        SelectedGenes{ i } = FeatureNames{ FeatureRank( i ) };
    end
    %% ======================================

    features=SelectedGenes';
    [m,n]=size(features);
    fid=fopen(Filename_txt{ i_select },'wt+');
    for i=1:1:m
        a=features{i,1};
        fprintf(fid,'%s\n',a);
    end
    creat_perl=perl ('creatbat_first.pl',filename,Filename_txt{ i_select },Filename_cv{ i_select },vector_number1,vector_number2,Modelname_txt{ i_select });
    fid=fopen('n.bat','at+');
    fprintf(fid,'%s\n',creat_perl);
    creat_perl=perl ('perl.pl',filename,Filename_txt{ i_select });
    fid=fopen(Filename_pl{ i_select },'wt+');
    fprintf(fid,'%s\n',creat_perl);
    perl (Filename_pl{ i_select });
%     pause(5);
    clearvars -except Filename_txt Filename_pl i_select parameter parameter_length filename vector_number vector_number1 vector_number2;
    load('pls.mat','xapp','yapp','filename');
    tmp=importdata('fea.txt');
    xapp=tmp.data';
    FeatureNames=importdata(Filename_txt{ i_select });
    save ('pls.mat','xapp','yapp','filename');
    fclose('all');

%     system('del fea.txt');
end
creat_perl=perl ('creatbat_second.pl');
fid=fopen('n.bat','at+');
fprintf(fid,'%s\n',creat_perl);

%% end======================================
fclose('all');
system('del feature_*.pl');
system('del fea.txt');
clear all;
%% do svm======================================
system ('n.bat');
clear all;
clc;
system('del pls.mat');
system('del n.bat');
system('del tr.txt');
system('del tr_pl.pl');