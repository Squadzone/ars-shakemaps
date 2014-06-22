      subroutine filterer()
      use par
      use spectra
      use traceinfo
      implicit none
      integer                     :: i
      real                        :: buttrlcf, buttrhcf
      if(ifilt /= 1)then
           filtered=fouriered
           return
      endif
      do i=1,npoint/2+1,1
           filtered(i) = cmplx(buttrlcf(freq(i), flcut, norder))*
     1                   fouriered(i)
           filtered(i) = cmplx(buttrhcf(freq(i), fhcut, norder))*
     1                   filtered(i)
           if(i /= 1) then
                filtered(npoint+2-i) = conjg(filtered(i))
           endif
      enddo
      return
      end

