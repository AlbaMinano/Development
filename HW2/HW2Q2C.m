%%  Development HW2- Spring 2019
%%% Alba Miñano Mañero
%%% 29th January 2019
%% Question 2, part 1: Positive correlation between LS and consumption seasonality
% NOTE: no correlation between non seasonal shock 
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
v = 1; 

%Calibration  of kappa
theta = 0.66;
yc = 1/0.5;
hm = 28.5*(30/7);

kappa = (theta*yc)*(1/(hm^2));
%2) Initialize matrices

%2.1) Consumption
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

% 2.2) Labour 
hiHighHigh = zeros(N, 12, 40); % Here we store consumption: HH * month* age 
                                % High deterministic, high seasonal
hiHighLow = zeros(N, 12, 40);
hiHighMiddle = zeros(N, 12, 40);
                                
hiLowHigh = zeros(N, 12, 40); % Here we store consumption: HH * month* age 
hiLowLow = zeros(N, 12, 40);
hiLowMiddle = zeros(N, 12, 40);

hiMiddleHigh = zeros(N, 12, 40); % Here we store consumption: HH * month* age 
hiMiddleLow = zeros(N, 12, 40); 
hiMiddleMiddle = zeros(N, 12, 40); 
 

%2.3) Errors

ui = zeros(N,1); % Error matrix



zi = zeros(N,1);  % Store the idyiosincratic component: One per household
                % Does not change over time              
                
epsilon = zeros(N,12, 40); % Store the shock. HH * months* time
                            % It will be the same across months
                            % It will change over HH and across time
epsilon_l = zeros(N, 12,40);                            

%2.4) Seasonality in consumption
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


%Stochastic seasonal component
smMiddle = [0.085, 0.068, 0.290, 0.283, 0.273, 0.273, 0.239, 0.205, 0.188, 0.188, 0.171, 0.137]';

smLow = [0.043, 0.034, 0.145, 0.142, 0.137, 0.137 0.119, 0.102, 0.094, 0.094, 0.085, 0.068]';

smHigh = [0.171, 0.137, 0.580, 0.567, 0.546, 0.546, 0.478, 0.410, 0.376, 0.376, 0.341, 0.273]';



%2.5) Seasonality in labour
lMiHigh = miHigh;
lMiLow = miLow;
lMiMiddle = miMiddle;

lmMiddle=gmMiddle;
lmHigh=gmHigh;
lmLow=gmLow;

eLmHigh = eGmHigh;
eLmLow = eGmLow;
eLmMiddle = eGmMiddle;

liSmMiddle =smMiddle;
liSmLow =smLow; 
liSmHigh = smHigh; 

lsSeasonalHigh = seasonalHigh;
lsSeasonalLow = seasonalLow;
lsSeasonalMiddle = seasonalMiddle;

lsNonSeasonal = nonSeasonal; 
%2.6) Matrices to store life time utility. 

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


%% 3) Obtain consumption

% 3) Obtain consumption. 

for i = 1:N
    ui(i,1) = lognrnd(0, sqrt(sigmaU));   %% Get ui
end 
for i = 1:N
    zi(i,1) = exp(1)^(-sigmaU/2).*ui(i,1); %% Get zi 
end 

mu = [0 0];

for a = 1:A
    for i = 1:N 
        sigmaEpsilon_cov= [sigmaEpsilon 0; 0 sigmaEpsilon];
        ee = mvnrnd(mu, sigmaEpsilon_cov,1); 
        epsilon(i,:,a) = exp(ee(1));
        epsilon_l(i,:,a) = exp(ee(2));
    end
end


for a = 1:A
    for i = 1:N
        nonSeasonal(i, :, a) = (exp(1)^(-(sigmaEpsilon/2))).*epsilon(i,:, a);
        lsNonSeasonal(i,:,a) = (exp(1)^(-(sigmaEpsilon/2))).*epsilon_l(i,:, a);
    end
end

for month = 1:T 
    eGmHigh(month,1) = exp(1).^gmHigh(month);
    eGmMiddle(month,1) = exp(1).^gmMiddle(month);
    eGmLow(month,1) = exp(1).^gmLow(month);
