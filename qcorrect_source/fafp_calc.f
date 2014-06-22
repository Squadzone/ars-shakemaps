      subroutine fafp_calc()
      use traceinfo
      use spectra
      implicit none
      integer                        :: i
      real                           :: x, y, PI
      complex, dimension (1050000)   :: tmp
      PI=4.*atan(1.)
      tmp=cmplx(100.,0)*acc_spec
      do i=1,npoint/2+1,1
           fa(i)=abs(tmp(i))*sqrt(real(npoint))/sr
           x=real(tmp(i))
           y=aimag(tmp(i))
           if(x > 0.)then
                fp(i)=atan(y/x)
           elseif(x == 0.and.y > 0.)then
                fp(i)=PI/2
           elseif(x == 0.and.y < 0.)then
                fp(i)=-PI/2
           elseif(x < 0.and.y >= 0.)then
                fp(i)=atan(y/x)+PI
           elseif(x < 0.and.y < 0.)then
                fp(i)=atan(y/x)-PI
           endif
      enddo
      return
      end

