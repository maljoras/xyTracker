function checkOpts(self)
% checks (and modifies potentially) the given options. 

  
 
  
  
  assert(self.bodylength>self.bodywidth);      
  % overwrite the given options
  self.bodylength = self.bodylength;

  
  if self.opts.tracks.useDagResults
    if self.bodylength<80
      warning(['Using DAG results for small bodysizes might result ' ...
               'in inferior results. Set default to SWB.']);
      self.opts.tracks.useDagResults = 0;
    end
    if self.nbody>10
      warning(['Using DAG results for large number of body might result ' ...
               'in inferior results. Set default to SWB.']);
      self.opts.tracks.useDagResults = 0;
    end
  end
  
  if self.nbody>10 & self.bodylength<80 &   self.opts.classifier.allSwitchProbThres<0.5
    warning(['Many small body. Consider increasing ' ...
             '"classifier.allSwitchProbThres" (set to 0.6)']);
    self.opts.classifier.allSwitchProbThres = 0.6;
  end
  
    
    
  %% classifier
  if self.opts.classifier.nlfd
    if self.opts.classifier.nlfd<0
      nlfd = max(self.nbody+1,10);
      xy.helper.verbose('Set nlfd [%d]',nlfd);
      self.opts.classifier.nlfd = nlfd;
      self.opts.classifier.npca = max(self.opts.classifier.npca,nlfd+1);
      
    elseif self.opts.classifier.nlfd<self.nbody+1;
      nlfd = self.nbody+1;
      xy.helper.verbose('Nlfd too small. Increased nlfd to number of body+1 [%d]',nlfd);
      self.opts.classifier.nlfd = nlfd;
      self.opts.classifier.npca = max(self.opts.classifier.npca,nlfd+1);
      
    end
  end
end