end


for age = 1:A
    for month = 1:T
        for household = 1:N
            sigmaHigh = [smHigh(month) smHigh(month);smHigh(month) smHigh(month)];
            r = mvnrnd(mu, sigmaHigh,1);
            miHigh(household, month, age) = exp(r(1));
            lMiHigh(household, month, age) =exp(r(2));
            sigmaLow = [smLow(month) smLow(month);smLow(month) smLow(month)];
            rlow = mvnrnd(mu, sigmaLow, 1);
            miLow(household, month, age) = exp(rlow(1));
            lMiLow(household, month, age) = exp(rlow(2));
            sigmaMiddle = [smMiddle(month) smMiddle(month);smMiddle(month) smMiddle(month)];
            rmiddle = mvnrnd(mu, sigmaMiddle, 1);
            miMiddle(household, month, age) = exp(rmiddle(1));
            lMiMiddle(household, month, age) = exp(rmiddle(2));
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

for month = 1:T 
    eLmHigh(month,1) = exp(1).^(-gmHigh(month));
    eLmMiddle(month,1) = exp(1).^(-gmMiddle(month));
    eLmLow(month,1) = exp(1).^(-gmLow(month));
end


for age = 1: A
    for month = 1: T
        for household = 1 : N
            lsSeasonalHigh(household, month, age) = exp(1)^(-smHigh(month)/2).*lMiHigh(household, month,age);
            lsSeasonalLow(household, month, age) = exp(1)^(-smLow(month)/2).*lMiLow(household, month,age);
            lsSeasonalMiddle(household, month, age) = exp(1)^(-smMiddle(month)/2).*lMiMiddle(household, month,age);
        end
    end
end

            

for age = 1:A % For every year
    for month = 1: T % For every month
        for household = 1: N % For every household
            hiHighHigh(household, month, age) = (zi(household)*eLmHigh(month)*lsNonSeasonal(household, month, age)*lsSeasonalHigh(household, month, age))*hm;
            hiHighLow(household, month, age) = (zi(household)*eLmHigh(month)*lsNonSeasonal(household, month, age)*lsSeasonalLow(household, month, age))*hm;
            hiHighMiddle(household, month, age) = (zi(household)*eLmHigh(month)*lsNonSeasonal(household, month, age)*lsSeasonalMiddle(household, month, age))*hm;
            % All combinations of high deterministic + stochastic
            
            hiLowHigh(household, month, age) = (zi(household)*eLmLow(month)*lsNonSeasonal(household, month, age)*lsSeasonalHigh(household, month, age))*hm;
            hiLowLow(household, month, age) = (zi(household)*eLmLow(month)*lsNonSeasonal(household, month, age)*lsSeasonalLow(household, month, age))*hm;
            hiLowMiddle(household, month, age) = (zi(household)*eLmLow(month)*lsNonSeasonal(household, month, age)*lsSeasonalMiddle(household, month, age))*hm;
            % All combinations of low deterministic + stochastic
            
            hiMiddleHigh(household, month, age) = (zi(household)*eLmMiddle(month)*lsNonSeasonal(household, month, age)*lsSeasonalHigh(household, month, age))*hm;
            hiMiddleLow(household, month, age) = (zi(household)*eLmMiddle(month)*lsNonSeasonal(household, month, age)*lsSeasonalLow(household, month, age))*hm;
            hiMiddleMiddle(household, month, age) =( zi(household)*eLmMiddle(month)*lsNonSeasonal(household, month, age)*lsSeasonalMiddle(household, month, age))*hm;
            
            end
        end
end

