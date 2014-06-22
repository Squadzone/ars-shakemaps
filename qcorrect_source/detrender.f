      subroutine detrender()
      use traceinfo
      use timeseries
      use par
      implicit none
      integer                     :: i
      double precision            :: x11=0., x12=0., x21=0.
      double precision            :: x22=0., y11=0., y21=0.
      x11=0.
      x12=0.
      x21=0.
      x22=0.
      y11=0.
      y21=0.
      if(itrend == 0)then
           detrended=deglitched
           trend_a=0.
           trend_b=0.
           return
      endif
      x12=dble(nsamp)
      do i=1,nsamp,1
           x11=x11+dble(i)
           x21=x21+dble(i**2.)
           y11=y11+dble(deglitched(i))
           y21=y21+dble(i*deglitched(i))
      enddo
      x22=x11
      trend_a=sngl((x22*y11-x12*y21)/(x11*x22-x12*x21))
      trend_b=sngl((x11*y21-x21*y11)/(x11*x22-x12*x21))
      detrended=0.
      do i=1,nsamp,1
           detrended(i)=deglitched(i)-(i*trend_a+trend_b)
      enddo
      return
      end
