%%  Development HW2- Spring 2019
%%% Alba Miñano Mañero
%%% 29th January 2019
%% Question 1, part 1 : seasonal utility
%% CRRA preferences with eta = 2
close all
clear all
rng(1234)


%1) Set parameters
N = 1000; % Nº of households
A = 40;  % Age ( i.e. time periods)
T = 12; % Season ( 12 months)
sigmaU= 0.2;
sigmaEpsilon = 0.2; 
 
beta = 0.9992;
eta = 2; 
%2) Initialize matrices
ciHigh = zeros(N, 12, 40); % Here we store consumption: HH * month* age 
ciLow = zeros(N, 12, 40); % Here we store consumption: HH * month* age 
ciMiddle = zeros(N, 12, 40); % Here we store consumption: HH * month* age 

ui = zeros(N,1); % Error matrix

zi = zeros(N,1);  % Store the idyiosincratic component: One per household
                % Does not change over time
                
epsilon = zeros(N,12, 40); % Store the shock. HH * months* time
                            % It will be the same across months
                            % It will change over HH and across time
                            
nonSeasonal = zeros(N, 12, 40); % Store non seasonal error. No change across
                                % months
                                
                                
gmMiddle = [-0.147, -0.370, 0.141, 0.131, 0.090 , 0.058, 0.036, 0.036, 0.036, 0.002, -0.033, -0.082 ]';
       
gmHigh = [-0.293, -0.739, 0.282, 0.262, 0.180, 0.116, 0.072, 0.072, 0.072, 0.004, - 0.066, -0.164]';
        
gmLow = [ - 0.073, -0.185, 0.071, 0.066, 0.045, 0.029, 0.018, 0.018,0.018, 0.001, -0.017, -0.041]'; 



eGmHigh = zeros(12, 1); 
eGmMiddle = zeros(12, 1); 
eGmLow = zeros(12, 1); 



wZiHighTemp=zeros(N, 40) ; % Here we store utility over months for each age
wZiLowTemp=zeros(N, 40) ;
wZiMiddleTemp=zeros(N, 40) ; 



wZiHigh=zeros(N,1) ; % Here we store lifetime utility: One value per individual
wZiLow=zeros(N,1) ;
wZiMiddle=zeros(N,1) ; 

% 3) Obtain consumption.          
for i = 1:N
    ui(i,1) = lognrnd(0, sqrt(sigmaU));   %% Get ui
end 
for i = 1:N
    zi(i,1) = exp(1)^(-sigmaU/2).*ui(i,1); %% Get zi 
end 

for a = 1:A
    for i = 1:N 
        epsilon(i,:, a) = lognrnd(0, sqrt(sigmaEpsilon)); 
    end
end

for a = 1:A
    for i = 1:N
        nonSeasonal(i, :, a) = exp(1)^(-(sigmaEpsilon/2)).*epsilon(i,:, a);
    end
end

for month = 1:T 
    eGmHigh(month,1) = exp(1).^gmHigh(month);
    eGmMiddle(month,1) = exp(1).^gmMiddle(month);
    eGmLow(month,1) = exp(1).^gmLow(month);
end

for age = 1:A % For every year
    for month = 1: T % For every month
        for household = 1: N % For every household
            ciHigh(household, month, age) = zi(household)*eGmHigh(month)*nonSeasonal(household, month, age) ;
            ciLow(household, month, age) = zi(household)*eGmLow(month)*nonSeasonal(household, month, age) ;
            ciMiddle(household, month, age) = zi(household)*eGmMiddle(month)*nonSeasonal(household, month, age) ;
            end
        end
    end

%4) Discount consumption 
% 4.1) Obtain utility of consumption
for age = 1: A
    for month = 1 : T
        for household = 1: N 
            ciHigh(household, month, age) = (ciHigh(household, month, age).^(1-eta)) /(1-eta); 
            ciLow(household, month, age) = (ciLow(household, month, age).^(1-eta)) /(1-eta); 
            ciMiddle(household, month, age) = (ciMiddle(household, month, age).^(1-eta)) /(1-eta); 
        end
    end
