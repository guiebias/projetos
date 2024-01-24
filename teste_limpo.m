clear all
close all
clc
%% Parâmetros do sistema
N_sub = 4; % número de subportadoras
N_cp = 4; % comprimento do prefixo cíclico
N_sym = 128; % número de símbolos OFDM por subportadora
M = 4; % ordem da modulação QAM
B = 15;
snr = 100; % relação sinal-ruído em dB
fc = 50; % frequência da portadora
fm = 1000; %frequência do sinal
fs = 4*fm; % frequência de amostragem
%t = 0:1/fs:(N_sample-1); %vetor de tempo
%% Transmissor
sinal = randi([0 M-1], N_sym,1);
sinal_QAM = qammod(sinal, M);
scatterplot(sinal_QAM);

sinal_sub = reshape(sinal_QAM, [N_sym/N_sub N_sub]);
sinal_OFDM = ifft(sinal_sub, [], 1);
sinal_OFDM_CP = [sinal_OFDM(end-N_cp+1:end,:); sinal_OFDM];
sinalserie = reshape(sinal_OFDM,1,[]);
sinalreal = real(sinalserie);
sinalimag = imag(sinalserie);
N = length(sinalserie);

t = 0:1/B:(N_sym-1)/B;
plot(t, sinalreal);
figure;
plot(t, sinalimag);
%% Modulação em Quadratura
portadora_phase = cos(2*pi*fc*t);
portadora_quad = sin(2*pi*fc*t);

sinal_transmitidoreal = sinalreal'.*portadora_phase';
figure;
plot(t, sinal_transmitidoreal)
sinal_transmitidoimag = sinalimag'.*portadora_quad';
figure;
plot(t, sinal_transmitidoimag)
sinal_transmitido = sinal_transmitidoreal + sinal_transmitidoimag;
figure;
plot(t, sinal_transmitido);

%L = 4; %fator de upsampling
%H = fft(sinal_transmitido); %sinal_transmitido na frequência
%H = H';
%Hup = [H(1:N/2); zeros((L-1)*N,1); H(N/2+1:N)]; % Introduz zeros no domínio da frequência para emular o upsampling.
%hup = ifft(Hup)*L; % Uma correção de amplitude (fator L) deve ser realiza para não haver ganho na amplitude do sinal.


%% Transmissão pelo canal AWGN
sinal_recebido = awgn(sinal_transmitido,snr, 'measured');
%% Receptor
sinal_demod = sinal_recebido.*portadora_phase' + sinal_recebido.*portadora_quad'.*j;
%sinal_demodimag = sinal_recebido.*portadora_quad'.*j;
sinal_demodsub = reshape(sinal_demod, [N_sym/N_sub N_sub]);


%filtro banda base
%sinal_filtroreal = lowpass(sinal_demodreal, 4);
%inal_filtroimag = lowpass(sinal_demodimag, 4);

%Receptor
%sinal_RX_OFDM = sinalmatriz(N_cp+1:end,:);
sinal_RX_QAM = fft(sinal_demodsub, [], 1);
sinalseriedemod = reshape(sinal_RX_QAM,1,[]);
sinal_recuperado = qamdemod(sinalseriedemod, M);
scatterplot(sinal_recuperado);

%% Cálculo da SER
erro = find(sinal - sinal_recuperado); % Retorna as posições da matriz em que houve erros, ou seja, símbolo recuperado diferente do símbolo transmitido.
ser = length(erro)/numel(sinal); % O número de erros dividido pelo total de símbolos transmitido lhe fornece a SER (symbol error rate).
% Pra estimar a BER, você teria que gerar bits, converter pra símbolos e
% então fazer o mesmo processo no receptor, comparando bits e não símbolos.

%% Plot dos Sinais
%Transmissor
figure;
subplot(4,1,1); stem(sinal); title('Sinal Original'); 
subplot(4,1,2); stem(sinal_QAM); title('Sinal QAM');
subplot(4,1,3); stem(sinal_OFDM); title('Sinal OFDM');
subplot(4,1,4); stem(sinal_OFDM_CP); title('Sinal OFDM com Prefixo Cíclico');

%Canal
figure;
plot(abs(sinal_transmitidoreal));title('Sinal Transmitido');

%Receptor
figure;
subplot(4,1,1); stem(sinalmatriz); title('Sinal Recebido com Prefixo Cíclico');
subplot(4,1,2); stem(sinal_RX_OFDM); title('Sinal Recebido sem Prefixo Cíclico');
subplot(4,1,3); stem(sinal_RX_QAM); title('Sinal OFDM demodulado');
subplot(4,1,4); stem(sinal_recuperado); title('Sinal Recuperado (QAM demodulado)');

%Constelação da Modulação QAM
figure;
scatter(real(sinal_QAM(:)), imag(sinal_QAM(:)));title('Constelação QAM');

%Constelação da Modulação QAM
figure;
scatter(real(sinal_RX_QAM(:)), imag(sinal_RX_QAM(:)));title('Constelação QAM recuperado');