% BPSK Modulation and Demodulation Example with Voice Input

% Parameters
bitRate = 1000; % Bit rate (bits per second)
symbolRate = 2 * bitRate; % Symbol rate (symbols per second)
SNRdB = 10; % Signal-to-Noise Ratio (in dB)
demodulatedDuration = 5; % Demodulated voice duration in seconds
cutoffFrequency = 3000; % Cut-off frequency of the low-pass filter

% Record voice input
recorder = audiorecorder; % Create audio recorder object
disp('Start speaking...');
recordblocking(recorder, demodulatedDuration); % Record voice for specified duration
disp('Recording complete.');
disp('Playing Recorded audio')

% Get recorded voice
voice = getaudiodata(recorder);
sampleRate = recorder.SampleRate;

% Normalize voice signal
voice = voice / max(abs(voice));

% Convert voice signal to bits
bits = reshape(dec2bin(round((voice + 1) / 2)), 1, []);

% Carrier frequency
carrierFrequency = 1000; % in Hz

% Time axis
t = (0:length(bits)-1) / symbolRate;

% Carrier signal
carrier = cos(2 * pi * carrierFrequency * t);

% BPSK modulation
symbols = (2 * (bits - '0') - 1) .* carrier;

% Add noise to the symbols
noisePower = 10^(-SNRdB/10); % Noise power (linear scale)
noise = sqrt(noisePower) * randn(1, length(symbols));
receivedSymbols = symbols + noise;

% BPSK demodulation
demodulatedSymbols = receivedSymbols .* carrier;
receivedBits = (demodulatedSymbols > 0);

% Low-pass filter
[b, a] = butter(6, cutoffFrequency / (sampleRate/2), 'low'); % Butterworth low-pass filter coefficients
filteredSignal = filter(b, a, receivedBits);

% Calculate Bit Error Rate (BER)
numErrors = sum(bits ~= filteredSignal);
BER = numErrors / length(bits);

% Display Bit Error Rate (BER)
disp(['Bit Error Rate (BER): ' num2str(BER)]);

% Convert received bits back to voice signal
receivedVoice = filteredSignal; % No conversion needed

% Adjust demodulated voice duration to desired length
desiredLength = round(demodulatedDuration * sampleRate);
receivedVoice = resample(receivedVoice, desiredLength, length(receivedVoice));

% Display message before playing demodulated voice
% Play original and demodulated voice signals
sound(voice, sampleRate);
pause(2)
disp('Playing demodulated voice...');
pause(demodulatedDuration);

sound(receivedVoice, sampleRate);


% Plot original and demodulated voice signals
t = (0:length(voice)-1) / sampleRate;
t_received = (0:length(receivedVoice)-1) / sampleRate;

subplot(2,1,1);
plot(t, voice, 'b');
title('Original Voice');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t_received, receivedVoice, 'g');
title('Demodulated Voice');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;
