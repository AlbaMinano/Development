%%  Development HW2- Spring 2019
%%% Alba Miñano Mañero
%%% 29th January 2019
%% Question 1, part 2 : seasonal stochastic component 
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


%2) Initialize matrices

ciHighHigh = zeros(N, 12, 40); % Here we store consumption: HH * month* age 
                                % High deterministic, high seasonal
ciHighLow = zeros(N, 12, 40);
ciHighMiddle = zeros(N, 12, 40);
                                
ciLowHigh = zeros(N, 12, 40); % Here we store consumption: HH * month* age 
ciLowLow = zeros(N, 12, 40);
ciLowMiddle = zeros(N, 12, 40);

ciMiddleHigh = zeros(N, 12, 40); % Here we store consumption: HH * month* age 
ciMiddleLow = zeros(N, 12, 40); 
ciMiddleMiddle = zeros(N, 12, 40); 

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
                                
                         
                                
gmMiddle = [-0.147, -0.370, 0.141, 0.131, 0.090 , 0.058, 0.036, 0.036, 0.036, 0.002, -0.033, -0.082 ]';
       
gmHigh = [-0.293, -0.739, 0.282, 0.262, 0.180, 0.116, 0.072, 0.072, 0.072, 0.004, - 0.066, -0.164]';
        
gmLow = [ - 0.073, -0.185, 0.071, 0.066, 0.045, 0.029, 0.018, 0.018,0.018, 0.001, -0.017, -0.041]'; 



eGmHigh = zeros(12, 1); 
eGmMiddle = zeros(12, 1); 
eGmLow = zeros(12, 1); 

wZiHighHighTemp=zeros(N, 40); % Here we store utility over months for each age and each combinatin stochastic deterministic
                                % High deterministic High stochastic
wZiHighMiddleTemp=zeros(N, 40); % High deterministic middle stochastic                              
wZiHighLowTemp=zeros(N, 40);    % High deterministic low stochastic

wZiLowHighTemp=zeros(N, 40) ; %Low deterministic, High stochastic
wZiLowMiddleTemp=zeros(N, 40) ; % Low deterministic, Middle stochastic
wZiLowLowTemp=zeros(N, 40) ; % Low deterministic,  Low stochastic 

wZiMiddleHighTemp=zeros(N, 40) ;  % Middle deterministic, high stochastic
wZiMiddleMiddleTemp=zeros(N, 40) ; %Middle deterministic, middle stochastic
wZiMiddleLowTemp=zeros(N, 40) ; % Middle deterministic, Low stochastic

wZiHighHigh=zeros(N,1); % Here we store lifetime utility: One value per individual
wZiHighMiddle=zeros(N,1);
wZiHighLow=zeros(N,1);

wZiLowHigh=zeros(N,1) ;
wZiLowMiddle=zeros(N,1) ;
wZiLowLow=zeros(N,1) ;

wZiMiddleHigh=zeros(N,1);
wZiMiddleMiddle=zeros(N,1);
wZiMiddleLow=zeros(N,1);

%Stochastic seasonal component
smMiddle = [0.085, 0.068, 0.290, 0.283, 0.273, 0.273, 0.239, 0.205, 0.188, 0.188, 0.171, 0.137]';

smLow = [0.043, 0.034, 0.145, 0.142, 0.137, 0.137 0.119, 0.102, 0.094, 0.094, 0.085, 0.068]';

smHigh = [0.171, 0.137, 0.580, 0.567, 0.546, 0.546, 0.478, 0.410, 0.376, 0.376, 0.341, 0.273]';