%Need to rescale labour supply 
%% Discount to get life time utility

    
%4) Discount consumption 
% 4.1) Obtain utility of consumption and leisure
for age = 1: A
    for month = 1 : T
        for household = 1: N 
            %Consumption
            ciHighHigh(household, month, age) = log(ciHighHigh(household, month, age)); 
            ciHighLow(household, month, age) = log(ciHighLow(household, month, age)); 
            ciHighMiddle(household, month, age) = log(ciHighMiddle(household, month, age)); 
            
            ciLowHigh(household, month, age) = log(ciLowHigh(household, month, age)); 
            ciLowMiddle(household, month, age) = log(ciLowMiddle(household, month, age)); 
            ciLowLow(household, month, age) = log(ciLowLow(household, month, age)); 
            
            ciMiddleHigh(household, month, age) = log(ciMiddleHigh(household, month, age)); 
            ciMiddleLow(household, month, age) = log(ciMiddleLow(household, month, age)); 
            ciMiddleMiddle(household, month, age) = log(ciMiddleMiddle(household, month, age)); 
            
            %Leisure 
            hiHighHigh(household, month, age) = kappa * ((hiHighHigh(household, month, age)^2)/2); 
            hiHighLow(household, month, age) = kappa*((hiHighLow(household, month, age)^2)/2); 
            hiHighMiddle(household, month, age) = kappa*((hiHighMiddle(household, month, age)^2)/2); 
            
            hiLowHigh(household, month, age) = kappa*((hiLowHigh(household, month, age)^2)/2); 
            hiLowMiddle(household, month, age) = kappa*((hiLowMiddle(household, month, age)^2)/2); 
            hiLowLow(household, month, age) = kappa*((hiLowLow(household, month, age)^2)/2); 
            
            hiMiddleHigh(household, month, age) = kappa*((hiMiddleHigh(household, month, age)^2)/2); 
            hiMiddleLow(household, month, age) = kappa*((hiMiddleLow(household, month, age)^2)/2); 
            hiMiddleMiddle(household, month, age) = kappa*((hiMiddleMiddle(household, month, age)^2)/2); 
        end
    end
end

for age = 1: A
    for month = 1: T
        for household = 1: N 
            ciHighHigh(household, month, age) = beta^(month-1).*(ciHighHigh(household, month, age)-hiHighHigh(household, month, age)); 
            ciHighLow(household, month, age) = beta^(month-1).*(ciHighLow(household, month, age)-hiHighLow(household, month, age)); 
            ciHighMiddle(household, month, age) = beta^(month-1).*(ciHighMiddle(household, month, age)-hiHighMiddle(household, month,age)); 

            ciLowHigh(household, month, age) = beta^(month-1).*(ciLowHigh(household, month, age)-hiLowHigh(household,month,age)); 
            ciLowLow(household, month, age) = beta^(month-1).*(ciLowLow(household, month, age)-hiLowLow(household,month,age)); 
            ciLowMiddle(household, month, age) = beta^(month-1).*(ciLowMiddle(household, month, age)-hiLowMiddle(household, month,age)); 
            
            ciMiddleHigh(household, month, age) = beta^(month-1).*(ciMiddleHigh(household, month, age)-hiMiddleHigh(household,month,age)); 
            ciMiddleMiddle(household, month, age) = beta^(month-1).*(ciMiddleMiddle(household, month, age)-hiMiddleMiddle(household, month,age)); 
            ciMiddleLow(household, month, age) = beta^(month-1).*(ciMiddleLow(household, month, age)-hiMiddleLow(household, month, age)); 
            
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
liNonSeasonal = zeros(N, 12, 40); % Her we store non seasonal labour
temp = zeros(N,12,40); % To add ci and li non seasonal
tempCi= zeros(N,12,40);


tempCiHH= zeros(N,12,40);
tempCiHL = zeros(N,12,40);
tempCiHM = zeros(N, 12, 40); 
tempCiLH= zeros(N,12,40);
tempCiLL = zeros(N,12,40);
tempCiLM = zeros(N, 12, 40); 
tempCiMH= zeros(N,12,40);
tempCiML = zeros(N,12,40);
tempCiMM = zeros(N, 12, 40); 




wZiTempNonSeasonal=zeros(N, 40) ; % Here we store utility over months for each age
wZiNonSeasonal=zeros(N,1) ; % Here we store lifetime utility: One value per individual

wZiTempNonSeasonalConsHH = zeros(N, 40); % We need to store also welfare deseasonalizing only c. We have 
                                        % 9 of this, one for each level of
                                        % seasonal deterministic-stochastic
                                        % on the labour supply
                                        
