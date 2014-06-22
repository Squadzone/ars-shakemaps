      subroutine readpar()
      use par
      use eventlistpar, only : ieflag
      implicit none
      integer                :: is, estat
      open(unit=61,file='parameter.dat',iostat=is,status='old')
      if (is/=0)then
           write(*,*)'parameter file doesnot exist, bye!'
           call exit(estat)
      endif
      read(61,*)iglit,itrend,ifilt,iresp
      read(61,*)taper
      read(61,*)norder, flcut, fhcut
      read(61,*) freq1, freq2, nfreq, damp
      read(61,*)ismooth, fbox
      read(61,*,iostat=is)elist
      ieflag=1
      if(is/=0)then
           elist='default.txt'
           ieflag=0
      endif
      open(unit=62,file='parameter.out',status='unknown')
      write(62,*)iglit,itrend,ifilt,iresp
      write(62,*)taper
      write(62,*)norder, flcut, fhcut
      write(62,*) freq1, freq2, nfreq, damp
      write(62,*)ismooth, fbox
      write(62,*)elist
      if (taper > .50) then
           write(*,*)' ERROR. Use taper<.5'
      endif
      close(unit=61)
      close(unit=62)
c     return
      end