%% 

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
        nonSeasonal(i, :, a) = (exp(1)^(-(sigmaEpsilon/2))).*epsilon(i,:, a);
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
            miHigh(household,month,age) = lognrnd(0,sqrt(smHigh(month))); 
            miMiddle(household, month,age) = lognrnd(0, sqrt(smMiddle(month)));
            miLow(household, month, age) = lognrnd(0, sqrt(smLow(month)));
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
            ciHighHigh(household, month, age) = zi(household)*eGmHigh(month)*nonSeasonal(household, month, age)*seasonalHigh(household, month, age);
            ciHighLow(household, month, age) = zi(household)*eGmHigh(month)*nonSeasonal(household, month, age)*seasonalLow(household, month, age);
            ciHighMiddle(household, month, age) = zi(household)*eGmHigh(month)*nonSeasonal(household, month, age)*seasonalMiddle(household, month, age);
            % All combinations of high deterministic + stochastic
            
            ciLowHigh(household, month, age) = zi(household)*eGmLow(month)*nonSeasonal(household, month, age)*seasonalHigh(household, month, age);
            ciLowLow(household, month, age) = zi(household)*eGmLow(month)*nonSeasonal(household, month, age)*seasonalLow(household, month, age);
            ciLowMiddle(household, month, age) = zi(household)*eGmLow(month)*nonSeasonal(household, month, age)*seasonalMiddle(household, month, age);
            % All combinations of low deterministic + stochastic
            
            ciMiddleHigh(household, month, age) = zi(household)*eGmMiddle(month)*nonSeasonal(household, month, age)*seasonalHigh(household, month, age);
            ciMiddleLow(household, month, age) = zi(household)*eGmMiddle(month)*nonSeasonal(household, month, age)*seasonalLow(household, month, age);
            ciMiddleMiddle(household, month, age) = zi(household)*eGmMiddle(month)*nonSeasonal(household, month, age)*seasonalMiddle(household, month, age);
            
            end
        end
    end

%4) Discount consumption 
% 4.1) Obtain utility of consumption
for age = 1: A
    for month = 1 : T
        for household = 1: N 
            ciHighHigh(household, month, age) = log(ciHighHigh(household, month, age)); 
            ciHighLow(household, month, age) = log(ciHighLow(household, month, age)); 
            ciHighMiddle(household, month, age) = log(ciHighMiddle(household, month, age)); 
            
            ciLowHigh(household, month, age) = log(ciLowHigh(household, month, age)); 
            ciLowMiddle(household, month, age) = log(ciLowMiddle(household, month, age)); 
            ciLowLow(household, month, age) = log(ciLowLow(household, month, age)); 
            
            ciMiddleHigh(household, month, age) = log(ciMiddleHigh(household, month, age)); 
            ciMiddleLow(household, month, age) = log(ciMiddleLow(household, month, age)); 
            ciMiddleMiddle(household, month, age) = log(ciMiddleMiddle(household, month, age)); 
            
        end
    end
end

for age = 1: A
    for month = 1: T
        for household = 1: N 
            ciHighHigh(household, month, age) = beta^(month-1).*ciHighHigh(household, month, age); 
            ciHighLow(household, month, age) = beta^(month-1).*ciHighLow(household, month, age); 
            ciHighMiddle(household, month, age) = beta^(month-1).*ciHighMiddle(household, month, age); 

            ciLowHigh(household, month, age) = beta^(month-1).*ciLowHigh(household, month, age); 
            ciLowLow(household, month, age) = beta^(month-1).*ciLowLow(household, month, age); 
            ciLowMiddle(household, month, age) = beta^(month-1).*ciLowMiddle(household, month, age); 
            
            ciMiddleHigh(household, month, age) = beta^(month-1).*ciMiddleHigh(household, month, age); 
            ciMiddleMiddle(household, month, age) = beta^(month-1).*ciMiddleMiddle(household, month, age); 
            ciMiddleLow(household, month, age) = beta^(month-1).*ciMiddleLow(household, month, age); 
            
        end
    end
end

%  5) Obtain monthly discounted utility 
for age = 1: A
    for household = 1 : N 
        wZiHighHighTemp(household, age) = sum(ciHighHigh(household, :, age), 2); 
        wZiHighLowTemp(household, age) = sum(ciHighLow(household, :, age), 2); 
        wZiHighMiddleTemp(household, age) = sum(ciHighMiddle(household, :, age), 2); 
        

        wZiLowHighTemp(household, age) = sum(ciLowHigh(household, :, age), 2);  
        wZiLowLowTemp(household, age) = sum(ciLowLow(household, :, age), 2);  
        wZiLowMiddleTemp(household, age) = sum(ciLowMiddle(household, :, age), 2);  
        
        wZiMiddleHighTemp(household, age) = sum(ciMiddleHigh(household, :, age), 2); 
        wZiMiddleLowTemp(household, age) = sum(ciMiddleLow(household, :, age), 2); 
        wZiMiddleMiddleTemp(household, age) = sum(ciMiddleMiddle(household, :, age), 2); 
        
    end
