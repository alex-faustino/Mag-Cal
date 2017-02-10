function BRG_Mag_Calibration_Main

platform = input('Enter the platform that data was collected on: \nQ - Quadrotor\nG - Ground Robot\nS - Smartphone\n','s');

[t,magCal,magUncal,hardOS,softOS] = Mag_Calibration(platform);

% Print offset values to console
hardOS
softOS

% Plotting
% Individual axis plots
figure(1)
plot(t,magCal(1,:),t,magCal(2,:),t,magCal(3,:))
legend('x mag','y mag','z mag','Location','northwest')
xlabel('Time (s)')
ylabel('Magnetic Field (\muT)')
grid on;
title('Calibrated Three axes Magnetometer (\muT)')

% Plot uncalibrated and calibrated points
figure(2)
scatter3(magUncal(1,:),magUncal(2,:),magUncal(3,:))
hold on
scatter3(magCal(1,:),magCal(2,:),magCal(3,:))
if (platform == 'S' || platform == 's')
    title('Smartphone Raw and Calibrated Magnetometer Data (\muT)')
elseif (platform == 'G' || platform == 'g')
    title('Ground Robot Raw and Calibrated Magnetometer Data (\muT)')
else
    title('Quadrotor Raw and Calibrated Magnetometer Data (\muT)')
end
legend('Raw Data Points','Calibrated Data Point')
axis equal
end