% Plot sum-of-three-sines in the time and frequency domains (complex)
% - This exercise is very similar to Exercise 5.1. Here you will run a 
%   MATLAB script to plot the signal from Eq. (5.8) in the time and 
%   frequency domains. This time however, we will focus on the complex
%   frequency domain. 

% PRINT FILE INFORMATION HYPERLINK TO COMMAND WINDOW
disp(['View file information for <a href="matlab: mfileinfo(''',mfilename,''')">',mfilename,'</a>']);




% set parameters
fs = 10240;                     % sampling rate
T_max = 1;                      % sim end time
t = (0:1/fs:(T_max-1/fs))';     % time vector
f1 = 100;                       % frequency of 1st tone 
f2 = 200;                       % frequency of 2nd tone
f3 = 300;
A1 = 10;                        % amplitudes of tones
A2 = 1;
A3 = 4;

% create sum of cosines signal
s_t = A1*cos((2*pi*f1*t)+pi/4) + A2*cos((2*pi*f2*t)+pi/6) + + A3*cos(2*pi*f3*t);      % cosines


% create very small impulse and add to signal (helps to ensure correctness 
% of phase spectrum)
r_t = zeros(length(s_t),1);   
r_t(1) = 0.01;                % try commenting out this line - see what happens!
y_t = s_t + r_t;

% perform FFT using rectangular window... 
Nfft = 1024;
X_1 = (1/(2*fs)) * fftshift(fft(y_t,Nfft));        % FFT
f = ((-Nfft/2):(Nfft/2)-1)/Nfft*fs;            % frequency scale

% plot figure (time_domain)
figure(501); 
plot(t,s_t,'-','Color',[0.2 0.7 0.2],'LineWidth',2)%,'MarkerSize',5,'MarkerFaceColor','b');
axis([0 0.05 -15 15]);
xlabel('time (s)');
ylabel('amplitude');
grid on;


% plot figure (frequency domain, 2 sided)
m = abs(X_1);
figure(502); 
stem(f,20*m,'-o','MarkerSize',5,'MarkerFaceColor',[0.2 0.2 0.8],'Color',[0.2 0.2 0.8],'LineWidth',2);
axis([-500 500 0 11]);
xlabel('frequency (Hz)');
ylabel('magnitude');
title('Complex magnitude spectrum');
grid on;

% get the phase information
g = rem(angle(X_1),3.14);
figure(503); 
stem(f,g,'-o','MarkerSize',5,'MarkerFaceColor',[0.6 0 0.9],'Color',[0.7 0 0.9],'LineWidth',2);
axis([0 500 0 pi]);
xlabel('frequency (Hz)');
ylabel('phase (radians)');
title('Phase spectrum');
grid on;

% find the indices of the significant components
i = find(abs(m) > 0.01);

% plot the magnitude response as Real and Imaginary, on separate axes
figure(504);
subplot(2,1,1)
stem(f(i),20*real(X_1(i)),'r-o','MarkerSize',5,'MarkerFaceColor','r','LineWidth',2);
axis([-500 500 -10 10]);
xlabel('frequency (Hz)');
ylabel('magnitude');
title('Magnitude FFT (REAL part, significant components only)');
grid on;
subplot(2,1,2)
stem(f(i),20*imag(X_1(i)),'b-o','MarkerSize',5,'MarkerFaceColor','b','LineWidth',2);
axis([-500 500 -10 10]);
xlabel('frequency (Hz)');
ylabel('magnitude');
title('Magnitude FFT (IMAGINARY part, significant components only)');
grid on;



%% ** OPTIONAL ** ('Uncomment' final section if desired)
% % plot the FFT showing only the significant components
% 
% % find the indices of the significant magnitude components
% i = find(abs(m) > 0.01);
% 
% % plot figure (frequency domain, 2 sided, significant components only)
% m = abs(X_1);
% figure(505); 
% stem(f(i),20*m(i),'-o','MarkerSize',5,'MarkerFaceColor',[0.2 0.2 0.8],'Color',[0.2 0.2 0.8],'LineWidth',2);
% axis([-500 500 0 11]);
% xlabel('frequency (Hz)');
% ylabel('magnitude');
% title('Complex magnitude spectrum (significant components only)');
% grid on;
% 
% % find the significant phases)
% ig = find (abs(g) > 0.01);
% 
% % plot the phase spectra
% figure(506); 
% stem(f(ig),g(ig),'-o','MarkerSize',5,'MarkerFaceColor',[0.6 0 0.9],'Color',[0.7 0 0.9],'LineWidth',2);
% axis([0 500 0 pi]);
% xlabel('frequency (Hz)');
% ylabel('phase (radians)');
% title('Phase spectrum (significant components only)');
% grid on;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Software, Simulation Examples and Design Exercises Licence Agreement  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         
%  This license agreement refers to the simulation examples, design
%  exercises and files, and associated software MATLAB and Simulink
%  resources that accompany the book:
% 
%    Title: Software Defined Radio using MATLAB & Simulink and the RTL-SDR 
%    Published by Strathclyde Academic Media, 2015
%    Authored by Robert W. Stewart, Kenneth W. Barlee, Dale S.W. Atkinson, 
%    and Louise H. Crockett
%
%  and made available as a download from www.desktopSDR.com or variously 
%  acquired by other means such as via USB storage, cloud storage, disk or 
%  any other electronic or optical or magnetic storage mechanism. These 
%  files and associated software may be used subject to the terms of 
%  agreement of the conditions below:
%
%    Copyright © 2015 Robert W. Stewart, Kenneth W. Barlee, 
%    Dale S.W. Atkinson, and Louise H. Crockett. All rights reserved.
%
%  Redistribution and use in source and binary forms, with or without 
%  modification, are permitted provided that the following conditions are
%  met:
%
%   (1) Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%
%   (2) Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the 
%       distribution.
%
%   (3) Neither the name of the copyright holder nor the names of its 
%       contributors may be used to endorse or promote products derived 
%       from this software without specific prior written permission.
%
%   (4) In all cases, the software is, and all modifications and 
%       derivatives of the software shall be, licensed to you solely for
%       use in conjunction with The MathWorks, Inc. products and service
%       offerings.
%
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
%  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
%  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
%  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
%  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
%  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
%  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
%  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
%  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
%  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
%  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%%  Audio Tracks used in Simulations Examples and Design Exercises
% 
%  The music and vocal files used within the Examples files and software 
%  within the book were variously written, arranged, performed, recorded 
%  and produced by Garrey Rice, Adam Struth, Jamie Struth, Iain 
%  Thistlethwaite and also Marshall Craigmyle who collectively, and 
%  individually where appropriate, assert and retain all of their 
%  copyright, performance and artistic rights. Permission to use and 
%  reproduce this music is granted for all purposes associated with 
%  MATLAB and Simulink software and the simulation examples and design 
%  exercises files that accompany this book. Requests to use the music 
%  for any other purpose should be directed to: info@desktopSDR.com. For
%  information on music track names, full credits, and links to the 
%  musicians please refer to www.desktopSDR.com/more/audio.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%