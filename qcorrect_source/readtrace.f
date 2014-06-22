      subroutine readtrace(fname)
      use traceinfo
      implicit none
      integer                :: nunit=50, i, j(3)
      real                   :: sample_interval, free1
      character (len=*)      :: fname
      nunit=50
      open(unit=nunit,file=fname,status='old')
      read(nunit,*)sample_interval
      sr=1/sample_interval
      call skipline(nunit,5)
      read(nunit,*)free1,stalat,stalon,stah
      call skipline(nunit,7)
      read(nunit,*)year, doy, hour, minute, second
      read(nunit,*)milsec, (j(i),i=1,3), nsamp
      write(event,51)year,doy
51    format(i4.4,'/',i3.3,'    ')
      write(stime,52)hour, minute, second, milsec
52    format(2(i2.2,':'),i2.2,'.',i3.3)
      call skipline(nunit,6)
      read(nunit,'(a4)')staname
      call skipline(nunit,5)
      read(nunit,'(16x,a3)')comp
      call skipline(nunit,1)
      trace=0.
      read(nunit,*) (trace(i),i=1,nsamp)
      close(unit=nunit)
      return
      end
