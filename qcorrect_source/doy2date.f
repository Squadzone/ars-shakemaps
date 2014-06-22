      subroutine doy2date(year,month,day,doy)
      implicit none
      integer                     :: year, month, day, doy
      integer                     :: i, j, monthday(13,2)
      data monthday/0,31,28,31,30,31,30,31,31,30,31,30,31,
     1              0,31,29,31,30,31,30,31,31,30,31,30,31/
      j=1
      if(mod(year,4) == 0.and.mod(year,100) /= 0)j=2
      if(mod(year,4) == 0.and.mod(year,100) == 0
     1                   .and.mod(year,400) == 0)j=2
      day=doy
      do i=1,12,1
           day=day-monthday(i,j)
           if(day <= monthday(i+1,j))then
                month=i
                return
           endif
      enddo
      month=i
      return
      end
