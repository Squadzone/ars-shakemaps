      subroutine windower()
      use traceinfo
      use timeseries
      use par
      implicit none
      integer                     :: i
      real                        :: wind
      windowed=0.
      do i=1,nsamp,1
           call win(i,1,nsamp,int(nsamp*taper),wind)
           windowed(i)=detrended(i)*wind
      enddo
      return
      end

