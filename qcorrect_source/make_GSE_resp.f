      subroutine make_GSE_resp()
      use traceinfo
      use respinfo
      implicit none
      integer                     :: i
      real                        :: PI
      double precision            :: sensGSE,sfactor
      character (len=30)          :: respname
      
      PI=4.*atan(1.)
      call doy2date(year,month,day,doy)
      respname(1:4)=staname
      do i=1,4,1
           if(respname(i:i).eq.' ')respname(i:i)='_'
      enddo 
      respname(5:5)='_'
      respname(6:7)=comp(1:2)
      respname(8:8)='_'
      respname(9:9)=comp(3:3)
      respname(10:10)='.'
      write(respname(11:14),'(i4.4)')year
      write(respname(15:29),10)month,day
10    format('-',i2.2,'-',i2.2,'-0000_GSE')
      sensGSE=10.**9/(sensitivity*2*PI*f0)
      sfactor=A0/10.**9
      open(unit=11,file=trim(respname),status='unknown')
      write(11,21)staname,comp,sensGSE,1/f0,year,month,day
21    format('CAL2 ',a5,1x,a3,13x,e10.2,1x,f7.3,18x,i4,'/',i2.2,'/',i2.2
     1,' 00:00')
c21   format('CAL2 ',a5,1x,a3,13x,e15.8,1x,f7.3,13x,i4,'/',i2.2,'/',i2.2
c    *,' 00:00')
      write(11,22)sfactor,npole,nzero+1
22    format('PAZ2  1 V ',e15.8,15x,i3,1x,i3,' Laplace transform')
      do i=1,npole,1
           write(11,23)real(p(i)),aimag(p(i))
      enddo
      do i=1,nzero,1
           write(11,23)real(z(i)),aimag(z(i))
      enddo
      write(11,23)0.,0.
23    format(2(1x,e15.8))
      write(11,24)sensitivity,sr
24    format('DIG2  2 ',e15.8,1x,f11.5)
      close(unit=11)
      return
      end
