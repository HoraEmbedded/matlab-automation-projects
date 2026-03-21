%% ================================================
%  Project 1.1 — Industrial Vibration Analysis
%  Script: signal_vibration.m
%  Author: HoraEmbedded
%  Date: 2026
%  Description: Generate a synthetic vibration signal
%               with noise and a hidden fault frequency
%% ================================================

%% --- STEP1 : Define the time axis ---
fs = 1000;
T = 1;
t = 0 : 1/fs : T;

%% STEP2 : Generate signal
sign_normal = sin (2*pi*50*t);
sign_harmonic = 0.5 * sin(2*pi*150*t);
sign_fault = 0.3 * sin(2*pi*120*t);
noise = 0.2 * randn (size(t));

%% --- STEP 3: Combine everything into one signal ---
sign_raw = sign_normal + sign_harmonic + sign_fault + noise;

%% STEP 4 Visualisation raw signal

figure;
plot(t,sign_raw, 'b');
title('Raw Vibration Signal');
xlabel('Time (sec)');
ylabel('Amplitude(g)');
grid on;

figure;
subplot(4, 1, 1);
plot(t,sign_normal,'b');
xlim([0 0.05])
title('Normal Vibration Signal(50Hz)');
ylabel('Amplitude(g)');
grid on;

subplot(4, 1, 2);
plot(t,sign_harmonic,'g');
xlim([0 0.05])
title('Harmonic Signal(150Hz)');
ylabel('Amplitude(g)');
grid on;

subplot(4, 1, 3);
plot(t,sign_fault,'r');
xlim([0 0.05])
title('Fault frequency(120Hz)');
ylabel('Amplitude(g)');
grid on;
disp(['Total samples :', num2str(length(t))]);

subplot(4, 1, 4);
plot(t,sign_raw,'k');
xlim([0 0.05])
title('Raw Vibration Signal(50Hz)');
ylabel('Amplitude(g)');
grid on;

figure;                          
hold on;                        

plot(t, sign_normal,   'b',  'LineWidth', 1.2);
plot(t, sign_fault,    'r',  'LineWidth', 1.5);
plot(t, sign_raw,      'k:', 'LineWidth', 0.8);

xlim([0 0.05]);
legend('Normal (50 Hz)', 'Fault (120 Hz)', 'Raw mixed signal');
title('overlay comparison');
xlabel('Time (sec)');
ylabel('Amplitude (g)');
grid on;

%%  STEP 3 — Design and Apply a Low-Pass Filter

fc = 200;
order = 4;

Wn = fc/(fs/2);
[b, a] = butter(order,Wn,"low");
sign_filtered = filtfilt(b,a,sign_raw);

figure;

subplot(2, 1, 1);
plot(t, sign_raw, 'b', 'LineWidth', 0.8);
xlim([0 0.05]);
title('BEFORE filtering : Raw signal (noisy)');
xlabel('Time (seconds)');
ylabel('Amplitude (g)');
grid on;

subplot(2, 1, 2);
plot(t, sign_filtered, 'r', 'LineWidth', 1.5);
xlim([0 0.05]);
title('AFTER filtering : Cleaned signal');
xlabel('Time (seconds)');
ylabel('Amplitude (g)');
grid on;


figure;
hold on;

plot(t, sign_raw,      'b',  'LineWidth', 0.8);
plot(t, sign_filtered, 'r',  'LineWidth', 2.0);

xlim([0 0.05]);
ylim([-2.5 2.5]);

legend('Raw (noisy)', 'Filtered (clean)');
title('Filter Effect');
xlabel('Time (seconds)');
ylabel('Amplitude (g)');
grid on;


figure;
noise_removed = sign_raw - sign_filtered;  % What the filter took out

plot(t, noise_removed, 'Color', [0.5 0.5 0.5]);  % Gray color
xlim([0 0.05]);
title('What the Filter Removed — Pure Noise');
xlabel('Time (seconds)');
ylabel('Amplitude (g)');
grid on;


figure;
noise_removed = signal_raw - signal_filtered;  % What the filter took out

plot(t, noise_removed, 'Color', [0.5 0.5 0.5]);  % Gray color
xlim([0 0.05]);
title('What the Filter Removed — Pure Noise');
xlabel('Time (seconds)');
ylabel('Amplitude (g)');
grid on;


disp(['   Filter type     : Butterworth Low-Pass']);
disp(['   Filter order    : ', num2str(order)]);
disp(['   Cutoff frequency: ', num2str(fc), ' Hz']);
disp(['   Normalized Wn   : ', num2str(Wn)]);