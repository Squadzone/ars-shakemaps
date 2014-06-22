      subroutine date2doy(year,month,day,doy)
      implicit none
      integer i, j, year, month, day, doy
      integer monthday(13,2)
      data monthday/0,31,28,31,30,31,30,31,31,30,31,30,31,
     1              0,31,29,31,30,31,30,31,31,30,31,30,31/
      j=1
      if(mod(year,4) == 0.and.mod(year,100) /= 0)j=2
      if(mod(year,4) == 0.and.mod(year,100) == 0
     1                   .and.mod(year,400) == 0)j=2
      doy=0
      do i=1,12,1
           doy=doy+monthday(i,j)
           if(i == month)then
                doy=doy+day
                return
           endif
      enddo
      return
      end
