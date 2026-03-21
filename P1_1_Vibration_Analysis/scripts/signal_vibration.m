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
noise_removed = sign_raw - sign_filtered;  % What the filter took out

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


%%  STEP 4 : FFT Frequency Analysis

N = length(sign_raw);

fft_raw = fft(sign_raw);
fft_filtered = fft(sign_filtered);

magn_raw = abs(fft_raw)/N;
magn_filtered = abs(fft_filtered)/N;

f = (0 : N-1)*(fs/N);

half = floor(N/2);
f_half = f(1:half);
magn_raw_half = 2 * magn_raw(1:half);
magn_fil_half = 2 * magn_filtered(1:half);


figure;
plot(f_half, magn_raw_half, 'b', 'LineWidth', 1.2);
title('Frequency Spectrum : RAW Signal (with noise)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 300]);               % Zoom: show only 0 to 300 Hz
grid on;

% Add vertical markers at our expected frequencies
xline(50,  'g--', '50 Hz (normal)',   'LineWidth', 1.5);
xline(120, 'r--', '120 Hz (FAULT!)', 'LineWidth', 2.0);
xline(150, 'm--', '150 Hz (harmonic)','LineWidth', 1.5);


figure;
plot(f_half, magn_fil_half, 'r', 'LineWidth', 1.5);
title('Frequency Spectrum — FILTERED Signal (clean)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 300]);
grid on;

xline(50,  'g--', '50 Hz (normal)',   'LineWidth', 1.5);
xline(120, 'r--', '120 Hz (FAULT!)', 'LineWidth', 2.0);
xline(150, 'm--', '150 Hz (harmonic)','LineWidth', 1.5);


figure;

subplot(2,1,1);
plot(f_half, magn_raw_half, 'b', 'LineWidth', 1.2);
title('Spectrum BEFORE filtering — noise hides the peaks');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 300]);
grid on;
xline(50,'g--','LineWidth',1.5);
xline(120,'r--','LineWidth',2.0);
xline(150,'m--','LineWidth',1.5);

subplot(2,1,2);
plot(f_half, magn_fil_half, 'r', 'LineWidth', 1.5);
title('Spectrum AFTER filtering — peaks are sharp and clear!');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 300]);
grid on;
xline(50,'g--','LineWidth',1.5);
xline(120,'r--','LineWidth',2.0);
xline(150,'m--','LineWidth',1.5);


% Let MATLAB find the peaks for us
[peaks, locations] = findpeaks(magn_fil_half, ...
                               f_half, ...
                               'MinPeakHeight', 0.05, ...
                               'MinPeakDistance', 10);

disp('✅ Step 4 complete — FFT Analysis done!');
disp('   Peaks detected in filtered spectrum:');
disp('   ─────────────────────────────────');

for i = 1:length(peaks)
    fprintf('   Peak %d : %.1f Hz  (magnitude = %.3f)\n', ...
             i, locations(i), peaks(i));
end

disp('   ─────────────────────────────────');
disp('   Expected: peaks near 50, 120, 150 Hz');


%% ================================================
%  STEP 5 — Automatic Fault Detection System
%% ================================================

%% --- 5A: Define fault parameters ---

fault_frequency = 120;     % Hz — the frequency we monitor
tolerance       = 5;       % Hz — search within ±5 Hz of target
threshold_warn  = 0.10;    % Magnitude threshold → WARNING
threshold_alarm = 0.20;    % Magnitude threshold → CRITICAL ALARM



%% --- 5B: Find the magnitude at fault frequency ---

% Find all indices where frequency is near 120 Hz (±5 Hz)
search_zone = (f_half >= fault_frequency - tolerance) & ...
              (f_half <= fault_frequency + tolerance);

% 🧠 search_zone is a logical array: 
%    1 where frequency is between 115-125 Hz
%    0 everywhere else

% Extract magnitudes in that zone
magnitudes_in_zone = magn_fil_half(search_zone);
frequencies_in_zone = f_half(search_zone);

% Find the maximum peak in that zone
[fault_magnitude, idx] = max(magnitudes_in_zone);
fault_freq_detected    = frequencies_in_zone(idx);

% 🧠 max() returns: the maximum VALUE and its INDEX position


%% --- 5C: Calculate fault severity ---

% Compare fault magnitude to normal vibration magnitude
% Find normal vibration magnitude at 50 Hz
normal_zone = (f_half >= 45) & (f_half <= 55);
normal_magnitude = max(magn_fil_half(normal_zone));

% Severity = fault / normal × 100 (percentage)
severity_percent = (fault_magnitude / normal_magnitude) * 100;

% 🧠 If severity = 30% → fault is 30% as strong as normal vibration
%    In real industry: > 25% often triggers maintenance inspection


%% --- 5D: The Decision System ---

disp(' ');
disp('══════════════════════════════════════════');
disp('   🏭 MACHINE HEALTH MONITORING SYSTEM   ');
disp('══════════════════════════════════════════');
fprintf('   Monitoring frequency : %d Hz\n', fault_frequency);
fprintf('   Detected magnitude   : %.4f\n', fault_magnitude);
fprintf('   Detected at          : %.1f Hz\n', fault_freq_detected);
fprintf('   Normal vibration     : %.4f\n', normal_magnitude);
fprintf('   Fault severity       : %.1f %%\n', severity_percent);
disp('──────────────────────────────────────────');

% Decision logic
if fault_magnitude > threshold_alarm
    disp('   🔴 STATUS: CRITICAL ALARM!');
    disp('   ⚠️  ACTION: STOP MACHINE IMMEDIATELY');
    disp('   ⚠️  SCHEDULE EMERGENCY MAINTENANCE');

elseif fault_magnitude > threshold_warn
    disp('   🟠 STATUS: WARNING — Fault Detected!');
    disp('   ⚠️  ACTION: Schedule maintenance soon');
    fprintf('   ⚠️  Fault at %.1f Hz exceeds warning threshold\n',...
             fault_freq_detected);
else
    disp('   🟢 STATUS: OK — Normal Operation');
    disp('   ✅ No fault detected above threshold');
end

disp('══════════════════════════════════════════');


%% --- 5E: Visualize the detection on the spectrum ---

figure;
plot(f_half, magn_fil_half, 'r', 'LineWidth', 1.5);
hold on;

% Highlight the fault zone
fault_zone_x = [fault_frequency-tolerance, fault_frequency+tolerance];
fault_zone_y = [threshold_warn, threshold_warn];

% Draw the threshold line
yline(threshold_warn,  'b--', 'Warning threshold',  'LineWidth', 1.5);
yline(threshold_alarm, 'r--', 'Critical threshold', 'LineWidth', 1.5);

% Mark the detected fault peak with a red circle
plot(fault_freq_detected, fault_magnitude, 'ro', ...
     'MarkerSize', 12, 'LineWidth', 3);

% Add text label on the fault peak
text(fault_freq_detected + 5, fault_magnitude, ...
     sprintf('⚠️ FAULT!\n%.1f Hz\nMag=%.3f', ...
     fault_freq_detected, fault_magnitude), ...
     'Color', 'red', 'FontWeight', 'bold', 'FontSize', 9);

xlim([0 300]);
title('Fault Detection System — Frequency Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend('Filtered Spectrum', 'Warning threshold', 'Critical threshold');
grid on;

disp('✅ Step 5 complete — Fault detection system active!');
