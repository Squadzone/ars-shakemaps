      subroutine make_FAP_resp()
      use respinfo
      implicit none
      integer                     :: i
      real                        :: f, phase
      complex                     :: accresp, velresp, dspresp
      open(unit=12,file='Response.FAP',status='unknown')
      write(12,20)
20    format(' Freq.(Hz)     Disp.Ampl.    Disp.Phase     Vel.Ampl.     
     1Vel.Phase     Acc.Ampl.    Acc.Phase')
      do i=0,200,1
           f=10.**(-2.+real(i)*0.02)
           call response(f, accresp, velresp, dspresp)
           write(12,21)f,cabs(dspresp),phase(dspresp),cabs(velresp),
     1     phase(velresp),cabs(accresp),phase(accresp)
21         format(7(1x,g12.5,1x))
      enddo
      close(unit=12)
      return
      end
