% cript for plotting features

PLOTFEATURES = 1;
PLOTCLASSMEANS = 1;

LOAD = 0;
PLOTORI = 0;

if LOAD 
  xyT = xy.Tracker([],'displayif',0);
  xyT.saveFields = {xyT.saveFields{:}, 'segment.FilledImage2x','segment.IdentityFeature',...
                   'segment.Image2x','segment.MinorAxisLength','segment.MajorAxisLength'};
  xyT.track([0,200]); % first couple of minutes
  res = xyT.getTrackingResults();
end

nbody = 5;

bendingThres = 5;

if PLOTFEATURES
  figure;
  clf;

  iframe = 300;
  nframes = 20;
  nskip = 1;

  s = 0;
  C = colormap;
  C(end,:) = [1,1,1];
  colormap(C)
  set(gcf,'color','w');
  for j = 1:nbody
    for i = 1:nframes
      s = s+1;
      track = res.tracks(iframe+(i-1)*nskip,j);
      seg = track.segment;

      
      a = subsubplot(3,1,1,nbody,nframes,s);
      sz = size(seg.FilledImage2x);
      x = (0:sz(2))-sz(2)/2;
      y = (0:sz(1))-sz(1)/2;
      if isa(seg.FilledImage2x,'uint8')
        img = double(seg.FilledImage2x)/255;
      else
        img = double(seg.FilledImage2x);
      end
      
      img =  img + j/nbody -0.5;
      img(~seg.Image2x) = 1;
      imagesc(x,y,img,[0,1]);

      xlim([-xyT.bodylength,xyT.bodylength]*0.5);
      ylim([-xyT.bodylength,xyT.bodylength]*0.5);
      set(a,'Clipping','off')
      axis off;
      daspect([1,1,1])

      if PLOTORI
        hold on;
        fy = tan(-seg.Orientation/180*pi)*x;
        fy(fy>xyT.bodylength/2) = NaN;
        fy(fy<-xyT.bodylength/2) = NaN;
        plot(x,fy,'r-');
      end
      
      

      a = subsubplot(3,1,2,nbody,nframes,s);
      img = double(seg.IdentityFeature(:,:,1));
      if seg.bendingStdValue>bendingThres
        xy.helper.imagescbw(img,[-0.5,1]);
      else
        imagesc(img);
      end
      
      axis off;

      
      a = subsubplot(3,1,3,nbody,nframes,s);
      img = double(seg.IdentityFeature(:,:,1))/nbody;
      [~,cl] = max(track.classProb);
      if seg.bendingStdValue>bendingThres
        xy.helper.imagescbw(img,[-1,1]);
      else
        imagesc(img+(cl-1)/nbody,[0,1]);
      end
      axis off;      

      

      
      
    end
  end



  tstr = {'Blob detection','Feature extraction','Classfication'};
  relshift = 1/3;
  for i = 1:3
    b = subsubplot(3,1,i,1,1,1);  
    p1 = get(b,'position');
    offx = p1(3)/nframes*relshift;
    offy = p1(4)/nbody*relshift;
    shiftaxes(b,[-offx,-offy,offx,offy]);
    title(tstr{i})
    set(b,'color','none');
    xlim([0.5-relshift,nframes+0.5]);
    ylim([0.5-relshift,nbody+0.5]);
    set(b,'xtick',1:nframes)
    set(b,'ytick',1:nbody);
    ylabel('Identity ID')
    set(b,'tickdir','out')
  end
  xlabel('Time [frames]');

end



if PLOTCLASSMEANS
  figure;
  clf;
  C = colormap;
  C(end,:) = [1,1,1];
  colormap(C);
  
  nframes = 30;
  iframe = 800;
  nskip = 1;

  fcl = xyT.identityClassifier;
  
  mu = fcl.getMeans();
  for i = 1:nbody
    subplot(2,nbody,i)
    m = squeeze(mu(i,:,:,1));
    imagesc(m,[0.2,0.45]);
    axis off
    k = (size(C,1)-2)/nbody*i;
    c = C(floor(k)+1,:);
    title(sprintf('Identity #%d',i),'color',c)
  end
  set(gcf,'color','w')
  
  [v,~,proj,m] = xy.helper.pca1(fcl.mu,2);
  
  a = subplot(2,2,3);
  for i = 1:nbody
    S =v'*fcl.Sigma(:,:,i)*v;
  

    k = (size(C,1)-2)/nbody*i;
    c = C(floor(k)+1,:);

    plot(proj(i,1),proj(i,2),'.','color',c,'linewidth',1,'Markersize',6)
    plotGauss(proj(i,:)',S,'color',c,'linewidth',2);
    
    hold on;
  end
  title(sprintf('Gaussian mixture (%d-dimensional)',fcl.npca))
  xlabel('Projected dimension #1')
  ylabel('Projected dimension #2')
  xl = [-4,4];
  yl = [-1,1];
  xlim(xl);
  ylim(yl);
 
  
  a = subplot(2,2,4);
  p = zeros(2,nframes,nbody);
  msk = ~ones(nframes,nbody);
  for j = 1:nbody
    for i = 1:nframes
      s = s+1;
      track = res.tracks(iframe+(i-1)*nskip,j);
      seg = track.segment;
      feat = fcl.preprocess(seg.IdentityFeature(:)');
      p(:,i,j) = (feat - m')*v;
      msk(i,j) = (seg.bendingStdValue>bendingThres);
    end
  end
  
  for j = 1:nbody
    
    k = (size(C,1)-2)/nbody*j;
    c = C(floor(k)+1,:);

    plot(p(1,:,j),p(2,:,j),'x','color',c,'linewidth',1,'Markersize',6);
    hold on;
    plot(p(1,msk(:,j),j),p(2,msk(:,j),j),'o','color',[1,1,1]*.5,'linewidth',0.5,'Markersize',6);

  
  end
  xlim(xl);
  ylim(yl);
   
  xlabel('Projected dimension #1')
  ylabel('Projected dimension #2')
  title('Example Frames')




end
