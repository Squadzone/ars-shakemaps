      subroutine make_summary(freqpsa ,psa)
      use traceinfo
      use timeseries
      implicit none
      integer                     :: i
      real, dimension (1000)      :: freqpsa ,psa
      real, dimension (20)        :: psa_sum
      real                        :: pga,pgv
      pga=0.
      pgv=0.
      do i=1,npoint
          if(abs(vel(i))>pgv)pgv=abs(vel(i))
          if(abs(acc(i))>pga)pga=abs(acc(i))
      enddo
      psa_sum(1)=psa(1)
      psa_sum(2)=(psa(21)*psa(22)*psa(23)*psa(24)*psa(25))**0.2
      psa_sum(3)=(psa(37)*psa(38)*psa(39)*psa(40)*psa(41))**0.2
      psa_sum(4)=(psa(51)*psa(52)*psa(53)*psa(54)*psa(55))**0.2
      psa_sum(5)=(psa(73)*psa(74)*psa(75)*psa(76)*psa(77))**0.2
      psa_sum(6)=(psa(95)*psa(96)*psa(97)*psa(98)*psa(99))**0.2
      psa_sum(7)=(psa(108)*psa(109)*psa(110)*psa(111)*psa(112))**0.2
      psa_sum(8)=(psa(124)*psa(125)*psa(126)*psa(127)*psa(128))**0.2
      psa_sum(9)=(psa(146)*psa(147)*psa(148)*psa(149)*psa(150))**0.2
      psa_sum(10)=(psa(169)*psa(170)*psa(171)*psa(172)*psa(173))**0.2
      write(57,58)staname,comp,stalat,stalon,stdist,(psa_sum(i),i=1,10),
     1            pga,pgv
c      write(57,58)staname,comp,stdist,(psa_sum(i),i=1,10),pga,pgv
58    format(a4,3x,a3,4x,2(f8.3,2x),f7.2,2x,12(e9.4,x))
      return
      end


