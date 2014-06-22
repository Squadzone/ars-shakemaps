      subroutine response(f, accresp_out, velresp_out, dspresp_out)
      use respinfo
      implicit none
      integer                :: iz, ip
      real                   :: PI, W, f
      complex                :: accresp_out, velresp_out, dspresp_out
      double complex         :: accresp, velresp, dspresp, S
      PI=4.*atan(1.)
      if(f.eq.0.)f=0.01
      W=2.*PI*f
      S=dcmplx(0.0,W)
      velresp =dcmplx(A0*sensitivity,0.)
      if(nzero.gt.0)then
           do iz=1, nzero
                velresp = velresp*(S-dcmplx(z(iz)))
           enddo
      endif
      if(npole.gt.0)then
           do ip = 1, npole
                velresp = velresp/(S-dcmplx(p(ip)))
           enddo
      endif
      dspresp=velresp*S
      accresp=velresp/S

      velresp_out= cmplx(sngl(real(velresp)),sngl(dimag(velresp)))
      dspresp_out= cmplx(sngl(real(dspresp)),sngl(dimag(dspresp)))
      accresp_out= cmplx(sngl(real(accresp)),sngl(dimag(accresp)))

      return
      end

