function test_bug2450

% MEM 500mb
% WALLTIME 00:05:00

% TEST test_bug2450
% TEST ft_rejectvisual

cfg = [];

data = [];
data.trial{1} = zeros(1,1000);
data.time{1}  = (0:999)./1000;
data.label{1} = 'chan01';

% running it with an empty cfg gets you into summary mode, which does not
% exit automatically
%ft_rejectvisual(cfg, data);