end

for age = 1: A
    for month = 1: T
        for household = 1: N 
            ciHigh(household, month, age) = beta^(month-1).*ciHigh(household, month, age); 
            ciLow(household, month, age) = beta^(month-1).*ciLow(household, month, age); 
            ciMiddle(household, month, age) = beta^(month-1).*ciMiddle(household, month, age); 
        end
    end
end

%  5) Obtain monthly discounted utility 
for age = 1: A
    for household = 1 : N 
        wZiHighTemp(household, age) = sum(ciHigh(household, :, age), 2);  
        wZiLowTemp(household, age) = sum(ciLow(household, :, age), 2);  
        wZiMiddleTemp(household, age) = sum(ciMiddle(household, :, age), 2);      
    end
end

% 6) Discounty monthly utility 
for age = 1: A
    for household = 1 : N 
        wZiHighTemp( household, age) = beta^(12*age)*wZiHighTemp(household, age); 
        wZiLowTemp( household, age) = beta^(12*age)*wZiLowTemp(household, age); 
        wZiMiddleTemp( household, age) = beta^(12*age)*wZiMiddleTemp(household, age); 
    end
end


% 7) Obtain life time utility
for household = 1 :N
    wZiHigh(household, 1) = sum(wZiHighTemp(household, :), 2);
    wZiMiddle(household, 1) = sum(wZiMiddleTemp(household, :), 2);
    wZiLow(household, 1) = sum(wZiLowTemp(household, :), 2);
end


%% Question 1 part 1: unseasonal utility. 
% We repeat the same as before but without seasonality. 

ciNonSeasonal = zeros(N, 12, 40); % Here we store non seasonal consumption: HH * month* age 

wZiTempNonSeasonal=zeros(N, 40) ; % Here we store utility over months for each age

wZiNonSeasonal=zeros(N,1) ; % Here we store lifetime utility: One value per individual

% 3) Obtain consumption. We already have nonseasonal shocks and zi 
for age = 1:A % For every year
    for month = 1: T % For every month
        for household = 1: N % For every household
            ciNonSeasonal(household, month, age) = zi(household)*nonSeasonal(household, month, age) ;
            end
        end
    end

%4) Discount consumption 
% 4.1) Obtain utility of consumption
for age = 1: A
    for month = 1: T
        for household = 1: N
            ciNonSeasonal(household, month, age) = ciNonSeasonal(household, month, age).^(1-eta)/(1-eta);
        end
    end
end

for age = 1: A
    for month = 1: T
        for household = 1: N 
            ciNonSeasonal(household, month, age) = beta^(month-1).*ciNonSeasonal(household, month, age); 
        end
    end
end

%  5) Obtain monthly discounted utility 
for age = 1: A
    for household = 1 : N 
        wZiTempNonSeasonal(household, age) = sum(ciNonSeasonal(household, :, age), 2);       
    end
end

% 6) Discounty monthly utility 
for age = 1: A
    for household = 1 : N 
        wZiTempNonSeasonal( household, age) = beta^(12*age)*wZiTempNonSeasonal(household, age); 
    end
end


% 7) Obtain life time utility
for household = 1 :N
    wZiNonSeasonal(household, 1) = sum(wZiTempNonSeasonal(household, :), 2);
end


%% Question 1 part 1 : we compute the welfare costs 
 gHigh = zeros (N,1); % Here we store the welfare gains for each individual
 gLow = zeros(N, 1); 
 gMiddle = zeros (N,1); 
t = zeros(N, 1);

 for household = 1: N 
     gHigh(household,1) = (round(wZiNonSeasonal(household))/round(wZiHigh(household)))^(1/(1-eta)) -1;
     gLow(household,1) = (round(wZiNonSeasonal(household))/round(wZiLow(household)))^(1/(1-eta)) -1;
     gMiddle(household, 1) = (round(wZiNonSeasonal(household))/round(wZiMiddle(household)))^(1/(1-eta)) -1;
 end

 
