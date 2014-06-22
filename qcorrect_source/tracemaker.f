      subroutine tracemaker()
      use traceinfo
      use timeseries
      use spectra
      implicit none
      complex, dimension (1050000) :: temp
      temp=disp_spec
      call fork(npoint, temp, +1.)
      disp=real(temp)
      temp=vel_spec
      call fork(npoint, temp, +1.)
      vel=real(temp)
      temp=acc_spec
      call fork(npoint, temp, +1.)
      acc=100.*real(temp)                         !This is to convert m/s^2 to cm/s^2
      return
      end