wZiTempNonSeasonalConsHL = zeros(N, 40);
wZiTempNonSeasonalConsHM = zeros(N, 40);
wZiTempNonSeasonalConsLH = zeros(N, 40);
wZiTempNonSeasonalConsLM = zeros(N, 40);
wZiTempNonSeasonalConsLL = zeros(N, 40);
wZiTempNonSeasonalConsMH = zeros(N, 40);
wZiTempNonSeasonalConsML = zeros(N, 40);
wZiTempNonSeasonalConsMM = zeros(N, 40);

wZiNonSeasonalConsHH = zeros(N, 1);  % 9 of this also
wZiNonSeasonalConsHL = zeros(N,1);  
wZiNonSeasonalConsHM = zeros(N,1);  

wZiNonSeasonalConsLH = zeros(N,1);  
wZiNonSeasonalConsLL = zeros(N,1);  
wZiNonSeasonalConsLM = zeros(N, 1);  

wZiNonSeasonalConsMH = zeros(N,1);  
wZiNonSeasonalConsML = zeros(N,1);  
wZiNonSeasonalConsMM = zeros(N, 1);  


% 3) Obtain consumption. We already have nonseasonal shocks and zi 
for age = 1:A % For every year
    for month = 1: T % For every month
        for household = 1: N % For every household
            ciNonSeasonal(household, month, age) = zi(household)*nonSeasonal(household, month, age) ;
            liNonSeasonal(household, month, age) = zi(household)*lsNonSeasonal(household,month,age)*hm;
            end
        end
    end

%4) Discount consumption 
% 4.1) Obtain utility of consumption
for age = 1: A
    for month = 1: T
        for household = 1: N
            ciNonSeasonal(household, month, age) = log(ciNonSeasonal(household, month, age));
            liNonSeasonal(household,month,age) = kappa *((liNonSeasonal(household,month,age)^2)/2);
        end
    end
end

for age = 1: A
    for month = 1: T
        for household = 1: N 
            ciNonSeasonal(household, month, age) = beta^(month-1).*ciNonSeasonal(household, month, age);
            liNonSeasonal(household, month,age) = beta^(month-1).*liNonSeasonal(household,month,age);
        end
    end
end

for age = 1:A
    for month = 1:T
        for household = 1:N
            temp(household, month,age) =ciNonSeasonal(household,month,age) - liNonSeasonal(household,month,age);
        end
    end
end

% We need to obtain the utilities for de seasonalized C and seasonal Ls 


for age= 1:A
    for month = 1:T
        for household = 1:N
          tempCiHH(household,month,age) = ciNonSeasonal(household,month,age) - beta^(month-1)*hiHighHigh(household, month, age);
          tempCiHL(household,month,age) = ciNonSeasonal(household,month,age) - beta^(month-1)*hiHighLow(household, month, age);
          tempCiHM(household,month,age) = ciNonSeasonal(household,month,age) - beta^(month-1)*hiHighMiddle(household, month, age);
          
          tempCiLH(household,month,age) = ciNonSeasonal(household,month,age) - beta^(month-1)*hiLowHigh(household, month, age);
          tempCiLL(household,month,age) = ciNonSeasonal(household,month,age) - beta^(month-1)*hiLowLow(household, month, age);
          tempCiLM(household,month,age) = ciNonSeasonal(household,month,age) - beta^(month-1)*hiLowMiddle(household, month, age);
          
          tempCiMH(household,month,age) = ciNonSeasonal(household,month,age) - beta^(month-1)*hiMiddleHigh(household, month, age);
          tempCiML(household,month,age) = ciNonSeasonal(household,month,age) - beta^(month-1)*hiMiddleLow(household, month, age);
          tempCiMM(household,month,age) = ciNonSeasonal(household,month,age) - beta^(month-1)*hiMiddleMiddle(household, month, age);
          
        end
    end
end



