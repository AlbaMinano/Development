%%  Development HW2- Spring 2019
%%% Alba Miñano Mañero
%%% 29th January 2019
%% Question 1, part 2 : seasonal stochastic component 
%% CRRA preferences with eta = 4
close all
clear all
rng(1234)


%1) Set parameters
N = 1000; % Nº of households
A = 40;  % Age ( i.e. time periods)
T = 12; % Season ( 12 months)
sigmaU= 0.2;
sigmaEpsilon = 0.4; 
beta = 0.964;
eta = 4; 
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


miHigh = zeros(N, 12, 40 ); % Store seasonal error. It will change acros months
                            % because we will draw from a distribution where
                            % the variance is difference each month. 
miLow = zeros(N, 12,40);
miMiddle=zeros(N, 12, 40); 

seasonalHigh = zeros(N, 12, 40); % Store seasonal component. Changes across months.                           
seasonalLow = zeros(N, 12, 40);
seasonalMiddle = zeros(N, 12, 40);

nonSeasonal = zeros(N, 12, 40); % Store non seasonal error. No change across
                                % months
                                
gmMiddle = [-0.15, -0.37, -0.14, 0.13, 0.09 , 0.06, 0.04, 0.04, 0.04, 0.00, -0.03, -0.08 ]';
       
gmHigh = [-0.29, -0.74, 0.28, 0.26, 0.18, 0.12, 0.07, 0.07, 0.07, 0.00, - 0.07, -0.16]';
        
gmLow = [ - 0.07, -0.18, 0.07, 0.07, 0.04, 0.03, 0.02, 0.02, 0.02, 0.00, -0.02, - 0.04]'; 


eGmHigh = zeros(12, 1); 
eGmMiddle = zeros(12, 1); 
eGmLow = zeros(12, 1); 



wZiHighTemp=zeros(N, 40) ; % Here we store utility over months for each age
wZiLowTemp=zeros(N, 40) ;
wZiMiddleTemp=zeros(N, 40) ; 



wZiHigh=zeros(N,1) ; % Here we store lifetime utility: One value per individual
wZiLow=zeros(N,1) ;
wZiMiddle=zeros(N,1) ; 

%Stochastic seasonal component
smMiddle = [0.085, 0.068, 0.290, 0.283, 0.273, 0.273, 0.239, 0.205, 0.188, 0.188, 0.171, 0.137];

smLow = [0.043, 0.034, 0.145, 0.142, 0.137, 0.137 0.119, 0.102, 0.094, 0.094, 0.085, 0.068];

smHigh = [0.171, 0.137, 0.580, 0.567, 0.546, 0.546, 0.478, 0.410, 0.376, 0.376, 0.341, 0.273];



%% 

% 3) Obtain consumption.          
for i = 1:N
    ui(i,1) = lognrnd(0, sigmaU);   %% Get ui
end 
for i = 1:N
    zi(i,1) = exp(1)^(sigmaU/2).*ui(i,1); %% Get zi 
end 

for a = 1:A
    for i = 1:N 
        epsilon(i,:, a) = lognrnd(0, sigmaEpsilon); 
    end
end

for a = 1:A
    for i = 1:N
        nonSeasonal(i, :, a) = exp(1)*(-(sigmaEpsilon/2)).*epsilon(i,:, a);
    end
end

for month = 1:T 
    eGmHigh(month,1) = exp(1).^gmHigh(month);
    eGmMiddle(month,1) = exp(1).^gmMiddle(month);
    eGmLow(month,1) = exp(1).^gmLow(month);
end


for age = 1:A
    for month = 1:T
        for household = 1: N
            miHigh(household,month,age) = lognrnd(0,smHigh(month)); 
            miMiddle(household, month,age) = lognrnd(0, smMiddle(month));
            miLow(household, month, age) = lognrnd(0, smLow(month));
        end
    end
end

for age = 1: A
    for month = 1: T
        for household = 1 : N
            seasonalHigh(household, month, age) = exp(1)^(-smHigh(month)/2).*miHigh(household, month,age);
            seasonalLow(household, month, age) = exp(1)^(-smLow(month)/2).*miLow(household, month,age);
            seasonalMiddle(household, month, age) = exp(1)^(-smMiddle(month)/2).*miMiddle(household, month,age);
        end
    end
end

            

for age = 1:A % For every year
    for month = 1: T % For every month
        for household = 1: N % For every household
            ciHigh(household, month, age) = zi(household)*eGmHigh(month)*nonSeasonal(household, month, age)*seasonalHigh(household, month, age);
            ciLow(household, month, age) = zi(household)*eGmLow(month)*nonSeasonal(household, month, age)*seasonalLow(household, month, age);
            ciMiddle(household, month, age) = zi(household)*eGmMiddle(month)*nonSeasonal(household, month, age)*seasonalMiddle(household, month, age);
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

histogram(wZiHigh)
hold on
histogram (wZiMiddle)
hold on
histogram (wZiLow)
hold off 

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

histogram(wZiLow)
hold on
histogram (wZiNonSeasonal)
hold off

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

 


h1 = histogram(gHigh);
hold on
h2 = histogram(gLow);
hold on
h3 = histogram(gMiddle);
legend( [h1 h2 h3],{'High', 'Low', 'Medium'})