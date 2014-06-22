      subroutine fork(lx,cx,signi)
c     fast fourier transform routine from Dave Boore.
c     result of sequence from time to freq to time requires no scaling.
      complex cx,carg,cexp,cw,ctemp
      dimension cx(lx)
      j=1
      sc=sqrt(1./lx)
c     write(*,*)'***** FAST FOURIER TRANSFORM CALLED *****'
      do 5 i=1,lx
           if(i .gt. j) go to 2
           ctemp = cx(j)*sc
           cx(j) = cx(i)*sc
           cx(i) = ctemp
2          m = lx/2
3          if(j .le. m) go to 5
           j = j - m
           m = m / 2
           if(m .ge. 1) go to 3
5     j = j + m
      l = 1
c     write(*,*)'First step completed'
6     istep = 2 * l
      temp = 3.14159265 * signi/l
      do 8 m = 1, l
           carg=(0., 1.) * temp * (m-1)
           cw=cexp(carg)
           do 8 i = m, lx, istep
                ctemp = cw *cx(i+l)
                cx(i+l) = cx(i) - ctemp
8     cx(i) = cx(i) + ctemp
      l = istep
      if(l .lt. lx) go to 6
c     write(*,*)'***** FAST FOURIER TRANSFORM DONE *****'
9     return
      end