%  5) Obtain monthly discounted utility 
for age = 1: A
    for household = 1 : N 
        wZiTempNonSeasonalCons(household, age) = sum(ciNonSeasonal(household, :, age), 2);
        wZiTempNonSeasonal(household,age)=sum(temp(household,:,age),2);
        
        wZiTempNonSeasonalConsHH(household,age) = sum(tempCiHH(household,:,age),2);
        wZiTempNonSeasonalConsHL(household,age) = sum(tempCiHL(household,:,age),2);
        wZiTempNonSeasonalConsHM(household,age) = sum(tempCiHM(household,:,age),2);
        
        wZiTempNonSeasonalConsLH(household,age) = sum(tempCiLH(household,:,age),2);
        wZiTempNonSeasonalConsLL(household,age) = sum(tempCiLL(household,:,age),2);
        wZiTempNonSeasonalConsLM(household,age) = sum(tempCiLM(household,:,age),2);
        
        wZiTempNonSeasonalConsMH(household,age) = sum(tempCiMH(household,:,age),2);
        wZiTempNonSeasonalConsML(household,age) = sum(tempCiML(household,:,age),2);
        wZiTempNonSeasonalConsMM(household,age) = sum(tempCiMM(household,:,age),2);
        
    end
end

% 6) Discounty monthly utility 
for age = 1: A
    for household = 1 : N 
        wZiTempNonSeasonalCons( household, age) = beta^(12*age)*wZiTempNonSeasonalCons(household, age); 
        wZiTempNonSeasonal(household,age) = beta^(12*age)*wZiTempNonSeasonal(household,age);
        
        wZiTempNonSeasonalConsHH(household, age) = beta^(12*age)*wZiTempNonSeasonalConsHH(household,age);
        wZiTempNonSeasonalConsHL(household, age) = beta^(12*age)*wZiTempNonSeasonalConsHL(household,age);
        wZiTempNonSeasonalConsHM(household, age) = beta^(12*age)*wZiTempNonSeasonalConsHM(household,age);
        
        wZiTempNonSeasonalConsLH(household, age) = beta^(12*age)*wZiTempNonSeasonalConsLH(household,age);
        wZiTempNonSeasonalConsLL(household, age) = beta^(12*age)*wZiTempNonSeasonalConsLL(household,age);
        wZiTempNonSeasonalConsLM(household, age) = beta^(12*age)*wZiTempNonSeasonalConsLM(household,age);
        
        wZiTempNonSeasonalConsMH(household, age) = beta^(12*age)*wZiTempNonSeasonalConsMH(household,age);
        wZiTempNonSeasonalConsML(household, age) = beta^(12*age)*wZiTempNonSeasonalConsML(household,age);
        wZiTempNonSeasonalConsMM(household, age) = beta^(12*age)*wZiTempNonSeasonalConsMM(household,age);
        
    end
end


% 7) Obtain life time utility
for household = 1 :N
    wZiNonSeasonal(household, 1) = sum(wZiTempNonSeasonal(household, :), 2);
    wZiNonSeasonalCons(household,1) = sum(wZiTempNonSeasonalCons(household,:),2);
    
    wZiNonSeasonalConsHH(household,1) = sum(wZiTempNonSeasonalConsHH(household,:),2);
    wZiNonSeasonalConsHL(household,1) = sum(wZiTempNonSeasonalConsHL(household,:),2);
    wZiNonSeasonalConsHM(household,1) = sum(wZiTempNonSeasonalConsHM(household,:),2);
    
    wZiNonSeasonalConsLH(household,1) = sum(wZiTempNonSeasonalConsLH(household,:),2);
    wZiNonSeasonalConsLL(household,1) = sum(wZiTempNonSeasonalConsLL(household,:),2);
    wZiNonSeasonalConsLM(household,1) = sum(wZiTempNonSeasonalConsLM(household,:),2);
    
    wZiNonSeasonalConsMH(household,1) = sum(wZiTempNonSeasonalConsMH(household,:),2);
    wZiNonSeasonalConsML(household,1) = sum(wZiTempNonSeasonalConsML(household,:),2);
    wZiNonSeasonalConsMM(household,1) = sum(wZiTempNonSeasonalConsMM(household,:),2);
end


