
      function buttrlcf(f, fcut, norder)
c     norder Butterworth low-cut filter response from AGRAM
c     taken from Boore, 1996
      implicit none
      integer                     :: norder
      real                        :: buttrlcf, f, fcut
      buttrlcf = 1.
      if (fcut == 0.) return
      buttrlcf = 0.
      if (f == 0.) return
      buttrlcf = 1./ (1. + (fcut/f)**real(2*norder))
      return
      end