end

% 6) Discounty monthly utility 
for age = 1: A
    for household = 1 : N 
        wZiHighHighTemp( household, age) = beta^(12*age)*wZiHighHighTemp(household, age); 
        wZiHighLowTemp( household, age) = beta^(12*age)*wZiHighLowTemp(household, age); 
        wZiHighMiddleTemp( household, age) = beta^(12*age)*wZiHighMiddleTemp(household, age); 
        
        wZiLowHighTemp( household, age) = beta^(12*age)*wZiLowHighTemp(household, age); 
        wZiLowLowTemp( household, age) = beta^(12*age)*wZiLowLowTemp(household, age); 
        wZiLowMiddleTemp( household, age) = beta^(12*age)*wZiLowMiddleTemp(household, age); 
        
        wZiMiddleHighTemp( household, age) = beta^(12*age)*wZiMiddleHighTemp(household, age);
        wZiMiddleLowTemp( household, age) = beta^(12*age)*wZiMiddleLowTemp(household, age);
        wZiMiddleMiddleTemp( household, age) = beta^(12*age)*wZiMiddleMiddleTemp(household, age);
        
    end
end


% 7) Obtain life time utility
for household = 1 :N
    wZiHighHigh(household, 1) = sum(wZiHighHighTemp(household, :), 2);
    wZiHighLow(household, 1) = sum(wZiHighLowTemp(household, :), 2);
    wZiHighMiddle(household, 1) = sum(wZiHighMiddleTemp(household, :), 2);
    
    wZiMiddleHigh(household, 1) = sum(wZiMiddleHighTemp(household, :), 2);
    wZiMiddleLow(household, 1) = sum(wZiMiddleLowTemp(household, :), 2);
    wZiMiddleMiddle(household, 1) = sum(wZiMiddleMiddleTemp(household, :), 2);
    
    wZiLowHigh(household, 1) = sum(wZiLowHighTemp(household, :), 2);
    wZiLowLow(household, 1) = sum(wZiLowLowTemp(household, :), 2);
    wZiLowMiddle(household, 1) = sum(wZiLowMiddleTemp(household, :), 2);
    
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
            ciNonSeasonal(household, month, age) = log(ciNonSeasonal(household, month, age));
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
 gHighHigh = zeros (N,1); % Here we store the welfare gains for each individual
 gHighLow = zeros (N,1);
 gHighMiddle = zeros (N,1);
 
 gLowHigh = zeros(N, 1); 
 gLowMiddle = zeros(N, 1); 
 gLowLow = zeros(N, 1); 
 
 gMiddleHigh = zeros (N,1); 
 gMiddleLow = zeros (N,1); 
 gMiddleMiddle = zeros (N,1); 
 
 aux = zeros (T, 1); 
aux2 = zeros(A, 1); 

for month = 1: T
    aux(month, 1) = beta ^(month-1);
end
for age = 1: A
    aux2(age, 1) = beta ^(12*age);
end

sumBetaMonth=sum(aux, 1);
sumBetaAge =sum(aux2, 1);



 for household = 1: N 
     gHighHigh(household,1) = exp((wZiNonSeasonal(household)-wZiHighHigh(household))/(sumBetaMonth*sumBetaAge)) -1;
     gHighLow(household,1) = exp((wZiNonSeasonal(household)-wZiHighLow(household))/(sumBetaMonth*sumBetaAge)) -1;
     gHighMiddle(household,1) = exp((wZiNonSeasonal(household)-wZiHighMiddle(household))/(sumBetaMonth*sumBetaAge))-1;
     
     gLowHigh(household,1) = exp((wZiNonSeasonal(household)-wZiLowHigh(household))/(sumBetaMonth*sumBetaAge)) -1;
     gLowLow(household,1) = exp((wZiNonSeasonal(household)-wZiLowLow(household))/(sumBetaMonth*sumBetaAge)) -1;
     gLowMiddle(household,1) = exp((wZiNonSeasonal(household)-wZiLowMiddle(household))/(sumBetaMonth*sumBetaAge)) -1;
     
     gMiddleHigh(household, 1) = exp((wZiNonSeasonal(household)-wZiMiddleHigh(household))/(sumBetaMonth*sumBetaAge)) -1;
     gMiddleLow(household, 1) = exp((wZiNonSeasonal(household)-wZiMiddleLow(household))/(sumBetaMonth*sumBetaAge)) -1;
     gMiddleMiddle(household, 1) = exp((wZiNonSeasonal(household)-wZiMiddleMiddle(household))/(sumBetaMonth*sumBetaAge)) -1;
     
 end

 
