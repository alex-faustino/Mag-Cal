function softOS = Gauss_Newton_Mag(magUncal,hardOS,platform)


% Magnetic field magnitud in micro tesla
% 53 is for UIUC campus
M = 53;

% Initialize intial guesses for A values
% I made these close to the values of intentional soft iron skewing matrix
% to decrease time to convergence
A1 = .5;
A2 = .5;
A3 = .1;
A4 = .75;
A5 = .1;
A6 = .75;
a = [A1 A2 A3 A4 A5 A6]';
A = [A1 A2 A3;
     A2 A4 A5;
     A3 A5 A6];
 
% B in the symbolic jacobian calculated being replaced by the hard offset
% calculated by ellipsoid fit.
B1 = hardOS(1);
B2 = hardOS(2);
B3 = hardOS(3);

% Initialize jacobian and residual
J0 = zeros(size(magUncal,2),6);
r0 = zeros(size(magUncal,2),1);

% Perform non-linear regression
for j=1:50
    % Populate Jacobian matrix and residual vector
    for k=1:size(magUncal,2)
        h1 = magUncal(1,k);
        h2 = magUncal(2,k);
        h3 = magUncal(3,k);
        J0(k,:) = [(B1-h1)*((A1)*((B1)-(h1))+(A2)*((B2)-(h2))+(A3)*((B3)-(h3))+A1*((B1)-(h1)))+A2*((B1)-(h1))*(B2-h2)+A3*((B1)-(h1))*(B3-h3),
                   (B1-h1)*((A2)*((B1)-(h1))+(A4)*((B2)-(h2))+(A5)*((B3)-(h3))+A2*((B1)-(h1))+A1*((B2)-(h2)))+(B2-h2)*((A1)*((B1)-(h1))+(A2)*((B2)-(h2))+(A3)*((B3)-(h3))+A2*((B2)-(h2))+A4*((B1)-(h1)))+(B3-h3)*(A3*((B2)-(h2))+A5*((B1)-(h1))),
                   (B1-h1)*((A3)*((B1)-(h1))+(A5)*((B2)-(h2))+(A6)*((B3)-(h3))+A3*((B1)-(h1))+A1*((B3)-(h3)))+(B3-h3)*((A1)*((B1)-(h1))+(A2)*((B2)-(h2))+(A3)*((B3)-(h3))+A6*((B1)-(h1))+A3*((B3)-(h3)))+(B2-h2)*(A5*((B1)-(h1))+A2*((B3)-(h3))),
                   (B2-h2)*((A2)*((B1)-(h1))+(A4)*((B2)-(h2))+(A5)*((B3)-(h3))+A4*((B2)-(h2)))+A2*((B2)-(h2))*(B1-h1)+A5*((B2)-(h2))*(B3-h3),
                   (B2-h2)*((A3)*((B1)-(h1))+(A5)*((B2)-(h2))+(A6)*((B3)-(h3))+A5*((B2)-(h2))+A4*((B3)-(h3)))+(B3-h3)*((A2)*((B1)-(h1))+(A4)*((B2)-(h2))+(A5)*((B3)-(h3))+A6*((B2)-(h2))+A5*((B3)-(h3)))+(B1-h1)*(A3*((B2)-(h2))+A2*((B3)-(h3))),
                   (B3-h3)*((A3)*((B1)-(h1))+(A5)*((B2)-(h2))+(A6)*((B3)-(h3))+A6*((B3)-(h3)))+A3*((B3)-(h3))*(B1-h1)+A5*((B3)-(h3))*(B2-h2)];
        r0(k,:) = (A*(magUncal(:,k)-hardOS))'*A*(magUncal(:,k)-hardOS)-M;
    end
    
    % Pseudo inverse
    a = a-(J0'*J0)\J0'*r0;
    A = [a(1) a(2) a(3);
         a(2) a(4) a(5);
         a(3) a(5) a(6)];
end

% Scale softOS matrix depending on platform
if (platform == 'S' || platform == 's' || platform == 'G' || platform == 'g')
    softOS = A*(7*eye(3));
else
    softOS = A*(10*eye(3));
end

end