%% Eliminating the non seasonal risk 

ciHomHigh = zeros(N, 12, 40); % Here we store seasonal homogenous consumption
ciHomLow = zeros(N, 12, 40);
ciHomMiddle = zeros(N, 12, 40);

wZiHighTempHom =zeros(N, 40) ; % Here we store utility over months for each age
wiZiLowTempHom = zeros(N,40);
wiZiMiddleTempHom = zeros(N, 40);


wiZiHighHom=zeros(N,1) ; % Here we store lifetime utility: One value per individual
wiZiLowHom = zeros(N, 1); 
wiZiMiddleHom = zeros(N, 1); 

 gHighHom = zeros (N,1); % Here we store the welfare gains for each individual
 gLowHom = zeros(N, 1); 
 gMiddleHom = zeros (N,1); 
 

 
for age = 1:A % For every year
    for month = 1: T % For every month
        for household = 1: N % For every household
            ciHomHigh(household, month, age) = zi(household)*eGmHigh(month) ;
            ciHomLow(household, month, age) = zi(household)*eGmLow(month) ;
            ciHomMiddle(household, month, age) = zi(household)*eGmMiddle(month) ;
            end
        end
end

    for age = 1: A
    for month = 1 : T
        for household = 1: N 
            ciHomHigh(household, month, age) = (ciHomHigh(household, month, age).^(1-eta)) /(1-eta); 
            ciHomLow(household, month, age) = (ciHomLow(household, month, age).^(1-eta)) /(1-eta); 
            ciHomMiddle(household, month, age) = (ciHomMiddle(household, month, age).^(1-eta)) /(1-eta); 
        end
    end
    end


    
for age = 1: A
    for month = 1: T
        for household = 1: N 
            ciHomHigh(household, month, age) = beta^(month-1).*ciHomHigh(household, month, age); 
            ciHomLow(household, month, age) = beta^(month-1).*ciHomLow(household, month, age); 
            ciHomMiddle(household, month, age) = beta^(month-1).*ciHomMiddle(household, month, age); 
        end
    end
end


for age = 1: A
    for household = 1 : N 
        wZiHighTempHom(household, age) = sum(ciHomHigh(household, :, age), 2);  
        wZiLowTempHom(household, age) = sum(ciHomLow(household, :, age), 2);  
        wZiMiddleTempHom(household, age) = sum(ciHomMiddle(household, :, age), 2);      
    end
end


for age = 1: A
    for household = 1 : N 
        wZiHighTempHom(household, age) = beta^(12*age)*wZiHighTempHom(household, age); 
        wZiLowTempHom(household, age) = beta^(12*age)*wZiLowTempHom(household, age); 
        wZiMiddleTempHom(household, age) = beta^(12*age)*wZiMiddleTempHom(household, age); 
    end
end


for household = 1 :N
    wZiHighHom(household, 1) = sum(wZiHighTempHom(household, :), 2);
    wZiMiddleHom(household, 1) = sum(wZiMiddleTempHom(household, :), 2);
    wZiLowHom(household, 1) = sum(wZiLowTempHom(household, :), 2);
end


 for household = 1: N 
     gHighHom(household,1) = (round(wZiHighHom(household))/round(wZiHigh(household)))^(1/(1-eta)) -1;
     gLowHom(household,1) = (round(wZiLowHom(household))/round(wZiLow(household)))^(1/(1-eta)) -1;
     gMiddleHom(household, 1) = (round(wZiMiddleHom(household))/round(wZiMiddle(household)))^(1/(1-eta)) -1;
 end
 %% %% Only personal differences 


ciPerHigh = zeros(N, 12, 40); % Here we store seasonal homogenous consumption
ciPerLow = zeros(N, 12, 40);
ciPerMiddle = zeros(N, 12, 40);

wZiHighTempPer =zeros(N, 40) ; % Here we store utility over months for each age
wiZiLowTempPer = zeros(N,40);
wiZiMiddleTempPer = zeros(N, 40);