subplot(3,1,1)
h1 = histogram(gHighHigh);
hold on
h2 = histogram(gHighLow);
hold on
h3 = histogram(gHighMiddle);
legend( [h1 h2 h3],{'High-High', 'High-Low', 'High-Medium'})
hold off 
title('High detemrinistic')

subplot(3,1,2)
h1 = histogram(gLowHigh);
hold on
h2 = histogram(gLowLow);
hold on
h3 = histogram(gLowMiddle);
legend( [h1 h2 h3],{'Low-High', 'Low-Low', 'Low-Medium'})
hold off 
title('Low deterministic')

subplot(3,1,3)
h1 = histogram(gMiddleHigh);
hold on
h2 = histogram(gMiddleLow);
hold on
h3 = histogram(gMiddleMiddle);
legend( [h1 h2 h3],{'Middle-High', 'Middle-Low', 'Middle-Medium'})
hold off 
title('Middle deterministic')

%% Removing non seasonal risk 


ciHomHighHigh = zeros(N, 12, 40); % Here we store seasonal homogenous consumption
ciHomHighLow = zeros(N, 12, 40);
ciHomHighMiddle = zeros(N, 12, 40);


ciHomLowHigh = zeros(N, 12, 40);
ciHomLowLow = zeros(N, 12, 40);
ciHomLowMiddle = zeros(N, 12, 40);

ciHomMiddlehigh = zeros(N, 12, 40);
ciHomMiddleLow = zeros(N, 12, 40);
ciHomMiddleLow = zeros(N, 12, 40);

wZiHighHighTempHom =zeros(N, 40) ; % Here we store utility over months for each age
wZiHighLowTempHom =zeros(N, 40) ;
wZiHighMiddleTempHom =zeros(N, 40) ;

wiZiLowHighTempHom = zeros(N,40);
wiZiLowLowTempHom = zeros(N,40);
wiZiLowMiddleTempHom = zeros(N,40);

wiZiMiddleHighTempHom = zeros(N, 40);
wiZiMiddleLowTempHom = zeros(N, 40);
wiZiMiddleMiddleTempHom = zeros(N, 40);


wiZiHighHighHom=zeros(N,1) ; % Here we store lifetime utility: One value per individual
wiZiHighLowHom=zeros(N,1) ;
wiZiHighMiddleHom=zeros(N,1) ;

wiZiLowHighHom = zeros(N, 1); 
wiZiLowLowHom = zeros(N, 1); 
wiZiLowMiddleHom = zeros(N, 1); 

wiZiMiddleHighHom = zeros(N, 1);
wiZiMiddleLowHom = zeros(N, 1);
wiZiMiddleMiddleHom = zeros(N, 1);



 gHighHighHom = zeros (N,1); % Here we store the welfare gains for each individual
 gHighLowHom = zeros (N,1);
 gHighMiddleHom = zeros (N,1);
 
 gLowHighHom = zeros(N, 1);
 gLowLowHom = zeros(N, 1);
 gLowMiddleHom = zeros(N, 1);
 
 gMiddleHighHom = zeros (N,1);
 gMiddleMiddleHom = zeros (N,1);
 gMiddleMiddleHom = zeros (N,1);
 
 
for age = 1:A % For every year
    for month = 1: T % For every month
        for household = 1: N % For every household
            ciHomHighHigh(household, month, age) = zi(household)*eGmHigh(month)*seasonalHigh(household, month, age) ;
            ciHomHighLow(household, month, age) = zi(household)*eGmHigh(month)*seasonalLow(household, month, age) ;
            ciHomHighMiddle(household, month, age) = zi(household)*eGmHigh(month)*seasonalMiddle(household, month, age) ;
            
            ciHomLowHigh(household, month, age) = zi(household)*eGmLow(month)*seasonalHigh(household, month, age) ;
            ciHomLowLow(household, month, age) = zi(household)*eGmLow(month)*seasonalLow(household, month, age) ;
            ciHomLowMiddle(household, month, age) = zi(household)*eGmLow(month)*seasonalMiddle(household, month, age) ;
            
            ciHomMiddleHigh(household, month, age) = zi(household)*eGmMiddle(month)*seasonalHigh(household, month, age) ;
            ciHomMiddleMiddle(household, month, age) = zi(household)*eGmMiddle(month)*seasonalMiddle(household, month, age);
            ciHomMiddleLow(household, month, age) = zi(household)*eGmMiddle(month)*seasonalLow(household, month, age) ;
            
            end
        end
