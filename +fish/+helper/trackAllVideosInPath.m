function trackAllVideosInPath(path,varargin)

  def.path = '/home/malte/Videos/';
  def.opts.excludeDone = 1;
  def.opts.checkDone = 1;

  def.opts.selectManual = 0;

  def.opts.excludeNames = {'toolboxes'};
  def.opts.extension = 'avi';
  def.opts.nameadd = 'a_';
  def.opts.args = {'displayif',0}; % for FishTracker
  def.opts.parallelif = 1;
  
  fish.helper.parseInputs;
  if HELP; return;end
  
  
  p = genpath(path);
  p = strsplit(p,':');
  
  if ~iscell(opts.excludeNames)
    opts.excludeNames = {opts.excludeNames};
  end

  idx = 0;
  for i = 1:length(opts.excludeNames)
    idx = idx | ~cellfun('isempty',strfind(p,opts.excludeNames{i}));
  end
  p(idx) = [];
  
  fish.helper.verbose('Following paths are searched:');
  disp(strjoin(p,'\n'))
  
  
  for i = 1:length(p)

    d = dir([p{i} filesep '*.' opts.extension]);
    
    if isempty(d)
      continue;
    end
    
    for j = 1:length(d)
      fname = [p{i} filesep d(j).name];
      [a,b,c] = fileparts(fname);
      matname = [p{i} filesep opts.nameadd, b,'.mat'];
      nfish = [];
      if opts.excludeDone && exist(matname,'file');
        
        if opts.checkDone
          % check whether done correctly
          v = load(matname);
          nfish = v.ft.nfish;
          nfish_selected = fish.helper.chooseNFish(fname,nfish);
          if nfish==nfish_selected
            continue;
          else
            nfish = nfish_selected;
          end
          
        else
          continue;
        end
      end
      
      if isempty(nfish) && opts.selectManual
        nfish = fish.helper.chooseNFish(fname,3);
        if isempty(nfish)
          continue; % do not track this video
        end
        
      end
      
      if ~isempty(nfish)
        add = {'nfish',nfish};
      else
        add = {};
      end
      
      
      if opts.parallelif
        parfeval(@subTrack,0,fname,matname,add{:},opts.args{:});
      else
        subTrack(fname,matname,add{:},opts.args{:});
      end
    end
    
    
    
  end
  

function subTrack(fname,matname,varargin);

  ft = fish.Tracker(fname,'displayif',0,varargin{:});
  ft.track();
  ft.save(matname)
