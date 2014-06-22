      subroutine find_event()
      use datapar
      use eqpar
      use eventlistpar
      implicit none
      integer                     :: i, doy, is, i_skip
      double precision            :: secfile, seclist
      character (len=80)          :: line
      i_skip=0
      call system('rdseed -t -f '//trim(SEEDfile)//' > tmp.txt')
      open(unit=70,file='tmp.txt',status='old')
      do while (.true.)
          read(70,'(a)')line
          if(index(line,'Rec#')>1)exit
      enddo 
c      call skipline(70,5)
      read(70,71,iostat=is)filedate(1),doy,filedate(4:6)
71    format(27x,i4,1x,i3,1x,3(i2,1x))
      close(unit=70)
      call system('rm -f tmp.txt')
      if(is /= 0)then
           filedate=0
           doy=0
           secfile=0.
      else
           call doy2date(filedate(1),filedate(2),filedate(3),doy)
           call julsec(filedate,secfile)
      endif
      if(ieflag == 1)then
           do i=1,n_eventlist
                read(eventlist(i),72)eqdate(1:6),eqcoord(1:3),eqmag
72              format(86x,i4,2(1x,i2),1x,3(1x,i2),
     1                  2x,f6.2,1x,f8.2,1x,f4.1,3x,f3.1)
                call julsec(eqdate,seclist)
                if(abs(seclist-secfile) < 300.) return
           enddo
      endif
      eqdate=filedate
      eqmsecond=0.0
      eqcoord=0.0
      eqmag=0.0
      return
      end
