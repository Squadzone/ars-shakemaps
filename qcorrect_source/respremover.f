      subroutine respremover()
      use par
      use traceinfo
      use spectra
      implicit none
      integer                     :: i, ncalc
      real                        :: f, PI, W, W0
      complex                     :: S, accresp, velresp, dspresp

      PI=4.*atan(1.)
      ncalc=npoint/2+1
      W0=2.*PI*sr/real(npoint)
      if(iresp == 0)then
           do i=1,ncalc,1
                W=real(i-1)*W0
                S=cmplx(0.,W)
                if(i /= 1)then
                     disp_spec(i)=filtered(i)/S
                     disp_spec(npoint+2-i)=disp_spec(i)
                else
                     disp_spec(i)=filtered(i)/cmplx(0.,W0/100)
                endif
                vel_spec(i)=filtered(i)
                acc_spec(i)=filtered(i)*S
                if(i > 1)then
                     disp_spec(npoint+2-i)=conjg(disp_spec(i))
                     vel_spec(npoint+2-i)=conjg(vel_spec(i))
                     acc_spec(npoint+2-i)=conjg(acc_spec(i))
                endif
           enddo
      else
           do i=1,ncalc,1
                f=real(i-1)*sr/real(npoint)
                call response(f,accresp,velresp,dspresp)
                disp_spec(i)=filtered(i)/dspresp
                vel_spec(i)=filtered(i)/velresp
                acc_spec(i)=filtered(i)/accresp
                if(i > 1)then
                     disp_spec(npoint+2-i)=conjg(disp_spec(i))
                     vel_spec(npoint+2-i)=conjg(vel_spec(i))
                     acc_spec(npoint+2-i)=conjg(acc_spec(i))
                endif
           enddo
      endif
      return
      end