end

for age = 1: A
    for month = 1 : T
        for household = 1: N 
            ciHomHighHigh(household, month, age) = log(ciHomHighHigh(household, month, age)); 
            ciHomHighLow(household, month, age) = log(ciHomHighLow(household, month, age)); 
            ciHomHighMiddle(household, month, age) = log(ciHomHighMiddle(household, month, age)); 
            
            ciHomLowHigh(household, month, age) = log(ciHomLowHigh(household, month, age));
            ciHomLowLow(household, month, age) = log(ciHomLowLow(household, month, age));
            ciHomLowMiddle(household, month, age) = log(ciHomLowMiddle(household, month, age));
            
            ciHomMiddleHigh(household, month, age) = log(ciHomMiddleHigh(household, month, age)); 
            ciHomMiddleLow(household, month, age) = log(ciHomMiddleLow(household, month, age)); 
            ciHomMiddleMiddle(household, month, age) = log(ciHomMiddleMiddle(household, month, age)); 
            
        end
    end
    end


    
for age = 1: A
    for month = 1: T
        for household = 1: N 
            ciHomHighHigh(household, month, age) = beta^(month-1).*ciHomHighHigh(household, month, age); 
            ciHomHighLow(household, month, age) = beta^(month-1).*ciHomHighLow(household, month, age); 
            ciHomHighMiddle(household, month, age) = beta^(month-1).*ciHomHighMiddle(household, month, age); 
            
            ciHomLowHigh(household, month, age) = beta^(month-1).*ciHomLowHigh(household, month, age); 
            ciHomLowLow(household, month, age) = beta^(month-1).*ciHomLowLow(household, month, age); 
            ciHomLowMiddle(household, month, age) = beta^(month-1).*ciHomLowMiddle(household, month, age); 
            
            ciHomMiddleHigh(household, month, age) = beta^(month-1).*ciHomMiddleHigh(household, month, age); 
            ciHomMiddleMiddle(household, month, age) = beta^(month-1).*ciHomMiddleMiddle(household, month, age); 
            ciHomMiddleLow(household, month, age) = beta^(month-1).*ciHomMiddleLow(household, month, age); 
            
        end
    end
end


for age = 1: A
    for household = 1 : N 
        wZiHighHighTempHom(household, age) = sum(ciHomHighHigh(household, :, age), 2);
        wZiHighLowTempHom(household, age) = sum(ciHomHighLow(household, :, age), 2);
        wZiHighMiddleTempHom(household, age) = sum(ciHomHighMiddle(household, :, age), 2);
        
        
        wZiLowHighTempHom(household, age) = sum(ciHomLowHigh(household, :, age), 2);  
        wZiLowLowTempHom(household, age) = sum(ciHomLowLow(household, :, age), 2);  
        wZiLowMiddleTempHom(household, age) = sum(ciHomLowMiddle(household, :, age), 2);  
        
        wZiMiddleHighTempHom(household, age) = sum(ciHomMiddleHigh(household, :, age), 2); 
        wZiMiddleLowTempHom(household, age) = sum(ciHomMiddleLow(household, :, age), 2); 
        wZiMiddleMiddleTempHom(household, age) = sum(ciHomMiddleMiddle(household, :, age), 2); 
        
    end
end