wiZiHighPer=zeros(N,1) ; % Here we store lifetime utility: One value per individual
wiZiLowPer= zeros(N, 1); 
wiZiMiddlePer = zeros(N, 1); 

for age = 1:A % For every year
    for month = 1: T % For every month
        for household = 1: N % For every household
            ciPerHigh(household, month, age) = zi(household);
            ciPerLow(household, month, age) = zi(household);
            ciPerMiddle(household, month, age) = zi(household) ;
            end
        end
    end

%4) Discount consumption 

for age = 1: A
    for month = 1: T
        for household = 1: N 
            ciPerHigh(household, month, age) = beta^(month-1).*(ciPerHigh(household, month, age).^(1-eta)) /(1-eta); 
            ciPerLow(household, month, age) = beta^(month-1).*(ciPerLow(household, month, age).^(1-eta)) /(1-eta); 
            ciPerMiddle(household, month, age) = beta^(month-1).*(ciPerMiddle(household, month, age).^(1-eta)) /(1-eta); 
        end
    end
end

%  5) Obtain monthly discounted utility 
for age = 1: A
    for household = 1 : N 
        wZiHighTempPer(household, age) = sum(ciPerHigh(household, :, age), 2);  
        wZiLowTempPer(household, age) = sum(ciPerLow(household, :, age), 2);  
        wZiMiddleTempPer(household, age) = sum(ciPerMiddle(household, :, age), 2);      
    end
end

% 6) Discounty monthly utility 
for age = 1: A
    for household = 1 : N 
        wZiHighTempPer( household, age) = beta^(12*age)*wZiHighTempPer(household, age); 
        wZiLowTempPer( household, age) = beta^(12*age)*wZiLowTempPer(household, age); 
        wZiMiddleTempPer( household, age) = beta^(12*age)*wZiMiddleTempPer(household, age); 
    end
end


% 7) Obtain life time utility
for household = 1 :N
    wZiHighPer(household, 1) = sum(wZiHighTempPer(household, :), 2);
    wZiMiddlePer(household, 1) = sum(wZiMiddleTempPer(household, :), 2);
    wZiLowPer(household, 1) = sum(wZiLowTempPer(household, :), 2);
end


 gHighPer = zeros (N,1); % Here we store the welfare gains for each individual
 gLowPer = zeros(N, 1); 
 gMiddlePer = zeros (N,1); 
 

for household= 1:N
    gHighPer(household,1) = (round(wZiHighPer(household))/round(wZiHigh(household)))^(1/(1-eta)) -1;
    gLowPer(household,1) = (round(wZiLowPer(household))/round(wZiLow(household)))^(1/(1-eta)) -1;
    gMiddlePer(household,1) = (round(wZiMiddlePer(household))/round(wZiMiddle(household)))^(1/(1-eta)) -1;
end

subplot(4,1, 1)
h1 = histogram(gHighPer);
hold on
h2 = histogram(gLowPer);
hold on
h3 = histogram(gMiddlePer);
legend( [h1 h2 h3],{'High', 'Low', 'Medium'})
hold off
title('Distribution of welfare gains')

subplot (4, 1,2)
histogram(gLowPer)
title('Low Shock')

subplot (4, 1,3)
histogram(gMiddlePer)
title('Middle Shock')

subplot (4, 1,4)
histogram(gHighPer)
title('High Shock')

subplot(4,1,1)
h1 = histogram(gHighHom);
hold on
h2 = histogram(gLowHom);
hold on
h3 = histogram(gMiddleHom);
legend( [h1 h2 h3],{'High', 'Low', 'Medium'})
hold off
title ('Distribution of welfare gains')

subplot (4, 1,2)
histogram(gLowHom)
title('Low Shock')

subplot (4, 1,3)
histogram(gMiddleHom)
title('Middle Shock')

subplot (4, 1,4)
histogram(gHighHom)
title('High Shock')