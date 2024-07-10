%RTL-SDR: MATLAB Envelope Detector for AM-DSB-TC Signals
% - In this exercise you will get the opportunity to run a MATLAB function 
%   that implements the Complex Envelope Detector you constructed in 
%   Exercise 8.4. The function has been designed to receive an AM-DSB-TC
%   audio signal, and will output the demodulated audio information to your
%   computer’s speakers or headphones.
% - Note: If you do not have an RTL-SDR, or are unable to transmit an 
%   AM-DSB-TC signal that you can receive, you can still complete this 
%   exercise by modifying a line in the code. Instructions on how to do
%   this will be discussed below.

function rtlsdr_am_envelope_demod_matlab

%% PARAMETERS (can change)
offline          = 1;                           % '0' = use RTL-SDR, '1' = import data
offline_filepath = 'rec_data/am_dsb_tc.mat';    % path to AM signal
rtlsdr_id        = '0';                         % stick ID
rtlsdr_fc        = 433.9e6;                     % tuner centre frequency in Hz
rtlsdr_gain      = 30;                          % tuner gain in dB
rtlsdr_fs        = 240e3;                       % tuner sampling rate
rtlsdr_ppm       = 0;                           % tuner parts per million correction
rtlsdr_frmlen    = 256*25;                      % output data frame size (must be a multiple of 5)
rtlsdr_datatype  = 'single';                    % output data type
audio_fs         = 48e3;                        % audio output sampling rate
sim_time         = 60;                          % simulation time in seconds

%% CALCULATIONS (do not edit)
rtlsdr_fc = rtlsdr_fc-40e3;                 % add 40kHz offset to tuner frequency entered by user
rtlsdr_frmtime = rtlsdr_frmlen/rtlsdr_fs;   % calculate time for 1 frame of data


%% SYSTEM OBJECTS (do not edit)

% check if running offline
if offline == 1
    
    % link to an rtl-sdr data file
    obj_rtlsdr = import_rtlsdr_data(...
        'filepath', offline_filepath,...
        'frm_size', rtlsdr_frmlen,...
        'data_type',rtlsdr_datatype);

else
    
    % link to a physical rtl-sdr
    obj_rtlsdr = comm.SDRRTLReceiver(...
        rtlsdr_id,...
        'CenterFrequency', rtlsdr_fc,...
        'EnableTunerAGC', false,...
        'TunerGain', rtlsdr_gain,...
        'SampleRate', rtlsdr_fs, ...
        'SamplesPerFrame', rtlsdr_frmlen,...
        'OutputDataType', rtlsdr_datatype,...
        'FrequencyCorrection', rtlsdr_ppm);
end;

% fir decimator
obj_decmtr = dsp.FIRDecimator(...
    'DecimationFactor', 5,...
    'Numerator', firpm(100, [0 15e3 20e3 (240e3/2)]/(240e3/2), [1 1 0 0], [1 1], 20));

% fir bandpass filter
obj_bpf = dsp.FIRFilter(...
    'Numerator', firpm(50,[0,20e3,25e3,55e3,60e3,240e3/2]/(240e3/2),...
    [0 0 1 1 0 0],[1 1 1],20));

% audio output
obj_audio = dsp.AudioPlayer(audio_fs);    % set output sampling rate to 48kHz

% spectrum analyzers
obj_spectrummod   = dsp.SpectrumAnalyzer(...
    'Name', 'Spectrum Analyzer Modulated',...
    'Title', 'Spectrum Analyzer Modulated',...
    'SpectrumType', 'Power density',...
    'FrequencySpan', 'Full',...
    'ShowLegend', true,...
    'SampleRate', rtlsdr_fs);
obj_spectrumdemod = dsp.SpectrumAnalyzer(...
    'Name', 'Spectrum Analyzer Demodulated',...
    'Title', 'Spectrum Analyzer Demodulated',...
    'SpectrumType', 'Power density',...
    'FrequencySpan', 'Full',...
    'SampleRate', audio_fs);

%% SIMULATION  (do not edit)

% if using RTL-SDR, check first if RTL-SDR is active
if offline == 0    
    if ~isempty(sdrinfo(obj_rtlsdr.RadioAddress))
    else
        error(['RTL-SDR failure. Please check connection to ',...
            'MATLAB using the "sdrinfo" command.']);
    end
end

% reset run_time to 0 (secs)
run_time = 0;

% loop while run_time is less than sim_time
while run_time < sim_time
    
    % fetch a frame from obj_rtlsdr (live or offline)
    rtlsdr_data = step(obj_rtlsdr);
    
    % bandpass filter data to isolate AM-DSB-TC signal around 40kHz
    data_bpf = step(obj_bpf,rtlsdr_data);
    
    % update 'modulated' spectrum analyzer window with the new frame
    % of data, and the frame of bandpass filtered data
    step(obj_spectrummod,[rtlsdr_data,data_bpf]);
    
    % implement complex envelope detector
    env_mag = abs(data_bpf);
    data_dec = step(obj_decmtr,env_mag);
    
    % update 'demodulated' spectrum analyzer window with new frame
    step(obj_spectrumdemod,data_dec);
    % output demodulated signal to speakers
    step(obj_audio,data_dec);
    
    % update run_time after processing another frame
    run_time = run_time + rtlsdr_frmtime;
    
end


end


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