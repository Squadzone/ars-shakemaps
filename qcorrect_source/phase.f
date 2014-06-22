      function phase(x)
      implicit none
      real                        :: phase
      complex                     :: x
      if(real(x) > 0.)then
           phase=atan(aimag(x)/real(x))
      elseif(real(x) == 0.)then
           if(aimag(x) > 0.)phase= 2.*atan(1.)
           if(aimag(x) < 0.)phase=-2.*atan(1.)
      elseif(real(x) < 0.)then
           if(aimag(x) > 0.)phase=atan(aimag(x)/real(x))+4.*atan(1.)
           if(aimag(x) == 0.)phase=4.*atan(1.)
           if(aimag(x) < 0.)phase=atan(aimag(x)/real(x))-4.*atan(1.)
      endif
      phase=phase*45./atan(1.)
      return
      end