for age = 1: A
    for household = 1 : N 
        wZiHighHighTempHom(household, age) = beta^(12*age)*wZiHighHighTempHom(household, age);
        wZiHighLowTempHom(household, age) = beta^(12*age)*wZiHighLowTempHom(household, age);
        wZiHighMiddleTempHom(household, age) = beta^(12*age)*wZiHighMiddleTempHom(household, age);
        
        wZiLowHighTempHom(household, age) = beta^(12*age)*wZiLowHighTempHom(household, age); 
        wZiLowMiddleTempHom(household, age) = beta^(12*age)*wZiLowMiddleTempHom(household, age); 
        wZiLowLowTempHom(household, age) = beta^(12*age)*wZiLowLowTempHom(household, age); 
        
        wZiMiddleHighTempHom(household, age) = beta^(12*age)*wZiMiddleHighTempHom(household, age); 
        wZiMiddleLowTempHom(household, age) = beta^(12*age)*wZiMiddleLowTempHom(household, age); 
        wZiMiddleMiddleTempHom(household, age) = beta^(12*age)*wZiMiddleMiddleTempHom(household, age); 
        
    end
end


for household = 1 :N
    wZiHighHighHom(household, 1) = sum(wZiHighHighTempHom(household, :), 2);
    wZiHighLowHom(household, 1) = sum(wZiHighLowTempHom(household, :), 2);
    wZiHighMiddleHom(household, 1) = sum(wZiHighMiddleTempHom(household, :), 2);
    
    wZiMiddleHighHom(household, 1) = sum(wZiMiddleHighTempHom(household, :), 2);
    wZiMiddleLowHom(household, 1) = sum(wZiMiddleLowTempHom(household, :), 2);
    wZiMiddleMiddleHom(household, 1) = sum(wZiMiddleMiddleTempHom(household, :), 2);
    
    wZiLowHighHom(household, 1) = sum(wZiLowHighTempHom(household, :), 2);
    wZiLowMiddleHom(household, 1) = sum(wZiLowMiddleTempHom(household, :), 2);
    wZiLowLowHom(household, 1) = sum(wZiLowLowTempHom(household, :), 2);
    
end


 for household = 1: N 
     gHighHighHom(household,1) = exp((wZiHighHighHom(household)-wZiHighHigh(household))/(sumBetaMonth*sumBetaAge)) -1;
     gHighLowHom(household,1) = exp((wZiHighLowHom(household)-wZiHighLow(household))/(sumBetaMonth*sumBetaAge)) -1;
     gHighMiddleHom(household,1) = exp((wZiHighMiddleHom(household)-wZiHighMiddle(household))/(sumBetaMonth*sumBetaAge)) -1;
     
     gLowHighHom(household,1) = exp((wZiLowHighHom(household)-wZiLowHigh(household))/(sumBetaMonth*sumBetaAge)) -1;
     gLowLowHom(household,1) = exp((wZiLowLowHom(household)-wZiLowLow(household))/(sumBetaMonth*sumBetaAge)) -1;
     gLowMiddleHom(household,1) = exp((wZiLowMiddleHom(household)-wZiLowMiddle(household))/(sumBetaMonth*sumBetaAge)) -1;
     
     gMiddleHighHom(household, 1) = exp((wZiMiddleHighHom(household)-wZiMiddleHigh(household))/(sumBetaMonth*sumBetaAge)) -1;
     gMiddleLowHom(household, 1) = exp((wZiMiddleLowHom(household)-wZiMiddleLow(household))/(sumBetaMonth*sumBetaAge)) -1;
     gMiddleMiddleHom(household, 1) = exp((wZiMiddleMiddleHom(household)-wZiMiddleMiddle(household))/(sumBetaMonth*sumBetaAge)) -1;
     
 end

subplot(3,1,1)
h1 = histogram(gHighHighHom);
hold on
h2 = histogram(gHighLowHom);
hold on
h3 = histogram(gHighMiddleHom);
legend( [h1 h2 h3],{'High-High', 'High-Low', 'High-Medium'})
hold off 
title('High detemrinistic')

subplot(3,1,2)
h1 = histogram(gLowHighHom);
hold on
h2 = histogram(gLowLowHom);
hold on
h3 = histogram(gLowMiddleHom);
legend( [h1 h2 h3],{'Low-High', 'Low-Low', 'Low-Medium'})
hold off 
title('Low deterministic')

subplot(3,1,3)
h1 = histogram(gMiddleHighHom);
hold on
h2 = histogram(gMiddleLowHom);
hold on
h3 = histogram(gMiddleMiddleHom);
legend( [h1 h2 h3],{'Middle-High', 'Middle-Low', 'Middle-Medium'})
hold off 
title('Middle deterministic')