%% Question 1 part 1 : we compute the welfare costs; first from consumption
%w(c unseasonal, l seasonal) = w(c seasonal(1+g), l seasonal)

aux = zeros (T, 1); 
aux2 = zeros(A, 1); 

for month = 1: T
    aux(month, 1) = beta ^(month-1);
end
for age = 1: A
    aux2(age, 1) = beta ^(12*age);
end


 gcHighHigh = zeros (N,1); % Here we store the welfare gains for each individual
 gcHighLow = zeros (N,1);
 gcHighMiddle = zeros (N,1);
 
 gcLowHigh = zeros(N, 1); 
 gcLowMiddle = zeros(N, 1); 
 gcLowLow = zeros(N, 1); 
 
 gcMiddleHigh = zeros (N,1); 
 gcMiddleLow = zeros (N,1); 
 gcMiddleMiddle = zeros (N,1); 
 
sumBetaMonth=sum(aux, 1);
sumBetaAge =sum(aux2, 1);

for household= 1:N
    gcHighHigh(household,1) = exp((round(wZiNonSeasonalConsHH(household),3)-round(wZiHighHigh(household),3))/(sumBetaAge*sumBetaMonth))-1;
    gcHighLow(household,1) = exp((round(wZiNonSeasonalConsHL(household),3)-round(wZiHighLow(household),3))/(sumBetaAge*sumBetaMonth))-1;
    gcHighMiddle(household,1) = exp((round(wZiNonSeasonalConsHM(household),3)-round(wZiHighMiddle(household),3))/(sumBetaAge*sumBetaMonth))-1;
    
    gcLowHigh(household,1) = exp((round(wZiNonSeasonalConsLH(household),3)-round(wZiLowHigh(household),3))/(sumBetaAge*sumBetaMonth))-1;
    gcLowLow(household,1) = exp((round(wZiNonSeasonalConsLL(household),3)-round(wZiLowLow(household),3))/(sumBetaAge*sumBetaMonth))-1;
    gcLowMiddle(household,1) = exp((round(wZiNonSeasonalConsLM(household),3)-round(wZiLowMiddle(household),3))/(sumBetaAge*sumBetaMonth))-1;
    
    gcMiddleHigh(household,1) = exp((round(wZiNonSeasonalConsMH(household),3)-round(wZiMiddleHigh(household),3))/(sumBetaAge*sumBetaMonth))-1;
    gcMiddleLow(household,1) = exp((round(wZiNonSeasonalConsML(household),3)-round(wZiMiddleLow(household),3))/(sumBetaAge*sumBetaMonth))-1;
    gcMiddleMiddle(household,1) = exp((round(wZiNonSeasonalConsMM(household),3)-round(wZiMiddleMiddle(household),3))/(sumBetaAge*sumBetaMonth))-1;
    
end


subplot(3,1,1)
h1 = histogram(gcHighHigh);
hold on
h2 = histogram(gcHighLow);
hold on
h3 = histogram(gcHighMiddle);
legend( [h1 h2 h3],{'High-High', 'High-Low', 'High-Medium'})
hold off 
title('High detrministic')

subplot(3,1,2)
h1 = histogram(gcLowHigh);
hold on
h2 = histogram(gcLowLow);
hold on
h3 = histogram(gcLowMiddle);
legend( [h1 h2 h3],{'Low-High', 'Low-Low', 'Low-Medium'})
hold off 
title('Low deterministic')

subplot(3,1,3)
h1 = histogram(gcMiddleHigh);
hold on
h2 = histogram(gcMiddleLow);
hold on
h3 = histogram(gcMiddleMiddle);
legend( [h1 h2 h3],{'Middle-High', 'Middle-Low', 'Middle-Medium'})
hold off 
title('Middle deterministic')

%% Welfare costs from deseasonalizing leisure


 glHighHigh = zeros (N,1); % Here we store the welfare gains for each individual
 glHighLow = zeros (N,1);
 glHighMiddle = zeros (N,1);
 
 glLowHigh = zeros(N, 1); 
 glLowMiddle = zeros(N, 1); 
 glLowLow = zeros(N, 1); 
 
 glMiddleHigh = zeros (N,1); 
 glMiddleLow = zeros (N,1); 
 glMiddleMiddle = zeros (N,1); 
 
