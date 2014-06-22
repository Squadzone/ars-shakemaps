      subroutine make_result_()
      use traceinfo
      use timeseries
      implicit none
      integer                     :: i, nunit=34
      character (len=80)          :: fname='result_'
      nunit=34
      fname='result_'
      open(unit=nunit,file=fname,status='unknown')
      write(nunit,'(g13.6)')sr,(acc(i),i=1,npoint)
      close(unit=nunit)
      return
      end
