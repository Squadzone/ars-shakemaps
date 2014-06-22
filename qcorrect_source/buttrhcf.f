      function buttrhcf(f, fcut, norder)
c     norder Butterworth high-cut filter response from AGRAM
c     taken from Boore, 1996
      implicit none
      integer                     :: norder
      real                        :: buttrhcf, f, fcut 
      buttrhcf = 1.
      if (fcut == 0.) return
      buttrhcf = 0.
      if (f == 0.) return
      buttrhcf = 1./ (1. + (f/fcut)**real(2*norder))
      return
      end

