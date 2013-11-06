function test_shared_virtual_channels

% MEM 1500mb
% WALLTIME 00:03:09

% TEST test_shared_virtual_channels
% TEST ft_timelockanalysis ft_sourceanalysis ft_channelselection ft_databrowser

% disable verbose output
global ft_default;
ft_default.feedback = 'no';

if ispc
  datadir  = 'H:\common\matlab\fieldtrip\data\ftp\tutorial\beamformer_extended';
elseif isunix
  datadir = '/home/common/matlab/fieldtrip/data/ftp/tutorial/beamformer_extended';
end

load(fullfile(datadir, 'hdm.mat'));
load(fullfile(datadir, 'source_diff'));
load(fullfile(datadir, 'source_coh_lft'));
load(fullfile(datadir, 'data_cmb'));

[maxval, maxcohindx] = max(source_coh_lft.avg.coh);
source_coh_lft.pos(maxcohindx, :)

assert(identical(source_coh_lft.pos(maxcohindx, :), [3.2000   -0.6000   7.4000], 'reltol', 0.001), 'coherence peak location not what it used to be!');

[maxval, maxpowindx] = max(source_diff.avg.pow);
source_diff.pos(maxpowindx, :)

assert(identical(source_diff.pos(maxpowindx, :), [ 0.8000   -8.6000    2.6000], 'reltol', 0.001), 'gamma power peak location not what it used to be!');

cfg                   = [];
cfg.covariance        = 'yes';
cfg.channel           = 'MEG';
cfg.vartrllength      = 2;
cfg.covariancewindow  = 'all';
tlock                 = ft_timelockanalysis(cfg, data_cmb);


cfg             = [];
cfg.method      = 'lcmv';
cfg.vol         = hdm;
cfg.grid.pos    = source_diff.pos([maxcohindx maxpowindx], :);
cfg.grid.inside = 1:size(cfg.grid.pos, 1);
cfg.grid.outside = [];
cfg.keepfilter  = 'yes';
source_idx      = ft_sourceanalysis(cfg, tlock);


beamformer_lft_coh = source_idx.avg.filter{1};
beamformer_gam_pow = source_idx.avg.filter{2};

chansel = ft_channelselection('MEG', data_cmb.label); % find MEG sensor names
chansel = match_str(data_cmb.label, chansel);         % find MEG sensor indices

coh_lft_data = [];
coh_lft_data.label = {'coh_lft_x', 'coh_lft_y', 'coh_lft_z'};
coh_lft_data.time = data_cmb.time;
gam_pow_data = [];
gam_pow_data.label = {'gam_pow_x', 'gam_pow_y', 'gam_pow_z'};
gam_pow_data.time = data_cmb.time;
for i=1:length(data_cmb.trial)
  coh_lft_data.trial{i} = beamformer_lft_coh * data_cmb.trial{i}(chansel,:);
  gam_pow_data.trial{i} = beamformer_gam_pow * data_cmb.trial{i}(chansel,:);
end

cfg = [];
cfg.viewmode = 'vertical';  % you can also specify 'butterfly'
ft_databrowser(cfg, gam_pow_data);
