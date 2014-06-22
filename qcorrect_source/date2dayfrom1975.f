      subroutine date2dayfrom1975(year,doy,nday)
      implicit none
      integer i, year, doy, nday, daysofyear

      nday=0
      do i=1975,year-1,1
          daysofyear=365
          if(mod(i,4).eq.0.and.mod(i,100).ne.0)daysofyear=366
          if(mod(i,4).eq.0.and.mod(i,100).eq.0
     1                    .and.mod(i,400).eq.0)daysofyear=366
          nday=nday+daysofyear
      enddo
      nday=nday+doy
      return
      end
