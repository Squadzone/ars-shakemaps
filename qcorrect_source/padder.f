      subroutine padder()
      use traceinfo
      use timeseries
      implicit none
      integer                     :: i
      padded=windowed
      do  i=1,20,1
           if(2**i >= nsamp)then
                npoint=2**i
                return
           endif
      enddo
      return
      end
