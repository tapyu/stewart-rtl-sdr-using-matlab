%% Early Late TED: S-curve and gain coefficient
% This script will determine and plot the S-curves for an Early Late 
% timing error detector, using the Raised Cosine (RC) pulse shape.
% It caters for two specific cases: 
%
%    (i)  Where the output of the matched filter is input directly to the 
%         TED and pulses are 'sign-corrected', i.e. to generate the correct
%         timing error, irrespective of whether pulses are +ve or -ve.
%
%    (ii) Where the output of the matched filter is squared to ensure that
%         the timing error is generated based on positive pulses. This 
%         squaring operation implies that the TED operates on a different
%         shape of pulse.

%% Configure font for figure plotting... 
% Use this only for printing figures for inclusion in the book

% % set the fonts used to Courier for the current figure
 set(gcf,'defaultTextFontName', 'Courier');
 set(gcf,'defaultAxesFontName', 'Courier');
 
%% Design parameters 
% High level design parameters defining the pulse shape.

Ts = 1;                     % symbol period, normalised
roll = 0.5;                   % roll off rate of Raised Cosine filter
L = 12;                     % number of symbol periods for RC filter response
t = [-(L/2):0.01:(L/2)];    % vector of time instants spanning L symbol periods


%% Generate Raised Cosine
% This section produces a vector representing the Raised Cosine pulse shape
% specified above, and a squared version of the same.

% see the following link for the equation of the Raised Cosine: 
% http://www.commsys.isy.liu.se/TSKS04/lectures/3/MichaelZoltowski_SquareRootRaisedCosine.pdf

% For convenience, build the RC equation in two sections... 
RC_1 = cos(pi*roll.*(t/Ts))./(1-(2*roll.*(t/Ts)).^2);
RC_2 = sin(pi.*(t/Ts))./(pi.*(t/Ts));

% generate Raised Cosine
RC = RC_1.*RC_2;

% generate Raised Cosine (squared)
RC_sq = RC.^2;


%% Plot the raised cosine and squared raised cosine impulse responses

figure(1)
hold off
plot(t,RC,'b');
hold on
plot(t,RC_sq,'r');
xlabel('Time (symbol periods)');
ylabel('Amplitude');
grid on


%% Generate the S-curves
% The S-curves plot the actual timing error along the x-axis, and the
% output of the TED on the y-axis. 
%
% Reference: M. Rice - Digital Communications: A Discrete Time Approach
% Chapter 6, pp. 453 - 455, Eq. 8.35.


K = 1;                         % received signal amplitude
Eavg = 1;                      % average symbol energy (assume 1)

tau_e = [-0.5:0.01:0.5];       % symbol timing errors (x-axis for S-curves)

rp_time_1 = (Ts/2) - tau_e;    % time vectors 1 and 2 are used to generate 
rp_time_2 = -(Ts/2) - tau_e;   % late and early raised cosine responses

% ** LATE raised cosine response - using rp_time_1 above **

% build two sections of RC as per method above
RC_1A = cos(pi*roll.*(rp_time_1/Ts))./(1-(2*roll.*(rp_time_1/Ts)).^2);
RC_2A = sin(pi.*(rp_time_1/Ts))./(pi.*(rp_time_1/Ts));

% combine two parts to generate raised cosine and squared RC.
RCA = RC_1A.*RC_2A;
RC_sqA = RCA.^2;

% ** EARLY raised cosine response - using rp_time_2 above **

% build two sections of RC as per method above
RC_1B = cos(pi*roll.*(rp_time_2/Ts))./(1-(2*roll.*(rp_time_2/Ts)).^2);
RC_2B = sin(pi.*(rp_time_2/Ts))./(pi.*(rp_time_2/Ts));

% combine two parts to generate raised cosine and squared RC.
RCB = RC_1B.*RC_2B;
RC_sqB = RCB.^2;

% ** compute responses of Early Late TED ** (RC and squared RC versions)
g_tau_e_RC = K*Eavg*(RCA-RCB);              % RC
g_tau_e_RC_sq = K*Eavg*(RC_sqA-RC_sqB);     % squared RC

%% Plot the S-curves in a figure

figure(2)
hold off
plot(tau_e, g_tau_e_RC,'b');
hold on
plot(tau_e,g_tau_e_RC_sq,'r');
xlabel('Normalised timing error, \tau_e');
ylabel('g(\tau_e)');
grid on
legend(['Symbol-corrected (roll-off = ', num2str(roll),')'],['Squared Input (roll-off = ', num2str(roll),')'],'location','SouthEast');

% optional - print the figure to an EPS file (with TIFF header)
%set(gcf, 'PaperPositionMode', 'manual');
%set(gcf, 'PaperUnits', 'centimeters');
%set(gcf, 'PaperPosition', [2 1 18 12]);
%print -f2 -depsc -tiff S_curves_ELTED;

%% Compute the gradient at zero and hence the ELTED gain, Ks
% The ELTED gain is defined as the gradient of the S-curve at at zero 
% timing error.

% find the number of elements of the timing error vector - we need the
% central ones to generate the gradient at timing error = 0. 
n = length(tau_e);

% find the gradent of the RC S-curve at timing error = 0, using a simple
% m = (y2 - y1)/(x2 - x1) approach. Repeat for squared version. 
gradient_at_zero_RC = (g_tau_e_RC(round(n/2)+1) - g_tau_e_RC(round(n/2)-1)) / (tau_e(round(n/2)+1) - tau_e(round(n/2)-1));
gradient_at_zero_RC_sq = (g_tau_e_RC_sq(round(n/2)+1) - g_tau_e_RC_sq(round(n/2)-1)) / (tau_e(round(n/2)+1) - tau_e(round(n/2)-1));

% print the calculated gains to the console
fprintf(['\r\nRC: \t Kp = ', num2str(gradient_at_zero_RC),'\r\n']);
fprintf(['RC_sq: \t Kp = ', num2str(gradient_at_zero_RC_sq),'\r\n']);



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