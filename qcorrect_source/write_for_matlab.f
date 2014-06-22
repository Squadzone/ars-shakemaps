      subroutine write_for_matlab()
      use eqpar 
      use traceinfo
      implicit none
      real                        :: esecond
      esecond=eqmsecond+real(eqdate(6))
      write(39,10)staname,comp,stdist,eqdate(1:5),esecond,eqcoord(1:3)
     1           ,eqmag
10    format(7x,a4,1x,a3,1x,f7.1,2x,i4,1x,i2,1x,i2,1x,i2,1x,i2,1x,f6.3,
     1       1x,f8.4,1x,f9.4,1x,f6.2,2x,f4.2)
      return
      end 
 
