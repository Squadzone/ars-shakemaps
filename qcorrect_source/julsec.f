      subroutine julsec(dtime_in,sec)
C     Julian day number formula taken from wikipedia + added seconds
      implicit none
      integer                        :: i
      integer, dimension(6)          :: dtime_in
      double precision               :: sec
      double precision, dimension(6) :: dtime
      do i=1,6
           dtime(i)=dble(dtime_in(i))
      enddo
      sec=(dtime(3)+((153.*dtime(2)+2.)/5.)+365.*dtime(1)+dtime(1)/4.
     1    -dtime(1)/100.+dtime(1)/400.-32045.)*86400.+dtime(4)*3600.+
     2     dtime(5)*60.+dtime(6)
      return
      end 