for household= 1:N
    glHighHigh(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiNonSeasonalConsHH(household),3))/(sumBetaAge*sumBetaMonth))-1;
    glHighLow(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiNonSeasonalConsHL(household),3))/(sumBetaAge*sumBetaMonth))-1;
    glHighMiddle(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiNonSeasonalConsHM(household),3))/(sumBetaAge*sumBetaMonth))-1;
    
    glLowHigh(household,1) = exp((wZiNonSeasonal(household)-wZiNonSeasonalConsLH(household))/(sumBetaAge*sumBetaMonth))-1;
    glLowLow(household,1) = exp((wZiNonSeasonal(household)-wZiNonSeasonalConsLL(household))/(sumBetaAge*sumBetaMonth))-1;
    glLowMiddle(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiNonSeasonalConsLM(household),3))/(sumBetaAge*sumBetaMonth))-1;
    
    glMiddleHigh(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiNonSeasonalConsMH(household),3))/(sumBetaAge*sumBetaMonth))-1;
    glMiddleLow(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiNonSeasonalConsML(household),3))/(sumBetaAge*sumBetaMonth))-1;
    glMiddleMiddle(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiNonSeasonalConsMM(household),3))/(sumBetaAge*sumBetaMonth))-1;
    
end



subplot(3,1,1)
h1 = histogram(glHighHigh);
hold on
h2 = histogram(glHighLow);
hold on
h3 = histogram(glHighMiddle);
legend( [h1 h2 h3],{'High-High', 'High-Low', 'High-Medium'})
hold off 
title('High detemrinistic')

subplot(3,1,2)
h1 = histogram(glLowHigh);
hold on
h2 = histogram(glLowLow);
hold on
h3 = histogram(glLowMiddle);
legend( [h1 h2 h3],{'Low-High', 'Low-Low', 'Low-Medium'})
hold off 
title('Low deterministic')

subplot(3,1,3)
h1 = histogram(glMiddleHigh);
hold on
h2 = histogram(glMiddleLow);
hold on
h3 = histogram(glMiddleMiddle);
legend( [h1 h2 h3],{'Middle-High', 'Middle-Low', 'Middle-Medium'})
hold off 
title('Middle deterministic')

%%Total gains
 gHighHigh = zeros (N,1); % Here we store the welfare gains for each individual
 gHighLow = zeros (N,1);
 gHighMiddle = zeros (N,1);
 
 gLowHigh = zeros(N, 1); 
 gLowMiddle = zeros(N, 1); 
 gLowLow = zeros(N, 1); 
 

 gMiddleHigh = zeros (N,1); 
 gMiddleLow = zeros (N,1); 
 gMiddleMiddle = zeros (N,1); 
 
for household= 1:N
    gHighHigh(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiHighHigh(household),3))/(sumBetaAge*sumBetaMonth))-1;
    gHighLow(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiHighLow(household),3))/(sumBetaAge*sumBetaMonth))-1;
    gHighMiddle(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiHighMiddle(household),3))/(sumBetaAge*sumBetaMonth))-1;
    
    gLowHigh(household,1) = exp((wZiNonSeasonal(household)-wZiLowHigh(household))/(sumBetaAge*sumBetaMonth))-1;
    gLowLow(household,1) = exp((wZiNonSeasonal(household)-wZiLowLow(household))/(sumBetaAge*sumBetaMonth))-1;
    gLowMiddle(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiLowMiddle(household),3))/(sumBetaAge*sumBetaMonth))-1;
    
    gMiddleHigh(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiMiddleHigh(household),3))/(sumBetaAge*sumBetaMonth))-1;
    gMiddleLow(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiMiddleLow(household),3))/(sumBetaAge*sumBetaMonth))-1;
    gMiddleMiddle(household,1) = exp((round(wZiNonSeasonal(household),3)-round(wZiMiddleMiddle(household),3))/(sumBetaAge*sumBetaMonth))-1;
    
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